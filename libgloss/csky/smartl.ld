/*
 * smartl.ld -- Linker script for QEMU -machine smartl board emulation.
 */

ENTRY(__start)
SEARCH_DIR(.)
GROUP(-lgcc -lc -lcsky)

MEMORY
{
	DATA   : ORIGIN = 0x20000000 , LENGTH = 0x01000000  /* 16M */
	INST   : ORIGIN = 0x60000000 , LENGTH = 0x01000000  /* 16M*/
	EEPROM : ORIGIN = 0x00000000 , LENGTH = 0x01000000  /* 16M*/
}

PROVIDE (__stack =  0x01000000 - 0x8);
PROVIDE (__heap_start = 0x00000100);
PROVIDE (__heap_end = 0x00900000);
PROVIDE (__csky_exit = 0x10002000);

REGION_ALIAS("REGION_TEXT",   INST);
REGION_ALIAS("REGION_RODATA", DATA);
REGION_ALIAS("REGION_DATA",   DATA);
REGION_ALIAS("REGION_BSS",    DATA);

/* force exit to be picked up in a hosted or os environment */
EXTERN(exit atexit)

/* Ensure that newlib runs the finalizers */
__libc_fini = _fini;

SECTIONS
{
  .text :
  {
    _start_text = .;
    *(.text .text.* .gnu.linkonce.t.*)

    . = ALIGN(0x4);
    KEEP (*crtbegin.o(.jcr))
    KEEP (*(EXCLUDE_FILE (*crtend.o) .jcr))
    KEEP (*crtend.o(.jcr))

  } > REGION_TEXT

  /* Exception handling sections are text-like.  */
  .gcc_except_table : ALIGN (4)
  {
    *(.gcc_except_table .gcc_except_table.*)
    *(.gnu_extab .gnu_extab.*)
  } > REGION_TEXT
  .eh_frame_hdr : ALIGN (4)
  {
    KEEP (*(.eh_frame_hdr))
    *(.eh_frame_entry .eh_frame_entry.*)
  } > REGION_TEXT
  .eh_frame : ALIGN (4)
  {
    KEEP (*(.eh_frame)) *(.eh_frame.*)
  } > REGION_TEXT
  .note.gnu.build-id : ALIGN (4)
  {
    KEEP (*(.note.gnu.build-id))
  } > REGION_TEXT

  /* Initialization code also needs to be in the text segment.  */
  .init_fini : ALIGN (4)
  {
    . = ALIGN(4);
    KEEP(*(.init))

    . = ALIGN(4);
    __preinit_array_start = .;
    KEEP (*(.preinit_array))
    __preinit_array_end = .;

    . = ALIGN(4);
    __init_array_start = .;
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array))
    __init_array_end = .;

    . = ALIGN(4);
    KEEP(*(.fini))

    . = ALIGN(4);
    __fini_array_start = .;
    KEEP (*(.fini_array))
    KEEP (*(SORT(.fini_array.*)))
    __fini_array_end = .;

    . = ALIGN(0x4);
    KEEP (*crtbegin.o(.ctors))
    KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*crtend.o(.ctors))

    . = ALIGN(0x4);
    KEEP (*crtbegin.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*crtend.o(.dtors))

    . = ALIGN (8);
    _etext = .;

  } > REGION_TEXT

  /* Read-only data, e.g. string constants.  */
  .rodata : ALIGN (4)
  {
    *(.rodata .rodata.* .gnu.linkonce.r.*)
    *(.lit)
  } > REGION_RODATA

  /* Writeable data.  */
  .data : ALIGN (8)
  {
    _start_data = .;
    *(.shdata)
    *(.data .data.* .gnu.linkonce.d.*)
    . = ALIGN(8);
    *(.got.plt) *(.got)
    *(.lit8)
    *(.lit4)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
    . = ALIGN (8);
    *(.ram)
    . = ALIGN (8);
    _edata = .;
    _end_data = .;
  } > REGION_DATA

  /* BSS, zero-initialized by crt0.S.  */
  .bss : ALIGN (8)
  {
    __sbss = . ;
    __bss_start = . ;
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
    *(.bss .bss.* .gnu.linkonce.b.*)
    *(COMMON)
    . = ALIGN (8);
    *(.ram.b .bss.ram)
    . = ALIGN(0x10) ;
    __ebss = . ;
    __end = . ;
  } > REGION_BSS

  /* Debugging sections.  */
  .stab 0 (NOLOAD) : { *(.stab) }
  .stabstr 0 (NOLOAD) : { *(.stabstr) }
  /* DWARF debug sections.
   * Symbols in the DWARF debugging sections are relative to
   * the beginning of the section so we begin them at 0.
   */
  /* DWARF 1 */
  .debug          0 : { *(.debug) }
  .line           0 : { *(.line) }
  /* GNU DWARF 1 extensions */
  .debug_srcinfo  0 : { *(.debug_srcinfo) }
  .debug_sfnames  0 : { *(.debug_sfnames) }
  /* DWARF 1.1 and DWARF 2 */
  .debug_aranges  0 : { *(.debug_aranges) }
  .debug_pubnames 0 : { *(.debug_pubnames) }
  /* DWARF 2 */
  .debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
  .debug_abbrev   0 : { *(.debug_abbrev) }
  .debug_line     0 : { *(.debug_line) }
  .debug_frame    0 : { *(.debug_frame) }
  .debug_str      0 : { *(.debug_str) }
  .debug_loc      0 : { *(.debug_loc) }
  .debug_macinfo  0 : { *(.debug_macinfo) }
  /* DWARF 2.1 */
  .debug_ranges   0 : { *(.debug_ranges) }
  /* SGI/MIPS DWARF 2 extensions */
  .debug_weaknames 0 : { *(.debug_weaknames) }
  .debug_funcnames 0 : { *(.debug_funcnames) }
  .debug_typenames 0 : { *(.debug_typenames) }
  .debug_varnames  0 : { *(.debug_varnames) }
}
