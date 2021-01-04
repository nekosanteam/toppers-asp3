#include <stdio.h>
#include <stdlib.h>
#include <setjmp.h>

typedef long				intptr_t;	/* ポインタを格納できる符号付き整数 */
typedef unsigned long       uintptr_t;

jmp_buf point1;
jmp_buf point2;

void func1()
{
    setjmp(point1);
	printf("enter func1()\n");
	printf("leave func1()\n");
}

void func2()
{
	printf("enter func2()\n");
	printf("leave func2()\n");
	longjmp(point2, 1);
}

#if defined(__aarch64__) || defined(__arm__)
extern uintptr_t __pointer_chk_guard_local __attribute__ ((section (".data.rel.ro"))) __attribute__ ((visibility ("hidden"))) __attribute__ ((nocommon));
#endif
void* functions[] = { func1, func2 };

int main(void)
{
    int i;
    int s;
    unsigned int x;
    intptr_t pc;
    intptr_t sp;

#if defined(__i386__)
#  define JMPBUF_PC			5			/* jmp_buf中でのPCの位置 */
#  define JMPBUF_SP			4			/* jmp_buf中でのSPの位置 */
#  define PTR_MANGLE(var)	asm ("xorl %%gs:%c2, %0\n"		  \
	            			     "roll $9, %0"			      \
				                 : "=r" (var)			      \
				                 : "0"  (var),			      \
				                   "i"  (0x18))
#  define PTR_DEMANGLE(var)	asm ("rorl $9, %0\n"			  \
				                 "xorl %%gs:%c2, %0"		  \
				                 : "=r" (var)			      \
				                 : "0"  (var),			      \
				                   "i"  (0x18))

#elif defined(__x86_64__)
#  define JMPBUF_PC			7			/* jmp_buf中でのPCの位置 */
#  define JMPBUF_SP			6			/* jmp_buf中でのSPの位置 */
#  define LP_SIZE           "8"
#  define PTR_MANGLE(var)	asm ("xor %%fs:%c2, %0\n"		  \
	            			     "rol $2*" LP_SIZE "+1, %0"   \
				                 : "=r" (var)	    		  \
			            	     : "0"  (var),			      \
				                   "i"  (0x30))
#  define PTR_DEMANGLE(var)	asm ("ror $2*" LP_SIZE "+1, %0\n" \
            				     "xor %%fs:%c2, %0"			  \
			            	     : "=r" (var)			      \
			            	     : "0"  (var),			      \
				                   "i"  (0x30))

#elif defined(__aarch64__)
#  define JMPBUF_PC			11			/* jmp_buf中でのPCの位置 */
#  define JMPBUF_SP			13			/* jmp_buf中でのSPの位置 */
#  define PTR_MANGLE(var) \
  (var) = (__typeof (var)) ((uintptr_t) (var) ^ __pointer_chk_guard_local)
#  define PTR_DEMANGLE(var)     PTR_MANGLE (var)

#elif defined(__arm__)
#  define JMPBUF_PC			1			/* jmp_buf中でのPCの位置 */
#  define JMPBUF_SP			0			/* jmp_buf中でのSPの位置 */
#  define PTR_MANGLE(var) \
  (var) = (__typeof (var)) ((uintptr_t) (var) ^ __pointer_chk_guard_local)
#  define PTR_DEMANGLE(var)     PTR_MANGLE (var)

#else
# error architecture not supported
#endif

    s = sizeof(point1);
    printf("jmpbuf size = %d\n", s);
    printf("pointer size = %d\n", sizeof(int*));
    printf("intptr_t size = %d\n", sizeof(intptr_t));

    func1();
    for (i=0; i<s; i++) {
        x = *(((unsigned char*)&point1) + i);
        printf("%02x ", x);
        if (i%16 == 15) {
            printf("\n");
        }
    }
    printf("\n");
    printf("func1 addr  = %p\n", func1);
    printf("func2 addr  = %p\n", func2);
    printf("sp addr     = %p\n", &x);
    printf("jmpbuf addr = %p\n", &point1);
    pc = *(intptr_t*)(&point1[0].__jmpbuf[JMPBUF_PC]);
    sp = *(intptr_t*)(&point1[0].__jmpbuf[JMPBUF_SP]);
    printf("jmpbuf_pc = %016lx\n", pc);
    printf("jmpbuf_sp = %016lx\n", sp);
    PTR_DEMANGLE(pc);
    PTR_DEMANGLE(sp);
    printf("real_pc   = %016lx\n", pc);
    printf("real_sp   = %016lx\n", sp);

	if (setjmp(point2) == 0) {
		pc = (intptr_t)func2;
		PTR_MANGLE(pc);
		*(intptr_t*)(&point1[0].__jmpbuf[JMPBUF_PC]) = pc;
		longjmp(point1, 1);
	}
	else {
		printf("return line\n");
	}

    return 0;
}