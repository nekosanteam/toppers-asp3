/*
 *  TOPPERS/SSP Kernel
 *      Smallest Set Profile Kernel
 * 
 *  Copyright (C) 2008 by Embedded and Real-Time Systems Laboratory
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2010 by Meika Sugimoto
 * 
 *  �嵭����Ԥϡ��ʲ���(1)��(4)�ξ������������˸¤ꡤ�ܥ��եȥ���
 *  �����ܥ��եȥ���������Ѥ�����Τ�ޤࡥ�ʲ�Ʊ���ˤ���ѡ�ʣ������
 *  �ѡ������ۡʰʲ������ѤȸƤ֡ˤ��뤳�Ȥ�̵���ǵ������롥
 *  (1) �ܥ��եȥ������򥽡��������ɤη������Ѥ�����ˤϡ��嵭������
 *      ��ɽ�����������Ѿ�浪��Ӳ�����̵�ݾڵ��꤬�����Τޤޤη��ǥ���
 *      ����������˴ޤޤ�Ƥ��뤳�ȡ�
 *  (2) �ܥ��եȥ������򡤥饤�֥������ʤɡ�¾�Υ��եȥ�������ȯ�˻�
 *      �ѤǤ�����Ǻ����ۤ�����ˤϡ������ۤ�ȼ���ɥ�����ȡ�����
 *      �ԥޥ˥奢��ʤɡˤˡ��嵭�����ɽ�����������Ѿ�浪��Ӳ���
 *      ��̵�ݾڵ����Ǻܤ��뤳�ȡ�
 *  (3) �ܥ��եȥ������򡤵�����Ȥ߹���ʤɡ�¾�Υ��եȥ�������ȯ�˻�
 *      �ѤǤ��ʤ����Ǻ����ۤ�����ˤϡ����Τ����줫�ξ�����������
 *      �ȡ�
 *    (a) �����ۤ�ȼ���ɥ�����ȡ����Ѽԥޥ˥奢��ʤɡˤˡ��嵭����
 *        �ɽ�����������Ѿ�浪��Ӳ�����̵�ݾڵ����Ǻܤ��뤳�ȡ�
 *    (b) �����ۤη��֤��̤�������ˡ�ˤ�äơ�TOPPERS�ץ��������Ȥ�
 *        ��𤹤뤳�ȡ�
 *  (4) �ܥ��եȥ����������Ѥˤ��ľ��Ū�ޤ��ϴ���Ū�������뤤���ʤ�»
 *      ������⡤�嵭����Ԥ����TOPPERS�ץ��������Ȥ����դ��뤳�ȡ�
 *      �ޤ����ܥ��եȥ������Υ桼���ޤ��ϥ���ɥ桼������Τ����ʤ���
 *      ͳ�˴�Ť����ᤫ��⡤�嵭����Ԥ����TOPPERS�ץ��������Ȥ�
 *      ���դ��뤳�ȡ�
 * 
 *  �ܥ��եȥ������ϡ�̵�ݾڤ��󶡤���Ƥ����ΤǤ��롥�嵭����Ԥ�
 *  ���TOPPERS�ץ��������Ȥϡ��ܥ��եȥ������˴ؤ��ơ�����λ�����Ū
 *  ���Ф���Ŭ������ޤ�ơ������ʤ��ݾڤ�Ԥ�ʤ����ޤ����ܥ��եȥ���
 *  �������Ѥˤ��ľ��Ū�ޤ��ϴ���Ū�������������ʤ�»���˴ؤ��Ƥ⡤��
 *  ����Ǥ�����ʤ���
 * 
 */

/*
 *  �ץ����å���¸�⥸�塼�� ������֥��������ARM-M�ѡ�
 */

#define TOPPERS_MACRO_ONLY
#define UINT_C(val)		(val)		/* uint_t�����������ޥ��� */
#define ULONG_C(val)	(val)		/* ulong_t�����������ޥ��� */
#define CAST(type, val)	(val)		/* �����㥹�Ȥ�Ԥ��ޥ��� */

#include "kernel_impl.h"
#include "arm_m.h"


	.text

/*
 *  ��������
 */
	.global		intnest

/*
 *  CPU�㳰����ȥ�
 *
 *  ����ߥ���ȥ�Ƚ��������Ƥ�Ʊ�������������μ��ब�ۤʤ뤿�ᡤ
 *  ʬ���Ƥ��롥
 */
	.align 2
	.syntax unified
	.code 16
	.global exc_entry
	.type exc_entry, function
