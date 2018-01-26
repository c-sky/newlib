/* int __hosted (int sys_operate, int *args); */
.text
.global __hosted
.type   __hosted, @function
.align 2

__hosted:
    nop
    bkpt
    .long 0x7fff7fff
    rts
