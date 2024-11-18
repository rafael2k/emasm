# this makefile (WMake) creates the Linux binary of JWasm (jwasm)
# Open Watcom v1.8-v1.9 may be used.

# Note that this makefile assumes that the OW environment is
# set - the OW tools are to be found in the PATH and the INCLUDE
# environment variable is set correctly.

name = jwasm

# Detect which platform we're _running_ on, to use proper
# directory separator.

DS=/

# When building _on_ Linux, use the script in the Watcom root
# directory to set up the proper environment variables. Call
# this script as ¨. owsetevn.sh¨ The WATCOM directory
# declarations should not end with a / or \.

!ifndef %WATCOM
WATCOM=$(DS)Watcom
!else
WATCOM=$(%WATCOM)
!endif

!ifndef DEBUG
DEBUG=0
!endif

!if $(DEBUG)
OUTD=OWELKSD
!else
OUTD=OWELKSR
!endif

# Linux is case-sensitive, so use lower case h for the Watcom includes.
inc_dirs  = -IH

LINK = owcc -bos2 -s -Wl,option -Wl,start=_start -Wl,option -Wl,dosseg -Wl,option -Wl,nodefaultlibs -Wl,option -Wl,stack=0x1000 -Wl,option -Wl,heapsize=0x2700 -Wl,library -Wl,/home/rafael2k/programs/devel/elks/libc/libc.lib

CC = owcc -c -bnone -mcmodel=l -march=i86 -Os -std=c99 -Wc,-fpi87 -Wc,-zev -Wc,-zls -Wc,-x -fno-stack-check -fnostdlib -Wall -Wextra -Wc,-wcd=303 -I/home/rafael2k/programs/devel/elks/libc/include -I/home/rafael2k/programs/devel/elks/include -I/home/rafael2k/programs/devel/elks/elks/include -I/usr/bin/watcom/h -IH -D__UNIX__ -DFASTMEM=0 -DFASTPASS=0 -DCOFF_SUPPORT=0 -DELF_SUPPORT=0 -DAMD64_SUPPORT=0 -DSSSE3SUPP=0 -DSSE4SUPP=0 -DOWFC_SUPPORT=0 -DDLLIMPORT=0 -DAVXSUPP=0 -DPE_SUPPORT=0 -DVMXSUPP=0 -DSVMSUPP=0 -DCVOSUPP=0 -DCOMDATSUPP=0 -DSTACKBASESUPP=0 -o $@
#CC = ia16-elf-gcc -c -o $@  -mcmodel=small -melks-libc -mtune=i8086 -Wall -Os -mno-segment-relocation-stuff -fno-inline -fno-builtin-printf -Wno-implicit-int -Wno-parentheses  -I/home/rafael2k/programs/devel/elks/include -I/home/rafael2k/programs/devel/elks/libc/include -I/home/rafael2k/programs/devel/elks/elks/include -D__ELKS__ -DELKS_VERSION=\"0.8.1\" -IH -D__UNIX__ -DFASTMEM=0 -DFASTPASS=0 -DCOFF_SUPPORT=0 -DELF_SUPPORT=0 -DAMD64_SUPPORT=0 -DSSSE3SUPP=0 -DSSE4SUPP=0 -DOWFC_SUPPORT=0 -DDLLIMPORT=0 -DAVXSUPP=0 -DPE_SUPPORT=0 -DVMXSUPP=0 -DSVMSUPP=0 -DCVOSUPP=0 -DCOMDATSUPP=0 -DSTACKBASESUPP=0

.c{$(OUTD)}.obj:
    $(CC) $<

proj_obj = &
!include owmod.inc

ALL: $(OUTD) $(OUTD)$(DS)$(name)

$(OUTD):
    @if not exist $(OUTD) mkdir $(OUTD)

$(OUTD)$(DS)$(name) : $(OUTD)$(DS)main.obj $(proj_obj)
    $(LINK) $(proj_obj) $(OUTD)/main.obj -o $(OUTD)$(DS)$(name)

$(OUTD)$(DS)msgtext.obj: msgtext.c H$(DS)msgdef.h H$(DS)globals.h
    $(CC) msgtext.c

$(OUTD)$(DS)reswords.obj: reswords.c H$(DS)instruct.h H$(DS)special.h H$(DS)directve.h
    $(CC) reswords.c

######
# Under non-Linux, the link format "elf" forces a file name extension of .elf.
# While this can be prevented by the NOEXTENSION link option, the resulting
# file without extension will not be detected by the "exist" below, so a "clean"
# leaves the file in place. Under Linux this detection works properly.
# Watcom ought to have a internal (=platform independent) command to detect
# the presence of such a file. E.g. %exist alllowing wildcards.

clean: .SYMBOLIC
    @if exist $(OUTD)$(DS)*     -rm $(OUTD)$(DS)*
    @if exist $(OUTD)$(DS)*.elf -rm $(OUTD)$(DS)*.elf
    @if exist $(OUTD)$(DS)*.obj -rm $(OUTD)$(DS)*.obj
    @if exist $(OUTD)$(DS)*.map -rm $(OUTD)$(DS)*.map