exc_entry:
	/*
	 *  �㳰/����ߤ�ȯ������ȡ�ȯ�����˥����ƥ��֤ʥ����å��˥�����
	 *  �å��쥸����������¸����롥
	 *  �������Ƥ˲ä��ơ�CPU�㳰�ϥ�ɥ�ؤξ���Ȥ��ơ�basepri ���ͤȡ�
	 *  EXC_RETURN�ξ����ä�����¸���롥basepri���ͤϡ�CPU�㳰�����
	 *  �꥿������˳����ͥ���٥ޥ������ͤ򸵤��᤹����ˤ��Ѥ����롥
	 *
	 *   -----------
	 *  | EXC_RETURN|  
	 *   -----------
	 *  |  basepri  |  
	 *   -----------
	 *  |    R0     |  
	 *   -----------
	 *  |    R1     |
	 *   -----------
	 *  |    R2     |
	 *   -----------
	 *  |    R3     |
	 *   -----------
	 *  |    R12    |
	 *   -----------
	 *  |    LR     |
	 *   -----------
	 *  |    PC     |
	 *   -----------
	 *  |   xPSR    |
	 *   -----------
	 *
	 */

	/*
	 *  �����ȯ�����γ����ͥ���٥ޥ����򥹥��å�����¸���뤿�����
	 */
	mrs   r2, basepri			/* baepri���ͤ���� */
	push  {r2}					/* �����ȯ�����γ����ͥ���٥ޥ������Ѥ� */
	push  {lr}					/* EXC_RETURN ���Ѥ�			  */ 
	mov   r0, sp				/* CPU�㳰�ϥ�ɥ�ؤΰ����Ȥʤ� */
	
	ldr   r1 , =lock_flag		/* CPU���å��ե饰����¸ */
	ldr   r1 , [r1]
	push  {r1}
	
	/* ����ߥͥ��ȿ��βû� */
	ldr r1 , =intnest
	ldr r3 , [r1]
	add r3 , #1
	str r3 , [r1]

	/*
	 *  ���̽���
	 */
