PROVIDE(hardware_init_hook = 0);
PROVIDE(software_init_hook = 0);
PROVIDE(software_term_hook = 0);

SECTIONS
{
    . = 0x8000;

    /* .text : プログラムコードが入る領域 */
    .text : {
        KEEP(*(.text.boot))
        *(.text .text.* .gnu.linkonce.t*)
    }

    /* .rodata : 変更されない文字列とか定数などが入る領域 */
    .rodata : {
        *(.rodata .rodata.* .gnu.linkonce.r*)
    }

    PROVIDE(_data = .);

    /* .data : 初期値を持った変数などを置く領域 */
    __start_idata = .;
    .data : {
        __start_data = .;
        *(.data .data.* .gnu.linkonce.d*)
        __end_data = .;
    }
    __end_idata = __start_idata + SIZEOF(.data);

    /* .bss : 初期値を持たない変数などを置く領域 */
    .bss (NOLOAD) : {
        . = ALIGN(16);
        __start_bss = .;
        *(.bss .bss.*)
        *(COMMON)
        __end_bss = .;
    }

    _end = .;

    /* 入力セクション破棄 */
    /DISCARD/ : {
        *(.comment)
        /* *(.gnu*) */
        *(.note*)
        *(.eh_frame*)
    }
}
