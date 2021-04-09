; Allocate at 256-byte aligned cursor memory

opgenroutines:
opgenE0:
	jp opgenFFwrite
opgenEA:
	jp opgenCONSTwrite
opgenF0:
	jp opgenFFread
opgenFA:
	jp opgenCONSTread
	
opgenCALLcond:
	jp _opgenCALLcond
opgenCALL:
	jp _opgenCALL
opgenRST:
	jp _opgenRST
opgenJR:
opgenJP:
	jp opgen_emit_jump
opgenRET:
	jp _opgenRET
opgenRETcond:
	jp _opgenRETcond

opgen08:
	jp _opgen08
opgen31:
	call opgenroutinecall2byte_3cc
	.dw ophandler31
opgenE8:
	call opgenroutinecall1byte_4cc
	.dw ophandlerE8
opgenF8:
	call opgenroutinecall1byte_3cc
	.dw ophandlerF8
opgen36:
	jp _opgen36
opgen34:
	call opgenroutinecall_3cc
	.dw ophandler34
opgen35:
	call opgenroutinecall_3cc
	.dw ophandler35
opgen39:
	call opgenroutinecall_2cc
	.dw ophandler39
opgen76:
	call opgenroutinecallsplit_1cc
	.dw ophandler76
opgenC5:
	call opgenroutinecall_4cc
	.dw ophandlerC5
opgenD5:
	call opgenroutinecall_4cc
	.dw ophandlerD5
opgenE2:
	call opgenroutinecall_2cc
	.dw ophandlerE2
opgenE5:
	call opgenroutinecall_4cc
	.dw ophandlerE5
opgenF1:
	call opgenroutinecall_3cc
	.dw ophandlerF1
opgenF2:
	call opgenroutinecall_2cc
	.dw ophandlerF2
opgenF3:
	call opgenroutinecall_1cc
	.dw ophandlerF3
opgenF5:
	call opgenroutinecall_4cc
	.dw ophandlerF5
opgenF9:
	call opgenroutinecall_2cc
	.dw ophandlerF9
opgenEI:
	call opgenroutinecall_1cc
	.dw ophandlerEI
opgen33:
	call opgenroutinecall_2cc
	.dw ophandler33
opgen3B:
	call opgenroutinecall_2cc
	.dw ophandler3B
opgenE9:
	call opgenblockend
	.dw ophandlerE9
opgenRETI:
	call opgenblockend
	.dw ophandlerRETI
	
opgenMEM:
	ld a,RST_MEM
	ld (de),a
	inc de
	ldi
opgen36_finish:
	inc de
	dec iyl
	jr opgen_next_fast
	
opgenPOP:
	xor a
	ld (de),a
	inc de
	ld a,RST_POP
	ld (de),a
	inc de
opgen1byte_3cc:
	dec iyl
opgen1byte_2cc:
	dec iyl
	jr opgen1byte
	
opgen_next_swap_skip:
	ex de,hl
opgen_next_skip:
	inc de
opgenNOP:
	inc hl
opgen_next:
	ld bc,opgentable
	jr opgen_next_fast
	
opgenCB:
	ldi
	ld a,(hl)
	and $07
	cp $06
	jr nz,opgen1byte
	jr _opgenCB
	
opgen3byte_low:
	inc b
opgen3byte:
	ldi
opgen2byte:
	ldi
opgen1byte:
	ldi
opgen_next_fast:
	ld c,(hl)
	ld a,iyh
	sub l
	ret m
opgen_next_no_bound_check:
	ld a,(bc)
	ld ixl,a
	jp (ix)
	
opgenINVALID:
	jr _opgenINVALID
opgen3F:
	jp _opgen3F
opgenJRcond:
	jr _opgenJRcond
opgenJPcond:
	jr _opgenJPcond
	
opgen27:
	call opgenroutinecall_1cc
	.dw ophandler27
	
opgenROT:
	ex de,hl
	
	.echo "Opgen routine size: ", $ - opgenroutines
	
	bit 4,c
	jr nz,opgenROT_rla_rra
	ld (hl),$37 ;SCF
	inc hl
	ld (hl),$8F ;ADC A,A
	inc hl
	ld (hl),$1F ;RRA
	inc hl
	ex de,hl
	jr opgen1byte
opgenROT_rla_rra:
	ld (hl),$CC	;CALL Z,reset_z_flag
	inc hl
	ld (hl),reset_z_flag & $FF
	inc hl
	ld (hl),reset_z_flag >> 8
	inc hl
	ex de,hl
	jr opgen1byte
	
_opgenCB:
	dec iyl
	ld a,(hl)
	add a,$40
	jp pe,_
	dec iyl
_
	dec de
	xor a
	ld (de),a
	inc de
	ld a,RST_BITS
	ld (de),a
	inc de
	jr opgen1byte
	
_opgenJRcond:
	ld a,$20 ^ $28
_
	xor c
	ex de,hl
	ld (hl),a
	inc hl
	ld (hl),11
	inc hl
	call opgen_emit_jump_swapped
	jp opgen_emit_subblock_bridge
	
_opgenJPcond:
	ld a,$C2 ^ $28
	jr -_
	
_opgenINVALID:
	jp opgenblockend_invalid
	