exc_entry_2:
	mrs   r3, ipsr               /* �ϥ�ɥ饢�ɥ쥹����� */
	ldr   r1, =_kernel_exc_tbl
	ldr   r2, [r1, r3, lsl #2]
	
#ifdef LOG_EXC_ENTER
	push  {r0, r2, r3}
	mov   r0, r3                 /* �㳰�ֹ��ѥ�᡼����  */
	bl    log_exc_enter          /* log_exc_enter��ƤӽФ� */
	pop   {r0, r2, r3}
#endif /* LOG_EXC_ENTER */

#ifdef LOG_EXC_LEAVE
	push  { r3 }                   /* �㳰�ֹ�򥹥��å���    */
#endif /* LOG_EXC_LEAVE */

	/*
	 *  CPU�㳰�ϥ�ɥ�θƤӽФ�
	 */
	blx   r2

	/* CPU���å��ե饰�򸵤��᤹ */
	pop   {r0}
	ldr   r1 , =lock_flag
	str   r0 , [r1]
	
#ifdef LOG_EXC_LEAVE
	pop   { r0 }                   /* �㳰�ֹ�������        */
	bl    log_exc_leave          /* log_exc_leave��ƤӽФ� */
#endif /* LOG_EXC_LEAVE */
	
	b     ret_exc


/*
 *  ����ߥ���ȥ�
 */
	.align 2
	.syntax unified
	.code 16
	.global int_entry
	.type int_entry, function
int_entry:
	/*
	 *	�����ȯ�����γ����ͥ���٥ޥ����򥹥��å�����¸���뤿�����
	 */
	mrs   r2, basepri			  /* baepri���ͤ���� */
	push  {r2}					 /* �����ȯ�����γ����ͥ���٥ޥ������Ѥ� */
	push  {lr}					 /* EXC_RETURN ���Ѥ�			  */ 
	mov   r0, sp				 /* ̤����γ���ߤ�ȯ���������ξ���Ȥ��� */
	
	/*
	 *	���̽���
	 */
int_entry_2:
	/* ����ߥͥ��ȿ��βû� */
	ldr r1 , =intnest
	ldr r3 , [r1]
	add r3 , #1
	str r3 , [r1]
	
	mrs   r3, ipsr				 /* �ϥ�ɥ饢�ɥ쥹����� */
	ldr   r1, =_kernel_exc_tbl
	ldr   r2, [r1, r3, lsl #2]

#ifdef LOG_INH_ENTER
	push  {r0,r2,r3}
	mov   r0, r3                 /* ������ֹ��ѥ�᡼����  */
	bl    log_inh_enter          /* log_inh_enter��ƤӽФ� */
	pop   { r0,r2,r3 }
#endif /* LOG_INH_ENTER */

#ifdef LOG_INH_LEAVE
	push  { r3 }                   /* ������ֹ�򥹥��å���    */
#endif /* LOG_INH_LEAVE */

	/*
	 *  CPU�㳰�ϥ�ɥ�θƤӽФ�
	 */
	blx   r2
	
#ifdef LOG_INH_LEAVE
	pop   { r0 }                   /* ������ֹ�������        */
	bl    log_inh_leave          /* log_inh_leave��ƤӽФ� */
#endif /* LOG_INH_LEAVE */

/*
 *  �����/�㳰�и�
 *
 *  ret_exc/ret_int�ϡ�CPU�㳰/����ߥϥ�ɥ餫����ä�ľ��˼¹Ԥ���
 *  �롼����Ǥ��롥
 */
ret_exc:
ret_int:
	/*
	 *  ����ߥ��å����֤Ȥ��롥���λ����Ǥϡ�CPU���å����֤ˤϤʤ�ʤ�
	 * ��basepri��lock_flag��saved_iipm�Ϲ������ʤ��ˡ�
	 *
	 *  ����ߥ��å����֤Ȥ���Τϡ������Υ���ƥ����ȤΥ����å��ȡ�
	 *  ����褬�󥿥�������ƥ����ȤǤ��ä����Υ꥿����򥢥ȥߥå�
	 *  �˹Ԥ�����Ǥ��롥bsepri��CPU���å����ͤˤ��뤳�ȤǤ⥢�ȥߥ�
	 *  ���ʥ����å��������ϲ�ǽ�Ǥ��뤬������ߤ���꥿���󤷤Ƥ⡤
	 *  basepri ���������Ƥϸ������ʤ����ᡤ���Ѥ��뤳�Ȥ��Ǥ��ʤ��� 
	 *  ������FAULTMASK�ϡ�����ߤ���Υ꥿��������ˤ�äơ�'0'�˥���
	 *  ������롥
	 */
	cpsid f
	
	/*
	 *  �����Υ���ƥ����Ȥ�Ƚ��
	 * 
	 *  intnest��0���ɤ�����Ƚ�Ǥ���
	 *  
	 */
	/* ����ߥͥ��ȿ��θ��� */
	ldr r1 , =intnest
	ldr r3 , [r1]
	add r3 , #-1
	str r3 , [r1]
	
	cmp   r3 , #0
	beq   ret_int_2
	
	/*
	 *  �����ܤγ���ߤνи�����
	 */
ret_int_1:
	/*
	 *  �����ˤϳ���ߥ��å����֡�FAULTMASK�����åȡˤ��줿���֤���롥
	 *  Thread�⡼�ɤ���Υ꥿����ˤ�꼫ưŪ�˳���ߥ��å�������֤ˤʤ롥
	 *  �����ͥ���٥ޥ����ϳ�������˾��֤��᤹��
	 */ 
	pop		{ r2 }
	pop		{ r1 }
	msr   basepri, r1			  /* �����ͥ���٥ޥ������������˾��֤� */
	bx	  r2					  /* �꥿���� */
	
ret_int_2:
	ldr   r0, =reqflg             /* reqflg��false�ʤ餽�Τޤ���� */
	ldr   r1, [r0]
	cmp   r1 , #0
	beq    ret_int_1           /* false�ʤ�ret_int_1��           */
ret_int_3:
	mov   r1, #0                   /* reqflg��false�� */
	str   r1, [r0]
	
	/*
	 *  CPU���å����֤˰ܹԤ��롥
	 *
	 *  �����ͥ�δ�����γ���ߤ�ػߤ���褦��basepri�����ꤷ��
	 *  lock_flag�򹹿����롥
	 *  ���λ�����CPU���å����֤Ȥ���Τϡ�dispatcher��ʬ���������
	 *  CPU���å����֤ˤʤäƤ���ɬ�פ����뤿��Ǥ��롥
     *  �ʤ������ν����θ塤Thread�⡼�ɤؤΰܹԽ�����Ԥʤ����ᡤ�����
     *  ���å�����(FAULTMASK��"1")���ݻ����롥
	 */
	ldr   r1, =IIPM_LOCK		  /* CPU���å����� */ 
	msr   basepri, r1
	mov   r1, #0x01 			  /* lock_flag �� true�� */
	ldr   r0, =lock_flag 
	str   r1, [r0]
	
	/*
	 *  lr����Ф����������ٱ�ǥ����ѥå��κݤˤ�Ȥ����ᡤ
	 *  �����å��ݥ��󥿤����ʤ���
	 */
	
	ldr   r2 , [sp]
	
	/*
	 *  Thread�⡼�ɤذܹԤ��롥
	 *
	 *  dispatcher��call_texrn��ƤӽФ����ϡ�Thread�⡼�ɤǤ���ɬ
	 *  �פ����뤿�ᡤPSP�����å���˥��ߡ����㳰�ե졼����֤��ơ�
	 *  ����Ū�˳���ߥϥ�ɥ餫��꥿���󤹤롥
	 *  �꥿�����Ʊ����FAULTMASK����ưŪ�˥��ꥢ���졤�����ͥ��������
	 *  ����ߤ����Ĥ���롥
	 */
	ldr   r0, =ret_int_4		  /* PC   */
	ldr   r1, =EPSR_T			  /* xPSR(T�ӥåȤ�'1'�Ǥ���ɬ�פ�����) */
	stmfd sp!, {r0-r1}			  /* ���ߡ��ե졼��򥹥��å�����Ѥ�	*/
	sub   sp, #(EXC_FRAME_SIZE - (4*2)) /* r0-r3,r12,lr�����Ƥ����ꤹ��ɬ�פ��ʤ� */
	bx	  r2					  /* Thread�⡼�ɤذܹ� */
    
ret_int_4:
	bl    search_schedtsk		/* �������ǵ�ư���줿��������¹� */
	bl    run_task
ret_int_r:
	svc   0 				   /* SVC�θƤӽФ� */
	
/*
 *  �ٱ�ǥ����ѥå�������������˰��Ū�˳����
 *  ����ƥ����Ȥ˰ܹԤ��뤿���SVC������ϥ�ɥ�
 */

	.align	2
	.thumb
	.thumb_func
	.globl kernel_svc_handler
kernel_svc_handler:
	/*
	 *  ����߽�������Υ꥿����ˤ�ꡤCPU���å�������֤˰ܹԤ����
	 *  ���������롥
	 */
	cpsid f 								/* ����ߥ��å����֤� */
	ldr		r2 , [ sp , #(EXC_FRAME_SIZE) ]	/* lr�򥹥��å��������	*/
	add		sp, #EXC_FRAME_SIZE + 8			/* �����å���ΤƤ�	*/
	mov		r0, #0
	ldr		r1, =lock_flag					/* CPU���å�������֤� */
	str		r0, [r1]
	msr		basepri , r0 
	bx		r2								/* �꥿����	  */

/*
 *  �ǥ����ѥå����ư���
 */
	.align	2
	.thumb
	.thumb_func
	.globl start_dispatch
start_dispatch:
	/*
	 *  ���Υ롼����ϡ������ͥ뵯ư���ˡ����٤Ƥγ���ߤ�ػߤ�������
	 * �ʳ���ߥ��å����֤�Ʊ���ˤǸƤӽФ���롥�ޤ�������ߥ⡼�ɡ���
	 *  ����������ƥ����Ȥ�Ʊ���ˤǸƤӽФ���뤳�Ȥ����ꤷ�Ƥ��롥
	 *
	 *  prc_initialize�ǡ�lock_flag��true�ˡ�saved_iipm��IIPM_ENAALL��
	 *  ��������Ƥ��뤿�ᡤ�����ͥ�������γ���ߤ���Ĥ��뤳�Ȥǡ�
	 *  CPU���å����֡��ʥ�ǥ��Ρ˳����ͥ���٥ޥ�����������֤ˤʤ롥
	 *  �ޤ���task_initialize��disdsp��false�˽�������Ƥ��뤿�ᡤ�ǥ�
	 *  ���ѥå����ľ��֤ˤʤäƤ��롥
	 */
	ldr   r0,=istkpt              /* MSP������   */
	ldr   r1,[r0]                 /* start_dispatch�ƤӽФ����˸ƤӽФ��Ѥ� */
	msr   msp, r1                 /* ���Ѥ��Ƥ��뤿����������             */
	ldr   r1, =IIPM_LOCK          /* �����ͥ������γ���ߤ�ػ� */
	msr   basepri, r1 
	cpsie f                       /* �����ͥ�������γ���ߤ���� */
	b	  dispatcher

/*
 *  �����ͥ�ν�λ�����θƽФ�
 *
 *  �����å����󥿥�������ƥ������Ѥ��ڤ��ؤ���
 *  
 */
	.text
	.syntax unified
	.code 16
	.globl call_exit_kernel
	.type call_exit_kernel, function
call_exit_kernel:
	b     exit_kernel       /* �����ͥ�ν�λ������Ƥ� */


/*
 *  ���������Ԥ�
 */
	.text
	.syntax unified
	.code 16
	.globl sil_dly_nse
	.type sil_dly_nse, function
sil_dly_nse:
	sub   r0, r0, #SIL_DLY_TIM1
	cmp   r0, #0
	bgt   sil_dly_nse1
	mov   pc, lr
sil_dly_nse1:
	sub   r0, r0, #SIL_DLY_TIM2
	cmp   r0, #0
	bgt   sil_dly_nse1
	mov   pc, lr