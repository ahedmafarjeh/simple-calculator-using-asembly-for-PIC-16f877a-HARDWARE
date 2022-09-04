# MPLAB IDE generated this makefile for use with GNU make.
# Project: simple_calc.asm.mcp
# Date: Thu Jun 23 02:48:14 2022

AS = MPASMWIN.exe
CC = 
LD = mplink.exe
AR = mplib.exe
RM = rm

simple_calc.asm.cof : simple_calc.o
	$(CC) /p16F877A "simple_calc.o" /u_DEBUG /z__MPLAB_BUILD=1 /z__MPLAB_DEBUG=1 /o"simple_calc.asm.cof" /M"simple_calc.asm.map" /W

simple_calc.o : simple_calc.asm P16F877A.INC LCDIS.INC
	$(AS) /q /p16F877A "simple_calc.asm" /l"simple_calc.lst" /e"simple_calc.err" /o"simple_calc.o" /d__DEBUG=1

clean : 
	$(CC) "simple_calc.o" "simple_calc.err" "simple_calc.lst" "simple_calc.asm.cof" "simple_calc.asm.hex"

