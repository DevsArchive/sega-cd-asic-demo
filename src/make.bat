@echo off
..\bin\asm68k.exe /p /q mainprg\mainprg.asm, _files\MAINPRG.MCD,,mainprg\mainprg.lst

..\bin\mkisofs.exe -quiet -abstract ABS.TXT -biblio BIB.TXT -copyright CPY.TXT -A "RALAKIMUS" -V "MCD_ASIC" -publisher "RALAKIMUS" -p "RALAKIMUS" -sysid "MEGA_CD" -iso-level 1 -o files.bin -pad _files

..\bin\asm68k.exe /p /q cdip\ip.asm, cdip\ip.bin,,cdip\ip.lst
..\bin\asm68k.exe /p /q cdsp\sp.asm, cdsp\sp.bin,,cdsp\sp.lst
..\bin\asm68k.exe /p /q main.asm, _out\segacdasic.iso
del files.bin > nul

pause