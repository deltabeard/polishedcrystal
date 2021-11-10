HBlankCopy2bpp::
	di
	ld [hSPBuffer], sp
	ld hl, hRequestedVTileDest
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a ; destination

	ld a, [hli] ; source
	ld h, [hl]
	ld l, a
	ld sp, hl ; set source to sp
	ld a, h ; save source high byte for later
	ld h, d ; exchange hl and de
	ld l, e
; vram to vram copy check:
	cp HIGH(vTiles0) ; is source in RAM?
	jr c, .innerLoop
	cp HIGH(SRAM_Begin) ; is source past VRAM
	jr nc, .innerLoop
	jmp VRAMToVRAMCopy
.outerLoop
	ldh a, [rLY]
	cp $88
	jmp nc, ContinueHBlankCopy
.innerLoop
	pop bc
	pop de

.waitNoHBlank
	ldh a, [rSTAT]
	and 3
	jr z, .waitNoHBlank
.waitHBlank
	ldh a, [rSTAT]
	and 3
	jr nz, .waitHBlank
; Load the first line of sprite into VRAM
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a

if DEF(SINGLE_SPEED)
; Copy 6 lines during HBlank (6/2 since repeated 2 times)
	ld c, 3

.waitNoHBlank2
	ldh a, [rSTAT]
	and 3
	jr z, .waitNoHBlank2
.waitHBlank2
	ldh a, [rSTAT]
	and 3
	jr nz, .waitHBlank2

; Number of repeats must be a common multiple of 6.
rept 2
; Copy line
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	pop de
endr

; Decrement number of lines printed
	dec c
; Loop if sprite hasn't finished copying
	jr nz, .waitNoHBlank2
else

; No need to check hblank when in doublespeed mode
rept 6
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
	pop de
endr

endc
	
; Copy final line
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a

	ldh a, [hTilesPerCycle]
	dec a
	ldh [hTilesPerCycle], a
	jr nz, .outerLoop
	jmp DoneHBlankCopy
