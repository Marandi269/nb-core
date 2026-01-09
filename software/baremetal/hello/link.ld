/* RISC-V链接脚本 - 裸机程序 */

OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    /* RAM从0x80000000开始（匹配CPU的PC初始值） */
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 8K
}

SECTIONS
{
    /* 代码段从RAM起始地址开始 */
    .text : {
        *(.text.start)
        *(.text*)
    } > RAM

    /* 只读数据 */
    .rodata : {
        *(.rodata*)
    } > RAM

    /* 数据段 */
    .data : {
        *(.data*)
    } > RAM

    /* BSS段（未初始化数据） */
    .bss : {
        *(.bss*)
        *(COMMON)
    } > RAM

    /* 丢弃不需要的段 */
    /DISCARD/ : {
        *(.note*)
        *(.comment*)
        *(.eh_frame*)
    }
}
