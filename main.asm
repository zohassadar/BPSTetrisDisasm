; da65 V2.19 - Git c097401f8
; Input file: clean.nes
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
tmp12           := $0012                        ; Appears to have multiple uses. One is for ram init along with $13
tmp13           := $0013
tmp14           := $0014                        ; at least one use is to send nametable to ppu (with $15)
tmp15           := $0015
jmp1E           := $001E                        ; used for indirect jumping at 8029
aBackup         := $002B
xBackup         := $002C
yBackup         := $002D
controllerInput := $0030                        ; todo: find out where this is read
nmiWaitVar      := $003C                        ; appears to always be 0?  Maybe all logic starts with NMI and ends in loop
rngSeed         := $0056
L0061           := $0061
L00A9           := $00A9
lastZPAddress   := $00FF                        ; This causes tetris-ram.awk to add '.bss' after zeropage
stack           := $0100
oamStaging      := $0200
PPUCTRL         := $2000
PPUMASK         := $2001
PPUSTATUS       := $2002
OAMADDR         := $2003
OAMDATA         := $2004
PPUSCROLL       := $2005
PPUADDR         := $2006
PPUDATA         := $2007
SQ1_VOL         := $4000
SQ1_SWEEP       := $4001
SQ1_LO          := $4002
SQ1_HI          := $4003
SQ2_VOL         := $4004
SQ2_SWEEP       := $4005
SQ2_LO          := $4006
SQ2_HI          := $4007
TRI_LINEAR      := $4008
TRI_LO          := $400A
TRI_HI          := $400B
NOISE_VOL       := $400C
NOISE_LO        := $400E
NOISE_HI        := $400F
DMC_FREQ        := $4010
DMC_RAW         := $4011
DMC_START       := $4012                        ; start << 6 + $C000
DMC_LEN         := $4013                        ; len << 4 + 1
OAMDMA          := $4014
SND_CHN         := $4015
JOY1            := $4016
JOY2            := $4017
; ----------------------------------------------------------------------------
; $8002 is incremented during bootup.  mmc1 remnant?
reset:
        jmp     resetContinued                  ; 8000 4C 05 81                 L..

; ----------------------------------------------------------------------------
irq:
        rti                                     ; 8003 40                       @

; ----------------------------------------------------------------------------
nmi:
        sta     aBackup                         ; 8004 85 2B                    .+
        stx     xBackup                         ; 8006 86 2C                    .,
        sty     yBackup                         ; 8008 84 2D                    .-
        lda     PPUSTATUS                       ; 800A AD 02 20                 .. 
        lda     #$08                            ; 800D A9 08                    ..
        ora     $29                             ; 800F 05 29                    .)
        ora     $35                             ; 8011 05 35                    .5
        sta     PPUCTRL                         ; 8013 8D 00 20                 .. 
        ldx     $42                             ; 8016 A6 42                    .B
        beq     L801E                           ; 8018 F0 04                    ..
        ldx     #$00                            ; 801A A2 00                    ..
        stx     $42                             ; 801C 86 42                    .B
L801E:
        ldy     #$00                            ; 801E A0 00                    ..
        sty     PPUMASK                         ; 8020 8C 01 20                 .. 
        cpy     $3F                             ; 8023 C4 3F                    .?
        beq     L8029                           ; 8025 F0 02                    ..
        dec     $3F                             ; 8027 C6 3F                    .?
L8029:
        jmp     (jmp1E)                         ; 8029 6C 1E 00                 l..

; ----------------------------------------------------------------------------
L802C:
        lda     $36                             ; 802C A5 36                    .6
        sta     PPUSCROLL                       ; 802E 8D 05 20                 .. 
        lda     $37                             ; 8031 A5 37                    .7
        sta     PPUSCROLL                       ; 8033 8D 05 20                 .. 
        lda     $2E                             ; 8036 A5 2E                    ..
        sta     PPUMASK                         ; 8038 8D 01 20                 .. 
        lda     #$80                            ; 803B A9 80                    ..
        ora     $29                             ; 803D 05 29                    .)
        ora     $3D                             ; 803F 05 3D                    .=
        sta     PPUCTRL                         ; 8041 8D 00 20                 .. 
        lda     #$00                            ; 8044 A9 00                    ..
        sta     OAMADDR                         ; 8046 8D 03 20                 .. 
        lda     #$02                            ; 8049 A9 02                    ..
        sta     OAMDMA                          ; 804B 8D 14 40                 ..@
        rts                                     ; 804E 60                       `

; ----------------------------------------------------------------------------
L804F:
        jsr     L805C                           ; 804F 20 5C 80                  \.
        jsr     LBC73                           ; 8052 20 73 BC                  s.
        ldy     yBackup                         ; 8055 A4 2D                    .-
        ldx     xBackup                         ; 8057 A6 2C                    .,
        lda     aBackup                         ; 8059 A5 2B                    .+
        rti                                     ; 805B 40                       @

; ----------------------------------------------------------------------------
L805C:
        lda     #$00                            ; 805C A9 00                    ..
        sta     nmiWaitVar                      ; 805E 85 3C                    .<
        sta     $3B                             ; 8060 85 3B                    .;
        sta     $3A                             ; 8062 85 3A                    .:
        sta     $38                             ; 8064 85 38                    .8
        jsr     L8FCE                           ; 8066 20 CE 8F                  ..
        bne     L806F                           ; 8069 D0 04                    ..
        inx                                     ; 806B E8                       .
        stx     nmiWaitVar                      ; 806C 86 3C                    .<
        rts                                     ; 806E 60                       `

; ----------------------------------------------------------------------------
L806F:
        txa                                     ; 806F 8A                       .
        and     #$04                            ; 8070 29 04                    ).
        beq     L8077                           ; 8072 F0 03                    ..
        sta     $3B                             ; 8074 85 3B                    .;
        rts                                     ; 8076 60                       `

; ----------------------------------------------------------------------------
L8077:
        txa                                     ; 8077 8A                       .
        and     #$01                            ; 8078 29 01                    ).
        beq     L807E                           ; 807A F0 02                    ..
        sta     $38                             ; 807C 85 38                    .8
L807E:
        txa                                     ; 807E 8A                       .
        and     #$08                            ; 807F 29 08                    ).
        beq     L8085                           ; 8081 F0 02                    ..
        sta     $3A                             ; 8083 85 3A                    .:
L8085:
        rts                                     ; 8085 60                       `

; ----------------------------------------------------------------------------
; can be jumped to using 1E/1F
unknownRoutine02:
        ldy     #$00                            ; 8086 A0 00                    ..
        cpy     $41                             ; 8088 C4 41                    .A
        beq     L80C4                           ; 808A F0 38                    .8
L808C:
        lda     $04D2,y                         ; 808C B9 D2 04                 ...
        cmp     #$FF                            ; 808F C9 FF                    ..
        bne     L80AC                           ; 8091 D0 19                    ..
        lda     $04CA,y                         ; 8093 B9 CA 04                 ...
L8096:
        ldx     $04C2,y                         ; 8096 BE C2 04                 ...
        stx     PPUADDR                         ; 8099 8E 06 20                 .. 
        ldx     $04BA,y                         ; 809C BE BA 04                 ...
        stx     PPUADDR                         ; 809F 8E 06 20                 .. 
        sta     PPUDATA                         ; 80A2 8D 07 20                 .. 
        iny                                     ; 80A5 C8                       .
        dec     $41                             ; 80A6 C6 41                    .A
        bne     L808C                           ; 80A8 D0 E2                    ..
        beq     L80C4                           ; 80AA F0 18                    ..
L80AC:
        ldx     $04C2,y                         ; 80AC BE C2 04                 ...
        stx     PPUADDR                         ; 80AF 8E 06 20                 .. 
        ldx     $04BA,y                         ; 80B2 BE BA 04                 ...
        stx     PPUADDR                         ; 80B5 8E 06 20                 .. 
        ldx     PPUDATA                         ; 80B8 AE 07 20                 .. 
        and     PPUDATA                         ; 80BB 2D 07 20                 -. 
        ora     $04CA,y                         ; 80BE 19 CA 04                 ...
        jmp     L8096                           ; 80C1 4C 96 80                 L..

; ----------------------------------------------------------------------------
L80C4:
        jsr     L9CFE                           ; 80C4 20 FE 9C                  ..
        jsr     L802C                           ; 80C7 20 2C 80                  ,.
        jmp     L804F                           ; 80CA 4C 4F 80                 LO.

; ----------------------------------------------------------------------------
; can be jumped to using 1E/1F
unknownRoutine08:
        lda     $3E                             ; 80CD A5 3E                    .>
        beq     L80FF                           ; 80CF F0 2E                    ..
        ldy     #$00                            ; 80D1 A0 00                    ..
        lda     tmp13                           ; 80D3 A5 13                    ..
        sta     PPUADDR                         ; 80D5 8D 06 20                 .. 
        lda     tmp12                           ; 80D8 A5 12                    ..
        sta     PPUADDR                         ; 80DA 8D 06 20                 .. 
L80DD:
        lda     ($10),y                         ; 80DD B1 10                    ..
        sta     PPUDATA                         ; 80DF 8D 07 20                 .. 
        iny                                     ; 80E2 C8                       .
        cpy     $34                             ; 80E3 C4 34                    .4
        bcc     L80DD                           ; 80E5 90 F6                    ..
        lda     $34                             ; 80E7 A5 34                    .4
        clc                                     ; 80E9 18                       .
        adc     $10                             ; 80EA 65 10                    e.
        sta     $10                             ; 80EC 85 10                    ..
        bcc     L80F2                           ; 80EE 90 02                    ..
        inc     $11                             ; 80F0 E6 11                    ..
L80F2:
        dec     $3E                             ; 80F2 C6 3E                    .>
        lda     tmp12                           ; 80F4 A5 12                    ..
        clc                                     ; 80F6 18                       .
        adc     $34                             ; 80F7 65 34                    e4
        .byte   $85,$12                         ; 80F9 85 12                    ..
; ----------------------------------------------------------------------------
        bcc     L80FF                           ; 80FB 90 02                    ..
        inc     tmp13                           ; 80FD E6 13                    ..
L80FF:
        jsr     L802C                           ; 80FF 20 2C 80                  ,.
        jmp     L804F                           ; 8102 4C 4F 80                 LO.

; ----------------------------------------------------------------------------
resetContinued:
        cld                                     ; 8105 D8                       .
        sei                                     ; 8106 78                       x
        inc     reset+2                         ; 8107 EE 02 80                 ...
        lda     #$08                            ; 810A A9 08                    ..
        sta     PPUCTRL                         ; 810C 8D 00 20                 .. 
        lda     #$00                            ; 810F A9 00                    ..
        sta     PPUMASK                         ; 8111 8D 01 20                 .. 
        sta     SND_CHN                         ; 8114 8D 15 40                 ..@
@vblankWait1:
        lda     PPUSTATUS                       ; 8117 AD 02 20                 .. 
        bpl     @vblankWait1                    ; 811A 10 FB                    ..
@vblankWait2:
        lda     PPUSTATUS                       ; 811C AD 02 20                 .. 
        bpl     @vblankWait2                    ; 811F 10 FB                    ..
        ldx     #$FF                            ; 8121 A2 FF                    ..
        txs                                     ; 8123 9A                       .
        jsr     setCNROMBank0                   ; 8124 20 70 8F                  p.
        jsr     initRoutine                     ; 8127 20 50 81                  P.
        lda     #$00                            ; 812A A9 00                    ..
        sta     $3D                             ; 812C 85 3D                    .=
        jsr     L997B                           ; 812E 20 7B 99                  {.
        lda     #$00                            ; 8131 A9 00                    ..
        sta     $3D                             ; 8133 85 3D                    .=
        lda     #$03                            ; 8135 A9 03                    ..
        sta     $0613                           ; 8137 8D 13 06                 ...
        inc     $0613                           ; 813A EE 13 06                 ...
        jsr     LBC1F                           ; 813D 20 1F BC                  ..
        lda     #$01                            ; 8140 A9 01                    ..
        jsr     L90F9                           ; 8142 20 F9 90                  ..
        ldy     #$F0                            ; 8145 A0 F0                    ..
        jsr     L8FBB                           ; 8147 20 BB 8F                  ..
        jsr     L835E                           ; 814A 20 5E 83                  ^.
        jmp     L83BD                           ; 814D 4C BD 83                 L..

; ----------------------------------------------------------------------------
; need a better name
initRoutine:
        lda     #$00                            ; 8150 A9 00                    ..
        ldy     #$10                            ; 8152 A0 10                    ..
; this doesn't touch the first 16 bytes of zp.  FDS remnant?
@initZeroPage:
        sta     $00,y                           ; 8154 99 00 00                 ...
        iny                                     ; 8157 C8                       .
        bne     @initZeroPage                   ; 8158 D0 FA                    ..
        lda     #$17                            ; 815A A9 17                    ..
@initRngSeed:
        sta     rngSeed,y                       ; 815C 99 56 00                 .V.
        ror     a                               ; 815F 6A                       j
        adc     #$26                            ; 8160 69 26                    i&
        iny                                     ; 8162 C8                       .
        cpy     #$07                            ; 8163 C0 07                    ..
        bcc     @initRngSeed                    ; 8165 90 F5                    ..
        jsr     blankOutNametables              ; 8167 20 F8 8F                  ..
        jsr     initRam                         ; 816A 20 16 90                  ..
        lda     #$FF                            ; 816D A9 FF                    ..
        sta     $0579                           ; 816F 8D 79 05                 .y.
        jsr     drawCreditScreenPatch           ; 8172 20 AB 81                  ..
        lda     #$86                            ; 8175 A9 86                    ..
        sta     jmp1E                           ; 8177 85 1E                    ..
        lda     #$80                            ; 8179 A9 80                    ..
        sta     jmp1E+1                         ; 817B 85 1F                    ..
        ldx     #$96                            ; 817D A2 96                    ..
@nextByte:
        lda     unknownTable01,x                ; 817F BD 88 AF                 ...
        sta     $04D9,x                         ; 8182 9D D9 04                 ...
        dex                                     ; 8185 CA                       .
        bne     @nextByte                       ; 8186 D0 F7                    ..
        lda     #$00                            ; 8188 A9 00                    ..
        jsr     L9D54                           ; 818A 20 54 9D                  T.
        lda     #$03                            ; 818D A9 03                    ..
        ldy     LC004                           ; 818F AC 04 C0                 ...
        beq     L8196                           ; 8192 F0 02                    ..
        lda     #$07                            ; 8194 A9 07                    ..
L8196:
        sta     $0615                           ; 8196 8D 15 06                 ...
        rts                                     ; 8199 60                       `

; ----------------------------------------------------------------------------
; address, length, data, null
ntCreditScreenPatch:
        .byte   $E9,$2D,$0D,$0D,$1C,$0F,$0E,$13 ; 819A E9 2D 0D 0D 1C 0F 0E 13  .-......
        .byte   $1E,$00,$1D,$0D,$1C,$0F,$0F,$18 ; 81A2 1E 00 1D 0D 1C 0F 0F 18  ........
        .byte   $00                             ; 81AA 00                       .
; ----------------------------------------------------------------------------
; this writes 'credit screen' to the nametable but is overwritten
drawCreditScreenPatch:
        ldy     #$00                            ; 81AB A0 00                    ..
; this routine looks like it can write multiple patches, but is hardcoded to the above
@checkForNextPatch:
        lda     ntCreditScreenPatch,y           ; 81AD B9 9A 81                 ...
        beq     @resetScroll                    ; 81B0 F0 1D                    ..
        sta     PPUADDR                         ; 81B2 8D 06 20                 .. 
        iny                                     ; 81B5 C8                       .
        lda     ntCreditScreenPatch,y           ; 81B6 B9 9A 81                 ...
        sta     PPUADDR                         ; 81B9 8D 06 20                 .. 
        iny                                     ; 81BC C8                       .
        lda     ntCreditScreenPatch,y           ; 81BD B9 9A 81                 ...
        tax                                     ; 81C0 AA                       .
@nextByte:
        iny                                     ; 81C1 C8                       .
        lda     ntCreditScreenPatch,y           ; 81C2 B9 9A 81                 ...
        sta     PPUDATA                         ; 81C5 8D 07 20                 .. 
        dex                                     ; 81C8 CA                       .
        bne     @nextByte                       ; 81C9 D0 F6                    ..
        iny                                     ; 81CB C8                       .
        jmp     @checkForNextPatch              ; 81CC 4C AD 81                 L..

; ----------------------------------------------------------------------------
@resetScroll:
        sta     PPUSCROLL                       ; 81CF 8D 05 20                 .. 
        sta     PPUSCROLL                       ; 81D2 8D 05 20                 .. 
        rts                                     ; 81D5 60                       `

; ----------------------------------------------------------------------------
        .byte   $30,$40,$50,$68,$88,$A8,$B8,$E7 ; 81D6 30 40 50 68 88 A8 B8 E7  0@Ph....
        .byte   $04,$04,$06,$08,$08,$04,$0C     ; 81DE 04 04 06 08 08 04 0C     .......
L81E5:
        .byte   $A9,$07,$20,$F9,$90,$A9,$06,$85 ; 81E5 A9 07 20 F9 90 A9 06 85  .. .....
        .byte   $2E,$8D,$01,$20,$A9,$00,$8D,$00 ; 81ED 2E 8D 01 20 A9 00 8D 00  ... ....
        .byte   $20,$A5,$29,$49,$03,$0A,$0A,$69 ; 81F5 20 A5 29 49 03 0A 0A 69   .)I...i
        .byte   $20,$8D,$06,$20,$A9,$00,$8D,$06 ; 81FD 20 8D 06 20 A9 00 8D 06   .. ....
        .byte   $20,$AA,$A9,$32,$A0,$03,$8D,$07 ; 8205 20 AA A9 32 A0 03 8D 07   ..2....
        .byte   $20,$CA,$D0,$FA,$88,$30,$07,$D0 ; 820D 20 CA D0 FA 88 30 07 D0   ....0..
        .byte   $F5,$A2,$C0,$4C,$0B,$82,$A2,$40 ; 8215 F5 A2 C0 4C 0B 82 A2 40  ...L...@
        .byte   $8C,$07,$20,$CA,$D0,$FA,$A9,$80 ; 821D 8C 07 20 CA D0 FA A9 80  .. .....
        .byte   $05,$29,$49,$03,$05,$3D,$8D,$00 ; 8225 05 29 49 03 05 3D 8D 00  .)I..=..
        .byte   $20,$A9,$08,$85,$26,$20,$EE,$91 ; 822D 20 A9 08 85 26 20 EE 91   ...& ..
        .byte   $A9,$06,$20,$DD,$92,$A9,$0C,$20 ; 8235 A9 06 20 DD 92 A9 0C 20  .. .... 
        .byte   $DD,$92,$A2,$30,$8E,$01,$02,$A2 ; 823D DD 92 A2 30 8E 01 02 A2  ...0....
        .byte   $20,$8E,$02,$02,$A2,$00,$8E,$03 ; 8245 20 8E 02 02 A2 00 8E 03   .......
        .byte   $02,$8E,$70,$05,$A9,$1E,$85,$2E ; 824D 02 8E 70 05 A9 1E 85 2E  ..p.....
        .byte   $A9,$1E,$8D,$C7,$05,$BD,$D6,$81 ; 8255 A9 1E 8D C7 05 BD D6 81  ........
        .byte   $8D,$00,$02,$8A,$48,$A2,$28,$20 ; 825D 8D 00 02 8A 48 A2 28 20  ....H.( 
        .byte   $C6,$93,$68,$AA,$A9,$28,$85,$3F ; 8265 C6 93 68 AA A9 28 85 3F  ..h..(.?
        .byte   $20,$EC,$82,$A5,$29,$49,$03,$09 ; 826D 20 EC 82 A5 29 49 03 09   ...)I..
        .byte   $80,$05,$3D,$8D,$00,$20,$AD,$70 ; 8275 80 05 3D 8D 00 20 AD 70  ..=.. .p
        .byte   $05,$18,$6D,$C7,$05,$8D,$70,$05 ; 827D 05 18 6D C7 05 8D 70 05  ..m...p.
        .byte   $90,$02,$A9,$FF,$8D,$05,$20,$A9 ; 8285 90 02 A9 FF 8D 05 20 A9  ...... .
        .byte   $00,$8D,$05,$20,$AC,$C7,$05,$F0 ; 828D 00 8D 05 20 AC C7 05 F0  ... ....
        .byte   $07,$88,$88,$F0,$03,$8C,$C7,$05 ; 8295 07 88 88 F0 03 8C C7 05  ........
        .byte   $86,$1C,$BD,$DE,$81,$85,$14,$20 ; 829D 86 1C BD DE 81 85 14 20  ....... 
        .byte   $CE,$8F,$8A,$8D,$98,$05,$D0,$39 ; 82A5 CE 8F 8A 8D 98 05 D0 39  .......9
        .byte   $C6,$14,$D0,$F3,$A6,$1C,$A9,$00 ; 82AD C6 14 D0 F3 A6 1C A9 00  ........
        .byte   $8D,$05,$20,$8D,$05,$20,$CD,$70 ; 82B5 8D 05 20 8D 05 20 CD 70  .. .. .p
        .byte   $05,$D0,$AD,$8D,$C7,$05,$BD,$D7 ; 82BD 05 D0 AD 8D C7 05 BD D7  ........
        .byte   $81,$8D,$00,$02,$A5,$3F,$D0,$A0 ; 82C5 81 8D 00 02 A5 3F D0 A0  .....?..
        .byte   $E8,$E0,$07,$90,$83,$A2,$2C,$20 ; 82CD E8 E0 07 90 83 A2 2C 20  ......, 
        .byte   $C6,$93,$A0,$C8,$20,$BB,$8F,$AD ; 82D5 C6 93 A0 C8 20 BB 8F AD  .... ...
        .byte   $98,$05,$D0,$05,$A0,$C8,$20,$BB ; 82DD 98 05 D0 05 A0 C8 20 BB  ...... .
        .byte   $8F,$A9,$F0,$8D,$00,$02,$60,$E6 ; 82E5 8F A9 F0 8D 00 02 60 E6  ......`.
        .byte   $42,$20,$59,$90,$AD,$02,$20,$A0 ; 82ED 42 20 59 90 AD 02 20 A0  B Y... .
        .byte   $A0                             ; 82F5 A0                       .
L82F6:
        .byte   $EA,$EA,$EA,$C8,$D0,$FA,$AD,$02 ; 82F6 EA EA EA C8 D0 FA AD 02  ........
        .byte   $20,$29,$40,$F0,$F9,$60         ; 82FE 20 29 40 F0 F9 60         )@..`
L8304:
        .byte   $20,$CB,$C3,$A0,$00,$20,$74,$8C ; 8304 20 CB C3 A0 00 20 74 8C   .... t.
        .byte   $20                             ; 830C 20                        
; ----------------------------------------------------------------------------
        lsr     LA98D,x                         ; 830D 5E 8D A9                 ^..
        brk                                     ; 8310 00                       .
        jsr     L8C4C                           ; 8311 20 4C 8C                  L.
        lda     #$12                            ; 8314 A9 12                    ..
        jsr     L92DD                           ; 8316 20 DD 92                  ..
        jsr     L8353                           ; 8319 20 53 83                  S.
        lda     #$08                            ; 831C A9 08                    ..
        sta     $3D                             ; 831E 85 3D                    .=
        jsr     LE000                           ; 8320 20 00 E0                  ..
        lda     $0614                           ; 8323 AD 14 06                 ...
        jsr     LBC1F                           ; 8326 20 1F BC                  ..
        jsr     L835E                           ; 8329 20 5E 83                  ^.
        lda     #$00                            ; 832C A9 00                    ..
        sta     $3D                             ; 832E 85 3D                    .=
        lda     #$FF                            ; 8330 A9 FF                    ..
        jsr     L8C4C                           ; 8332 20 4C 8C                  L.
        lda     #$00                            ; 8335 A9 00                    ..
        jsr     L92DD                           ; 8337 20 DD 92                  ..
        jsr     L8774                           ; 833A 20 74 87                  t.
        jsr     L8F49                           ; 833D 20 49 8F                  I.
        rts                                     ; 8340 60                       `

; ----------------------------------------------------------------------------
L8341:
        lda     #$05                            ; 8341 A9 05                    ..
        ldx     $0596                           ; 8343 AE 96 05                 ...
        cpx     #$05                            ; 8346 E0 05                    ..
        bne     L834C                           ; 8348 D0 02                    ..
        lda     #$06                            ; 834A A9 06                    ..
L834C:
        jsr     LBC1F                           ; 834C 20 1F BC                  ..
        rts                                     ; 834F 60                       `

; ----------------------------------------------------------------------------
L8350:
        .byte   $33                             ; 8350 33                       3
        .byte   $3C                             ; 8351 3C                       <
L8353           := * + 1
        eor     L00A9                           ; 8352 45 A9                    E.
        beq     L82F6                           ; 8354 F0 A0                    ..
        brk                                     ; 8356 00                       .
        sta     oamStaging,y                    ; 8357 99 00 02                 ...
        .byte   $C8,$D0                         ; 835A C8 D0                    ..
; ----------------------------------------------------------------------------
        .byte   $FA                             ; 835C FA                       .
        rts                                     ; 835D 60                       `

; ----------------------------------------------------------------------------
L835E:
        jsr     L8353                           ; 835E 20 53 83                  S.
        ldx     #$00                            ; 8361 A2 00                    ..
L8363:
        inx                                     ; 8363 E8                       .
        inx                                     ; 8364 E8                       .
        lda     #$00                            ; 8365 A9 00                    ..
        sta     oamStaging,x                    ; 8367 9D 00 02                 ...
        inx                                     ; 836A E8                       .
        inx                                     ; 836B E8                       .
        cpx     #$30                            ; 836C E0 30                    .0
        bcc     L8363                           ; 836E 90 F3                    ..
        ldx     #$10                            ; 8370 A2 10                    ..
        ldy     #$00                            ; 8372 A0 00                    ..
L8374:
        lda     #$F0                            ; 8374 A9 F0                    ..
        sta     oamStaging,x                    ; 8376 9D 00 02                 ...
        inx                                     ; 8379 E8                       .
        lda     #$60                            ; 837A A9 60                    .`
        sta     oamStaging,x                    ; 837C 9D 00 02                 ...
        inx                                     ; 837F E8                       .
        lda     #$02                            ; 8380 A9 02                    ..
        sta     oamStaging,x                    ; 8382 9D 00 02                 ...
        inx                                     ; 8385 E8                       .
        lda     L8350,y                         ; 8386 B9 50 83                 .P.
        sta     oamStaging,x                    ; 8389 9D 00 02                 ...
        inx                                     ; 838C E8                       .
        iny                                     ; 838D C8                       .
        cpy     #$03                            ; 838E C0 03                    ..
        bcc     L8374                           ; 8390 90 E2                    ..
        rts                                     ; 8392 60                       `

; ----------------------------------------------------------------------------
L8393:
        lda     #$00                            ; 8393 A9 00                    ..
        sta     $0587                           ; 8395 8D 87 05                 ...
        sta     $0588                           ; 8398 8D 88 05                 ...
        sta     $0589                           ; 839B 8D 89 05                 ...
        sta     $058A                           ; 839E 8D 8A 05                 ...
        sta     $058B                           ; 83A1 8D 8B 05                 ...
        sta     $058C                           ; 83A4 8D 8C 05                 ...
        sta     $058D                           ; 83A7 8D 8D 05                 ...
        sta     $058E                           ; 83AA 8D 8E 05                 ...
        lda     #$03                            ; 83AD A9 03                    ..
        sta     $059E                           ; 83AF 8D 9E 05                 ...
L83B2:
        lda     #$04                            ; 83B2 A9 04                    ..
        jsr     L90F9                           ; 83B4 20 F9 90                  ..
        lda     #$00                            ; 83B7 A9 00                    ..
        jsr     L92DD                           ; 83B9 20 DD 92                  ..
        rts                                     ; 83BC 60                       `

; ----------------------------------------------------------------------------
L83BD:
        lda     #$02                            ; 83BD A9 02                    ..
        jsr     L90F9                           ; 83BF 20 F9 90                  ..
        lda     #$03                            ; 83C2 A9 03                    ..
        jsr     LBC1F                           ; 83C4 20 1F BC                  ..
        lda     #$01                            ; 83C7 A9 01                    ..
        sta     nmiWaitVar                      ; 83C9 85 3C                    .<
L83CB:
        lda     nmiWaitVar                      ; 83CB A5 3C                    .<
        beq     L840C                           ; 83CD F0 3D                    .=
        lda     $0612                           ; 83CF AD 12 06                 ...
        bne     L83CB                           ; 83D2 D0 F7                    ..
        jsr     LC3CB                           ; 83D4 20 CB C3                  ..
        jsr     L8733                           ; 83D7 20 33 87                  3.
        jsr     L83B2                           ; 83DA 20 B2 83                  ..
        lda     #$00                            ; 83DD A9 00                    ..
        jsr     LBC1F                           ; 83DF 20 1F BC                  ..
        jsr     L863A                           ; 83E2 20 3A 86                  :.
        lda     $0598                           ; 83E5 AD 98 05                 ...
        bne     L840C                           ; 83E8 D0 22                    ."
        jsr     L9580                           ; 83EA 20 80 95                  ..
        ldy     #$C8                            ; 83ED A0 C8                    ..
        jsr     L8FBB                           ; 83EF 20 BB 8F                  ..
        lda     $0598                           ; 83F2 AD 98 05                 ...
        bne     L840C                           ; 83F5 D0 15                    ..
        ldy     #$C8                            ; 83F7 A0 C8                    ..
        jsr     L8FBB                           ; 83F9 20 BB 8F                  ..
        lda     $0598                           ; 83FC AD 98 05                 ...
        bne     L840C                           ; 83FF D0 0B                    ..
        jsr     L81E5                           ; 8401 20 E5 81                  ..
        jsr     LC3CB                           ; 8404 20 CB C3                  ..
        lda     $0598                           ; 8407 AD 98 05                 ...
        beq     L83BD                           ; 840A F0 B1                    ..
L840C:
        jsr     LC3CB                           ; 840C 20 CB C3                  ..
        lda     #$03                            ; 840F A9 03                    ..
        jsr     L90F9                           ; 8411 20 F9 90                  ..
        lda     #$00                            ; 8414 A9 00                    ..
        jsr     L92DD                           ; 8416 20 DD 92                  ..
        jsr     L87CF                           ; 8419 20 CF 87                  ..
        jsr     L8393                           ; 841C 20 93 83                  ..
L841F:
        jsr     L8F49                           ; 841F 20 49 8F                  I.
        ldy     $0597                           ; 8422 AC 97 05                 ...
        jsr     L8C74                           ; 8425 20 74 8C                  t.
L8428:
        ldx     $0595                           ; 8428 AE 95 05                 ...
        lda     L8907,x                         ; 842B BD 07 89                 ...
        sta     $0575                           ; 842E 8D 75 05                 .u.
        lda     #$19                            ; 8431 A9 19                    ..
        sta     $0580                           ; 8433 8D 80 05                 ...
        lda     #$00                            ; 8436 A9 00                    ..
        sta     $057F                           ; 8438 8D 7F 05                 ...
        sta     $057A                           ; 843B 8D 7A 05                 .z.
        sta     $057B                           ; 843E 8D 7B 05                 .{.
        sta     $057C                           ; 8441 8D 7C 05                 .|.
        sta     $057D                           ; 8444 8D 7D 05                 .}.
        sta     $0581                           ; 8447 8D 81 05                 ...
        sta     $0582                           ; 844A 8D 82 05                 ...
        sta     $0618                           ; 844D 8D 18 06                 ...
        sta     $0619                           ; 8450 8D 19 06                 ...
        sta     $061A                           ; 8453 8D 1A 06                 ...
        jsr     L91EE                           ; 8456 20 EE 91                  ..
        lda     #$06                            ; 8459 A9 06                    ..
        jsr     L92DD                           ; 845B 20 DD 92                  ..
        jsr     L8E62                           ; 845E 20 62 8E                  b.
        jsr     L8E7B                           ; 8461 20 7B 8E                  {.
        jsr     L8D5E                           ; 8464 20 5E 8D                  ^.
        jsr     L8EE4                           ; 8467 20 E4 8E                  ..
L846A:
        jsr     L8EB1                           ; 846A 20 B1 8E                  ..
        lda     $0598                           ; 846D AD 98 05                 ...
        bne     L8475                           ; 8470 D0 03                    ..
        jmp     L8511                           ; 8472 4C 11 85                 L..

; ----------------------------------------------------------------------------
L8475:
        ldx     #$24                            ; 8475 A2 24                    .$
        jsr     L93C6                           ; 8477 20 C6 93                  ..
        ldy     #$1E                            ; 847A A0 1E                    ..
        jsr     L902E                           ; 847C 20 2E 90                  ..
        ldx     #$24                            ; 847F A2 24                    .$
        jsr     L93C6                           ; 8481 20 C6 93                  ..
        jsr     L8CE7                           ; 8484 20 E7 8C                  ..
        dec     $0574                           ; 8487 CE 74 05                 .t.
        ldy     #$14                            ; 848A A0 14                    ..
        jsr     L902E                           ; 848C 20 2E 90                  ..
        ldx     #$24                            ; 848F A2 24                    .$
        jsr     L93C6                           ; 8491 20 C6 93                  ..
        ldx     $0570                           ; 8494 AE 70 05                 .p.
        ldy     $0571                           ; 8497 AC 71 05                 .q.
        jsr     L8D36                           ; 849A 20 36 8D                  6.
        ldy     #$14                            ; 849D A0 14                    ..
        jsr     L902E                           ; 849F 20 2E 90                  ..
        jsr     L8CE7                           ; 84A2 20 E7 8C                  ..
        jsr     L8B0E                           ; 84A5 20 0E 8B                  ..
        jsr     L962E                           ; 84A8 20 2E 96                  ..
        lda     $059E                           ; 84AB AD 9E 05                 ...
        beq     L84B3                           ; 84AE F0 03                    ..
        jmp     L841F                           ; 84B0 4C 1F 84                 L..

; ----------------------------------------------------------------------------
L84B3:
        jsr     LC3CB                           ; 84B3 20 CB C3                  ..
        ldx     #$00                            ; 84B6 A2 00                    ..
L84B8:
        lda     LAE17,x                         ; 84B8 BD 17 AE                 ...
        sta     $030A,x                         ; 84BB 9D 0A 03                 ...
        inx                                     ; 84BE E8                       .
        cpx     #$C8                            ; 84BF E0 C8                    ..
        bcc     L84B8                           ; 84C1 90 F5                    ..
        jsr     L8D5E                           ; 84C3 20 5E 8D                  ^.
        ldy     #$C8                            ; 84C6 A0 C8                    ..
        jsr     L8FBB                           ; 84C8 20 BB 8F                  ..
        lda     #$0A                            ; 84CB A9 0A                    ..
        sta     $26                             ; 84CD 85 26                    .&
        jsr     LC3CB                           ; 84CF 20 CB C3                  ..
        jsr     L94D9                           ; 84D2 20 D9 94                  ..
        jsr     L9580                           ; 84D5 20 80 95                  ..
        lda     $05B8                           ; 84D8 AD B8 05                 ...
        bmi     L84E0                           ; 84DB 30 03                    0.
        jsr     L942F                           ; 84DD 20 2F 94                  /.
L84E0:
        ldy     #$C8                            ; 84E0 A0 C8                    ..
        sty     $3F                             ; 84E2 84 3F                    .?
L84E4:
        jsr     L8FCE                           ; 84E4 20 CE 8F                  ..
        txa                                     ; 84E7 8A                       .
        bne     L8504                           ; 84E8 D0 1A                    ..
        ldy     $05B8                           ; 84EA AC B8 05                 ...
        bpl     L84F6                           ; 84ED 10 07                    ..
        lda     $0612                           ; 84EF AD 12 06                 ...
        bne     L84E4                           ; 84F2 D0 F0                    ..
        beq     L8504                           ; 84F4 F0 0E                    ..
L84F6:
        lda     $0612                           ; 84F6 AD 12 06                 ...
        bne     L8500                           ; 84F9 D0 05                    ..
        lda     #$04                            ; 84FB A9 04                    ..
        jsr     LBC1F                           ; 84FD 20 1F BC                  ..
L8500:
        lda     $3F                             ; 8500 A5 3F                    .?
        bne     L84E4                           ; 8502 D0 E0                    ..
L8504:
        lda     #$02                            ; 8504 A9 02                    ..
        jsr     LC3CD                           ; 8506 20 CD C3                  ..
        ldy     #$3C                            ; 8509 A0 3C                    .<
        jsr     L902E                           ; 850B 20 2E 90                  ..
        jmp     L83BD                           ; 850E 4C BD 83                 L..

; ----------------------------------------------------------------------------
L8511:
        lda     $0575                           ; 8511 AD 75 05                 .u.
        sta     $3F                             ; 8514 85 3F                    .?
L8516:
        lda     $0570                           ; 8516 AD 70 05                 .p.
        sta     $0584                           ; 8519 8D 84 05                 ...
        lda     $0571                           ; 851C AD 71 05                 .q.
        sta     $0585                           ; 851F 8D 85 05                 ...
        lda     $0573                           ; 8522 AD 73 05                 .s.
        sta     $0586                           ; 8525 8D 86 05                 ...
        lda     #$00                            ; 8528 A9 00                    ..
        sta     $0599                           ; 852A 8D 99 05                 ...
        cmp     nmiWaitVar                      ; 852D C5 3C                    .<
        beq     L853A                           ; 852F F0 09                    ..
        ldx     #$FF                            ; 8531 A2 FF                    ..
        stx     $05BA                           ; 8533 8E BA 05                 ...
        inx                                     ; 8536 E8                       .
        stx     $05BB                           ; 8537 8E BB 05                 ...
L853A:
        lda     $3F                             ; 853A A5 3F                    .?
        beq     L85BB                           ; 853C F0 7D                    .}
        jsr     L8FCE                           ; 853E 20 CE 8F                  ..
        beq     L8516                           ; 8541 F0 D3                    ..
        lda     #$00                            ; 8543 A9 00                    ..
        sta     nmiWaitVar                      ; 8545 85 3C                    .<
        txa                                     ; 8547 8A                       .
        and     #$C0                            ; 8548 29 C0                    ).
        bne     L856B                           ; 854A D0 1F                    ..
        sta     $05BB                           ; 854C 8D BB 05                 ...
        txa                                     ; 854F 8A                       .
        and     #$01                            ; 8550 29 01                    ).
        and     $05BA                           ; 8552 2D BA 05                 -..
        bne     L85B0                           ; 8555 D0 59                    .Y
        txa                                     ; 8557 8A                       .
        and     #$04                            ; 8558 29 04                    ).
        bne     L8594                           ; 855A D0 38                    .8
        txa                                     ; 855C 8A                       .
        and     #$08                            ; 855D 29 08                    ).
        bne     L85AA                           ; 855F D0 49                    .I
        txa                                     ; 8561 8A                       .
        and     #$20                            ; 8562 29 20                    ) 
        and     $05BA                           ; 8564 2D BA 05                 -..
        bne     L85D5                           ; 8567 D0 6C                    .l
        beq     L8516                           ; 8569 F0 AB                    ..
L856B:
        lda     $05BB                           ; 856B AD BB 05                 ...
        beq     L8583                           ; 856E F0 13                    ..
        cmp     #$FF                            ; 8570 C9 FF                    ..
        beq     L8585                           ; 8572 F0 11                    ..
        lda     #$FF                            ; 8574 A9 FF                    ..
        dec     $05BB                           ; 8576 CE BB 05                 ...
        beq     L8585                           ; 8579 F0 0A                    ..
        ldy     #$01                            ; 857B A0 01                    ..
        jsr     L902E                           ; 857D 20 2E 90                  ..
        jmp     L8516                           ; 8580 4C 16 85                 L..

; ----------------------------------------------------------------------------
L8583:
        lda     #$19                            ; 8583 A9 19                    ..
L8585:
        sta     $05BB                           ; 8585 8D BB 05                 ...
        lda     #$FF                            ; 8588 A9 FF                    ..
        sta     $05BA                           ; 858A 8D BA 05                 ...
        txa                                     ; 858D 8A                       .
        and     #$40                            ; 858E 29 40                    )@
        beq     L85E6                           ; 8590 F0 54                    .T
        bne     L85E0                           ; 8592 D0 4C                    .L
L8594:
        txa                                     ; 8594 8A                       .
        and     #$02                            ; 8595 29 02                    ).
        beq     L85A4                           ; 8597 F0 0B                    ..
        lda     LC005                           ; 8599 AD 05 C0                 ...
        beq     L85A4                           ; 859C F0 06                    ..
        jsr     L8304                           ; 859E 20 04 83                  ..
        jmp     L841F                           ; 85A1 4C 1F 84                 L..

; ----------------------------------------------------------------------------
L85A4:
        jsr     L8A74                           ; 85A4 20 74 8A                  t.
        jmp     L8516                           ; 85A7 4C 16 85                 L..

; ----------------------------------------------------------------------------
L85AA:
        jsr     L8A1D                           ; 85AA 20 1D 8A                  ..
        jmp     L8516                           ; 85AD 4C 16 85                 L..

; ----------------------------------------------------------------------------
L85B0:
        eor     #$FF                            ; 85B0 49 FF                    I.
        sta     $05BA                           ; 85B2 8D BA 05                 ...
        jsr     L8A92                           ; 85B5 20 92 8A                  ..
        jmp     L846A                           ; 85B8 4C 6A 84                 Lj.

; ----------------------------------------------------------------------------
L85BB:
        inc     $0585                           ; 85BB EE 85 05                 ...
        jsr     L8AB4                           ; 85BE 20 B4 8A                  ..
        lda     $0598                           ; 85C1 AD 98 05                 ...
        beq     L85CF                           ; 85C4 F0 09                    ..
        dec     $0585                           ; 85C6 CE 85 05                 ...
        jsr     L8B52                           ; 85C9 20 52 8B                  R.
        jmp     L846A                           ; 85CC 4C 6A 84                 Lj.

; ----------------------------------------------------------------------------
L85CF:
        jsr     L8CC8                           ; 85CF 20 C8 8C                  ..
        jmp     L8511                           ; 85D2 4C 11 85                 L..

; ----------------------------------------------------------------------------
L85D5:
        eor     #$FF                            ; 85D5 49 FF                    I.
        sta     $05BA                           ; 85D7 8D BA 05                 ...
        jsr     L8A00                           ; 85DA 20 00 8A                  ..
        jmp     L85EE                           ; 85DD 4C EE 85                 L..

; ----------------------------------------------------------------------------
L85E0:
        dec     $0584                           ; 85E0 CE 84 05                 ...
        jmp     L85E9                           ; 85E3 4C E9 85                 L..

; ----------------------------------------------------------------------------
L85E6:
        inc     $0584                           ; 85E6 EE 84 05                 ...
L85E9:
        jsr     L8AB4                           ; 85E9 20 B4 8A                  ..
        ldx     #$04                            ; 85EC A2 04                    ..
L85EE:
        ldy     $0598                           ; 85EE AC 98 05                 ...
        bne     L8605                           ; 85F1 D0 12                    ..
        jsr     L93C6                           ; 85F3 20 C6 93                  ..
        jsr     L8CC8                           ; 85F6 20 C8 8C                  ..
        ldy     #$02                            ; 85F9 A0 02                    ..
        lda     $05BB                           ; 85FB AD BB 05                 ...
        bpl     L8602                           ; 85FE 10 02                    ..
        ldy     #$08                            ; 8600 A0 08                    ..
L8602:
        jsr     L902E                           ; 8602 20 2E 90                  ..
L8605:
        jmp     L8516                           ; 8605 4C 16 85                 L..

; ----------------------------------------------------------------------------
L8608:
        ldx     $061A                           ; 8608 AE 1A 06                 ...
        beq     L8621                           ; 860B F0 14                    ..
        inc     $18                             ; 860D E6 18                    ..
        inc     $0618                           ; 860F EE 18 06                 ...
L8613           := * + 1
        bne     L8619                           ; 8612 D0 05                    ..
        inc     $0619                           ; 8614 EE 19 06                 ...
        inc     $19                             ; 8617 E6 19                    ..
L8619:
        dec     $061A                           ; 8619 CE 1A 06                 ...
        lsr     a                               ; 861C 4A                       J
        lsr     a                               ; 861D 4A                       J
        lsr     a                               ; 861E 4A                       J
        lsr     a                               ; 861F 4A                       J
        rts                                     ; 8620 60                       `

; ----------------------------------------------------------------------------
L8621:
        and     #$0F                            ; 8621 29 0F                    ).
        inx                                     ; 8623 E8                       .
        inc     $061A                           ; 8624 EE 1A 06                 ...
        rts                                     ; 8627 60                       `

; ----------------------------------------------------------------------------
L8628:
        ldx     $061C                           ; 8628 AE 1C 06                 ...
        lda     $0619                           ; 862B AD 19 06                 ...
        clc                                     ; 862E 18                       .
        adc     unknownTable02+1,x              ; 862F 7D 51 9D                 }Q.
        sta     $19                             ; 8632 85 19                    ..
        lda     unknownTable02,x                ; 8634 BD 50 9D                 .P.
        sta     $18                             ; 8637 85 18                    ..
        rts                                     ; 8639 60                       `

; ----------------------------------------------------------------------------
L863A:
        jsr     L8E62                           ; 863A 20 62 8E                  b.
        jsr     L8E7B                           ; 863D 20 7B 8E                  {.
        inc     $061B                           ; 8640 EE 1B 06                 ...
        .byte   $20,$28,$86,$A0,$C8,$B1,$18,$99 ; 8643 20 28 86 A0 C8 B1 18 99   (......
        .byte   $09,$03,$88,$D0,$F8,$AD,$18,$06 ; 864B 09 03 88 D0 F8 AD 18 06  ........
        .byte   $18,$69,$C8,$8D,$18,$06,$20,$5E ; 8653 18 69 C8 8D 18 06 20 5E  .i.... ^
        .byte   $8D                             ; 865B 8D                       .
L865C:
        .byte   $A0,$08,$20,$BB,$8F,$AD,$98,$05 ; 865C A0 08 20 BB 8F AD 98 05  .. .....
        .byte   $D0                             ; 8664 D0                       .
; ----------------------------------------------------------------------------
        bpl     L8613                           ; 8665 10 AC                    ..
        clc                                     ; 8667 18                       .
        asl     $C0                             ; 8668 06 C0                    ..
        .byte   $FF                             ; 866A FF                       .
        bcc     L8679                           ; 866B 90 0C                    ..
        beq     L8679                           ; 866D F0 0A                    ..
        lda     $0619                           ; 866F AD 19 06                 ...
        cmp     #$03                            ; 8672 C9 03                    ..
        bcc     L8679                           ; 8674 90 03                    ..
        jmp     L871B                           ; 8676 4C 1B 87                 L..

; ----------------------------------------------------------------------------
L8679:
        .byte   $20,$28,$86,$B1,$18,$20,$08,$86 ; 8679 20 28 86 B1 18 20 08 86   (... ..
        .byte   $C9                             ; 8681 C9                       .
; ----------------------------------------------------------------------------
        php                                     ; 8682 08                       .
        beq     L86B9                           ; 8683 F0 34                    .4
        bcs     L86D2                           ; 8685 B0 4B                    .K
        sta     $0572                           ; 8687 8D 72 05                 .r.
        jsr     L8628                           ; 868A 20 28 86                  (.
        ldy     $0618                           ; 868D AC 18 06                 ...
        lda     ($18),y                         ; 8690 B1 18                    ..
        jsr     L8608                           ; 8692 20 08 86                  ..
        sta     $0573                           ; 8695 8D 73 05                 .s.
        sta     $0586                           ; 8698 8D 86 05                 ...
        jsr     L8E9C                           ; 869B 20 9C 8E                  ..
        ldx     #$FF                            ; 869E A2 FF                    ..
        stx     $0574                           ; 86A0 8E 74 05                 .t.
        ldx     #$0F                            ; 86A3 A2 0F                    ..
        stx     $0570                           ; 86A5 8E 70 05                 .p.
        stx     $0584                           ; 86A8 8E 84 05                 ...
        ldy     #$06                            ; 86AB A0 06                    ..
        sty     $0571                           ; 86AD 8C 71 05                 .q.
        sty     $0585                           ; 86B0 8C 85 05                 ...
        jsr     L8D36                           ; 86B3 20 36 8D                  6.
        jmp     L865C                           ; 86B6 4C 5C 86                 L\.

; ----------------------------------------------------------------------------
L86B9:
        ldx     #$00                            ; 86B9 A2 00                    ..
        jsr     L93C6                           ; 86BB 20 C6 93                  ..
        ldx     $0573                           ; 86BE AE 73 05                 .s.
        inx                                     ; 86C1 E8                       .
        inx                                     ; 86C2 E8                       .
        cpx     #$08                            ; 86C3 E0 08                    ..
        bcc     L86C9                           ; 86C5 90 02                    ..
        ldx     #$00                            ; 86C7 A2 00                    ..
L86C9:
        stx     $0586                           ; 86C9 8E 86 05                 ...
        jsr     L8CC8                           ; 86CC 20 C8 8C                  ..
        jmp     L865C                           ; 86CF 4C 5C 86                 L\.

; ----------------------------------------------------------------------------
L86D2:
        cmp     #$09                            ; 86D2 C9 09                    ..
        bne     L86DC                           ; 86D4 D0 06                    ..
        dec     $0584                           ; 86D6 CE 84 05                 ...
        jmp     L86E3                           ; 86D9 4C E3 86                 L..

; ----------------------------------------------------------------------------
L86DC:
        cmp     #$0A                            ; 86DC C9 0A                    ..
        bne     L86EE                           ; 86DE D0 0E                    ..
        inc     $0584                           ; 86E0 EE 84 05                 ...
L86E3:
        ldx     #$04                            ; 86E3 A2 04                    ..
        jsr     L93C6                           ; 86E5 20 C6 93                  ..
        jsr     L8CC8                           ; 86E8 20 C8 8C                  ..
        jmp     L865C                           ; 86EB 4C 5C 86                 L\.

; ----------------------------------------------------------------------------
L86EE:
        cmp     #$0C                            ; 86EE C9 0C                    ..
        bne     L86FB                           ; 86F0 D0 09                    ..
        inc     $0585                           ; 86F2 EE 85 05                 ...
        jsr     L8CC8                           ; 86F5 20 C8 8C                  ..
        jmp     L865C                           ; 86F8 4C 5C 86                 L\.

; ----------------------------------------------------------------------------
L86FB:
        cmp     #$0D                            ; 86FB C9 0D                    ..
        bne     L8711                           ; 86FD D0 12                    ..
        ldx     $0570                           ; 86FF AE 70 05                 .p.
        stx     $0584                           ; 8702 8E 84 05                 ...
        ldy     $0571                           ; 8705 AC 71 05                 .q.
        sty     $0585                           ; 8708 8C 85 05                 ...
        jsr     L8B52                           ; 870B 20 52 8B                  R.
        jmp     L865C                           ; 870E 4C 5C 86                 L\.

; ----------------------------------------------------------------------------
L8711:
        cmp     #$0B                            ; 8711 C9 0B                    ..
        bne     L871B                           ; 8713 D0 06                    ..
        jsr     L8A92                           ; 8715 20 92 8A                  ..
        jmp     L865C                           ; 8718 4C 5C 86                 L\.

; ----------------------------------------------------------------------------
L871B:
        jsr     L8CE7                           ; 871B 20 E7 8C                  ..
        lda     rngSeed                         ; 871E A5 56                    .V
        and     #$02                            ; 8720 29 02                    ).
        jsr     L9D54                           ; 8722 20 54 9D                  T.
        .byte   $AD,$98,$05,$D0,$05,$A0,$5A,$20 ; 8725 AD 98 05 D0 05 A0 5A 20  ......Z 
        .byte   $BB,$8F,$CE,$1B,$06,$60         ; 872D BB 8F CE 1B 06 60        .....`
L8733:
        .byte   $A2,$FF,$8E,$74,$05,$E8,$8E,$18 ; 8733 A2 FF 8E 74 05 E8 8E 18  ...t....
        .byte   $06,$8E,$19,$06,$8E,$1A,$06,$8E ; 873B 06 8E 19 06 8E 1A 06 8E  ........
        .byte   $98,$05,$8E,$7F,$05,$20,$28,$86 ; 8743 98 05 8E 7F 05 20 28 86  ..... (.
        .byte   $A2,$19,$8E,$80,$05,$A0,$00,$20 ; 874B A2 19 8E 80 05 A0 00 20  ....... 
        .byte   $74,$8C,$A0,$00,$B1,$18,$20,$08 ; 8753 74 8C A0 00 B1 18 20 08  t..... .
        .byte   $86,$8D,$96,$05,$A8,$BE,$14,$89 ; 875B 86 8D 96 05 A8 BE 14 89  ........
        .byte   $8E,$97,$05,$A0,$00,$B1,$18,$20 ; 8763 8E 97 05 A0 00 B1 18 20  ....... 
        .byte   $08,$86,$8D,$95,$05,$20,$EE,$91 ; 876B 08 86 8D 95 05 20 EE 91  ..... ..
        .byte   $60                             ; 8773 60                       `
L8774:
        .byte   $A2,$08,$A9,$03,$85,$2A,$A9,$00 ; 8774 A2 08 A9 03 85 2A A9 00  .....*..
        .byte   $8D                             ; 877C 8D                       .
; ----------------------------------------------------------------------------
        tya                                     ; 877D 98                       .
        ora     $A0                             ; 877E 05 A0                    ..
        .byte   $07                             ; 8780 07                       .
L8781:
        sty     $1C                             ; 8781 84 1C                    ..
        lda     $0587,y                         ; 8783 B9 87 05                 ...
        bne     L8797                           ; 8786 D0 0F                    ..
        lda     $0598                           ; 8788 AD 98 05                 ...
        bne     L8795                           ; 878B D0 08                    ..
        lda     #$32                            ; 878D A9 32                    .2
        dec     $0598                           ; 878F CE 98 05                 ...
        jmp     L8797                           ; 8792 4C 97 87                 L..

; ----------------------------------------------------------------------------
L8795:
        lda     #$0A                            ; 8795 A9 0A                    ..
L8797:
        ldy     #$02                            ; 8797 A0 02                    ..
        jsr     L9323                           ; 8799 20 23 93                  #.
        inc     $0598                           ; 879C EE 98 05                 ...
        inx                                     ; 879F E8                       .
        ldy     $1C                             ; 87A0 A4 1C                    ..
        dey                                     ; 87A2 88                       .
        bpl     L8781                           ; 87A3 10 DC                    ..
        jsr     L9054                           ; 87A5 20 54 90                  T.
        rts                                     ; 87A8 60                       `

; ----------------------------------------------------------------------------
L87A9:
        ora     $07                             ; 87A9 05 07                    ..
        ora     #$0B                            ; 87AB 09 0B                    ..
        ora     $0705                           ; 87AD 0D 05 07                 ...
        ora     #$0B                            ; 87B0 09 0B                    ..
        .byte   $0D,$15,$17,$19,$15,$17,$19     ; 87B2 0D 15 17 19 15 17 19     .......
L87B9:
        .byte   $09,$09,$09,$09,$09,$0B,$0B,$0B ; 87B9 09 09 09 09 09 0B 0B 0B  ........
        .byte   $0B,$0B,$09,$09,$09,$0B,$0B,$0B ; 87C1 0B 0B 09 09 09 0B 0B 0B  ........
        .byte   $00,$0A                         ; 87C9 00 0A                    ..
L87CB:
        .byte   $05,$03                         ; 87CB 05 03                    ..
L87CD:
        .byte   $0A,$06                         ; 87CD 0A 06                    ..
L87CF:
        .byte   $A2,$00,$8E,$96,$05,$8E,$95,$05 ; 87CF A2 00 8E 96 05 8E 95 05  ........
        .byte   $8E                             ; 87D7 8E                       .
; ----------------------------------------------------------------------------
        lda     PPUSCROLL,y                     ; 87D8 B9 05 20                 .. 
        .byte   $1A                             ; 87DB 1A                       .
        .byte   $89                             ; 87DC 89                       .
        lda     #$01                            ; 87DD A9 01                    ..
        jsr     L89DB                           ; 87DF 20 DB 89                  ..
        lda     #$03                            ; 87E2 A9 03                    ..
        sta     $3F                             ; 87E4 85 3F                    .?
L87E6:
        lda     $3F                             ; 87E6 A5 3F                    .?
        bne     L87E6                           ; 87E8 D0 FC                    ..
        jsr     L8FCE                           ; 87EA 20 CE 8F                  ..
        beq     L87E6                           ; 87ED F0 F7                    ..
        txa                                     ; 87EF 8A                       .
        and     #$F1                            ; 87F0 29 F1                    ).
        bne     L880E                           ; 87F2 D0 1A                    ..
        ldx     $05B9                           ; 87F4 AE B9 05                 ...
        beq     L8809                           ; 87F7 F0 10                    ..
        ldx     #$00                            ; 87F9 A2 00                    ..
        jsr     L93C6                           ; 87FB 20 C6 93                  ..
        lda     #$03                            ; 87FE A9 03                    ..
        jsr     L89DB                           ; 8800 20 DB 89                  ..
        .byte   $CE,$B9,$05,$20,$1A,$89         ; 8803 CE B9 05 20 1A 89        ... ..
L8809:
        .byte   $A9,$14,$4C,$90,$88             ; 8809 A9 14 4C 90 88           ..L..
L880E:
        .byte   $29,$F0,$D0,$1F                 ; 880E 29 F0 D0 1F              )...
; ----------------------------------------------------------------------------
        lda     #$02                            ; 8812 A9 02                    ..
        jsr     L89DB                           ; 8814 20 DB 89                  ..
        inc     $05B9                           ; 8817 EE B9 05                 ...
        ldx     #$18                            ; 881A A2 18                    ..
        jsr     L93C6                           ; 881C 20 C6 93                  ..
        jsr     L891A                           ; 881F 20 1A 89                  ..
        lda     $05B9                           ; 8822 AD B9 05                 ...
        cmp     #$02                            ; 8825 C9 02                    ..
        bcs     L882E                           ; 8827 B0 05                    ..
        lda     #$14                            ; 8829 A9 14                    ..
        jmp     L8890                           ; 882B 4C 90 88                 L..

; ----------------------------------------------------------------------------
L882E:
        jmp     L889A                           ; 882E 4C 9A 88                 L..

; ----------------------------------------------------------------------------
        pha                                     ; 8831 48                       H
        ldx     #$14                            ; 8832 A2 14                    ..
        jsr     L93C6                           ; 8834 20 C6 93                  ..
        lda     #$03                            ; 8837 A9 03                    ..
        jsr     L89DB                           ; 8839 20 DB 89                  ..
        pla                                     ; 883C 68                       h
        tax                                     ; 883D AA                       .
        ldy     $05B9                           ; 883E AC B9 05                 ...
        and     #$10                            ; 8841 29 10                    ).
        beq     L8854                           ; 8843 F0 0F                    ..
        lda     $0595,y                         ; 8845 B9 95 05                 ...
        sec                                     ; 8848 38                       8
        sbc     L87CB,y                         ; 8849 F9 CB 87                 ...
        bcs     L888B                           ; 884C B0 3D                    .=
        .byte   $79,$CD,$87,$4C,$8B,$88         ; 884E 79 CD 87 4C 8B 88        y..L..
L8854:
        .byte   $8A,$29,$20,$F0,$12,$B9,$95,$05 ; 8854 8A 29 20 F0 12 B9 95 05  .) .....
        .byte   $18                             ; 885C 18                       .
; ----------------------------------------------------------------------------
        adc     L87CB,y                         ; 885D 79 CB 87                 y..
        cmp     L87CD,y                         ; 8860 D9 CD 87                 ...
        bcc     L888B                           ; 8863 90 26                    .&
        sbc     L87CD,y                         ; 8865 F9 CD 87                 ...
        jmp     L888B                           ; 8868 4C 8B 88                 L..

; ----------------------------------------------------------------------------
        txa                                     ; 886B 8A                       .
        and     #$40                            ; 886C 29 40                    )@
        .byte   $F0,$0F,$BE,$95,$05,$CA         ; 886E F0 0F BE 95 05 CA        ......
; ----------------------------------------------------------------------------
        txa                                     ; 8874 8A                       .
        bpl     L888B                           ; 8875 10 14                    ..
        ldx     L87CD,y                         ; 8877 BE CD 87                 ...
        .byte   $CA,$8A,$4C,$8B,$88,$BE,$95,$05 ; 887A CA 8A 4C 8B 88 BE 95 05  ..L.....
        .byte   $E8,$8A,$D9,$CD,$87,$90         ; 8882 E8 8A D9 CD 87 90        ......
; ----------------------------------------------------------------------------
        .byte   $02                             ; 8888 02                       .
        lda     #$00                            ; 8889 A9 00                    ..
L888B:
        sta     $0595,y                         ; 888B 99 95 05                 ...
        lda     #$0C                            ; 888E A9 0C                    ..
L8890:
        sta     $3F                             ; 8890 85 3F                    .?
        .byte   $A9,$01                         ; 8892 A9 01                    ..
; ----------------------------------------------------------------------------
        jsr     L89DB                           ; 8894 20 DB 89                  ..
        jmp     L87E6                           ; 8897 4C E6 87                 L..

; ----------------------------------------------------------------------------
L889A:
        lda     $0614                           ; 889A AD 14 06                 ...
        jsr     LBC1F                           ; 889D 20 1F BC                  ..
        lda     #$01                            ; 88A0 A9 01                    ..
        jsr     L8977                           ; 88A2 20 77 89                  w.
        jsr     L8A83                           ; 88A5 20 83 8A                  ..
L88A8:
        jsr     L8FCE                           ; 88A8 20 CE 8F                  ..
        txa                                     ; 88AB 8A                       .
        beq     L88A8                           ; 88AC F0 FA                    ..
        and     #$F1                            ; 88AE 29 F1                    ).
        beq     L88F2                           ; 88B0 F0 40                    .@
        and     #$01                            ; 88B2 29 01                    ).
        bne     L88E3                           ; 88B4 D0 2D                    .-
        txa                                     ; 88B6 8A                       .
        pha                                     ; 88B7 48                       H
        lda     #$03                            ; 88B8 A9 03                    ..
        jsr     L8977                           ; 88BA 20 77 89                  w.
        pla                                     ; 88BD 68                       h
        and     #$50                            ; 88BE 29 50                    )P
        bne     L88D0                           ; 88C0 D0 0E                    ..
        ldx     $0614                           ; 88C2 AE 14 06                 ...
        inx                                     ; 88C5 E8                       .
        cpx     $0615                           ; 88C6 EC 15 06                 ...
        bcc     L88DD                           ; 88C9 90 12                    ..
        .byte   $A2,$FF,$4C,$DD,$88             ; 88CB A2 FF 4C DD 88           ..L..
L88D0:
        .byte   $AE,$14,$06,$30,$04,$CA,$4C,$DD ; 88D0 AE 14 06 30 04 CA 4C DD  ...0..L.
        .byte   $88                             ; 88D8 88                       .
; ----------------------------------------------------------------------------
        ldx     $0615                           ; 88D9 AE 15 06                 ...
        dex                                     ; 88DC CA                       .
L88DD:
        stx     $0614                           ; 88DD 8E 14 06                 ...
        jmp     L889A                           ; 88E0 4C 9A 88                 L..

; ----------------------------------------------------------------------------
L88E3:
        .byte   $A9,$02,$20                     ; 88E3 A9 02 20                 .. 
; ----------------------------------------------------------------------------
        .byte   $77                             ; 88E6 77                       w
        .byte   $89                             ; 88E7 89                       .
        ldx     $0596                           ; 88E8 AE 96 05                 ...
        lda     L8914,x                         ; 88EB BD 14 89                 ...
        sta     $0597                           ; 88EE 8D 97 05                 ...
        rts                                     ; 88F1 60                       `

; ----------------------------------------------------------------------------
L88F2:
        ldx     #$00                            ; 88F2 A2 00                    ..
        jsr     L93C6                           ; 88F4 20 C6 93                  ..
        lda     #$03                            ; 88F7 A9 03                    ..
        jsr     L8977                           ; 88F9 20 77 89                  w.
        .byte   $CE,$B9,$05,$20,$1A,$89,$A9,$14 ; 88FC CE B9 05 20 1A 89 A9 14  ... ....
        .byte   $4C,$90,$88                     ; 8904 4C 90 88                 L..
L8907:
        .byte   $50,$41,$32,$28,$20,$19,$14,$11 ; 8907 50 41 32 28 20 19 14 11  PA2( ...
        .byte   $0F,$0D,$08,$06,$05             ; 890F 0F 0D 08 06 05           .....
L8914:
        .byte   $00,$03,$06,$08,$0A,$0C         ; 8914 00 03 06 08 0A 0C        ......
L891A:
        .byte   $A2,$00                         ; 891A A2 00                    ..
L891C:
        .byte   $A9,$01,$86,$1C,$EC,$B9,$05     ; 891C A9 01 86 1C EC B9 05     .......
; ----------------------------------------------------------------------------
        beq     L892B                           ; 8923 F0 06                    ..
        lda     #$02                            ; 8925 A9 02                    ..
        bcc     L892B                           ; 8927 90 02                    ..
        lda     #$03                            ; 8929 A9 03                    ..
L892B:
        sta     $2A                             ; 892B 85 2A                    .*
        txa                                     ; 892D 8A                       .
        asl     a                               ; 892E 0A                       .
        asl     a                               ; 892F 0A                       .
        adc     $1C                             ; 8930 65 1C                    e.
        sta     $1D                             ; 8932 85 1D                    ..
        tay                                     ; 8934 A8                       .
        lda     L8965,x                         ; 8935 BD 65 89                 .e.
        tay                                     ; 8938 A8                       .
        lda     #$05                            ; 8939 A9 05                    ..
        sta     tmp14                           ; 893B 85 14                    ..
        lda     L8962,x                         ; 893D BD 62 89                 .b.
        tax                                     ; 8940 AA                       .
L8941:
        stx     $0570                           ; 8941 8E 70 05                 .p.
        ldx     $1D                             ; 8944 A6 1D                    ..
        lda     L8968,x                         ; 8946 BD 68 89                 .h.
        inc     $1D                             ; 8949 E6 1D                    ..
        ldx     $0570                           ; 894B AE 70 05                 .p.
        jsr     L9323                           ; 894E 20 23 93                  #.
        inx                                     ; 8951 E8                       .
        inx                                     ; 8952 E8                       .
        dec     tmp14                           ; 8953 C6 14                    ..
        bne     L8941                           ; 8955 D0 EA                    ..
        ldx     $1C                             ; 8957 A6 1C                    ..
        inx                                     ; 8959 E8                       .
        cpx     #$03                            ; 895A E0 03                    ..
        bcc     L891C                           ; 895C 90 BE                    ..
        jsr     L9054                           ; 895E 20 54 90                  T.
        rts                                     ; 8961 60                       `

; ----------------------------------------------------------------------------
L8962:
        ora     tmp13                           ; 8962 05 13                    ..
        .byte   $0B                             ; 8964 0B                       .
L8965:
        ora     $05                             ; 8965 05 05                    ..
L8968           := * + 1
        ora     (xBackup),y                     ; 8967 11 2C                    .,
        .byte   $5B                             ; 8969 5B                       [
        eor     $2C2C,x                         ; 896A 5D 2C 2C                 ],,
        .byte   $2C,$71,$72,$2C,$2C,$2C,$57,$59 ; 896D 2C 71 72 2C 2C 2C 57 59  ,qr,,,WY
        .byte   $2C,$2C                         ; 8975 2C 2C                    ,,
L8977:
        .byte   $AC,$04,$C0,$D0,$30,$85,$2A,$AE ; 8977 AC 04 C0 D0 30 85 2A AE  ....0.*.
        .byte   $14                             ; 897F 14                       .
; ----------------------------------------------------------------------------
        asl     $E8                             ; 8980 06 E8                    ..
        stx     tmp15                           ; 8982 86 15                    ..
        txa                                     ; 8984 8A                       .
        asl     a                               ; 8985 0A                       .
        pha                                     ; 8986 48                       H
        asl     a                               ; 8987 0A                       .
        asl     a                               ; 8988 0A                       .
        adc     tmp15                           ; 8989 65 15                    e.
        sta     tmp15                           ; 898B 85 15                    ..
        pla                                     ; 898D 68                       h
        clc                                     ; 898E 18                       .
        adc     #$15                            ; 898F 69 15                    i.
        tay                                     ; 8991 A8                       .
        lda     #$09                            ; 8992 A9 09                    ..
        sta     tmp14                           ; 8994 85 14                    ..
        ldx     #$07                            ; 8996 A2 07                    ..
L8998:
        stx     tmp14                           ; 8998 86 14                    ..
        ldx     tmp15                           ; 899A A6 15                    ..
        lda     L89AD,x                         ; 899C BD AD 89                 ...
        inc     tmp15                           ; 899F E6 15                    ..
        ldx     tmp14                           ; 89A1 A6 14                    ..
        jsr     L9323                           ; 89A3 20 23 93                  #.
        inx                                     ; 89A6 E8                       .
        inx                                     ; 89A7 E8                       .
        cpx     #$19                            ; 89A8 E0 19                    ..
        bcc     L8998                           ; 89AA 90 EC                    ..
        rts                                     ; 89AC 60                       `

; ----------------------------------------------------------------------------
L89AD:
        bit     $582C                           ; 89AD 2C 2C 58                 ,,X
        rol     $5E72                           ; 89B0 2E 72 5E                 .r^
        bit     $2C2C                           ; 89B3 2C 2C 2C                 ,,,
        .byte   $2C,$2C,$5B,$5A,$72,$5B,$59,$2C ; 89B6 2C 2C 5B 5A 72 5B 59 2C  ,,[Zr[Y,
        .byte   $2C,$2C,$2C,$5F,$5F,$72,$5C,$2C ; 89BE 2C 2C 2C 5F 5F 72 5C 2C  ,,,__r\,
        .byte   $2C,$2C,$2C,$2C,$5B,$71,$5F,$2C ; 89C6 2C 2C 2C 2C 5B 71 5F 2C  ,,,,[q_,
        .byte   $2C,$2C,$2C                     ; 89CE 2C 2C 2C                 ,,,
L89D1:
        .byte   $75,$77,$79,$7B,$7D,$7F,$83,$87 ; 89D1 75 77 79 7B 7D 7F 83 87  uwy{}...
        .byte   $8B,$8F                         ; 89D9 8B 8F                    ..
L89DB:
        .byte   $85,$2A,$AC,$B9,$05,$B9,$C9,$87 ; 89DB 85 2A AC B9 05 B9 C9 87  .*......
        .byte   $18                             ; 89E3 18                       .
; ----------------------------------------------------------------------------
        adc     $0595,y                         ; 89E4 79 95 05                 y..
        tax                                     ; 89E7 AA                       .
        lda     L87B9,x                         ; 89E8 BD B9 87                 ...
        sta     $0571                           ; 89EB 8D 71 05                 .q.
        lda     L87A9,x                         ; 89EE BD A9 87                 ...
        tax                                     ; 89F1 AA                       .
        lda     $0595,y                         ; 89F2 B9 95 05                 ...
        tay                                     ; 89F5 A8                       .
        lda     L89D1,y                         ; 89F6 B9 D1 89                 ...
        ldy     $0571                           ; 89F9 AC 71 05                 .q.
        jsr     L9335                           ; 89FC 20 35 93                  5.
        rts                                     ; 89FF 60                       `

; ----------------------------------------------------------------------------
L8A00:
        lda     $0573                           ; 8A00 AD 73 05                 .s.
        pha                                     ; 8A03 48                       H
        clc                                     ; 8A04 18                       .
        adc     #$02                            ; 8A05 69 02                    i.
        cmp     #$08                            ; 8A07 C9 08                    ..
        bcc     L8A0D                           ; 8A09 90 02                    ..
        lda     #$00                            ; 8A0B A9 00                    ..
L8A0D:
        sta     $0586                           ; 8A0D 8D 86 05                 ...
        sta     $0573                           ; 8A10 8D 73 05                 .s.
        jsr     L8AB4                           ; 8A13 20 B4 8A                  ..
        pla                                     ; 8A16 68                       h
        sta     $0573                           ; 8A17 8D 73 05                 .s.
        ldx     #$00                            ; 8A1A A2 00                    ..
        rts                                     ; 8A1C 60                       `

; ----------------------------------------------------------------------------
L8A1D:
        lda     $3F                             ; 8A1D A5 3F                    .?
        pha                                     ; 8A1F 48                       H
        jsr     L8CE7                           ; 8A20 20 E7 8C                  ..
        ldx     #$C8                            ; 8A23 A2 C8                    ..
L8A25:
        lda     $0309,x                         ; 8A25 BD 09 03                 ...
        sta     $03D1,x                         ; 8A28 9D D1 03                 ...
        dex                                     ; 8A2B CA                       .
        bne     L8A25                           ; 8A2C D0 F7                    ..
        ldx     #$C8                            ; 8A2E A2 C8                    ..
L8A30:
        lda     LAEC0,x                         ; 8A30 BD C0 AE                 ...
        sta     $0309,x                         ; 8A33 9D 09 03                 ...
        dex                                     ; 8A36 CA                       .
        bne     L8A30                           ; 8A37 D0 F7                    ..
        jsr     L976C                           ; 8A39 20 6C 97                  l.
        lda     #$06                            ; 8A3C A9 06                    ..
        jsr     L92DD                           ; 8A3E 20 DD 92                  ..
        jsr     L8D5E                           ; 8A41 20 5E 8D                  ^.
        jsr     L8A83                           ; 8A44 20 83 8A                  ..
L8A47:
        lda     $3A                             ; 8A47 A5 3A                    .:
        beq     L8A47                           ; 8A49 F0 FC                    ..
        jsr     L8A83                           ; 8A4B 20 83 8A                  ..
        ldx     #$C8                            ; 8A4E A2 C8                    ..
L8A50:
        lda     $03D1,x                         ; 8A50 BD D1 03                 ...
        sta     $0309,x                         ; 8A53 9D 09 03                 ...
        dex                                     ; 8A56 CA                       .
        bne     L8A50                           ; 8A57 D0 F7                    ..
        jsr     L91EE                           ; 8A59 20 EE 91                  ..
        lda     #$06                            ; 8A5C A9 06                    ..
        jsr     L92DD                           ; 8A5E 20 DD 92                  ..
        jsr     L8D5E                           ; 8A61 20 5E 8D                  ^.
        dec     $0574                           ; 8A64 CE 74 05                 .t.
        ldx     $0570                           ; 8A67 AE 70 05                 .p.
        ldy     $0571                           ; 8A6A AC 71 05                 .q.
        jsr     L8D36                           ; 8A6D 20 36 8D                  6.
        pla                                     ; 8A70 68                       h
        sta     $3F                             ; 8A71 85 3F                    .?
        rts                                     ; 8A73 60                       `

; ----------------------------------------------------------------------------
L8A74:
        lda     $0579                           ; 8A74 AD 79 05                 .y.
        eor     #$FF                            ; 8A77 49 FF                    I.
        sta     $0579                           ; 8A79 8D 79 05                 .y.
        jsr     L8EFD                           ; 8A7C 20 FD 8E                  ..
        jsr     L8A83                           ; 8A7F 20 83 8A                  ..
        rts                                     ; 8A82 60                       `

; ----------------------------------------------------------------------------
L8A83:
        lda     $3F                             ; 8A83 A5 3F                    .?
        pha                                     ; 8A85 48                       H
        lda     #$00                            ; 8A86 A9 00                    ..
        sta     nmiWaitVar                      ; 8A88 85 3C                    .<
@waitForNmi:
        lda     nmiWaitVar                      ; 8A8A A5 3C                    .<
        beq     @waitForNmi                     ; 8A8C F0 FC                    ..
        pla                                     ; 8A8E 68                       h
        sta     $3F                             ; 8A8F 85 3F                    .?
        rts                                     ; 8A91 60                       `

; ----------------------------------------------------------------------------
L8A92:
        ldx     #$08                            ; 8A92 A2 08                    ..
        jsr     L93C6                           ; 8A94 20 C6 93                  ..
L8A97:
        inc     $0585                           ; 8A97 EE 85 05                 ...
        inc     $0581                           ; 8A9A EE 81 05                 ...
        bne     L8AA2                           ; 8A9D D0 03                    ..
        inc     $0582                           ; 8A9F EE 82 05                 ...
L8AA2:
        jsr     L8AB4                           ; 8AA2 20 B4 8A                  ..
        lda     $0598                           ; 8AA5 AD 98 05                 ...
        beq     L8A97                           ; 8AA8 F0 ED                    ..
        dec     $0585                           ; 8AAA CE 85 05                 ...
        jsr     L8B52                           ; 8AAD 20 52 8B                  R.
        jsr     L8A83                           ; 8AB0 20 83 8A                  ..
        rts                                     ; 8AB3 60                       `

; ----------------------------------------------------------------------------
L8AB4:
        jsr     L8E9C                           ; 8AB4 20 9C 8E                  ..
        ldy     #$00                            ; 8AB7 A0 00                    ..
        sty     $0598                           ; 8AB9 8C 98 05                 ...
L8ABC:
        sty     $1C                             ; 8ABC 84 1C                    ..
        lda     ($43),y                         ; 8ABE B1 43                    .C
        beq     L8AED                           ; 8AC0 F0 2B                    .+
        sta     tmp14                           ; 8AC2 85 14                    ..
        lda     $1C                             ; 8AC4 A5 1C                    ..
        and     #$03                            ; 8AC6 29 03                    ).
        clc                                     ; 8AC8 18                       .
        adc     $0584                           ; 8AC9 6D 84 05                 m..
        tax                                     ; 8ACC AA                       .
        lda     $1C                             ; 8ACD A5 1C                    ..
        and     #$0C                            ; 8ACF 29 0C                    ).
        lsr     a                               ; 8AD1 4A                       J
        lsr     a                               ; 8AD2 4A                       J
        clc                                     ; 8AD3 18                       .
        adc     $0585                           ; 8AD4 6D 85 05                 m..
        tay                                     ; 8AD7 A8                       .
        lda     $0599                           ; 8AD8 AD 99 05                 ...
        beq     L8AE5                           ; 8ADB F0 08                    ..
        lda     tmp14                           ; 8ADD A5 14                    ..
        jsr     L8C2F                           ; 8ADF 20 2F 8C                  /.
        jmp     L8AED                           ; 8AE2 4C ED 8A                 L..

; ----------------------------------------------------------------------------
L8AE5:
        jsr     L8AF5                           ; 8AE5 20 F5 8A                  ..
        lda     $0598                           ; 8AE8 AD 98 05                 ...
        bne     L8AF4                           ; 8AEB D0 07                    ..
L8AED:
        ldy     $1C                             ; 8AED A4 1C                    ..
        iny                                     ; 8AEF C8                       .
        cpy     #$10                            ; 8AF0 C0 10                    ..
        bcc     L8ABC                           ; 8AF2 90 C8                    ..
L8AF4:
        rts                                     ; 8AF4 60                       `

; ----------------------------------------------------------------------------
L8AF5:
        cpx     #$0B                            ; 8AF5 E0 0B                    ..
        beq     L8B0A                           ; 8AF7 F0 11                    ..
        cpx     #$16                            ; 8AF9 E0 16                    ..
        beq     L8B0A                           ; 8AFB F0 0D                    ..
        cpy     #$1A                            ; 8AFD C0 1A                    ..
        bcs     L8B0A                           ; 8AFF B0 09                    ..
        jsr     L8C3C                           ; 8B01 20 3C 8C                  <.
        tax                                     ; 8B04 AA                       .
        lda     $030A,x                         ; 8B05 BD 0A 03                 ...
        beq     L8B0D                           ; 8B08 F0 03                    ..
L8B0A:
        inc     $0598                           ; 8B0A EE 98 05                 ...
L8B0D:
        rts                                     ; 8B0D 60                       `

; ----------------------------------------------------------------------------
L8B0E:
        ldy     #$12                            ; 8B0E A0 12                    ..
L8B10:
        sty     $1C                             ; 8B10 84 1C                    ..
        tya                                     ; 8B12 98                       .
        jsr     L8E93                           ; 8B13 20 93 8E                  ..
        tax                                     ; 8B16 AA                       .
        ldy     #$14                            ; 8B17 A0 14                    ..
        sta     $1D                             ; 8B19 85 1D                    ..
        lda     #$37                            ; 8B1B A9 37                    .7
L8B1D:
        sta     $030A,x                         ; 8B1D 9D 0A 03                 ...
        inx                                     ; 8B20 E8                       .
        dey                                     ; 8B21 88                       .
        bne     L8B1D                           ; 8B22 D0 F9                    ..
        jsr     L8C1F                           ; 8B24 20 1F 8C                  ..
        jsr     L8D5E                           ; 8B27 20 5E 8D                  ^.
        ldy     $1C                             ; 8B2A A4 1C                    ..
        dey                                     ; 8B2C 88                       .
        dey                                     ; 8B2D 88                       .
        bpl     L8B10                           ; 8B2E 10 E0                    ..
        dec     $059E                           ; 8B30 CE 9E 05                 ...
        jsr     L8F49                           ; 8B33 20 49 8F                  I.
        ldy     #$14                            ; 8B36 A0 14                    ..
        jsr     L902E                           ; 8B38 20 2E 90                  ..
        inc     $059E                           ; 8B3B EE 9E 05                 ...
        jsr     L8F49                           ; 8B3E 20 49 8F                  I.
        ldy     #$14                            ; 8B41 A0 14                    ..
        jsr     L902E                           ; 8B43 20 2E 90                  ..
        dec     $059E                           ; 8B46 CE 9E 05                 ...
        jsr     L8F49                           ; 8B49 20 49 8F                  I.
        ldy     #$28                            ; 8B4C A0 28                    .(
        jsr     L902E                           ; 8B4E 20 2E 90                  ..
        rts                                     ; 8B51 60                       `

; ----------------------------------------------------------------------------
L8B52:
        jsr     L8CE7                           ; 8B52 20 E7 8C                  ..
        lda     #$01                            ; 8B55 A9 01                    ..
        sta     $0599                           ; 8B57 8D 99 05                 ...
        jsr     L8AB4                           ; 8B5A 20 B4 8A                  ..
        dec     $0599                           ; 8B5D CE 99 05                 ...
        ldx     #$0C                            ; 8B60 A2 0C                    ..
        jsr     L93C6                           ; 8B62 20 C6 93                  ..
        jsr     L8D5E                           ; 8B65 20 5E 8D                  ^.
        jsr     L8D74                           ; 8B68 20 74 8D                  t.
        jsr     L8DBE                           ; 8B6B 20 BE 8D                  ..
        jsr     L8D5E                           ; 8B6E 20 5E 8D                  ^.
        jsr     L8E62                           ; 8B71 20 62 8E                  b.
        lda     $061B                           ; 8B74 AD 1B 06                 ...
        bne     L8B81                           ; 8B77 D0 08                    ..
        lda     $057F                           ; 8B79 AD 7F 05                 ...
        cmp     $0580                           ; 8B7C CD 80 05                 ...
        bcs     L8B82                           ; 8B7F B0 01                    ..
L8B81:
        rts                                     ; 8B81 60                       `

; ----------------------------------------------------------------------------
L8B82:
        jsr     L8CE7                           ; 8B82 20 E7 8C                  ..
        jsr     L8C1F                           ; 8B85 20 1F 8C                  ..
        ldx     #$C8                            ; 8B88 A2 C8                    ..
L8B8A:
        lda     #$00                            ; 8B8A A9 00                    ..
        sta     $03D1,x                         ; 8B8C 9D D1 03                 ...
        dex                                     ; 8B8F CA                       .
        bne     L8B8A                           ; 8B90 D0 F8                    ..
        ldx     #$00                            ; 8B92 A2 00                    ..
        stx     tmp14                           ; 8B94 86 14                    ..
L8B96:
        ldy     #$0A                            ; 8B96 A0 0A                    ..
L8B98:
        lda     $030A,x                         ; 8B98 BD 0A 03                 ...
        bne     L8BAB                           ; 8B9B D0 0E                    ..
        inx                                     ; 8B9D E8                       .
        dey                                     ; 8B9E 88                       .
        bne     L8B98                           ; 8B9F D0 F7                    ..
        inc     tmp14                           ; 8BA1 E6 14                    ..
        lda     tmp14                           ; 8BA3 A5 14                    ..
        cmp     #$14                            ; 8BA5 C9 14                    ..
        bcc     L8B96                           ; 8BA7 90 ED                    ..
        bcs     L8BD9                           ; 8BA9 B0 2E                    ..
L8BAB:
        lda     #$14                            ; 8BAB A9 14                    ..
        sec                                     ; 8BAD 38                       8
        sbc     $0597                           ; 8BAE ED 97 05                 ...
        cmp     tmp14                           ; 8BB1 C5 14                    ..
        .byte   $90                             ; 8BB3 90                       .
; ----------------------------------------------------------------------------
        .byte   $02                             ; 8BB4 02                       .
        lda     tmp14                           ; 8BB5 A5 14                    ..
        jsr     L8E93                           ; 8BB7 20 93 8E                  ..
        tax                                     ; 8BBA AA                       .
        lda     #$14                            ; 8BBB A9 14                    ..
        sec                                     ; 8BBD 38                       8
        sbc     $0597                           ; 8BBE ED 97 05                 ...
        cmp     #$14                            ; 8BC1 C9 14                    ..
        beq     L8BD9                           ; 8BC3 F0 14                    ..
        jsr     L8E93                           ; 8BC5 20 93 8E                  ..
        tay                                     ; 8BC8 A8                       .
L8BC9:
        lda     $030A,x                         ; 8BC9 BD 0A 03                 ...
        sta     $03D2,y                         ; 8BCC 99 D2 03                 ...
        inx                                     ; 8BCF E8                       .
        cpx     #$C8                            ; 8BD0 E0 C8                    ..
        bcs     L8BD9                           ; 8BD2 B0 05                    ..
        iny                                     ; 8BD4 C8                       .
        cpy     #$C8                            ; 8BD5 C0 C8                    ..
        bcc     L8BC9                           ; 8BD7 90 F0                    ..
L8BD9:
        jsr     L962E                           ; 8BD9 20 2E 96                  ..
        jsr     L8C72                           ; 8BDC 20 72 8C                  r.
        jsr     L8D5E                           ; 8BDF 20 5E 8D                  ^.
        lda     #$06                            ; 8BE2 A9 06                    ..
        jsr     L92DD                           ; 8BE4 20 DD 92                  ..
        inc     $0595                           ; 8BE7 EE 95 05                 ...
        ldx     #$C8                            ; 8BEA A2 C8                    ..
L8BEC:
        lda     $03D1,x                         ; 8BEC BD D1 03                 ...
        sta     $0309,x                         ; 8BEF 9D 09 03                 ...
        dex                                     ; 8BF2 CA                       .
        bne     L8BEC                           ; 8BF3 D0 F7                    ..
        lda     $0595                           ; 8BF5 AD 95 05                 ...
        cmp     #$0A                            ; 8BF8 C9 0A                    ..
        bcc     L8C18                           ; 8BFA 90 1C                    ..
        jsr     L8304                           ; 8BFC 20 04 83                  ..
        lda     #$00                            ; 8BFF A9 00                    ..
        sta     $0595                           ; 8C01 8D 95 05                 ...
        ldx     $0596                           ; 8C04 AE 96 05                 ...
        cpx     #$05                            ; 8C07 E0 05                    ..
        beq     L8C0C                           ; 8C09 F0 01                    ..
        inx                                     ; 8C0B E8                       .
L8C0C:
        stx     $0596                           ; 8C0C 8E 96 05                 ...
        ldy     L8914,x                         ; 8C0F BC 14 89                 ...
        sty     $0597                           ; 8C12 8C 97 05                 ...
        jsr     L8C74                           ; 8C15 20 74 8C                  t.
L8C18:
        ldx     #$FF                            ; 8C18 A2 FF                    ..
        txs                                     ; 8C1A 9A                       .
        jmp     L8428                           ; 8C1B 4C 28 84                 L(.

; ----------------------------------------------------------------------------
        rts                                     ; 8C1E 60                       `

; ----------------------------------------------------------------------------
L8C1F:
        ldx     #$00                            ; 8C1F A2 00                    ..
        lda     #$F0                            ; 8C21 A9 F0                    ..
L8C23:
        sta     oamStaging,x                    ; 8C23 9D 00 02                 ...
        inx                                     ; 8C26 E8                       .
        inx                                     ; 8C27 E8                       .
        inx                                     ; 8C28 E8                       .
        inx                                     ; 8C29 E8                       .
        cpx     #$10                            ; 8C2A E0 10                    ..
        bcc     L8C23                           ; 8C2C 90 F5                    ..
        rts                                     ; 8C2E 60                       `

; ----------------------------------------------------------------------------
L8C2F:
        pha                                     ; 8C2F 48                       H
        jsr     L8C3C                           ; 8C30 20 3C 8C                  <.
        tax                                     ; 8C33 AA                       .
        pla                                     ; 8C34 68                       h
        clc                                     ; 8C35 18                       .
        adc     #$32                            ; 8C36 69 32                    i2
        sta     $030A,x                         ; 8C38 9D 0A 03                 ...
        rts                                     ; 8C3B 60                       `

; ----------------------------------------------------------------------------
L8C3C:
        txa                                     ; 8C3C 8A                       .
        sec                                     ; 8C3D 38                       8
        sbc     #$0C                            ; 8C3E E9 0C                    ..
        sta     tmp15                           ; 8C40 85 15                    ..
        tya                                     ; 8C42 98                       .
        sec                                     ; 8C43 38                       8
        sbc     #$06                            ; 8C44 E9 06                    ..
        jsr     L8E93                           ; 8C46 20 93 8E                  ..
        adc     tmp15                           ; 8C49 65 15                    e.
        rts                                     ; 8C4B 60                       `

; ----------------------------------------------------------------------------
L8C4C:
        sta     tmp14                           ; 8C4C 85 14                    ..
        lda     #$00                            ; 8C4E A9 00                    ..
        sta     $2A                             ; 8C50 85 2A                    .*
        ldy     #$1A                            ; 8C52 A0 1A                    ..
L8C54:
        ldx     #$03                            ; 8C54 A2 03                    ..
L8C56:
        lda     tmp14                           ; 8C56 A5 14                    ..
        beq     L8C64                           ; 8C58 F0 0A                    ..
        txa                                     ; 8C5A 8A                       .
        clc                                     ; 8C5B 18                       .
        adc     #$3D                            ; 8C5C 69 3D                    i=
        cpy     #$1A                            ; 8C5E C0 1A                    ..
        beq     L8C64                           ; 8C60 F0 02                    ..
        adc     #$0F                            ; 8C62 69 0F                    i.
L8C64:
        jsr     L9323                           ; 8C64 20 23 93                  #.
        inx                                     ; 8C67 E8                       .
        cpx     #$09                            ; 8C68 E0 09                    ..
        bcc     L8C56                           ; 8C6A 90 EA                    ..
        iny                                     ; 8C6C C8                       .
        cpy     #$1C                            ; 8C6D C0 1C                    ..
        bcc     L8C54                           ; 8C6F 90 E3                    ..
        rts                                     ; 8C71 60                       `

; ----------------------------------------------------------------------------
L8C72:
        ldy     #$00                            ; 8C72 A0 00                    ..
L8C74:
        lda     #$00                            ; 8C74 A9 00                    ..
        ldx     #$C8                            ; 8C76 A2 C8                    ..
L8C78:
        sta     $0309,x                         ; 8C78 9D 09 03                 ...
        dex                                     ; 8C7B CA                       .
        bne     L8C78                           ; 8C7C D0 FA                    ..
        tya                                     ; 8C7E 98                       .
        beq     L8CC7                           ; 8C7F F0 46                    .F
        jsr     L8E93                           ; 8C81 20 93 8E                  ..
        tay                                     ; 8C84 A8                       .
        ldx     #$C8                            ; 8C85 A2 C8                    ..
L8C87:
        lda     #$0A                            ; 8C87 A9 0A                    ..
        sta     tmp14                           ; 8C89 85 14                    ..
        lda     rngSeed+5                       ; 8C8B A5 5B                    .[
        and     #$03                            ; 8C8D 29 03                    ).
        sta     tmp15                           ; 8C8F 85 15                    ..
        lda     rngSeed+6                       ; 8C91 A5 5C                    .\
        and     #$03                            ; 8C93 29 03                    ).
        clc                                     ; 8C95 18                       .
        adc     tmp15                           ; 8C96 65 15                    e.
        adc     #$02                            ; 8C98 69 02                    i.
        sta     tmp15                           ; 8C9A 85 15                    ..
L8C9C:
        lda     tmp15                           ; 8C9C A5 15                    ..
        beq     L8CBD                           ; 8C9E F0 1D                    ..
        cmp     tmp14                           ; 8CA0 C5 14                    ..
        bcs     L8CAB                           ; 8CA2 B0 07                    ..
        jsr     L9092                           ; 8CA4 20 92 90                  ..
        lda     rngSeed                         ; 8CA7 A5 56                    .V
        bmi     L8CBD                           ; 8CA9 30 12                    0.
L8CAB:
        jsr     L9092                           ; 8CAB 20 92 90                  ..
        lda     rngSeed+2                       ; 8CAE A5 58                    .X
        and     #$07                            ; 8CB0 29 07                    ).
        cmp     #$06                            ; 8CB2 C9 06                    ..
        bcs     L8CAB                           ; 8CB4 B0 F5                    ..
        adc     #$33                            ; 8CB6 69 33                    i3
        sta     $0309,x                         ; 8CB8 9D 09 03                 ...
        dec     tmp15                           ; 8CBB C6 15                    ..
L8CBD:
        dex                                     ; 8CBD CA                       .
        dey                                     ; 8CBE 88                       .
        beq     L8CC7                           ; 8CBF F0 06                    ..
        dec     tmp14                           ; 8CC1 C6 14                    ..
        beq     L8C87                           ; 8CC3 F0 C2                    ..
        bne     L8C9C                           ; 8CC5 D0 D5                    ..
L8CC7:
        rts                                     ; 8CC7 60                       `

; ----------------------------------------------------------------------------
L8CC8:
        jsr     L8CE7                           ; 8CC8 20 E7 8C                  ..
        dec     $0574                           ; 8CCB CE 74 05                 .t.
        lda     $0586                           ; 8CCE AD 86 05                 ...
        sta     $0573                           ; 8CD1 8D 73 05                 .s.
        jsr     L8E9C                           ; 8CD4 20 9C 8E                  ..
        ldy     $0585                           ; 8CD7 AC 85 05                 ...
        sty     $0571                           ; 8CDA 8C 71 05                 .q.
        ldx     $0584                           ; 8CDD AE 84 05                 ...
        stx     $0570                           ; 8CE0 8E 70 05                 .p.
        jsr     L8D36                           ; 8CE3 20 36 8D                  6.
        rts                                     ; 8CE6 60                       `

; ----------------------------------------------------------------------------
L8CE7:
        lda     #$00                            ; 8CE7 A9 00                    ..
        sta     $0574                           ; 8CE9 8D 74 05                 .t.
        jsr     L8E9C                           ; 8CEC 20 9C 8E                  ..
        ldx     $0570                           ; 8CEF AE 70 05                 .p.
        ldy     $0571                           ; 8CF2 AC 71 05                 .q.
        jsr     L8D36                           ; 8CF5 20 36 8D                  6.
        rts                                     ; 8CF8 60                       `

; ----------------------------------------------------------------------------
L8CF9:
        lda     ($43),y                         ; 8CF9 B1 43                    .C
        bne     L8CFE                           ; 8CFB D0 01                    ..
        rts                                     ; 8CFD 60                       `

; ----------------------------------------------------------------------------
L8CFE:
        and     $0574                           ; 8CFE 2D 74 05                 -t.
        bne     L8D0E                           ; 8D01 D0 0B                    ..
        lda     #$F0                            ; 8D03 A9 F0                    ..
        sta     oamStaging,x                    ; 8D05 9D 00 02                 ...
        sta     oamStaging+3,x                  ; 8D08 9D 03 02                 ...
        jmp     L8D31                           ; 8D0B 4C 31 8D                 L1.

; ----------------------------------------------------------------------------
L8D0E:
        clc                                     ; 8D0E 18                       .
        adc     #$32                            ; 8D0F 69 32                    i2
        sta     oamStaging+1,x                  ; 8D11 9D 01 02                 ...
        tya                                     ; 8D14 98                       .
        and     #$03                            ; 8D15 29 03                    ).
        clc                                     ; 8D17 18                       .
        adc     $0570                           ; 8D18 6D 70 05                 mp.
        asl     a                               ; 8D1B 0A                       .
        asl     a                               ; 8D1C 0A                       .
        asl     a                               ; 8D1D 0A                       .
        sta     oamStaging+3,x                  ; 8D1E 9D 03 02                 ...
        tya                                     ; 8D21 98                       .
        lsr     a                               ; 8D22 4A                       J
        lsr     a                               ; 8D23 4A                       J
        clc                                     ; 8D24 18                       .
        adc     $0571                           ; 8D25 6D 71 05                 mq.
        asl     a                               ; 8D28 0A                       .
        asl     a                               ; 8D29 0A                       .
        asl     a                               ; 8D2A 0A                       .
        sta     oamStaging,x                    ; 8D2B 9D 00 02                 ...
        dec     oamStaging,x                    ; 8D2E DE 00 02                 ...
L8D31:
        inx                                     ; 8D31 E8                       .
        inx                                     ; 8D32 E8                       .
        inx                                     ; 8D33 E8                       .
        inx                                     ; 8D34 E8                       .
        rts                                     ; 8D35 60                       `

; ----------------------------------------------------------------------------
L8D36:
        stx     $0570                           ; 8D36 8E 70 05                 .p.
        sty     $0571                           ; 8D39 8C 71 05                 .q.
        ldx     #$20                            ; 8D3C A2 20                    . 
        ldy     #$00                            ; 8D3E A0 00                    ..
L8D40:
        jsr     L8CF9                           ; 8D40 20 F9 8C                  ..
        iny                                     ; 8D43 C8                       .
        cpy     #$10                            ; 8D44 C0 10                    ..
        bcc     L8D40                           ; 8D46 90 F8                    ..
        rts                                     ; 8D48 60                       `

; ----------------------------------------------------------------------------
L8D49:
        lda     $0577                           ; 8D49 AD 77 05                 .w.
        asl     a                               ; 8D4C 0A                       .
        asl     a                               ; 8D4D 0A                       .
        asl     a                               ; 8D4E 0A                       .
        ora     $0578                           ; 8D4F 0D 78 05                 .x.
        tax                                     ; 8D52 AA                       .
        lda     LFEC0,x                         ; 8D53 BD C0 FE                 ...
        sta     $43                             ; 8D56 85 43                    .C
        lda     LFEC1,x                         ; 8D58 BD C1 FE                 ...
        sta     $44                             ; 8D5B 85 44                    .D
        rts                                     ; 8D5D 60                       `

; ----------------------------------------------------------------------------
L8D5E:
        inc     $42                             ; 8D5E E6 42                    .B
        jsr     L9059                           ; 8D60 20 59 90                  Y.
        lda     #$00                            ; 8D63 A9 00                    ..
        sta     jmp1E                           ; 8D65 85 1E                    ..
        lda     #$F8                            ; 8D67 A9 F8                    ..
        sta     jmp1E+1                         ; 8D69 85 1F                    ..
        lda     #$04                            ; 8D6B A9 04                    ..
        sta     $35                             ; 8D6D 85 35                    .5
L8D6F:
        lda     $35                             ; 8D6F A5 35                    .5
        bne     L8D6F                           ; 8D71 D0 FC                    ..
        rts                                     ; 8D73 60                       `

; ----------------------------------------------------------------------------
L8D74:
        ldy     #$FF                            ; 8D74 A0 FF                    ..
        sty     $059A                           ; 8D76 8C 9A 05                 ...
        sty     $059B                           ; 8D79 8C 9B 05                 ...
        sty     $059C                           ; 8D7C 8C 9C 05                 ...
        sty     $059D                           ; 8D7F 8C 9D 05                 ...
        iny                                     ; 8D82 C8                       .
        sty     $1C                             ; 8D83 84 1C                    ..
L8D85:
        sty     $0571                           ; 8D85 8C 71 05                 .q.
        tya                                     ; 8D88 98                       .
        jsr     L8E93                           ; 8D89 20 93 8E                  ..
        tax                                     ; 8D8C AA                       .
        lda     #$0A                            ; 8D8D A9 0A                    ..
        sta     $1D                             ; 8D8F 85 1D                    ..
L8D91:
        lda     $030A,x                         ; 8D91 BD 0A 03                 ...
        beq     L8DA5                           ; 8D94 F0 0F                    ..
        inx                                     ; 8D96 E8                       .
        dec     $1D                             ; 8D97 C6 1D                    ..
        bne     L8D91                           ; 8D99 D0 F6                    ..
        lda     $0571                           ; 8D9B AD 71 05                 .q.
        ldx     $1C                             ; 8D9E A6 1C                    ..
        sta     $059A,x                         ; 8DA0 9D 9A 05                 ...
        inc     $1C                             ; 8DA3 E6 1C                    ..
L8DA5:
        ldy     $0571                           ; 8DA5 AC 71 05                 .q.
        iny                                     ; 8DA8 C8                       .
        cpy     #$14                            ; 8DA9 C0 14                    ..
        bcc     L8D85                           ; 8DAB 90 D8                    ..
        ldx     $1C                             ; 8DAD A6 1C                    ..
        beq     L8DBD                           ; 8DAF F0 0C                    ..
        txa                                     ; 8DB1 8A                       .
        dex                                     ; 8DB2 CA                       .
        inc     $057A,x                         ; 8DB3 FE 7A 05                 .z.
        clc                                     ; 8DB6 18                       .
        adc     $057F                           ; 8DB7 6D 7F 05                 m..
        sta     $057F                           ; 8DBA 8D 7F 05                 ...
L8DBD:
        rts                                     ; 8DBD 60                       `

; ----------------------------------------------------------------------------
L8DBE:
        lda     $059A                           ; 8DBE AD 9A 05                 ...
        bmi     L8E22                           ; 8DC1 30 5F                    0_
        lda     #$00                            ; 8DC3 A9 00                    ..
L8DC5:
        sta     $1C                             ; 8DC5 85 1C                    ..
        jsr     L8E93                           ; 8DC7 20 93 8E                  ..
        tax                                     ; 8DCA AA                       .
        ldy     $1C                             ; 8DCB A4 1C                    ..
        lda     $059A,y                         ; 8DCD B9 9A 05                 ...
        bmi     L8DEF                           ; 8DD0 30 1D                    0.
        jsr     L8E93                           ; 8DD2 20 93 8E                  ..
        tay                                     ; 8DD5 A8                       .
        lda     #$0A                            ; 8DD6 A9 0A                    ..
        sta     $1D                             ; 8DD8 85 1D                    ..
L8DDA:
        lda     $030A,y                         ; 8DDA B9 0A 03                 ...
        sta     $03D2,x                         ; 8DDD 9D D2 03                 ...
        inx                                     ; 8DE0 E8                       .
        iny                                     ; 8DE1 C8                       .
        dec     $1D                             ; 8DE2 C6 1D                    ..
        bne     L8DDA                           ; 8DE4 D0 F4                    ..
        lda     $1C                             ; 8DE6 A5 1C                    ..
        clc                                     ; 8DE8 18                       .
        adc     #$01                            ; 8DE9 69 01                    i.
        cmp     #$04                            ; 8DEB C9 04                    ..
        bcc     L8DC5                           ; 8DED 90 D6                    ..
L8DEF:
        lda     #$00                            ; 8DEF A9 00                    ..
        jsr     L8E23                           ; 8DF1 20 23 8E                  #.
        lda     #$FF                            ; 8DF4 A9 FF                    ..
        jsr     L8E23                           ; 8DF6 20 23 8E                  #.
        lda     #$00                            ; 8DF9 A9 00                    ..
        jsr     L8E23                           ; 8DFB 20 23 8E                  #.
        lda     #$FF                            ; 8DFE A9 FF                    ..
        jsr     L8E23                           ; 8E00 20 23 8E                  #.
        ldy     #$00                            ; 8E03 A0 00                    ..
L8E05:
        lda     $059A,y                         ; 8E05 B9 9A 05                 ...
        bmi     L8E22                           ; 8E08 30 18                    0.
        jsr     L8E93                           ; 8E0A 20 93 8E                  ..
        clc                                     ; 8E0D 18                       .
        adc     #$09                            ; 8E0E 69 09                    i.
        tax                                     ; 8E10 AA                       .
L8E11:
        lda     $0300,x                         ; 8E11 BD 00 03                 ...
        sta     $030A,x                         ; 8E14 9D 0A 03                 ...
        dex                                     ; 8E17 CA                       .
        bne     L8E11                           ; 8E18 D0 F7                    ..
        stx     $030A                           ; 8E1A 8E 0A 03                 ...
        iny                                     ; 8E1D C8                       .
        cpy     #$04                            ; 8E1E C0 04                    ..
        bcc     L8E05                           ; 8E20 90 E3                    ..
L8E22:
        rts                                     ; 8E22 60                       `

; ----------------------------------------------------------------------------
L8E23:
        sta     tmp15                           ; 8E23 85 15                    ..
        ldx     #$00                            ; 8E25 A2 00                    ..
L8E27:
        stx     $1C                             ; 8E27 86 1C                    ..
        lda     $059A,x                         ; 8E29 BD 9A 05                 ...
        bmi     L8E54                           ; 8E2C 30 26                    0&
        jsr     L8E93                           ; 8E2E 20 93 8E                  ..
        tay                                     ; 8E31 A8                       .
        txa                                     ; 8E32 8A                       .
        jsr     L8E93                           ; 8E33 20 93 8E                  ..
        tax                                     ; 8E36 AA                       .
        lda     #$0A                            ; 8E37 A9 0A                    ..
        sta     $1D                             ; 8E39 85 1D                    ..
L8E3B:
        lda     $03D2,x                         ; 8E3B BD D2 03                 ...
        and     tmp15                           ; 8E3E 25 15                    %.
        bne     L8E44                           ; 8E40 D0 02                    ..
        lda     #$31                            ; 8E42 A9 31                    .1
L8E44:
        sta     $030A,y                         ; 8E44 99 0A 03                 ...
        inx                                     ; 8E47 E8                       .
        iny                                     ; 8E48 C8                       .
        dec     $1D                             ; 8E49 C6 1D                    ..
        bne     L8E3B                           ; 8E4B D0 EE                    ..
        ldx     $1C                             ; 8E4D A6 1C                    ..
        inx                                     ; 8E4F E8                       .
        cpx     #$04                            ; 8E50 E0 04                    ..
        bcc     L8E27                           ; 8E52 90 D3                    ..
L8E54:
        ldx     #$10                            ; 8E54 A2 10                    ..
        jsr     L93C6                           ; 8E56 20 C6 93                  ..
        jsr     L8D5E                           ; 8E59 20 5E 8D                  ^.
        ldy     #$07                            ; 8E5C A0 07                    ..
        jsr     L902E                           ; 8E5E 20 2E 90                  ..
        rts                                     ; 8E61 60                       `

; ----------------------------------------------------------------------------
L8E62:
        lda     #$03                            ; 8E62 A9 03                    ..
        sta     $2A                             ; 8E64 85 2A                    .*
        lda     $057F                           ; 8E66 AD 7F 05                 ...
        sec                                     ; 8E69 38                       8
        sbc     $0580                           ; 8E6A ED 80 05                 ...
        bcc     L8E71                           ; 8E6D 90 02                    ..
        lda     #$00                            ; 8E6F A9 00                    ..
L8E71:
        jsr     L908C                           ; 8E71 20 8C 90                  ..
        ldx     #$07                            ; 8E74 A2 07                    ..
        ldy     #$0A                            ; 8E76 A0 0A                    ..
        jmp     L96CC                           ; 8E78 4C CC 96                 L..

; ----------------------------------------------------------------------------
L8E7B:
        lda     #$03                            ; 8E7B A9 03                    ..
        sta     $2A                             ; 8E7D 85 2A                    .*
        ldx     #$07                            ; 8E7F A2 07                    ..
        ldy     #$08                            ; 8E81 A0 08                    ..
        lda     $0595                           ; 8E83 AD 95 05                 ...
        jsr     L96CC                           ; 8E86 20 CC 96                  ..
        ldx     #$07                            ; 8E89 A2 07                    ..
        ldy     #$06                            ; 8E8B A0 06                    ..
        lda     $0596                           ; 8E8D AD 96 05                 ...
        jmp     L96CC                           ; 8E90 4C CC 96                 L..

; ----------------------------------------------------------------------------
L8E93:
        asl     a                               ; 8E93 0A                       .
        sta     tmp14                           ; 8E94 85 14                    ..
        asl     a                               ; 8E96 0A                       .
        asl     a                               ; 8E97 0A                       .
        clc                                     ; 8E98 18                       .
        adc     tmp14                           ; 8E99 65 14                    e.
        rts                                     ; 8E9B 60                       `

; ----------------------------------------------------------------------------
L8E9C:
        lda     $0572                           ; 8E9C AD 72 05                 .r.
        asl     a                               ; 8E9F 0A                       .
        asl     a                               ; 8EA0 0A                       .
        asl     a                               ; 8EA1 0A                       .
        ora     $0573                           ; 8EA2 0D 73 05                 .s.
        tax                                     ; 8EA5 AA                       .
        lda     LFEC0,x                         ; 8EA6 BD C0 FE                 ...
        sta     $43                             ; 8EA9 85 43                    .C
        lda     LFEC1,x                         ; 8EAB BD C1 FE                 ...
        sta     $44                             ; 8EAE 85 44                    .D
        rts                                     ; 8EB0 60                       `

; ----------------------------------------------------------------------------
L8EB1:
        lda     #$FF                            ; 8EB1 A9 FF                    ..
        sta     $0574                           ; 8EB3 8D 74 05                 .t.
        lda     $0578                           ; 8EB6 AD 78 05                 .x.
        sta     $0573                           ; 8EB9 8D 73 05                 .s.
        lda     $0577                           ; 8EBC AD 77 05                 .w.
        sta     $0572                           ; 8EBF 8D 72 05                 .r.
        jsr     L8E9C                           ; 8EC2 20 9C 8E                  ..
        ldx     #$0F                            ; 8EC5 A2 0F                    ..
        stx     $0570                           ; 8EC7 8E 70 05                 .p.
        stx     $0584                           ; 8ECA 8E 84 05                 ...
        ldy     #$06                            ; 8ECD A0 06                    ..
        sty     $0571                           ; 8ECF 8C 71 05                 .q.
        sty     $0585                           ; 8ED2 8C 85 05                 ...
        jsr     L8D36                           ; 8ED5 20 36 8D                  6.
        jsr     L8AB4                           ; 8ED8 20 B4 8A                  ..
        jsr     L8EE4                           ; 8EDB 20 E4 8E                  ..
        ldy     #$0A                            ; 8EDE A0 0A                    ..
        jsr     L902E                           ; 8EE0 20 2E 90                  ..
        rts                                     ; 8EE3 60                       `

; ----------------------------------------------------------------------------
L8EE4:
        jsr     L9092                           ; 8EE4 20 92 90                  ..
        lda     rngSeed+3                       ; 8EE7 A5 59                    .Y
        and     #$07                            ; 8EE9 29 07                    ).
        eor     $0577                           ; 8EEB 4D 77 05                 Mw.
        beq     L8EE4                           ; 8EEE F0 F4                    ..
        sta     $0577                           ; 8EF0 8D 77 05                 .w.
        dec     $0577                           ; 8EF3 CE 77 05                 .w.
        lda     rngSeed+1                       ; 8EF6 A5 57                    .W
        and     #$06                            ; 8EF8 29 06                    ).
        sta     $0578                           ; 8EFA 8D 78 05                 .x.
L8EFD:
        jsr     L8D49                           ; 8EFD 20 49 8D                  I.
        ldx     #$00                            ; 8F00 A2 00                    ..
        ldy     #$0F                            ; 8F02 A0 0F                    ..
L8F04:
        jsr     L8F10                           ; 8F04 20 10 8F                  ..
        dey                                     ; 8F07 88                       .
        bpl     L8F04                           ; 8F08 10 FA                    ..
        inc     $42                             ; 8F0A E6 42                    .B
        jsr     L9059                           ; 8F0C 20 59 90                  Y.
        rts                                     ; 8F0F 60                       `

; ----------------------------------------------------------------------------
L8F10:
        lda     ($43),y                         ; 8F10 B1 43                    .C
        bne     L8F15                           ; 8F12 D0 01                    ..
        rts                                     ; 8F14 60                       `

; ----------------------------------------------------------------------------
L8F15:
        and     $0579                           ; 8F15 2D 79 05                 -y.
        bne     L8F25                           ; 8F18 D0 0B                    ..
        lda     #$F0                            ; 8F1A A9 F0                    ..
        sta     oamStaging,x                    ; 8F1C 9D 00 02                 ...
        sta     oamStaging+3,x                  ; 8F1F 9D 03 02                 ...
        jmp     L8F44                           ; 8F22 4C 44 8F                 LD.

; ----------------------------------------------------------------------------
L8F25:
        clc                                     ; 8F25 18                       .
        adc     #$32                            ; 8F26 69 32                    i2
        sta     oamStaging+1,x                  ; 8F28 9D 01 02                 ...
        tya                                     ; 8F2B 98                       .
        and     #$03                            ; 8F2C 29 03                    ).
        asl     a                               ; 8F2E 0A                       .
        asl     a                               ; 8F2F 0A                       .
        asl     a                               ; 8F30 0A                       .
        adc     #$C9                            ; 8F31 69 C9                    i.
        sta     oamStaging+3,x                  ; 8F33 9D 03 02                 ...
        tya                                     ; 8F36 98                       .
        and     #$0C                            ; 8F37 29 0C                    ).
        asl     a                               ; 8F39 0A                       .
        adc     #$98                            ; 8F3A 69 98                    i.
        sta     oamStaging,x                    ; 8F3C 9D 00 02                 ...
        lda     #$00                            ; 8F3F A9 00                    ..
        sta     oamStaging+2,x                  ; 8F41 9D 02 02                 ...
L8F44:
        inx                                     ; 8F44 E8                       .
        inx                                     ; 8F45 E8                       .
        inx                                     ; 8F46 E8                       .
        inx                                     ; 8F47 E8                       .
        rts                                     ; 8F48 60                       `

; ----------------------------------------------------------------------------
L8F49:
        ldx     #$00                            ; 8F49 A2 00                    ..
        ldy     #$00                            ; 8F4B A0 00                    ..
        lda     #$1F                            ; 8F4D A9 1F                    ..
L8F4F:
        cpy     $059E                           ; 8F4F CC 9E 05                 ...
        bcc     L8F56                           ; 8F52 90 02                    ..
        lda     #$F0                            ; 8F54 A9 F0                    ..
L8F56:
        sta     oamStaging+16,x                 ; 8F56 9D 10 02                 ...
        inx                                     ; 8F59 E8                       .
        inx                                     ; 8F5A E8                       .
        inx                                     ; 8F5B E8                       .
        inx                                     ; 8F5C E8                       .
        iny                                     ; 8F5D C8                       .
        cpy     #$03                            ; 8F5E C0 03                    ..
        bcc     L8F4F                           ; 8F60 90 ED                    ..
        inc     $42                             ; 8F62 E6 42                    .B
        jsr     L9059                           ; 8F64 20 59 90                  Y.
        rts                                     ; 8F67 60                       `

; ----------------------------------------------------------------------------
L8F68:
        .byte   $02                             ; 8F68 02                       .
L8F69:
        .byte   $80                             ; 8F69 80                       .
        .byte   $FF                             ; 8F6A FF                       .
        .byte   $BF                             ; 8F6B BF                       .
        brk                                     ; 8F6C 00                       .
        cpy     #$F9                            ; 8F6D C0 F9                    ..
        .byte   $FF                             ; 8F6F FF                       .
setCNROMBank0:
        lda     LC003                           ; 8F70 AD 03 C0                 ...
        beq     maybeUnusedCode                 ; 8F73 F0 06                    ..
        lda     #$00                            ; 8F75 A9 00                    ..
        sta     cnromBank                       ; 8F77 8D 01 C0                 ...
        rts                                     ; 8F7A 60                       `

; ----------------------------------------------------------------------------
; the branch above reads $01 From rom and only branches here on $00
maybeUnusedCode:
        lda     #$02                            ; 8F7B A9 02                    ..
        ldy     #$00                            ; 8F7D A0 00                    ..
        jsr     L8F97                           ; 8F7F 20 97 8F                  ..
        lda     #$00                            ; 8F82 A9 00                    ..
        ldy     #$02                            ; 8F84 A0 02                    ..
        jsr     L8F97                           ; 8F86 20 97 8F                  ..
        lda     #$00                            ; 8F89 A9 00                    ..
        ldy     #$04                            ; 8F8B A0 04                    ..
        jsr     L8F97                           ; 8F8D 20 97 8F                  ..
        lda     #$00                            ; 8F90 A9 00                    ..
        ldy     #$06                            ; 8F92 A0 06                    ..
        jmp     L8F97                           ; 8F94 4C 97 8F                 L..

; ----------------------------------------------------------------------------
L8F97:
        ldx     LC003                           ; 8F97 AE 03 C0                 ...
        beq     L8FA2                           ; 8F9A F0 06                    ..
        lsr     a                               ; 8F9C 4A                       J
        tax                                     ; 8F9D AA                       .
        sta     cnromBank,x                     ; 8F9E 9D 01 C0                 ...
        rts                                     ; 8FA1 60                       `

; ----------------------------------------------------------------------------
L8FA2:
        ldx     #$00                            ; 8FA2 A2 00                    ..
        tax                                     ; 8FA4 AA                       .
        lda     L8F68,y                         ; 8FA5 B9 68 8F                 .h.
        sta     $24                             ; 8FA8 85 24                    .$
        lda     L8F69,y                         ; 8FAA B9 69 8F                 .i.
        sta     $25                             ; 8FAD 85 25                    .%
        txa                                     ; 8FAF 8A                       .
        ldy     #$00                            ; 8FB0 A0 00                    ..
        ldx     #$05                            ; 8FB2 A2 05                    ..
L8FB4:
        sta     ($24),y                         ; 8FB4 91 24                    .$
        lsr     a                               ; 8FB6 4A                       J
        dex                                     ; 8FB7 CA                       .
        bne     L8FB4                           ; 8FB8 D0 FA                    ..
        rts                                     ; 8FBA 60                       `

; ----------------------------------------------------------------------------
L8FBB:
        sty     $3F                             ; 8FBB 84 3F                    .?
        jsr     L8A83                           ; 8FBD 20 83 8A                  ..
L8FC0:
        lda     $3F                             ; 8FC0 A5 3F                    .?
        beq     L8FCA                           ; 8FC2 F0 06                    ..
        jsr     L8FCE                           ; 8FC4 20 CE 8F                  ..
        txa                                     ; 8FC7 8A                       .
        beq     L8FC0                           ; 8FC8 F0 F6                    ..
L8FCA:
        sta     $0598                           ; 8FCA 8D 98 05                 ...
        rts                                     ; 8FCD 60                       `

; ----------------------------------------------------------------------------
L8FCE:
        lda     $2F                             ; 8FCE A5 2F                    ./
        beq     L8FD6                           ; 8FD0 F0 04                    ..
        lda     #$00                            ; 8FD2 A9 00                    ..
        tax                                     ; 8FD4 AA                       .
        rts                                     ; 8FD5 60                       `

; ----------------------------------------------------------------------------
L8FD6:
        inc     $2F                             ; 8FD6 E6 2F                    ./
        lda     #$01                            ; 8FD8 A9 01                    ..
        sta     JOY1                            ; 8FDA 8D 16 40                 ..@
        lda     #$00                            ; 8FDD A9 00                    ..
        sta     JOY1                            ; 8FDF 8D 16 40                 ..@
        ldx     #$08                            ; 8FE2 A2 08                    ..
L8FE4:
        lda     JOY1                            ; 8FE4 AD 16 40                 ..@
        and     #$03                            ; 8FE7 29 03                    ).
        cmp     #$01                            ; 8FE9 C9 01                    ..
        ror     controllerInput                 ; 8FEB 66 30                    f0
        dex                                     ; 8FED CA                       .
        bne     L8FE4                           ; 8FEE D0 F4                    ..
        jsr     L9092                           ; 8FF0 20 92 90                  ..
        dec     $2F                             ; 8FF3 C6 2F                    ./
        ldx     controllerInput                 ; 8FF5 A6 30                    .0
        rts                                     ; 8FF7 60                       `

; ----------------------------------------------------------------------------
blankOutNametables:
        ldy     #$10                            ; 8FF8 A0 10                    ..
        lda     #$20                            ; 8FFA A9 20                    . 
        sta     PPUADDR                         ; 8FFC 8D 06 20                 .. 
        lda     #$00                            ; 8FFF A9 00                    ..
        sta     PPUADDR                         ; 9001 8D 06 20                 .. 
        ldx     #$00                            ; 9004 A2 00                    ..
@blankLoop:
        sta     PPUDATA                         ; 9006 8D 07 20                 .. 
        dex                                     ; 9009 CA                       .
        bne     @blankLoop                      ; 900A D0 FA                    ..
        dey                                     ; 900C 88                       .
        bne     @blankLoop                      ; 900D D0 F7                    ..
        stx     PPUSCROLL                       ; 900F 8E 05 20                 .. 
        stx     PPUSCROLL                       ; 9012 8E 05 20                 .. 
        rts                                     ; 9015 60                       `

; ----------------------------------------------------------------------------
initRam:
        ldx     #$02                            ; 9016 A2 02                    ..
@nextPage:
        jsr     @initPage                       ; 9018 20 21 90                  !.
        inx                                     ; 901B E8                       .
        cpx     #$08                            ; 901C E0 08                    ..
        bcc     @nextPage                       ; 901E 90 F8                    ..
        rts                                     ; 9020 60                       `

; ----------------------------------------------------------------------------
@initPage:
        stx     tmp13                           ; 9021 86 13                    ..
        ldy     #$00                            ; 9023 A0 00                    ..
        tya                                     ; 9025 98                       .
        sty     tmp12                           ; 9026 84 12                    ..
@nextByte:
        sta     (tmp12),y                       ; 9028 91 12                    ..
        iny                                     ; 902A C8                       .
        bne     @nextByte                       ; 902B D0 FB                    ..
        rts                                     ; 902D 60                       `

; ----------------------------------------------------------------------------
L902E:
        tya                                     ; 902E 98                       .
        lsr     a                               ; 902F 4A                       J
        sta     tmp14                           ; 9030 85 14                    ..
        lda     $3F                             ; 9032 A5 3F                    .?
        sec                                     ; 9034 38                       8
        sbc     tmp14                           ; 9035 E5 14                    ..
        bcs     L903B                           ; 9037 B0 02                    ..
        lda     #$00                            ; 9039 A9 00                    ..
L903B:
        pha                                     ; 903B 48                       H
        sty     $3F                             ; 903C 84 3F                    .?
        ldy     #$01                            ; 903E A0 01                    ..
        jsr     L9047                           ; 9040 20 47 90                  G.
        pla                                     ; 9043 68                       h
        sta     $3F                             ; 9044 85 3F                    .?
        rts                                     ; 9046 60                       `

; ----------------------------------------------------------------------------
L9047:
        pha                                     ; 9047 48                       H
L9048:
        lda     $3E,y                           ; 9048 B9 3E 00                 .>.
        bne     L9048                           ; 904B D0 FB                    ..
        pla                                     ; 904D 68                       h
        rts                                     ; 904E 60                       `

; ----------------------------------------------------------------------------
L904F:
        ldy     #$00                            ; 904F A0 00                    ..
        jmp     L9047                           ; 9051 4C 47 90                 LG.

; ----------------------------------------------------------------------------
L9054:
        ldy     #$03                            ; 9054 A0 03                    ..
        jmp     L9047                           ; 9056 4C 47 90                 LG.

; ----------------------------------------------------------------------------
L9059:
        pha                                     ; 9059 48                       H
        tya                                     ; 905A 98                       .
        pha                                     ; 905B 48                       H
        txa                                     ; 905C 8A                       .
        pha                                     ; 905D 48                       H
        ldy     #$04                            ; 905E A0 04                    ..
        jsr     L9047                           ; 9060 20 47 90                  G.
        pla                                     ; 9063 68                       h
        tax                                     ; 9064 AA                       .
        pla                                     ; 9065 68                       h
        tay                                     ; 9066 A8                       .
        pla                                     ; 9067 68                       h
        rts                                     ; 9068 60                       `

; ----------------------------------------------------------------------------
        ldx     #$00                            ; 9069 A2 00                    ..
        stx     $47                             ; 906B 86 47                    .G
        stx     $48                             ; 906D 86 48                    .H
        stx     $49                             ; 906F 86 49                    .I
        lsr     $45                             ; 9071 46 45                    FE
        .byte   $90,$0D,$A5,$48,$18,$65,$46,$85 ; 9073 90 0D A5 48 18 65 46 85  ...H.eF.
        .byte   $48,$A5,$49,$65,$47,$85,$49,$06 ; 907B 48 A5 49 65 47 85 49 06  H.IeG.I.
        .byte   $46,$26,$47,$E8,$E0,$08,$90,$E6 ; 9083 46 26 47 E8 E0 08 90 E6  F&G.....
        .byte   $60                             ; 908B 60                       `
L908C:
        .byte   $49,$FF,$18,$69,$01,$60         ; 908C 49 FF 18 69 01 60        I..i.`
L9092:
        .byte   $08,$48,$8A                     ; 9092 08 48 8A                 .H.
; ----------------------------------------------------------------------------
        pha                                     ; 9095 48                       H
        tya                                     ; 9096 98                       .
        pha                                     ; 9097 48                       H
        lda     tmp14                           ; 9098 A5 14                    ..
        eor     $5E                             ; 909A 45 5E                    E^
        sta     $5E                             ; 909C 85 5E                    .^
        ldx     #$00                            ; 909E A2 00                    ..
        ldy     #$08                            ; 90A0 A0 08                    ..
L90A2:
        lda     rngSeed+1,x                     ; 90A2 B5 57                    .W
        adc     $5E                             ; 90A4 65 5E                    e^
        sta     $5E                             ; 90A6 85 5E                    .^
        and     #$01                            ; 90A8 29 01                    ).
        cmp     #$01                            ; 90AA C9 01                    ..
        ror     rngSeed,x                       ; 90AC 76 56                    vV
        inx                                     ; 90AE E8                       .
        dey                                     ; 90AF 88                       .
        bne     L90A2                           ; 90B0 D0 F0                    ..
        pla                                     ; 90B2 68                       h
        tay                                     ; 90B3 A8                       .
        pla                                     ; 90B4 68                       h
        tax                                     ; 90B5 AA                       .
        pla                                     ; 90B6 68                       h
        plp                                     ; 90B7 28                       (
        rts                                     ; 90B8 60                       `

; ----------------------------------------------------------------------------
L90B9:
        .byte   $7B                             ; 90B9 7B                       {
L90BA:
        .byte   $97                             ; 90BA 97                       .
        .byte   $63                             ; 90BB 63                       c
        lda     $63                             ; 90BC A5 63                    .c
        lda     #$1F                            ; 90BE A9 1F                    ..
        ldy     jmp1E+1,x                       ; 90C0 B4 1F                    ..
        .byte   $B0,$1F,$B8,$63,$A1,$63,$9D,$63 ; 90C2 B0 1F B8 63 A1 63 9D 63  ...c.c.c
        .byte   $9D,$1F,$B8,$1F,$B0             ; 90CA 9D 1F B8 1F B0           .....
L90CF:
        .byte   $86                             ; 90CF 86                       .
L90D0:
        .byte   $9C,$97,$92,$87,$92,$77,$92,$07 ; 90D0 9C 97 92 87 92 77 92 07  .....w..
        .byte   $92,$67,$92,$47,$92,$67,$92,$97 ; 90D8 92 67 92 47 92 67 92 97  .g.G.g..
        .byte   $92,$97,$92,$17,$92             ; 90E0 92 97 92 17 92           .....
L90E5:
        .byte   $00,$00,$02,$00,$00,$00,$02,$00 ; 90E5 00 00 02 00 00 00 02 00  ........
        .byte   $00,$00                         ; 90ED 00 00                    ..
L90EF:
        .byte   $00,$00,$00,$00,$00,$00,$18,$00 ; 90EF 00 00 00 00 00 00 18 00  ........
        .byte   $00,$00                         ; 90F7 00 00                    ..
L90F9:
        .byte   $85,$27,$20,$EE,$91,$20,$67,$91 ; 90F9 85 27 20 EE 91 20 67 91  .' .. g.
        .byte   $A5                             ; 9101 A5                       .
; ----------------------------------------------------------------------------
        and     a:$8D,x                         ; 9102 3D 8D 00                 =..
        jsr     L00A9                           ; 9105 20 A9 00                  ..
        sta     PPUMASK                         ; 9108 8D 01 20                 .. 
        ldx     $27                             ; 910B A6 27                    .'
        lda     L90E5,x                         ; 910D BD E5 90                 ...
        ldy     #$02                            ; 9110 A0 02                    ..
        jsr     L8F97                           ; 9112 20 97 8F                  ..
        lda     $29                             ; 9115 A5 29                    .)
        eor     #$03                            ; 9117 49 03                    I.
        sta     $29                             ; 9119 85 29                    .)
        sta     $28                             ; 911B 85 28                    .(
        asl     a                               ; 911D 0A                       .
        asl     a                               ; 911E 0A                       .
        adc     #$20                            ; 911F 69 20                    i 
        sta     PPUADDR                         ; 9121 8D 06 20                 .. 
        lda     #$00                            ; 9124 A9 00                    ..
        sta     PPUADDR                         ; 9126 8D 06 20                 .. 
        lda     $27                             ; 9129 A5 27                    .'
        sta     $26                             ; 912B 85 26                    .&
        asl     a                               ; 912D 0A                       .
        tax                                     ; 912E AA                       .
        lda     L90B9,x                         ; 912F BD B9 90                 ...
        sta     $18                             ; 9132 85 18                    ..
        lda     L90BA,x                         ; 9134 BD BA 90                 ...
        sta     $19                             ; 9137 85 19                    ..
        ldy     #$00                            ; 9139 A0 00                    ..
        ldx     #$04                            ; 913B A2 04                    ..
L913D:
        lda     ($18),y                         ; 913D B1 18                    ..
        sta     PPUDATA                         ; 913F 8D 07 20                 .. 
        iny                                     ; 9142 C8                       .
        bne     L913D                           ; 9143 D0 F8                    ..
        inc     $19                             ; 9145 E6 19                    ..
        dex                                     ; 9147 CA                       .
        bne     L913D                           ; 9148 D0 F3                    ..
        stx     PPUSCROLL                       ; 914A 8E 05 20                 .. 
        stx     PPUSCROLL                       ; 914D 8E 05 20                 .. 
        ldx     $26                             ; 9150 A6 26                    .&
        lda     L90EF,x                         ; 9152 BD EF 90                 ...
        sta     $3D                             ; 9155 85 3D                    .=
        ora     #$80                            ; 9157 09 80                    ..
        ora     $29                             ; 9159 05 29                    .)
        sta     PPUCTRL                         ; 915B 8D 00 20                 .. 
        inc     $42                             ; 915E E6 42                    .B
        jsr     L9059                           ; 9160 20 59 90                  Y.
        jsr     L91A3                           ; 9163 20 A3 91                  ..
        rts                                     ; 9166 60                       `

; ----------------------------------------------------------------------------
L9167:
        ldy     #$00                            ; 9167 A0 00                    ..
        sty     $0598                           ; 9169 8C 98 05                 ...
L916C:
        lda     $049A,y                         ; 916C B9 9A 04                 ...
        cmp     #$0F                            ; 916F C9 0F                    ..
        beq     L918B                           ; 9171 F0 18                    ..
        inc     $0598                           ; 9173 EE 98 05                 ...
        and     #$F0                            ; 9176 29 F0                    ).
        bne     L917F                           ; 9178 D0 05                    ..
        lda     #$0F                            ; 917A A9 0F                    ..
        jmp     L918B                           ; 917C 4C 8B 91                 L..

; ----------------------------------------------------------------------------
L917F:
        sec                                     ; 917F 38                       8
        sbc     #$10                            ; 9180 E9 10                    ..
        sta     tmp14                           ; 9182 85 14                    ..
        lda     $049A,y                         ; 9184 B9 9A 04                 ...
        and     #$0F                            ; 9187 29 0F                    ).
        ora     tmp14                           ; 9189 05 14                    ..
L918B:
        sta     $049A,y                         ; 918B 99 9A 04                 ...
        iny                                     ; 918E C8                       .
        cpy     #$10                            ; 918F C0 10                    ..
        bcc     L916C                           ; 9191 90 D9                    ..
        lda     #$06                            ; 9193 A9 06                    ..
        jsr     L92DD                           ; 9195 20 DD 92                  ..
        ldy     #$03                            ; 9198 A0 03                    ..
        jsr     L902E                           ; 919A 20 2E 90                  ..
        lda     $0598                           ; 919D AD 98 05                 ...
        bne     L9167                           ; 91A0 D0 C5                    ..
        rts                                     ; 91A2 60                       `

; ----------------------------------------------------------------------------
L91A3:
        lda     $26                             ; 91A3 A5 26                    .&
        asl     a                               ; 91A5 0A                       .
        tax                                     ; 91A6 AA                       .
        lda     L90CF,x                         ; 91A7 BD CF 90                 ...
        sta     $18                             ; 91AA 85 18                    ..
        lda     L90D0,x                         ; 91AC BD D0 90                 ...
        sta     $19                             ; 91AF 85 19                    ..
L91B1:
        ldy     #$00                            ; 91B1 A0 00                    ..
        sty     $0598                           ; 91B3 8C 98 05                 ...
L91B6:
        lda     $049A,y                         ; 91B6 B9 9A 04                 ...
        cmp     ($18),y                         ; 91B9 D1 18                    ..
        beq     L91D6                           ; 91BB F0 19                    ..
        inc     $0598                           ; 91BD EE 98 05                 ...
        cmp     #$0F                            ; 91C0 C9 0F                    ..
        bne     L91C9                           ; 91C2 D0 05                    ..
        lda     #$00                            ; 91C4 A9 00                    ..
        jmp     L91CE                           ; 91C6 4C CE 91                 L..

; ----------------------------------------------------------------------------
L91C9:
        and     #$F0                            ; 91C9 29 F0                    ).
        clc                                     ; 91CB 18                       .
        adc     #$10                            ; 91CC 69 10                    i.
L91CE:
        sta     tmp14                           ; 91CE 85 14                    ..
        lda     ($18),y                         ; 91D0 B1 18                    ..
        and     #$0F                            ; 91D2 29 0F                    ).
        ora     tmp14                           ; 91D4 05 14                    ..
L91D6:
        sta     $049A,y                         ; 91D6 99 9A 04                 ...
        iny                                     ; 91D9 C8                       .
        cpy     #$10                            ; 91DA C0 10                    ..
        bcc     L91B6                           ; 91DC 90 D8                    ..
        lda     #$06                            ; 91DE A9 06                    ..
        jsr     L92DD                           ; 91E0 20 DD 92                  ..
        ldy     #$03                            ; 91E3 A0 03                    ..
        jsr     L902E                           ; 91E5 20 2E 90                  ..
        lda     $0598                           ; 91E8 AD 98 05                 ...
        bne     L91B1                           ; 91EB D0 C4                    ..
        rts                                     ; 91ED 60                       `

; ----------------------------------------------------------------------------
L91EE:
        lda     $26                             ; 91EE A5 26                    .&
        asl     a                               ; 91F0 0A                       .
        tax                                     ; 91F1 AA                       .
        lda     L90CF,x                         ; 91F2 BD CF 90                 ...
        sta     $18                             ; 91F5 85 18                    ..
        lda     L90D0,x                         ; 91F7 BD D0 90                 ...
        sta     $19                             ; 91FA 85 19                    ..
        ldy     #$0F                            ; 91FC A0 0F                    ..
L91FE:
        lda     ($18),y                         ; 91FE B1 18                    ..
        sta     $049A,y                         ; 9200 99 9A 04                 ...
        dey                                     ; 9203 88                       .
        bpl     L91FE                           ; 9204 10 F8                    ..
        rts                                     ; 9206 60                       `

; ----------------------------------------------------------------------------
        .byte   $0F                             ; 9207 0F                       .
        brk                                     ; 9208 00                       .
        bpl     L923B                           ; 9209 10 30                    .0
        .byte   $0F                             ; 920B 0F                       .
        rol     a                               ; 920C 2A                       *
        asl     controllerInput,x               ; 920D 16 30                    .0
        .byte   $0F                             ; 920F 0F                       .
        .byte   $19,$37,$02,$0F,$00,$30,$02     ; 9210 19 37 02 0F 00 30 02     .7...0.
L9217:
        .byte   $0F,$00,$10,$30,$0F,$16,$37,$07 ; 9217 0F 00 10 30 0F 16 37 07  ...0..7.
        .byte   $0F,$27,$37,$0C,$0F,$00,$20,$0C ; 921F 0F 27 37 0C 0F 00 20 0C  .'7... .
        .byte   $0F,$2A,$16,$30,$0F,$2A,$12,$30 ; 9227 0F 2A 16 30 0F 2A 12 30  .*.0.*.0
        .byte   $0F,$37,$16,$30,$0F,$00,$21,$30 ; 922F 0F 37 16 30 0F 00 21 30  .7.0..!0
        .byte   $0F,$37,$12,$30                 ; 9237 0F 37 12 30              .7.0
L923B:
        .byte   $0F,$37,$17,$39,$0F,$37,$1A,$30 ; 923B 0F 37 17 39 0F 37 1A 30  .7.9.7.0
        .byte   $0F,$37,$16,$30,$0F,$0F,$07,$27 ; 9243 0F 37 16 30 0F 0F 07 27  .7.0...'
        .byte   $0F,$0F,$08,$28,$0F,$08,$18,$28 ; 924B 0F 0F 08 28 0F 08 18 28  ...(...(
        .byte   $0F,$0C,$0F,$10,$20,$08,$17,$37 ; 9253 0F 0C 0F 10 20 08 17 37  .... ..7
        .byte   $20,$07,$17,$37,$20,$17,$27,$37 ; 925B 20 07 17 37 20 17 27 37   ..7 .'7
        .byte   $20,$1C,$10,$20,$0F,$0F,$0F,$0F ; 9263 20 1C 10 20 0F 0F 0F 0F   .. ....
        .byte   $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F ; 926B 0F 0F 0F 0F 0F 0F 0F 0F  ........
        .byte   $0F,$0F,$0F,$0F,$0F,$30,$10,$00 ; 9273 0F 0F 0F 0F 0F 30 10 00  .....0..
        .byte   $0F,$31,$30,$2A,$0F,$31,$30,$16 ; 927B 0F 31 30 2A 0F 31 30 16  .10*.10.
        .byte   $0F,$31,$30,$11,$0F,$27,$17,$37 ; 9283 0F 31 30 11 0F 27 17 37  .10..'.7
        .byte   $0F,$1C,$2C,$3B,$0F,$00,$10,$20 ; 928B 0F 1C 2C 3B 0F 00 10 20  ..,;... 
        .byte   $0F,$1C,$17,$27,$0F,$11,$2C,$31 ; 9293 0F 1C 17 27 0F 11 2C 31  ...'..,1
        .byte   $0F,$16,$37,$07,$0F,$00,$10,$30 ; 929B 0F 16 37 07 0F 00 10 30  ..7....0
        .byte   $0F,$00,$20,$0C                 ; 92A3 0F 00 20 0C              .. .
L92A7:
        .byte   $27                             ; 92A7 27                       '
L92A8:
        .byte   $92                             ; 92A8 92                       .
L92A9:
        .byte   $10                             ; 92A9 10                       .
L92AA:
        .byte   $3F                             ; 92AA 3F                       ?
L92AB:
        .byte   $10                             ; 92AB 10                       .
L92AC:
        .byte   $01,$9A,$04,$00,$3F,$10,$01,$67 ; 92AC 01 9A 04 00 3F 10 01 67  ....?..g
        .byte   $92,$10,$3F,$10,$01,$37,$92,$10 ; 92B4 92 10 3F 10 01 37 92 10  ..?..7..
        .byte   $3F,$10,$01,$17,$92,$00,$3F,$10 ; 92BC 3F 10 01 17 92 00 3F 10  ?.....?.
        .byte   $01,$9A,$04,$10,$3F,$10,$01,$57 ; 92C4 01 9A 04 10 3F 10 01 57  ....?..W
        .byte   $92,$00,$3F,$10,$01,$AA,$04,$10 ; 92CC 92 00 3F 10 01 AA 04 10  ..?.....
        .byte   $3F,$10,$01,$9A,$04,$00,$3F,$10 ; 92D4 3F 10 01 9A 04 00 3F 10  ?.....?.
        .byte   $02                             ; 92DC 02                       .
; ----------------------------------------------------------------------------
L92DD:
        pha                                     ; 92DD 48                       H
        inc     $42                             ; 92DE E6 42                    .B
        jsr     L9059                           ; 92E0 20 59 90                  Y.
        lda     #$CD                            ; 92E3 A9 CD                    ..
        sta     jmp1E                           ; 92E5 85 1E                    ..
        lda     #$80                            ; 92E7 A9 80                    ..
        sta     jmp1E+1                         ; 92E9 85 1F                    ..
        pla                                     ; 92EB 68                       h
        tax                                     ; 92EC AA                       .
        lda     L92A7,x                         ; 92ED BD A7 92                 ...
        sta     $10                             ; 92F0 85 10                    ..
        lda     L92A8,x                         ; 92F2 BD A8 92                 ...
        sta     $11                             ; 92F5 85 11                    ..
        lda     L92A9,x                         ; 92F7 BD A9 92                 ...
        sta     tmp12                           ; 92FA 85 12                    ..
        lda     L92AA,x                         ; 92FC BD AA 92                 ...
        cmp     #$20                            ; 92FF C9 20                    . 
        bne     L9309                           ; 9301 D0 06                    ..
        lda     $28                             ; 9303 A5 28                    .(
        asl     a                               ; 9305 0A                       .
        asl     a                               ; 9306 0A                       .
        adc     #$20                            ; 9307 69 20                    i 
L9309:
        sta     tmp13                           ; 9309 85 13                    ..
        lda     L92AB,x                         ; 930B BD AB 92                 ...
        sta     $34                             ; 930E 85 34                    .4
        lda     L92AC,x                         ; 9310 BD AC 92                 ...
        sta     $33                             ; 9313 85 33                    .3
        sta     $3E                             ; 9315 85 3E                    .>
        jsr     L904F                           ; 9317 20 4F 90                  O.
        lda     #$86                            ; 931A A9 86                    ..
        sta     jmp1E                           ; 931C 85 1E                    ..
        lda     #$80                            ; 931E A9 80                    ..
        sta     jmp1E+1                         ; 9320 85 1F                    ..
        rts                                     ; 9322 60                       `

; ----------------------------------------------------------------------------
L9323:
        sta     $32                             ; 9323 85 32                    .2
        txa                                     ; 9325 8A                       .
        pha                                     ; 9326 48                       H
        tya                                     ; 9327 98                       .
        pha                                     ; 9328 48                       H
        lda     $32                             ; 9329 A5 32                    .2
        jsr     L9335                           ; 932B 20 35 93                  5.
        pla                                     ; 932E 68                       h
        tay                                     ; 932F A8                       .
        pla                                     ; 9330 68                       h
        tax                                     ; 9331 AA                       .
        lda     $32                             ; 9332 A5 32                    .2
        rts                                     ; 9334 60                       `

; ----------------------------------------------------------------------------
L9335:
        sta     $4A                             ; 9335 85 4A                    .J
        tya                                     ; 9337 98                       .
        lsr     a                               ; 9338 4A                       J
        pha                                     ; 9339 48                       H
        lsr     a                               ; 933A 4A                       J
        lsr     a                               ; 933B 4A                       J
        sta     $4D                             ; 933C 85 4D                    .M
        tya                                     ; 933E 98                       .
        asl     a                               ; 933F 0A                       .
        asl     a                               ; 9340 0A                       .
        asl     a                               ; 9341 0A                       .
        asl     a                               ; 9342 0A                       .
        asl     a                               ; 9343 0A                       .
        sta     $4E                             ; 9344 85 4E                    .N
        txa                                     ; 9346 8A                       .
        clc                                     ; 9347 18                       .
        adc     $4E                             ; 9348 65 4E                    eN
        sta     $4E                             ; 934A 85 4E                    .N
        lda     #$00                            ; 934C A9 00                    ..
        adc     $4D                             ; 934E 65 4D                    eM
        sta     $4D                             ; 9350 85 4D                    .M
        lda     $28                             ; 9352 A5 28                    .(
        asl     a                               ; 9354 0A                       .
        asl     a                               ; 9355 0A                       .
        adc     $4D                             ; 9356 65 4D                    eM
        adc     #$20                            ; 9358 69 20                    i 
        sta     $4D                             ; 935A 85 4D                    .M
        lda     #$FF                            ; 935C A9 FF                    ..
        sta     $4B                             ; 935E 85 4B                    .K
        jsr     L93A4                           ; 9360 20 A4 93                  ..
        lda     #$03                            ; 9363 A9 03                    ..
        sta     $4C                             ; 9365 85 4C                    .L
        txa                                     ; 9367 8A                       .
        lsr     a                               ; 9368 4A                       J
        lsr     a                               ; 9369 4A                       J
        bcc     L9370                           ; 936A 90 04                    ..
        asl     $4C                             ; 936C 06 4C                    .L
        asl     $4C                             ; 936E 06 4C                    .L
L9370:
        sta     $4E                             ; 9370 85 4E                    .N
        pla                                     ; 9372 68                       h
        lsr     a                               ; 9373 4A                       J
        bcc     L937E                           ; 9374 90 08                    ..
        asl     $4C                             ; 9376 06 4C                    .L
        asl     $4C                             ; 9378 06 4C                    .L
        asl     $4C                             ; 937A 06 4C                    .L
        asl     $4C                             ; 937C 06 4C                    .L
L937E:
        asl     a                               ; 937E 0A                       .
        asl     a                               ; 937F 0A                       .
        asl     a                               ; 9380 0A                       .
        clc                                     ; 9381 18                       .
        adc     $4E                             ; 9382 65 4E                    eN
        clc                                     ; 9384 18                       .
        adc     #$C0                            ; 9385 69 C0                    i.
        sta     $4E                             ; 9387 85 4E                    .N
        lda     $28                             ; 9389 A5 28                    .(
        asl     a                               ; 938B 0A                       .
        asl     a                               ; 938C 0A                       .
        adc     #$23                            ; 938D 69 23                    i#
        sta     $4D                             ; 938F 85 4D                    .M
        lda     $2A                             ; 9391 A5 2A                    .*
        sta     $4A                             ; 9393 85 4A                    .J
        lda     $4C                             ; 9395 A5 4C                    .L
        eor     #$FF                            ; 9397 49 FF                    I.
        sta     $4B                             ; 9399 85 4B                    .K
        lda     $4C                             ; 939B A5 4C                    .L
L939D:
        lsr     a                               ; 939D 4A                       J
        bcs     L93A4                           ; 939E B0 04                    ..
        asl     $4A                             ; 93A0 06 4A                    .J
        bcc     L939D                           ; 93A2 90 F9                    ..
L93A4:
        ldy     $41                             ; 93A4 A4 41                    .A
        cpy     #$08                            ; 93A6 C0 08                    ..
        beq     L93A4                           ; 93A8 F0 FA                    ..
        lda     $4B                             ; 93AA A5 4B                    .K
        sta     $04D2,y                         ; 93AC 99 D2 04                 ...
        lda     $4E                             ; 93AF A5 4E                    .N
        sta     $04BA,y                         ; 93B1 99 BA 04                 ...
        lda     $4D                             ; 93B4 A5 4D                    .M
        sta     $04C2,y                         ; 93B6 99 C2 04                 ...
        lda     $4A                             ; 93B9 A5 4A                    .J
        sta     $04CA,y                         ; 93BB 99 CA 04                 ...
        inc     $41                             ; 93BE E6 41                    .A
        iny                                     ; 93C0 C8                       .
        cpy     $41                             ; 93C1 C4 41                    .A
        bne     L93A4                           ; 93C3 D0 DF                    ..
        rts                                     ; 93C5 60                       `

; ----------------------------------------------------------------------------
L93C6:
        lda     #$0A                            ; 93C6 A9 0A                    ..
        sta     $05F9                           ; 93C8 8D F9 05                 ...
        inx                                     ; 93CB E8                       .
        inx                                     ; 93CC E8                       .
        inx                                     ; 93CD E8                       .
        ldy     #$03                            ; 93CE A0 03                    ..
L93D0:
        lda     L93DB,x                         ; 93D0 BD DB 93                 ...
        sta     SQ2_VOL,y                       ; 93D3 99 04 40                 ..@
        dex                                     ; 93D6 CA                       .
        dey                                     ; 93D7 88                       .
        bpl     L93D0                           ; 93D8 10 F6                    ..
        rts                                     ; 93DA 60                       `

; ----------------------------------------------------------------------------
L93DB:
        .byte   $5F                             ; 93DB 5F                       _
        .byte   $8B                             ; 93DC 8B                       .
        asl     $1F7C                           ; 93DD 0E 7C 1F                 .|.
        lda     #$2E                            ; 93E0 A9 2E                    ..
        .byte   $3B                             ; 93E2 3B                       ;
        .byte   $DF                             ; 93E3 DF                       .
        .byte   $A3,$9E,$B8,$9F,$A9,$2E,$6F,$9F ; 93E4 A3 9E B8 9F A9 2E 6F 9F  ......o.
        .byte   $81,$1E,$58,$DF,$19,$FE,$48,$DF ; 93EC 81 1E 58 DF 19 FE 48 DF  ..X...H.
        .byte   $2A,$01,$8E,$9F,$F9,$1E,$57,$9F ; 93F4 2A 01 8E 9F F9 1E 57 9F  *.....W.
        .byte   $F9,$D2,$52,$43,$00,$60,$3B,$9F ; 93FC F9 D2 52 43 00 60 3B 9F  ..RC.`;.
        .byte   $8C,$80,$F9,$00,$00,$00,$00     ; 9404 8C 80 F9 00 00 00 00     .......
L940B:
        .byte   $48,$A9,$30,$AE,$70,$05,$AC,$71 ; 940B 48 A9 30 AE 70 05 AC 71  H.0.p..q
        .byte   $05                             ; 9413 05                       .
; ----------------------------------------------------------------------------
        jsr     L9323                           ; 9414 20 23 93                  #.
        jsr     L9054                           ; 9417 20 54 90                  T.
        pla                                     ; 941A 68                       h
        ldx     $0570                           ; 941B AE 70 05                 .p.
        ldy     $0571                           ; 941E AC 71 05                 .q.
        jsr     L9323                           ; 9421 20 23 93                  #.
        jmp     L9054                           ; 9424 4C 54 90                 LT.

; ----------------------------------------------------------------------------
L9427:
        .byte   $04                             ; 9427 04                       .
        php                                     ; 9428 08                       .
        .byte   $12                             ; 9429 12                       .
        clc                                     ; 942A 18                       .
L942B:
        .byte   $03                             ; 942B 03                       .
        php                                     ; 942C 08                       .
        .byte   $02                             ; 942D 02                       .
        .byte   $02                             ; 942E 02                       .
L942F:
        jsr     L956F                           ; 942F 20 6F 95                  o.
        .byte   $85,$1C,$AD,$B8,$05,$18         ; 9432 85 1C AD B8 05 18        ......
; ----------------------------------------------------------------------------
        adc     #$0E                            ; 9438 69 0E                    i.
        sta     $0571                           ; 943A 8D 71 05                 .q.
        lda     L9427                           ; 943D AD 27 94                 .'.
        sta     $0570                           ; 9440 8D 70 05                 .p.
        lda     #$03                            ; 9443 A9 03                    ..
        sta     $1D                             ; 9445 85 1D                    ..
        sta     $3F                             ; 9447 85 3F                    .?
L9449:
        lda     $0612                           ; 9449 AD 12 06                 ...
        bne     L9453                           ; 944C D0 05                    ..
        lda     #$04                            ; 944E A9 04                    ..
        jsr     LBC1F                           ; 9450 20 1F BC                  ..
L9453:
        lda     $3F                             ; 9453 A5 3F                    .?
        bne     L9449                           ; 9455 D0 F2                    ..
        .byte   $20,$CE,$8F,$D0,$0B             ; 9457 20 CE 8F D0 0B            ....
; ----------------------------------------------------------------------------
        ldx     $1C                             ; 945C A6 1C                    ..
        lda     $04DA,x                         ; 945E BD DA 04                 ...
        jsr     L940B                           ; 9461 20 0B 94                  ..
        jmp     L9449                           ; 9464 4C 49 94                 LI.

; ----------------------------------------------------------------------------
        txa                                     ; 9467 8A                       .
        ldx     $1C                             ; 9468 A6 1C                    ..
        and     #$33                            ; 946A 29 33                    )3
        beq     L9449                           ; 946C F0 DB                    ..
        and     #$32                            ; 946E 29 32                    )2
        beq     L94CF                           ; 9470 F0 5D                    .]
        and     #$30                            ; 9472 29 30                    )0
        beq     L94BC                           ; 9474 F0 46                    .F
        and     #$20                            ; 9476 29 20                    ) 
        beq     L948C                           ; 9478 F0 12                    ..
        dec     $04DA,x                         ; 947A DE DA 04                 ...
        lda     $04DA,x                         ; 947D BD DA 04                 ...
        cmp     #$0B                            ; 9480 C9 0B                    ..
        bcs     L949D                           ; 9482 B0 19                    ..
        .byte   $A9,$24,$9D,$DA,$04,$4C,$9D,$94 ; 9484 A9 24 9D DA 04 4C 9D 94  .$...L..
L948C:
        .byte   $FE,$DA,$04,$BD,$DA,$04,$C9,$24 ; 948C FE DA 04 BD DA 04 C9 24  .......$
        .byte   $90                             ; 9494 90                       .
; ----------------------------------------------------------------------------
        .byte   $07                             ; 9495 07                       .
        beq     L949D                           ; 9496 F0 05                    ..
        lda     #$0B                            ; 9498 A9 0B                    ..
        sta     $04DA,x                         ; 949A 9D DA 04                 ...
L949D:
        lda     $04DA,x                         ; 949D BD DA 04                 ...
        ldx     $0570                           ; 94A0 AE 70 05                 .p.
        ldy     $0571                           ; 94A3 AC 71 05                 .q.
        jsr     L9335                           ; 94A6 20 35 93                  5.
        lda     #$00                            ; 94A9 A9 00                    ..
        sta     nmiWaitVar                      ; 94AB 85 3C                    .<
L94AD:
        lda     nmiWaitVar                      ; 94AD A5 3C                    .<
        bne     L9449                           ; 94AF D0 98                    ..
        ldx     $1C                             ; 94B1 A6 1C                    ..
        lda     $04DA,x                         ; 94B3 BD DA 04                 ...
        jsr     L940B                           ; 94B6 20 0B 94                  ..
        jmp     L94AD                           ; 94B9 4C AD 94                 L..

; ----------------------------------------------------------------------------
L94BC:
        lda     $1D                             ; 94BC A5 1D                    ..
        cmp     #$03                            ; 94BE C9 03                    ..
        bcc     L94C5                           ; 94C0 90 03                    ..
        jmp     L9449                           ; 94C2 4C 49 94                 LI.

; ----------------------------------------------------------------------------
L94C5:
        .byte   $E6,$1D,$C6,$1C,$CE,$70,$05,$4C ; 94C5 E6 1D C6 1C CE 70 05 4C  .....p.L
        .byte   $A9,$94                         ; 94CD A9 94                    ..
L94CF:
        .byte   $E6,$1C,$EE,$70,$05,$C6,$1D,$D0 ; 94CF E6 1C EE 70 05 C6 1D D0  ...p....
        .byte   $D1                             ; 94D7 D1                       .
; ----------------------------------------------------------------------------
        rts                                     ; 94D8 60                       `

; ----------------------------------------------------------------------------
L94D9:
        lda     #$00                            ; 94D9 A9 00                    ..
L94DB:
        sta     $05B8                           ; 94DB 8D B8 05                 ...
        jsr     L9579                           ; 94DE 20 79 95                  y.
        tax                                     ; 94E1 AA                       .
        ldy     #$07                            ; 94E2 A0 07                    ..
L94E4:
        lda     $04DA,x                         ; 94E4 BD DA 04                 ...
        cmp     #$0A                            ; 94E7 C9 0A                    ..
        bcc     L94ED                           ; 94E9 90 02                    ..
        lda     #$00                            ; 94EB A9 00                    ..
L94ED:
        cmp     $0587,y                         ; 94ED D9 87 05                 ...
        bcc     L9508                           ; 94F0 90 16                    ..
        bne     L94F8                           ; 94F2 D0 04                    ..
        inx                                     ; 94F4 E8                       .
        dey                                     ; 94F5 88                       .
        bpl     L94E4                           ; 94F6 10 EC                    ..
L94F8:
        lda     $05B8                           ; 94F8 AD B8 05                 ...
        clc                                     ; 94FB 18                       .
        adc     #$01                            ; 94FC 69 01                    i.
        cmp     #$0A                            ; 94FE C9 0A                    ..
        bcc     L94DB                           ; 9500 90 D9                    ..
        lda     #$FF                            ; 9502 A9 FF                    ..
        sta     $05B8                           ; 9504 8D B8 05                 ...
        rts                                     ; 9507 60                       `

; ----------------------------------------------------------------------------
L9508:
        lda     $05B8                           ; 9508 AD B8 05                 ...
        .byte   $20,$6F,$95,$85,$14,$E6         ; 950B 20 6F 95 85 14 E6         o....
; ----------------------------------------------------------------------------
        .byte   $14                             ; 9511 14                       .
        ldx     #$87                            ; 9512 A2 87                    ..
L9514:
        lda     $04D9,x                         ; 9514 BD D9 04                 ...
        sta     $04E8,x                         ; 9517 9D E8 04                 ...
        dex                                     ; 951A CA                       .
        cpx     tmp14                           ; 951B E4 14                    ..
        bcs     L9514                           ; 951D B0 F5                    ..
        lda     $05B8                           ; 951F AD B8 05                 ...
        jsr     L956F                           ; 9522 20 6F 95                  o.
        tax                                     ; 9525 AA                       .
        lda     #$0B                            ; 9526 A9 0B                    ..
        sta     $04DA,x                         ; 9528 9D DA 04                 ...
        inx                                     ; 952B E8                       .
        sta     $04DA,x                         ; 952C 9D DA 04                 ...
        inx                                     ; 952F E8                       .
        sta     $04DA,x                         ; 9530 9D DA 04                 ...
        inx                                     ; 9533 E8                       .
        ldy     #$07                            ; 9534 A0 07                    ..
L9536:
        lda     $0587,y                         ; 9536 B9 87 05                 ...
        bne     L954B                           ; 9539 D0 10                    ..
        lda     #$32                            ; 953B A9 32                    .2
        sta     $04DA,x                         ; 953D 9D DA 04                 ...
        inx                                     ; 9540 E8                       .
        dey                                     ; 9541 88                       .
        bpl     L9536                           ; 9542 10 F2                    ..
L9544:
        lda     $0587,y                         ; 9544 B9 87 05                 ...
        bne     L954B                           ; 9547 D0 02                    ..
        lda     #$0A                            ; 9549 A9 0A                    ..
L954B:
        sta     $04DA,x                         ; 954B 9D DA 04                 ...
        inx                                     ; 954E E8                       .
        dey                                     ; 954F 88                       .
        bpl     L9544                           ; 9550 10 F2                    ..
        .byte   $A9,$32                         ; 9552 A9 32                    .2
; ----------------------------------------------------------------------------
        sta     $04DA,x                         ; 9554 9D DA 04                 ...
        sta     $04DC,x                         ; 9557 9D DC 04                 ...
        lda     $0596                           ; 955A AD 96 05                 ...
        bne     L9561                           ; 955D D0 02                    ..
        lda     #$0A                            ; 955F A9 0A                    ..
L9561:
        sta     $04DB,x                         ; 9561 9D DB 04                 ...
        lda     $0595                           ; 9564 AD 95 05                 ...
        bne     L956B                           ; 9567 D0 02                    ..
        .byte   $A9                             ; 9569 A9                       .
; ----------------------------------------------------------------------------
        asl     a                               ; 956A 0A                       .
L956B:
        sta     $04DD,x                         ; 956B 9D DD 04                 ...
        rts                                     ; 956E 60                       `

; ----------------------------------------------------------------------------
L956F:
        sta     tmp14                           ; 956F 85 14                    ..
        asl     a                               ; 9571 0A                       .
        asl     a                               ; 9572 0A                       .
        asl     a                               ; 9573 0A                       .
        asl     a                               ; 9574 0A                       .
        sec                                     ; 9575 38                       8
        sbc     tmp14                           ; 9576 E5 14                    ..
        rts                                     ; 9578 60                       `

; ----------------------------------------------------------------------------
L9579:
        jsr     L956F                           ; 9579 20 6F 95                  o.
        clc                                     ; 957C 18                       .
        adc     #$03                            ; 957D 69 03                    i.
        rts                                     ; 957F 60                       `

; ----------------------------------------------------------------------------
L9580:
        lda     #$05                            ; 9580 A9 05                    ..
        jsr     L90F9                           ; 9582 20 F9 90                  ..
        lda     #$04                            ; 9585 A9 04                    ..
        jsr     LBC1F                           ; 9587 20 1F BC                  ..
        lda     #$01                            ; 958A A9 01                    ..
        sta     $2A                             ; 958C 85 2A                    .*
        ldy     #$0E                            ; 958E A0 0E                    ..
        ldx     #$00                            ; 9590 A2 00                    ..
L9592:
        sty     $0571                           ; 9592 8C 71 05                 .q.
        ldy     #$00                            ; 9595 A0 00                    ..
L9597:
        lda     L9427,y                         ; 9597 B9 27 94                 .'.
        sta     $0570                           ; 959A 8D 70 05                 .p.
        lda     L942B,y                         ; 959D B9 2B 94                 .+.
        sta     $1C                             ; 95A0 85 1C                    ..
        sty     $1D                             ; 95A2 84 1D                    ..
        ldy     $0571                           ; 95A4 AC 71 05                 .q.
L95A7:
        lda     $04DA,x                         ; 95A7 BD DA 04                 ...
        stx     tmp14                           ; 95AA 86 14                    ..
        ldx     $0570                           ; 95AC AE 70 05                 .p.
        jsr     L9323                           ; 95AF 20 23 93                  #.
        inc     $0570                           ; 95B2 EE 70 05                 .p.
        ldx     tmp14                           ; 95B5 A6 14                    ..
        inx                                     ; 95B7 E8                       .
        dec     $1C                             ; 95B8 C6 1C                    ..
        bne     L95A7                           ; 95BA D0 EB                    ..
        ldy     $1D                             ; 95BC A4 1D                    ..
        iny                                     ; 95BE C8                       .
        cpy     #$04                            ; 95BF C0 04                    ..
        bcc     L9597                           ; 95C1 90 D4                    ..
        ldy     $0571                           ; 95C3 AC 71 05                 .q.
        iny                                     ; 95C6 C8                       .
        cpy     #$18                            ; 95C7 C0 18                    ..
        bcc     L9592                           ; 95C9 90 C7                    ..
        jsr     L9054                           ; 95CB 20 54 90                  T.
        lda     #$09                            ; 95CE A9 09                    ..
        sta     $26                             ; 95D0 85 26                    .&
        jsr     L91A3                           ; 95D2 20 A3 91                  ..
        rts                                     ; 95D5 60                       `

; ----------------------------------------------------------------------------
L95D6:
L95D7           := * + 1
        ldy     #$05                            ; 95D6 A0 05                    ..
        ldy     $05                             ; 95D8 A4 05                    ..
        tay                                     ; 95DA A8                       .
        ora     $AC                             ; 95DB 05 AC                    ..
        ora     $B0                             ; 95DD 05 B0                    ..
        .byte   $05                             ; 95DF 05                       .
L95E0:
        .byte   $07,$0B,$0E,$11,$14             ; 95E0 07 0B 0E 11 14           .....
L95E5:
        .byte   $01,$04,$0A,$1E,$78,$00,$01,$01 ; 95E5 01 04 0A 1E 78 00 01 01  ....x...
        .byte   $01,$01                         ; 95ED 01 01                    ..
L95EF:
        .byte   $06,$0A,$0D,$10,$13             ; 95EF 06 0A 0D 10 13           .....
L95F4:
        .byte   $AE,$9F,$05,$BC,$EA,$95,$AE,$70 ; 95F4 AE 9F 05 BC EA 95 AE 70  .......p
        .byte   $05                             ; 95FC 05                       .
; ----------------------------------------------------------------------------
L95FD:
        lda     ($18),y                         ; 95FD B1 18                    ..
        clc                                     ; 95FF 18                       .
        adc     #$01                            ; 9600 69 01                    i.
        cmp     #$0A                            ; 9602 C9 0A                    ..
        bcc     L9608                           ; 9604 90 02                    ..
        lda     #$00                            ; 9606 A9 00                    ..
L9608:
        sta     ($18),y                         ; 9608 91 18                    ..
        bne     L9610                           ; 960A D0 04                    ..
        iny                                     ; 960C C8                       .
        jmp     L95FD                           ; 960D 4C FD 95                 L..

; ----------------------------------------------------------------------------
L9610:
        sty     $1C                             ; 9610 84 1C                    ..
        lda     $0570                           ; 9612 AD 70 05                 .p.
        sec                                     ; 9615 38                       8
        sbc     $1C                             ; 9616 E5 1C                    ..
        tax                                     ; 9618 AA                       .
L9619:
        sty     $1C                             ; 9619 84 1C                    ..
        lda     ($18),y                         ; 961B B1 18                    ..
        bne     L9621                           ; 961D D0 02                    ..
        lda     #$0A                            ; 961F A9 0A                    ..
L9621:
        ldy     $0571                           ; 9621 AC 71 05                 .q.
        jsr     L9323                           ; 9624 20 23 93                  #.
        ldy     $1C                             ; 9627 A4 1C                    ..
        inx                                     ; 9629 E8                       .
        dey                                     ; 962A 88                       .
        bpl     L9619                           ; 962B 10 EC                    ..
        rts                                     ; 962D 60                       `

; ----------------------------------------------------------------------------
L962E:
        jsr     L9751                           ; 962E 20 51 97                  Q.
        ldx     #$01                            ; 9631 A2 01                    ..
L9633:
        stx     $059F                           ; 9633 8E 9F 05                 ...
        lda     $0579,x                         ; 9636 BD 79 05                 .y.
        ldy     L95EF,x                         ; 9639 BC EF 95                 ...
        ldx     #$0C                            ; 963C A2 0C                    ..
        jsr     L96CC                           ; 963E 20 CC 96                  ..
        ldx     $059F                           ; 9641 AE 9F 05                 ...
        inx                                     ; 9644 E8                       .
        cpx     #$05                            ; 9645 E0 05                    ..
        bcc     L9633                           ; 9647 90 EA                    ..
        lda     #$00                            ; 9649 A9 00                    ..
        ldy     #$04                            ; 964B A0 04                    ..
L964D:
        sta     $058F,y                         ; 964D 99 8F 05                 ...
        sta     $05A0,y                         ; 9650 99 A0 05                 ...
        sta     $05A4,y                         ; 9653 99 A4 05                 ...
        sta     $05A8,y                         ; 9656 99 A8 05                 ...
        sta     $05AC,y                         ; 9659 99 AC 05                 ...
        sta     $05B0,y                         ; 965C 99 B0 05                 ...
        dey                                     ; 965F 88                       .
        bpl     L964D                           ; 9660 10 EB                    ..
        lda     #$00                            ; 9662 A9 00                    ..
        sta     $059F                           ; 9664 8D 9F 05                 ...
        jsr     L9743                           ; 9667 20 43 97                  C.
L966A:
        ldx     $0581                           ; 966A AE 81 05                 ...
        beq     L9678                           ; 966D F0 09                    ..
L966F:
        dec     $0581                           ; 966F CE 81 05                 ...
        jsr     L96EB                           ; 9672 20 EB 96                  ..
        jmp     L966A                           ; 9675 4C 6A 96                 Lj.

; ----------------------------------------------------------------------------
L9678:
        ldx     $0582                           ; 9678 AE 82 05                 ...
        beq     L9683                           ; 967B F0 06                    ..
        dec     $0582                           ; 967D CE 82 05                 ...
        jmp     L966F                           ; 9680 4C 6F 96                 Lo.

; ----------------------------------------------------------------------------
L9683:
        ldx     #$01                            ; 9683 A2 01                    ..
L9685:
        stx     $059F                           ; 9685 8E 9F 05                 ...
        jsr     L9743                           ; 9688 20 43 97                  C.
L968B:
        ldx     $059F                           ; 968B AE 9F 05                 ...
        lda     $0579,x                         ; 968E BD 79 05                 .y.
        beq     L96A7                           ; 9691 F0 14                    ..
        dec     $0579,x                         ; 9693 DE 79 05                 .y.
        lda     L95E5,x                         ; 9696 BD E5 95                 ...
        sta     $05B5                           ; 9699 8D B5 05                 ...
L969C:
        jsr     L96EB                           ; 969C 20 EB 96                  ..
        dec     $05B5                           ; 969F CE B5 05                 ...
        bne     L969C                           ; 96A2 D0 F8                    ..
        jmp     L968B                           ; 96A4 4C 8B 96                 L..

; ----------------------------------------------------------------------------
L96A7:
        ldx     $059F                           ; 96A7 AE 9F 05                 ...
        inx                                     ; 96AA E8                       .
        cpx     #$05                            ; 96AB E0 05                    ..
        bcc     L9685                           ; 96AD 90 D6                    ..
        ldy     #$78                            ; 96AF A0 78                    .x
        jsr     L8FBB                           ; 96B1 20 BB 8F                  ..
        rts                                     ; 96B4 60                       `

; ----------------------------------------------------------------------------
L96B5:
        cmp     #$63                            ; 96B5 C9 63                    .c
        bcc     L96BB                           ; 96B7 90 02                    ..
        lda     #$63                            ; 96B9 A9 63                    .c
L96BB:
        ldy     #$FF                            ; 96BB A0 FF                    ..
L96BD:
        iny                                     ; 96BD C8                       .
        sec                                     ; 96BE 38                       8
        sbc     #$0A                            ; 96BF E9 0A                    ..
        bcs     L96BD                           ; 96C1 B0 FA                    ..
        adc     #$0A                            ; 96C3 69 0A                    i.
        sty     $05B6                           ; 96C5 8C B6 05                 ...
        sta     $05B7                           ; 96C8 8D B7 05                 ...
        rts                                     ; 96CB 60                       `

; ----------------------------------------------------------------------------
L96CC:
        sty     $0571                           ; 96CC 8C 71 05                 .q.
        jsr     L96B5                           ; 96CF 20 B5 96                  ..
        ldy     $0571                           ; 96D2 AC 71 05                 .q.
        lda     $05B6                           ; 96D5 AD B6 05                 ...
        bne     L96DC                           ; 96D8 D0 02                    ..
        lda     #$32                            ; 96DA A9 32                    .2
L96DC:
        jsr     L9323                           ; 96DC 20 23 93                  #.
        inx                                     ; 96DF E8                       .
        lda     $05B7                           ; 96E0 AD B7 05                 ...
        bne     L96E7                           ; 96E3 D0 02                    ..
        lda     #$0A                            ; 96E5 A9 0A                    ..
L96E7:
        jsr     L9335                           ; 96E7 20 35 93                  5.
        rts                                     ; 96EA 60                       `

; ----------------------------------------------------------------------------
L96EB:
        lda     #$87                            ; 96EB A9 87                    ..
        sta     $18                             ; 96ED 85 18                    ..
        lda     #$05                            ; 96EF A9 05                    ..
        sta     $19                             ; 96F1 85 19                    ..
        lda     #$0F                            ; 96F3 A9 0F                    ..
        sta     $0570                           ; 96F5 8D 70 05                 .p.
        lda     #$02                            ; 96F8 A9 02                    ..
        sta     $0571                           ; 96FA 8D 71 05                 .q.
        lda     #$03                            ; 96FD A9 03                    ..
        sta     $2A                             ; 96FF 85 2A                    .*
        jsr     L95F4                           ; 9701 20 F4 95                  ..
        ldx     #$01                            ; 9704 A2 01                    ..
        stx     $2A                             ; 9706 86 2A                    .*
        lda     #$8F                            ; 9708 A9 8F                    ..
        sta     $18                             ; 970A 85 18                    ..
        lda     #$05                            ; 970C A9 05                    ..
        sta     $19                             ; 970E 85 19                    ..
        lda     #$14                            ; 9710 A9 14                    ..
        sta     $0570                           ; 9712 8D 70 05                 .p.
        lda     #$18                            ; 9715 A9 18                    ..
        sta     $0571                           ; 9717 8D 71 05                 .q.
        jsr     L95F4                           ; 971A 20 F4 95                  ..
        lda     $059F                           ; 971D AD 9F 05                 ...
        asl     a                               ; 9720 0A                       .
        tax                                     ; 9721 AA                       .
        lda     L95D6,x                         ; 9722 BD D6 95                 ...
        sta     $18                             ; 9725 85 18                    ..
        lda     L95D7,x                         ; 9727 BD D7 95                 ...
        sta     $19                             ; 972A 85 19                    ..
        ldx     $059F                           ; 972C AE 9F 05                 ...
        lda     #$14                            ; 972F A9 14                    ..
        sta     $0570                           ; 9731 8D 70 05                 .p.
        lda     L95E0,x                         ; 9734 BD E0 95                 ...
        sta     $0571                           ; 9737 8D 71 05                 .q.
        jsr     L95F4                           ; 973A 20 F4 95                  ..
        ldx     #$14                            ; 973D A2 14                    ..
        jsr     L93C6                           ; 973F 20 C6 93                  ..
        rts                                     ; 9742 60                       `

; ----------------------------------------------------------------------------
L9743:
        ldx     $059F                           ; 9743 AE 9F 05                 ...
        ldy     L95E0,x                         ; 9746 BC E0 95                 ...
        ldx     #$14                            ; 9749 A2 14                    ..
        lda     #$0A                            ; 974B A9 0A                    ..
        jsr     L9323                           ; 974D 20 23 93                  #.
        rts                                     ; 9750 60                       `

; ----------------------------------------------------------------------------
L9751:
        ldx     #$C8                            ; 9751 A2 C8                    ..
L9753:
        lda     LAD62,x                         ; 9753 BD 62 AD                 .b.
        sta     $0309,x                         ; 9756 9D 09 03                 ...
        dex                                     ; 9759 CA                       .
        bne     L9753                           ; 975A D0 F7                    ..
        jsr     L976C                           ; 975C 20 6C 97                  l.
        lda     #$06                            ; 975F A9 06                    ..
        jsr     L92DD                           ; 9761 20 DD 92                  ..
        jsr     L8D5E                           ; 9764 20 5E 8D                  ^.
        lda     #$01                            ; 9767 A9 01                    ..
        sta     $2A                             ; 9769 85 2A                    .*
        rts                                     ; 976B 60                       `

; ----------------------------------------------------------------------------
L976C:
        jsr     L91EE                           ; 976C 20 EE 91                  ..
        ldx     #$07                            ; 976F A2 07                    ..
L9771:
        lda     L9217,x                         ; 9771 BD 17 92                 ...
        sta     $049A,x                         ; 9774 9D 9A 04                 ...
        dex                                     ; 9777 CA                       .
        bpl     L9771                           ; 9778 10 F7                    ..
        rts                                     ; 977A 60                       `

; ----------------------------------------------------------------------------
; possible nametable
unknownTable03:
        .byte   $00,$00,$00,$00,$00,$00,$DF,$E0 ; 977B 00 00 00 00 00 00 DF E0  ........
        .byte   $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0 ; 9783 E0 E0 E0 E0 E0 E0 E0 E0  ........
        .byte   $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0 ; 978B E0 E0 E0 E0 E0 E0 E0 E0  ........
        .byte   $E0,$E1,$00,$00,$00,$00,$00,$00 ; 9793 E0 E1 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$E2,$30 ; 979B 00 00 00 00 00 00 E2 30  .......0
        .byte   $30,$30,$30,$30,$30,$30,$30,$30 ; 97A3 30 30 30 30 30 30 30 30  00000000
        .byte   $30,$30,$30,$30,$30,$30,$30,$30 ; 97AB 30 30 30 30 30 30 30 30  00000000
        .byte   $30,$E3,$00,$00,$00,$00,$00,$00 ; 97B3 30 E3 00 00 00 00 00 00  0.......
        .byte   $00,$00,$00,$00,$00,$00,$E2,$30 ; 97BB 00 00 00 00 00 00 E2 30  .......0
        .byte   $30,$30,$30,$30,$30,$30,$30,$30 ; 97C3 30 30 30 30 30 30 30 30  00000000
        .byte   $30,$30,$30,$30,$30,$30,$30,$30 ; 97CB 30 30 30 30 30 30 30 30  00000000
        .byte   $30,$E3,$00,$00,$00,$00,$00,$00 ; 97D3 30 E3 00 00 00 00 00 00  0.......
        .byte   $00,$00,$00,$00,$00,$00,$E2,$30 ; 97DB 00 00 00 00 00 00 E2 30  .......0
        .byte   $30,$30,$30,$30,$30,$30,$30,$30 ; 97E3 30 30 30 30 30 30 30 30  00000000
        .byte   $30,$30,$30,$30,$30,$30,$30,$30 ; 97EB 30 30 30 30 30 30 30 30  00000000
        .byte   $30,$E3,$00,$00,$00,$00,$00,$00 ; 97F3 30 E3 00 00 00 00 00 00  0.......
        .byte   $00,$00,$00,$00,$00,$00,$E2,$30 ; 97FB 00 00 00 00 00 00 E2 30  .......0
        .byte   $30,$30,$30,$30,$30,$30,$30,$30 ; 9803 30 30 30 30 30 30 30 30  00000000
        .byte   $30,$30,$30,$30,$30,$30,$30,$30 ; 980B 30 30 30 30 30 30 30 30  00000000
        .byte   $30,$E3,$00,$00,$00,$00,$00,$00 ; 9813 30 E3 00 00 00 00 00 00  0.......
        .byte   $00,$00,$00,$00,$00,$00,$E2,$30 ; 981B 00 00 00 00 00 00 E2 30  .......0
        .byte   $30,$30,$E4,$E5,$E5,$E6,$E4,$E5 ; 9823 30 30 E4 E5 E5 E6 E4 E5  00......
        .byte   $E5,$E7,$E8,$E9,$EA,$EB,$30,$30 ; 982B E5 E7 E8 E9 EA EB 30 30  ......00
        .byte   $30,$E3,$00,$00,$00,$00,$00,$00 ; 9833 30 E3 00 00 00 00 00 00  0.......
        .byte   $00,$00,$00,$00,$00,$00,$E2,$30 ; 983B 00 00 00 00 00 00 E2 30  .......0
        .byte   $30,$30,$EC,$00,$00,$ED,$EC,$00 ; 9843 30 30 EC 00 00 ED EC 00  00......
        .byte   $00,$EE,$EF,$00,$F1,$F2,$30,$30 ; 984B 00 EE EF 00 F1 F2 30 30  ......00
        .byte   $30,$E3,$00,$00,$00,$00,$00,$00 ; 9853 30 E3 00 00 00 00 00 00  0.......
        .byte   $00,$00,$00,$00,$00,$00,$E2,$30 ; 985B 00 00 00 00 00 00 E2 30  .......0
        .byte   $30,$30,$EC,$00,$00,$F3,$EC,$00 ; 9863 30 30 EC 00 00 F3 EC 00  00......
        .byte   $00,$F4,$F5,$00,$00,$ED,$30,$30 ; 986B 00 F4 F5 00 00 ED 30 30  ......00
        .byte   $30,$E3,$00,$00,$00,$00,$00,$00 ; 9873 30 E3 00 00 00 00 00 00  0.......
        .byte   $00,$00,$00,$00,$00,$00,$E2,$30 ; 987B 00 00 00 00 00 00 E2 30  .......0
        .byte   $30,$30,$EC,$00,$00,$ED,$EC,$00 ; 9883 30 30 EC 00 00 ED EC 00  00......
        .byte   $EE,$30,$EF,$00,$F6,$F7,$30,$30 ; 988B EE 30 EF 00 F6 F7 30 30  .0....00
        .byte   $30,$E3,$00,$00,$00,$00,$00,$00 ; 9893 30 E3 00 00 00 00 00 00  0.......
        .byte   $00,$00,$00,$00,$00,$00,$E2,$30 ; 989B 00 00 00 00 00 00 E2 30  .......0
        .byte   $30,$30,$F8,$F9,$F9,$F7,$F8,$F9 ; 98A3 30 30 F8 F9 F9 F7 F8 F9  00......
        .byte   $FA,$FB,$FC,$F9,$F4,$30,$30,$30 ; 98AB FA FB FC F9 F4 30 30 30  .....000
        .byte   $30,$E3,$00,$00,$00,$00,$00,$00 ; 98B3 30 E3 00 00 00 00 00 00  0.......
        .byte   $00,$00,$00,$00,$00,$00,$E2,$30 ; 98BB 00 00 00 00 00 00 E2 30  .......0
        .byte   $30,$30,$30,$30,$30,$30,$30,$30 ; 98C3 30 30 30 30 30 30 30 30  00000000
        .byte   $30,$30,$30,$30,$30,$30,$30,$30 ; 98CB 30 30 30 30 30 30 30 30  00000000
        .byte   $30,$E3,$00,$00,$00,$00,$00,$00 ; 98D3 30 E3 00 00 00 00 00 00  0.......
        .byte   $00,$00,$00,$00,$00,$00,$E2,$30 ; 98DB 00 00 00 00 00 00 E2 30  .......0
        .byte   $30,$30,$30,$30,$30,$30,$30,$30 ; 98E3 30 30 30 30 30 30 30 30  00000000
        .byte   $30,$30,$30,$30,$30,$30,$30,$30 ; 98EB 30 30 30 30 30 30 30 30  00000000
        .byte   $30,$E3,$00,$00,$00,$00,$00,$00 ; 98F3 30 E3 00 00 00 00 00 00  0.......
        .byte   $00,$00,$00,$00,$00,$00,$E2,$30 ; 98FB 00 00 00 00 00 00 E2 30  .......0
        .byte   $30,$30,$30,$30,$30,$30,$30,$30 ; 9903 30 30 30 30 30 30 30 30  00000000
        .byte   $30,$30,$30,$30,$30,$30,$30,$30 ; 990B 30 30 30 30 30 30 30 30  00000000
        .byte   $30,$E3,$00,$00,$00,$00,$00,$00 ; 9913 30 E3 00 00 00 00 00 00  0.......
        .byte   $00,$00,$00,$00,$00,$00,$E2,$30 ; 991B 00 00 00 00 00 00 E2 30  .......0
        .byte   $30,$30,$30,$30,$30,$30,$30,$30 ; 9923 30 30 30 30 30 30 30 30  00000000
        .byte   $30,$30,$30,$30,$30,$30,$30,$30 ; 992B 30 30 30 30 30 30 30 30  00000000
        .byte   $30,$E3,$00,$00,$00,$00,$00,$00 ; 9933 30 E3 00 00 00 00 00 00  0.......
        .byte   $00,$00,$00,$00,$00,$00,$FD,$FE ; 993B 00 00 00 00 00 00 FD FE  ........
        .byte   $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE ; 9943 FE FE FE FE FE FE FE FE  ........
        .byte   $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE ; 994B FE FE FE FE FE FE FE FE  ........
        .byte   $FE,$FF,$00,$00,$00,$00,$00,$00 ; 9953 FE FF 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; 995B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; 9963 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; 996B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; 9973 00 00 00 00 00 00 00 00  ........
; ----------------------------------------------------------------------------
L997B:
        lda     #$00                            ; 997B A9 00                    ..
        sta     $05BC                           ; 997D 8D BC 05                 ...
        jsr     L9A2C                           ; 9980 20 2C 9A                  ,.
        jsr     drawBPSLogo                     ; 9983 20 22 9C                  ".
        lda     #$88                            ; 9986 A9 88                    ..
        sta     PPUCTRL                         ; 9988 8D 00 20                 .. 
        inc     $05BC                           ; 998B EE BC 05                 ...
        jsr     L9A2C                           ; 998E 20 2C 9A                  ,.
        jsr     L9059                           ; 9991 20 59 90                  Y.
        lda     #$1E                            ; 9994 A9 1E                    ..
        sta     $2E                             ; 9996 85 2E                    ..
        jsr     L9CDD                           ; 9998 20 DD 9C                  ..
        lda     #$40                            ; 999B A9 40                    .@
        sta     $3F                             ; 999D 85 3F                    .?
        lda     #$02                            ; 999F A9 02                    ..
        sta     $40                             ; 99A1 85 40                    .@
L99A3:
        lda     #$40                            ; 99A3 A9 40                    .@
        sec                                     ; 99A5 38                       8
        sbc     $3F                             ; 99A6 E5 3F                    .?
        lsr     a                               ; 99A8 4A                       J
        lsr     a                               ; 99A9 4A                       J
        ora     #$B8                            ; 99AA 09 B8                    ..
        sta     SQ1_VOL                         ; 99AC 8D 00 40                 ..@
        sta     SQ2_VOL                         ; 99AF 8D 04 40                 ..@
        lda     $40                             ; 99B2 A5 40                    .@
        bne     L99A3                           ; 99B4 D0 ED                    ..
        ldy     #$07                            ; 99B6 A0 07                    ..
        sty     $3F                             ; 99B8 84 3F                    .?
L99BA:
        jsr     L9059                           ; 99BA 20 59 90                  Y.
        lda     $3F                             ; 99BD A5 3F                    .?
        asl     a                               ; 99BF 0A                       .
        ora     #$B0                            ; 99C0 09 B0                    ..
        sta     SQ1_VOL                         ; 99C2 8D 00 40                 ..@
        sta     SQ2_VOL                         ; 99C5 8D 04 40                 ..@
        lda     $3F                             ; 99C8 A5 3F                    .?
        bne     L99BA                           ; 99CA D0 EE                    ..
        ldy     #$0A                            ; 99CC A0 0A                    ..
        jsr     L902E                           ; 99CE 20 2E 90                  ..
        lda     #$30                            ; 99D1 A9 30                    .0
        sta     SQ1_VOL                         ; 99D3 8D 00 40                 ..@
        sta     SQ2_VOL                         ; 99D6 8D 04 40                 ..@
        ldy     #$5A                            ; 99D9 A0 5A                    .Z
        jsr     L902E                           ; 99DB 20 2E 90                  ..
        ldx     #$00                            ; 99DE A2 00                    ..
        jsr     L9A64                           ; 99E0 20 64 9A                  d.
        jsr     L9AE9                           ; 99E3 20 E9 9A                  ..
        jsr     L9A16                           ; 99E6 20 16 9A                  ..
        ldx     #$02                            ; 99E9 A2 02                    ..
        jsr     L9A64                           ; 99EB 20 64 9A                  d.
        ldy     #$22                            ; 99EE A0 22                    ."
        jsr     L902E                           ; 99F0 20 2E 90                  ..
        lda     #$00                            ; 99F3 A9 00                    ..
        sta     SQ1_VOL                         ; 99F5 8D 00 40                 ..@
        sta     SQ2_VOL                         ; 99F8 8D 04 40                 ..@
        lda     SND_CHN                         ; 99FB AD 15 40                 ..@
        and     #$E0                            ; 99FE 29 E0                    ).
        sta     SND_CHN                         ; 9A00 8D 15 40                 ..@
        ldy     #$64                            ; 9A03 A0 64                    .d
        jsr     L902E                           ; 9A05 20 2E 90                  ..
        lda     #$F0                            ; 9A08 A9 F0                    ..
        ldy     #$00                            ; 9A0A A0 00                    ..
L9A0C:
        sta     oamStaging,y                    ; 9A0C 99 00 02                 ...
        iny                                     ; 9A0F C8                       .
        bne     L9A0C                           ; 9A10 D0 FA                    ..
        jsr     L9CF2                           ; 9A12 20 F2 9C                  ..
        rts                                     ; 9A15 60                       `

; ----------------------------------------------------------------------------
L9A16:
        ldx     #$00                            ; 9A16 A2 00                    ..
L9A18:
        lda     L9A24,x                         ; 9A18 BD 24 9A                 .$.
        sta     SQ1_VOL,x                       ; 9A1B 9D 00 40                 ..@
        inx                                     ; 9A1E E8                       .
        cpx     #$08                            ; 9A1F E0 08                    ..
        bne     L9A18                           ; 9A21 D0 F5                    ..
        rts                                     ; 9A23 60                       `

; ----------------------------------------------------------------------------
L9A24:
        .byte   $8F,$00,$20,$40,$8F,$00,$20,$40 ; 9A24 8F 00 20 40 8F 00 20 40  .. @.. @
; ----------------------------------------------------------------------------
L9A2C:
        ldx     #$00                            ; 9A2C A2 00                    ..
        lda     $05BC                           ; 9A2E AD BC 05                 ...
        and     #$01                            ; 9A31 29 01                    ).
        asl     a                               ; 9A33 0A                       .
        asl     a                               ; 9A34 0A                       .
        asl     a                               ; 9A35 0A                       .
        tay                                     ; 9A36 A8                       .
L9A37:
        lda     L9A4C,y                         ; 9A37 B9 4C 9A                 .L.
        sta     SQ1_VOL,x                       ; 9A3A 9D 00 40                 ..@
        inx                                     ; 9A3D E8                       .
        iny                                     ; 9A3E C8                       .
        cpx     #$08                            ; 9A3F E0 08                    ..
        bne     L9A37                           ; 9A41 D0 F4                    ..
        lda     SND_CHN                         ; 9A43 AD 15 40                 ..@
        ora     #$03                            ; 9A46 09 03                    ..
        sta     SND_CHN                         ; 9A48 8D 15 40                 ..@
        rts                                     ; 9A4B 60                       `

; ----------------------------------------------------------------------------
L9A4C:
        clv                                     ; 9A4C B8                       .
        brk                                     ; 9A4D 00                       .
        .byte   $FF                             ; 9A4E FF                       .
        .byte   $03                             ; 9A4F 03                       .
        clv                                     ; 9A50 B8                       .
        brk                                     ; 9A51 00                       .
        .byte   $FC                             ; 9A52 FC                       .
        .byte   $03                             ; 9A53 03                       .
        sty     $AF                             ; 9A54 84 AF                    ..
        .byte   $FF,$03,$84,$AF,$FC,$03,$CC,$9B ; 9A56 FF 03 84 AF FC 03 CC 9B  ........
        .byte   $11,$9C                         ; 9A5E 11 9C                    ..
L9A60:
        .byte   $FB                             ; 9A60 FB                       .
L9A61:
        .byte   $10,$00,$03                     ; 9A61 10 00 03                 ...
L9A64:
        .byte   $BD,$5C,$9A,$85,$16,$BD,$5D,$9A ; 9A64 BD 5C 9A 85 16 BD 5D 9A  .\....].
        .byte   $85                             ; 9A6C 85                       .
; ----------------------------------------------------------------------------
        .byte   $17                             ; 9A6D 17                       .
        lda     L9A60,x                         ; 9A6E BD 60 9A                 .`.
        sta     $05C8                           ; 9A71 8D C8 05                 ...
        lda     L9A61,x                         ; 9A74 BD 61 9A                 .a.
        sta     $05C6                           ; 9A77 8D C6 05                 ...
        ldy     #$00                            ; 9A7A A0 00                    ..
        sty     $05BF                           ; 9A7C 8C BF 05                 ...
        lda     ($16),y                         ; 9A7F B1 16                    ..
        sta     $05BD                           ; 9A81 8D BD 05                 ...
        iny                                     ; 9A84 C8                       .
        lda     ($16),y                         ; 9A85 B1 16                    ..
        sta     $05BE                           ; 9A87 8D BE 05                 ...
        iny                                     ; 9A8A C8                       .
        lda     ($16),y                         ; 9A8B B1 16                    ..
        sta     $05C3                           ; 9A8D 8D C3 05                 ...
        iny                                     ; 9A90 C8                       .
        lda     ($16),y                         ; 9A91 B1 16                    ..
        sta     $05C4                           ; 9A93 8D C4 05                 ...
        iny                                     ; 9A96 C8                       .
        sty     $05C5                           ; 9A97 8C C5 05                 ...
L9A9A:
        lda     $05BF                           ; 9A9A AD BF 05                 ...
        beq     L9AA6                           ; 9A9D F0 07                    ..
        ldx     #$F0                            ; 9A9F A2 F0                    ..
        ldy     #$F0                            ; 9AA1 A0 F0                    ..
        jsr     L9AF6                           ; 9AA3 20 F6 9A                  ..
L9AA6:
        ldy     $05C5                           ; 9AA6 AC C5 05                 ...
        lda     ($16),y                         ; 9AA9 B1 16                    ..
        cmp     #$FF                            ; 9AAB C9 FF                    ..
        beq     L9AE9                           ; 9AAD F0 3A                    .:
        sta     tmp14                           ; 9AAF 85 14                    ..
        iny                                     ; 9AB1 C8                       .
        lda     ($16),y                         ; 9AB2 B1 16                    ..
        sta     tmp15                           ; 9AB4 85 15                    ..
        iny                                     ; 9AB6 C8                       .
        lda     ($16),y                         ; 9AB7 B1 16                    ..
        sta     $05C0                           ; 9AB9 8D C0 05                 ...
        iny                                     ; 9ABC C8                       .
        lda     ($16),y                         ; 9ABD B1 16                    ..
        sta     $05BF                           ; 9ABF 8D BF 05                 ...
        ldx     $05BD                           ; 9AC2 AE BD 05                 ...
        ldy     $05BE                           ; 9AC5 AC BE 05                 ...
        jsr     L9AF6                           ; 9AC8 20 F6 9A                  ..
        ldy     $05C0                           ; 9ACB AC C0 05                 ...
        jsr     L9B31                           ; 9ACE 20 31 9B                  1.
        lda     $05BE                           ; 9AD1 AD BE 05                 ...
        clc                                     ; 9AD4 18                       .
        adc     $05C8                           ; 9AD5 6D C8 05                 m..
        sta     $05BE                           ; 9AD8 8D BE 05                 ...
        lda     $05C5                           ; 9ADB AD C5 05                 ...
        clc                                     ; 9ADE 18                       .
        adc     #$04                            ; 9ADF 69 04                    i.
        sta     $05C5                           ; 9AE1 8D C5 05                 ...
        dec     $05C6                           ; 9AE4 CE C6 05                 ...
        bne     L9A9A                           ; 9AE7 D0 B1                    ..
L9AE9:
        ldx     #$F0                            ; 9AE9 A2 F0                    ..
        ldy     #$F0                            ; 9AEB A0 F0                    ..
        jsr     L9059                           ; 9AED 20 59 90                  Y.
        jsr     L9AF6                           ; 9AF0 20 F6 9A                  ..
        jmp     L9059                           ; 9AF3 4C 59 90                 LY.

; ----------------------------------------------------------------------------
L9AF6:
        stx     $05C1                           ; 9AF6 8E C1 05                 ...
        sty     $05C2                           ; 9AF9 8C C2 05                 ...
        ldy     #$00                            ; 9AFC A0 00                    ..
L9AFE:
        lda     (tmp14),y                       ; 9AFE B1 14                    ..
        cmp     #$80                            ; 9B00 C9 80                    ..
        beq     L9B30                           ; 9B02 F0 2C                    .,
        asl     a                               ; 9B04 0A                       .
        asl     a                               ; 9B05 0A                       .
        tax                                     ; 9B06 AA                       .
        lda     $05C2                           ; 9B07 AD C2 05                 ...
        cmp     #$F0                            ; 9B0A C9 F0                    ..
        bne     L9B19                           ; 9B0C D0 0B                    ..
        sta     oamStaging,x                    ; 9B0E 9D 00 02                 ...
        sta     oamStaging+3,x                  ; 9B11 9D 03 02                 ...
        iny                                     ; 9B14 C8                       .
        iny                                     ; 9B15 C8                       .
L9B16:
        iny                                     ; 9B16 C8                       .
        bne     L9AFE                           ; 9B17 D0 E5                    ..
L9B19:
        iny                                     ; 9B19 C8                       .
        lda     $05C1                           ; 9B1A AD C1 05                 ...
        clc                                     ; 9B1D 18                       .
        adc     (tmp14),y                       ; 9B1E 71 14                    q.
        sta     oamStaging+3,x                  ; 9B20 9D 03 02                 ...
        iny                                     ; 9B23 C8                       .
        lda     $05C2                           ; 9B24 AD C2 05                 ...
        clc                                     ; 9B27 18                       .
        adc     (tmp14),y                       ; 9B28 71 14                    q.
        sta     oamStaging,x                    ; 9B2A 9D 00 02                 ...
        jmp     L9B16                           ; 9B2D 4C 16 9B                 L..

; ----------------------------------------------------------------------------
L9B30:
        rts                                     ; 9B30 60                       `

; ----------------------------------------------------------------------------
L9B31:
        ldx     #$00                            ; 9B31 A2 00                    ..
L9B33:
        nop                                     ; 9B33 EA                       .
        dex                                     ; 9B34 CA                       .
        bne     L9B33                           ; 9B35 D0 FC                    ..
        dey                                     ; 9B37 88                       .
        cpy     #$FF                            ; 9B38 C0 FF                    ..
        bne     L9B33                           ; 9B3A D0 F7                    ..
        rts                                     ; 9B3C 60                       `

; ----------------------------------------------------------------------------
introScreenSprites:
        .byte   $F0,$D6,$03,$F0,$F0,$D7,$03,$F0 ; 9B3D F0 D6 03 F0 F0 D7 03 F0  ........
        .byte   $F0,$D8,$03,$F0,$F0,$D9,$03,$F0 ; 9B45 F0 D8 03 F0 F0 D9 03 F0  ........
        .byte   $F0,$DA,$03,$F0,$F0,$DB,$03,$F0 ; 9B4D F0 DA 03 F0 F0 DB 03 F0  ........
        .byte   $F0,$DC,$03,$F0,$F0,$DD,$03,$F0 ; 9B55 F0 DC 03 F0 F0 DD 03 F0  ........
        .byte   $F0,$D5,$23,$F0,$F0,$D5,$23,$F0 ; 9B5D F0 D5 23 F0 F0 D5 23 F0  ..#...#.
        .byte   $F0,$D5,$23,$F0,$F0,$D5,$23,$F0 ; 9B65 F0 D5 23 F0 F0 D5 23 F0  ..#...#.
        .byte   $F0,$D5,$23,$F0,$F0,$D5,$23,$F0 ; 9B6D F0 D5 23 F0 F0 D5 23 F0  ..#...#.
        .byte   $F0,$D5,$23,$F0,$F0,$D5,$23,$F0 ; 9B75 F0 D5 23 F0 F0 D5 23 F0  ..#...#.
        .byte   $F0,$D5,$23,$F0,$F0,$D5,$23,$F0 ; 9B7D F0 D5 23 F0 F0 D5 23 F0  ..#...#.
        .byte   $F0,$D5,$23,$F0,$F0,$D5,$23,$F0 ; 9B85 F0 D5 23 F0 F0 D5 23 F0  ..#...#.
; above sprite table stops here
unknownTable04:
        .byte   $34,$00,$00,$35,$08,$02,$36,$10 ; 9B8D 34 00 00 35 08 02 36 10  4..5..6.
        .byte   $04,$37,$18,$06,$38,$20,$08,$39 ; 9B95 04 37 18 06 38 20 08 39  .7..8 .9
        .byte   $28,$0A,$3A,$30,$0C,$3B,$38,$0E ; 9B9D 28 0A 3A 30 0C 3B 38 0E  (.:0.;8.
        .byte   $3C,$40,$10,$3D,$48,$12,$3E,$50 ; 9BA5 3C 40 10 3D 48 12 3E 50  <@.=H.>P
        .byte   $14,$3F,$58,$16,$80,$2C,$00,$00 ; 9BAD 14 3F 58 16 80 2C 00 00  .?X..,..
        .byte   $2D,$08,$00,$2E,$00,$08,$2F,$08 ; 9BB5 2D 08 00 2E 00 08 2F 08  -...../.
        .byte   $08,$80,$30,$00,$00,$31,$08,$00 ; 9BBD 08 80 30 00 00 31 08 00  ..0..1..
        .byte   $32,$00,$08,$33,$08,$08,$80,$50 ; 9BC5 32 00 08 33 08 08 80 50  2..3...P
        .byte   $90,$50,$40,$8D,$9B,$14,$01,$8D ; 9BCD 90 50 40 8D 9B 14 01 8D  .P@.....
        .byte   $9B,$14,$01,$8D,$9B,$14,$01,$8D ; 9BD5 9B 14 01 8D 9B 14 01 8D  ........
        .byte   $9B,$14,$01,$8D,$9B,$14,$01,$8D ; 9BDD 9B 14 01 8D 9B 14 01 8D  ........
        .byte   $9B,$14,$01,$8D,$9B,$14,$01,$8D ; 9BE5 9B 14 01 8D 9B 14 01 8D  ........
        .byte   $9B,$14,$01,$8D,$9B,$14,$01,$8D ; 9BED 9B 14 01 8D 9B 14 01 8D  ........
        .byte   $9B,$14,$01,$8D,$9B,$14,$01,$8D ; 9BF5 9B 14 01 8D 9B 14 01 8D  ........
        .byte   $9B,$14,$01,$8D,$9B,$14,$01,$8D ; 9BFD 9B 14 01 8D 9B 14 01 8D  ........
        .byte   $9B,$14,$01,$8D,$9B,$14,$01,$8D ; 9C05 9B 14 01 8D 9B 14 01 8D  ........
        .byte   $9B,$00,$00,$FF,$A5,$61,$A5,$61 ; 9C0D 9B 00 00 FF A5 61 A5 61  .....a.a
        .byte   $B2,$9B,$64,$01,$BF,$9B,$FF,$01 ; 9C15 B2 9B 64 01 BF 9B FF 01  ..d.....
        .byte   $B2,$9B,$8C,$00,$FF             ; 9C1D B2 9B 8C 00 FF           .....
; ----------------------------------------------------------------------------
drawBPSLogo:
        lda     #$20                            ; 9C22 A9 20                    . 
        sta     PPUADDR                         ; 9C24 8D 06 20                 .. 
        lda     #$00                            ; 9C27 A9 00                    ..
        sta     PPUADDR                         ; 9C29 8D 06 20                 .. 
        tax                                     ; 9C2C AA                       .
        tay                                     ; 9C2D A8                       .
@blankLoop:
        sta     PPUDATA                         ; 9C2E 8D 07 20                 .. 
        iny                                     ; 9C31 C8                       .
        bne     @blankLoop                      ; 9C32 D0 FA                    ..
        inx                                     ; 9C34 E8                       .
        cpx     #$04                            ; 9C35 E0 04                    ..
        bcc     @blankLoop                      ; 9C37 90 F5                    ..
        lda     #<unknownTable03                ; 9C39 A9 7B                    .{
        sta     tmp14                           ; 9C3B 85 14                    ..
        lda     #>unknownTable03                ; 9C3D A9 97                    ..
        sta     tmp15                           ; 9C3F 85 15                    ..
        ldx     #$21                            ; 9C41 A2 21                    .!
        stx     PPUADDR                         ; 9C43 8E 06 20                 .. 
        ldx     #$00                            ; 9C46 A2 00                    ..
        stx     PPUADDR                         ; 9C48 8E 06 20                 .. 
        inx                                     ; 9C4B E8                       .
@sendByte:
        lda     (tmp14),y                       ; 9C4C B1 14                    ..
        sta     PPUDATA                         ; 9C4E 8D 07 20                 .. 
        iny                                     ; 9C51 C8                       .
        bne     @sendByte                       ; 9C52 D0 F8                    ..
        inc     tmp15                           ; 9C54 E6 15                    ..
        dex                                     ; 9C56 CA                       .
        bpl     @sendByte                       ; 9C57 10 F3                    ..
        ldx     #$4F                            ; 9C59 A2 4F                    .O
@spriteLoop:
        lda     introScreenSprites,x            ; 9C5B BD 3D 9B                 .=.
        sta     oamStaging+176,x                ; 9C5E 9D B0 02                 ...
        dex                                     ; 9C61 CA                       .
        bpl     @spriteLoop                     ; 9C62 10 F7                    ..
@vblankWait:
        lda     PPUSTATUS                       ; 9C64 AD 02 20                 .. 
        bpl     @vblankWait                     ; 9C67 10 FB                    ..
        lda     #$3F                            ; 9C69 A9 3F                    .?
        sta     PPUADDR                         ; 9C6B 8D 06 20                 .. 
        inx                                     ; 9C6E E8                       .
        stx     PPUADDR                         ; 9C6F 8E 06 20                 .. 
@paletteLoop:
        lda     introScreenPalette,x            ; 9C72 BD 86 9C                 ...
        sta     PPUDATA                         ; 9C75 8D 07 20                 .. 
        inx                                     ; 9C78 E8                       .
        cpx     #$20                            ; 9C79 E0 20                    . 
        bcc     @paletteLoop                    ; 9C7B 90 F5                    ..
        ldy     #$00                            ; 9C7D A0 00                    ..
        sty     PPUSCROLL                       ; 9C7F 8C 05 20                 .. 
        sty     PPUSCROLL                       ; 9C82 8C 05 20                 .. 
        rts                                     ; 9C85 60                       `

; ----------------------------------------------------------------------------
introScreenPalette:
        .byte   $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F ; 9C86 0F 0F 0F 0F 0F 0F 0F 0F  ........
        .byte   $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F ; 9C8E 0F 0F 0F 0F 0F 0F 0F 0F  ........
        .byte   $0F,$0F,$30,$00,$0F,$30,$27,$0F ; 9C96 0F 0F 30 00 0F 30 27 0F  ..0..0'.
        .byte   $0F,$27,$0F,$30,$0F,$2C,$3C,$30 ; 9C9E 0F 27 0F 30 0F 2C 3C 30  .'.0.,<0
; above palette table ends here
unknownTable05:
        .byte   $03,$0C,$08,$03,$1C,$08,$01,$0C ; 9CA6 03 0C 08 03 1C 08 01 0C  ........
        .byte   $08,$02,$0C,$08,$03,$2C,$08,$02 ; 9CAE 08 02 0C 08 03 2C 08 02  .....,..
        .byte   $01,$08,$03,$3C,$08,$01,$1C,$01 ; 9CB6 01 08 03 3C 08 01 1C 01  ...<....
        .byte   $FF                             ; 9CBE FF                       .
L9CBF:
        .byte   $03,$1C,$05,$02,$0C,$05,$01,$0C ; 9CBF 03 1C 05 02 0C 05 01 0C  ........
        .byte   $05,$03,$0C,$05,$02,$0F,$05,$01 ; 9CC7 05 03 0C 05 02 0F 05 01  ........
        .byte   $0F,$05,$03,$0F,$14,$FF         ; 9CCF 0F 05 03 0F 14 FF        ......
; ----------------------------------------------------------------------------
; has at least one palette table
addressTable01:
        .addr   introScreenPalette              ; 9CD5 86 9C                    ..
        .addr   unknownTable05                  ; 9CD7 A6 9C                    ..
        .addr   introScreenPalette              ; 9CD9 86 9C                    ..
        .addr   L9CBF                           ; 9CDB BF 9C                    ..
; ----------------------------------------------------------------------------
L9CDD:
        ldy     #$00                            ; 9CDD A0 00                    ..
L9CDF:
        lda     introScreenPalette,y            ; 9CDF B9 86 9C                 ...
        sta     $049A,y                         ; 9CE2 99 9A 04                 ...
        iny                                     ; 9CE5 C8                       .
        cpy     #$10                            ; 9CE6 C0 10                    ..
        bcc     L9CDF                           ; 9CE8 90 F5                    ..
L9CEA:
        ldx     #$00                            ; 9CEA A2 00                    ..
        stx     $53                             ; 9CEC 86 53                    .S
        inx                                     ; 9CEE E8                       .
        stx     $54                             ; 9CEF 86 54                    .T
        rts                                     ; 9CF1 60                       `

; ----------------------------------------------------------------------------
L9CF2:
        jsr     L9CEA                           ; 9CF2 20 EA 9C                  ..
        lda     #$06                            ; 9CF5 A9 06                    ..
        sta     $40                             ; 9CF7 85 40                    .@
L9CF9:
        lda     $40                             ; 9CF9 A5 40                    .@
        bne     L9CF9                           ; 9CFB D0 FC                    ..
        rts                                     ; 9CFD 60                       `

; ----------------------------------------------------------------------------
L9CFE:
        ldx     $40                             ; 9CFE A6 40                    .@
        beq     L9D45                           ; 9D00 F0 43                    .C
        ldy     $53                             ; 9D02 A4 53                    .S
        bne     L9D10                           ; 9D04 D0 0A                    ..
        lda     addressTable01,x                ; 9D06 BD D5 9C                 ...
        sta     $20                             ; 9D09 85 20                    . 
        lda     addressTable01+1,x              ; 9D0B BD D6 9C                 ...
        sta     $21                             ; 9D0E 85 21                    .!
L9D10:
        dec     $54                             ; 9D10 C6 54                    .T
        bne     L9D45                           ; 9D12 D0 31                    .1
        lda     ($20),y                         ; 9D14 B1 20                    . 
        sta     $55                             ; 9D16 85 55                    .U
        bmi     L9D46                           ; 9D18 30 2C                    0,
        inc     $53                             ; 9D1A E6 53                    .S
        iny                                     ; 9D1C C8                       .
        lda     ($20),y                         ; 9D1D B1 20                    . 
        ldy     $55                             ; 9D1F A4 55                    .U
        sta     $049A,y                         ; 9D21 99 9A 04                 ...
        lda     #$3F                            ; 9D24 A9 3F                    .?
        sta     PPUADDR                         ; 9D26 8D 06 20                 .. 
        lda     #$00                            ; 9D29 A9 00                    ..
        sta     PPUADDR                         ; 9D2B 8D 06 20                 .. 
        ldy     #$00                            ; 9D2E A0 00                    ..
L9D30:
        lda     $049A,y                         ; 9D30 B9 9A 04                 ...
        sta     PPUDATA                         ; 9D33 8D 07 20                 .. 
        iny                                     ; 9D36 C8                       .
        cpy     #$10                            ; 9D37 C0 10                    ..
        bcc     L9D30                           ; 9D39 90 F5                    ..
        inc     $53                             ; 9D3B E6 53                    .S
        ldy     $53                             ; 9D3D A4 53                    .S
        lda     ($20),y                         ; 9D3F B1 20                    . 
        sta     $54                             ; 9D41 85 54                    .T
        inc     $53                             ; 9D43 E6 53                    .S
L9D45:
        rts                                     ; 9D45 60                       `

; ----------------------------------------------------------------------------
L9D46:
        ldy     #$00                            ; 9D46 A0 00                    ..
        sty     $53                             ; 9D48 84 53                    .S
        sty     $40                             ; 9D4A 84 40                    .@
        iny                                     ; 9D4C C8                       .
        sty     $54                             ; 9D4D 84 54                    .T
        rts                                     ; 9D4F 60                       `

; ----------------------------------------------------------------------------
unknownTable02:
        .byte   $00,$F0,$00,$F4                 ; 9D50 00 F0 00 F4              ....
; ----------------------------------------------------------------------------
L9D54:
        sta     $061C                           ; 9D54 8D 1C 06                 ...
        ldy     #$00                            ; 9D57 A0 00                    ..
        sty     $0618                           ; 9D59 8C 18 06                 ...
        sty     $0619                           ; 9D5C 8C 19 06                 ...
        jsr     L8628                           ; 9D5F 20 28 86                  (.
        rts                                     ; 9D62 60                       `

; ----------------------------------------------------------------------------
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9D63 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9D6B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9D73 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9D7B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9D83 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9D8B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9D93 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9D9B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9DA3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9DAB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9DB3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9DBB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9DC3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$0D,$1C,$0F,$0E ; 9DCB 32 32 32 32 0D 1C 0F 0E  2222....
        .byte   $13,$1E,$1D,$32,$32,$32,$32,$32 ; 9DD3 13 1E 1D 32 32 32 32 32  ...22222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9DDB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9DE3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9DEB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9DF3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9DFB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9E03 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9E0B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9E13 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9E1B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9E23 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9E2B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9E33 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9E3B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$1A,$1C,$19,$0E,$1F ; 9E43 32 32 32 1A 1C 19 0E 1F  222.....
        .byte   $0D,$0F,$0E,$32,$0C,$23,$32,$23 ; 9E4B 0D 0F 0E 32 0C 23 32 23  ...2.#2#
        .byte   $0B,$1D,$1F,$0B,$15,$13,$32,$18 ; 9E53 0B 1D 1F 0B 15 13 32 18  ......2.
        .byte   $0B,$11,$19,$1D,$12,$13,$32,$32 ; 9E5B 0B 11 19 1D 12 13 32 32  ......22
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9E63 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9E6B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9E73 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9E7B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$1A,$1C,$19,$11,$1C ; 9E83 32 32 32 1A 1C 19 11 1C  222.....
        .byte   $0B,$17,$17,$0F,$0E,$32,$0C,$23 ; 9E8B 0B 17 17 0F 0E 32 0C 23  .....2.#
        .byte   $32,$0C,$19,$0C,$32,$1C,$1F,$1E ; 9E93 32 0C 19 0C 32 1C 1F 1E  2...2...
        .byte   $12,$0F,$1C,$10,$19,$1C,$0E,$32 ; 9E9B 12 0F 1C 10 19 1C 0E 32  .......2
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9EA3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9EAB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9EB3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9EBB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$11,$1C,$0B,$1A,$12 ; 9EC3 32 32 32 11 1C 0B 1A 12  222.....
        .byte   $13,$0D,$1D,$32,$0C,$23,$32,$12 ; 9ECB 13 0D 1D 32 0C 23 32 12  ...2.#2.
        .byte   $0B,$18,$1D,$32,$14,$0B,$18,$1D ; 9ED3 0B 18 1D 32 14 0B 18 1D  ...2....
        .byte   $1D,$0F,$18,$32,$32,$32,$32,$32 ; 9EDB 1D 0F 18 32 32 32 32 32  ...22222
        .byte   $32,$32,$32,$0B,$18,$0E,$32,$15 ; 9EE3 32 32 32 0B 18 0E 32 15  222...2.
        .byte   $0B,$24,$1F,$23,$1F,$15,$13,$32 ; 9EEB 0B 24 1F 23 1F 15 13 32  .$.#...2
        .byte   $1E,$0B,$15,$13,$17,$19,$1E,$19 ; 9EF3 1E 0B 15 13 17 19 1E 19  ........
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9EFB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9F03 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9F0B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9F13 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9F1B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$17,$1F,$1D,$13,$0D ; 9F23 32 32 32 17 1F 1D 13 0D  222.....
        .byte   $32,$0C,$23,$32,$32,$32,$32,$32 ; 9F2B 32 0C 23 32 32 32 32 32  2.#22222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9F33 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9F3B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$12,$13,$1D,$0B,$1D ; 9F43 32 32 32 12 13 1D 0B 1D  222.....
        .byte   $12,$13,$32,$24,$0F,$1C,$19,$32 ; 9F4B 12 13 32 24 0F 1C 19 32  ..2$...2
        .byte   $23,$19,$1E,$1D,$1F,$17,$19,$1E ; 9F53 23 19 1E 1D 1F 17 19 1E  #.......
        .byte   $19,$32,$0B,$18,$0E,$32,$32,$32 ; 9F5B 19 32 0B 18 0E 32 32 32  .2...222
        .byte   $32,$32,$32,$12,$13,$1C,$19,$1D ; 9F63 32 32 32 12 13 1C 19 1D  222.....
        .byte   $12,$13,$32,$1E,$0B,$11,$1F,$0D ; 9F6B 12 13 32 1E 0B 11 1F 0D  ..2.....
        .byte   $12,$13,$32,$32,$32,$32,$32,$32 ; 9F73 12 13 32 32 32 32 32 32  ..222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9F7B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9F83 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9F8B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9F93 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9F9B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$1D,$19,$1F,$18,$0E ; 9FA3 32 32 32 1D 19 1F 18 0E  222.....
        .byte   $32,$0C,$23,$32,$12,$13,$1C,$19 ; 9FAB 32 0C 23 32 12 13 1C 19  2.#2....
        .byte   $1D,$12,$13,$32,$1D,$1F,$24,$1F ; 9FB3 1D 12 13 32 1D 1F 24 1F  ...2..$.
        .byte   $15,$13,$32,$32,$32,$32,$32,$32 ; 9FBB 15 13 32 32 32 32 32 32  ..222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9FC3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9FCB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9FD3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9FDB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9FE3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9FEB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9FF3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; 9FFB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A003 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A00B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A013 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A01B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$1D,$1A ; A023 32 32 32 32 32 32 1D 1A  222222..
        .byte   $0F,$0D,$13,$0B,$16,$32,$1E,$12 ; A02B 0F 0D 13 0B 16 32 1E 12  .....2..
        .byte   $0B,$18,$15,$1D,$32,$1E,$19,$32 ; A033 0B 18 15 1D 32 1E 19 32  ....2..2
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A03B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A043 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A04B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A053 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A05B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$1E,$0B ; A063 32 32 32 32 32 32 1E 0B  222222..
        .byte   $15,$0B,$12,$13,$1C,$19,$32,$15 ; A06B 15 0B 12 13 1C 19 32 15  ......2.
        .byte   $19,$1D,$0F,$15,$13,$32,$32,$32 ; A073 19 1D 0F 15 13 32 32 32  .....222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A07B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$1E,$12 ; A083 32 32 32 32 32 32 1E 12  222222..
        .byte   $19,$17,$0B,$1D,$32,$19,$1E,$0B ; A08B 19 17 0B 1D 32 19 1E 0B  ....2...
        .byte   $15,$0F,$32,$32,$32,$32,$32,$32 ; A093 15 0F 32 32 32 32 32 32  ..222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A09B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$0B,$18 ; A0A3 32 32 32 32 32 32 0B 18  222222..
        .byte   $0E,$32,$19,$1F,$1C,$32,$0C,$1A ; A0AB 0E 32 19 1F 1C 32 0C 1A  .2...2..
        .byte   $1D,$32,$1D,$1E,$0B,$10,$10,$32 ; A0B3 1D 32 1D 1E 0B 10 10 32  .2.....2
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A0BB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A0C3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A0CB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A0D3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A0DB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A0E3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A0EB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A0F3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A0FB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A103 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A10B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A113 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A11B 32 32 32 32 32 32 32 32  22222222
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; A123 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; A12B FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; A133 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; A13B FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; A143 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; A14B FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; A153 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; A15B FF FF FF FF FF FF FF FF  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A163 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A16B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A173 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A17B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A183 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A18B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A193 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A19B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A1A3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A1AB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A1B3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A1BB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A1C3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A1CB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A1D3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A1DB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A1E3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A1EB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A1F3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A1FB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A203 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A20B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A213 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A21B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A223 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A22B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A233 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A23B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A243 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A24B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A253 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A25B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A263 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$80 ; A26B 00 00 00 00 00 00 00 80  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A273 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A27B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A283 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$81,$82 ; A28B 00 00 00 00 00 00 81 82  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A293 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A29B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A2A3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$84,$85 ; A2AB 00 00 00 00 00 00 84 85  ........
        .byte   $E2,$00,$00,$00,$00,$00,$00,$00 ; A2B3 E2 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A2BB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A2C3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$87,$88 ; A2CB 00 00 00 00 00 00 87 88  ........
        .byte   $E1,$00,$00,$00,$00,$00,$00,$00 ; A2D3 E1 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A2DB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A2E3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$8A,$9C ; A2EB 00 00 00 00 00 00 8A 9C  ........
        .byte   $8C,$00,$00,$00,$00,$00,$00,$00 ; A2F3 8C 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A2FB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A303 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$A1,$A2 ; A30B 00 00 00 00 00 00 A1 A2  ........
        .byte   $A3,$00,$00,$00,$00,$00,$00,$00 ; A313 A3 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A31B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$80,$00,$00,$00,$00 ; A323 00 00 00 80 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$8D,$A2 ; A32B 00 00 00 00 00 00 8D A2  ........
        .byte   $A3,$00,$00,$00,$00,$00,$00,$00 ; A333 A3 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A33B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$81,$82,$00,$00,$00,$00 ; A343 00 00 81 82 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$96,$97 ; A34B 00 00 00 00 00 00 96 97  ........
        .byte   $71,$00,$00,$00,$00,$00,$00,$00 ; A353 71 00 00 00 00 00 00 00  q.......
        .byte   $00,$00,$92,$93,$00,$00,$00,$00 ; A35B 00 00 92 93 00 00 00 00  ........
        .byte   $00,$00,$90,$91,$E2,$00,$00,$00 ; A363 00 00 90 91 E2 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$8D,$A2 ; A36B 00 00 00 00 00 00 8D A2  ........
        .byte   $A3,$00,$00,$00,$00,$00,$00,$00 ; A373 A3 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$DA,$DB,$00,$00,$00,$00 ; A37B 00 00 DA DB 00 00 00 00  ........
        .byte   $E7,$E5,$87,$A8,$E1,$E5,$00,$E7 ; A383 E7 E5 87 A8 E1 E5 00 E7  ........
        .byte   $E7,$00,$92,$93,$E7,$E7,$B2,$B3 ; A38B E7 00 92 93 E7 E7 B2 B3  ........
        .byte   $B4,$E6,$00,$E6,$E7,$7C,$00,$E7 ; A393 B4 E6 00 E6 E7 7C 00 E7  .....|..
        .byte   $E5,$D6,$D7,$D8,$D9,$E7,$7C,$E7 ; A39B E5 D6 D7 D8 D9 E7 7C E7  ......|.
        .byte   $74,$75,$8A,$8B,$8C,$00,$DF,$98 ; A3A3 74 75 8A 8B 8C 00 DF 98  tu......
        .byte   $E5,$E5,$DA,$DB,$00,$E6,$8D,$A2 ; A3AB E5 E5 DA DB 00 E6 8D A2  ........
        .byte   $A3,$E5,$E7,$7C,$F3,$E7,$78,$79 ; A3B3 A3 E5 E7 7C F3 E7 78 79  ...|..xy
        .byte   $CF,$D0,$D1,$D3,$D4,$D5,$78,$79 ; A3BB CF D0 D1 D3 D4 D5 78 79  ......xy
        .byte   $76,$77,$8D,$8E,$8F,$00,$72,$73 ; A3C3 76 77 8D 8E 8F 00 72 73  vw....rs
        .byte   $E5,$D6,$D7,$D8,$D9,$E5,$C0,$C1 ; A3CB E5 D6 D7 D8 D9 E5 C0 C1  ........
        .byte   $C2,$00,$78,$79,$92,$93,$7A,$7B ; A3D3 C2 00 78 79 92 93 7A 7B  ..xy..z{
        .byte   $E5,$CB,$CC,$CD,$CE,$E6,$7A,$00 ; A3DB E5 CB CC CD CE E6 7A 00  ......z.
        .byte   $00,$F8,$8D,$8E,$8F,$00,$F1,$F2 ; A3E3 00 F8 8D 8E 8F 00 F1 F2  ........
        .byte   $CF,$D0,$D1,$D3,$D4,$DD,$C0,$C1 ; A3EB CF D0 D1 D3 D4 DD C0 C1  ........
        .byte   $C2,$00,$F1,$DE,$EE,$EF,$DE,$F2 ; A3F3 C2 00 F1 DE EE EF DE F2  ........
        .byte   $00,$8A,$8B,$8B,$8C,$00,$F1,$F2 ; A3FB 00 8A 8B 8B 8C 00 F1 F2  ........
        .byte   $DE,$F2,$96,$97,$71,$E5,$F3,$F4 ; A403 DE F2 96 97 71 E5 F3 F4  ....q...
        .byte   $00,$CB,$CC,$CD,$CE,$00,$C4,$C5 ; A40B 00 CB CC CD CE 00 C4 C5  ........
        .byte   $C6,$00,$F3,$FD,$FE,$FF,$DC,$F4 ; A413 C6 00 F3 FD FE FF DC F4  ........
        .byte   $00,$8D,$8E,$8E,$8F,$00,$F3,$F4 ; A41B 00 8D 8E 8E 8F 00 F3 F4  ........
        .byte   $F3,$F4,$8D,$8E,$8F,$00,$F5,$F6 ; A423 F3 F4 8D 8E 8F 00 F5 F6  ........
        .byte   $00,$8A,$9C,$9C,$8C,$E5,$C9,$C9 ; A42B 00 8A 9C 9C 8C E5 C9 C9  ........
        .byte   $CA,$00,$E8,$E9,$EA,$EB,$EC,$ED ; A433 CA 00 E8 E9 EA EB EC ED  ........
        .byte   $00,$AC,$BC,$BC,$AE,$00,$F5,$F6 ; A43B 00 AC BC BC AE 00 F5 F6  ........
        .byte   $F8,$F8,$A4,$A5,$A6,$00,$7A,$F8 ; A443 F8 F8 A4 A5 A6 00 7A F8  ......z.
        .byte   $00,$B2,$B3,$B3,$B4,$00,$C9,$C9 ; A44B 00 B2 B3 B3 B4 00 C9 C9  ........
        .byte   $CA,$00,$F8,$F9,$FA,$FB,$FC,$F8 ; A453 CA 00 F8 F9 FA FB FC F8  ........
        .byte   $00,$B5,$C3,$C3,$B7,$00,$F7,$F8 ; A45B 00 B5 C3 C3 B7 00 F7 F8  ........
        .byte   $00,$F8,$AC,$AD,$AE,$00,$00,$00 ; A463 00 F8 AC AD AE 00 00 00  ........
        .byte   $E5,$8A,$9C,$9C,$8C,$00,$B3,$B3 ; A46B E5 8A 9C 9C 8C 00 B3 B3  ........
        .byte   $B3,$00,$00,$8A,$9C,$9C,$8C,$00 ; A473 B3 00 00 8A 9C 9C 8C 00  ........
        .byte   $00,$AC,$BC,$BC,$AE,$00,$F3,$F3 ; A47B 00 AC BC BC AE 00 F3 F3  ........
        .byte   $00,$00,$B5,$B6,$B7,$00,$00,$00 ; A483 00 00 B5 B6 B7 00 00 00  ........
        .byte   $00,$96,$97,$97,$71,$00,$A5,$A5 ; A48B 00 96 97 97 71 00 A5 A5  ....q...
        .byte   $A5,$00,$00,$B2,$B3,$B3,$B4,$E5 ; A493 A5 00 00 B2 B3 B3 B4 E5  ........
        .byte   $00,$B5,$C3,$C3,$B7,$00,$E5,$00 ; A49B 00 B5 C3 C3 B7 00 E5 00  ........
        .byte   $E4,$E4,$E4,$E4,$E4,$E4,$E4,$E4 ; A4A3 E4 E4 E4 E4 E4 E4 E4 E4  ........
        .byte   $E4,$E4,$E4,$E4,$E4,$E4,$E4,$E4 ; A4AB E4 E4 E4 E4 E4 E4 E4 E4  ........
        .byte   $E4,$E4,$E4,$E4,$E4,$E4,$E4,$E4 ; A4B3 E4 E4 E4 E4 E4 E4 E4 E4  ........
        .byte   $E4,$E4,$E4,$E4,$E4,$E4,$E4,$E4 ; A4BB E4 E4 E4 E4 E4 E4 E4 E4  ........
        .byte   $E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3 ; A4C3 E3 E3 E3 E3 E3 E3 E3 E3  ........
        .byte   $E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3 ; A4CB E3 E3 E3 E3 E3 E3 E3 E3  ........
        .byte   $E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3 ; A4D3 E3 E3 E3 E3 E3 E3 E3 E3  ........
        .byte   $E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3 ; A4DB E3 E3 E3 E3 E3 E3 E3 E3  ........
        .byte   $E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3 ; A4E3 E3 E3 E3 E3 E3 E3 E3 E3  ........
        .byte   $E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3 ; A4EB E3 E3 E3 E3 E3 E3 E3 E3  ........
        .byte   $E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3 ; A4F3 E3 E3 E3 E3 E3 E3 E3 E3  ........
        .byte   $E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3 ; A4FB E3 E3 E3 E3 E3 E3 E3 E3  ........
        .byte   $E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3 ; A503 E3 E3 E3 E3 E3 E3 E3 E3  ........
        .byte   $E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3 ; A50B E3 E3 E3 E3 E3 E3 E3 E3  ........
        .byte   $E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3 ; A513 E3 E3 E3 E3 E3 E3 E3 E3  ........
        .byte   $E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3 ; A51B E3 E3 E3 E3 E3 E3 E3 E3  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; A523 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; A52B FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$77,$DD,$FF,$FF,$FF ; A533 FF FF FF 77 DD FF FF FF  ...w....
        .byte   $3F,$CF,$FF,$33,$CC,$FF,$EF,$FF ; A53B 3F CF FF 33 CC FF EF FF  ?..3....
        .byte   $70,$DC,$50,$10,$C0,$F3,$00,$CC ; A543 70 DC 50 10 C0 F3 00 CC  p.P.....
        .byte   $77,$DD,$05,$01,$CC,$FF,$99,$DD ; A54B 77 DD 05 01 CC FF 99 DD  w.......
        .byte   $07,$0D,$00,$00,$00,$00,$09,$0D ; A553 07 0D 00 00 00 00 09 0D  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A55B 00 00 00 00 00 00 00 00  ........
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A563 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A56B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A573 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A57B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A583 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A58B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A593 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A59B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A5A3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A5AB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A5B3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A5BB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A5C3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A5CB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A5D3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A5DB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A5E3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A5EB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A5F3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A5FB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A603 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A60B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A613 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A61B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A623 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A62B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A633 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A63B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$1E,$17,$32,$0B,$18,$0E ; A643 32 32 1E 17 32 0B 18 0E  22..2...
        .byte   $32,$26,$32,$01,$09,$08,$07,$32 ; A64B 32 26 32 01 09 08 07 32  2&2....2
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A653 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A65B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$20,$28,$19,$32,$0F,$16 ; A663 32 32 20 28 19 32 0F 16  22 (.2..
        .byte   $0F,$0D,$1E,$1C,$19,$18,$19,$1C ; A66B 0F 0D 1E 1C 19 18 19 1C  ........
        .byte   $11,$1E,$0F,$0D,$12,$18,$13,$0D ; A673 11 1E 0F 0D 12 18 13 0D  ........
        .byte   $0B,$32,$32,$32,$32,$32,$32,$32 ; A67B 0B 32 32 32 32 32 32 32  .2222222
        .byte   $32,$32,$29,$A3,$0F,$16,$19,$1C ; A683 32 32 29 A3 0F 16 19 1C  22).....
        .byte   $11,$A3,$2A,$32,$32,$32,$32,$32 ; A68B 11 A3 2A 32 32 32 32 32  ..*22222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A693 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A69B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A6A3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A6AB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A6B3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A6BB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$1E,$0F,$1E,$1C,$13,$1D ; A6C3 32 32 1E 0F 1E 1C 13 1D  22......
        .byte   $32,$16,$13,$0D,$0F,$18,$1D,$0F ; A6CB 32 16 13 0D 0F 18 1D 0F  2.......
        .byte   $0E,$32,$1E,$19,$32,$18,$13,$18 ; A6D3 0E 32 1E 19 32 18 13 18  .2..2...
        .byte   $1E,$0F,$18,$0E,$19,$32,$32,$32 ; A6DB 1E 0F 18 0E 19 32 32 32  .....222
        .byte   $32,$32,$0B,$18,$0E,$32,$1D,$1F ; A6E3 32 32 0B 18 0E 32 1D 1F  22...2..
        .byte   $0C,$16,$13,$0D,$0F,$18,$1D,$0F ; A6EB 0C 16 13 0D 0F 18 1D 0F  ........
        .byte   $0E,$32,$1E,$19,$32,$32,$32,$32 ; A6F3 0E 32 1E 19 32 32 32 32  .2..2222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A6FB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$0C,$1F,$16,$16,$0F,$1E ; A703 32 32 0C 1F 16 16 0F 1E  22......
        .byte   $DE,$1A,$1C,$19,$19,$10,$32,$1D ; A70B DE 1A 1C 19 19 10 32 1D  ......2.
        .byte   $19,$10,$1E,$21,$0B,$1C,$0F,$25 ; A713 19 10 1E 21 0B 1C 0F 25  ...!...%
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A71B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A723 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A72B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A733 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A73B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$26,$01,$09,$08,$08,$32 ; A743 32 32 26 01 09 08 08 32  22&....2
        .byte   $0C,$1F,$16,$16,$0F,$1E,$DE,$1A ; A74B 0C 1F 16 16 0F 1E DE 1A  ........
        .byte   $1C,$19,$19,$10,$32,$1D,$19,$10 ; A753 1C 19 19 10 32 1D 19 10  ....2...
        .byte   $1E,$21,$0B,$1C,$0F,$25,$32,$32 ; A75B 1E 21 0B 1C 0F 25 32 32  .!...%22
        .byte   $32,$32,$0B,$16,$16,$32,$1C,$13 ; A763 32 32 0B 16 16 32 1C 13  22...2..
        .byte   $11,$12,$1E,$1D,$32,$1C,$0F,$1D ; A76B 11 12 1E 1D 32 1C 0F 1D  ....2...
        .byte   $0F,$1C,$20,$0F,$0E,$25,$32,$32 ; A773 0F 1C 20 0F 0E 25 32 32  .. ..%22
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A77B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A783 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A78B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A793 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A79B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A7A3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A7AB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A7B3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A7BB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$19,$1C,$13,$11,$13,$18 ; A7C3 32 32 19 1C 13 11 13 18  22......
        .byte   $0B,$16,$32,$0D,$19,$18,$0D,$0F ; A7CB 0B 16 32 0D 19 18 0D 0F  ..2.....
        .byte   $1A,$1E,$27,$32,$0E,$0F,$1D,$13 ; A7D3 1A 1E 27 32 0E 0F 1D 13  ..'2....
        .byte   $11,$18,$32,$0B,$18,$0E,$32,$32 ; A7DB 11 18 32 0B 18 0E 32 32  ..2...22
        .byte   $32,$32,$1A,$1C,$19,$11,$1C,$0B ; A7E3 32 32 1A 1C 19 11 1C 0B  22......
        .byte   $17,$32,$0C,$23,$32,$0B,$16,$0F ; A7EB 17 32 0C 23 32 0B 16 0F  .2.#2...
        .byte   $22,$0F,$23,$32,$1A,$0B,$24,$12 ; A7F3 22 0F 23 32 1A 0B 24 12  ".#2..$.
        .byte   $13,$1E,$18,$19,$20,$25,$32,$32 ; A7FB 13 1E 18 19 20 25 32 32  .... %22
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A803 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A80B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A813 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A81B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A823 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A82B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A833 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A83B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A843 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A84B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A853 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A85B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A863 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A86B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A873 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A87B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A883 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A88B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A893 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A89B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A8A3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A8AB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A8B3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A8BB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A8C3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A8CB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A8D3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A8DB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A8E3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A8EB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A8F3 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A8FB 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A903 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A90B 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A913 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; A91B 32 32 32 32 32 32 32 32  22222222
        .byte   $55,$55,$55,$55,$55,$55,$55,$55 ; A923 55 55 55 55 55 55 55 55  UUUUUUUU
        .byte   $55,$55,$55,$55,$55,$55,$55,$55 ; A92B 55 55 55 55 55 55 55 55  UUUUUUUU
        .byte   $55,$55,$55,$55,$55,$55,$55,$55 ; A933 55 55 55 55 55 55 55 55  UUUUUUUU
        .byte   $55,$55,$55,$55,$55,$55,$55,$55 ; A93B 55 55 55 55 55 55 55 55  UUUUUUUU
        .byte   $55,$55,$55,$55,$55,$55,$55,$55 ; A943 55 55 55 55 55 55 55 55  UUUUUUUU
        .byte   $55,$55,$55,$55,$55,$55,$55,$55 ; A94B 55 55 55 55 55 55 55 55  UUUUUUUU
        .byte   $55,$55,$55,$55,$55,$55,$55,$55 ; A953 55 55 55 55 55 55 55 55  UUUUUUUU
        .byte   $55,$55,$55,$55,$55,$55,$55,$55 ; A95B 55 55 55 55 55 55 55 55  UUUUUUUU
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A963 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A96B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A973 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A97B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A983 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00                         ; A98B 00 00                    ..
LA98D:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A98D 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A995 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; A99D 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$03,$04,$05,$00 ; A9A5 00 00 00 00 03 04 05 00  ........
        .byte   $04,$05,$00,$03,$04,$05,$00,$06 ; A9AD 04 05 00 03 04 05 00 06  ........
        .byte   $07,$E5,$EF,$F0,$00,$08,$09,$0A ; A9B5 07 E5 EF F0 00 08 09 0A  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$B6 ; A9BD 00 00 00 00 00 00 00 B6  ........
        .byte   $B7,$9C,$9D,$00,$0B,$0C,$0D,$00 ; A9C5 B7 9C 9D 00 0B 0C 0D 00  ........
        .byte   $0C,$0E,$00,$0B,$0C,$0D,$00,$0C ; A9CD 0C 0E 00 0B 0C 0D 00 0C  ........
        .byte   $0F,$A6,$EC,$ED,$00,$10,$11,$12 ; A9D5 0F A6 EC ED 00 10 11 12  ........
        .byte   $9D,$9C,$9D,$9C,$BA,$00,$00,$9A ; A9DD 9D 9C 9D 9C BA 00 00 9A  ........
        .byte   $C2,$C3,$C2,$C3,$C2,$13,$C2,$C3 ; A9E5 C2 C3 C2 C3 C2 13 C2 C3  ........
        .byte   $13,$14,$C2,$C3,$13,$C3,$C2,$13 ; A9ED 13 14 C2 C3 13 C3 C2 13  ........
        .byte   $E4,$A7,$EB,$EE,$C2,$16,$17,$18 ; A9F5 E4 A7 EB EE C2 16 17 18  ........
        .byte   $C2,$C3,$C2,$C3,$9A,$00,$00,$9B ; A9FD C2 C3 C2 C3 9A 00 00 9B  ........
        .byte   $C4,$C5,$C4,$C5,$C4,$19,$C4,$C5 ; AA05 C4 C5 C4 C5 C4 19 C4 C5  ........
        .byte   $19,$1A,$C4,$C5,$19,$C5,$C4,$19 ; AA0D 19 1A C4 C5 19 C5 C4 19  ........
        .byte   $E3,$E2,$E9,$EA,$C4,$1C,$1D,$72 ; AA15 E3 E2 E9 EA C4 1C 1D 72  .......r
        .byte   $73,$C5,$C4,$C5,$9B,$00,$00,$9A ; AA1D 73 C5 C4 C5 9B 00 00 9A  s.......
        .byte   $C2,$C3,$C2,$C3,$C2,$C3,$C2,$C3 ; AA25 C2 C3 C2 C3 C2 C3 C2 C3  ........
        .byte   $C2,$C3,$C2,$C3,$C2,$1F,$20,$A9 ; AA2D C2 C3 C2 C3 C2 1F 20 A9  ...... .
        .byte   $CC,$E6,$F1,$C3,$C2,$C3,$C2,$C3 ; AA35 CC E6 F1 C3 C2 C3 C2 C3  ........
        .byte   $C2,$C3,$C2,$C3,$9A,$00,$00,$9B ; AA3D C2 C3 C2 C3 9A 00 00 9B  ........
        .byte   $C4,$C5,$C4,$C5,$C4,$C5,$C4,$C5 ; AA45 C4 C5 C4 C5 C4 C5 C4 C5  ........
        .byte   $C4,$C5,$C4,$C5,$21,$22,$23,$24 ; AA4D C4 C5 C4 C5 21 22 23 24  ....!"#$
        .byte   $CD,$CB,$C7,$C5,$C4,$C5,$C4,$C5 ; AA55 CD CB C7 C5 C4 C5 C4 C5  ........
        .byte   $C4,$C5,$C4,$C5,$9B,$00,$00,$9A ; AA5D C4 C5 C4 C5 9B 00 00 9A  ........
        .byte   $C2,$C3,$C2,$C3,$C2,$C3,$C2,$C3 ; AA65 C2 C3 C2 C3 C2 C3 C2 C3  ........
        .byte   $C2,$C3,$C2,$25,$26,$27,$28,$29 ; AA6D C2 C3 C2 25 26 27 28 29  ...%&'()
        .byte   $2A,$AA,$C8,$C3,$C2,$C3,$C2,$C3 ; AA75 2A AA C8 C3 C2 C3 C2 C3  *.......
        .byte   $C2,$C3,$C2,$C3,$9A,$00,$00,$9B ; AA7D C2 C3 C2 C3 9A 00 00 9B  ........
        .byte   $C4,$C5,$C4,$C5,$C4,$C5,$C4,$C5 ; AA85 C4 C5 C4 C5 C4 C5 C4 C5  ........
        .byte   $C4,$C5,$2B,$2C,$2D,$2E,$2F,$30 ; AA8D C4 C5 2B 2C 2D 2E 2F 30  ..+,-./0
        .byte   $31,$CF,$C9,$C5,$C4,$C5,$C4,$C5 ; AA95 31 CF C9 C5 C4 C5 C4 C5  1.......
        .byte   $C4,$C5,$C4,$C5,$9B,$00,$00,$9A ; AA9D C4 C5 C4 C5 9B 00 00 9A  ........
        .byte   $C2,$C3,$C2,$C3,$C2,$C3,$C2,$33 ; AAA5 C2 C3 C2 C3 C2 C3 C2 33  .......3
        .byte   $34,$C3,$35,$36,$37,$38,$39,$3A ; AAAD 34 C3 35 36 37 38 39 3A  4.56789:
        .byte   $3B,$AB,$D0,$33,$34,$C3,$C2,$C3 ; AAB5 3B AB D0 33 34 C3 C2 C3  ;..34...
        .byte   $C2,$C3,$C2,$C3,$9A,$00,$00,$9B ; AABD C2 C3 C2 C3 9A 00 00 9B  ........
        .byte   $C4,$C5,$C4,$C5,$C4,$C5,$3D,$3E ; AAC5 C4 C5 C4 C5 C4 C5 3D 3E  ......=>
        .byte   $3F,$40,$A4,$41,$42,$43,$44,$45 ; AACD 3F 40 A4 41 42 43 44 45  ?@.ABCDE
        .byte   $46,$AC,$D1,$3E,$3F,$40,$C4,$C5 ; AAD5 46 AC D1 3E 3F 40 C4 C5  F..>?@..
        .byte   $C4,$C5,$C4,$C5,$9B,$00,$00,$9A ; AADD C4 C5 C4 C5 9B 00 00 9A  ........
        .byte   $C2,$C3,$C2,$C3,$C2,$C3,$47,$48 ; AAE5 C2 C3 C2 C3 C2 C3 47 48  ......GH
        .byte   $49,$4A,$A3,$4B,$4C,$4D,$4E,$4F ; AAED 49 4A A3 4B 4C 4D 4E 4F  IJ.KLMNO
        .byte   $50,$D2,$47,$48,$49,$4A,$C2,$C3 ; AAF5 50 D2 47 48 49 4A C2 C3  P.GHIJ..
        .byte   $C2,$C3,$C2,$C3,$9A,$00,$00,$9B ; AAFD C2 C3 C2 C3 9A 00 00 9B  ........
        .byte   $C4,$C5,$C4,$C5,$C4,$C5,$51,$52 ; AB05 C4 C5 C4 C5 C4 C5 51 52  ......QR
        .byte   $53,$54,$DA,$DB,$56,$57,$58,$59 ; AB0D 53 54 DA DB 56 57 58 59  ST..VWXY
        .byte   $5A,$D3,$51,$52,$53,$54,$C4,$C5 ; AB15 5A D3 51 52 53 54 C4 C5  Z.QRST..
        .byte   $C4,$C5,$C4,$C5,$9B,$00,$00,$9A ; AB1D C4 C5 C4 C5 9B 00 00 9A  ........
        .byte   $C2,$C3,$C2,$C3,$C2,$C3,$AD,$5C ; AB25 C2 C3 C2 C3 C2 C3 AD 5C  .......\
        .byte   $5D,$5E,$DC,$DD,$01,$60,$61,$62 ; AB2D 5D 5E DC DD 01 60 61 62  ]^...`ab
        .byte   $63,$D4,$E7,$5C,$5D,$AF,$C2,$C3 ; AB35 63 D4 E7 5C 5D AF C2 C3  c..\]...
        .byte   $C2,$C3,$C2,$C3,$9A,$00,$00,$9B ; AB3D C2 C3 C2 C3 9A 00 00 9B  ........
        .byte   $C4,$C5,$C4,$C5,$C4,$C5,$AE,$65 ; AB45 C4 C5 C4 C5 C4 C5 AE 65  .......e
        .byte   $66,$67,$DE,$E0,$02,$69,$6A,$6B ; AB4D 66 67 DE E0 02 69 6A 6B  fg...ijk
        .byte   $6C,$D5,$E8,$65,$66,$B0,$C4,$C5 ; AB55 6C D5 E8 65 66 B0 C4 C5  l..ef...
        .byte   $C4,$C5,$C4,$C5,$9B,$00,$00,$9A ; AB5D C4 C5 C4 C5 9B 00 00 9A  ........
        .byte   $C2,$C3,$C2,$C3,$74,$75,$76,$77 ; AB65 C2 C3 C2 C3 74 75 76 77  ....tuvw
        .byte   $78,$79,$7A,$7B,$7C,$7D,$7E,$7F ; AB6D 78 79 7A 7B 7C 7D 7E 7F  xyz{|}~.
        .byte   $80,$81,$82,$83,$84,$85,$86,$87 ; AB75 80 81 82 83 84 85 86 87  ........
        .byte   $C2,$C3,$C2,$C3,$9A,$00,$00,$9B ; AB7D C2 C3 C2 C3 9A 00 00 9B  ........
        .byte   $C4,$C5,$C4,$C5,$88,$89,$8A,$8A ; AB85 C4 C5 C4 C5 88 89 8A 8A  ........
        .byte   $8A,$90,$91,$92,$8A,$8A,$8A,$8A ; AB8D 8A 90 91 92 8A 8A 8A 8A  ........
        .byte   $93,$94,$95,$8A,$8A,$8A,$96,$97 ; AB95 93 94 95 8A 8A 8A 96 97  ........
        .byte   $C4,$C5,$C4,$C5,$9B,$00,$00,$9A ; AB9D C4 C5 C4 C5 9B 00 00 9A  ........
        .byte   $C2,$C3,$C2,$C3,$8B,$8C,$8C,$8C ; ABA5 C2 C3 C2 C3 8B 8C 8C 8C  ........
        .byte   $8A,$8A,$8A,$8A,$8C,$8C,$8A,$8A ; ABAD 8A 8A 8A 8A 8C 8C 8A 8A  ........
        .byte   $8A,$8A,$8C,$8C,$8C,$8C,$8C,$8D ; ABB5 8A 8A 8C 8C 8C 8C 8C 8D  ........
        .byte   $C2,$C3,$C2,$C3,$9A,$00,$00,$9B ; ABBD C2 C3 C2 C3 9A 00 00 9B  ........
        .byte   $C4,$C5,$C4,$C5,$8F,$8C,$8C,$8C ; ABC5 C4 C5 C4 C5 8F 8C 8C 8C  ........
        .byte   $8A,$8A,$8A,$8A,$8C,$8C,$8A,$8A ; ABCD 8A 8A 8A 8A 8C 8C 8A 8A  ........
        .byte   $8A,$8A,$B3,$8C,$8C,$8C,$8C,$8E ; ABD5 8A 8A B3 8C 8C 8C 8C 8E  ........
        .byte   $C4,$C5,$C4,$C5,$9B,$00,$00,$9A ; ABDD C4 C5 C4 C5 9B 00 00 9A  ........
        .byte   $C2,$C3,$C2,$C3,$8F,$8C,$B3,$8C ; ABE5 C2 C3 C2 C3 8F 8C B3 8C  ........
        .byte   $8C,$8C,$8C,$8C,$8C,$8C,$B3,$8C ; ABED 8C 8C 8C 8C 8C 8C B3 8C  ........
        .byte   $8C,$B2,$C2,$B5,$8C,$8C,$8C,$8E ; ABF5 8C B2 C2 B5 8C 8C 8C 8E  ........
        .byte   $C2,$C3,$C2,$C3,$9A,$00,$00,$9B ; ABFD C2 C3 C2 C3 9A 00 00 9B  ........
        .byte   $C4,$C5,$C4,$C5,$B1,$B2,$C4,$B5 ; AC05 C4 C5 C4 C5 B1 B2 C4 B5  ........
        .byte   $8C,$8C,$8C,$8C,$8C,$B2,$C4,$B5 ; AC0D 8C 8C 8C 8C 8C B2 C4 B5  ........
        .byte   $B2,$C5,$C4,$C5,$B5,$B3,$B3,$B4 ; AC15 B2 C5 C4 C5 B5 B3 B3 B4  ........
        .byte   $C4,$C5,$C4,$C5,$9B,$00,$00,$9A ; AC1D C4 C5 C4 C5 9B 00 00 9A  ........
        .byte   $C2,$C3,$C2,$C3,$C2,$C3,$C2,$C3 ; AC25 C2 C3 C2 C3 C2 C3 C2 C3  ........
        .byte   $B5,$B3,$8C,$8C,$B2,$C3,$C2,$C3 ; AC2D B5 B3 8C 8C B2 C3 C2 C3  ........
        .byte   $C2,$C3,$98,$C3,$C2,$C3,$C2,$C3 ; AC35 C2 C3 98 C3 C2 C3 C2 C3  ........
        .byte   $C2,$C3,$C2,$C3,$9A,$00,$00,$B9 ; AC3D C2 C3 C2 C3 9A 00 00 B9  ........
        .byte   $C4,$C5,$C4,$C5,$C4,$C5,$C4,$C5 ; AC45 C4 C5 C4 C5 C4 C5 C4 C5  ........
        .byte   $C4,$C5,$B5,$B2,$C4,$C5,$C4,$C5 ; AC4D C4 C5 B5 B2 C4 C5 C4 C5  ........
        .byte   $C4,$98,$98,$98,$C4,$C5,$C4,$C5 ; AC55 C4 98 98 98 C4 C5 C4 C5  ........
        .byte   $C4,$C5,$C4,$C5,$B9,$00,$BE,$BA ; AC5D C4 C5 C4 C5 B9 00 BE BA  ........
        .byte   $C2,$C3,$C2,$C3,$C2,$C3,$C2,$C3 ; AC65 C2 C3 C2 C3 C2 C3 C2 C3  ........
        .byte   $C2,$C3,$C2,$C3,$C2,$C3,$C2,$C3 ; AC6D C2 C3 C2 C3 C2 C3 C2 C3  ........
        .byte   $C2,$C3,$C2,$C3,$C2,$C3,$C2,$C3 ; AC75 C2 C3 C2 C3 C2 C3 C2 C3  ........
        .byte   $C2,$C3,$C2,$D6,$BA,$00,$BF,$BB ; AC7D C2 C3 C2 D6 BA 00 BF BB  ........
        .byte   $C4,$C5,$C4,$C5,$C4,$C5,$98,$98 ; AC85 C4 C5 C4 C5 C4 C5 98 98  ........
        .byte   $98,$C5,$C4,$C5,$C4,$C5,$C4,$C5 ; AC8D 98 C5 C4 C5 C4 C5 C4 C5  ........
        .byte   $C4,$C5,$C4,$C5,$98,$C5,$C4,$C5 ; AC95 C4 C5 C4 C5 98 C5 C4 C5  ........
        .byte   $C4,$C5,$C4,$D7,$BB,$00,$C0,$BC ; AC9D C4 C5 C4 D7 BB 00 C0 BC  ........
        .byte   $C2,$C3,$C2,$C3,$C2,$98,$99,$99 ; ACA5 C2 C3 C2 C3 C2 98 99 99  ........
        .byte   $98,$00,$98,$C3,$C2,$C3,$98,$98 ; ACAD 98 00 98 C3 C2 C3 98 98  ........
        .byte   $99,$00,$00,$99,$99,$99,$98,$98 ; ACB5 99 00 00 99 99 99 98 98  ........
        .byte   $C2,$C3,$C2,$D8,$BC,$00,$C1,$BD ; ACBD C2 C3 C2 D8 BC 00 C1 BD  ........
        .byte   $C4,$C5,$C4,$C5,$98,$98,$99,$99 ; ACC5 C4 C5 C4 C5 98 98 99 99  ........
        .byte   $98,$98,$98,$98,$00,$98,$98,$98 ; ACCD 98 98 98 98 00 98 98 98  ........
        .byte   $99,$99,$99,$99,$99,$99,$98,$98 ; ACD5 99 99 99 99 99 99 98 98  ........
        .byte   $C4,$C5,$C4,$D9,$BD,$00,$00,$C3 ; ACDD C4 C5 C4 D9 BD 00 00 C3  ........
        .byte   $C2,$C3,$C2,$C3,$99,$99,$99,$99 ; ACE5 C2 C3 C2 C3 99 99 99 99  ........
        .byte   $98,$98,$99,$99,$99,$99,$98,$98 ; ACED 98 98 99 99 99 99 98 98  ........
        .byte   $98,$98,$99,$99,$99,$99,$99,$99 ; ACF5 98 98 99 99 99 99 99 99  ........
        .byte   $C2,$C3,$C2,$C3,$C2,$00,$00,$C5 ; ACFD C2 C3 C2 C3 C2 00 00 C5  ........
        .byte   $C4,$C5,$C4,$C5,$99,$99,$99,$99 ; AD05 C4 C5 C4 C5 99 99 99 99  ........
        .byte   $98,$98,$99,$99,$99,$99,$98,$98 ; AD0D 98 98 99 99 99 99 98 98  ........
        .byte   $98,$98,$99,$99,$99,$99,$99,$99 ; AD15 98 98 99 99 99 99 99 99  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; AD1D 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; AD25 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; AD2D 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; AD35 00 00 00 00 00 00 00 00  ........
        .byte   $50,$77,$DD,$50,$00,$00,$00,$0C ; AD3D 50 77 DD 50 00 00 00 0C  Pw.P....
        .byte   $CF,$3F,$FF,$0F,$03,$00,$00,$00 ; AD45 CF 3F FF 0F 03 00 00 00  .?......
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; AD4D 00 00 00 00 00 00 00 00  ........
        .byte   $20,$00,$80,$A0,$00,$00,$00,$08 ; AD55 20 00 80 A0 00 00 00 08   .......
        .byte   $02,$0A,$00,$0A,$02             ; AD5D 02 0A 00 0A 02           .....
LAD62:
        .byte   $00,$32,$32,$32,$32,$32,$32,$32 ; AD62 00 32 32 32 32 32 32 32  .2222222
        .byte   $32,$32,$32,$0E,$1C,$19,$1A,$1D ; AD6A 32 32 32 0E 1C 19 1A 1D  222.....
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AD72 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$01 ; AD7A 32 32 32 32 32 32 32 01  2222222.
        .byte   $32,$16,$13,$18,$0F,$32,$32,$32 ; AD82 32 16 13 18 0F 32 32 32  2....222
        .byte   $32,$32,$32,$32,$22,$32,$04,$0A ; AD8A 32 32 32 32 22 32 04 0A  2222"2..
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AD92 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$02,$32,$16 ; AD9A 32 32 32 32 32 02 32 16  22222.2.
        .byte   $13,$18,$0F,$1D,$32,$32,$32,$32 ; ADA2 13 18 0F 1D 32 32 32 32  ....2222
        .byte   $32,$32,$22,$32,$01,$0A,$0A,$32 ; ADAA 32 32 22 32 01 0A 0A 32  22"2...2
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; ADB2 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$03,$32,$16,$13,$18 ; ADBA 32 32 32 03 32 16 13 18  222.2...
        .byte   $0F,$1D,$32,$32,$32,$32,$32,$32 ; ADC2 0F 1D 32 32 32 32 32 32  ..222222
        .byte   $22,$32,$03,$0A,$0A,$32,$32,$32 ; ADCA 22 32 03 0A 0A 32 32 32  "2...222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; ADD2 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$04,$32,$16,$13,$18,$0F,$1D ; ADDA 32 04 32 16 13 18 0F 1D  2.2.....
        .byte   $32,$32,$32,$32,$32,$32,$22,$32 ; ADE2 32 32 32 32 32 32 22 32  222222"2
        .byte   $01,$02,$0A,$0A,$32,$32,$32,$32 ; ADEA 01 02 0A 0A 32 32 32 32  ....2222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; ADF2 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; ADFA 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AE02 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$1E,$12,$13,$1D,$32 ; AE0A 32 32 32 1E 12 13 1D 32  222....2
        .byte   $1D,$1E,$0B,$11,$0F             ; AE12 1D 1E 0B 11 0F           .....
LAE17:
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AE17 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AE1F 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AE27 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AE2F 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AE37 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$11,$0B,$17,$0F,$32 ; AE3F 32 32 32 11 0B 17 0F 32  222....2
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AE47 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$19 ; AE4F 32 32 32 32 32 32 32 19  2222222.
        .byte   $20,$0F,$1C,$32,$32,$32,$32,$32 ; AE57 20 0F 1C 32 32 32 32 32   ..22222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AE5F 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AE67 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AE6F 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AE77 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AE7F 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AE87 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$1A,$16,$0F,$0B,$1D,$0F ; AE8F 32 32 1A 16 0F 0B 1D 0F  22......
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AE97 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$1E ; AE9F 32 32 32 32 32 32 32 1E  2222222.
        .byte   $1C,$23,$32,$32,$32,$32,$32,$32 ; AEA7 1C 23 32 32 32 32 32 32  .#222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AEAF 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$0B,$11,$0B,$13,$18,$32 ; AEB7 32 32 0B 11 0B 13 18 32  22.....2
        .byte   $32                             ; AEBF 32                       2
LAEC0:
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AEC0 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AEC8 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AED0 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AED8 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AEE0 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$12,$13,$1E,$32 ; AEE8 32 32 32 32 12 13 1E 32  2222...2
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AEF0 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$1D ; AEF8 32 32 32 32 32 32 32 1D  2222222.
        .byte   $1E,$0B,$1C,$1E,$32,$32,$32,$32 ; AF00 1E 0B 1C 1E 32 32 32 32  ....2222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AF08 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$1E,$19,$32 ; AF10 32 32 32 32 32 1E 19 32  22222..2
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AF18 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$0D,$19 ; AF20 32 32 32 32 32 32 0D 19  222222..
        .byte   $18,$1E,$13,$18,$1F,$0F,$32,$32 ; AF28 18 1E 13 18 1F 0F 32 32  ......22
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AF30 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$11,$0B,$17,$0F ; AF38 32 32 32 32 11 0B 17 0F  2222....
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AF40 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AF48 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AF50 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AF58 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AF60 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AF68 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AF70 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AF78 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; AF80 32 32 32 32 32 32 32 32  22222222
; copied to $04D9 during init at $817D
unknownTable01:
        .byte   $32,$0C,$1A,$1D,$32,$32,$32,$01 ; AF88 32 0C 1A 1D 32 32 32 01  2...222.
        .byte   $0A,$0A,$0A,$0A,$32,$0A,$32,$09 ; AF90 0A 0A 0A 0A 32 0A 32 09  ....2.2.
        .byte   $0C,$1A,$1D,$32,$32,$32,$32,$09 ; AF98 0C 1A 1D 32 32 32 32 09  ...2222.
        .byte   $0A,$0A,$0A,$32,$0A,$32,$08,$0C ; AFA0 0A 0A 0A 32 0A 32 08 0C  ...2.2..
        .byte   $1A,$1D,$32,$32,$32,$32,$08,$0A ; AFA8 1A 1D 32 32 32 32 08 0A  ..2222..
        .byte   $0A,$0A,$32,$0A,$32,$07,$0C,$1A ; AFB0 0A 0A 32 0A 32 07 0C 1A  ..2.2...
        .byte   $1D,$32,$32,$32,$32,$07,$0A,$0A ; AFB8 1D 32 32 32 32 07 0A 0A  .2222...
        .byte   $0A,$32,$0A,$32,$06,$0C,$1A,$1D ; AFC0 0A 32 0A 32 06 0C 1A 1D  .2.2....
        .byte   $32,$32,$32,$32,$06,$0A,$0A,$0A ; AFC8 32 32 32 32 06 0A 0A 0A  2222....
        .byte   $32,$0A,$32,$05,$0C,$1A,$1D,$32 ; AFD0 32 0A 32 05 0C 1A 1D 32  2.2....2
        .byte   $32,$32,$32,$05,$0A,$0A,$0A,$32 ; AFD8 32 32 32 05 0A 0A 0A 32  222....2
        .byte   $0A,$32,$04,$0C,$1A,$1D,$32,$32 ; AFE0 0A 32 04 0C 1A 1D 32 32  .2....22
        .byte   $32,$32,$04,$0A,$0A,$0A,$32,$0A ; AFE8 32 32 04 0A 0A 0A 32 0A  22....2.
        .byte   $32,$03,$0C,$1A,$1D,$32,$32,$32 ; AFF0 32 03 0C 1A 1D 32 32 32  2....222
        .byte   $32,$03,$0A,$0A,$0A,$32,$0A,$32 ; AFF8 32 03 0A 0A 0A 32 0A 32  2....2.2
        .byte   $02,$0C,$1A,$1D,$32,$32,$32,$32 ; B000 02 0C 1A 1D 32 32 32 32  ....2222
        .byte   $02,$0A,$0A,$0A,$32,$0A,$32,$01 ; B008 02 0A 0A 0A 32 0A 32 01  ....2.2.
        .byte   $0C,$1A,$1D,$32,$32,$32,$32,$01 ; B010 0C 1A 1D 32 32 32 32 01  ...2222.
        .byte   $0A,$0A,$0A,$32,$0A,$32,$0A,$32 ; B018 0A 0A 0A 32 0A 32 0A 32  ...2.2.2
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B020 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B028 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B030 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B038 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B040 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B048 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B050 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B058 32 32 32 32 32 32 32 32  22222222
        .byte   $1D,$0D,$19,$1C,$0F,$32,$32,$32 ; B060 1D 0D 19 1C 0F 32 32 32  .....222
        .byte   $32,$32,$32,$32,$32,$32,$0A,$32 ; B068 32 32 32 32 32 32 0A 32  222222.2
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B070 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$B8,$32,$32,$32,$32,$32 ; B078 32 32 B8 32 32 32 32 32  22.22222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B080 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B088 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B090 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$B7,$32,$32,$32,$32,$32 ; B098 32 32 B7 32 32 32 32 32  22.22222
        .byte   $16,$13,$20,$0F,$1D,$32,$32,$32 ; B0A0 16 13 20 0F 1D 32 32 32  .. ..222
        .byte   $CE,$98,$92,$92,$92,$92,$92,$92 ; B0A8 CE 98 92 92 92 92 92 92  ........
        .byte   $92,$92,$92,$92,$92,$92,$99,$32 ; B0B0 92 92 92 92 92 92 99 32  .......2
        .byte   $32,$32,$B6,$32,$32,$32,$32,$32 ; B0B8 32 32 B6 32 32 32 32 32  22.22222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B0C0 32 32 32 32 32 32 32 32  22222222
        .byte   $CE,$90,$D0,$CF,$CF,$CF,$CF,$CF ; B0C8 CE 90 D0 CF CF CF CF CF  ........
        .byte   $CF,$CF,$CF,$CF,$CF,$D1,$91,$32 ; B0D0 CF CF CF CF CF D1 91 32  .......2
        .byte   $32,$A9,$AA,$AB,$32,$32,$32,$32 ; B0D8 32 A9 AA AB 32 32 32 32  2...2222
        .byte   $1C,$19,$1F,$18,$0E,$32,$32,$32 ; B0E0 1C 19 1F 18 0E 32 32 32  .....222
        .byte   $CE,$90,$91,$00,$00,$00,$00,$00 ; B0E8 CE 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$32 ; B0F0 00 00 00 00 00 90 91 32  .......2
        .byte   $AC,$AD,$AE,$AF,$B5,$32,$32,$32 ; B0F8 AC AD AE AF B5 32 32 32  .....222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B100 32 32 32 32 32 32 32 32  22222222
        .byte   $CE,$90,$91,$00,$00,$00,$00,$00 ; B108 CE 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$32 ; B110 00 00 00 00 00 90 91 32  .......2
        .byte   $B0,$B1,$B2,$B3,$B4,$32,$32,$32 ; B118 B0 B1 B2 B3 B4 32 32 32  .....222
        .byte   $1D,$1E,$0B,$11,$0F,$32,$32,$32 ; B120 1D 1E 0B 11 0F 32 32 32  .....222
        .byte   $CE,$90,$91,$00,$00,$00,$00,$00 ; B128 CE 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$32 ; B130 00 00 00 00 00 90 91 32  .......2
        .byte   $BB,$A2,$A2,$A2,$BA,$32,$32,$32 ; B138 BB A2 A2 A2 BA 32 32 32  .....222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B140 32 32 32 32 32 32 32 32  22222222
        .byte   $CE,$90,$91,$00,$00,$00,$00,$00 ; B148 CE 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$32 ; B150 00 00 00 00 00 90 91 32  .......2
        .byte   $A1,$A4,$A5,$70,$A0,$32,$32,$32 ; B158 A1 A4 A5 70 A0 32 32 32  ...p.222
        .byte   $16,$13,$18,$0F,$1D,$32,$32,$32 ; B160 16 13 18 0F 1D 32 32 32  .....222
        .byte   $CE,$90,$91,$00,$00,$00,$00,$00 ; B168 CE 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$32 ; B170 00 00 00 00 00 90 91 32  .......2
        .byte   $A1,$A8,$A5,$A8,$A0,$32,$32,$32 ; B178 A1 A8 A5 A8 A0 32 32 32  .....222
        .byte   $32,$32,$32,$32,$32,$32,$C0,$32 ; B180 32 32 32 32 32 32 C0 32  222222.2
        .byte   $CE,$90,$91,$00,$00,$00,$00,$00 ; B188 CE 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$32 ; B190 00 00 00 00 00 90 91 32  .......2
        .byte   $A1,$A7,$A5,$A7,$A0,$32,$32,$32 ; B198 A1 A7 A5 A7 A0 32 32 32  .....222
        .byte   $32,$32,$32,$32,$32,$32,$B6,$32 ; B1A0 32 32 32 32 32 32 B6 32  222222.2
        .byte   $CE,$90,$91,$00,$00,$00,$00,$00 ; B1A8 CE 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$32 ; B1B0 00 00 00 00 00 90 91 32  .......2
        .byte   $A1,$A4,$A5,$70,$A0,$32,$32,$32 ; B1B8 A1 A4 A5 70 A0 32 32 32  ...p.222
        .byte   $32,$32,$32,$32,$32,$A9,$AA,$AB ; B1C0 32 32 32 32 32 A9 AA AB  22222...
        .byte   $CE,$90,$91,$00,$00,$00,$00,$00 ; B1C8 CE 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$32 ; B1D0 00 00 00 00 00 90 91 32  .......2
        .byte   $A1,$A8,$A5,$A8,$A0,$32,$32,$A2 ; B1D8 A1 A8 A5 A8 A0 32 32 A2  .....22.
        .byte   $A2,$A2,$A2,$A2,$A2,$A2,$A2,$A2 ; B1E0 A2 A2 A2 A2 A2 A2 A2 A2  ........
        .byte   $A2,$90,$91,$00,$00,$00,$00,$00 ; B1E8 A2 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$32 ; B1F0 00 00 00 00 00 90 91 32  .......2
        .byte   $A1,$A7,$A5,$A7,$A0,$32,$32,$BD ; B1F8 A1 A7 A5 A7 A0 32 32 BD  .....22.
        .byte   $BF,$BE,$BD,$BE,$BD,$BE,$BD,$BF ; B200 BF BE BD BE BD BE BD BF  ........
        .byte   $BE,$90,$91,$00,$00,$00,$00,$00 ; B208 BE 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$32 ; B210 00 00 00 00 00 90 91 32  .......2
        .byte   $A1,$A4,$A5,$70,$A0,$32,$32,$00 ; B218 A1 A4 A5 70 A0 32 32 00  ...p.22.
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; B220 00 00 00 00 00 00 00 00  ........
        .byte   $00,$90,$91,$00,$00,$00,$00,$00 ; B228 00 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$9D ; B230 00 00 00 00 00 90 91 9D  ........
        .byte   $9D,$9D,$9D,$9D,$9D,$9D,$9D,$00 ; B238 9D 9D 9D 9D 9D 9D 9D 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; B240 00 00 00 00 00 00 00 00  ........
        .byte   $00,$90,$91,$00,$00,$00,$00,$00 ; B248 00 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$CA ; B250 00 00 00 00 00 90 91 CA  ........
        .byte   $CB,$CB,$CB,$CB,$CC,$9B,$9B,$9D ; B258 CB CB CB CB CC 9B 9B 9D  ........
        .byte   $9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D ; B260 9D 9D 9D 9D 9D 9D 9D 9D  ........
        .byte   $9D,$90,$91,$00,$00,$00,$00,$00 ; B268 9D 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$C1 ; B270 00 00 00 00 00 90 91 C1  ........
        .byte   $C3,$C4,$C5,$C6,$C2,$9B,$9B,$9B ; B278 C3 C4 C5 C6 C2 9B 9B 9B  ........
        .byte   $9B,$9B,$9B,$9B,$9B,$9B,$9B,$9B ; B280 9B 9B 9B 9B 9B 9B 9B 9B  ........
        .byte   $CD,$90,$91,$00,$00,$00,$00,$00 ; B288 CD 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$C1 ; B290 00 00 00 00 00 90 91 C1  ........
        .byte   $00,$00,$00,$00,$C2,$9B,$9B,$CD ; B298 00 00 00 00 C2 9B 9B CD  ........
        .byte   $9C,$D2,$9C,$D2,$9C,$D2,$9C,$D3 ; B2A0 9C D2 9C D2 9C D2 9C D3  ........
        .byte   $CD,$90,$91,$00,$00,$00,$00,$00 ; B2A8 CD 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$C1 ; B2B0 00 00 00 00 00 90 91 C1  ........
        .byte   $00,$00,$00,$00,$C2,$9B,$9B,$9B ; B2B8 00 00 00 00 C2 9B 9B 9B  ........
        .byte   $9B,$9B,$9B,$9B,$9B,$9B,$9B,$9B ; B2C0 9B 9B 9B 9B 9B 9B 9B 9B  ........
        .byte   $CD,$90,$91,$00,$00,$00,$00,$00 ; B2C8 CD 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$C1 ; B2D0 00 00 00 00 00 90 91 C1  ........
        .byte   $00,$00,$00,$00,$C2,$9B,$9B,$9B ; B2D8 00 00 00 00 C2 9B 9B 9B  ........
        .byte   $CD,$98,$99,$9B,$CD,$98,$99,$9B ; B2E0 CD 98 99 9B CD 98 99 9B  ........
        .byte   $CD,$90,$91,$00,$00,$00,$00,$00 ; B2E8 CD 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$C1 ; B2F0 00 00 00 00 00 90 91 C1  ........
        .byte   $00,$00,$00,$00,$C2,$9B,$9B,$9B ; B2F8 00 00 00 00 C2 9B 9B 9B  ........
        .byte   $CD,$90,$91,$9B,$CD,$90,$91,$9B ; B300 CD 90 91 9B CD 90 91 9B  ........
        .byte   $CD,$90,$91,$00,$00,$00,$00,$00 ; B308 CD 90 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$91,$C8 ; B310 00 00 00 00 00 90 91 C8  ........
        .byte   $C7,$C7,$C7,$C7,$C9,$C9,$9B,$92 ; B318 C7 C7 C7 C7 C9 C9 9B 92  ........
        .byte   $92,$93,$94,$92,$92,$93,$94,$92 ; B320 92 93 94 92 92 93 94 92  ........
        .byte   $92,$93,$91,$00,$00,$00,$00,$00 ; B328 92 93 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$94,$92 ; B330 00 00 00 00 00 90 94 92  ........
        .byte   $92,$92,$92,$92,$92,$92,$92,$9A ; B338 92 92 92 92 92 92 92 9A  ........
        .byte   $D0,$CF,$CF,$CF,$CF,$CF,$CF,$CF ; B340 D0 CF CF CF CF CF CF CF  ........
        .byte   $CF,$D1,$91,$00,$00,$00,$00,$00 ; B348 CF D1 91 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$90,$9A,$9A ; B350 00 00 00 00 00 90 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B358 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $91,$00,$40,$41,$42,$43,$44,$45 ; B360 91 00 40 41 42 43 44 45  ..@ABCDE
        .byte   $00,$90,$94,$92,$92,$92,$92,$92 ; B368 00 90 94 92 92 92 92 92  ........
        .byte   $92,$92,$92,$92,$92,$93,$9A,$9A ; B370 92 92 92 92 92 93 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B378 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $91,$00,$50,$51,$52,$53,$54,$55 ; B380 91 00 50 51 52 53 54 55  ..PQRSTU
        .byte   $00,$90,$9A,$9A,$9A,$9A,$9A,$9A ; B388 00 90 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B390 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B398 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $94,$92,$92,$92,$92,$92,$92,$92 ; B3A0 94 92 92 92 92 92 92 92  ........
        .byte   $92,$93,$9A,$9A,$9A,$9A,$9A,$9A ; B3A8 92 93 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B3B0 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B3B8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B3C0 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B3C8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B3D0 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$FF ; B3D8 9A 9A 9A 9A 9A 9A 9A FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; B3E0 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$33,$50,$50,$10,$AA,$EE,$FF ; B3E8 FF 33 50 50 10 AA EE FF  .3PP....
        .byte   $FF,$33,$55,$55,$11,$FF,$FF,$0F ; B3F0 FF 33 55 55 11 FF FF 0F  .3UU....
        .byte   $0F,$03,$55,$55,$11,$FF,$FF,$00 ; B3F8 0F 03 55 55 11 FF FF 00  ..UU....
        .byte   $00,$00,$55,$55,$11,$00,$00,$00 ; B400 00 00 55 55 11 00 00 00  ..UU....
        .byte   $00,$00,$55,$55,$11,$00,$00,$00 ; B408 00 00 55 55 11 00 00 00  ..UU....
        .byte   $00,$00,$05,$05,$01,$00,$00,$00 ; B410 00 00 05 05 01 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$9A ; B418 00 00 00 00 00 00 00 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B420 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B428 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B430 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B438 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B440 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B448 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B450 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B458 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B460 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B468 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B470 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B478 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$97,$95,$95,$95,$95,$95 ; B480 9A 9A 97 95 95 95 95 95  ........
        .byte   $95,$95,$95,$95,$95,$96,$9A,$9A ; B488 95 95 95 95 95 96 9A 9A  ........
        .byte   $97,$95,$95,$95,$95,$95,$95,$95 ; B490 97 95 95 95 95 95 95 95  ........
        .byte   $95,$95,$95,$96,$9A,$9A,$9A,$9A ; B498 95 95 95 96 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$91,$2D,$2D,$48,$4B,$4C ; B4A0 9A 9A 91 2D 2D 48 4B 4C  ...--HKL
        .byte   $4D,$4E,$2D,$2D,$2D,$90,$9A,$9A ; B4A8 4D 4E 2D 2D 2D 90 9A 9A  MN---...
        .byte   $91,$2D,$2D,$4F,$61,$47,$62,$63 ; B4B0 91 2D 2D 4F 61 47 62 63  .--OaGbc
        .byte   $2D,$2D,$2D,$90,$9A,$9A,$9A,$9A ; B4B8 2D 2D 2D 90 9A 9A 9A 9A  ---.....
        .byte   $9A,$9A,$91,$2C,$2C,$58,$5B,$5C ; B4C0 9A 9A 91 2C 2C 58 5B 5C  ...,,X[\
        .byte   $5D,$5E,$2C,$2C,$2C,$90,$9A,$9A ; B4C8 5D 5E 2C 2C 2C 90 9A 9A  ]^,,,...
        .byte   $91,$2C,$2C,$5F,$71,$71,$72,$73 ; B4D0 91 2C 2C 5F 71 71 72 73  .,,_qqrs
        .byte   $2C,$2C,$2C,$90,$9A,$9A,$9A,$9A ; B4D8 2C 2C 2C 90 9A 9A 9A 9A  ,,,.....
        .byte   $9A,$9A,$94,$92,$92,$92,$92,$92 ; B4E0 9A 9A 94 92 92 92 92 92  ........
        .byte   $92,$92,$92,$92,$92,$93,$9A,$9A ; B4E8 92 92 92 92 92 93 9A 9A  ........
        .byte   $94,$92,$92,$92,$92,$92,$92,$92 ; B4F0 94 92 92 92 92 92 92 92  ........
        .byte   $92,$92,$92,$93,$9A,$9A,$9A,$9A ; B4F8 92 92 92 93 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$97,$95,$95,$95,$95,$95 ; B500 9A 9A 97 95 95 95 95 95  ........
        .byte   $95,$95,$95,$95,$95,$96,$9A,$9A ; B508 95 95 95 95 95 96 9A 9A  ........
        .byte   $9A,$9A,$97,$95,$95,$95,$95,$95 ; B510 9A 9A 97 95 95 95 95 95  ........
        .byte   $95,$96,$9A,$9A,$9A,$9A,$9A,$9A ; B518 95 96 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$91,$64,$65,$66,$67,$68 ; B520 9A 9A 91 64 65 66 67 68  ...defgh
        .byte   $69,$6A,$6B,$6C,$6D,$90,$9A,$9A ; B528 69 6A 6B 6C 6D 90 9A 9A  ijklm...
        .byte   $9A,$9A,$91,$64,$65,$66,$67,$68 ; B530 9A 9A 91 64 65 66 67 68  ...defgh
        .byte   $69,$90,$9A,$9A,$9A,$9A,$9A,$9A ; B538 69 90 9A 9A 9A 9A 9A 9A  i.......
        .byte   $9A,$9A,$91,$74,$75,$76,$77,$78 ; B540 9A 9A 91 74 75 76 77 78  ...tuvwx
        .byte   $79,$7A,$7B,$7C,$7D,$90,$9A,$9A ; B548 79 7A 7B 7C 7D 90 9A 9A  yz{|}...
        .byte   $9A,$9A,$91,$74,$75,$76,$77,$78 ; B550 9A 9A 91 74 75 76 77 78  ...tuvwx
        .byte   $79,$90,$9A,$9A,$9A,$9A,$9A,$9A ; B558 79 90 9A 9A 9A 9A 9A 9A  y.......
        .byte   $9A,$9A,$91,$6E,$6F,$80,$81,$84 ; B560 9A 9A 91 6E 6F 80 81 84  ...no...
        .byte   $85,$88,$89,$8C,$8D,$90,$9A,$9A ; B568 85 88 89 8C 8D 90 9A 9A  ........
        .byte   $9A,$9A,$91,$6A,$6B,$6C,$6D,$6E ; B570 9A 9A 91 6A 6B 6C 6D 6E  ...jklmn
        .byte   $6F,$90,$9A,$9A,$9A,$9A,$9A,$9A ; B578 6F 90 9A 9A 9A 9A 9A 9A  o.......
        .byte   $9A,$9A,$91,$7E,$7F,$82,$83,$86 ; B580 9A 9A 91 7E 7F 82 83 86  ...~....
        .byte   $87,$8A,$8B,$8E,$8F,$90,$9A,$9A ; B588 87 8A 8B 8E 8F 90 9A 9A  ........
        .byte   $9A,$9A,$91,$7A,$7B,$7C,$7D,$7E ; B590 9A 9A 91 7A 7B 7C 7D 7E  ...z{|}~
        .byte   $7F,$90,$9A,$9A,$9A,$9A,$9A,$9A ; B598 7F 90 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$94,$92,$92,$92,$92,$92 ; B5A0 9A 9A 94 92 92 92 92 92  ........
        .byte   $92,$92,$92,$92,$92,$93,$9A,$9A ; B5A8 92 92 92 92 92 93 9A 9A  ........
        .byte   $9A,$9A,$94,$92,$92,$92,$92,$92 ; B5B0 9A 9A 94 92 92 92 92 92  ........
        .byte   $92,$93,$9A,$9A,$9A,$9A,$9A,$9A ; B5B8 92 93 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B5C0 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B5C8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B5D0 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B5D8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B5E0 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B5E8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B5F0 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B5F8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B600 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $97,$95,$95,$95,$95,$95,$95,$95 ; B608 97 95 95 95 95 95 95 95  ........
        .byte   $95,$95,$95,$96,$9A,$9A,$9A,$9A ; B610 95 95 95 96 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B618 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B620 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $91,$2D,$2D,$46,$47,$48,$49,$4A ; B628 91 2D 2D 46 47 48 49 4A  .--FGHIJ
        .byte   $2D,$2D,$2D,$90,$9A,$9A,$9A,$9A ; B630 2D 2D 2D 90 9A 9A 9A 9A  ---.....
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B638 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B640 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $91,$2C,$2C,$56,$57,$58,$59,$5A ; B648 91 2C 2C 56 57 58 59 5A  .,,VWXYZ
        .byte   $2C,$2C,$2C,$90,$9A,$9A,$9A,$9A ; B650 2C 2C 2C 90 9A 9A 9A 9A  ,,,.....
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B658 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B660 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $94,$92,$92,$92,$92,$92,$92,$92 ; B668 94 92 92 92 92 92 92 92  ........
        .byte   $92,$92,$92,$93,$9A,$93,$9A,$9A ; B670 92 92 92 93 9A 93 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B678 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$97,$95,$95,$95 ; B680 9A 9A 9A 9A 97 95 95 95  ........
        .byte   $95,$95,$95,$95,$95,$95,$95,$95 ; B688 95 95 95 95 95 95 95 95  ........
        .byte   $95,$95,$95,$95,$95,$95,$95,$96 ; B690 95 95 95 95 95 95 95 96  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B698 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$91,$2D,$2D,$2D ; B6A0 9A 9A 9A 9A 91 2D 2D 2D  .....---
        .byte   $2D,$2D,$48,$49,$2F,$4E,$62,$4A ; B6A8 2D 2D 48 49 2F 4E 62 4A  --HI/NbJ
        .byte   $4E,$2D,$2D,$2D,$2D,$2D,$2D,$90 ; B6B0 4E 2D 2D 2D 2D 2D 2D 90  N------.
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B6B8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$91,$2C,$2C,$2C ; B6C0 9A 9A 9A 9A 91 2C 2C 2C  .....,,,
        .byte   $2C,$2C,$58,$59,$2E,$5E,$72,$5A ; B6C8 2C 2C 58 59 2E 5E 72 5A  ,,XY.^rZ
        .byte   $5E,$2C,$2C,$2C,$2C,$2C,$2C,$90 ; B6D0 5E 2C 2C 2C 2C 2C 2C 90  ^,,,,,,.
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B6D8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$91,$2D,$2D,$2D ; B6E0 9A 9A 9A 9A 91 2D 2D 2D  .....---
        .byte   $2D,$2D,$4B,$4E,$4A,$2B,$62,$61 ; B6E8 2D 2D 4B 4E 4A 2B 62 61  --KNJ+ba
        .byte   $4B,$4F,$49,$48,$2D,$2D,$2D,$90 ; B6F0 4B 4F 49 48 2D 2D 2D 90  KOIH---.
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B6F8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$91,$2C,$2C,$2C ; B700 9A 9A 9A 9A 91 2C 2C 2C  .....,,,
        .byte   $2C,$2C,$5B,$5E,$5A,$72,$72,$71 ; B708 2C 2C 5B 5E 5A 72 72 71  ,,[^Zrrq
        .byte   $5B,$5F,$59,$58,$2C,$2C,$2C,$90 ; B710 5B 5F 59 58 2C 2C 2C 90  [_YX,,,.
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B718 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$91,$2D,$2D,$2D ; B720 9A 9A 9A 9A 91 2D 2D 2D  .....---
        .byte   $2D,$2D,$3F,$4C,$4F,$49,$62,$3F ; B728 2D 2D 3F 4C 4F 49 62 3F  --?LOIb?
        .byte   $4C,$2D,$2D,$2D,$2D,$2D,$2D,$90 ; B730 4C 2D 2D 2D 2D 2D 2D 90  L------.
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B738 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$91,$2C,$2C,$2C ; B740 9A 9A 9A 9A 91 2C 2C 2C  .....,,,
        .byte   $2C,$2C,$5F,$5C,$5F,$59,$72,$5F ; B748 2C 2C 5F 5C 5F 59 72 5F  ,,_\_Yr_
        .byte   $5C,$2C,$2C,$2C,$2C,$2C,$2C,$90 ; B750 5C 2C 2C 2C 2C 2C 2C 90  \,,,,,,.
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B758 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$91,$2D,$2D,$2D ; B760 9A 9A 9A 9A 91 2D 2D 2D  .....---
        .byte   $2D,$2D,$4B,$4F,$61,$49,$3F,$4C ; B768 2D 2D 4B 4F 61 49 3F 4C  --KOaI?L
        .byte   $2D,$2D,$2D,$2D,$2D,$2D,$2D,$90 ; B770 2D 2D 2D 2D 2D 2D 2D 90  -------.
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B778 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$91,$2C,$2C,$2C ; B780 9A 9A 9A 9A 91 2C 2C 2C  .....,,,
        .byte   $2C,$2C,$5B,$5F,$71,$59,$5F,$5C ; B788 2C 2C 5B 5F 71 59 5F 5C  ,,[_qY_\
        .byte   $2C,$2C,$2C,$2C,$2C,$2C,$2C,$90 ; B790 2C 2C 2C 2C 2C 2C 2C 90  ,,,,,,,.
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B798 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$94,$92,$92,$92 ; B7A0 9A 9A 9A 9A 94 92 92 92  ........
        .byte   $92,$92,$92,$92,$92,$92,$92,$92 ; B7A8 92 92 92 92 92 92 92 92  ........
        .byte   $92,$92,$92,$92,$92,$92,$92,$93 ; B7B0 92 92 92 92 92 92 92 93  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B7B8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B7C0 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B7C8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B7D0 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$00 ; B7D8 9A 9A 9A 9A 9A 9A 9A 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; B7E0 00 00 00 00 00 00 00 00  ........
        .byte   $0F,$0F,$03,$0C,$0F,$0F,$00,$00 ; B7E8 0F 0F 03 0C 0F 0F 00 00  ........
        .byte   $FF,$FF,$33,$00,$FF,$33,$00,$00 ; B7F0 FF FF 33 00 FF 33 00 00  ..3..3..
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; B7F8 00 00 00 00 00 00 00 00  ........
        .byte   $00,$0C,$0F,$0F,$00,$00,$00,$00 ; B800 00 0C 0F 0F 00 00 00 00  ........
        .byte   $CC,$FF,$FF,$FF,$FF,$00,$00,$00 ; B808 CC FF FF FF FF 00 00 00  ........
        .byte   $CC,$FF,$FF,$FF,$FF,$00,$00,$00 ; B810 CC FF FF FF FF 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$9A ; B818 00 00 00 00 00 00 00 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B820 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B828 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B830 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B838 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B840 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B848 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B850 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B858 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B860 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $D4,$98,$92,$92,$92,$92,$92,$92 ; B868 D4 98 92 92 92 92 92 92  ........
        .byte   $92,$92,$92,$92,$99,$9A,$9A,$9A ; B870 92 92 92 92 99 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B878 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B880 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $D4,$90,$97,$95,$95,$95,$95,$95 ; B888 D4 90 97 95 95 95 95 95  ........
        .byte   $95,$95,$95,$96,$91,$9A,$9A,$9A ; B890 95 95 95 96 91 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B898 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B8A0 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $D4,$90,$91,$00,$40,$41,$42,$43 ; B8A8 D4 90 91 00 40 41 42 43  ....@ABC
        .byte   $44,$45,$00,$90,$91,$9A,$9A,$9A ; B8B0 44 45 00 90 91 9A 9A 9A  DE......
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B8B8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B8C0 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $D4,$90,$91,$00,$50,$51,$50,$53 ; B8C8 D4 90 91 00 50 51 50 53  ....PQPS
        .byte   $50,$55,$00,$90,$91,$9A,$9A,$9A ; B8D0 50 55 00 90 91 9A 9A 9A  PU......
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B8D8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B8E0 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $D4,$90,$94,$92,$92,$92,$92,$92 ; B8E8 D4 90 94 92 92 92 92 92  ........
        .byte   $92,$92,$92,$93,$91,$9A,$9A,$9A ; B8F0 92 92 92 93 91 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B8F8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B900 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $D4,$90,$9A,$9A,$9A,$9A,$9A,$9A ; B908 D4 90 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$91,$9A,$9A,$9A ; B910 9A 9A 9A 9A 91 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B918 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $D4,$98,$92,$92,$92,$92,$92,$92 ; B920 D4 98 92 92 92 92 92 92  ........
        .byte   $92,$93,$9A,$9A,$9A,$9A,$9A,$9A ; B928 92 93 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$94,$92,$92,$92 ; B930 9A 9A 9A 9A 94 92 92 92  ........
        .byte   $92,$92,$92,$92,$99,$9A,$9A,$9A ; B938 92 92 92 92 99 9A 9A 9A  ........
        .byte   $D4,$90,$9A,$9A,$9A,$9A,$9A,$9A ; B940 D4 90 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B948 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; B950 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$91,$9A,$9A,$9A ; B958 9A 9A 9A 9A 91 9A 9A 9A  ........
        .byte   $D4,$90,$97,$95,$95,$95,$95,$95 ; B960 D4 90 97 95 95 95 95 95  ........
        .byte   $95,$95,$95,$95,$95,$95,$95,$95 ; B968 95 95 95 95 95 95 95 95  ........
        .byte   $95,$95,$95,$95,$95,$95,$95,$95 ; B970 95 95 95 95 95 95 95 95  ........
        .byte   $95,$95,$95,$96,$91,$9A,$9A,$9A ; B978 95 95 95 96 91 9A 9A 9A  ........
        .byte   $D4,$90,$91,$18,$0B,$17,$0F,$32 ; B980 D4 90 91 18 0B 17 0F 32  .......2
        .byte   $32,$32,$1D,$0D,$0A,$1C,$0F,$32 ; B988 32 32 1D 0D 0A 1C 0F 32  22.....2
        .byte   $1C,$19,$1F,$18,$0E,$32,$1D,$1E ; B990 1C 19 1F 18 0E 32 1D 1E  .....2..
        .byte   $0B,$11,$0F,$90,$91,$9A,$9A,$9A ; B998 0B 11 0F 90 91 9A 9A 9A  ........
        .byte   $D4,$90,$94,$92,$92,$92,$92,$92 ; B9A0 D4 90 94 92 92 92 92 92  ........
        .byte   $92,$92,$92,$92,$92,$92,$92,$92 ; B9A8 92 92 92 92 92 92 92 92  ........
        .byte   $92,$92,$92,$92,$92,$92,$92,$92 ; B9B0 92 92 92 92 92 92 92 92  ........
        .byte   $92,$92,$92,$93,$91,$9A,$9A,$9A ; B9B8 92 92 92 93 91 9A 9A 9A  ........
        .byte   $D4,$90,$97,$95,$95,$95,$95,$95 ; B9C0 D4 90 97 95 95 95 95 95  ........
        .byte   $95,$95,$95,$95,$95,$95,$95,$95 ; B9C8 95 95 95 95 95 95 95 95  ........
        .byte   $95,$95,$95,$95,$95,$95,$95,$95 ; B9D0 95 95 95 95 95 95 95 95  ........
        .byte   $95,$95,$95,$96,$91,$9A,$9A,$9A ; B9D8 95 95 95 96 91 9A 9A 9A  ........
        .byte   $D4,$90,$91,$32,$32,$32,$32,$32 ; B9E0 D4 90 91 32 32 32 32 32  ...22222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B9E8 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; B9F0 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$90,$91,$9A,$9A,$9A ; B9F8 32 32 32 90 91 9A 9A 9A  222.....
        .byte   $D4,$90,$91,$32,$32,$32,$32,$32 ; BA00 D4 90 91 32 32 32 32 32  ...22222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BA08 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BA10 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$90,$91,$9A,$9A,$9A ; BA18 32 32 32 90 91 9A 9A 9A  222.....
        .byte   $D4,$90,$91,$32,$32,$32,$32,$32 ; BA20 D4 90 91 32 32 32 32 32  ...22222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BA28 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BA30 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$90,$91,$9A,$9A,$9A ; BA38 32 32 32 90 91 9A 9A 9A  222.....
        .byte   $D4,$90,$91,$32,$32,$32,$32,$32 ; BA40 D4 90 91 32 32 32 32 32  ...22222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BA48 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BA50 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$90,$91,$9A,$9A,$9A ; BA58 32 32 32 90 91 9A 9A 9A  222.....
        .byte   $D4,$90,$91,$32,$32,$32,$32,$32 ; BA60 D4 90 91 32 32 32 32 32  ...22222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BA68 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BA70 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$90,$91,$9A,$9A,$9A ; BA78 32 32 32 90 91 9A 9A 9A  222.....
        .byte   $D4,$90,$91,$32,$32,$32,$32,$32 ; BA80 D4 90 91 32 32 32 32 32  ...22222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BA88 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BA90 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$90,$91,$9A,$9A,$9A ; BA98 32 32 32 90 91 9A 9A 9A  222.....
        .byte   $D4,$90,$91,$32,$32,$32,$32,$32 ; BAA0 D4 90 91 32 32 32 32 32  ...22222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BAA8 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BAB0 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$90,$91,$9A,$9A,$9A ; BAB8 32 32 32 90 91 9A 9A 9A  222.....
        .byte   $D4,$90,$91,$32,$32,$32,$32,$32 ; BAC0 D4 90 91 32 32 32 32 32  ...22222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BAC8 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BAD0 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$90,$91,$9A,$9A,$9A ; BAD8 32 32 32 90 91 9A 9A 9A  222.....
        .byte   $D4,$90,$91,$32,$32,$32,$32,$32 ; BAE0 D4 90 91 32 32 32 32 32  ...22222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BAE8 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BAF0 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$90,$91,$9A,$9A,$9A ; BAF8 32 32 32 90 91 9A 9A 9A  222.....
        .byte   $D4,$90,$91,$32,$32,$32,$32,$32 ; BB00 D4 90 91 32 32 32 32 32  ...22222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BB08 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$32,$32,$32,$32,$32 ; BB10 32 32 32 32 32 32 32 32  22222222
        .byte   $32,$32,$32,$90,$91,$9A,$9A,$9A ; BB18 32 32 32 90 91 9A 9A 9A  222.....
        .byte   $D4,$90,$94,$92,$92,$92,$92,$92 ; BB20 D4 90 94 92 92 92 92 92  ........
        .byte   $92,$92,$92,$92,$92,$92,$92,$92 ; BB28 92 92 92 92 92 92 92 92  ........
        .byte   $92,$92,$92,$92,$92,$92,$92,$92 ; BB30 92 92 92 92 92 92 92 92  ........
        .byte   $92,$92,$92,$93,$91,$9A,$9A,$9A ; BB38 92 92 92 93 91 9A 9A 9A  ........
        .byte   $D4,$9E,$CF,$CF,$CF,$CF,$CF,$CF ; BB40 D4 9E CF CF CF CF CF CF  ........
        .byte   $CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF ; BB48 CF CF CF CF CF CF CF CF  ........
        .byte   $CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF ; BB50 CF CF CF CF CF CF CF CF  ........
        .byte   $CF,$CF,$CF,$CF,$9F,$9A,$9A,$9A ; BB58 CF CF CF CF 9F 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; BB60 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; BB68 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; BB70 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; BB78 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; BB80 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; BB88 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; BB90 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; BB98 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; BBA0 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; BBA8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; BBB0 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; BBB8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; BBC0 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; BBC8 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$9A ; BBD0 9A 9A 9A 9A 9A 9A 9A 9A  ........
        .byte   $9A,$9A,$9A,$9A,$9A,$9A,$9A,$00 ; BBD8 9A 9A 9A 9A 9A 9A 9A 00  ........
        .byte   $00,$40,$50,$50,$10,$00,$00,$00 ; BBE0 00 40 50 50 10 00 00 00  .@PP....
        .byte   $00,$44,$5A,$5A,$11,$00,$00,$44 ; BBE8 00 44 5A 5A 11 00 00 44  .DZZ...D
        .byte   $55,$55,$55,$55,$55,$55,$11,$44 ; BBF0 55 55 55 55 55 55 11 44  UUUUUU.D
        .byte   $55,$55,$55,$55,$55,$55,$11,$44 ; BBF8 55 55 55 55 55 55 11 44  UUUUUU.D
        .byte   $55,$55,$55,$55,$55,$55,$11,$44 ; BC00 55 55 55 55 55 55 11 44  UUUUUU.D
        .byte   $55,$55,$55,$55,$55,$55,$11,$04 ; BC08 55 55 55 55 55 55 11 04  UUUUUU..
        .byte   $05,$05,$05,$05,$05,$05,$01,$00 ; BC10 05 05 05 05 05 05 01 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00     ; BC18 00 00 00 00 00 00 00     .......
LBC1F:
        .byte   $AE,$16,$06,$D0,$05,$CD,$13,$06 ; BC1F AE 16 06 D0 05 CD 13 06  ........
        .byte   $F0                             ; BC27 F0                       .
; ----------------------------------------------------------------------------
        bit     $138D                           ; BC28 2C 8D 13                 ,..
        asl     $C9                             ; BC2B 06 C9                    ..
        .byte   $FF                             ; BC2D FF                       .
        beq     LBC56                           ; BC2E F0 26                    .&
        lda     #$00                            ; BC30 A9 00                    ..
        sta     $0616                           ; BC32 8D 16 06                 ...
        sta     $0612                           ; BC35 8D 12 06                 ...
        ldy     #$3C                            ; BC38 A0 3C                    .<
        lda     #$00                            ; BC3A A9 00                    ..
LBC3C:
        sta     $05D4,y                         ; BC3C 99 D4 05                 ...
        dey                                     ; BC3F 88                       .
        bpl     LBC3C                           ; BC40 10 FA                    ..
        lda     $0613                           ; BC42 AD 13 06                 ...
        jsr     LBD55                           ; BC45 20 55 BD                  U.
        jsr     LC334                           ; BC48 20 34 C3                  4.
        lda     #$0F                            ; BC4B A9 0F                    ..
        sta     SND_CHN                         ; BC4D 8D 15 40                 ..@
        lda     #$FF                            ; BC50 A9 FF                    ..
        sta     $0612                           ; BC52 8D 12 06                 ...
        rts                                     ; BC55 60                       `

; ----------------------------------------------------------------------------
LBC56:
        lda     #$00                            ; BC56 A9 00                    ..
        sta     $0616                           ; BC58 8D 16 06                 ...
        sta     $0612                           ; BC5B 8D 12 06                 ...
        sta     $05FD                           ; BC5E 8D FD 05                 ...
        sta     $05E9                           ; BC61 8D E9 05                 ...
        sta     $05D5                           ; BC64 8D D5 05                 ...
        ldx     #$0F                            ; BC67 A2 0F                    ..
LBC69:
        sta     SQ1_VOL,x                       ; BC69 9D 00 40                 ..@
        dex                                     ; BC6C CA                       .
        bpl     LBC69                           ; BC6D 10 FA                    ..
        stx     $0613                           ; BC6F 8E 13 06                 ...
        rts                                     ; BC72 60                       `

; ----------------------------------------------------------------------------
LBC73:
        lda     $0612                           ; BC73 AD 12 06                 ...
        bne     LBC79                           ; BC76 D0 01                    ..
        rts                                     ; BC78 60                       `

; ----------------------------------------------------------------------------
LBC79:
        lda     $0616                           ; BC79 AD 16 06                 ...
        beq     LBCAE                           ; BC7C F0 30                    .0
        dec     $0617                           ; BC7E CE 17 06                 ...
        bne     LBCAE                           ; BC81 D0 2B                    .+
        sta     $0617                           ; BC83 8D 17 06                 ...
        ldx     $05D7                           ; BC86 AE D7 05                 ...
        dex                                     ; BC89 CA                       .
        stx     $05D7                           ; BC8A 8E D7 05                 ...
        stx     $05EB                           ; BC8D 8E EB 05                 ...
        stx     $05FF                           ; BC90 8E FF 05                 ...
        cpx     $05D6                           ; BC93 EC D6 05                 ...
        bcs     LBC9B                           ; BC96 B0 03                    ..
        stx     $05D6                           ; BC98 8E D6 05                 ...
LBC9B:
        cpx     $05EA                           ; BC9B EC EA 05                 ...
        bcs     LBCA3                           ; BC9E B0 03                    ..
        stx     $05EA                           ; BCA0 8E EA 05                 ...
LBCA3:
        cpx     $05FE                           ; BCA3 EC FE 05                 ...
        bcs     LBCAB                           ; BCA6 B0 03                    ..
        stx     $05FE                           ; BCA8 8E FE 05                 ...
LBCAB:
        txa                                     ; BCAB 8A                       .
        beq     LBC56                           ; BCAC F0 A8                    ..
LBCAE:
        ldx     #$00                            ; BCAE A2 00                    ..
        jsr     LC006                           ; BCB0 20 06 C0                  ..
        ldx     #$14                            ; BCB3 A2 14                    ..
        jsr     LC006                           ; BCB5 20 06 C0                  ..
        ldx     #$28                            ; BCB8 A2 28                    .(
        jsr     LC006                           ; BCBA 20 06 C0                  ..
        jsr     LC2ED                           ; BCBD 20 ED C2                  ..
        jsr     LC1FF                           ; BCC0 20 FF C1                  ..
        jsr     LC21D                           ; BCC3 20 1D C2                  ..
        jsr     LBCCA                           ; BCC6 20 CA BC                  ..
        rts                                     ; BCC9 60                       `

; ----------------------------------------------------------------------------
LBCCA:
        ldx     #$00                            ; BCCA A2 00                    ..
        jsr     LBCF5                           ; BCCC 20 F5 BC                  ..
        ldx     #$14                            ; BCCF A2 14                    ..
        jsr     LBCF5                           ; BCD1 20 F5 BC                  ..
        ldx     #$28                            ; BCD4 A2 28                    .(
        lda     $05D5,x                         ; BCD6 BD D5 05                 ...
        cmp     $05D6,x                         ; BCD9 DD D6 05                 ...
        beq     LBCF4                           ; BCDC F0 16                    ..
        bcc     LBCE9                           ; BCDE 90 09                    ..
        lda     #$00                            ; BCE0 A9 00                    ..
        sta     $05D5,x                         ; BCE2 9D D5 05                 ...
        sta     TRI_LINEAR                      ; BCE5 8D 08 40                 ..@
        rts                                     ; BCE8 60                       `

; ----------------------------------------------------------------------------
LBCE9:
        lda     #$FF                            ; BCE9 A9 FF                    ..
        sta     TRI_LINEAR                      ; BCEB 8D 08 40                 ..@
        lda     $05D6,x                         ; BCEE BD D6 05                 ...
        sta     $05D5,x                         ; BCF1 9D D5 05                 ...
LBCF4:
        rts                                     ; BCF4 60                       `

; ----------------------------------------------------------------------------
LBCF5:
        lda     $05E7,x                         ; BCF5 BD E7 05                 ...
        and     #$30                            ; BCF8 29 30                    )0
        cmp     #$30                            ; BCFA C9 30                    .0
        beq     LBD15                           ; BCFC F0 17                    ..
        lda     $05D5,x                         ; BCFE BD D5 05                 ...
        cmp     $05D6,x                         ; BD01 DD D6 05                 ...
        beq     LBD40                           ; BD04 F0 3A                    .:
        bcs     LBD0E                           ; BD06 B0 06                    ..
        .byte   $A9,$00,$9D,$D5,$05,$60         ; BD08 A9 00 9D D5 05 60        .....`
LBD0E:
        .byte   $BD,$D5,$05,$9D,$D6,$05,$60     ; BD0E BD D5 05 9D D6 05 60     ......`
LBD15:
        .byte   $BD,$D5,$05,$DD,$D6,$05,$F0,$23 ; BD15 BD D5 05 DD D6 05 F0 23  .......#
        .byte   $30                             ; BD1D 30                       0
; ----------------------------------------------------------------------------
        .byte   $12                             ; BD1E 12                       .
        clc                                     ; BD1F 18                       .
        adc     $05D9,x                         ; BD20 7D D9 05                 }..
        cmp     $05D6,x                         ; BD23 DD D6 05                 ...
        bpl     LBD2B                           ; BD26 10 03                    ..
        lda     $05D6,x                         ; BD28 BD D6 05                 ...
LBD2B:
        sta     $05D5,x                         ; BD2B 9D D5 05                 ...
        jmp     LBD43                           ; BD2E 4C 43 BD                 LC.

; ----------------------------------------------------------------------------
        .byte   $18,$7D,$D8                     ; BD31 18 7D D8                 .}.
; ----------------------------------------------------------------------------
        ora     $DD                             ; BD34 05 DD                    ..
        dec     $05,x                           ; BD36 D6 05                    ..
        bmi     LBD3D                           ; BD38 30 03                    0.
        lda     $05D6,x                         ; BD3A BD D6 05                 ...
LBD3D:
        sta     $05D5,x                         ; BD3D 9D D5 05                 ...
LBD40:
        lda     $05D5,x                         ; BD40 BD D5 05                 ...
LBD43:
        ldy     $05E5,x                         ; BD43 BC E5 05                 ...
        beq     LBD49                           ; BD46 F0 01                    ..
        rts                                     ; BD48 60                       `

; ----------------------------------------------------------------------------
LBD49:
        ldy     $05E6,x                         ; BD49 BC E6 05                 ...
        lsr     a                               ; BD4C 4A                       J
        lsr     a                               ; BD4D 4A                       J
        ora     $05E7,x                         ; BD4E 1D E7 05                 ...
        sta     SQ1_VOL,y                       ; BD51 99 00 40                 ..@
        rts                                     ; BD54 60                       `

; ----------------------------------------------------------------------------
LBD55:
        ldy     #$00                            ; BD55 A0 00                    ..
        sty     $60                             ; BD57 84 60                    .`
        asl     a                               ; BD59 0A                       .
        rol     $60                             ; BD5A 26 60                    &`
        sta     $5F                             ; BD5C 85 5F                    ._
        asl     a                               ; BD5E 0A                       .
        rol     $60                             ; BD5F 26 60                    &`
        asl     a                               ; BD61 0A                       .
        rol     $60                             ; BD62 26 60                    &`
        clc                                     ; BD64 18                       .
        adc     $5F                             ; BD65 65 5F                    e_
        bcc     LBD6B                           ; BD67 90 02                    ..
        inc     $60                             ; BD69 E6 60                    .`
LBD6B:
        clc                                     ; BD6B 18                       .
        adc     #$E1                            ; BD6C 69 E1                    i.
        sta     $5F                             ; BD6E 85 5F                    ._
        lda     $60                             ; BD70 A5 60                    .`
        .byte   $69,$C3                         ; BD72 69 C3                    i.
; ----------------------------------------------------------------------------
        sta     $60                             ; BD74 85 60                    .`
        lda     ($5F),y                         ; BD76 B1 5F                    ._
        sta     $05D1                           ; BD78 8D D1 05                 ...
        iny                                     ; BD7B C8                       .
        lda     ($5F),y                         ; BD7C B1 5F                    ._
        sta     $05D2                           ; BD7E 8D D2 05                 ...
        iny                                     ; BD81 C8                       .
        lda     ($5F),y                         ; BD82 B1 5F                    ._
        sta     $05CB                           ; BD84 8D CB 05                 ...
        iny                                     ; BD87 C8                       .
        lda     ($5F),y                         ; BD88 B1 5F                    ._
        sta     $05CC                           ; BD8A 8D CC 05                 ...
        iny                                     ; BD8D C8                       .
        lda     ($5F),y                         ; BD8E B1 5F                    ._
        sta     $05DC                           ; BD90 8D DC 05                 ...
        iny                                     ; BD93 C8                       .
        lda     ($5F),y                         ; BD94 B1 5F                    ._
        sta     $05DD                           ; BD96 8D DD 05                 ...
        iny                                     ; BD99 C8                       .
        lda     ($5F),y                         ; BD9A B1 5F                    ._
        sta     $05F0                           ; BD9C 8D F0 05                 ...
        iny                                     ; BD9F C8                       .
        lda     ($5F),y                         ; BDA0 B1 5F                    ._
        sta     $05F1                           ; BDA2 8D F1 05                 ...
        iny                                     ; BDA5 C8                       .
        lda     ($5F),y                         ; BDA6 B1 5F                    ._
        sta     $0604                           ; BDA8 8D 04 06                 ...
        iny                                     ; BDAB C8                       .
        lda     ($5F),y                         ; BDAC B1 5F                    ._
        sta     $0605                           ; BDAE 8D 05 06                 ...
        lda     #$02                            ; BDB1 A9 02                    ..
        sta     $05DA                           ; BDB3 8D DA 05                 ...
        sta     $05EE                           ; BDB6 8D EE 05                 ...
        sta     $0602                           ; BDB9 8D 02 06                 ...
        sta     $05CA                           ; BDBC 8D CA 05                 ...
        lda     #$FF                            ; BDBF A9 FF                    ..
        sta     $05D0                           ; BDC1 8D D0 05                 ...
        lda     #$00                            ; BDC4 A9 00                    ..
        sta     $05E5                           ; BDC6 8D E5 05                 ...
        sta     $05F9                           ; BDC9 8D F9 05                 ...
        sta     $060D                           ; BDCC 8D 0D 06                 ...
        lda     #$B0                            ; BDCF A9 B0                    ..
        sta     $05E7                           ; BDD1 8D E7 05                 ...
        sta     $05FB                           ; BDD4 8D FB 05                 ...
        sta     $060F                           ; BDD7 8D 0F 06                 ...
        lda     #$1F                            ; BDDA A9 1F                    ..
        sta     $05D7                           ; BDDC 8D D7 05                 ...
        sta     $05EB                           ; BDDF 8D EB 05                 ...
        sta     $05FF                           ; BDE2 8D FF 05                 ...
        lda     #$02                            ; BDE5 A9 02                    ..
        sta     $0600                           ; BDE7 8D 00 06                 ...
        lda     #$FE                            ; BDEA A9 FE                    ..
        sta     $0601                           ; BDEC 8D 01 06                 ...
        lda     #$00                            ; BDEF A9 00                    ..
        sta     $05E6                           ; BDF1 8D E6 05                 ...
        lda     #$04                            ; BDF4 A9 04                    ..
        sta     $05FA                           ; BDF6 8D FA 05                 ...
        lda     #$08                            ; BDF9 A9 08                    ..
        sta     $060E                           ; BDFB 8D 0E 06                 ...
        rts                                     ; BDFE 60                       `

; ----------------------------------------------------------------------------
        brk                                     ; BDFF 00                       .
        .byte   $63                             ; BE00 63                       c
        dey                                     ; BE01 88                       .
        .byte   $FF                             ; BE02 FF                       .
        ldy     LFFFA+5,x                       ; BE03 BC FF FF                 ...
        .byte   $EF                             ; BE06 EF                       .
        .byte   $FF                             ; BE07 FF                       .
        .byte   $F0,$2E,$EC,$DD,$FF,$FF,$FF,$FF ; BE08 F0 2E EC DD FF FF FF FF  ........
        .byte   $E7,$EA,$F8,$F5,$FF,$FF,$FF,$FF ; BE10 E7 EA F8 F5 FF FF FF FF  ........
        .byte   $5F,$AE,$FF,$FE,$FF,$FF,$FF,$FF ; BE18 5F AE FF FE FF FF FF FF  _.......
        .byte   $D3,$8B,$DB,$EF,$FF,$FF,$FF,$F7 ; BE20 D3 8B DB EF FF FF FF F7  ........
        .byte   $0F,$D6,$FD,$FA,$FF,$FF,$FF,$FF ; BE28 0F D6 FD FA FF FF FF FF  ........
        .byte   $41,$0A,$6F,$FF,$F7,$FF,$FF,$FF ; BE30 41 0A 6F FF F7 FF FF FF  A.o.....
        .byte   $37,$87,$DB,$F8,$FF,$FF,$FF,$DF ; BE38 37 87 DB F8 FF FF FF DF  7.......
        .byte   $E3,$B0,$B3,$FF,$FF,$FF,$FF,$FF ; BE40 E3 B0 B3 FF FF FF FF FF  ........
        .byte   $06,$94,$DF,$DE,$FF,$FF,$FF,$7F ; BE48 06 94 DF DE FF FF FF 7F  ........
        .byte   $CE,$70,$FF,$FF,$FF,$FF,$FF,$FF ; BE50 CE 70 FF FF FF FF FF FF  .p......
        .byte   $2D,$E8,$D7,$FD,$FF,$FF,$FF,$FE ; BE58 2D E8 D7 FD FF FF FF FE  -.......
        .byte   $1A,$7C,$FE,$FF,$FF,$FF,$FF,$FF ; BE60 1A 7C FE FF FF FF FF FF  .|......
        .byte   $80,$92,$DD,$AF,$FF,$FF,$FF,$BF ; BE68 80 92 DD AF FF FF FF BF  ........
        .byte   $6C,$EB,$EF,$F7,$FF,$FF,$FF,$FE ; BE70 6C EB EF F7 FF FF FF FE  l.......
        .byte   $50,$2F,$FF,$FF,$FF,$FF,$FB,$FF ; BE78 50 2F FF FF FF FF FB FF  P/......
        .byte   $5D,$AA,$F2,$DF,$FF,$FF,$FF,$FF ; BE80 5D AA F2 DF FF FF FF FF  ].......
        .byte   $E6,$5E,$FF,$E2,$FF,$FF,$FF,$FF ; BE88 E6 5E FF E2 FF FF FF FF  .^......
        .byte   $75,$ED,$77,$E7,$FF,$FF,$FF,$FF ; BE90 75 ED 77 E7 FF FF FF FF  u.w.....
        .byte   $AE,$DF,$EF,$BC,$FF,$FF,$FF,$FF ; BE98 AE DF EF BC FF FF FF FF  ........
        .byte   $A4,$6A,$BA,$FF,$FF,$FF,$F7,$FF ; BEA0 A4 6A BA FF FF FF F7 FF  .j......
        .byte   $0D,$5D,$F3,$FC,$FF,$FF,$FF,$7F ; BEA8 0D 5D F3 FC FF FF FF 7F  .]......
        .byte   $92,$4C,$A6,$FF,$FF,$FF,$FF,$FF ; BEB0 92 4C A6 FF FF FF FF FF  .L......
        .byte   $FA,$B8,$FE,$F0,$FF,$FF,$FF,$FF ; BEB8 FA B8 FE F0 FF FF FF FF  ........
        .byte   $18,$D0,$F9,$EC,$FF,$BF,$CD,$FF ; BEC0 18 D0 F9 EC FF BF CD FF  ........
        .byte   $5B,$58,$6E,$EF,$FF,$FF,$FF,$FF ; BEC8 5B 58 6E EF FF FF FF FF  [Xn.....
        .byte   $F5,$6B,$97,$BE,$FF,$FF,$FF,$FF ; BED0 F5 6B 97 BE FF FF FF FF  .k......
        .byte   $32,$08,$FB,$AD,$FF,$FF,$FF,$FF ; BED8 32 08 FB AD FF FF FF FF  2.......
        .byte   $5D,$6A,$FD,$FB,$FF,$FE,$FF,$FF ; BEE0 5D 6A FD FB FF FE FF FF  ]j......
        .byte   $4D,$D1,$FF,$FE,$FF,$FF,$FF,$FF ; BEE8 4D D1 FF FE FF FF FF FF  M.......
        .byte   $FF,$81,$BC,$ED,$FF,$FF,$F7,$EE ; BEF0 FF 81 BC ED FF FF F7 EE  ........
        .byte   $6D,$F3,$EF,$FF,$FF,$FF,$FF,$FF ; BEF8 6D F3 EF FF FF FF FF FF  m.......
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF00 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF08 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF10 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF18 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$40,$00,$00,$00 ; BF20 00 00 00 00 40 00 00 00  ....@...
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF28 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF30 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF38 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$10,$00,$00 ; BF40 00 00 00 00 00 10 00 00  ........
        .byte   $00,$00,$00,$00,$20,$01,$00,$00 ; BF48 00 00 00 00 20 01 00 00  .... ...
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF50 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF58 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF60 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF68 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF70 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF78 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF80 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$04 ; BF88 00 00 00 00 00 00 00 04  ........
        .byte   $00,$00,$00,$00,$04,$00,$00,$00 ; BF90 00 00 00 00 04 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF98 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$01,$00,$00,$00 ; BFA0 00 00 00 00 01 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFA8 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFB0 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFB8 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFC0 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFC8 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFD0 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFD8 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$01,$00,$00,$00 ; BFE0 00 00 00 00 01 00 00 00  ........
        .byte   $00,$00,$00,$00,$01,$00,$00,$00 ; BFE8 00 00 00 00 01 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFF0 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$80 ; BFF8 00 00 00 00 00 00 00 80  ........
        .byte   $80                             ; C000 80                       .
; need to confirm.  Most likely for bus conflict avoidance
cnromBank:
        .byte   $00,$01                         ; C001 00 01                    ..
LC003:
        .byte   $01                             ; C003 01                       .
LC004:
        .byte   $00                             ; C004 00                       .
LC005:
        .byte   $00                             ; C005 00                       .
LC006:
        .byte   $AD,$12,$06,$D0,$01,$60,$BD,$E5 ; C006 AD 12 06 D0 01 60 BD E5  .....`..
        .byte   $05                             ; C00E 05                       .
; ----------------------------------------------------------------------------
        beq     LC014                           ; C00F F0 03                    ..
        dec     $05E5,x                         ; C011 DE E5 05                 ...
LC014:
        dec     $05DA,x                         ; C014 DE DA 05                 ...
        beq     LC024                           ; C017 F0 0B                    ..
        dec     $05DB,x                         ; C019 DE DB 05                 ...
        bne     LC023                           ; C01C D0 05                    ..
        lda     #$00                            ; C01E A9 00                    ..
        sta     $05D6,x                         ; C020 9D D6 05                 ...
LC023:
        rts                                     ; C023 60                       `

; ----------------------------------------------------------------------------
LC024:
        lda     $05DC,x                         ; C024 BD DC 05                 ...
        sta     $5F                             ; C027 85 5F                    ._
        lda     $05DD,x                         ; C029 BD DD 05                 ...
        sta     $60                             ; C02C 85 60                    .`
        jmp     LC03C                           ; C02E 4C 3C C0                 L<.

; ----------------------------------------------------------------------------
LC031:
        clc                                     ; C031 18                       .
        adc     $5F                             ; C032 65 5F                    e_
        sta     $5F                             ; C034 85 5F                    ._
        lda     #$00                            ; C036 A9 00                    ..
        adc     $60                             ; C038 65 60                    e`
        sta     $60                             ; C03A 85 60                    .`
LC03C:
        ldy     #$00                            ; C03C A0 00                    ..
        lda     ($5F),y                         ; C03E B1 5F                    ._
        bmi     LC072                           ; C040 30 30                    00
        sta     $05E3,x                         ; C042 9D E3 05                 ...
        lda     $05DA,x                         ; C045 BD DA 05                 ...
        lda     $05DA,x                         ; C048 BD DA 05                 ...
        bne     LC059                           ; C04B D0 0C                    ..
        lda     $05DE,x                         ; C04D BD DE 05                 ...
        sta     $05DA,x                         ; C050 9D DA 05                 ...
        lda     $05DF,x                         ; C053 BD DF 05                 ...
        sta     $05DB,x                         ; C056 9D DB 05                 ...
LC059:
        lda     $05D7,x                         ; C059 BD D7 05                 ...
        sta     $05D6,x                         ; C05C 9D D6 05                 ...
        clc                                     ; C05F 18                       .
        lda     #$01                            ; C060 A9 01                    ..
        adc     $5F                             ; C062 65 5F                    e_
        sta     $05DC,x                         ; C064 9D DC 05                 ...
        lda     #$00                            ; C067 A9 00                    ..
        adc     $60                             ; C069 65 60                    e`
        sta     $05DD,x                         ; C06B 9D DD 05                 ...
        jmp     LC278                           ; C06E 4C 78 C2                 Lx.

; ----------------------------------------------------------------------------
        rts                                     ; C071 60                       `

; ----------------------------------------------------------------------------
LC072:
        cmp     #$F0                            ; C072 C9 F0                    ..
        bpl     LC0F0                           ; C074 10 7A                    .z
        sec                                     ; C076 38                       8
        sbc     #$90                            ; C077 E9 90                    ..
        tay                                     ; C079 A8                       .
        .byte   $B9                             ; C07A B9                       .
; ----------------------------------------------------------------------------
        sta     ($C0),y                         ; C07B 91 C0                    ..
        sta     $05DB,x                         ; C07D 9D DB 05                 ...
        sta     $05DF,x                         ; C080 9D DF 05                 ...
        lda     LC0C1,y                         ; C083 B9 C1 C0                 ...
        sta     $05DA,x                         ; C086 9D DA 05                 ...
        sta     $05DE,x                         ; C089 9D DE 05                 ...
        lda     #$01                            ; C08C A9 01                    ..
        jmp     LC031                           ; C08E 4C 31 C0                 L1.

; ----------------------------------------------------------------------------
        ora     ($02,x)                         ; C091 01 02                    ..
        .byte   $03                             ; C093 03                       .
        .byte   $04                             ; C094 04                       .
        asl     $07                             ; C095 06 07                    ..
        asl     a                               ; C097 0A                       .
        ora     $150F                           ; C098 0D 0F 15                 ...
        .byte   $1D,$21,$2D,$3D,$45,$5D,$05,$08 ; C09B 1D 21 2D 3D 45 5D 05 08  .!-=E]..
        .byte   $09,$12,$13,$1C,$2B,$58,$58,$58 ; C0A3 09 12 13 1C 2B 58 58 58  ....+XXX
        .byte   $09,$21,$2D,$3D,$45,$5D,$01,$02 ; C0AB 09 21 2D 3D 45 5D 01 02  .!-=E]..
        .byte   $03,$04,$06,$07,$0A,$0D,$0F,$15 ; C0B3 03 04 06 07 0A 0D 0F 15  ........
        .byte   $1D,$21,$2D,$3D,$45,$5D         ; C0BB 1D 21 2D 3D 45 5D        .!-=E]
LC0C1:
        .byte   $01,$03,$04,$06,$08,$09,$0C,$10 ; C0C1 01 03 04 06 08 09 0C 10  ........
        .byte   $12,$18,$20,$24,$30,$40,$48,$60 ; C0C9 12 18 20 24 30 40 48 60  .. $0@H`
        .byte   $07,$0A,$0B,$14,$15,$1E,$2D,$5A ; C0D1 07 0A 0B 14 15 1E 2D 5A  ......-Z
        .byte   $5A,$5A,$5A,$5A,$5A,$5A,$5A,$5A ; C0D9 5A 5A 5A 5A 5A 5A 5A 5A  ZZZZZZZZ
        .byte   $06,$08,$09,$0C,$10,$12,$18,$20 ; C0E1 06 08 09 0C 10 12 18 20  ....... 
        .byte   $24,$30,$40,$48,$60,$90,$90     ; C0E9 24 30 40 48 60 90 90     $0@H`..
LC0F0:
        .byte   $38,$E9,$F7,$0A,$A8,$B9,$02,$C1 ; C0F0 38 E9 F7 0A A8 B9 02 C1  8.......
        .byte   $85                             ; C0F8 85                       .
; ----------------------------------------------------------------------------
        adc     ($B9,x)                         ; C0F9 61 B9                    a.
        .byte   $03                             ; C0FB 03                       .
        cmp     ($85,x)                         ; C0FC C1 85                    ..
        .byte   $62                             ; C0FE 62                       b
        jmp     (L0061)                         ; C0FF 6C 61 00                 la.

; ----------------------------------------------------------------------------
        .byte   $14                             ; C102 14                       .
        cmp     ($83,x)                         ; C103 C1 83                    ..
        cmp     ($75,x)                         ; C105 C1 75                    .u
        cmp     ($23,x)                         ; C107 C1 23                    .#
        cmp     ($49,x)                         ; C109 C1 49                    .I
        .byte   $C1,$35,$C1,$C7,$C1,$E5,$C1,$D3 ; C10B C1 35 C1 C7 C1 E5 C1 D3  .5......
        .byte   $C1,$A0,$01,$B1,$5F,$9D,$DA,$05 ; C113 C1 A0 01 B1 5F 9D DA 05  ...._...
        .byte   $9D,$DB                         ; C11B 9D DB                    ..
; ----------------------------------------------------------------------------
        ora     L00A9                           ; C11D 05 A9                    ..
        .byte   $02                             ; C11F 02                       .
        jmp     LC031                           ; C120 4C 31 C0                 L1.

; ----------------------------------------------------------------------------
        ldy     #$01                            ; C123 A0 01                    ..
        lda     ($5F),y                         ; C125 B1 5F                    ._
        sta     $05DA,x                         ; C127 9D DA 05                 ...
        iny                                     ; C12A C8                       .
        lda     ($5F),y                         ; C12B B1 5F                    ._
        .byte   $9D,$DB,$05,$A9,$03,$4C,$31,$C0 ; C12D 9D DB 05 A9 03 4C 31 C0  .....L1.
        .byte   $A5,$5F,$18,$69,$01,$9D,$E1,$05 ; C135 A5 5F 18 69 01 9D E1 05  ._.i....
        .byte   $A5,$60,$69,$00,$9D,$E2,$05,$A9 ; C13D A5 60 69 00 9D E2 05 A9  .`i.....
        .byte   $01,$4C,$31,$C0,$BD,$E0,$05,$F0 ; C145 01 4C 31 C0 BD E0 05 F0  .L1.....
        .byte   $14,$DE,$E0,$05,$F0,$1D,$BD,$E1 ; C14D 14 DE E0 05 F0 1D BD E1  ........
        .byte   $05,$85,$5F,$BD,$E2,$05,$85,$60 ; C155 05 85 5F BD E2 05 85 60  .._....`
        .byte   $A9,$00,$4C,$31,$C0,$A0,$01,$B1 ; C15D A9 00 4C 31 C0 A0 01 B1  ..L1....
        .byte   $5F,$F0,$08,$9D,$E0,$05,$DE,$E0 ; C165 5F F0 08 9D E0 05 DE E0  _.......
        .byte   $05,$D0,$E3,$A9,$02,$4C,$31,$C0 ; C16D 05 D0 E3 A9 02 4C 31 C0  .....L1.
        .byte   $A0,$01,$B1,$5F,$0A,$0A,$9D,$D7 ; C175 A0 01 B1 5F 0A 0A 9D D7  ..._....
        .byte   $05                             ; C17D 05                       .
; ----------------------------------------------------------------------------
        lda     #$02                            ; C17E A9 02                    ..
        jmp     LC031                           ; C180 4C 31 C0                 L1.

; ----------------------------------------------------------------------------
        ldy     #$01                            ; C183 A0 01                    ..
        lda     ($5F),y                         ; C185 B1 5F                    ._
        asl     a                               ; C187 0A                       .
        asl     a                               ; C188 0A                       .
        tay                                     ; C189 A8                       .
        lda     LC1A7,y                         ; C18A B9 A7 C1                 ...
        sta     $05D8,x                         ; C18D 9D D8 05                 ...
        lda     LC1A8,y                         ; C190 B9 A8 C1                 ...
        sta     $05D9,x                         ; C193 9D D9 05                 ...
        lda     LC1A9,y                         ; C196 B9 A9 C1                 ...
        sta     $05E7,x                         ; C199 9D E7 05                 ...
        lda     LC1AA,y                         ; C19C B9 AA C1                 ...
        sta     $05E4,x                         ; C19F 9D E4 05                 ...
        lda     #$02                            ; C1A2 A9 02                    ..
        jmp     LC031                           ; C1A4 4C 31 C0                 L1.

; ----------------------------------------------------------------------------
LC1A7:
        .byte   $1F                             ; C1A7 1F                       .
LC1A8:
LC1A9           := * + 1
LC1AA           := * + 2
        inc     LFFB0,x                         ; C1A8 FE B0 FF                 ...
        .byte   $0F                             ; C1AB 0F                       .
        .byte   $FF                             ; C1AC FF                       .
        bvs     LC1AF                           ; C1AD 70 00                    p.
LC1AF:
        .byte   $0F                             ; C1AF 0F                       .
        .byte   $FF,$70,$FF,$07,$FF,$30,$00,$0F ; C1B0 FF 70 FF 07 FF 30 00 0F  .p...0..
        .byte   $FF,$0F,$00,$0A,$FF,$B0,$00,$05 ; C1B8 FF 0F 00 0A FF B0 00 05  ........
        .byte   $FF,$30,$00,$0F,$FF,$82,$00,$A0 ; C1C0 FF 30 00 0F FF 82 00 A0  .0......
        .byte   $01,$B1,$5F,$9D,$E4,$05,$A9,$02 ; C1C8 01 B1 5F 9D E4 05 A9 02  .._.....
        .byte   $4C,$31,$C0,$A0,$01,$B1,$5F,$48 ; C1D0 4C 31 C0 A0 01 B1 5F 48  L1...._H
        .byte   $C8,$B1,$5F,$85                 ; C1D8 C8 B1 5F 85              .._.
; ----------------------------------------------------------------------------
        rts                                     ; C1DC 60                       `

; ----------------------------------------------------------------------------
        pla                                     ; C1DD 68                       h
        sta     $5F                             ; C1DE 85 5F                    ._
        lda     #$00                            ; C1E0 A9 00                    ..
        jmp     LC031                           ; C1E2 4C 31 C0                 L1.

; ----------------------------------------------------------------------------
        lda     #$00                            ; C1E5 A9 00                    ..
        sta     $0612                           ; C1E7 8D 12 06                 ...
        sta     $0613                           ; C1EA 8D 13 06                 ...
        dec     $0613                           ; C1ED CE 13 06                 ...
        sta     SND_CHN                         ; C1F0 8D 15 40                 ..@
        ldy     #$0C                            ; C1F3 A0 0C                    ..
LC1F5:
        sta     SQ1_VOL,y                       ; C1F5 99 00 40                 ..@
        dey                                     ; C1F8 88                       .
        dey                                     ; C1F9 88                       .
        dey                                     ; C1FA 88                       .
        dey                                     ; C1FB 88                       .
        bpl     LC1F5                           ; C1FC 10 F7                    ..
        rts                                     ; C1FE 60                       `

; ----------------------------------------------------------------------------
LC1FF:
        lda     $0610                           ; C1FF AD 10 06                 ...
        tay                                     ; C202 A8                       .
        lda     LC217,y                         ; C203 B9 17 C2                 ...
        sta     $0611                           ; C206 8D 11 06                 ...
        iny                                     ; C209 C8                       .
        cpy     #$06                            ; C20A C0 06                    ..
        bcc     LC210                           ; C20C 90 02                    ..
        ldy     #$00                            ; C20E A0 00                    ..
LC210:
        tya                                     ; C210 98                       .
        and     #$0F                            ; C211 29 0F                    ).
        sta     $0610                           ; C213 8D 10 06                 ...
        rts                                     ; C216 60                       `

; ----------------------------------------------------------------------------
LC217:
        bpl     LC225                           ; C217 10 0C                    ..
        php                                     ; C219 08                       .
        brk                                     ; C21A 00                       .
        php                                     ; C21B 08                       .
        .byte   $0C                             ; C21C 0C                       .
LC21D:
        ldx     #$00                            ; C21D A2 00                    ..
        jsr     LC229                           ; C21F 20 29 C2                  ).
        .byte   $A2,$14,$20                     ; C222 A2 14 20                 .. 
LC225:
        .byte   $29                             ; C225 29                       )
; ----------------------------------------------------------------------------
        .byte   $C2                             ; C226 C2                       .
        ldx     #$28                            ; C227 A2 28                    .(
LC229:
        lda     $05E5,x                         ; C229 BD E5 05                 ...
        beq     LC22F                           ; C22C F0 01                    ..
        rts                                     ; C22E 60                       `

; ----------------------------------------------------------------------------
LC22F:
        lda     $05E4,x                         ; C22F BD E4 05                 ...
        bne     LC235                           ; C232 D0 01                    ..
        rts                                     ; C234 60                       `

; ----------------------------------------------------------------------------
LC235:
        lda     $05E3,x                         ; C235 BD E3 05                 ...
        pha                                     ; C238 48                       H
        lda     $05E6,x                         ; C239 BD E6 05                 ...
        tay                                     ; C23C A8                       .
        pla                                     ; C23D 68                       h
        .byte   $48,$29,$0F,$0A,$AA,$BD,$D5,$C2 ; C23E 48 29 0F 0A AA BD D5 C2  H)......
        .byte   $85,$61,$BD,$D6,$C2,$85,$62,$BD ; C246 85 61 BD D6 C2 85 62 BD  .a....b.
        .byte   $E4,$05,$F0,$0E,$AD,$10,$06,$18 ; C24E E4 05 F0 0E AD 10 06 18  ........
        .byte   $65,$61,$85,$61,$A9,$00,$65,$62 ; C256 65 61 85 61 A9 00 65 62  ea.a..eb
        .byte   $85,$62,$68,$29,$F0,$4A,$4A,$4A ; C25E 85 62 68 29 F0 4A 4A 4A  .bh).JJJ
        .byte   $4A,$AA,$CA,$30,$07,$46,$62,$66 ; C266 4A AA CA 30 07 46 62 66  J..0.Fbf
        .byte   $61,$4C,$68,$C2,$A5,$61,$99,$02 ; C26E 61 4C 68 C2 A5 61 99 02  aLh..a..
        .byte   $40,$60                         ; C276 40 60                    @`
LC278:
        .byte   $BD,$D4,$05,$48,$BD,$E7,$05,$8D ; C278 BD D4 05 48 BD E7 05 8D  ...H....
        .byte   $D3                             ; C280 D3                       .
; ----------------------------------------------------------------------------
        ora     $BD                             ; C281 05 BD                    ..
        sbc     $05                             ; C283 E5 05                    ..
        beq     LC289                           ; C285 F0 02                    ..
        pla                                     ; C287 68                       h
        rts                                     ; C288 60                       `

; ----------------------------------------------------------------------------
LC289:
        lda     $05E3,x                         ; C289 BD E3 05                 ...
        ldy     $05E6,x                         ; C28C BC E6 05                 ...
        pha                                     ; C28F 48                       H
        and     #$0F                            ; C290 29 0F                    ).
        asl     a                               ; C292 0A                       .
        tax                                     ; C293 AA                       .
        clc                                     ; C294 18                       .
        tya                                     ; C295 98                       .
        adc     LC2D5,x                         ; C296 7D D5 C2                 }..
        sta     L0061                           ; C299 85 61                    .a
        lda     LC2D6,x                         ; C29B BD D6 C2                 ...
        adc     #$00                            ; C29E 69 00                    i.
        sta     $62                             ; C2A0 85 62                    .b
        pla                                     ; C2A2 68                       h
        and     #$F0                            ; C2A3 29 F0                    ).
        lsr     a                               ; C2A5 4A                       J
        lsr     a                               ; C2A6 4A                       J
        lsr     a                               ; C2A7 4A                       J
        lsr     a                               ; C2A8 4A                       J
        tax                                     ; C2A9 AA                       .
LC2AA:
        dex                                     ; C2AA CA                       .
        bmi     LC2B4                           ; C2AB 30 07                    0.
        lsr     $62                             ; C2AD 46 62                    Fb
        ror     L0061                           ; C2AF 66 61                    fa
        jmp     LC2AA                           ; C2B1 4C AA C2                 L..

; ----------------------------------------------------------------------------
LC2B4:
        pla                                     ; C2B4 68                       h
        lda     $05D3                           ; C2B5 AD D3 05                 ...
        sta     SQ1_VOL,y                       ; C2B8 99 00 40                 ..@
        tya                                     ; C2BB 98                       .
        lsr     a                               ; C2BC 4A                       J
        lsr     a                               ; C2BD 4A                       J
        and     #$01                            ; C2BE 29 01                    ).
        clc                                     ; C2C0 18                       .
        adc     L0061                           ; C2C1 65 61                    ea
        sta     SQ1_LO,y                        ; C2C3 99 02 40                 ..@
        lda     #$00                            ; C2C6 A9 00                    ..
        adc     $62                             ; C2C8 65 62                    eb
        ora     #$08                            ; C2CA 09 08                    ..
        sta     SQ1_HI,y                        ; C2CC 99 03 40                 ..@
        lda     #$00                            ; C2CF A9 00                    ..
        sta     SQ1_SWEEP,y                     ; C2D1 99 01 40                 ..@
        rts                                     ; C2D4 60                       `

; ----------------------------------------------------------------------------
LC2D5:
LC2D6           := * + 1
        ldx     $4E06                           ; C2D5 AE 06 4E                 ..N
        asl     $F3                             ; C2D8 06 F3                    ..
        ora     $9E                             ; C2DA 05 9E                    ..
        ora     $4D                             ; C2DC 05 4D                    .M
        .byte   $05,$01,$05,$B9,$04,$75,$04,$35 ; C2DE 05 01 05 B9 04 75 04 35  .....u.5
        .byte   $04,$F8,$03,$BF,$03,$89,$03     ; C2E6 04 F8 03 BF 03 89 03     .......
LC2ED:
        .byte   $CE,$CA,$05,$F0,$01,$60,$AD,$CD ; C2ED CE CA 05 F0 01 60 AD CD  .....`..
        .byte   $05                             ; C2F5 05                       .
; ----------------------------------------------------------------------------
        sta     $5F                             ; C2F6 85 5F                    ._
        lda     $05CE                           ; C2F8 AD CE 05                 ...
        sta     $60                             ; C2FB 85 60                    .`
        ldy     $05CF                           ; C2FD AC CF 05                 ...
        lda     ($5F),y                         ; C300 B1 5F                    ._
        and     #$0F                            ; C302 29 0F                    ).
        sta     $05CA                           ; C304 8D CA 05                 ...
        lda     ($5F),y                         ; C307 B1 5F                    ._
        and     #$F0                            ; C309 29 F0                    ).
        and     $05D0                           ; C30B 2D D0 05                 -..
        beq     LC32B                           ; C30E F0 1B                    ..
        lsr     a                               ; C310 4A                       J
        lsr     a                               ; C311 4A                       J
        tax                                     ; C312 AA                       .
        lda     LC39B,x                         ; C313 BD 9B C3                 ...
        sta     NOISE_VOL                       ; C316 8D 0C 40                 ..@
        lda     LC39C,x                         ; C319 BD 9C C3                 ...
        sta     $400D                           ; C31C 8D 0D 40                 ..@
        lda     LC39D,x                         ; C31F BD 9D C3                 ...
        sta     NOISE_LO                        ; C322 8D 0E 40                 ..@
        lda     LC39E,x                         ; C325 BD 9E C3                 ...
        sta     NOISE_HI                        ; C328 8D 0F 40                 ..@
LC32B:
        iny                                     ; C32B C8                       .
        cpy     #$10                            ; C32C C0 10                    ..
        beq     LC334                           ; C32E F0 04                    ..
        sty     $05CF                           ; C330 8C CF 05                 ...
        rts                                     ; C333 60                       `

; ----------------------------------------------------------------------------
LC334:
        lda     $05CB                           ; C334 AD CB 05                 ...
        sta     $5F                             ; C337 85 5F                    ._
        lda     $05CC                           ; C339 AD CC 05                 ...
        sta     $60                             ; C33C 85 60                    .`
        ldy     #$00                            ; C33E A0 00                    ..
        lda     ($5F),y                         ; C340 B1 5F                    ._
        bpl     LC35A                           ; C342 10 16                    ..
        cmp     #$FE                            ; C344 C9 FE                    ..
        beq     LC359                           ; C346 F0 11                    ..
        iny                                     ; C348 C8                       .
        lda     ($5F),y                         ; C349 B1 5F                    ._
        pha                                     ; C34B 48                       H
        iny                                     ; C34C C8                       .
        lda     ($5F),y                         ; C34D B1 5F                    ._
        sta     $05CC                           ; C34F 8D CC 05                 ...
        pla                                     ; C352 68                       h
        sta     $05CB                           ; C353 8D CB 05                 ...
        jmp     LC334                           ; C356 4C 34 C3                 L4.

; ----------------------------------------------------------------------------
LC359:
        rts                                     ; C359 60                       `

; ----------------------------------------------------------------------------
LC35A:
        sec                                     ; C35A 38                       8
        sbc     #$01                            ; C35B E9 01                    ..
        pha                                     ; C35D 48                       H
        clc                                     ; C35E 18                       .
        lda     $5F                             ; C35F A5 5F                    ._
        adc     #$01                            ; C361 69 01                    i.
        sta     $05CB                           ; C363 8D CB 05                 ...
        lda     $60                             ; C366 A5 60                    .`
        adc     #$00                            ; C368 69 00                    i.
        sta     $05CC                           ; C36A 8D CC 05                 ...
        pla                                     ; C36D 68                       h
        sta     $5F                             ; C36E 85 5F                    ._
        lda     #$00                            ; C370 A9 00                    ..
        sta     $60                             ; C372 85 60                    .`
        asl     $5F                             ; C374 06 5F                    ._
        rol     $60                             ; C376 26 60                    &`
        asl     $5F                             ; C378 06 5F                    ._
        rol     $60                             ; C37A 26 60                    &`
        asl     $5F                             ; C37C 06 5F                    ._
        rol     $60                             ; C37E 26 60                    &`
        asl     $5F                             ; C380 06 5F                    ._
        rol     $60                             ; C382 26 60                    &`
        clc                                     ; C384 18                       .
        lda     $5F                             ; C385 A5 5F                    ._
        adc     $05D1                           ; C387 6D D1 05                 m..
        sta     $05CD                           ; C38A 8D CD 05                 ...
        lda     $60                             ; C38D A5 60                    .`
        adc     $05D2                           ; C38F 6D D2 05                 m..
        sta     $05CE                           ; C392 8D CE 05                 ...
        lda     #$00                            ; C395 A9 00                    ..
        sta     $05CF                           ; C397 8D CF 05                 ...
        rts                                     ; C39A 60                       `

; ----------------------------------------------------------------------------
LC39B:
        .byte   $07                             ; C39B 07                       .
LC39C:
        brk                                     ; C39C 00                       .
LC39D:
        .byte   $03                             ; C39D 03                       .
LC39E:
        .byte   $02                             ; C39E 02                       .
        .byte   $03                             ; C39F 03                       .
        brk                                     ; C3A0 00                       .
        .byte   $07                             ; C3A1 07                       .
        .byte   $02                             ; C3A2 02                       .
        asl     $00                             ; C3A3 06 00                    ..
        .byte   $05,$02,$01,$00,$04,$FF,$00,$00 ; C3A5 05 02 01 00 04 FF 00 00  ........
        .byte   $01,$FF,$02,$00,$0D,$FF,$02,$00 ; C3AD 01 FF 02 00 0D FF 02 00  ........
        .byte   $0E,$FF,$01,$00,$0D,$FF,$01,$00 ; C3B5 0E FF 01 00 0D FF 01 00  ........
        .byte   $0E,$FF,$01,$00,$0E,$FF,$00,$00 ; C3BD 0E FF 01 00 0E FF 00 00  ........
        .byte   $0C,$FF,$00,$00,$0F,$FF         ; C3C5 0C FF 00 00 0F FF        ......
LC3CB:
        .byte   $A9,$04                         ; C3CB A9 04                    ..
LC3CD:
        .byte   $8D,$16,$06,$8D,$17,$06,$60     ; C3CD 8D 16 06 8D 17 06 60     ......`
; ----------------------------------------------------------------------------
        lda     $05D5,x                         ; C3D4 BD D5 05                 ...
        ldy     $05E6,x                         ; C3D7 BC E6 05                 ...
        sta     SQ1_VOL,y                       ; C3DA 99 00 40                 ..@
        .byte   $20,$78,$C2,$60,$E6,$CB,$36,$D1 ; C3DD 20 78 C2 60 E6 CB 36 D1   x.`..6.
        .byte   $26,$CC,$09,$CE,$54,$D0,$27,$C4 ; C3E5 26 CC 09 CE 54 D0 27 C4  &...T.'.
        .byte   $AA,$C7,$67,$C4,$4C,$C5,$BC,$C6 ; C3ED AA C7 67 C4 4C C5 BC C6  ..g.L...
        .byte   $E1,$C7,$B7,$CB,$31,$C8,$55,$C9 ; C3F5 E1 C7 B7 CB 31 C8 55 C9  ....1.U.
        .byte   $4F,$CA,$5D,$D1,$EF,$D4,$AD,$D1 ; C3FD 4F CA 5D D1 EF D4 AD D1  O.].....
        .byte   $6C,$D3,$1A,$D4,$18,$D5,$F5,$D8 ; C405 6C D3 1A D4 18 D5 F5 D8  l.......
        .byte   $08,$D6,$02,$D7,$34,$D8,$10,$D9 ; C40D 08 D6 02 D7 34 D8 10 D9  ....4...
        .byte   $34,$DC,$50,$D9,$28,$DA,$50,$DB ; C415 34 DC 50 D9 28 DA 50 DB  4.P.(.P.
        .byte   $4B,$DC,$71,$DF,$8B,$DC,$67,$DD ; C41D 4B DC 71 DF 8B DC 67 DD  K.q...g.
        .byte   $90,$DE,$06,$06,$A6,$06,$06,$06 ; C425 90 DE 06 06 A6 06 06 06  ........
        .byte   $A3,$01,$01,$01,$01,$01,$01,$01 ; C42D A3 01 01 01 01 01 01 01  ........
        .byte   $01,$01,$A6,$06,$06,$06,$06,$06 ; C435 01 01 A6 06 06 06 06 06  ........
        .byte   $03,$01,$01,$01,$01,$01,$01,$01 ; C43D 03 01 01 01 01 01 01 01  ........
        .byte   $01,$01,$06,$06,$06,$06,$06,$06 ; C445 01 01 06 06 06 06 06 06  ........
        .byte   $03,$01,$01,$01,$01,$01,$01,$01 ; C44D 03 01 01 01 01 01 01 01  ........
        .byte   $01,$01,$06,$06,$A6,$06,$06,$06 ; C455 01 01 06 06 A6 06 06 06  ........
        .byte   $06,$06,$00,$00,$00,$00,$00,$00 ; C45D 06 06 00 00 00 00 00 00  ........
        .byte   $00,$00,$F9,$08,$F8,$00,$99,$27 ; C465 00 00 F9 08 F8 00 99 27  .......'
        .byte   $96,$24,$25,$99,$27,$96,$24,$25 ; C46D 96 24 25 99 27 96 24 25  .$%.'.$%
        .byte   $99,$27,$96,$25,$24,$98,$22,$93 ; C475 99 27 96 25 24 98 22 93  .'.%$.".
        .byte   $00,$96,$29,$29,$98,$27,$93,$25 ; C47D 00 96 29 29 98 27 93 25  ..)).'.%
        .byte   $96,$24,$25,$99,$27,$96,$24,$25 ; C485 96 24 25 99 27 96 24 25  .$%.'.$%
        .byte   $99,$27,$96,$25,$24,$22,$00,$99 ; C48D 99 27 96 25 24 22 00 99  .'.%$"..
        .byte   $32,$9C,$30,$96,$29,$30,$2A,$93 ; C495 32 9C 30 96 29 30 2A 93  2.0.)0*.
        .byte   $29,$27,$99,$25,$20,$96,$29,$30 ; C49D 29 27 99 25 20 96 29 30  )'.% .)0
        .byte   $27,$29,$99,$25,$20,$22,$96,$22 ; C4A5 27 29 99 25 20 22 96 22  ').% "."
        .byte   $24,$27,$25,$24,$22,$99,$20,$20 ; C4AD 24 27 25 24 22 99 20 20  $'%$".  
        .byte   $20,$30,$96,$29,$30,$2A,$93,$29 ; C4B5 20 30 96 29 30 2A 93 29   0.)0*.)
        .byte   $27,$99,$25,$20,$96,$29,$30,$27 ; C4BD 27 99 25 20 96 29 30 27  '.% .)0'
        .byte   $29,$99,$25,$20,$22,$96,$22,$24 ; C4C5 29 99 25 20 22 96 22 24  ).% "."$
        .byte   $27,$25,$24,$22,$99,$30,$2A,$F7 ; C4CD 27 25 24 22 99 30 2A F7  '%$".0*.
        .byte   $30,$29,$9B,$29,$96,$29,$99,$27 ; C4D5 30 29 9B 29 96 29 99 27  0).).).'
        .byte   $96,$24,$25,$99,$27,$96,$24,$25 ; C4DD 96 24 25 99 27 96 24 25  .$%.'.$%
        .byte   $99,$27,$96,$25,$24,$99,$22,$96 ; C4E5 99 27 96 25 24 99 22 96  .'.%$.".
        .byte   $29,$29,$98,$27,$93,$25,$96,$24 ; C4ED 29 29 98 27 93 25 96 24  )).'.%.$
        .byte   $25,$99,$27,$96,$24,$25,$99,$27 ; C4F5 25 99 27 96 24 25 99 27  %.'.$%.'
        .byte   $96,$25,$24,$22,$00,$99,$32,$9C ; C4FD 96 25 24 22 00 99 32 9C  .%$"..2.
        .byte   $30,$96,$29,$30,$2A,$93,$29,$27 ; C505 30 96 29 30 2A 93 29 27  0.)0*.)'
        .byte   $99,$25,$20,$96,$29,$30,$27,$29 ; C50D 99 25 20 96 29 30 27 29  .% .)0')
        .byte   $99,$25,$20,$22,$96,$22,$24,$27 ; C515 99 25 20 22 96 22 24 27  .% "."$'
        .byte   $25,$24,$22,$99,$20,$20,$20,$30 ; C51D 25 24 22 99 20 20 20 30  %$".   0
        .byte   $96,$29,$30,$2A,$93,$29,$27,$99 ; C525 96 29 30 2A 93 29 27 99  .)0*.)'.
        .byte   $25,$20,$96,$29,$30,$27,$29,$99 ; C52D 25 20 96 29 30 27 29 99  % .)0').
        .byte   $25,$20,$22,$96,$22,$24,$27,$25 ; C535 25 20 22 96 22 24 27 25  % "."$'%
        .byte   $24,$22,$99,$30,$2A,$F7,$30,$29 ; C53D 24 22 99 30 2A F7 30 29  $".0*.0)
        .byte   $9B,$29,$96,$29,$FF,$67,$C4,$F9 ; C545 9B 29 96 29 FF 67 C4 F9  .).).g..
        .byte   $06,$F8,$00,$99,$2A,$96,$27,$29 ; C54D 06 F8 00 99 2A 96 27 29  ....*.')
        .byte   $99,$2A,$96,$27,$29,$99,$2A,$96 ; C555 99 2A 96 27 29 99 2A 96  .*.').*.
        .byte   $29,$27,$99,$25,$93,$30,$00,$30 ; C55D 29 27 99 25 93 30 00 30  )'.%.0.0
        .byte   $00,$98,$2A,$93,$29,$96,$27,$29 ; C565 00 98 2A 93 29 96 27 29  ..*.).')
        .byte   $99,$2A,$96,$27,$29,$99,$2A,$96 ; C56D 99 2A 96 27 29 99 2A 96  .*.').*.
        .byte   $29,$27,$25,$9B,$00,$9C,$00,$96 ; C575 29 27 25 9B 00 9C 00 96  )'%.....
        .byte   $00,$93,$29,$98,$00,$93,$2A,$00 ; C57D 00 93 29 98 00 93 2A 00  ..)...*.
        .byte   $96,$00,$93,$29,$98,$00,$93,$29 ; C585 96 00 93 29 98 00 93 29  ...)...)
        .byte   $00,$96,$00,$93,$29,$98,$00,$93 ; C58D 00 96 00 93 29 98 00 93  ....)...
        .byte   $2A,$00,$96,$00,$93,$29,$98,$00 ; C595 2A 00 96 00 93 29 98 00  *....)..
        .byte   $93,$29,$00,$96,$00,$93,$25,$98 ; C59D 93 29 00 96 00 93 25 98  .)....%.
        .byte   $00,$93,$25,$00,$96,$00,$93,$25 ; C5A5 00 93 25 00 96 00 93 25  ..%....%
        .byte   $98,$00,$93,$25,$00,$96,$00,$93 ; C5AD 98 00 93 25 00 96 00 93  ...%....
        .byte   $27,$98,$00,$93,$29,$00,$99,$27 ; C5B5 27 98 00 93 29 00 99 27  '...)..'
        .byte   $00,$96,$00,$93,$29,$98,$00,$93 ; C5BD 00 96 00 93 29 98 00 93  ....)...
        .byte   $2A,$00,$96,$00,$93,$29,$98,$00 ; C5C5 2A 00 96 00 93 29 98 00  *....)..
        .byte   $93,$29,$00,$96,$00,$93,$29,$98 ; C5CD 93 29 00 96 00 93 29 98  .)....).
        .byte   $00,$93,$2A,$00,$96,$00,$93,$29 ; C5D5 00 93 2A 00 96 00 93 29  ..*....)
        .byte   $98,$00,$93,$29,$00,$96,$00,$93 ; C5DD 98 00 93 29 00 96 00 93  ...)....
        .byte   $25,$98,$00,$93,$25,$00,$96,$00 ; C5E5 25 98 00 93 25 00 96 00  %...%...
        .byte   $93,$25,$98,$00,$93,$25,$00,$96 ; C5ED 93 25 98 00 93 25 00 96  .%...%..
        .byte   $00,$93,$27,$98,$00,$93,$27,$00 ; C5F5 00 93 27 98 00 93 27 00  ..'...'.
        .byte   $F7,$30,$24,$98,$24,$F7,$1E,$00 ; C5FD F7 30 24 98 24 F7 1E 00  .0$.$...
        .byte   $99,$2A,$96,$27,$29,$99,$2A,$96 ; C605 99 2A 96 27 29 99 2A 96  .*.').*.
        .byte   $27,$29,$99,$2A,$96,$29,$27,$99 ; C60D 27 29 99 2A 96 29 27 99  ').*.)'.
        .byte   $25,$93,$30,$00,$30,$00,$98,$2A ; C615 25 93 30 00 30 00 98 2A  %.0.0..*
        .byte   $93,$29,$96,$27,$29,$99,$2A,$96 ; C61D 93 29 96 27 29 99 2A 96  .).').*.
        .byte   $27,$29,$99,$2A,$96,$29,$27,$25 ; C625 27 29 99 2A 96 29 27 25  ').*.)'%
        .byte   $9B,$00,$9C,$00,$96,$00,$93,$29 ; C62D 9B 00 9C 00 96 00 93 29  .......)
        .byte   $98,$00,$93,$2A,$00,$96,$00,$93 ; C635 98 00 93 2A 00 96 00 93  ...*....
        .byte   $29,$98,$00,$93,$29,$00,$96,$00 ; C63D 29 98 00 93 29 00 96 00  )...)...
        .byte   $93,$29,$98,$00,$93,$2A,$00,$96 ; C645 93 29 98 00 93 2A 00 96  .)...*..
        .byte   $00,$93,$29,$98,$00,$93,$29,$00 ; C64D 00 93 29 98 00 93 29 00  ..)...).
        .byte   $96,$00,$93,$25,$98,$00,$93,$25 ; C655 96 00 93 25 98 00 93 25  ...%...%
        .byte   $00,$96,$00,$93,$25,$98,$00,$93 ; C65D 00 96 00 93 25 98 00 93  ....%...
        .byte   $25,$00,$96,$00,$93,$27,$98,$00 ; C665 25 00 96 00 93 27 98 00  %....'..
        .byte   $93,$29,$00,$9C,$27,$96,$00,$93 ; C66D 93 29 00 9C 27 96 00 93  .)..'...
        .byte   $29,$98,$00,$93,$2A,$00,$96,$00 ; C675 29 98 00 93 2A 00 96 00  )...*...
        .byte   $93,$29,$98,$00,$93,$29,$00,$96 ; C67D 93 29 98 00 93 29 00 96  .)...)..
        .byte   $00,$93,$29,$98,$00,$93,$2A,$00 ; C685 00 93 29 98 00 93 2A 00  ..)...*.
        .byte   $96,$00,$93,$29,$98,$00,$93,$29 ; C68D 96 00 93 29 98 00 93 29  ...)...)
        .byte   $00,$96,$00,$93,$25,$98,$00,$93 ; C695 00 96 00 93 25 98 00 93  ....%...
        .byte   $25,$00,$96,$00,$93,$25,$98,$00 ; C69D 25 00 96 00 93 25 98 00  %....%..
        .byte   $93,$25,$00,$96,$00,$93,$27,$98 ; C6A5 93 25 00 96 00 93 27 98  .%....'.
        .byte   $00,$93,$27,$00,$F7,$30,$24,$98 ; C6AD 00 93 27 00 F7 30 24 98  ..'..0$.
        .byte   $24,$F7,$1E,$00,$FF,$4C,$C5,$99 ; C6B5 24 F7 1E 00 FF 4C C5 99  $....L..
        .byte   $19,$96,$19,$00,$19,$00,$19,$00 ; C6BD 19 96 19 00 19 00 19 00  ........
        .byte   $19,$00,$19,$00,$22,$00,$22,$00 ; C6C5 19 00 19 00 22 00 22 00  ....".".
        .byte   $19,$00,$19,$00,$19,$00,$19,$00 ; C6CD 19 00 19 00 19 00 19 00  ........
        .byte   $19,$00,$19,$00,$22,$9B,$00,$9C ; C6D5 19 00 19 00 22 9B 00 9C  ...."...
        .byte   $00,$99,$25,$96,$20,$00,$99,$25 ; C6DD 00 99 25 96 20 00 99 25  ..%. ..%
        .byte   $96,$25,$00,$99,$25,$96,$20,$00 ; C6E5 96 25 00 99 25 96 20 00  .%..%. .
        .byte   $99,$15,$96,$19,$00,$99,$1A,$96 ; C6ED 99 15 96 19 00 99 1A 96  ........
        .byte   $1A,$00,$99,$17,$96,$17,$00,$98 ; C6F5 1A 00 99 17 96 17 00 98  ........
        .byte   $20,$93,$00,$98,$20,$93,$00,$99 ; C6FD 20 93 00 98 20 93 00 99   ... ...
        .byte   $20,$00,$25,$96,$20,$00,$99,$25 ; C705 20 00 25 96 20 00 99 25   .%. ..%
        .byte   $96,$25,$00,$25,$00,$20,$00,$99 ; C70D 96 25 00 25 00 20 00 99  .%.%. ..
        .byte   $15,$96,$19,$00,$99,$1A,$96,$1A ; C715 15 96 19 00 99 1A 96 1A  ........
        .byte   $00,$1B,$00,$1B,$00,$99,$20,$98 ; C71D 00 1B 00 1B 00 99 20 98  ...... .
        .byte   $20,$93,$00,$F7,$30,$19,$98,$19 ; C725 20 93 00 F7 30 19 98 19   ...0...
        .byte   $F7,$1E,$00,$99,$19,$96,$19,$00 ; C72D F7 1E 00 99 19 96 19 00  ........
        .byte   $19,$00,$19,$00,$19,$00,$19,$00 ; C735 19 00 19 00 19 00 19 00  ........
        .byte   $22,$00,$22,$00,$19,$00,$19,$00 ; C73D 22 00 22 00 19 00 19 00  ".".....
        .byte   $19,$00,$19,$00,$19,$00,$19,$00 ; C745 19 00 19 00 19 00 19 00  ........
        .byte   $22,$9B,$00,$9C,$00,$99,$25,$96 ; C74D 22 9B 00 9C 00 99 25 96  ".....%.
        .byte   $20,$00,$99,$25,$96,$25,$00,$99 ; C755 20 00 99 25 96 25 00 99   ..%.%..
        .byte   $25,$96,$20,$00,$99,$15,$96,$19 ; C75D 25 96 20 00 99 15 96 19  %. .....
        .byte   $00,$99,$1A,$96,$1A,$00,$99,$17 ; C765 00 99 1A 96 1A 00 99 17  ........
        .byte   $96,$17,$00,$98,$20,$93,$00,$98 ; C76D 96 17 00 98 20 93 00 98  .... ...
        .byte   $20,$93,$00,$9C,$20,$99,$25,$96 ; C775 20 93 00 9C 20 99 25 96   ... .%.
        .byte   $20,$00,$99,$25,$96,$25,$00,$25 ; C77D 20 00 99 25 96 25 00 25   ..%.%.%
        .byte   $00,$20,$00,$99,$15,$96,$19,$00 ; C785 00 20 00 99 15 96 19 00  . ......
        .byte   $99,$1A,$96,$1A,$00,$1B,$00,$1B ; C78D 99 1A 96 1A 00 1B 00 1B  ........
        .byte   $00,$99,$20,$98,$20,$93,$00,$F7 ; C795 00 99 20 98 20 93 00 F7  .. . ...
        .byte   $30,$19,$98,$19,$F7,$1E,$00,$FF ; C79D 30 19 98 19 F7 1E 00 FF  0.......
        .byte   $BC,$C6,$FF,$A7,$C7,$01,$01,$01 ; C7A5 BC C6 FF A7 C7 01 01 01  ........
        .byte   $01,$01,$01,$01,$02,$03,$01,$01 ; C7AD 01 01 01 01 02 03 01 01  ........
        .byte   $01,$01,$01,$01,$01,$02,$01,$01 ; C7B5 01 01 01 01 01 02 01 01  ........
        .byte   $01,$01,$01,$01,$01,$02,$03,$01 ; C7BD 01 01 01 01 01 02 03 01  ........
        .byte   $01,$01,$01,$01,$01,$01,$02,$03 ; C7C5 01 01 01 01 01 01 02 03  ........
        .byte   $01,$01,$01,$01,$01,$01,$01,$02 ; C7CD 01 01 01 01 01 01 01 02  ........
        .byte   $01,$01,$01,$01,$01,$01,$01,$02 ; C7D5 01 01 01 01 01 01 01 02  ........
        .byte   $03,$FF,$AA,$C7,$06,$06,$06,$06 ; C7DD 03 FF AA C7 06 06 06 06  ........
        .byte   $06,$06,$06,$06,$06,$06,$06,$06 ; C7E5 06 06 06 06 06 06 06 06  ........
        .byte   $06,$06,$06,$06,$06,$06,$A6,$06 ; C7ED 06 06 06 06 06 06 A6 06  ........
        .byte   $06,$06,$A6,$06,$06,$06,$A6,$06 ; C7F5 06 06 A6 06 06 06 A6 06  ........
        .byte   $06,$06,$A6,$06,$06,$06,$06,$06 ; C7FD 06 06 A6 06 06 06 06 06  ........
        .byte   $06,$06,$06,$06,$06,$06,$06,$06 ; C805 06 06 06 06 06 06 06 06  ........
        .byte   $06,$06,$06,$06,$06,$06,$06,$06 ; C80D 06 06 06 06 06 06 06 06  ........
        .byte   $06,$06,$06,$06,$06,$06,$06,$06 ; C815 06 06 06 06 06 06 06 06  ........
        .byte   $06,$06,$06,$06,$06,$06,$06,$06 ; C81D 06 06 06 06 06 06 06 06  ........
        .byte   $06,$06,$06,$06,$06,$06,$06,$06 ; C825 06 06 06 06 06 06 06 06  ........
        .byte   $06,$06,$06,$06,$F9,$08,$9F,$00 ; C82D 06 06 06 06 F9 08 9F 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$F8 ; C835 00 00 00 00 00 00 00 F8  ........
        .byte   $05,$9C,$34,$30,$32,$2B,$96,$30 ; C83D 05 9C 34 30 32 2B 96 30  ..402+.0
        .byte   $28,$29,$2B,$30,$29,$2B,$30,$9C ; C845 28 29 2B 30 29 2B 30 9C  ()+0)+0.
        .byte   $32,$28,$F7,$3C,$34,$96,$29,$2B ; C84D 32 28 F7 3C 34 96 29 2B  2(.<4.)+
        .byte   $30,$F7,$3C,$32,$32,$30,$2B,$9C ; C855 30 F7 3C 32 32 30 2B 9C  0.<220+.
        .byte   $29,$28,$29,$96,$26,$28,$29,$2B ; C85D 29 28 29 96 26 28 29 2B  )().&()+
        .byte   $9C,$34,$30,$32,$2B,$96,$30,$28 ; C865 9C 34 30 32 2B 96 30 28  .402+.0(
        .byte   $29,$2B,$30,$29,$2B,$30,$9C,$32 ; C86D 29 2B 30 29 2B 30 9C 32  )+0)+0.2
        .byte   $28,$F7,$3C,$34,$96,$29,$2B,$30 ; C875 28 F7 3C 34 96 29 2B 30  (.<4.)+0
        .byte   $F7,$3C,$32,$32,$30,$2B,$9C,$29 ; C87D F7 3C 32 32 30 2B 9C 29  .<220+.)
        .byte   $28,$29,$96,$26,$28,$29,$2B,$F8 ; C885 28 29 96 26 28 29 2B F8  ().&()+.
        .byte   $01,$9B,$39,$93,$39,$00,$39,$00 ; C88D 01 9B 39 93 39 00 39 00  ..9.9.9.
        .byte   $39,$00,$38,$00,$39,$00,$9B,$3B ; C895 39 00 38 00 39 00 9B 3B  9.8.9..;
        .byte   $93,$38,$00,$9B,$34,$93,$34,$00 ; C89D 93 38 00 9B 34 93 34 00  .8..4.4.
        .byte   $99,$40,$39,$30,$32,$F7,$54,$34 ; C8A5 99 40 39 30 32 F7 54 34  .@902.T4
        .byte   $93,$34,$00,$9B,$39,$93,$3B,$00 ; C8AD 93 34 00 9B 39 93 3B 00  .4..9.;.
        .byte   $40,$00,$3B,$00,$39,$00,$34,$00 ; C8B5 40 00 3B 00 39 00 34 00  @.;.9.4.
        .byte   $9B,$32,$96,$35,$99,$39,$93,$3B ; C8BD 9B 32 96 35 99 39 93 3B  .2.5.9.;
        .byte   $00,$39,$00,$9B,$34,$93,$35,$00 ; C8C5 00 39 00 9B 34 93 35 00  .9..4.5.
        .byte   $34,$00,$32,$00,$2B,$00,$30,$00 ; C8CD 34 00 32 00 2B 00 30 00  4.2.+.0.
        .byte   $F7,$54,$29,$34,$00,$9B,$39,$93 ; C8D5 F7 54 29 34 00 9B 39 93  .T)4..9.
        .byte   $39,$00,$39,$00,$39,$00,$38,$00 ; C8DD 39 00 39 00 39 00 38 00  9.9.9.8.
        .byte   $39,$00,$9B,$3B,$93,$38,$00,$9B ; C8E5 39 00 9B 3B 93 38 00 9B  9..;.8..
        .byte   $34,$93,$34,$00,$99,$40,$39,$30 ; C8ED 34 93 34 00 99 40 39 30  4.4..@90
        .byte   $32,$F7,$54,$34,$93,$34,$00,$9B ; C8F5 32 F7 54 34 93 34 00 9B  2.T4.4..
        .byte   $39,$93,$3B,$00,$40,$00,$3B,$00 ; C8FD 39 93 3B 00 40 00 3B 00  9.;.@.;.
        .byte   $39,$00,$34,$00,$9B,$32,$96,$35 ; C905 39 00 34 00 9B 32 96 35  9.4..2.5
        .byte   $99,$39,$93,$3B,$00,$39,$00,$9B ; C90D 99 39 93 3B 00 39 00 9B  .9.;.9..
        .byte   $34,$93,$35,$00,$34,$00,$32,$00 ; C915 34 93 35 00 34 00 32 00  4.5.4.2.
        .byte   $2B,$00,$30,$00,$F7,$54,$29,$34 ; C91D 2B 00 30 00 F7 54 29 34  +.0..T)4
        .byte   $00,$9B,$39,$93,$3B,$00,$40,$00 ; C925 00 9B 39 93 3B 00 40 00  ..9.;.@.
        .byte   $3B,$00,$39,$00,$34,$00,$9B,$32 ; C92D 3B 00 39 00 34 00 9B 32  ;.9.4..2
        .byte   $96,$35,$99,$39,$93,$3B,$00,$39 ; C935 96 35 99 39 93 3B 00 39  .5.9.;.9
        .byte   $00,$9B,$34,$93,$35,$00,$34,$00 ; C93D 00 9B 34 93 35 00 34 00  ..4.5.4.
        .byte   $32,$00,$2B,$00,$30,$00,$F7,$54 ; C945 32 00 2B 00 30 00 F7 54  2.+.0..T
        .byte   $29,$96,$00,$F8,$05,$FF,$3C,$C8 ; C94D 29 96 00 F8 05 FF 3C C8  ).....<.
        .byte   $F9,$08,$9F,$00,$00,$00,$00,$00 ; C955 F9 08 9F 00 00 00 00 00  ........
        .byte   $00,$00,$00,$F8,$03,$9F,$00,$00 ; C95D 00 00 00 F8 03 9F 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$96,$19 ; C965 00 00 00 00 00 00 96 19  ........
        .byte   $00,$19,$00,$19,$00,$19,$00,$14 ; C96D 00 19 00 19 00 19 00 14  ........
        .byte   $00,$14,$00,$14,$00,$14,$00,$19 ; C975 00 14 00 14 00 14 00 19  ........
        .byte   $00,$19,$00,$15,$00,$15,$00,$14 ; C97D 00 19 00 15 00 15 00 14  ........
        .byte   $00,$14,$00,$14,$00,$14,$00,$19 ; C985 00 14 00 14 00 14 00 19  ........
        .byte   $00,$19,$00,$19,$00,$19,$00,$12 ; C98D 00 19 00 19 00 19 00 12  ........
        .byte   $00,$12,$00,$12,$00,$12,$00,$14 ; C995 00 12 00 12 00 12 00 14  ........
        .byte   $00,$14,$00,$14,$00,$14,$00,$19 ; C99D 00 14 00 14 00 14 00 19  ........
        .byte   $00,$19,$00,$19,$00,$19,$00,$19 ; C9A5 00 19 00 19 00 19 00 19  ........
        .byte   $00,$19,$00,$19,$00,$19,$00,$14 ; C9AD 00 19 00 19 00 19 00 14  ........
        .byte   $00,$14,$00,$14,$00,$14,$00,$19 ; C9B5 00 14 00 14 00 14 00 19  ........
        .byte   $00,$19,$00,$15,$00,$15,$00,$14 ; C9BD 00 19 00 15 00 15 00 14  ........
        .byte   $00,$14,$00,$14,$00,$14,$00,$19 ; C9C5 00 14 00 14 00 14 00 19  ........
        .byte   $00,$19,$00,$19,$00,$19,$00,$12 ; C9CD 00 19 00 19 00 19 00 12  ........
        .byte   $00,$12,$00,$12,$00,$12,$00,$14 ; C9D5 00 12 00 12 00 12 00 14  ........
        .byte   $00,$14,$00,$14,$00,$14,$00,$19 ; C9DD 00 14 00 14 00 14 00 19  ........
        .byte   $00,$19,$00,$19,$00,$19,$00,$19 ; C9E5 00 19 00 19 00 19 00 19  ........
        .byte   $00,$19,$00,$19,$00,$19,$00,$14 ; C9ED 00 19 00 19 00 19 00 14  ........
        .byte   $00,$14,$00,$14,$00,$14,$00,$19 ; C9F5 00 14 00 14 00 14 00 19  ........
        .byte   $00,$19,$00,$15,$00,$15,$00,$14 ; C9FD 00 19 00 15 00 15 00 14  ........
        .byte   $00,$14,$00,$14,$00,$14,$00,$19 ; CA05 00 14 00 14 00 14 00 19  ........
        .byte   $00,$19,$00,$19,$00,$19,$00,$12 ; CA0D 00 19 00 19 00 19 00 12  ........
        .byte   $00,$12,$00,$12,$00,$12,$00,$14 ; CA15 00 12 00 12 00 12 00 14  ........
        .byte   $00,$14,$00,$14,$00,$14,$00,$19 ; CA1D 00 14 00 14 00 14 00 19  ........
        .byte   $00,$19,$00,$19,$00,$19,$00,$19 ; CA25 00 19 00 19 00 19 00 19  ........
        .byte   $00,$19,$00,$19,$00,$19,$00,$12 ; CA2D 00 19 00 19 00 19 00 12  ........
        .byte   $00,$12,$00,$12,$00,$12,$00,$14 ; CA35 00 12 00 12 00 12 00 14  ........
        .byte   $00,$14,$00,$14,$00,$14,$00,$19 ; CA3D 00 14 00 14 00 14 00 19  ........
        .byte   $00,$19,$00,$19,$00,$19,$00,$FF ; CA45 00 19 00 19 00 19 00 FF  ........
        .byte   $60,$C9,$96,$29,$34,$30,$34,$29 ; CA4D 60 C9 96 29 34 30 34 29  `..)404)
        .byte   $34,$30,$34,$28,$34,$32,$34,$28 ; CA55 34 30 34 28 34 32 34 28  404(424(
        .byte   $34,$32,$34,$29,$34,$30,$34,$29 ; CA5D 34 32 34 29 34 30 34 29  424)404)
        .byte   $35,$30,$35,$28,$34,$32,$34,$28 ; CA65 35 30 35 28 34 32 34 28  505(424(
        .byte   $34,$32,$34,$29,$34,$30,$34,$29 ; CA6D 34 32 34 29 34 30 34 29  424)404)
        .byte   $34,$30,$34,$29,$35,$32,$35,$29 ; CA75 34 30 34 29 35 32 35 29  404)525)
        .byte   $35,$32,$35,$29,$34,$30,$34,$28 ; CA7D 35 32 35 29 34 30 34 28  525)404(
        .byte   $34,$32,$34,$29,$34,$30,$34,$29 ; CA85 34 32 34 29 34 30 34 29  424)404)
        .byte   $34,$30,$34,$96,$29,$34,$30,$34 ; CA8D 34 30 34 96 29 34 30 34  404.)404
        .byte   $29,$34,$30,$34,$28,$34,$32,$34 ; CA95 29 34 30 34 28 34 32 34  )404(424
        .byte   $28,$34,$32,$34,$29,$34,$30,$34 ; CA9D 28 34 32 34 29 34 30 34  (424)404
        .byte   $29,$35,$30,$35,$28,$34,$32,$34 ; CAA5 29 35 30 35 28 34 32 34  )505(424
        .byte   $28,$34,$32,$34,$29,$34,$30,$34 ; CAAD 28 34 32 34 29 34 30 34  (424)404
        .byte   $29,$34,$30,$34,$29,$35,$32,$35 ; CAB5 29 34 30 34 29 35 32 35  )404)525
        .byte   $29,$35,$32,$35,$29,$34,$30,$34 ; CABD 29 35 32 35 29 34 30 34  )525)404
        .byte   $28,$34,$32,$34,$29,$34,$30,$34 ; CAC5 28 34 32 34 29 34 30 34  (424)404
        .byte   $29,$34,$30,$34,$29,$34,$30,$34 ; CACD 29 34 30 34 29 34 30 34  )404)404
        .byte   $29,$34,$30,$34,$28,$34,$32,$34 ; CAD5 29 34 30 34 28 34 32 34  )404(424
        .byte   $28,$34,$32,$34,$29,$34,$30,$34 ; CADD 28 34 32 34 29 34 30 34  (424)404
        .byte   $29,$35,$30,$35,$28,$34,$32,$34 ; CAE5 29 35 30 35 28 34 32 34  )505(424
        .byte   $28,$34,$32,$34,$29,$34,$30,$34 ; CAED 28 34 32 34 29 34 30 34  (424)404
        .byte   $29,$34,$30,$34,$29,$35,$32,$35 ; CAF5 29 34 30 34 29 35 32 35  )404)525
        .byte   $29,$35,$32,$35,$29,$34,$30,$34 ; CAFD 29 35 32 35 29 34 30 34  )525)404
        .byte   $28,$34,$32,$34,$29,$34,$30,$34 ; CB05 28 34 32 34 29 34 30 34  (424)404
        .byte   $29,$34,$30,$34,$00,$34,$00,$34 ; CB0D 29 34 30 34 00 34 00 34  )404.4.4
        .byte   $00,$34,$00,$34,$00,$32,$00,$32 ; CB15 00 34 00 34 00 32 00 32  .4.4.2.2
        .byte   $00,$32,$00,$32,$00,$34,$00,$34 ; CB1D 00 32 00 32 00 34 00 34  .2.2.4.4
        .byte   $00,$30,$00,$30,$00,$32,$00,$32 ; CB25 00 30 00 30 00 32 00 32  .0.0.2.2
        .byte   $00,$32,$00,$32,$00,$34,$00,$34 ; CB2D 00 32 00 32 00 34 00 34  .2.2.4.4
        .byte   $00,$34,$00,$34,$00,$35,$00,$35 ; CB35 00 34 00 34 00 35 00 35  .4.4.5.5
        .byte   $00,$35,$00,$35,$00,$34,$00,$34 ; CB3D 00 35 00 35 00 34 00 34  .5.5.4.4
        .byte   $00,$32,$00,$32,$00,$34,$00,$34 ; CB45 00 32 00 32 00 34 00 34  .2.2.4.4
        .byte   $00,$34,$00,$34,$00,$34,$00,$34 ; CB4D 00 34 00 34 00 34 00 34  .4.4.4.4
        .byte   $00,$34,$00,$34,$00,$32,$00,$32 ; CB55 00 34 00 34 00 32 00 32  .4.4.2.2
        .byte   $00,$32,$00,$32,$00,$34,$00,$34 ; CB5D 00 32 00 32 00 34 00 34  .2.2.4.4
        .byte   $00,$30,$00,$30,$00,$32,$00,$32 ; CB65 00 30 00 30 00 32 00 32  .0.0.2.2
        .byte   $00,$32,$00,$32,$00,$34,$00,$34 ; CB6D 00 32 00 32 00 34 00 34  .2.2.4.4
        .byte   $00,$34,$00,$34,$00,$35,$00,$35 ; CB75 00 34 00 34 00 35 00 35  .4.4.5.5
        .byte   $00,$35,$00,$35,$00,$34,$00,$34 ; CB7D 00 35 00 35 00 34 00 34  .5.5.4.4
        .byte   $00,$32,$00,$32,$00,$34,$00,$34 ; CB85 00 32 00 32 00 34 00 34  .2.2.4.4
        .byte   $00,$34,$00,$34,$00,$34,$00,$34 ; CB8D 00 34 00 34 00 34 00 34  .4.4.4.4
        .byte   $00,$34,$00,$34,$00,$35,$00,$35 ; CB95 00 34 00 34 00 35 00 35  .4.4.5.5
        .byte   $00,$35,$00,$35,$00,$34,$00,$34 ; CB9D 00 35 00 35 00 34 00 34  .5.5.4.4
        .byte   $00,$32,$00,$32,$00,$34,$00,$34 ; CBA5 00 32 00 32 00 34 00 34  .2.2.4.4
        .byte   $00,$34,$00,$34,$FF,$90,$CA,$FF ; CBAD 00 34 00 34 FF 90 CA FF  .4.4....
        .byte   $B4,$CB,$01,$01,$01,$01,$01,$01 ; CBB5 B4 CB 01 01 01 01 01 01  ........
        .byte   $01,$01,$01,$01,$01,$01,$01,$01 ; CBBD 01 01 01 01 01 01 01 01  ........
        .byte   $01,$01,$01,$01,$01,$01,$01,$01 ; CBC5 01 01 01 01 01 01 01 01  ........
        .byte   $01,$01,$02,$02,$02,$02,$02,$02 ; CBCD 01 01 02 02 02 02 02 02  ........
        .byte   $02,$02,$02,$02,$02,$02,$02,$02 ; CBD5 02 02 02 02 02 02 02 02  ........
        .byte   $02,$02,$02,$02,$02,$02,$FF,$B7 ; CBDD 02 02 02 02 02 02 FF B7  ........
        .byte   $CB,$06,$06,$06,$06,$06,$06,$06 ; CBE5 CB 06 06 06 06 06 06 06  ........
        .byte   $06,$06,$06,$06,$06,$06,$06,$06 ; CBED 06 06 06 06 06 06 06 06  ........
        .byte   $06,$B6,$06,$06,$06,$A6,$06,$06 ; CBF5 06 B6 06 06 06 A6 06 06  ........
        .byte   $06,$B6,$06,$06,$06,$A6,$46,$46 ; CBFD 06 B6 06 06 06 A6 46 46  ......FF
        .byte   $46,$B6,$06,$06,$06,$A6,$06,$06 ; CC05 46 B6 06 06 06 A6 06 06  F.......
        .byte   $06,$B6,$06,$06,$06,$A6,$A6,$A6 ; CC0D 06 B6 06 06 06 A6 A6 A6  ........
        .byte   $A6,$B6,$06,$46,$46,$A6,$06,$46 ; CC15 A6 B6 06 46 46 A6 06 46  ...FF..F
        .byte   $46,$B6,$06,$46,$46,$A6,$06,$46 ; CC1D 46 B6 06 46 46 A6 06 46  F..FF..F
        .byte   $46,$F9,$08,$F8,$01,$9F,$00,$00 ; CC25 46 F9 08 F8 01 9F 00 00  F.......
        .byte   $00,$F7,$3C,$00,$93,$29,$00,$32 ; CC2D 00 F7 3C 00 93 29 00 32  ..<..).2
        .byte   $00,$35,$00,$34,$00,$29,$00,$32 ; CC35 00 35 00 34 00 29 00 32  .5.4.).2
        .byte   $00,$29,$00,$30,$00,$29,$00,$32 ; CC3D 00 29 00 30 00 29 00 32  .).0.).2
        .byte   $00,$29,$00,$34,$00,$29,$00,$32 ; CC45 00 29 00 34 00 29 00 32  .).4.).2
        .byte   $00,$96,$29,$00,$93,$29,$00,$32 ; CC4D 00 96 29 00 93 29 00 32  ..)..).2
        .byte   $00,$35,$00,$34,$00,$29,$00,$32 ; CC55 00 35 00 34 00 29 00 32  .5.4.).2
        .byte   $00,$29,$00,$30,$00,$29,$00,$32 ; CC5D 00 29 00 30 00 29 00 32  .).0.).2
        .byte   $00,$29,$00,$34,$00,$29,$00,$35 ; CC65 00 29 00 34 00 29 00 35  .).4.).5
        .byte   $00,$96,$37,$00,$93,$29,$00,$32 ; CC6D 00 96 37 00 93 29 00 32  ..7..).2
        .byte   $00,$35,$00,$34,$00,$29,$00,$32 ; CC75 00 35 00 34 00 29 00 32  .5.4.).2
        .byte   $00,$29,$00,$30,$00,$29,$00,$32 ; CC7D 00 29 00 30 00 29 00 32  .).0.).2
        .byte   $00,$29,$00,$34,$00,$29,$00,$32 ; CC85 00 29 00 34 00 29 00 32  .).4.).2
        .byte   $00,$96,$29,$00,$93,$29,$00,$32 ; CC8D 00 96 29 00 93 29 00 32  ..)..).2
        .byte   $00,$35,$00,$34,$00,$29,$00,$32 ; CC95 00 35 00 34 00 29 00 32  .5.4.).2
        .byte   $00,$29,$00,$30,$00,$29,$00,$32 ; CC9D 00 29 00 30 00 29 00 32  .).0.).2
        .byte   $00,$29,$00,$34,$00,$29,$00,$35 ; CCA5 00 29 00 34 00 29 00 35  .).4.).5
        .byte   $00,$96,$37,$00,$93,$29,$00,$32 ; CCAD 00 96 37 00 93 29 00 32  ..7..).2
        .byte   $00,$35,$00,$34,$00,$29,$00,$32 ; CCB5 00 35 00 34 00 29 00 32  .5.4.).2
        .byte   $00,$29,$00,$30,$00,$29,$00,$32 ; CCBD 00 29 00 30 00 29 00 32  .).0.).2
        .byte   $00,$29,$00,$34,$00,$29,$00,$32 ; CCC5 00 29 00 34 00 29 00 32  .).4.).2
        .byte   $00,$96,$29,$00,$93,$29,$00,$32 ; CCCD 00 96 29 00 93 29 00 32  ..)..).2
        .byte   $00,$35,$00,$34,$00,$29,$00,$32 ; CCD5 00 35 00 34 00 29 00 32  .5.4.).2
        .byte   $00,$29,$00,$30,$00,$29,$00,$32 ; CCDD 00 29 00 30 00 29 00 32  .).0.).2
        .byte   $00,$29,$00,$34,$00,$29,$00,$35 ; CCE5 00 29 00 34 00 29 00 35  .).4.).5
        .byte   $00,$96,$37,$00,$93,$29,$00,$32 ; CCED 00 96 37 00 93 29 00 32  ..7..).2
        .byte   $00,$35,$00,$34,$00,$29,$00,$32 ; CCF5 00 35 00 34 00 29 00 32  .5.4.).2
        .byte   $00,$29,$00,$30,$00,$29,$00,$32 ; CCFD 00 29 00 30 00 29 00 32  .).0.).2
        .byte   $00,$29,$00,$34,$00,$29,$00,$32 ; CD05 00 29 00 34 00 29 00 32  .).4.).2
        .byte   $00,$96,$29,$00,$93,$29,$00,$32 ; CD0D 00 96 29 00 93 29 00 32  ..)..).2
        .byte   $00,$35,$00,$34,$00,$29,$00,$32 ; CD15 00 35 00 34 00 29 00 32  .5.4.).2
        .byte   $00,$29,$00,$30,$00,$29,$00,$32 ; CD1D 00 29 00 30 00 29 00 32  .).0.).2
        .byte   $00,$29,$00,$34,$00,$29,$00,$35 ; CD25 00 29 00 34 00 29 00 35  .).4.).5
        .byte   $00,$96,$37,$00,$93,$29,$00,$32 ; CD2D 00 96 37 00 93 29 00 32  ..7..).2
        .byte   $00,$35,$00,$F7,$60,$35,$9F,$35 ; CD35 00 35 00 F7 60 35 9F 35  .5..`5.5
        .byte   $93,$35,$00,$30,$98,$00,$93,$33 ; CD3D 93 35 00 30 98 00 93 33  .5.0...3
        .byte   $98,$00,$93,$2A,$98,$00,$93,$30 ; CD45 98 00 93 2A 98 00 93 30  ...*...0
        .byte   $00,$30,$00,$28,$00,$2A,$00,$30 ; CD4D 00 30 00 28 00 2A 00 30  .0.(.*.0
        .byte   $00,$33,$00,$99,$35,$93,$33,$00 ; CD55 00 33 00 99 35 93 33 00  .3..5.3.
        .byte   $35,$00,$30,$98,$00,$93,$33,$98 ; CD5D 35 00 30 98 00 93 33 98  5.0...3.
        .byte   $00,$93,$2A,$98,$00,$93,$30,$00 ; CD65 00 93 2A 98 00 93 30 00  ..*...0.
        .byte   $30,$00,$28,$98,$00,$93,$2A,$00 ; CD6D 30 00 28 98 00 93 2A 00  0.(...*.
        .byte   $99,$23,$96,$25,$00,$93,$35,$00 ; CD75 99 23 96 25 00 93 35 00  .#.%..5.
        .byte   $30,$98,$00,$93,$33,$98,$00,$93 ; CD7D 30 98 00 93 33 98 00 93  0...3...
        .byte   $2A,$98,$00,$93,$30,$00,$96,$30 ; CD85 2A 98 00 93 30 00 96 30  *...0..0
        .byte   $93,$28,$00,$2A,$00,$30,$00,$33 ; CD8D 93 28 00 2A 00 30 00 33  .(.*.0.3
        .byte   $00,$99,$35,$93,$33,$00,$35,$00 ; CD95 00 99 35 93 33 00 35 00  ..5.3.5.
        .byte   $30,$98,$00,$93,$33,$98,$00,$93 ; CD9D 30 98 00 93 33 98 00 93  0...3...
        .byte   $2A,$98,$00,$93,$30,$00,$96,$30 ; CDA5 2A 98 00 93 30 00 96 30  *...0..0
        .byte   $93,$28,$98,$00,$93,$2A,$00,$99 ; CDAD 93 28 98 00 93 2A 00 99  .(...*..
        .byte   $23,$93,$25,$98,$00,$93,$35,$00 ; CDB5 23 93 25 98 00 93 35 00  #.%...5.
        .byte   $30,$98,$00,$93,$33,$98,$00,$93 ; CDBD 30 98 00 93 33 98 00 93  0...3...
        .byte   $2A,$98,$00,$F7,$0C,$30,$96,$30 ; CDC5 2A 98 00 F7 0C 30 96 30  *....0.0
        .byte   $31,$93,$33,$00,$36,$00,$30,$00 ; CDCD 31 93 33 00 36 00 30 00  1.3.6.0.
        .byte   $31,$00,$32,$00,$F7,$0C,$34,$F7 ; CDD5 31 00 32 00 F7 0C 34 F7  1.2...4.
        .byte   $3C,$34,$32,$00,$31,$00,$F7,$0C ; CDDD 3C 34 32 00 31 00 F7 0C  <42.1...
        .byte   $2B,$9C,$2B,$93,$34,$00,$35,$00 ; CDE5 2B 9C 2B 93 34 00 35 00  +.+.4.5.
        .byte   $36,$00,$F7,$0C,$37,$F7,$3C,$37 ; CDED 36 00 F7 0C 37 F7 3C 37  6...7.<7
        .byte   $36,$00,$37,$00,$F7,$0C,$39,$96 ; CDF5 36 00 37 00 F7 0C 39 96  6.7...9.
        .byte   $39,$93,$37,$00,$39,$00,$F7,$3C ; CDFD 39 93 37 00 39 00 F7 3C  9.7.9..<
        .byte   $3B,$FF,$26,$CC,$F9,$08,$F8,$03 ; CE05 3B FF 26 CC F9 08 F8 03  ;.&.....
        .byte   $93,$12,$00,$22,$00,$12,$00,$22 ; CE0D 93 12 00 22 00 12 00 22  ..."..."
        .byte   $00,$15,$00,$25,$00,$15,$00,$25 ; CE15 00 15 00 25 00 15 00 25  ...%...%
        .byte   $00,$0A,$00,$1A,$00,$0A,$00,$1A ; CE1D 00 0A 00 1A 00 0A 00 1A  ........
        .byte   $00,$10,$00,$20,$00,$10,$00,$20 ; CE25 00 10 00 20 00 10 00 20  ... ... 
        .byte   $00,$12,$00,$22,$00,$12,$00,$22 ; CE2D 00 12 00 22 00 12 00 22  ..."..."
        .byte   $00,$15,$00,$25,$00,$15,$00,$25 ; CE35 00 15 00 25 00 15 00 25  ...%...%
        .byte   $00,$0A,$00,$1A,$00,$0A,$00,$1A ; CE3D 00 0A 00 1A 00 0A 00 1A  ........
        .byte   $00,$10,$00,$20,$00,$10,$00,$20 ; CE45 00 10 00 20 00 10 00 20  ... ... 
        .byte   $00,$12,$00,$22,$00,$12,$00,$22 ; CE4D 00 12 00 22 00 12 00 22  ..."..."
        .byte   $00,$15,$00,$25,$00,$15,$00,$25 ; CE55 00 15 00 25 00 15 00 25  ...%...%
        .byte   $00,$0A,$00,$1A,$00,$0A,$00,$1A ; CE5D 00 0A 00 1A 00 0A 00 1A  ........
        .byte   $00,$10,$00,$20,$00,$10,$00,$20 ; CE65 00 10 00 20 00 10 00 20  ... ... 
        .byte   $00,$12,$00,$22,$00,$12,$00,$22 ; CE6D 00 12 00 22 00 12 00 22  ..."..."
        .byte   $00,$15,$00,$25,$00,$15,$00,$25 ; CE75 00 15 00 25 00 15 00 25  ...%...%
        .byte   $00,$0A,$00,$1A,$00,$0A,$00,$1A ; CE7D 00 0A 00 1A 00 0A 00 1A  ........
        .byte   $00,$10,$00,$20,$00,$10,$00,$20 ; CE85 00 10 00 20 00 10 00 20  ... ... 
        .byte   $00,$12,$00,$22,$00,$12,$00,$22 ; CE8D 00 12 00 22 00 12 00 22  ..."..."
        .byte   $00,$15,$00,$25,$00,$15,$00,$25 ; CE95 00 15 00 25 00 15 00 25  ...%...%
        .byte   $00,$0A,$00,$1A,$00,$0A,$00,$1A ; CE9D 00 0A 00 1A 00 0A 00 1A  ........
        .byte   $00,$10,$00,$20,$00,$10,$00,$20 ; CEA5 00 10 00 20 00 10 00 20  ... ... 
        .byte   $00,$12,$00,$22,$00,$12,$00,$22 ; CEAD 00 12 00 22 00 12 00 22  ..."..."
        .byte   $00,$15,$00,$25,$00,$15,$00,$25 ; CEB5 00 15 00 25 00 15 00 25  ...%...%
        .byte   $00,$0A,$00,$1A,$00,$0A,$00,$1A ; CEBD 00 0A 00 1A 00 0A 00 1A  ........
        .byte   $00,$10,$00,$20,$00,$10,$00,$20 ; CEC5 00 10 00 20 00 10 00 20  ... ... 
        .byte   $00,$12,$00,$22,$00,$12,$00,$22 ; CECD 00 12 00 22 00 12 00 22  ..."..."
        .byte   $00,$15,$00,$25,$00,$15,$00,$25 ; CED5 00 15 00 25 00 15 00 25  ...%...%
        .byte   $00,$0A,$00,$1A,$00,$0A,$00,$1A ; CEDD 00 0A 00 1A 00 0A 00 1A  ........
        .byte   $00,$10,$00,$20,$00,$10,$00,$20 ; CEE5 00 10 00 20 00 10 00 20  ... ... 
        .byte   $00,$12,$00,$22,$00,$12,$00,$22 ; CEED 00 12 00 22 00 12 00 22  ..."..."
        .byte   $00,$15,$00,$25,$00,$15,$00,$25 ; CEF5 00 15 00 25 00 15 00 25  ...%...%
        .byte   $00,$0A,$00,$1A,$00,$0A,$00,$1A ; CEFD 00 0A 00 1A 00 0A 00 1A  ........
        .byte   $00,$10,$00,$20,$00,$10,$00,$20 ; CF05 00 10 00 20 00 10 00 20  ... ... 
        .byte   $00,$12,$00,$22,$00,$12,$00,$22 ; CF0D 00 12 00 22 00 12 00 22  ..."..."
        .byte   $00,$15,$00,$25,$00,$15,$00,$25 ; CF15 00 15 00 25 00 15 00 25  ...%...%
        .byte   $00,$0A,$00,$1A,$00,$0A,$00,$1A ; CF1D 00 0A 00 1A 00 0A 00 1A  ........
        .byte   $00,$10,$00,$20,$00,$10,$00,$20 ; CF25 00 10 00 20 00 10 00 20  ... ... 
        .byte   $00,$12,$00,$22,$00,$12,$00,$22 ; CF2D 00 12 00 22 00 12 00 22  ..."..."
        .byte   $00,$15,$00,$25,$00,$15,$00,$25 ; CF35 00 15 00 25 00 15 00 25  ...%...%
        .byte   $00,$0A,$00,$1A,$00,$0A,$00,$1A ; CF3D 00 0A 00 1A 00 0A 00 1A  ........
        .byte   $00,$10,$00,$20,$00,$10,$00,$20 ; CF45 00 10 00 20 00 10 00 20  ... ... 
        .byte   $00,$15,$00,$15,$13,$10,$00,$13 ; CF4D 00 15 00 15 13 10 00 13  ........
        .byte   $00,$15,$00,$15,$13,$10,$00,$13 ; CF55 00 15 00 15 13 10 00 13  ........
        .byte   $00,$15,$00,$15,$13,$10,$00,$13 ; CF5D 00 15 00 15 13 10 00 13  ........
        .byte   $00,$15,$00,$16,$00,$17,$00,$96 ; CF65 00 15 00 16 00 17 00 96  ........
        .byte   $18,$93,$18,$00,$18,$16,$13,$00 ; CF6D 18 93 18 00 18 16 13 00  ........
        .byte   $16,$00,$18,$00,$18,$16,$13,$00 ; CF75 16 00 18 00 18 16 13 00  ........
        .byte   $16,$00,$18,$00,$18,$16,$13,$00 ; CF7D 16 00 18 00 18 16 13 00  ........
        .byte   $16,$00,$18,$00,$17,$00,$16,$00 ; CF85 16 00 18 00 17 00 16 00  ........
        .byte   $96,$15,$93,$15,$00,$15,$13,$10 ; CF8D 96 15 93 15 00 15 13 10  ........
        .byte   $00,$13,$00,$15,$00,$15,$13,$10 ; CF95 00 13 00 15 00 15 13 10  ........
        .byte   $00,$13,$00,$15,$00,$15,$13,$10 ; CF9D 00 13 00 15 00 15 13 10  ........
        .byte   $00,$13,$00,$15,$00,$16,$00,$17 ; CFA5 00 13 00 15 00 16 00 17  ........
        .byte   $00,$96,$18,$93,$18,$00,$18,$16 ; CFAD 00 96 18 93 18 00 18 16  ........
        .byte   $13,$00,$16,$00,$18,$00,$18,$16 ; CFB5 13 00 16 00 18 00 18 16  ........
        .byte   $13,$00,$16,$00,$18,$00,$18,$16 ; CFBD 13 00 16 00 18 00 18 16  ........
        .byte   $13,$00,$16,$00,$18,$00,$17,$00 ; CFC5 13 00 16 00 18 00 17 00  ........
        .byte   $16,$00,$96,$15,$93,$15,$00,$15 ; CFCD 16 00 96 15 93 15 00 15  ........
        .byte   $13,$10,$00,$13,$00,$15,$00,$15 ; CFD5 13 10 00 13 00 15 00 15  ........
        .byte   $13,$10,$00,$13,$00,$15,$00,$15 ; CFDD 13 10 00 13 00 15 00 15  ........
        .byte   $13,$10,$00,$13,$00,$15,$00,$16 ; CFE5 13 10 00 13 00 15 00 16  ........
        .byte   $00,$17,$00,$96,$18,$93,$18,$00 ; CFED 00 17 00 96 18 93 18 00  ........
        .byte   $18,$16,$13,$00,$16,$00,$18,$00 ; CFF5 18 16 13 00 16 00 18 00  ........
        .byte   $18,$16,$13,$00,$16,$00,$18,$00 ; CFFD 18 16 13 00 16 00 18 00  ........
        .byte   $18,$16,$13,$00,$16,$00,$18,$00 ; D005 18 16 13 00 16 00 18 00  ........
        .byte   $19,$00,$1A,$00,$96,$1B,$93,$1B ; D00D 19 00 1A 00 96 1B 93 1B  ........
        .byte   $00,$1B,$19,$96,$16,$19,$1B,$93 ; D015 00 1B 19 96 16 19 1B 93  ........
        .byte   $1B,$19,$96,$16,$19,$93,$1B,$00 ; D01D 1B 19 96 16 19 93 1B 00  ........
        .byte   $1B,$19,$96,$16,$19,$93,$1B,$00 ; D025 1B 19 96 16 19 93 1B 00  ........
        .byte   $20,$00,$21,$00,$96,$12,$12,$93 ; D02D 20 00 21 00 96 12 12 93   .!.....
        .byte   $12,$10,$96,$09,$10,$93,$12,$00 ; D035 12 10 96 09 10 93 12 00  ........
        .byte   $12,$10,$96,$09,$10,$93,$14,$00 ; D03D 12 10 96 09 10 93 14 00  ........
        .byte   $14,$12,$96,$0B,$12,$93,$16,$00 ; D045 14 12 96 0B 12 93 16 00  ........
        .byte   $16,$14,$99,$11,$FF,$09,$CE,$9F ; D04D 16 14 99 11 FF 09 CE 9F  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; D055 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$9E,$29,$93,$27 ; D05D 00 00 00 00 9E 29 93 27  .....).'
        .byte   $29,$2A,$30,$9C,$32,$99,$30,$2A ; D065 29 2A 30 9C 32 99 30 2A  )*0.2.0*
        .byte   $96,$30,$29,$9B,$25,$93,$25,$00 ; D06D 96 30 29 9B 25 93 25 00  .0).%.%.
        .byte   $27,$00,$29,$00,$9B,$2A,$27,$99 ; D075 27 00 29 00 9B 2A 27 99  '.)..*'.
        .byte   $24,$9E,$29,$93,$34,$35,$37,$39 ; D07D 24 9E 29 93 34 35 37 39  $.).4579
        .byte   $9C,$3A,$99,$39,$37,$96,$39,$35 ; D085 9C 3A 99 39 37 96 39 35  .:.97.95
        .byte   $9B,$40,$96,$40,$44,$45,$9B,$47 ; D08D 9B 40 96 40 44 45 9B 47  .@.@DE.G
        .byte   $44,$99,$40,$F7,$60,$2A,$9F,$2A ; D095 44 99 40 F7 60 2A 9F 2A  D.@.`*.*
        .byte   $00,$00,$93,$25,$27,$28,$27,$25 ; D09D 00 00 93 25 27 28 27 25  ...%'('%
        .byte   $98,$00,$93,$25,$27,$28,$2A,$30 ; D0A5 98 00 93 25 27 28 2A 30  ...%'(*0
        .byte   $98,$00,$93,$2A,$30,$31,$33,$35 ; D0AD 98 00 93 2A 30 31 33 35  ...*0135
        .byte   $98,$00,$93,$35,$37,$38,$3A,$96 ; D0B5 98 00 93 35 37 38 3A 96  ...578:.
        .byte   $40,$00,$40,$93,$40,$00,$40,$00 ; D0BD 40 00 40 93 40 00 40 00  @.@.@.@.
        .byte   $41,$00,$99,$3A,$F7,$18,$3A,$96 ; D0C5 41 00 99 3A F7 18 3A 96  A..:..:.
        .byte   $3A,$43,$3A,$40,$99,$38,$40,$93 ; D0CD 3A 43 3A 40 99 38 40 93  :C:@.8@.
        .byte   $25,$27,$28,$27,$25,$98,$00,$93 ; D0D5 25 27 28 27 25 98 00 93  %'('%...
        .byte   $25,$27,$28,$2A,$30,$98,$00,$93 ; D0DD 25 27 28 2A 30 98 00 93  %'(*0...
        .byte   $2A,$30,$31,$33,$96,$35,$00,$93 ; D0E5 2A 30 31 33 96 35 00 93  *013.5..
        .byte   $35,$37,$38,$3A,$F7,$18,$40,$96 ; D0ED 35 37 38 3A F7 18 40 96  578:..@.
        .byte   $40,$93,$40,$00,$96,$40,$41,$99 ; D0F5 40 93 40 00 96 40 41 99  @.@..@A.
        .byte   $3A,$F7,$18,$40,$93,$40,$00,$96 ; D0FD 3A F7 18 40 93 40 00 96  :..@.@..
        .byte   $31,$33,$36,$38,$39,$3A,$F7,$0C ; D105 31 33 36 38 39 3A F7 0C  13689:..
        .byte   $3B,$F7,$3C,$3B,$39,$38,$F7,$0C ; D10D 3B F7 3C 3B 39 38 F7 0C  ;.<;98..
        .byte   $36,$9C,$36,$96,$3B,$40,$41,$F7 ; D115 36 9C 36 96 3B 40 41 F7  6.6.;@A.
        .byte   $0C,$42,$F7,$3C,$42,$40,$42,$F7 ; D11D 0C 42 F7 3C 42 40 42 F7  .B.<B@B.
        .byte   $0C,$44,$44,$93,$42,$00,$44,$00 ; D125 0C 44 44 93 42 00 44 00  .DD.B.D.
        .byte   $F7,$3C,$46,$FF,$54,$D0,$FF,$33 ; D12D F7 3C 46 FF 54 D0 FF 33  .<F.T..3
        .byte   $D1,$01,$01,$01,$01,$01,$01,$01 ; D135 D1 01 01 01 01 01 01 01  ........
        .byte   $01,$02,$02,$02,$02,$02,$02,$02 ; D13D 01 02 02 02 02 02 02 02  ........
        .byte   $02,$02,$02,$02,$03,$04,$04,$04 ; D145 02 02 02 02 03 04 04 04  ........
        .byte   $04,$04,$04,$04,$04,$04,$04,$04 ; D14D 04 04 04 04 04 04 04 04  ........
        .byte   $04,$04,$04,$04,$04,$FF,$36,$D1 ; D155 04 04 04 04 04 FF 36 D1  ......6.
        .byte   $06,$06,$06,$06,$A6,$06,$06,$06 ; D15D 06 06 06 06 A6 06 06 06  ........
        .byte   $06,$06,$06,$06,$A6,$06,$06,$06 ; D165 06 06 06 06 A6 06 06 06  ........
        .byte   $B6,$06,$06,$06,$06,$06,$06,$06 ; D16D B6 06 06 06 06 06 06 06  ........
        .byte   $06,$06,$06,$06,$06,$06,$06,$06 ; D175 06 06 06 06 06 06 06 06  ........
        .byte   $06,$06,$06,$06,$06,$06,$06,$06 ; D17D 06 06 06 06 06 06 06 06  ........
        .byte   $06,$06,$06,$06,$06,$06,$06,$06 ; D185 06 06 06 06 06 06 06 06  ........
        .byte   $06,$06,$06,$06,$06,$06,$06,$06 ; D18D 06 06 06 06 06 06 06 06  ........
        .byte   $06,$06,$06,$06,$06,$06,$06,$06 ; D195 06 06 06 06 06 06 06 06  ........
        .byte   $06,$06,$06,$06,$06,$06,$06,$06 ; D19D 06 06 06 06 06 06 06 06  ........
        .byte   $06,$06,$06,$06,$06,$06,$06,$06 ; D1A5 06 06 06 06 06 06 06 06  ........
        .byte   $F9,$08,$F8,$05,$99,$34,$96,$2B ; D1AD F9 08 F8 05 99 34 96 2B  .....4.+
        .byte   $30,$99,$32,$96,$30,$2B,$99,$29 ; D1B5 30 99 32 96 30 2B 99 29  0.2.0+.)
        .byte   $96,$29,$30,$99,$34,$96,$32,$30 ; D1BD 96 29 30 99 34 96 32 30  .)0.4.20
        .byte   $99,$2B,$96,$2B,$30,$98,$32,$93 ; D1C5 99 2B 96 2B 30 98 32 93  .+.+0.2.
        .byte   $00,$98,$34,$93,$00,$99,$30,$98 ; D1CD 00 98 34 93 00 99 30 98  ..4...0.
        .byte   $29,$93,$00,$9C,$29,$96,$32,$98 ; D1D5 29 93 00 9C 29 96 32 98  )...).2.
        .byte   $32,$93,$00,$96,$35,$98,$39,$93 ; D1DD 32 93 00 96 35 98 39 93  2...5.9.
        .byte   $00,$96,$37,$35,$98,$34,$93,$00 ; D1E5 00 96 37 35 98 34 93 00  ..75.4..
        .byte   $96,$34,$30,$98,$34,$93,$00,$96 ; D1ED 96 34 30 98 34 93 00 96  .40.4...
        .byte   $32,$30,$98,$2B,$93,$00,$96,$2B ; D1F5 32 30 98 2B 93 00 96 2B  20.+...+
        .byte   $30,$98,$32,$93,$00,$98,$34,$93 ; D1FD 30 98 32 93 00 98 34 93  0.2...4.
        .byte   $00,$98,$30,$93,$00,$98,$29,$93 ; D205 00 98 30 93 00 98 29 93  ..0...).
        .byte   $00,$9C,$29,$F7,$1B,$34,$95,$00 ; D20D 00 9C 29 F7 1B 34 95 00  ..)..4..
        .byte   $96,$33,$F7,$1B,$34,$95,$00,$96 ; D215 96 33 F7 1B 34 95 00 96  .3..4...
        .byte   $32,$F7,$1B,$34,$95,$00,$96,$39 ; D21D 32 F7 1B 34 95 00 96 39  2..4...9
        .byte   $98,$34,$93,$00,$96,$32,$30,$98 ; D225 98 34 93 00 96 32 30 98  .4...20.
        .byte   $2B,$93,$00,$96,$2B,$30,$98,$32 ; D22D 2B 93 00 96 2B 30 98 32  +...+0.2
        .byte   $93,$00,$98,$34,$93,$00,$F7,$60 ; D235 93 00 98 34 93 00 F7 60  ...4...`
        .byte   $39,$F7,$4E,$39,$98,$00,$99,$34 ; D23D 39 F7 4E 39 98 00 99 34  9.N9...4
        .byte   $96,$2B,$30,$99,$32,$96,$30,$2B ; D245 96 2B 30 99 32 96 30 2B  .+0.2.0+
        .byte   $99,$29,$96,$29,$30,$99,$34,$96 ; D24D 99 29 96 29 30 99 34 96  .).)0.4.
        .byte   $32,$30,$99,$2B,$96,$2B,$30,$98 ; D255 32 30 99 2B 96 2B 30 98  20.+.+0.
        .byte   $32,$93,$00,$98,$34,$93,$00,$99 ; D25D 32 93 00 98 34 93 00 99  2...4...
        .byte   $30,$98,$29,$93,$00,$9C,$29,$96 ; D265 30 98 29 93 00 9C 29 96  0.)...).
        .byte   $32,$98,$32,$93,$00,$96,$35,$98 ; D26D 32 98 32 93 00 96 35 98  2.2...5.
        .byte   $39,$93,$00,$96,$37,$35,$98,$34 ; D275 39 93 00 96 37 35 98 34  9...75.4
        .byte   $93,$00,$96,$34,$30,$98,$34,$93 ; D27D 93 00 96 34 30 98 34 93  ...40.4.
        .byte   $00,$96,$32,$30,$98,$2B,$93,$00 ; D285 00 96 32 30 98 2B 93 00  ..20.+..
        .byte   $96,$2B,$30,$98,$32,$93,$00,$98 ; D28D 96 2B 30 98 32 93 00 98  .+0.2...
        .byte   $34,$93,$00,$98,$30,$93,$00,$98 ; D295 34 93 00 98 30 93 00 98  4...0...
        .byte   $29,$93,$00,$9C,$29,$99,$34,$96 ; D29D 29 93 00 9C 29 99 34 96  )...).4.
        .byte   $2B,$30,$99,$32,$96,$30,$2B,$99 ; D2A5 2B 30 99 32 96 30 2B 99  +0.2.0+.
        .byte   $29,$96,$29,$30,$99,$34,$96,$32 ; D2AD 29 96 29 30 99 34 96 32  ).)0.4.2
        .byte   $30,$99,$2B,$96,$2B,$30,$98,$32 ; D2B5 30 99 2B 96 2B 30 98 32  0.+.+0.2
        .byte   $93,$00,$98,$34,$93,$00,$99,$30 ; D2BD 93 00 98 34 93 00 99 30  ...4...0
        .byte   $98,$29,$93,$00,$9C,$29,$96,$32 ; D2C5 98 29 93 00 9C 29 96 32  .)...).2
        .byte   $98,$32,$93,$00,$96,$35,$98,$39 ; D2CD 98 32 93 00 96 35 98 39  .2...5.9
        .byte   $93,$00,$96,$37,$35,$98,$34,$93 ; D2D5 93 00 96 37 35 98 34 93  ...75.4.
        .byte   $00,$96,$34,$30,$98,$34,$93,$00 ; D2DD 00 96 34 30 98 34 93 00  ..40.4..
        .byte   $96,$32,$30,$98,$2B,$93,$00,$96 ; D2E5 96 32 30 98 2B 93 00 96  .20.+...
        .byte   $2B,$30,$98,$32,$93,$00,$98,$34 ; D2ED 2B 30 98 32 93 00 98 34  +0.2...4
        .byte   $93,$00,$98,$30,$93,$00,$98,$29 ; D2F5 93 00 98 30 93 00 98 29  ...0...)
        .byte   $93,$00,$9C,$29,$F7,$1B,$34,$95 ; D2FD 93 00 9C 29 F7 1B 34 95  ...)..4.
        .byte   $00,$96,$33,$F7,$1B,$34,$95,$00 ; D305 00 96 33 F7 1B 34 95 00  ..3..4..
        .byte   $96,$33,$F7,$1B,$34,$95,$00,$96 ; D30D 96 33 F7 1B 34 95 00 96  .3..4...
        .byte   $39,$98,$34,$93,$00,$96,$32,$30 ; D315 39 98 34 93 00 96 32 30  9.4...20
        .byte   $98,$2B,$93,$00,$96,$2B,$30,$98 ; D31D 98 2B 93 00 96 2B 30 98  .+...+0.
        .byte   $32,$93,$00,$98,$34,$93,$00,$98 ; D325 32 93 00 98 34 93 00 98  2...4...
        .byte   $30,$93,$00,$98,$29,$93,$00,$9C ; D32D 30 93 00 98 29 93 00 9C  0...)...
        .byte   $29,$F7,$1B,$34,$95,$00,$96,$33 ; D335 29 F7 1B 34 95 00 96 33  )..4...3
        .byte   $F7,$1B,$34,$95,$00,$96,$32,$F7 ; D33D F7 1B 34 95 00 96 32 F7  ..4...2.
        .byte   $1B,$34,$95,$00,$96,$39,$98,$34 ; D345 1B 34 95 00 96 39 98 34  .4...9.4
        .byte   $93,$00,$96,$32,$30,$98,$2B,$93 ; D34D 93 00 96 32 30 98 2B 93  ...20.+.
        .byte   $00,$96,$2B,$30,$98,$32,$93,$00 ; D355 00 96 2B 30 98 32 93 00  ..+0.2..
        .byte   $98,$34,$93,$00,$F7,$60,$39,$F7 ; D35D 98 34 93 00 F7 60 39 F7  .4...`9.
        .byte   $4E,$39,$98,$00,$FE,$AD,$D1,$F9 ; D365 4E 39 98 00 FE AD D1 F9  N9......
        .byte   $08,$F8,$05,$F7,$60,$28,$9E,$29 ; D36D 08 F8 05 F7 60 28 9E 29  ....`(.)
        .byte   $96,$29,$28,$9E,$24,$99,$24,$F7 ; D375 96 29 28 9E 24 99 24 F7  .)(.$.$.
        .byte   $4E,$29,$98,$00,$9E,$32,$96,$30 ; D37D 4E 29 98 00 9E 32 96 30  N)...2.0
        .byte   $2B,$9E,$29,$96,$2B,$29,$9C,$28 ; D385 2B 9E 29 96 2B 29 9C 28  +.).+).(
        .byte   $96,$28,$93,$29,$28,$96,$24,$28 ; D38D 96 28 93 29 28 96 24 28  .(.)(.$(
        .byte   $9F,$29,$00,$9E,$29,$96,$2B,$29 ; D395 9F 29 00 9E 29 96 2B 29  .)..).+)
        .byte   $9C,$28,$96,$28,$93,$29,$28,$96 ; D39D 9C 28 96 28 93 29 28 96  .(.(.)(.
        .byte   $24,$28,$F7,$60,$29,$F7,$54,$29 ; D3A5 24 28 F7 60 29 F7 54 29  $(.`).T)
        .byte   $00,$F7,$60,$28,$9E,$29,$96,$29 ; D3AD 00 F7 60 28 9E 29 96 29  ..`(.).)
        .byte   $28,$9E,$24,$99,$24,$F7,$4E,$29 ; D3B5 28 9E 24 99 24 F7 4E 29  (.$.$.N)
        .byte   $98,$00,$9E,$32,$96,$30,$2B,$9E ; D3BD 98 00 9E 32 96 30 2B 9E  ...2.0+.
        .byte   $29,$96,$2B,$29,$9C,$28,$96,$28 ; D3C5 29 96 2B 29 9C 28 96 28  ).+).(.(
        .byte   $93,$29,$28,$96,$24,$28,$9F,$29 ; D3CD 93 29 28 96 24 28 9F 29  .)(.$(.)
        .byte   $F7,$60,$28,$9E,$29,$96,$29,$28 ; D3D5 F7 60 28 9E 29 96 29 28  .`(.).)(
        .byte   $9E,$24,$99,$24,$F7,$4E,$29,$98 ; D3DD 9E 24 99 24 F7 4E 29 98  .$.$.N).
        .byte   $00,$9E,$32,$96,$30,$2B,$9E,$29 ; D3E5 00 9E 32 96 30 2B 9E 29  ..2.0+.)
        .byte   $96,$2B,$29,$9C,$28,$96,$28,$93 ; D3ED 96 2B 29 9C 28 96 28 93  .+).(.(.
        .byte   $29,$28,$96,$24,$28,$9F,$29,$00 ; D3F5 29 28 96 24 28 9F 29 00  )(.$(.).
        .byte   $00,$00,$00,$00,$9E,$29,$96,$2B ; D3FD 00 00 00 00 9E 29 96 2B  .....).+
        .byte   $29,$9C,$28,$96,$28,$93,$29,$28 ; D405 29 9C 28 96 28 93 29 28  ).(.(.)(
        .byte   $96,$24,$28,$F7,$60,$29,$F7,$54 ; D40D 96 24 28 F7 60 29 F7 54  .$(.`).T
        .byte   $29,$00,$FE,$6C,$D3,$9F,$00,$00 ; D415 29 00 FE 6C D3 9F 00 00  )..l....
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; D41D 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$96,$24,$2B,$32,$38 ; D425 00 00 00 96 24 2B 32 38  ....$+28
        .byte   $32,$2B,$24,$2B,$24,$29,$30,$29 ; D42D 32 2B 24 2B 24 29 30 29  2+$+$)0)
        .byte   $34,$29,$30,$29,$24,$2B,$32,$38 ; D435 34 29 30 29 24 2B 32 38  4)0)$+28
        .byte   $32,$2B,$24,$2B,$24,$29,$30,$34 ; D43D 32 2B 24 2B 24 29 30 34  2+$+$)04
        .byte   $99,$30,$29,$96,$35,$29,$32,$35 ; D445 99 30 29 96 35 29 32 35  .0).5)25
        .byte   $93,$35,$37,$96,$35,$32,$29,$34 ; D44D 93 35 37 96 35 32 29 34  .57.52)4
        .byte   $24,$29,$34,$30,$29,$24,$29,$2B ; D455 24 29 34 30 29 24 29 2B  $)40)$)+
        .byte   $1B,$22,$29,$2B,$29,$22,$1B,$19 ; D45D 1B 22 29 2B 29 22 1B 19  .")+)"..
        .byte   $24,$29,$30,$9C,$39,$96,$24,$2B ; D465 24 29 30 9C 39 96 24 2B  $)0.9.$+
        .byte   $32,$2B,$38,$2B,$32,$2B,$24,$29 ; D46D 32 2B 38 2B 32 2B 24 29  2+8+2+$)
        .byte   $30,$29,$34,$29,$30,$29,$24,$2B ; D475 30 29 34 29 30 29 24 2B  0)4)0)$+
        .byte   $32,$38,$32,$2B,$24,$2B,$24,$29 ; D47D 32 38 32 2B 24 2B 24 29  282+$+$)
        .byte   $30,$34,$99,$30,$29,$96,$35,$29 ; D485 30 34 99 30 29 96 35 29  04.0).5)
        .byte   $32,$35,$93,$35,$37,$96,$35,$32 ; D48D 32 35 93 35 37 96 35 32  25.57.52
        .byte   $29,$34,$24,$29,$34,$30,$29,$24 ; D495 29 34 24 29 34 30 29 24  )4$)40)$
        .byte   $29,$2B,$1B,$22,$29,$2B,$29,$22 ; D49D 29 2B 1B 22 29 2B 29 22  )+.")+)"
        .byte   $1B,$19,$24,$29,$30,$9C,$39,$96 ; D4A5 1B 19 24 29 30 9C 39 96  ..$)0.9.
        .byte   $24,$29,$30,$29,$34,$29,$30,$29 ; D4AD 24 29 30 29 34 29 30 29  $)0)4)0)
        .byte   $24,$29,$30,$24,$34,$30,$29,$24 ; D4B5 24 29 30 24 34 30 29 24  $)0$40)$
        .byte   $24,$2B,$32,$2B,$38,$32,$2B,$32 ; D4BD 24 2B 32 2B 38 32 2B 32  $+2+82+2
        .byte   $24,$29,$30,$34,$9C,$30,$96,$24 ; D4C5 24 29 30 34 9C 30 96 24  $)04.0.$
        .byte   $29,$30,$29,$34,$29,$30,$29,$34 ; D4CD 29 30 29 34 29 30 29 34  )0)4)0)4
        .byte   $29,$30,$24,$34,$30,$29,$24,$24 ; D4D5 29 30 24 34 30 29 24 24  )0$40)$$
        .byte   $2B,$32,$2B,$38,$32,$2B,$32,$F7 ; D4DD 2B 32 2B 38 32 2B 32 F7  +2+82+2.
        .byte   $60,$29,$9F,$29,$FE,$1A,$D4,$FF ; D4E5 60 29 9F 29 FE 1A D4 FF  `).)....
        .byte   $EC,$D4,$03,$03,$03,$03,$03,$03 ; D4ED EC D4 03 03 03 03 03 03  ........
        .byte   $03,$03,$03,$03,$03,$03,$03,$01 ; D4F5 03 03 03 03 03 03 03 01  ........
        .byte   $01,$01,$01,$01,$01,$01,$01,$01 ; D4FD 01 01 01 01 01 01 01 01  ........
        .byte   $01,$01,$01,$01,$01,$01,$01,$01 ; D505 01 01 01 01 01 01 01 01  ........
        .byte   $01,$01,$01,$01,$01,$01,$01,$02 ; D50D 01 01 01 01 01 01 01 02  ........
        .byte   $FF,$EF,$D4,$A3,$A3,$A3,$A3,$A3 ; D515 FF EF D4 A3 A3 A3 A3 A3  ........
        .byte   $A3,$A3,$A3,$A3,$A3,$A1,$01,$01 ; D51D A3 A3 A3 A3 A3 A1 01 01  ........
        .byte   $A1,$01,$01,$A3,$A3,$A3,$A3,$A3 ; D525 A1 01 01 A3 A3 A3 A3 A3  ........
        .byte   $A3,$A3,$A3,$A3,$A3,$A1,$01,$01 ; D52D A3 A3 A3 A3 A3 A1 01 01  ........
        .byte   $A1,$01,$01,$A6,$06,$06,$06,$06 ; D535 A1 01 01 A6 06 06 06 06  ........
        .byte   $06,$A6,$06,$A6,$06,$A6,$01,$02 ; D53D 06 A6 06 A6 06 A6 01 02  ........
        .byte   $01,$01,$01,$AC,$0C,$0C,$AC,$AC ; D545 01 01 01 AC 0C 0C AC AC  ........
        .byte   $AC,$AC,$0C,$02,$02,$02,$02,$01 ; D54D AC AC 0C 02 02 02 02 01  ........
        .byte   $01,$01,$01,$AC,$AC,$AC,$AC,$06 ; D555 01 01 01 AC AC AC AC 06  ........
        .byte   $AC,$06,$AC,$06,$AC,$01,$01,$01 ; D55D AC 06 AC 06 AC 01 01 01  ........
        .byte   $01,$01,$01,$AC,$AC,$AC,$AC,$0C ; D565 01 01 01 AC AC AC AC 0C  ........
        .byte   $0C,$AC,$AC,$A5,$01,$01,$01,$01 ; D56D 0C AC AC A5 01 01 01 01  ........
        .byte   $01,$01,$01,$AC,$06,$AC,$06,$AC ; D575 01 01 01 AC 06 AC 06 AC  ........
        .byte   $06,$AC,$06,$AC,$0C,$06,$02,$01 ; D57D 06 AC 06 AC 0C 06 02 01  ........
        .byte   $01,$01,$01,$AC,$AC,$AC,$AC,$0C ; D585 01 01 01 AC AC AC AC 0C  ........
        .byte   $0C,$AC,$AC,$A5,$01,$01,$01,$01 ; D58D 0C AC AC A5 01 01 01 01  ........
        .byte   $01,$01,$01,$AC,$0C,$0C,$AC,$AC ; D595 01 01 01 AC 0C 0C AC AC  ........
        .byte   $AC,$AC,$06,$AB,$01,$01,$01,$01 ; D59D AC AC 06 AB 01 01 01 01  ........
        .byte   $01,$01,$01,$AC,$06,$AC,$06,$AC ; D5A5 01 01 01 AC 06 AC 06 AC  ........
        .byte   $0C,$0C,$AC,$AC,$A6,$01,$01,$01 ; D5AD 0C 0C AC AC A6 01 01 01  ........
        .byte   $01,$01,$01,$AC,$0C,$0C,$AC,$AC ; D5B5 01 01 01 AC 0C 0C AC AC  ........
        .byte   $AC,$AC,$0C,$05,$01,$01,$01,$01 ; D5BD AC AC 0C 05 01 01 01 01  ........
        .byte   $01,$01,$01,$AC,$AC,$AC,$AC,$06 ; D5C5 01 01 01 AC AC AC AC 06  ........
        .byte   $AC,$06,$AC,$06,$AC,$01,$01,$01 ; D5CD AC 06 AC 06 AC 01 01 01  ........
        .byte   $01,$01,$01,$AC,$06,$AC,$06,$AC ; D5D5 01 01 01 AC 06 AC 06 AC  ........
        .byte   $0C,$0C,$0C,$0C,$06,$01,$01,$01 ; D5DD 0C 0C 0C 0C 06 01 01 01  ........
        .byte   $01,$01,$01,$08,$08,$08,$08,$08 ; D5E5 01 01 01 08 08 08 08 08  ........
        .byte   $08,$08,$08,$08,$06,$05,$05,$05 ; D5ED 08 08 08 08 06 05 05 05  ........
        .byte   $05,$05,$05,$A6,$A6,$A6,$A6,$A6 ; D5F5 05 05 05 A6 A6 A6 A6 A6  ........
        .byte   $A6,$A6,$A3,$02,$01,$A1,$01,$01 ; D5FD A6 A6 A3 02 01 A1 01 01  ........
        .byte   $01,$01,$01,$F9,$08,$F8,$03,$93 ; D605 01 01 01 F9 08 F8 03 93  ........
        .byte   $21,$F7,$1E,$00,$21,$00,$20,$00 ; D60D 21 F7 1E 00 21 00 20 00  !...!. .
        .byte   $21,$00,$20,$F7,$1E,$00,$21,$00 ; D615 21 00 20 F7 1E 00 21 00  !. ...!.
        .byte   $20,$00,$21,$00,$20,$F7,$1E,$00 ; D61D 20 00 21 00 20 F7 1E 00   .!. ...
        .byte   $21,$00,$20,$00,$21,$00,$20,$00 ; D625 21 00 20 00 21 00 20 00  !. .!. .
        .byte   $21,$00,$21,$00,$21,$00,$1B,$00 ; D62D 21 00 21 00 21 00 1B 00  !.!.!...
        .byte   $21,$00,$21,$F7,$1E,$00,$21,$00 ; D635 21 00 21 F7 1E 00 21 00  !.!...!.
        .byte   $20,$00,$21,$00,$20,$F7,$1E,$00 ; D63D 20 00 21 00 20 F7 1E 00   .!. ...
        .byte   $21,$00,$20,$00,$21,$00,$20,$F7 ; D645 21 00 20 00 21 00 20 F7  !. .!. .
        .byte   $1E,$00,$21,$00,$20,$00,$21,$00 ; D64D 1E 00 21 00 20 00 21 00  ..!. .!.
        .byte   $20,$00,$21,$00,$21,$00,$21,$00 ; D655 20 00 21 00 21 00 21 00   .!.!.!.
        .byte   $1B,$00,$21,$00,$21,$F7,$1E,$00 ; D65D 1B 00 21 00 21 F7 1E 00  ..!.!...
        .byte   $21,$00,$20,$00,$21,$00,$20,$F7 ; D665 21 00 20 00 21 00 20 F7  !. .!. .
        .byte   $1E,$00,$21,$00,$20,$00,$21,$00 ; D66D 1E 00 21 00 20 00 21 00  ..!. .!.
        .byte   $20,$F7,$1E,$00,$21,$00,$20,$00 ; D675 20 F7 1E 00 21 00 20 00   ...!. .
        .byte   $21,$00,$20,$00,$21,$00,$21,$00 ; D67D 21 00 20 00 21 00 21 00  !. .!.!.
        .byte   $21,$00,$1B,$00,$21,$00,$21,$F7 ; D685 21 00 1B 00 21 00 21 F7  !...!.!.
        .byte   $1E,$00,$21,$00,$20,$00,$21,$00 ; D68D 1E 00 21 00 20 00 21 00  ..!. .!.
        .byte   $20,$F7,$1E,$00,$21,$00,$20,$00 ; D695 20 F7 1E 00 21 00 20 00   ...!. .
        .byte   $21,$F8,$05,$00,$F7,$24,$31,$9B ; D69D 21 F8 05 00 F7 24 31 9B  !....$1.
        .byte   $31,$99,$33,$96,$00,$99,$34,$96 ; D6A5 31 99 33 96 00 99 34 96  1.3...4.
        .byte   $00,$99,$38,$96,$00,$36,$93,$00 ; D6AD 00 99 38 96 00 36 93 00  ..8..6..
        .byte   $96,$34,$93,$00,$96,$32,$93,$00 ; D6B5 96 34 93 00 96 32 93 00  .4...2..
        .byte   $96,$31,$93,$00,$96,$32,$93,$00 ; D6BD 96 31 93 00 96 32 93 00  .1...2..
        .byte   $96,$34,$93,$00,$9C,$35,$99,$00 ; D6C5 96 34 93 00 9C 35 99 00  .4...5..
        .byte   $34,$96,$00,$99,$30,$96,$00,$99 ; D6CD 34 96 00 99 30 96 00 99  4...0...
        .byte   $33,$96,$00,$98,$32,$30,$96,$2A ; D6D5 33 96 00 98 32 30 96 2A  3...20.*
        .byte   $33,$35,$33,$35,$40,$F7,$6C,$3B ; D6DD 33 35 33 35 40 F7 6C 3B  3535@.l;
        .byte   $9B,$3B,$F7,$48,$2B,$9E,$2B,$F7 ; D6E5 9B 3B F7 48 2B 9E 2B F7  .;.H+.+.
        .byte   $24,$2A,$F7,$6C,$2A,$F7,$6C,$28 ; D6ED 24 2A F7 6C 2A F7 6C 28  $*.l*.l(
        .byte   $9B,$28,$F7,$48,$31,$F7,$6C,$31 ; D6F5 9B 28 F7 48 31 F7 6C 31  .(.H1.l1
        .byte   $F8,$03,$FE,$08,$D6,$F9,$08,$F8 ; D6FD F8 03 FE 08 D6 F9 08 F8  ........
        .byte   $03,$93,$13,$F7,$1E,$00,$13,$00 ; D705 03 93 13 F7 1E 00 13 00  ........
        .byte   $13,$00,$13,$00,$13,$F7,$1E,$00 ; D70D 13 00 13 00 13 F7 1E 00  ........
        .byte   $13,$00,$13,$00,$13,$00,$14,$F7 ; D715 13 00 13 00 13 00 14 F7  ........
        .byte   $1E,$00,$14,$00,$14,$00,$14,$00 ; D71D 1E 00 14 00 14 00 14 00  ........
        .byte   $14,$96,$00,$93,$14,$96,$00,$93 ; D725 14 96 00 93 14 96 00 93  ........
        .byte   $14,$96,$00,$93,$14,$96,$00,$93 ; D72D 14 96 00 93 14 96 00 93  ........
        .byte   $13,$F7,$1E,$00,$13,$00,$13,$00 ; D735 13 F7 1E 00 13 00 13 00  ........
        .byte   $13,$00,$13,$F7,$1E,$00,$13,$00 ; D73D 13 00 13 F7 1E 00 13 00  ........
        .byte   $13,$00,$13,$00,$14,$F7,$1E,$00 ; D745 13 00 13 00 14 F7 1E 00  ........
        .byte   $14,$00,$14,$00,$14,$00,$14,$96 ; D74D 14 00 14 00 14 00 14 96  ........
        .byte   $00,$93,$14,$96,$00,$93,$14,$96 ; D755 00 93 14 96 00 93 14 96  ........
        .byte   $00,$93,$14,$96,$00,$93,$13,$F7 ; D75D 00 93 14 96 00 93 13 F7  ........
        .byte   $1E,$00,$13,$00,$13,$00,$13,$00 ; D765 1E 00 13 00 13 00 13 00  ........
        .byte   $13,$F7,$1E,$00,$13,$00,$13,$00 ; D76D 13 F7 1E 00 13 00 13 00  ........
        .byte   $13,$00,$14,$F7,$1E,$00,$14,$00 ; D775 13 00 14 F7 1E 00 14 00  ........
        .byte   $14,$00,$14,$00,$14,$96,$00,$93 ; D77D 14 00 14 00 14 96 00 93  ........
        .byte   $14,$96,$00,$93,$14,$96,$00,$93 ; D785 14 96 00 93 14 96 00 93  ........
        .byte   $14,$96,$00,$93,$13,$F7,$1E,$00 ; D78D 14 96 00 93 13 F7 1E 00  ........
        .byte   $13,$00,$13,$00,$13,$00,$13,$F7 ; D795 13 00 13 00 13 00 13 F7  ........
        .byte   $1E,$00,$13,$00,$13,$00,$13,$00 ; D79D 1E 00 13 00 13 00 13 00  ........
        .byte   $14,$F7,$1E,$00,$14,$00,$14,$00 ; D7A5 14 F7 1E 00 14 00 14 00  ........
        .byte   $14,$00,$14,$96,$00,$93,$14,$96 ; D7AD 14 00 14 96 00 93 14 96  ........
        .byte   $00,$93,$14,$96,$00,$93,$14,$96 ; D7B5 00 93 14 96 00 93 14 96  ........
        .byte   $00,$93,$12,$F7,$1E,$00,$12,$00 ; D7BD 00 93 12 F7 1E 00 12 00  ........
        .byte   $12,$00,$12,$00,$12,$F7,$1E,$00 ; D7C5 12 00 12 00 12 F7 1E 00  ........
        .byte   $12,$00,$12,$00,$12,$00,$20,$F7 ; D7CD 12 00 12 00 12 00 20 F7  ...... .
        .byte   $1E,$00,$20,$00,$20,$00,$20,$00 ; D7D5 1E 00 20 00 20 00 20 00  .. . . .
        .byte   $20,$96,$00,$93,$20,$96,$00,$93 ; D7DD 20 96 00 93 20 96 00 93   ... ...
        .byte   $20,$96,$00,$93,$20,$96,$00,$93 ; D7E5 20 96 00 93 20 96 00 93   ... ...
        .byte   $1A,$F7,$1E,$00,$1A,$00,$1A,$00 ; D7ED 1A F7 1E 00 1A 00 1A 00  ........
        .byte   $1A,$00,$1A,$F7,$1E,$00,$1A,$00 ; D7F5 1A 00 1A F7 1E 00 1A 00  ........
        .byte   $1A,$00,$1A,$00,$19,$F7,$1E,$00 ; D7FD 1A 00 1A 00 19 F7 1E 00  ........
        .byte   $19,$00,$19,$00,$19,$00,$19,$96 ; D805 19 00 19 00 19 00 19 96  ........
        .byte   $00,$93,$19,$96,$00,$93,$19,$96 ; D80D 00 93 19 96 00 93 19 96  ........
        .byte   $00,$93,$19,$96,$00,$F7,$48,$22 ; D815 00 93 19 96 00 F7 48 22  ......H"
        .byte   $9E,$22,$F7,$24,$20,$9B,$20,$9E ; D81D 9E 22 F7 24 20 9B 20 9E  .".$ . .
        .byte   $17,$F7,$6C,$1A,$9B,$1A,$F7,$48 ; D825 17 F7 6C 1A 9B 1A F7 48  ..l....H
        .byte   $19,$F7,$6C,$19,$FE,$02,$D7,$F7 ; D82D 19 F7 6C 19 FE 02 D7 F7  ..l.....
        .byte   $3C,$28,$96,$23,$9E,$30,$9B,$2B ; D835 3C 28 96 23 9E 30 9B 2B  <(.#.0.+
        .byte   $28,$98,$24,$26,$24,$26,$F7,$3C ; D83D 28 98 24 26 24 26 F7 3C  (.$&$&.<
        .byte   $28,$96,$23,$9B,$30,$30,$24,$26 ; D845 28 96 23 9B 30 30 24 26  (.#.00$&
        .byte   $98,$28,$2A,$2B,$31,$F7,$24,$28 ; D84D 98 28 2A 2B 31 F7 24 28  .(*+1.$(
        .byte   $99,$28,$96,$23,$9E,$30,$9B,$2B ; D855 99 28 96 23 9E 30 9B 2B  .(.#.0.+
        .byte   $28,$98,$24,$26,$24,$26,$F7,$3C ; D85D 28 98 24 26 24 26 F7 3C  (.$&$&.<
        .byte   $28,$96,$23,$9E,$30,$9B,$24,$26 ; D865 28 96 23 9E 30 9B 24 26  (.#.0.$&
        .byte   $98,$28,$2A,$2B,$31,$93,$2B,$F7 ; D86D 98 28 2A 2B 31 93 2B F7  .(*+1.+.
        .byte   $1E,$00,$2B,$00,$2B,$00,$24,$00 ; D875 1E 00 2B 00 2B 00 24 00  ..+.+.$.
        .byte   $2B,$F7,$1E,$00,$24,$00,$24,$00 ; D87D 2B F7 1E 00 24 00 24 00  +...$.$.
        .byte   $24,$00,$2A,$F7,$1E,$00,$2A,$00 ; D885 24 00 2A F7 1E 00 2A 00  $.*...*.
        .byte   $25,$00,$25,$00,$2A,$96,$00,$93 ; D88D 25 00 25 00 2A 96 00 93  %.%.*...
        .byte   $2A,$96,$00,$93,$2A,$96,$00,$93 ; D895 2A 96 00 93 2A 96 00 93  *...*...
        .byte   $2A,$96,$00,$93,$28,$F7,$1E,$00 ; D89D 2A 96 00 93 28 F7 1E 00  *...(...
        .byte   $23,$00,$23,$00,$23,$00,$28,$F7 ; D8A5 23 00 23 00 23 00 28 F7  #.#.#.(.
        .byte   $1E,$00,$23,$00,$23,$00,$23,$00 ; D8AD 1E 00 23 00 23 00 23 00  ..#.#.#.
        .byte   $26,$F7,$1E,$00,$31,$00,$26,$00 ; D8B5 26 F7 1E 00 31 00 26 00  &...1.&.
        .byte   $31,$00,$31,$96,$00,$93,$31,$96 ; D8BD 31 00 31 96 00 93 31 96  1.1...1.
        .byte   $00,$93,$31,$96,$00,$93,$31,$96 ; D8C5 00 93 31 96 00 93 31 96  ..1...1.
        .byte   $00,$9B,$38,$98,$36,$34,$32,$31 ; D8CD 00 9B 38 98 36 34 32 31  ..8.6421
        .byte   $32,$34,$F7,$24,$35,$9B,$35,$34 ; D8D5 32 34 F7 24 35 9B 35 34  24.$5.54
        .byte   $30,$33,$98,$32,$30,$96,$2A,$33 ; D8DD 30 33 98 32 30 96 2A 33  03.20.*3
        .byte   $35,$33,$35,$40,$F7,$48,$3B,$F7 ; D8E5 35 33 35 40 F7 48 3B F7  535@.H;.
        .byte   $6C,$3B,$FE,$34,$D8,$FF,$F2,$D8 ; D8ED 6C 3B FE 34 D8 FF F2 D8  l;.4....
        .byte   $03,$04,$05,$04,$06,$07,$08,$09 ; D8F5 03 04 05 04 06 07 08 09  ........
        .byte   $0A,$0B,$0C,$04,$06,$07,$08,$09 ; D8FD 0A 0B 0C 04 06 07 08 09  ........
        .byte   $0D,$0E,$0E,$0E,$0F,$0F,$0F,$0F ; D905 0D 0E 0E 0E 0F 0F 0F 0F  ........
        .byte   $FF,$F5,$D8,$B6,$06,$A6,$06,$B6 ; D90D FF F5 D8 B6 06 A6 06 B6  ........
        .byte   $06,$A6,$06,$B6,$06,$A6,$A6,$B6 ; D915 06 A6 06 B6 06 A6 A6 B6  ........
        .byte   $06,$A6,$06,$B6,$06,$06,$06,$B6 ; D91D 06 A6 06 B6 06 06 06 B6  ........
        .byte   $06,$06,$06,$B6,$06,$06,$06,$06 ; D925 06 06 06 B6 06 06 06 06  ........
        .byte   $06,$06,$06,$B6,$06,$06,$06,$A6 ; D92D 06 06 06 B6 06 06 06 A6  ........
        .byte   $06,$06,$06,$B6,$06,$06,$06,$A6 ; D935 06 06 06 B6 06 06 06 A6  ........
        .byte   $06,$06,$06,$B6,$06,$A6,$06,$B6 ; D93D 06 06 06 B6 06 A6 06 B6  ........
        .byte   $06,$A6,$06,$B6,$06,$06,$06,$B6 ; D945 06 A6 06 B6 06 06 06 B6  ........
        .byte   $06,$06,$06,$F9,$08,$F8,$03,$9B ; D94D 06 06 06 F9 08 F8 03 9B  ........
        .byte   $20,$93,$22,$00,$9B,$24,$93,$20 ; D955 20 93 22 00 9B 24 93 20   ."..$. 
        .byte   $00,$99,$24,$93,$22,$00,$20,$00 ; D95D 00 99 24 93 22 00 20 00  ..$.". .
        .byte   $99,$22,$17,$9B,$22,$93,$24,$00 ; D965 99 22 17 9B 22 93 24 00  ."..".$.
        .byte   $9B,$25,$93,$22,$00,$99,$25,$93 ; D96D 9B 25 93 22 00 99 25 93  .%."..%.
        .byte   $24,$00,$22,$00,$9C,$20,$99,$27 ; D975 24 00 22 00 9C 20 99 27  $.".. .'
        .byte   $30,$2B,$93,$30,$00,$2B,$00,$99 ; D97D 30 2B 93 30 00 2B 00 99  0+.0.+..
        .byte   $29,$93,$27,$00,$25,$00,$99,$10 ; D985 29 93 27 00 25 00 99 10  ).'.%...
        .byte   $20,$93,$20,$00,$99,$29,$93,$25 ; D98D 20 93 20 00 99 29 93 25   . ..).%
        .byte   $00,$9B,$27,$93,$24,$00,$22,$00 ; D995 00 9B 27 93 24 00 22 00  ..'.$.".
        .byte   $17,$00,$25,$00,$22,$00,$96,$20 ; D99D 17 00 25 00 22 00 96 20  ..%.".. 
        .byte   $9B,$00,$99,$2B,$2B,$93,$2B,$00 ; D9A5 9B 00 99 2B 2B 93 2B 00  ...++.+.
        .byte   $30,$00,$2B,$00,$29,$00,$9C,$27 ; D9AD 30 00 2B 00 29 00 9C 27  0.+.)..'
        .byte   $96,$00,$93,$24,$00,$25,$00,$27 ; D9B5 96 00 93 24 00 25 00 27  ...$.%.'
        .byte   $00,$99,$29,$29,$93,$29,$00,$27 ; D9BD 00 99 29 29 93 29 00 27  ..)).).'
        .byte   $00,$25,$00,$24,$00,$F7,$3C,$20 ; D9C5 00 25 00 24 00 F7 3C 20  .%.$..< 
        .byte   $25,$00,$27,$00,$29,$00,$99,$2B ; D9CD 25 00 27 00 29 00 99 2B  %.'.)..+
        .byte   $2B,$93,$2B,$00,$30,$00,$32,$00 ; D9D5 2B 93 2B 00 30 00 32 00  +.+.0.2.
        .byte   $34,$00,$F7,$3C,$30,$30,$00,$32 ; D9DD 34 00 F7 3C 30 30 00 32  4..<00.2
        .byte   $00,$34,$00,$99,$35,$35,$93,$35 ; D9E5 00 34 00 99 35 35 93 35  .4..55.5
        .byte   $00,$39,$00,$37,$00,$35,$00,$9C ; D9ED 00 39 00 37 00 35 00 9C  .9.7.5..
        .byte   $37,$96,$3B,$00,$42,$00,$99,$27 ; D9F5 37 96 3B 00 42 00 99 27  7.;.B..'
        .byte   $30,$2B,$93,$30,$00,$2B,$00,$99 ; D9FD 30 2B 93 30 00 2B 00 99  0+.0.+..
        .byte   $29,$93,$27,$00,$25,$00,$99,$27 ; DA05 29 93 27 00 25 00 99 27  ).'.%..'
        .byte   $20,$93,$20,$00,$99,$29,$93,$25 ; DA0D 20 93 20 00 99 29 93 25   . ..).%
        .byte   $00,$9B,$27,$93,$24,$00,$22,$00 ; DA15 00 9B 27 93 24 00 22 00  ..'.$.".
        .byte   $17,$00,$24,$00,$22,$00,$9C,$20 ; DA1D 17 00 24 00 22 00 9C 20  ..$.".. 
        .byte   $FE,$50,$D9,$F9,$08,$F8,$03,$93 ; DA25 FE 50 D9 F9 08 F8 03 93  .P......
        .byte   $20,$00,$27,$00,$17,$00,$30,$00 ; DA2D 20 00 27 00 17 00 30 00   .'...0.
        .byte   $20,$00,$27,$00,$17,$00,$30,$00 ; DA35 20 00 27 00 17 00 30 00   .'...0.
        .byte   $96,$20,$93,$27,$00,$96,$17,$93 ; DA3D 96 20 93 27 00 96 17 93  . .'....
        .byte   $34,$00,$22,$00,$2B,$00,$17,$00 ; DA45 34 00 22 00 2B 00 17 00  4.".+...
        .byte   $32,$00,$22,$00,$2B,$00,$96,$27 ; DA4D 32 00 22 00 2B 00 96 27  2.".+..'
        .byte   $93,$32,$00,$22,$00,$2B,$00,$96 ; DA55 93 32 00 22 00 2B 00 96  .2.".+..
        .byte   $17,$93,$32,$00,$22,$00,$2B,$00 ; DA5D 17 93 32 00 22 00 2B 00  ..2.".+.
        .byte   $17,$00,$32,$00,$20,$00,$30,$00 ; DA65 17 00 32 00 20 00 30 00  ..2. .0.
        .byte   $96,$17,$93,$27,$00,$20,$00,$30 ; DA6D 96 17 93 27 00 20 00 30  ...'. .0
        .byte   $00,$96,$17,$93,$27,$00,$20,$00 ; DA75 00 96 17 93 27 00 20 00  ....'. .
        .byte   $2B,$00,$96,$17,$93,$27,$00,$96 ; DA7D 2B 00 96 17 93 27 00 96  +....'..
        .byte   $19,$93,$30,$00,$96,$14,$93,$29 ; DA85 19 93 30 00 96 14 93 29  ..0....)
        .byte   $00,$20,$00,$30,$00,$96,$17,$93 ; DA8D 00 20 00 30 00 96 17 93  . .0....
        .byte   $27,$00,$96,$19,$93,$20,$00,$96 ; DA95 27 00 96 19 93 20 00 96  '.... ..
        .byte   $14,$93,$29,$00,$20,$00,$30,$00 ; DA9D 14 93 29 00 20 00 30 00  ..). .0.
        .byte   $96,$17,$93,$27,$00,$99,$2B,$93 ; DAA5 96 17 93 27 00 99 2B 93  ...'..+.
        .byte   $27,$00,$25,$00,$99,$24,$20,$93 ; DAAD 27 00 25 00 99 24 20 93  '.%..$ .
        .byte   $17,$98,$00,$99,$22,$17,$00,$24 ; DAB5 17 98 00 99 22 17 00 24  ...."..$
        .byte   $27,$20,$30,$25,$20,$25,$00,$20 ; DABD 27 20 30 25 20 25 00 20  ' 0% %. 
        .byte   $27,$19,$17,$93,$17,$00,$27,$00 ; DAC5 27 19 17 93 17 00 27 00  '.....'.
        .byte   $1B,$00,$2B,$00,$22,$00,$27,$00 ; DACD 1B 00 2B 00 22 00 27 00  ..+.".'.
        .byte   $17,$00,$2B,$00,$24,$00,$30,$00 ; DAD5 17 00 2B 00 24 00 30 00  ..+.$.0.
        .byte   $20,$00,$27,$00,$17,$00,$30,$00 ; DADD 20 00 27 00 17 00 30 00   .'...0.
        .byte   $14,$00,$27,$00,$19,$00,$29,$00 ; DAE5 14 00 27 00 19 00 29 00  ..'...).
        .byte   $20,$00,$30,$00,$24,$00,$29,$00 ; DAED 20 00 30 00 24 00 29 00   .0.$.).
        .byte   $25,$00,$30,$00,$27,$00,$32,$00 ; DAF5 25 00 30 00 27 00 32 00  %.0.'.2.
        .byte   $22,$00,$2B,$00,$96,$1B,$00,$27 ; DAFD 22 00 2B 00 96 1B 00 27  ".+....'
        .byte   $00,$93,$20,$00,$30,$00,$96,$17 ; DB05 00 93 20 00 30 00 96 17  .. .0...
        .byte   $93,$27,$00,$20,$00,$2B,$00,$96 ; DB0D 93 27 00 20 00 2B 00 96  .'. .+..
        .byte   $17,$93,$27,$00,$96,$19,$93,$29 ; DB15 17 93 27 00 96 19 93 29  ..'....)
        .byte   $00,$96,$14,$93,$30,$00,$20,$00 ; DB1D 00 96 14 93 30 00 20 00  ....0. .
        .byte   $27,$00,$96,$17,$93,$30,$00,$96 ; DB25 27 00 96 17 93 30 00 96  '....0..
        .byte   $19,$93,$29,$00,$96,$14,$93,$30 ; DB2D 19 93 29 00 96 14 93 30  ..)....0
        .byte   $00,$20,$00,$27,$00,$96,$17,$93 ; DB35 00 20 00 27 00 96 17 93  . .'....
        .byte   $30,$00,$99,$2B,$93,$27,$00,$25 ; DB3D 30 00 99 2B 93 27 00 25  0..+.'.%
        .byte   $00,$24,$98,$00,$93,$20,$98,$00 ; DB45 00 24 98 00 93 20 98 00  .$... ..
        .byte   $FE,$28,$DA,$9B,$34,$93,$35,$00 ; DB4D FE 28 DA 9B 34 93 35 00  .(..4.5.
        .byte   $9B,$37,$93,$34,$00,$99,$37,$93 ; DB55 9B 37 93 34 00 99 37 93  .7.4..7.
        .byte   $35,$00,$34,$00,$99,$35,$2B,$9B ; DB5D 35 00 34 00 99 35 2B 9B  5.4..5+.
        .byte   $35,$93,$37,$00,$9B,$39,$93,$35 ; DB65 35 93 37 00 9B 39 93 35  5.7..9.5
        .byte   $00,$99,$39,$93,$37,$00,$35,$00 ; DB6D 00 99 39 93 37 00 35 00  ..9.7.5.
        .byte   $9C,$34,$99,$40,$44,$42,$93,$44 ; DB75 9C 34 99 40 44 42 93 44  .4.@DB.D
        .byte   $00,$42,$00,$99,$40,$93,$44,$00 ; DB7D 00 42 00 99 40 93 44 00  .B..@.D.
        .byte   $42,$00,$99,$44,$F7,$18,$37,$93 ; DB85 42 00 99 44 F7 18 37 93  B..D..7.
        .byte   $37,$00,$99,$45,$93,$42,$00,$9B ; DB8D 37 00 99 45 93 42 00 9B  7..E.B..
        .byte   $44,$93,$47,$00,$45,$00,$3B,$00 ; DB95 44 93 47 00 45 00 3B 00  D.G.E.;.
        .byte   $47,$00,$45,$00,$96,$44,$9B,$00 ; DB9D 47 00 45 00 96 44 9B 00  G.E..D..
        .byte   $9F,$34,$96,$37,$00,$37,$00,$93 ; DBA5 9F 34 96 37 00 37 00 93  .4.7.7..
        .byte   $37,$00,$34,$00,$32,$00,$30,$00 ; DBAD 37 00 34 00 32 00 30 00  7.4.2.0.
        .byte   $9F,$34,$96,$30,$00,$99,$30,$93 ; DBB5 9F 34 96 30 00 99 30 93  .4.0..0.
        .byte   $30,$00,$2B,$00,$29,$00,$27,$00 ; DBBD 30 00 2B 00 29 00 27 00  0.+.).'.
        .byte   $99,$1B,$1B,$93,$1B,$00,$20,$00 ; DBC5 99 1B 1B 93 1B 00 20 00  ...... .
        .byte   $22,$00,$96,$24,$F7,$3C,$20,$93 ; DBCD 22 00 96 24 F7 3C 20 93  "..$.< .
        .byte   $20,$00,$22,$00,$24,$00,$99,$25 ; DBD5 20 00 22 00 24 00 99 25   .".$..%
        .byte   $25,$93,$25,$00,$29,$00,$27,$00 ; DBDD 25 93 25 00 29 00 27 00  %.%.).'.
        .byte   $25,$00,$9C,$27,$96,$2B,$00,$37 ; DBE5 25 00 9C 27 96 2B 00 37  %..'.+.7
        .byte   $00,$93,$57,$00,$55,$00,$54,$00 ; DBED 00 93 57 00 55 00 54 00  ..W.U.T.
        .byte   $52,$00,$50,$00,$4B,$00,$49,$00 ; DBF5 52 00 50 00 4B 00 49 00  R.P.K.I.
        .byte   $47,$00,$57,$00,$55,$00,$54,$00 ; DBFD 47 00 57 00 55 00 54 00  G.W.U.T.
        .byte   $52,$00,$54,$00,$55,$00,$57,$00 ; DC05 52 00 54 00 55 00 57 00  R.T.U.W.
        .byte   $59,$00,$5B,$00,$59,$00,$57,$00 ; DC0D 59 00 5B 00 59 00 57 00  Y.[.Y.W.
        .byte   $55,$00,$54,$00,$52,$00,$50,$00 ; DC15 55 00 54 00 52 00 50 00  U.T.R.P.
        .byte   $4B,$00,$57,$57,$59,$00,$5A,$00 ; DC1D 4B 00 57 57 59 00 5A 00  K.WWY.Z.
        .byte   $5B,$00,$60,$98,$00,$93,$30,$98 ; DC25 5B 00 60 98 00 93 30 98  [.`...0.
        .byte   $00,$FE,$50,$DB,$FF,$31,$DC,$01 ; DC2D 00 FE 50 DB FF 31 DC 01  ..P..1..
        .byte   $01,$01,$01,$01,$01,$01,$01,$02 ; DC35 01 01 01 01 01 01 01 02  ........
        .byte   $03,$02,$03,$01,$01,$01,$01,$01 ; DC3D 03 02 03 01 01 01 01 01  ........
        .byte   $01,$01,$04,$FF,$34,$DC,$B6,$06 ; DC45 01 01 04 FF 34 DC B6 06  ....4...
        .byte   $A6,$06,$B6,$06,$A6,$06,$B6,$06 ; DC4D A6 06 B6 06 A6 06 B6 06  ........
        .byte   $A6,$A6,$B6,$06,$A6,$06,$B6,$06 ; DC55 A6 A6 B6 06 A6 06 B6 06  ........
        .byte   $06,$06,$B6,$06,$06,$06,$B6,$06 ; DC5D 06 06 B6 06 06 06 B6 06  ........
        .byte   $06,$06,$06,$06,$06,$06,$B6,$06 ; DC65 06 06 06 06 06 06 B6 06  ........
        .byte   $06,$06,$A6,$06,$06,$06,$B6,$06 ; DC6D 06 06 A6 06 06 06 B6 06  ........
        .byte   $06,$06,$A6,$06,$06,$06,$B6,$06 ; DC75 06 06 A6 06 06 06 B6 06  ........
        .byte   $A6,$06,$B6,$06,$A6,$06,$B6,$06 ; DC7D A6 06 B6 06 A6 06 B6 06  ........
        .byte   $06,$06,$B6,$06,$06,$06,$F9,$08 ; DC85 06 06 B6 06 06 06 F9 08  ........
        .byte   $F8,$01,$9B,$20,$93,$22,$00,$9B ; DC8D F8 01 9B 20 93 22 00 9B  ... ."..
        .byte   $23,$93,$20,$00,$99,$23,$93,$22 ; DC95 23 93 20 00 99 23 93 22  #. ..#."
        .byte   $00,$20,$00,$99,$22,$17,$9B,$22 ; DC9D 00 20 00 99 22 17 9B 22  . ..".."
        .byte   $93,$23,$00,$9B,$25,$93,$22,$00 ; DCA5 93 23 00 9B 25 93 22 00  .#..%.".
        .byte   $99,$25,$93,$23,$00,$22,$00,$9C ; DCAD 99 25 93 23 00 22 00 9C  .%.#."..
        .byte   $20,$99,$27,$30,$2A,$93,$30,$00 ; DCB5 20 99 27 30 2A 93 30 00   .'0*.0.
        .byte   $2A,$00,$99,$28,$93,$27,$00,$25 ; DCBD 2A 00 99 28 93 27 00 25  *..(.'.%
        .byte   $00,$99,$27,$20,$93,$20,$00,$99 ; DCC5 00 99 27 20 93 20 00 99  ..' . ..
        .byte   $28,$93,$25,$00,$9B,$27,$93,$23 ; DCCD 28 93 25 00 9B 27 93 23  (.%..'.#
        .byte   $00,$22,$00,$17,$00,$23,$00,$22 ; DCD5 00 22 00 17 00 23 00 22  ."...#."
        .byte   $00,$20,$F7,$2A,$00,$99,$2A,$96 ; DCDD 00 20 F7 2A 00 99 2A 96  . .*..*.
        .byte   $2A,$00,$93,$2A,$00,$30,$00,$2A ; DCE5 2A 00 93 2A 00 30 00 2A  *..*.0.*
        .byte   $00,$28,$00,$9C,$27,$96,$00,$93 ; DCED 00 28 00 9C 27 96 00 93  .(..'...
        .byte   $23,$00,$25,$00,$27,$00,$99,$28 ; DCF5 23 00 25 00 27 00 99 28  #.%.'..(
        .byte   $28,$93,$28,$00,$27,$00,$25,$00 ; DCFD 28 93 28 00 27 00 25 00  (.(.'.%.
        .byte   $23,$00,$F7,$3C,$20,$25,$00,$27 ; DD05 23 00 F7 3C 20 25 00 27  #..< %.'
        .byte   $00,$29,$00,$99,$2B,$2B,$93,$2B ; DD0D 00 29 00 99 2B 2B 93 2B  .)..++.+
        .byte   $00,$30,$00,$32,$00,$35,$00,$F7 ; DD15 00 30 00 32 00 35 00 F7  .0.2.5..
        .byte   $3C,$33,$30,$00,$32,$00,$33,$00 ; DD1D 3C 33 30 00 32 00 33 00  <30.2.3.
        .byte   $99,$35,$35,$93,$35,$00,$38,$00 ; DD25 99 35 35 93 35 00 38 00  .55.5.8.
        .byte   $37,$00,$35,$00,$9C,$37,$96,$3B ; DD2D 37 00 35 00 9C 37 96 3B  7.5..7.;
        .byte   $00,$42,$00,$99,$27,$40,$2A,$93 ; DD35 00 42 00 99 27 40 2A 93  .B..'@*.
        .byte   $30,$00,$2A,$00,$99,$28,$93,$27 ; DD3D 30 00 2A 00 99 28 93 27  0.*..(.'
        .byte   $00,$25,$00,$99,$27,$20,$93,$20 ; DD45 00 25 00 99 27 20 93 20  .%..' . 
        .byte   $00,$99,$28,$93,$25,$00,$9B,$27 ; DD4D 00 99 28 93 25 00 9B 27  ..(.%..'
        .byte   $93,$23,$00,$22,$00,$17,$00,$23 ; DD55 93 23 00 22 00 17 00 23  .#."...#
        .byte   $00,$22,$00,$20,$F7,$2A,$00,$FE ; DD5D 00 22 00 20 F7 2A 00 FE  .". .*..
        .byte   $8B,$DC,$F9,$08,$F8,$01,$93,$23 ; DD65 8B DC F9 08 F8 01 93 23  .......#
        .byte   $00,$27,$00,$17,$00,$23,$00,$20 ; DD6D 00 27 00 17 00 23 00 20  .'...#. 
        .byte   $00,$30,$00,$17,$00,$27,$00,$20 ; DD75 00 30 00 17 00 27 00 20  .0...'. 
        .byte   $00,$23,$00,$96,$30,$93,$20,$00 ; DD7D 00 23 00 96 30 93 20 00  .#..0. .
        .byte   $22,$00,$2B,$00,$17,$00,$27,$00 ; DD85 22 00 2B 00 17 00 27 00  ".+...'.
        .byte   $22,$00,$32,$00,$96,$17,$93,$27 ; DD8D 22 00 32 00 96 17 93 27  ".2....'
        .byte   $00,$22,$00,$2B,$00,$96,$17,$93 ; DD95 00 22 00 2B 00 96 17 93  .".+....
        .byte   $32,$00,$22,$00,$32,$00,$17,$00 ; DD9D 32 00 22 00 32 00 17 00  2.".2...
        .byte   $32,$00,$20,$00,$23,$00,$96,$17 ; DDA5 32 00 20 00 23 00 96 17  2. .#...
        .byte   $93,$27,$00,$20,$00,$30,$00,$96 ; DDAD 93 27 00 20 00 30 00 96  .'. .0..
        .byte   $17,$93,$27,$00,$20,$00,$2A,$00 ; DDB5 17 93 27 00 20 00 2A 00  ..'. .*.
        .byte   $96,$17,$93,$23,$00,$96,$18,$93 ; DDBD 96 17 93 23 00 96 18 93  ...#....
        .byte   $28,$00,$96,$13,$93,$30,$00,$20 ; DDC5 28 00 96 13 93 30 00 20  (....0. 
        .byte   $00,$23,$00,$96,$17,$93,$30,$00 ; DDCD 00 23 00 96 17 93 30 00  .#....0.
        .byte   $96,$18,$93,$28,$00,$96,$13,$93 ; DDD5 96 18 93 28 00 96 13 93  ...(....
        .byte   $30,$00,$20,$00,$27,$00,$96,$17 ; DDDD 30 00 20 00 27 00 96 17  0. .'...
        .byte   $93,$23,$00,$99,$2B,$93,$27,$00 ; DDE5 93 23 00 99 2B 93 27 00  .#..+.'.
        .byte   $25,$00,$99,$23,$20,$93,$1A,$98 ; DDED 25 00 99 23 20 93 1A 98  %..# ...
        .byte   $00,$99,$15,$98,$1A,$F7,$1E,$00 ; DDF5 00 99 15 98 1A F7 1E 00  ........
        .byte   $99,$20,$23,$17,$20,$18,$13,$18 ; DDFD 99 20 23 17 20 18 13 18  . #. ...
        .byte   $00,$20,$27,$18,$15,$93,$17,$00 ; DE05 00 20 27 18 15 93 17 00  . '.....
        .byte   $2B,$00,$1B,$00,$32,$00,$22,$00 ; DE0D 2B 00 1B 00 32 00 22 00  +...2.".
        .byte   $27,$00,$17,$00,$2B,$00,$23,$00 ; DE15 27 00 17 00 2B 00 23 00  '...+.#.
        .byte   $30,$00,$20,$00,$23,$00,$17,$00 ; DE1D 30 00 20 00 23 00 17 00  0. .#...
        .byte   $27,$00,$13,$00,$30,$00,$18,$00 ; DE25 27 00 13 00 30 00 18 00  '...0...
        .byte   $28,$00,$20,$00,$35,$00,$23,$00 ; DE2D 28 00 20 00 35 00 23 00  (. .5.#.
        .byte   $30,$00,$25,$00,$28,$00,$27,$00 ; DE35 30 00 25 00 28 00 27 00  0.%.(.'.
        .byte   $2B,$00,$22,$00,$27,$00,$1B,$98 ; DE3D 2B 00 22 00 27 00 1B 98  +.".'...
        .byte   $00,$93,$27,$98,$00,$93,$20,$00 ; DE45 00 93 27 98 00 93 20 00  ..'... .
        .byte   $30,$00,$96,$17,$93,$27,$00,$20 ; DE4D 30 00 96 17 93 27 00 20  0....'. 
        .byte   $00,$2A,$00,$96,$17,$93,$27,$00 ; DE55 00 2A 00 96 17 93 27 00  .*....'.
        .byte   $96,$18,$93,$28,$00,$96,$13,$93 ; DE5D 96 18 93 28 00 96 13 93  ...(....
        .byte   $30,$00,$20,$00,$27,$00,$96,$17 ; DE65 30 00 20 00 27 00 96 17  0. .'...
        .byte   $93,$30,$00,$18,$00,$28,$00,$13 ; DE6D 93 30 00 18 00 28 00 13  .0...(..
        .byte   $00,$30,$00,$20,$00,$27,$00,$96 ; DE75 00 30 00 20 00 27 00 96  .0. .'..
        .byte   $17,$30,$99,$2B,$93,$27,$00,$25 ; DE7D 17 30 99 2B 93 27 00 25  .0.+.'.%
        .byte   $00,$23,$98,$00,$93,$20,$98,$00 ; DE85 00 23 98 00 93 20 98 00  .#... ..
        .byte   $FE,$67,$DD,$9B,$33,$93,$35,$00 ; DE8D FE 67 DD 9B 33 93 35 00  .g..3.5.
        .byte   $9B,$37,$93,$33,$00,$99,$37,$93 ; DE95 9B 37 93 33 00 99 37 93  .7.3..7.
        .byte   $35,$00,$33,$00,$99,$35,$2B,$9B ; DE9D 35 00 33 00 99 35 2B 9B  5.3..5+.
        .byte   $35,$93,$37,$00,$9B,$38,$93,$35 ; DEA5 35 93 37 00 9B 38 93 35  5.7..8.5
        .byte   $00,$99,$38,$93,$37,$00,$35,$00 ; DEAD 00 99 38 93 37 00 35 00  ..8.7.5.
        .byte   $9C,$33,$99,$3A,$43,$42,$93,$43 ; DEB5 9C 33 99 3A 43 42 93 43  .3.:CB.C
        .byte   $00,$42,$00,$99,$40,$93,$3A,$00 ; DEBD 00 42 00 99 40 93 3A 00  .B..@.:.
        .byte   $38,$00,$99,$3A,$33,$93,$33,$00 ; DEC5 38 00 99 3A 33 93 33 00  8..:3.3.
        .byte   $99,$40,$93,$38,$00,$9B,$3A,$93 ; DECD 99 40 93 38 00 9B 3A 93  .@.8..:.
        .byte   $37,$00,$35,$00,$2B,$00,$37,$00 ; DED5 37 00 35 00 2B 00 37 00  7.5.+.7.
        .byte   $35,$00,$33,$F7,$2A,$00,$9F,$33 ; DEDD 35 00 33 F7 2A 00 9F 33  5.3.*..3
        .byte   $96,$37,$00,$37,$00,$93,$37,$00 ; DEE5 96 37 00 37 00 93 37 00  .7.7..7.
        .byte   $33,$00,$32,$00,$30,$00,$9F,$33 ; DEED 33 00 32 00 30 00 9F 33  3.2.0..3
        .byte   $96,$30,$00,$99,$30,$93,$30,$00 ; DEF5 96 30 00 99 30 93 30 00  .0..0.0.
        .byte   $2A,$00,$28,$00,$27,$00,$99,$1B ; DEFD 2A 00 28 00 27 00 99 1B  *.(.'...
        .byte   $1B,$93,$1B,$00,$20,$00,$22,$00 ; DF05 1B 93 1B 00 20 00 22 00  .... .".
        .byte   $25,$00,$F7,$3C,$23,$20,$00,$22 ; DF0D 25 00 F7 3C 23 20 00 22  %..<# ."
        .byte   $00,$23,$00,$99,$25,$25,$93,$25 ; DF15 00 23 00 99 25 25 93 25  .#..%%.%
        .byte   $00,$28,$00,$27,$00,$25,$00,$9C ; DF1D 00 28 00 27 00 25 00 9C  .(.'.%..
        .byte   $27,$96,$32,$00,$47,$00,$93,$57 ; DF25 27 96 32 00 47 00 93 57  '.2.G..W
        .byte   $00,$55,$00,$53,$00,$52,$00,$50 ; DF2D 00 55 00 53 00 52 00 50  .U.S.R.P
        .byte   $00,$4A,$00,$48,$00,$47,$00,$57 ; DF35 00 4A 00 48 00 47 00 57  .J.H.G.W
        .byte   $00,$55,$00,$53,$00,$52,$00,$53 ; DF3D 00 55 00 53 00 52 00 53  .U.S.R.S
        .byte   $00,$55,$00,$57,$00,$58,$00,$5A ; DF45 00 55 00 57 00 58 00 5A  .U.W.X.Z
        .byte   $00,$58,$00,$57,$00,$55,$00,$53 ; DF4D 00 58 00 57 00 55 00 53  .X.W.U.S
        .byte   $00,$52,$00,$50,$00,$4A,$00,$57 ; DF55 00 52 00 50 00 4A 00 57  .R.P.J.W
        .byte   $00,$58,$00,$59,$00,$5B,$00,$60 ; DF5D 00 58 00 59 00 5B 00 60  .X.Y.[.`
        .byte   $98,$00,$93,$30,$98,$00,$FE,$90 ; DF65 98 00 93 30 98 00 FE 90  ...0....
        .byte   $DE,$FF,$6E,$DF,$01,$01,$01,$01 ; DF6D DE FF 6E DF 01 01 01 01  ..n.....
        .byte   $01,$01,$01,$01,$02,$03,$02,$03 ; DF75 01 01 01 01 02 03 02 03  ........
        .byte   $01,$01,$01,$01,$01,$01,$01,$04 ; DF7D 01 01 01 01 01 01 01 04  ........
        .byte   $FF,$71,$DF,$00,$00,$00,$00,$00 ; DF85 FF 71 DF 00 00 00 00 00  .q......
        .byte   $00,$00,$00,$00,$00,$00,$00,$04 ; DF8D 00 00 00 00 00 00 00 04  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DF95 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DF9D 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$02 ; DFA5 00 00 00 00 00 00 00 02  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DFAD 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DFB5 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DFBD 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DFC5 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DFCD 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DFD5 00 00 00 00 00 00 00 00  ........
        .byte   $00,$01,$00,$00,$00,$00,$00,$10 ; DFDD 00 01 00 00 00 00 00 10  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DFE5 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DFED 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$20 ; DFF5 00 00 00 00 00 00 00 20  ....... 
        .byte   $03,$A4,$01                     ; DFFD 03 A4 01                 ...
LE000:
        .byte   $4C,$AA,$E2                     ; E000 4C AA E2                 L..
LE003:
        .byte   $0D                             ; E003 0D                       .
LE004:
        .byte   $E0,$21,$E0,$35,$E0             ; E004 E0 21 E0 35 E0           .!.5.
; ----------------------------------------------------------------------------
        eor     #$E0                            ; E009 49 E0                    I.
        eor     $7BE0,x                         ; E00B 5D E0 7B                 ].{
        .byte   $E0,$83,$E0,$8B,$E0,$96,$E0,$9D ; E00E E0 83 E0 8B E0 96 E0 9D  ........
        .byte   $E0,$A0,$E0,$AE,$E0,$A3,$E0,$71 ; E016 E0 A0 E0 AE E0 A3 E0 71  .......q
        .byte   $E0,$76,$E0,$C2,$E0,$C2,$E0,$C2 ; E01E E0 76 E0 C2 E0 C2 E0 C2  .v......
        .byte   $E0,$C2,$E0,$C9,$E0,$C9,$E0,$C9 ; E026 E0 C2 E0 C9 E0 C9 E0 C9  ........
        .byte   $E0,$C9,$E0,$B8,$E0,$BD,$E0,$E3 ; E02E E0 C9 E0 B8 E0 BD E0 E3  ........
        .byte   $E0,$E7,$E0,$EB,$E0,$EF,$E0,$E3 ; E036 E0 E7 E0 EB E0 EF E0 E3  ........
        .byte   $E0,$E7,$E0,$EB,$E0,$EF,$E0,$D9 ; E03E E0 E7 E0 EB E0 EF E0 D9  ........
        .byte   $E0,$D4,$E0,$F3,$E0,$F6,$E0,$F9 ; E046 E0 D4 E0 F3 E0 F6 E0 F9  ........
        .byte   $E0,$FC,$E0,$FF,$E0,$02,$E1,$F9 ; E04E E0 FC E0 FF E0 02 E1 F9  ........
        .byte   $E0,$FC,$E0,$DE,$E0,$D4,$E0,$05 ; E056 E0 FC E0 DE E0 D4 E0 05  ........
        .byte   $E1,$09,$E1,$0D,$E1,$11,$E1,$05 ; E05E E1 09 E1 0D E1 11 E1 05  ........
        .byte   $E1,$09,$E1,$0D,$E1,$11,$E1,$DE ; E066 E1 09 E1 0D E1 11 E1 DE  ........
        .byte   $E0,$D4,$E0,$00,$01,$00,$02,$FF ; E06E E0 D4 E0 00 01 00 02 FF  ........
        .byte   $16,$03,$03,$16,$FF,$16,$08,$0B ; E076 16 03 03 16 FF 16 08 0B  ........
        .byte   $0C,$0D,$16,$0B,$FF,$16,$0F,$10 ; E07E 0C 0D 16 0B FF 16 0F 10  ........
        .byte   $11,$12,$13,$14,$FF,$16,$08,$09 ; E086 11 12 13 14 FF 16 08 09  ........
        .byte   $0A,$09,$08,$17,$18,$17,$08,$FF ; E08E 0A 09 08 17 18 17 08 FF  ........
        .byte   $16,$08,$0E,$08,$19,$08,$FF,$16 ; E096 16 08 0E 08 19 08 FF 16  ........
        .byte   $15,$FF,$16,$1A,$FF,$16,$05,$06 ; E09E 15 FF 16 1A FF 16 05 06  ........
        .byte   $07,$06,$05,$06,$07,$06,$00,$FF ; E0A6 07 06 05 06 07 06 00 FF  ........
        .byte   $16,$1B,$1C,$1D,$1C,$1B,$1C,$1D ; E0AE 16 1B 1C 1D 1C 1B 1C 1D  ........
        .byte   $1E,$FF,$04,$05,$06,$05,$FF,$00 ; E0B6 1E FF 04 05 06 05 FF 00  ........
        .byte   $10,$10,$00,$FF,$00,$01,$02,$03 ; E0BE 10 10 00 FF 00 01 02 03  ........
        .byte   $12,$11,$FF,$00,$07,$08,$09,$0A ; E0C6 12 11 FF 00 07 08 09 0A  ........
        .byte   $0B,$0C,$0D,$0E,$0F,$FF,$04,$03 ; E0CE 0B 0C 0D 0E 0F FF 04 03  ........
        .byte   $03,$04,$FF,$00,$01,$00,$02,$FF ; E0D6 03 04 FF 00 01 00 02 FF  ........
        .byte   $00,$01,$02,$01,$FF,$08,$06,$05 ; E0DE 00 01 02 01 FF 08 06 05  ........
        .byte   $FF,$07,$08,$06,$FF,$05,$07,$08 ; E0E6 FF 07 08 06 FF 05 07 08  ........
        .byte   $FF,$06,$05,$07,$FF,$05,$06,$FF ; E0EE FF 06 05 07 FF 05 06 FF  ........
        .byte   $05,$07,$FF,$05,$08,$FF,$05,$09 ; E0F6 05 07 FF 05 08 FF 05 09  ........
        .byte   $FF,$05,$0A,$FF,$05,$0B,$FF,$05 ; E0FE FF 05 0A FF 05 0B FF 05  ........
        .byte   $06,$07,$FF,$06,$05,$07,$FF,$07 ; E106 06 07 FF 06 05 07 FF 07  ........
        .byte   $05,$06,$FF,$06,$07,$05,$FF     ; E10E 05 06 FF 06 07 05 FF     .......
LE115:
        .byte   $1F                             ; E115 1F                       .
LE116:
        .byte   $E1,$BA,$E1,$19,$E2,$46,$E2,$82 ; E116 E1 BA E1 19 E2 46 E2 82  .....F..
        .byte   $E2,$00,$35,$36,$3F,$40,$00,$37 ; E11E E2 00 35 36 3F 40 00 37  ..56?@.7
        .byte   $38,$41,$42,$00,$39,$3A,$43,$44 ; E126 38 41 42 00 39 3A 43 44  8AB.9:CD
        .byte   $00,$3B,$3C,$45,$46,$00,$39,$3A ; E12E 00 3B 3C 45 46 00 39 3A  .;<EF.9:
        .byte   $4F,$50,$00,$49,$4A,$51,$40,$00 ; E136 4F 50 00 49 4A 51 40 00  OP.IJQ@.
        .byte   $4B,$4C,$52,$53,$00,$4D,$4E,$54 ; E13E 4B 4C 52 53 00 4D 4E 54  KLRS.MNT
        .byte   $55,$00,$57,$58,$5D,$5E,$00,$59 ; E146 55 00 57 58 5D 5E 00 59  U.WX]^.Y
        .byte   $5A,$5F,$60,$00,$5B,$5C,$61,$62 ; E14E 5A 5F 60 00 5B 5C 61 62  Z_`.[\ab
        .byte   $00,$63,$64,$69,$6A,$00,$65,$66 ; E156 00 63 64 69 6A 00 65 66  .cdij.ef
        .byte   $6B,$6C,$00,$67,$68,$6D,$6E,$00 ; E15E 6B 6C 00 67 68 6D 6E 00  kl.ghmn.
        .byte   $6F,$70,$71,$72,$00,$73,$74,$7D ; E166 6F 70 71 72 00 73 74 7D  opqr.st}
        .byte   $7E,$00,$75,$76,$7F,$80,$00,$77 ; E16E 7E 00 75 76 7F 80 00 77  ~.uv...w
        .byte   $78,$81,$82,$00,$79,$7A,$83,$84 ; E176 78 81 82 00 79 7A 83 84  x...yz..
        .byte   $00,$7B,$E6,$85,$86,$00,$E6,$7C ; E17E 00 7B E6 85 86 00 E6 7C  .{.....|
        .byte   $87,$88,$00,$89,$8A,$8B,$8C,$00 ; E186 87 88 00 89 8A 8B 8C 00  ........
        .byte   $3D,$3E,$47,$48,$40,$5A,$59,$60 ; E18E 3D 3E 47 48 40 5A 59 60  =>GH@ZY`
        .byte   $5F,$40,$5C,$5B,$62,$61,$40,$70 ; E196 5F 40 5C 5B 62 61 40 70  _@\[ba@p
        .byte   $6F,$72,$71,$40,$8A,$89,$8C,$8B ; E19E 6F 72 71 40 8A 89 8C 8B  orq@....
        .byte   $40,$4A,$49,$40,$51,$40,$4C,$4B ; E1A6 40 4A 49 40 51 40 4C 4B  @JI@Q@LK
        .byte   $53,$52,$40,$4E,$4D,$55,$54,$40 ; E1AE 53 52 40 4E 4D 55 54 40  SR@NMUT@
        .byte   $36,$35,$40,$3F,$00,$01,$02,$1B ; E1B6 36 35 40 3F 00 01 02 1B  65@?....
        .byte   $1C,$00,$03,$04,$1D,$1C,$00,$05 ; E1BE 1C 00 03 04 1D 1C 00 05  ........
        .byte   $06,$1E,$1F,$00,$07,$08,$20,$21 ; E1C6 06 1E 1F 00 07 08 20 21  ...... !
        .byte   $00,$26,$27,$2D,$2E,$00,$03,$28 ; E1CE 00 26 27 2D 2E 00 03 28  .&'-...(
        .byte   $2F,$30,$00,$29,$2A,$31,$32,$00 ; E1D6 2F 30 00 29 2A 31 32 00  /0.)*12.
        .byte   $09,$0A,$22,$1C,$00,$0B,$0C,$23 ; E1DE 09 0A 22 1C 00 0B 0C 23  .."....#
        .byte   $1C,$00,$0D,$0E,$23,$1C,$00,$0F ; E1E6 1C 00 0D 0E 23 1C 00 0F  ....#...
        .byte   $10,$23,$1C,$00,$11,$12,$24,$25 ; E1EE 10 23 1C 00 11 12 24 25  .#....$%
        .byte   $00,$13,$14,$23,$1C,$00,$15,$16 ; E1F6 00 13 14 23 1C 00 15 16  ...#....
        .byte   $23,$1C,$00,$17,$18,$23,$1C,$00 ; E1FE 23 1C 00 17 18 23 1C 00  #....#..
        .byte   $19,$1A,$23,$1C,$00,$2B,$2C,$33 ; E206 19 1A 23 1C 00 2B 2C 33  ..#..+,3
        .byte   $34,$40,$04,$03,$1C,$1D,$40,$06 ; E20E 34 40 04 03 1C 1D 40 06  4@....@.
        .byte   $05,$1F,$1E,$00,$8D,$8E,$9C,$9D ; E216 05 1F 1E 00 8D 8E 9C 9D  ........
        .byte   $00,$8F,$90,$9E,$9F,$00,$8F,$90 ; E21E 00 8F 90 9E 9F 00 8F 90  ........
        .byte   $A0,$A1,$00,$91,$92,$A2,$46,$00 ; E226 A0 A1 00 91 92 A2 46 00  ......F.
        .byte   $93,$94,$A2,$48,$00,$95,$96,$A3 ; E22E 93 94 A2 48 00 95 96 A3  ...H....
        .byte   $A4,$00,$97,$98,$A5,$A4,$00,$99 ; E236 A4 00 97 98 A5 A4 00 99  ........
        .byte   $96,$A6,$A7,$00,$9A,$9B,$A8,$A9 ; E23E 96 A6 A7 00 9A 9B A8 A9  ........
        .byte   $00,$AA,$AB,$3F,$BA,$00,$AC,$AD ; E246 00 AA AB 3F BA 00 AC AD  ...?....
        .byte   $41,$BB,$00,$AE,$AD,$BC,$BD,$00 ; E24E 41 BB 00 AE AD BC BD 00  A.......
        .byte   $AF,$B0,$BE,$BF,$00,$B1,$B2,$C0 ; E256 AF B0 BE BF 00 B1 B2 C0  ........
        .byte   $C1,$00,$B3,$B4,$C2,$C3,$00,$B5 ; E25E C1 00 B3 B4 C2 C3 00 B5  ........
        .byte   $B6,$C4,$C5,$00,$B3,$B7,$C2,$C6 ; E266 B6 C4 C5 00 B3 B7 C2 C6  ........
        .byte   $00,$B3,$B8,$C2,$C7,$00,$B5,$B7 ; E26E 00 B3 B8 C2 C7 00 B5 B7  ........
        .byte   $C4,$C6,$00,$B9,$B7,$C8,$C6,$00 ; E276 C4 C6 00 B9 B7 C8 C6 00  ........
        .byte   $B9,$B4,$C8,$C3,$00,$C9,$CA,$D9 ; E27E B9 B4 C8 C3 00 C9 CA D9  ........
        .byte   $DA,$00,$CB,$CC,$DB,$DC,$00,$CD ; E286 DA 00 CB CC DB DC 00 CD  ........
        .byte   $CE,$DD,$DE,$00,$CF,$D0,$DF,$E0 ; E28E CE DD DE 00 CF D0 DF E0  ........
        .byte   $00,$D1,$D2,$E1,$E2,$00,$D3,$D4 ; E296 00 D1 D2 E1 E2 00 D3 D4  ........
        .byte   $E3,$E4,$00,$D5,$D6,$E5,$E4,$00 ; E29E E3 E4 00 D5 D6 E5 E4 00  ........
        .byte   $D7,$D8,$E5,$E4,$A9,$08,$85,$3D ; E2A6 D7 D8 E5 E4 A9 08 85 3D  .......=
        .byte   $A9,$00,$18,$A0,$05             ; E2AE A9 00 18 A0 05           .....
; ----------------------------------------------------------------------------
LE2B3:
        adc     $0596                           ; E2B3 6D 96 05                 m..
        dey                                     ; E2B6 88                       .
        bne     LE2B3                           ; E2B7 D0 FA                    ..
        tax                                     ; E2B9 AA                       .
        lda     #$00                            ; E2BA A9 00                    ..
        tay                                     ; E2BC A8                       .
        clc                                     ; E2BD 18                       .
LE2BE:
        adc     LE349,x                         ; E2BE 7D 49 E3                 }I.
        sta     $A2,y                           ; E2C1 99 A2 00                 ...
        inx                                     ; E2C4 E8                       .
        iny                                     ; E2C5 C8                       .
        cpy     #$05                            ; E2C6 C0 05                    ..
        bcc     LE2BE                           ; E2C8 90 F4                    ..
        sta     $A7                             ; E2CA 85 A7                    ..
        jsr     LE4AA                           ; E2CC 20 AA E4                  ..
        jsr     LFF21                           ; E2CF 20 21 FF                  !.
        ldx     $0596                           ; E2D2 AE 96 05                 ...
        lda     LE343,x                         ; E2D5 BD 43 E3                 .C.
        sta     $A0                             ; E2D8 85 A0                    ..
LE2DA:
        ldx     #$00                            ; E2DA A2 00                    ..
        stx     $AA                             ; E2DC 86 AA                    ..
        stx     $A1                             ; E2DE 86 A1                    ..
        stx     $A8                             ; E2E0 86 A8                    ..
LE2E2:
        ldx     $A1                             ; E2E2 A6 A1                    ..
        dec     $C1,x                           ; E2E4 D6 C1                    ..
        bne     LE2F1                           ; E2E6 D0 09                    ..
        jsr     LE60C                           ; E2E8 20 0C E6                  ..
        jsr     LE5AB                           ; E2EB 20 AB E5                  ..
        jsr     LE5C6                           ; E2EE 20 C6 E5                  ..
LE2F1:
        ldx     $AA                             ; E2F1 A6 AA                    ..
        inc     $A1                             ; E2F3 E6 A1                    ..
        inc     $A8                             ; E2F5 E6 A8                    ..
LE2F7:
        lda     $A1                             ; E2F7 A5 A1                    ..
        cmp     $A2,x                           ; E2F9 D5 A2                    ..
        bcc     LE2E2                           ; E2FB 90 E5                    ..
        inx                                     ; E2FD E8                       .
        stx     $AA                             ; E2FE 86 AA                    ..
        lda     #$00                            ; E300 A9 00                    ..
        sta     $A8                             ; E302 85 A8                    ..
        cpx     #$05                            ; E304 E0 05                    ..
        bcc     LE2F7                           ; E306 90 EF                    ..
        inc     $42                             ; E308 E6 42                    .B
        jsr     LFF03                           ; E30A 20 03 FF                  ..
        lda     $0612                           ; E30D AD 12 06                 ...
        bne     LE31C                           ; E310 D0 0A                    ..
        dec     $A0                             ; E312 C6 A0                    ..
        beq     LE323                           ; E314 F0 0D                    ..
        jsr     LFF21                           ; E316 20 21 FF                  !.
        jmp     LE2DA                           ; E319 4C DA E2                 L..

; ----------------------------------------------------------------------------
LE31C:
        lda     nmiWaitVar                      ; E31C A5 3C                    .<
        bne     LE2DA                           ; E31E D0 BA                    ..
        jsr     LFF1E                           ; E320 20 1E FF                  ..
LE323:
        jsr     LE38B                           ; E323 20 8B E3                  ..
        jsr     LE401                           ; E326 20 01 E4                  ..
        .byte   $AD,$96,$05                     ; E329 AD 96 05                 ...
; ----------------------------------------------------------------------------
        cmp     #$05                            ; E32C C9 05                    ..
        bcc     LE33D                           ; E32E 90 0D                    ..
        lda     #$06                            ; E330 A9 06                    ..
        jsr     LFF27                           ; E332 20 27 FF                  '.
        jsr     LE79E                           ; E335 20 9E E7                  ..
        lda     #$04                            ; E338 A9 04                    ..
        jsr     LFF27                           ; E33A 20 27 FF                  '.
LE33D:
        lda     #$02                            ; E33D A9 02                    ..
        sta     SND_CHN                         ; E33F 8D 15 40                 ..@
        rts                                     ; E342 60                       `

; ----------------------------------------------------------------------------
LE343:
        ora     ($01,x)                         ; E343 01 01                    ..
        ora     ($01,x)                         ; E345 01 01                    ..
        ora     ($02,x)                         ; E347 01 02                    ..
LE349:
        ora     ($01,x)                         ; E349 01 01                    ..
        brk                                     ; E34B 00                       .
        .byte   $01,$00,$01,$01,$01,$01,$00,$02 ; E34C 01 00 01 01 01 01 00 02  ........
        .byte   $01,$01,$01,$01,$03,$02,$01,$01 ; E354 01 01 01 01 03 02 01 01  ........
        .byte   $01,$03,$03,$02,$01,$01,$04,$03 ; E35C 01 03 03 02 01 01 04 03  ........
        .byte   $02,$01,$01                     ; E364 02 01 01                 ...
LE367:
        .byte   $C0,$80,$D0,$D0,$D0             ; E367 C0 80 D0 D0 D0           .....
LE36C:
        .byte   $58,$00,$08,$08,$08             ; E36C 58 00 08 08 08           X....
LE371:
        .byte   $A8,$48,$48,$48,$48             ; E371 A8 48 48 48 48           .HHHH
LE376:
        .byte   $80                             ; E376 80                       .
LE377:
        .byte   $E3,$84,$E3,$87,$E3,$89,$E3,$8A ; E377 E3 84 E3 87 E3 89 E3 8A  ........
        .byte   $E3,$72,$96,$84,$60,$23,$36,$10 ; E37F E3 72 96 84 60 23 36 10  .r..`#6.
        .byte   $20,$40,$30,$10                 ; E387 20 40 30 10               @0.
LE38B:
        .byte   $A2,$00,$86,$AA,$86,$A8,$86,$A7 ; E38B A2 00 86 AA 86 A8 86 A7  ........
LE393:
        .byte   $86                             ; E393 86                       .
; ----------------------------------------------------------------------------
        lda     (L00A9,x)                       ; E394 A1 A9                    ..
        .byte   $12                             ; E396 12                       .
        sta     $AB,x                           ; E397 95 AB                    ..
        lda     #$00                            ; E399 A9 00                    ..
        sta     $B6,x                           ; E39B 95 B6                    ..
        jsr     LE60C                           ; E39D 20 0C E6                  ..
        jsr     LE5C6                           ; E3A0 20 C6 E5                  ..
        ldy     $AA                             ; E3A3 A4 AA                    ..
        ldx     $A1                             ; E3A5 A6 A1                    ..
        inx                                     ; E3A7 E8                       .
        inc     $A8                             ; E3A8 E6 A8                    ..
LE3AA:
        txa                                     ; E3AA 8A                       .
        cmp     $A2,y                           ; E3AB D9 A2 00                 ...
        bcc     LE393                           ; E3AE 90 E3                    ..
        lda     #$00                            ; E3B0 A9 00                    ..
        sta     $A8                             ; E3B2 85 A8                    ..
        iny                                     ; E3B4 C8                       .
        sty     $AA                             ; E3B5 84 AA                    ..
        cpy     #$05                            ; E3B7 C0 05                    ..
        bcc     LE3AA                           ; E3B9 90 EF                    ..
LE3BB:
        ldy     #$14                            ; E3BB A0 14                    ..
        jsr     LFF09                           ; E3BD 20 09 FF                  ..
        ldx     #$00                            ; E3C0 A2 00                    ..
        stx     $AA                             ; E3C2 86 AA                    ..
        stx     $A1                             ; E3C4 86 A1                    ..
        stx     $A8                             ; E3C6 86 A8                    ..
LE3C8:
        ldx     $A1                             ; E3C8 A6 A1                    ..
        lda     $AB,x                           ; E3CA B5 AB                    ..
        cmp     #$12                            ; E3CC C9 12                    ..
        bcc     LE3E3                           ; E3CE 90 13                    ..
        jsr     LE60C                           ; E3D0 20 0C E6                  ..
        jsr     LE5AB                           ; E3D3 20 AB E5                  ..
        jsr     LE5C6                           ; E3D6 20 C6 E5                  ..
        ldx     $A1                             ; E3D9 A6 A1                    ..
        lda     $AB,x                           ; E3DB B5 AB                    ..
        cmp     #$12                            ; E3DD C9 12                    ..
        bcs     LE3E3                           ; E3DF B0 02                    ..
        inc     $A7                             ; E3E1 E6 A7                    ..
LE3E3:
        ldx     $AA                             ; E3E3 A6 AA                    ..
        inc     $A1                             ; E3E5 E6 A1                    ..
        inc     $A8                             ; E3E7 E6 A8                    ..
LE3E9:
        lda     $A1                             ; E3E9 A5 A1                    ..
        cmp     $A2,x                           ; E3EB D5 A2                    ..
        bcc     LE3C8                           ; E3ED 90 D9                    ..
        inx                                     ; E3EF E8                       .
        stx     $AA                             ; E3F0 86 AA                    ..
        lda     #$00                            ; E3F2 A9 00                    ..
        sta     $A8                             ; E3F4 85 A8                    ..
        cpx     #$05                            ; E3F6 E0 05                    ..
        bcc     LE3E9                           ; E3F8 90 EF                    ..
        lda     $A7                             ; E3FA A5 A7                    ..
        cmp     $A6                             ; E3FC C5 A6                    ..
        bcc     LE3BB                           ; E3FE 90 BB                    ..
        rts                                     ; E400 60                       `

; ----------------------------------------------------------------------------
LE401:
        ldx     #$00                            ; E401 A2 00                    ..
        stx     $AA                             ; E403 86 AA                    ..
        stx     $A8                             ; E405 86 A8                    ..
        stx     $A7                             ; E407 86 A7                    ..
LE409:
        stx     $A1                             ; E409 86 A1                    ..
        lda     #$10                            ; E40B A9 10                    ..
        sta     $AB,x                           ; E40D 95 AB                    ..
        lda     #$00                            ; E40F A9 00                    ..
        sta     $B6,x                           ; E411 95 B6                    ..
        jsr     LE60C                           ; E413 20 0C E6                  ..
        jsr     LE5C6                           ; E416 20 C6 E5                  ..
        ldy     $AA                             ; E419 A4 AA                    ..
        ldx     $A1                             ; E41B A6 A1                    ..
        inx                                     ; E41D E8                       .
        inc     $A8                             ; E41E E6 A8                    ..
LE420:
        txa                                     ; E420 8A                       .
        cmp     $A2,y                           ; E421 D9 A2 00                 ...
        bcc     LE409                           ; E424 90 E3                    ..
        lda     #$00                            ; E426 A9 00                    ..
        sta     $A8                             ; E428 85 A8                    ..
        iny                                     ; E42A C8                       .
        sty     $AA                             ; E42B 84 AA                    ..
        cpy     #$05                            ; E42D C0 05                    ..
        bcc     LE420                           ; E42F 90 EF                    ..
LE431:
        ldy     #$0A                            ; E431 A0 0A                    ..
        jsr     LFF09                           ; E433 20 09 FF                  ..
        ldx     #$00                            ; E436 A2 00                    ..
        stx     $AA                             ; E438 86 AA                    ..
        stx     $A1                             ; E43A 86 A1                    ..
        stx     $A8                             ; E43C 86 A8                    ..
LE43E:
        lda     $A1                             ; E43E A5 A1                    ..
        asl     a                               ; E440 0A                       .
        asl     a                               ; E441 0A                       .
        asl     a                               ; E442 0A                       .
        asl     a                               ; E443 0A                       .
        tax                                     ; E444 AA                       .
        lda     oamStaging+83,x                 ; E445 BD 53 02                 .S.
        ldy     $AA                             ; E448 A4 AA                    ..
        cmp     #$F0                            ; E44A C9 F0                    ..
        bcs     LE489                           ; E44C B0 3B                    .;
        adc     #$04                            ; E44E 69 04                    i.
        cmp     LE371,y                         ; E450 D9 71 E3                 .q.
        bcc     LE465                           ; E453 90 10                    ..
        inc     $A7                             ; E455 E6 A7                    ..
        lda     #$F0                            ; E457 A9 F0                    ..
        sta     oamStaging+80,x                 ; E459 9D 50 02                 .P.
        sta     oamStaging+84,x                 ; E45C 9D 54 02                 .T.
        sta     oamStaging+88,x                 ; E45F 9D 58 02                 .X.
        sta     oamStaging+92,x                 ; E462 9D 5C 02                 .\.
LE465:
        sta     oamStaging+83,x                 ; E465 9D 53 02                 .S.
        sta     oamStaging+91,x                 ; E468 9D 5B 02                 .[.
        adc     #$08                            ; E46B 69 08                    i.
        sta     oamStaging+87,x                 ; E46D 9D 57 02                 .W.
        sta     oamStaging+95,x                 ; E470 9D 5F 02                 ._.
        jsr     LE60C                           ; E473 20 0C E6                  ..
        ldx     $A1                             ; E476 A6 A1                    ..
        ldy     $B6,x                           ; E478 B4 B6                    ..
        iny                                     ; E47A C8                       .
        lda     ($D9),y                         ; E47B B1 D9                    ..
        bpl     LE481                           ; E47D 10 02                    ..
        ldy     #$00                            ; E47F A0 00                    ..
LE481:
        sty     $B6,x                           ; E481 94 B6                    ..
        jsr     LE60C                           ; E483 20 0C E6                  ..
        jsr     LE5C6                           ; E486 20 C6 E5                  ..
LE489:
        ldx     $AA                             ; E489 A6 AA                    ..
        inc     $A1                             ; E48B E6 A1                    ..
        inc     $A8                             ; E48D E6 A8                    ..
LE48F:
        lda     $A1                             ; E48F A5 A1                    ..
        cmp     $A2,x                           ; E491 D5 A2                    ..
        bcc     LE43E                           ; E493 90 A9                    ..
        inx                                     ; E495 E8                       .
        stx     $AA                             ; E496 86 AA                    ..
        lda     #$00                            ; E498 A9 00                    ..
        sta     $A8                             ; E49A 85 A8                    ..
        cpx     #$05                            ; E49C E0 05                    ..
        bcc     LE48F                           ; E49E 90 EF                    ..
        lda     $A7                             ; E4A0 A5 A7                    ..
        cmp     $A6                             ; E4A2 C5 A6                    ..
        bcc     LE4A7                           ; E4A4 90 01                    ..
        rts                                     ; E4A6 60                       `

; ----------------------------------------------------------------------------
LE4A7:
        jmp     LE431                           ; E4A7 4C 31 E4                 L1.

; ----------------------------------------------------------------------------
LE4AA:
        ldx     #$00                            ; E4AA A2 00                    ..
        stx     $A8                             ; E4AC 86 A8                    ..
        stx     $AA                             ; E4AE 86 AA                    ..
        stx     $A1                             ; E4B0 86 A1                    ..
LE4B2:
        ldx     $A1                             ; E4B2 A6 A1                    ..
        lda     #$10                            ; E4B4 A9 10                    ..
        sta     $AB,x                           ; E4B6 95 AB                    ..
        lda     #$00                            ; E4B8 A9 00                    ..
        sta     $B6,x                           ; E4BA 95 B6                    ..
        lda     $A1                             ; E4BC A5 A1                    ..
        asl     a                               ; E4BE 0A                       .
        asl     a                               ; E4BF 0A                       .
        asl     a                               ; E4C0 0A                       .
        asl     a                               ; E4C1 0A                       .
        tax                                     ; E4C2 AA                       .
        ldy     $AA                             ; E4C3 A4 AA                    ..
        lda     LE367,y                         ; E4C5 B9 67 E3                 .g.
        sta     oamStaging+80,x                 ; E4C8 9D 50 02                 .P.
        sta     oamStaging+84,x                 ; E4CB 9D 54 02                 .T.
        clc                                     ; E4CE 18                       .
        adc     #$08                            ; E4CF 69 08                    i.
        sta     oamStaging+88,x                 ; E4D1 9D 58 02                 .X.
        sta     oamStaging+92,x                 ; E4D4 9D 5C 02                 .\.
        ldy     $AA                             ; E4D7 A4 AA                    ..
        lda     LE36C,y                         ; E4D9 B9 6C E3                 .l.
        sta     oamStaging+83,x                 ; E4DC 9D 53 02                 .S.
        sta     oamStaging+91,x                 ; E4DF 9D 5B 02                 .[.
        clc                                     ; E4E2 18                       .
        adc     #$08                            ; E4E3 69 08                    i.
        sta     oamStaging+87,x                 ; E4E5 9D 57 02                 .W.
        sta     oamStaging+95,x                 ; E4E8 9D 5F 02                 ._.
        jsr     LFF00                           ; E4EB 20 00 FF                  ..
        lda     rngSeed                         ; E4EE A5 56                    .V
        and     #$03                            ; E4F0 29 03                    ).
        ora     #$20                            ; E4F2 09 20                    . 
        sta     oamStaging+82,x                 ; E4F4 9D 52 02                 .R.
        sta     oamStaging+86,x                 ; E4F7 9D 56 02                 .V.
        sta     oamStaging+90,x                 ; E4FA 9D 5A 02                 .Z.
        sta     oamStaging+94,x                 ; E4FD 9D 5E 02                 .^.
        jsr     LE60C                           ; E500 20 0C E6                  ..
        jsr     LE5C6                           ; E503 20 C6 E5                  ..
        ldx     $AA                             ; E506 A6 AA                    ..
        inc     $A1                             ; E508 E6 A1                    ..
        inc     $A8                             ; E50A E6 A8                    ..
LE50C:
        lda     $A1                             ; E50C A5 A1                    ..
        cmp     $A2,x                           ; E50E D5 A2                    ..
        bcc     LE4B2                           ; E510 90 A0                    ..
        inx                                     ; E512 E8                       .
        stx     $AA                             ; E513 86 AA                    ..
        lda     #$00                            ; E515 A9 00                    ..
        sta     $A8                             ; E517 85 A8                    ..
        cpx     #$05                            ; E519 E0 05                    ..
        bcc     LE50C                           ; E51B 90 EF                    ..
LE51D:
        ldy     #$0A                            ; E51D A0 0A                    ..
        jsr     LFF09                           ; E51F 20 09 FF                  ..
        ldx     #$00                            ; E522 A2 00                    ..
        stx     $AA                             ; E524 86 AA                    ..
        stx     $A1                             ; E526 86 A1                    ..
        stx     $A8                             ; E528 86 A8                    ..
LE52A:
        ldx     $A1                             ; E52A A6 A1                    ..
        lda     $AB,x                           ; E52C B5 AB                    ..
        cmp     #$10                            ; E52E C9 10                    ..
        bcc     LE57F                           ; E530 90 4D                    .M
        jsr     LE60C                           ; E532 20 0C E6                  ..
        ldx     $A1                             ; E535 A6 A1                    ..
        ldy     $B6,x                           ; E537 B4 B6                    ..
        iny                                     ; E539 C8                       .
        lda     ($D9),y                         ; E53A B1 D9                    ..
        bpl     LE540                           ; E53C 10 02                    ..
        ldy     #$00                            ; E53E A0 00                    ..
LE540:
        tya                                     ; E540 98                       .
        sta     $B6,x                           ; E541 95 B6                    ..
        txa                                     ; E543 8A                       .
        asl     a                               ; E544 0A                       .
        asl     a                               ; E545 0A                       .
        asl     a                               ; E546 0A                       .
        asl     a                               ; E547 0A                       .
        tax                                     ; E548 AA                       .
        lda     $AA                             ; E549 A5 AA                    ..
        asl     a                               ; E54B 0A                       .
        tay                                     ; E54C A8                       .
        lda     LE376,y                         ; E54D B9 76 E3                 .v.
        sta     $18                             ; E550 85 18                    ..
        lda     LE377,y                         ; E552 B9 77 E3                 .w.
        sta     $19                             ; E555 85 19                    ..
        ldy     $A8                             ; E557 A4 A8                    ..
        lda     oamStaging+83,x                 ; E559 BD 53 02                 .S.
        cmp     ($18),y                         ; E55C D1 18                    ..
        bcc     LE568                           ; E55E 90 08                    ..
        jsr     LE59B                           ; E560 20 9B E5                  ..
        dec     $A7                             ; E563 C6 A7                    ..
        jmp     LE579                           ; E565 4C 79 E5                 Ly.

; ----------------------------------------------------------------------------
LE568:
        clc                                     ; E568 18                       .
        adc     #$04                            ; E569 69 04                    i.
        sta     oamStaging+83,x                 ; E56B 9D 53 02                 .S.
        sta     oamStaging+91,x                 ; E56E 9D 5B 02                 .[.
        adc     #$08                            ; E571 69 08                    i.
        sta     oamStaging+87,x                 ; E573 9D 57 02                 .W.
        sta     oamStaging+95,x                 ; E576 9D 5F 02                 ._.
LE579:
        jsr     LE60C                           ; E579 20 0C E6                  ..
        jsr     LE5C6                           ; E57C 20 C6 E5                  ..
LE57F:
        ldx     $AA                             ; E57F A6 AA                    ..
        inc     $A1                             ; E581 E6 A1                    ..
        inc     $A8                             ; E583 E6 A8                    ..
LE585:
        lda     $A1                             ; E585 A5 A1                    ..
        cmp     $A2,x                           ; E587 D5 A2                    ..
        bcc     LE52A                           ; E589 90 9F                    ..
        inx                                     ; E58B E8                       .
        stx     $AA                             ; E58C 86 AA                    ..
        lda     #$00                            ; E58E A9 00                    ..
        sta     $A8                             ; E590 85 A8                    ..
        cpx     #$05                            ; E592 E0 05                    ..
        bcc     LE585                           ; E594 90 EF                    ..
        lda     $A7                             ; E596 A5 A7                    ..
        bne     LE51D                           ; E598 D0 83                    ..
        rts                                     ; E59A 60                       `

; ----------------------------------------------------------------------------
LE59B:
        ldx     $A1                             ; E59B A6 A1                    ..
        jsr     LFF00                           ; E59D 20 00 FF                  ..
        lda     rngSeed+5                       ; E5A0 A5 5B                    .[
        and     #$0E                            ; E5A2 29 0E                    ).
        sta     $AB,x                           ; E5A4 95 AB                    ..
        lda     #$00                            ; E5A6 A9 00                    ..
        sta     $B6,x                           ; E5A8 95 B6                    ..
        rts                                     ; E5AA 60                       `

; ----------------------------------------------------------------------------
LE5AB:
        ldx     $A1                             ; E5AB A6 A1                    ..
        inc     $B6,x                           ; E5AD F6 B6                    ..
        ldy     $B6,x                           ; E5AF B4 B6                    ..
        lda     ($D9),y                         ; E5B1 B1 D9                    ..
        bpl     LE5C2                           ; E5B3 10 0D                    ..
        jsr     LFF00                           ; E5B5 20 00 FF                  ..
        lda     rngSeed+6                       ; E5B8 A5 5C                    .\
        and     #$0E                            ; E5BA 29 0E                    ).
        sta     $AB,x                           ; E5BC 95 AB                    ..
        lda     #$00                            ; E5BE A9 00                    ..
        sta     $B6,x                           ; E5C0 95 B6                    ..
LE5C2:
        jsr     LE60C                           ; E5C2 20 0C E6                  ..
        rts                                     ; E5C5 60                       `

; ----------------------------------------------------------------------------
LE5C6:
        ldx     $A1                             ; E5C6 A6 A1                    ..
        lda     #$0C                            ; E5C8 A9 0C                    ..
        sta     $C1,x                           ; E5CA 95 C1                    ..
        txa                                     ; E5CC 8A                       .
        asl     a                               ; E5CD 0A                       .
        asl     a                               ; E5CE 0A                       .
        asl     a                               ; E5CF 0A                       .
        asl     a                               ; E5D0 0A                       .
        tax                                     ; E5D1 AA                       .
        ldy     #$00                            ; E5D2 A0 00                    ..
        lda     oamStaging+82,x                 ; E5D4 BD 52 02                 .R.
        and     #$23                            ; E5D7 29 23                    )#
        ora     ($DB),y                         ; E5D9 11 DB                    ..
        sta     oamStaging+82,x                 ; E5DB 9D 52 02                 .R.
        sta     oamStaging+86,x                 ; E5DE 9D 56 02                 .V.
        sta     oamStaging+90,x                 ; E5E1 9D 5A 02                 .Z.
        sta     oamStaging+94,x                 ; E5E4 9D 5E 02                 .^.
        iny                                     ; E5E7 C8                       .
        lda     ($DB),y                         ; E5E8 B1 DB                    ..
        clc                                     ; E5EA 18                       .
        adc     #$1A                            ; E5EB 69 1A                    i.
        sta     oamStaging+81,x                 ; E5ED 9D 51 02                 .Q.
        iny                                     ; E5F0 C8                       .
        lda     ($DB),y                         ; E5F1 B1 DB                    ..
        clc                                     ; E5F3 18                       .
        adc     #$1A                            ; E5F4 69 1A                    i.
        sta     oamStaging+85,x                 ; E5F6 9D 55 02                 .U.
        iny                                     ; E5F9 C8                       .
        lda     ($DB),y                         ; E5FA B1 DB                    ..
        clc                                     ; E5FC 18                       .
        adc     #$1A                            ; E5FD 69 1A                    i.
        sta     oamStaging+89,x                 ; E5FF 9D 59 02                 .Y.
        iny                                     ; E602 C8                       .
        lda     ($DB),y                         ; E603 B1 DB                    ..
        clc                                     ; E605 18                       .
        adc     #$1A                            ; E606 69 1A                    i.
        sta     oamStaging+93,x                 ; E608 9D 5D 02                 .].
        rts                                     ; E60B 60                       `

; ----------------------------------------------------------------------------
LE60C:
        lda     $AA                             ; E60C A5 AA                    ..
        asl     a                               ; E60E 0A                       .
        tax                                     ; E60F AA                       .
        lda     LE003,x                         ; E610 BD 03 E0                 ...
        sta     $D7                             ; E613 85 D7                    ..
        lda     LE004,x                         ; E615 BD 04 E0                 ...
        sta     $D8                             ; E618 85 D8                    ..
        ldx     $A1                             ; E61A A6 A1                    ..
        ldy     $AB,x                           ; E61C B4 AB                    ..
        lda     ($D7),y                         ; E61E B1 D7                    ..
        sta     $D9                             ; E620 85 D9                    ..
        iny                                     ; E622 C8                       .
        lda     ($D7),y                         ; E623 B1 D7                    ..
        sta     $DA                             ; E625 85 DA                    ..
        ldy     $B6,x                           ; E627 B4 B6                    ..
        lda     $AA                             ; E629 A5 AA                    ..
        asl     a                               ; E62B 0A                       .
        tax                                     ; E62C AA                       .
        lda     ($D9),y                         ; E62D B1 D9                    ..
        asl     a                               ; E62F 0A                       .
        asl     a                               ; E630 0A                       .
        adc     ($D9),y                         ; E631 71 D9                    q.
        adc     LE115,x                         ; E633 7D 15 E1                 }..
        sta     $DB                             ; E636 85 DB                    ..
        lda     #$00                            ; E638 A9 00                    ..
        adc     LE116,x                         ; E63A 7D 16 E1                 }..
        sta     $DC                             ; E63D 85 DC                    ..
        rts                                     ; E63F 60                       `

; ----------------------------------------------------------------------------
LE640:
        ora     $05                             ; E640 05 05                    ..
        ora     $05                             ; E642 05 05                    ..
        ora     $05                             ; E644 05 05                    ..
        ora     $05                             ; E646 05 05                    ..
        ora     $05                             ; E648 05 05                    ..
        .byte   $05,$05,$05,$05,$05,$05,$04,$04 ; E64A 05 05 05 05 05 05 04 04  ........
        .byte   $04,$04,$04,$04,$04,$04,$04,$04 ; E652 04 04 04 04 04 04 04 04  ........
        .byte   $03,$03,$03,$03,$03,$03,$03,$03 ; E65A 03 03 03 03 03 03 03 03  ........
        .byte   $03,$03,$02,$02,$02,$02,$02,$02 ; E662 03 03 02 02 02 02 02 02  ........
        .byte   $02,$02,$01,$01,$01,$01,$01,$01 ; E66A 02 02 01 01 01 01 01 01  ........
        .byte   $00,$00,$00,$00,$00,$80,$00,$00 ; E672 00 00 00 00 00 80 00 00  ........
        .byte   $00,$00,$00,$FF,$FF,$FF,$FF,$FF ; E67A 00 00 00 FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FE,$FE,$FE ; E682 FF FF FF FF FF FE FE FE  ........
        .byte   $FE,$FE,$FE,$FE,$FE,$FE,$FE,$81 ; E68A FE FE FE FE FE FE FE 81  ........
        .byte   $D7,$02,$21,$F8,$D7,$00,$20,$F0 ; E692 D7 02 21 F8 D7 00 20 F0  ..!... .
        .byte   $D7,$00,$20,$E8,$D7,$00,$20,$E0 ; E69A D7 00 20 E8 D7 00 20 E0  .. ... .
        .byte   $CF,$00,$20,$F8,$CF,$00,$20,$F0 ; E6A2 CF 00 20 F8 CF 00 20 F0  .. ... .
        .byte   $CF,$00,$20,$E8,$CF,$00,$20,$E0 ; E6AA CF 00 20 E8 CF 00 20 E0  .. ... .
        .byte   $C7,$00,$20,$F8,$C7,$00,$20,$F0 ; E6B2 C7 00 20 F8 C7 00 20 F0  .. ... .
        .byte   $C7,$00,$20,$E8,$C7,$00,$20,$E0 ; E6BA C7 00 20 E8 C7 00 20 E0  .. ... .
        .byte   $BF,$00,$20,$F8,$BF,$00,$20,$F0 ; E6C2 BF 00 20 F8 BF 00 20 F0  .. ... .
        .byte   $BF,$00,$20,$E8,$BF,$00,$20,$E0 ; E6CA BF 00 20 E8 BF 00 20 E0  .. ... .
        .byte   $D7,$00,$60,$00,$D7,$00,$60,$08 ; E6D2 D7 00 60 00 D7 00 60 08  ..`...`.
        .byte   $D7,$00,$60,$10,$D7,$00,$60,$18 ; E6DA D7 00 60 10 D7 00 60 18  ..`...`.
        .byte   $CF,$00,$60,$00,$CF,$00,$60,$08 ; E6E2 CF 00 60 00 CF 00 60 08  ..`...`.
        .byte   $CF,$00,$60,$10,$CF,$00,$60,$18 ; E6EA CF 00 60 10 CF 00 60 18  ..`...`.
        .byte   $C7,$00,$60,$00,$C7,$00,$60,$08 ; E6F2 C7 00 60 00 C7 00 60 08  ..`...`.
        .byte   $C7,$00,$60,$10,$C7,$00,$60,$18 ; E6FA C7 00 60 10 C7 00 60 18  ..`...`.
        .byte   $BF,$00,$60,$00,$BF,$00,$60,$08 ; E702 BF 00 60 00 BF 00 60 08  ..`...`.
        .byte   $BF,$00,$60,$10,$BF,$00,$60,$18 ; E70A BF 00 60 10 BF 00 60 18  ..`...`.
        .byte   $DF,$00,$E0,$00,$DF,$00,$E0,$08 ; E712 DF 00 E0 00 DF 00 E0 08  ........
        .byte   $DF,$00,$E0,$10,$DF,$00,$E0,$18 ; E71A DF 00 E0 10 DF 00 E0 18  ........
        .byte   $E7,$00,$E0,$00,$E7,$00,$E0,$08 ; E722 E7 00 E0 00 E7 00 E0 08  ........
        .byte   $E7,$00,$E0,$10,$E7,$00,$E0,$18 ; E72A E7 00 E0 10 E7 00 E0 18  ........
        .byte   $EF,$00,$E0,$00,$EF,$00,$E0,$08 ; E732 EF 00 E0 00 EF 00 E0 08  ........
        .byte   $EF,$00,$E0,$10,$EF,$00,$E0,$18 ; E73A EF 00 E0 10 EF 00 E0 18  ........
        .byte   $F7,$00,$E0,$00,$F7,$00,$E0,$08 ; E742 F7 00 E0 00 F7 00 E0 08  ........
        .byte   $F7,$00,$E0,$10,$F7,$00,$E0,$18 ; E74A F7 00 E0 10 F7 00 E0 18  ........
        .byte   $DF,$00,$A0,$F8,$DF,$00,$A0,$F0 ; E752 DF 00 A0 F8 DF 00 A0 F0  ........
        .byte   $DF,$00,$A0,$E8,$DF,$00,$A0,$E0 ; E75A DF 00 A0 E8 DF 00 A0 E0  ........
        .byte   $E7,$00,$A0,$F8,$E7,$00,$A0,$F0 ; E762 E7 00 A0 F8 E7 00 A0 F0  ........
        .byte   $E7,$00,$A0,$E8,$E7,$00,$A0,$E0 ; E76A E7 00 A0 E8 E7 00 A0 E0  ........
        .byte   $EF,$00,$A0,$F8,$EF,$00,$A0,$F0 ; E772 EF 00 A0 F8 EF 00 A0 F0  ........
        .byte   $EF,$00,$A0,$E8,$EF,$00,$A0,$E0 ; E77A EF 00 A0 E8 EF 00 A0 E0  ........
        .byte   $F7,$00,$A0,$F8,$F7,$00,$A0,$F0 ; E782 F7 00 A0 F8 F7 00 A0 F0  ........
        .byte   $F7,$00,$A0,$E8,$F7,$00,$A0,$E0 ; E78A F7 00 A0 E8 F7 00 A0 E0  ........
LE792:
        .byte   $96,$B6,$41,$C0                 ; E792 96 B6 41 C0              ..A.
LE796:
        .byte   $0F,$00,$0E,$08                 ; E796 0F 00 0E 08              ....
LE79A:
        .byte   $1F,$00,$0C,$28                 ; E79A 1F 00 0C 28              ...(
LE79E:
        .byte   $A9,$01,$85,$A7                 ; E79E A9 01 85 A7              ....
LE7A2:
        .byte   $A2,$00                         ; E7A2 A2 00                    ..
LE7A4:
        .byte   $BD,$92,$E6                     ; E7A4 BD 92 E6                 ...
; ----------------------------------------------------------------------------
        sta     oamStaging,x                    ; E7A7 9D 00 02                 ...
        inx                                     ; E7AA E8                       .
        bne     LE7A4                           ; E7AB D0 F7                    ..
        lda     rngSeed+2                       ; E7AD A5 58                    .X
        ora     #$80                            ; E7AF 09 80                    ..
        sta     tmp14                           ; E7B1 85 14                    ..
LE7B3:
        inx                                     ; E7B3 E8                       .
        inx                                     ; E7B4 E8                       .
        inx                                     ; E7B5 E8                       .
        lda     oamStaging,x                    ; E7B6 BD 00 02                 ...
        clc                                     ; E7B9 18                       .
        adc     tmp14                           ; E7BA 65 14                    e.
        sta     oamStaging,x                    ; E7BC 9D 00 02                 ...
        inx                                     ; E7BF E8                       .
        bne     LE7B3                           ; E7C0 D0 F1                    ..
        lda     rngSeed                         ; E7C2 A5 56                    .V
        and     #$7F                            ; E7C4 29 7F                    ).
        sta     $3F                             ; E7C6 85 3F                    .?
LE7C8:
        jsr     LFF12                           ; E7C8 20 12 FF                  ..
        txa                                     ; E7CB 8A                       .
        bne     LE84D                           ; E7CC D0 7F                    ..
        lda     $3F                             ; E7CE A5 3F                    .?
        bne     LE7C8                           ; E7D0 D0 F6                    ..
        lda     #$01                            ; E7D2 A9 01                    ..
        sta     SND_CHN                         ; E7D4 8D 15 40                 ..@
        ldx     #$03                            ; E7D7 A2 03                    ..
LE7D9:
        lda     LE792,x                         ; E7D9 BD 92 E7                 ...
        sta     SQ1_VOL,x                       ; E7DC 9D 00 40                 ..@
        dex                                     ; E7DF CA                       .
        bpl     LE7D9                           ; E7E0 10 F7                    ..
        lda     #$01                            ; E7E2 A9 01                    ..
        sta     SND_CHN                         ; E7E4 8D 15 40                 ..@
        ldx     #$00                            ; E7E7 A2 00                    ..
        stx     $A5                             ; E7E9 86 A5                    ..
        stx     $A4                             ; E7EB 86 A4                    ..
        inx                                     ; E7ED E8                       .
        stx     $A0                             ; E7EE 86 A0                    ..
LE7F0:
        ldx     $A4                             ; E7F0 A6 A4                    ..
        lda     LE640,x                         ; E7F2 BD 40 E6                 .@.
        bmi     LE806                           ; E7F5 30 0F                    0.
        jsr     LE997                           ; E7F7 20 97 E9                  ..
        inc     $42                             ; E7FA E6 42                    .B
        jsr     LFF03                           ; E7FC 20 03 FF                  ..
        lda     nmiWaitVar                      ; E7FF A5 3C                    .<
        beq     LE84D                           ; E801 F0 4A                    .J
        jmp     LE7F0                           ; E803 4C F0 E7                 L..

; ----------------------------------------------------------------------------
LE806:
        lda     #$08                            ; E806 A9 08                    ..
        sta     SND_CHN                         ; E808 8D 15 40                 ..@
        ldx     #$03                            ; E80B A2 03                    ..
LE80D:
        lda     LE796,x                         ; E80D BD 96 E7                 ...
        sta     NOISE_VOL,x                     ; E810 9D 0C 40                 ..@
        dex                                     ; E813 CA                       .
        bpl     LE80D                           ; E814 10 F7                    ..
        lda     #$08                            ; E816 A9 08                    ..
        sta     SND_CHN                         ; E818 8D 15 40                 ..@
        lda     #$20                            ; E81B A9 20                    . 
        ldx     #$0F                            ; E81D A2 0F                    ..
LE81F:
        sta     $04AA,x                         ; E81F 9D AA 04                 ...
        dex                                     ; E822 CA                       .
        bpl     LE81F                           ; E823 10 FA                    ..
        lda     #$2A                            ; E825 A9 2A                    .*
        jsr     LFF0C                           ; E827 20 0C FF                  ..
        lda     #$24                            ; E82A A9 24                    .$
        jsr     LFF0C                           ; E82C 20 0C FF                  ..
        lda     #$0F                            ; E82F A9 0F                    ..
        tax                                     ; E831 AA                       .
LE832:
        sta     $04AA,x                         ; E832 9D AA 04                 ...
        dex                                     ; E835 CA                       .
        bpl     LE832                           ; E836 10 FA                    ..
        jsr     LE964                           ; E838 20 64 E9                  d.
        lda     #$2A                            ; E83B A9 2A                    .*
        jsr     LFF0C                           ; E83D 20 0C FF                  ..
        ldy     #$03                            ; E840 A0 03                    ..
        jsr     LFF09                           ; E842 20 09 FF                  ..
        ldy     #$00                            ; E845 A0 00                    ..
        inc     $A4                             ; E847 E6 A4                    ..
LE849:
        lda     nmiWaitVar                      ; E849 A5 3C                    .<
        bne     LE850                           ; E84B D0 03                    ..
LE84D:
        jmp     LE8F7                           ; E84D 4C F7 E8                 L..

; ----------------------------------------------------------------------------
LE850:
        ldx     #$00                            ; E850 A2 00                    ..
        lda     LE9C3,y                         ; E852 B9 C3 E9                 ...
        bmi     LE896                           ; E855 30 3F                    0?
LE857:
        .byte   $F0,$03                         ; E857 F0 03                    ..
; ----------------------------------------------------------------------------
        clc                                     ; E859 18                       .
        adc     #$00                            ; E85A 69 00                    i.
LE85C:
        sta     oamStaging+1,x                  ; E85C 9D 01 02                 ...
        sta     oamStaging+65,x                 ; E85F 9D 41 02                 .A.
        sta     oamStaging+129,x                ; E862 9D 81 02                 ...
        sta     oamStaging+193,x                ; E865 9D C1 02                 ...
        inx                                     ; E868 E8                       .
        inx                                     ; E869 E8                       .
        inx                                     ; E86A E8                       .
        inx                                     ; E86B E8                       .
        iny                                     ; E86C C8                       .
        lda     LE9C3,y                         ; E86D B9 C3 E9                 ...
        bpl     LE857                           ; E870 10 E5                    ..
        lda     #$00                            ; E872 A9 00                    ..
        dey                                     ; E874 88                       .
        cpx     #$40                            ; E875 E0 40                    .@
        bcc     LE85C                           ; E877 90 E3                    ..
        sty     $CC                             ; E879 84 CC                    ..
        jsr     LE997                           ; E87B 20 97 E9                  ..
        ldy     #$07                            ; E87E A0 07                    ..
        sty     $3F                             ; E880 84 3F                    .?
LE882:
        inc     $42                             ; E882 E6 42                    .B
        jsr     LFF03                           ; E884 20 03 FF                  ..
        lda     nmiWaitVar                      ; E887 A5 3C                    .<
        beq     LE84D                           ; E889 F0 C2                    ..
        lda     $3F                             ; E88B A5 3F                    .?
        bne     LE882                           ; E88D D0 F3                    ..
        ldy     $CC                             ; E88F A4 CC                    ..
        iny                                     ; E891 C8                       .
        iny                                     ; E892 C8                       .
        jmp     LE849                           ; E893 4C 49 E8                 LI.

; ----------------------------------------------------------------------------
LE896:
        cmp     #$FF                            ; E896 C9 FF                    ..
        beq     LE8E3                           ; E898 F0 49                    .I
        iny                                     ; E89A C8                       .
        sty     $CC                             ; E89B 84 CC                    ..
        cmp     #$FE                            ; E89D C9 FE                    ..
        beq     LE8BC                           ; E89F F0 1B                    ..
        lda     $A5                             ; E8A1 A5 A5                    ..
        beq     LE849                           ; E8A3 F0 A4                    ..
        and     #$0F                            ; E8A5 29 0F                    ).
        eor     #$04                            ; E8A7 49 04                    I.
        cmp     #$0D                            ; E8A9 C9 0D                    ..
        bcc     LE8AF                           ; E8AB 90 02                    ..
        eor     #$0C                            ; E8AD 49 0C                    I.
LE8AF:
        jsr     LE96F                           ; E8AF 20 6F E9                  o.
        lda     #$30                            ; E8B2 A9 30                    .0
        jsr     LFF0C                           ; E8B4 20 0C FF                  ..
        .byte   $A4                             ; E8B7 A4                       .
; ----------------------------------------------------------------------------
        cpy     $494C                           ; E8B8 CC 4C 49                 .LI
        inx                                     ; E8BB E8                       .
LE8BC:
        lda     rngSeed+3                       ; E8BC A5 59                    .Y
        and     #$18                            ; E8BE 29 18                    ).
        bne     LE849                           ; E8C0 D0 87                    ..
        lda     $04AD                           ; E8C2 AD AD 04                 ...
        sta     $A5                             ; E8C5 85 A5                    ..
        ldx     #$10                            ; E8C7 A2 10                    ..
        lda     #$0F                            ; E8C9 A9 0F                    ..
LE8CB:
        sta     $04A9,x                         ; E8CB 9D A9 04                 ...
        dex                                     ; E8CE CA                       .
        bne     LE8CB                           ; E8CF D0 FA                    ..
        sta     $04A8                           ; E8D1 8D A8 04                 ...
        lda     #$30                            ; E8D4 A9 30                    .0
        jsr     LFF0C                           ; E8D6 20 0C FF                  ..
        ldy     #$01                            ; E8D9 A0 01                    ..
        jsr     LFF09                           ; E8DB 20 09 FF                  ..
        ldy     $CC                             ; E8DE A4 CC                    ..
        jmp     LE849                           ; E8E0 4C 49 E8                 LI.

; ----------------------------------------------------------------------------
LE8E3:
        dec     $A0                             ; E8E3 C6 A0                    ..
        lda     nmiWaitVar                      ; E8E5 A5 3C                    .<
        beq     LE8F7                           ; E8E7 F0 0E                    ..
        jsr     LE902                           ; E8E9 20 02 E9                  ..
        jsr     LEB1F                           ; E8EC 20 1F EB                  ..
        lda     $0598                           ; E8EF AD 98 05                 ...
        bne     LE8F7                           ; E8F2 D0 03                    ..
        jmp     LE7A2                           ; E8F4 4C A2 E7                 L..

; ----------------------------------------------------------------------------
LE8F7:
        lda     #$F0                            ; E8F7 A9 F0                    ..
        ldx     #$00                            ; E8F9 A2 00                    ..
LE8FB:
        sta     oamStaging,x                    ; E8FB 9D 00 02                 ...
        inx                                     ; E8FE E8                       .
        bne     LE8FB                           ; E8FF D0 FA                    ..
        rts                                     ; E901 60                       `

; ----------------------------------------------------------------------------
LE902:
        lda     #$30                            ; E902 A9 30                    .0
        sta     $A2                             ; E904 85 A2                    ..
        lda     #$20                            ; E906 A9 20                    . 
        sta     $A3                             ; E908 85 A3                    ..
LE90A:
        ldy     #$14                            ; E90A A0 14                    ..
        sty     $3F                             ; E90C 84 3F                    .?
LE90E:
        jsr     LFF00                           ; E90E 20 00 FF                  ..
        lda     rngSeed+5                       ; E911 A5 5B                    .[
        and     #$01                            ; E913 29 01                    ).
        tay                                     ; E915 A8                       .
        lda     $04AD                           ; E916 AD AD 04                 ...
        and     #$0F                            ; E919 29 0F                    ).
        ora     $A2,y                           ; E91B 19 A2 00                 ...
        sta     $04AD                           ; E91E 8D AD 04                 ...
        sta     $04B1                           ; E921 8D B1 04                 ...
        sta     $04B5                           ; E924 8D B5 04                 ...
        sta     $04B8                           ; E927 8D B8 04                 ...
        lda     $3F                             ; E92A A5 3F                    .?
        and     #$07                            ; E92C 29 07                    ).
        bne     LE933                           ; E92E D0 03                    ..
        jsr     LE997                           ; E930 20 97 E9                  ..
LE933:
        lda     $04AD                           ; E933 AD AD 04                 ...
        and     #$0F                            ; E936 29 0F                    ).
        ldy     $A3                             ; E938 A4 A3                    ..
        cpy     #$20                            ; E93A C0 20                    . 
        bcc     LE940                           ; E93C 90 02                    ..
        ora     #$10                            ; E93E 09 10                    ..
LE940:
        sta     $04A8                           ; E940 8D A8 04                 ...
        lda     #$30                            ; E943 A9 30                    .0
        jsr     LFF0C                           ; E945 20 0C FF                  ..
        lda     $3F                             ; E948 A5 3F                    .?
        bne     LE90E                           ; E94A D0 C2                    ..
        lda     $A3                             ; E94C A5 A3                    ..
        cmp     #$0F                            ; E94E C9 0F                    ..
        beq     LE963                           ; E950 F0 11                    ..
        sta     $A2                             ; E952 85 A2                    ..
        sec                                     ; E954 38                       8
        sbc     #$10                            ; E955 E9 10                    ..
        bpl     LE95F                           ; E957 10 06                    ..
        lda     $A7                             ; E959 A5 A7                    ..
        bne     LE963                           ; E95B D0 06                    ..
        lda     #$0F                            ; E95D A9 0F                    ..
LE95F:
        sta     $A3                             ; E95F 85 A3                    ..
        bpl     LE90A                           ; E961 10 A7                    ..
LE963:
        rts                                     ; E963 60                       `

; ----------------------------------------------------------------------------
LE964:
        jsr     LFF00                           ; E964 20 00 FF                  ..
        .byte   $A5                             ; E967 A5                       .
; ----------------------------------------------------------------------------
        .byte   $5A                             ; E968 5A                       Z
        and     #$0F                            ; E969 29 0F                    ).
        cmp     #$0D                            ; E96B C9 0D                    ..
        bcs     LE964                           ; E96D B0 F5                    ..
LE96F:
        ora     #$40                            ; E96F 09 40                    .@
        sta     tmp15                           ; E971 85 15                    ..
        ldx     #$03                            ; E973 A2 03                    ..
LE975:
        lda     tmp15                           ; E975 A5 15                    ..
        sec                                     ; E977 38                       8
        sbc     #$10                            ; E978 E9 10                    ..
        sta     tmp15                           ; E97A 85 15                    ..
        sta     $04AA,x                         ; E97C 9D AA 04                 ...
        sta     $04AE,x                         ; E97F 9D AE 04                 ...
        sta     $04B2,x                         ; E982 9D B2 04                 ...
        sta     $04B6,x                         ; E985 9D B6 04                 ...
        dex                                     ; E988 CA                       .
        bne     LE975                           ; E989 D0 EA                    ..
        and     #$0F                            ; E98B 29 0F                    ).
        ldx     rngSeed+3                       ; E98D A6 59                    .Y
        bmi     LE993                           ; E98F 30 02                    0.
        ora     #$10                            ; E991 09 10                    ..
LE993:
        sta     $04A8                           ; E993 8D A8 04                 ...
        rts                                     ; E996 60                       `

; ----------------------------------------------------------------------------
LE997:
        ldy     $A4                             ; E997 A4 A4                    ..
        lda     LE640,y                         ; E999 B9 40 E6                 .@.
        cmp     #$81                            ; E99C C9 81                    ..
        beq     LE9BE                           ; E99E F0 1E                    ..
        ldx     #$00                            ; E9A0 A2 00                    ..
LE9A2:
        lda     oamStaging,x                    ; E9A2 BD 00 02                 ...
        sec                                     ; E9A5 38                       8
        sbc     LE640,y                         ; E9A6 F9 40 E6                 .@.
        sta     oamStaging,x                    ; E9A9 9D 00 02                 ...
        inx                                     ; E9AC E8                       .
        inx                                     ; E9AD E8                       .
        inx                                     ; E9AE E8                       .
        lda     oamStaging,x                    ; E9AF BD 00 02                 ...
        sec                                     ; E9B2 38                       8
        sbc     $A0                             ; E9B3 E5 A0                    ..
        sta     oamStaging,x                    ; E9B5 9D 00 02                 ...
        inx                                     ; E9B8 E8                       .
        bne     LE9A2                           ; E9B9 D0 E7                    ..
        inc     $A4                             ; E9BB E6 A4                    ..
        txa                                     ; E9BD 8A                       .
LE9BE:
        rts                                     ; E9BE 60                       `

; ----------------------------------------------------------------------------
        .byte   $02                             ; E9BF 02                       .
        .byte   $FF                             ; E9C0 FF                       .
        .byte   $03                             ; E9C1 03                       .
        .byte   $FF                             ; E9C2 FF                       .
LE9C3:
        .byte   $04                             ; E9C3 04                       .
        .byte   $FF                             ; E9C4 FF                       .
        asl     $05                             ; E9C5 06 05                    ..
        brk                                     ; E9C7 00                       .
        .byte   $00,$01,$FF,$FE,$1C,$1B,$00,$00 ; E9C8 00 01 FF FE 1C 1B 00 00  ........
        .byte   $11,$10,$FF,$FD,$1F,$1E,$1D,$00 ; E9D0 11 10 FF FD 1F 1E 1D 00  ........
        .byte   $14,$13,$12,$00,$0A,$09,$FF,$23 ; E9D8 14 13 12 00 0A 09 FF 23  .......#
        .byte   $22,$21,$20,$17,$16,$15,$00,$0D ; E9E0 22 21 20 17 16 15 00 0D  "! .....
        .byte   $0C,$0B,$00,$07,$FF,$27,$26,$25 ; E9E8 0C 0B 00 07 FF 27 26 25  .....'&%
        .byte   $24,$1A,$19,$18,$00,$0F,$0E,$0B ; E9F0 24 1A 19 18 00 0F 0E 0B  $.......
        .byte   $00,$08,$FF,$32,$31,$30,$2F,$2E ; E9F8 00 08 FF 32 31 30 2F 2E  ...210/.
        .byte   $2D,$2C,$00,$2B,$2A,$29,$00,$28 ; EA00 2D 2C 00 2B 2A 29 00 28  -,.+*).(
        .byte   $FF,$FF                         ; EA08 FF FF                    ..
LEA0A:
        .byte   $1B,$18,$04,$0F,$0D,$FE,$FC,$F2 ; EA0A 1B 18 04 0F 0D FE FC F2  ........
        .byte   $EB,$F8,$ED,$F9,$06,$16,$12,$08 ; EA12 EB F8 ED F9 06 16 12 08  ........
        .byte   $0F,$FC,$E8,$FC,$F3,$FE,$EF,$05 ; EA1A 0F FC E8 FC F3 FE EF 05  ........
        .byte   $09,$0F,$0F,$18,$06,$02,$F4,$F4 ; EA22 09 0F 0F 18 06 02 F4 F4  ........
        .byte   $EF,$E9                         ; EA2A EF E9                    ..
LEA2C:
        .byte   $FE,$F4,$FD,$FD,$E9,$E6,$F2,$ED ; EA2C FE F4 FD FD E9 E6 F2 ED  ........
        .byte   $FE,$02,$0F,$16,$0A,$07,$15,$1A ; EA34 FE 02 0F 16 0A 07 15 1A  ........
        .byte   $F2,$0F,$08,$04,$0A,$1B,$15,$14 ; EA3C F2 0F 08 04 0A 1B 15 14  ........
        .byte   $02,$04,$0F,$0D,$F7,$ED,$E9,$F7 ; EA44 02 04 0F 0D F7 ED E9 F7  ........
        .byte   $00,$F4                         ; EA4C 00 F4                    ..
LEA4E:
        .byte   $33,$37,$3A,$3E,$56,$5A,$5E,$37 ; EA4E 33 37 3A 3E 56 5A 5E 37  37:>VZ^7
LEA56:
        .byte   $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0 ; EA56 C0 C0 C0 C0 C0 C0 C0 C0  ........
LEA5E:
        .byte   $12,$12,$22,$22,$22,$12,$22,$22 ; EA5E 12 12 22 22 22 12 22 22  ..""".""
LEA66:
        .byte   $AD,$00,$02,$85,$A1,$AD,$03,$02 ; EA66 AD 00 02 85 A1 AD 03 02  ........
        .byte   $85                             ; EA6E 85                       .
; ----------------------------------------------------------------------------
        ldy     #$A5                            ; EA6F A0 A5                    ..
        .byte   $5A                             ; EA71 5A                       Z
        and     #$07                            ; EA72 29 07                    ).
        tax                                     ; EA74 AA                       .
        lda     LEA4E,x                         ; EA75 BD 4E EA                 .N.
        sta     $A6                             ; EA78 85 A6                    ..
        lda     LEA56,x                         ; EA7A BD 56 EA                 .V.
        sta     L00A9                           ; EA7D 85 A9                    ..
        lda     LEA5E,x                         ; EA7F BD 5E EA                 .^.
        sta     $A8                             ; EA82 85 A8                    ..
        ldy     #$00                            ; EA84 A0 00                    ..
        lda     #$F0                            ; EA86 A9 F0                    ..
LEA88:
        sta     oamStaging,y                    ; EA88 99 00 02                 ...
        iny                                     ; EA8B C8                       .
        bne     LEA88                           ; EA8C D0 FA                    ..
LEA8E:
        jsr     LFF00                           ; EA8E 20 00 FF                  ..
        tya                                     ; EA91 98                       .
        asl     a                               ; EA92 0A                       .
        asl     a                               ; EA93 0A                       .
        tax                                     ; EA94 AA                       .
        lda     LEA0A,y                         ; EA95 B9 0A EA                 ...
        bmi     LEA9C                           ; EA98 30 02                    0.
        eor     #$FF                            ; EA9A 49 FF                    I.
LEA9C:
        adc     #$28                            ; EA9C 69 28                    i(
        sta     $AA,y                           ; EA9E 99 AA 00                 ...
        lda     LEA2C,y                         ; EAA1 B9 2C EA                 .,.
        clc                                     ; EAA4 18                       .
        adc     $A1                             ; EAA5 65 A1                    e.
        adc     #$03                            ; EAA7 69 03                    i.
        sta     oamStaging,x                    ; EAA9 9D 00 02                 ...
        lda     #$32                            ; EAAC A9 32                    .2
        sta     oamStaging+1,x                  ; EAAE 9D 01 02                 ...
        lda     #$23                            ; EAB1 A9 23                    .#
        sta     oamStaging+2,x                  ; EAB3 9D 02 02                 ...
        lda     LEA0A,y                         ; EAB6 B9 0A EA                 ...
        clc                                     ; EAB9 18                       .
        adc     $A0                             ; EABA 65 A0                    e.
        adc     #$03                            ; EABC 69 03                    i.
        sta     oamStaging+3,x                  ; EABE 9D 03 02                 ...
        iny                                     ; EAC1 C8                       .
        cpy     #$22                            ; EAC2 C0 22                    ."
        bcc     LEA8E                           ; EAC4 90 C8                    ..
        lda     $04AD                           ; EAC6 AD AD 04                 ...
        and     #$0F                            ; EAC9 29 0F                    ).
        sta     tmp14                           ; EACB 85 14                    ..
        sta     $04A8                           ; EACD 8D A8 04                 ...
        ldy     #$00                            ; EAD0 A0 00                    ..
LEAD2:
        lda     LEAE5,y                         ; EAD2 B9 E5 EA                 ...
        ora     tmp14                           ; EAD5 05 14                    ..
        sta     $04AA,y                         ; EAD7 99 AA 04                 ...
        iny                                     ; EADA C8                       .
        cpy     #$10                            ; EADB C0 10                    ..
        bcc     LEAD2                           ; EADD 90 F3                    ..
        lda     #$30                            ; EADF A9 30                    .0
        jsr     LFF0C                           ; EAE1 20 0C FF                  ..
        rts                                     ; EAE4 60                       `

; ----------------------------------------------------------------------------
LEAE5:
        .byte   $0F                             ; EAE5 0F                       .
        bpl     LEB08                           ; EAE6 10 20                    . 
        bmi     LEAF9                           ; EAE8 30 0F                    0.
        brk                                     ; EAEA 00                       .
        bpl     LEB0D                           ; EAEB 10 20                    . 
        .byte   $0F                             ; EAED 0F                       .
        .byte   $0F,$00,$10,$0F,$0F,$0F,$00     ; EAEE 0F 00 10 0F 0F 0F 00     .......
LEAF5:
        .byte   $20,$00,$FF,$A5                 ; EAF5 20 00 FF A5               ...
LEAF9:
        .byte   $5A,$25,$A9,$85,$14             ; EAF9 5A 25 A9 85 14           Z%...
; ----------------------------------------------------------------------------
        lda     oamStaging+2,x                  ; EAFE BD 02 02                 ...
        and     #$3F                            ; EB01 29 3F                    )?
        ora     tmp14                           ; EB03 05 14                    ..
        sta     oamStaging+2,x                  ; EB05 9D 02 02                 ...
LEB08:
        rts                                     ; EB08 60                       `

; ----------------------------------------------------------------------------
LEB09:
        inc     oamStaging+1,x                  ; EB09 FE 01 02                 ...
LEB0D           := * + 1
        lda     oamStaging+1,x                  ; EB0C BD 01 02                 ...
        sec                                     ; EB0F 38                       8
        sbc     #$04                            ; EB10 E9 04                    ..
        cmp     $A6                             ; EB12 C5 A6                    ..
        bcc     LEB1E                           ; EB14 90 08                    ..
        jsr     LEAF5                           ; EB16 20 F5 EA                  ..
        lda     $A6                             ; EB19 A5 A6                    ..
        sta     oamStaging+1,x                  ; EB1B 9D 01 02                 ...
LEB1E:
        rts                                     ; EB1E 60                       `

; ----------------------------------------------------------------------------
LEB1F:
        jsr     LEA66                           ; EB1F 20 66 EA                  f.
        jsr     LEC24                           ; EB22 20 24 EC                  $.
        lda     $0598                           ; EB25 AD 98 05                 ...
        bne     LEB35                           ; EB28 D0 0B                    ..
        jsr     LEB36                           ; EB2A 20 36 EB                  6.
        lda     $0598                           ; EB2D AD 98 05                 ...
        bne     LEB35                           ; EB30 D0 03                    ..
        jsr     LEC94                           ; EB32 20 94 EC                  ..
LEB35:
        rts                                     ; EB35 60                       `

; ----------------------------------------------------------------------------
LEB36:
        ldy     #$00                            ; EB36 A0 00                    ..
        sty     $0598                           ; EB38 8C 98 05                 ...
LEB3B:
        jsr     LEB9C                           ; EB3B 20 9C EB                  ..
        jsr     LEB09                           ; EB3E 20 09 EB                  ..
        iny                                     ; EB41 C8                       .
        cpy     $A8                             ; EB42 C4 A8                    ..
        bcc     LEB3B                           ; EB44 90 F5                    ..
        lda     $3F                             ; EB46 A5 3F                    .?
        bne     LEB4E                           ; EB48 D0 04                    ..
        lda     #$20                            ; EB4A A9 20                    . 
        sta     $3F                             ; EB4C 85 3F                    .?
LEB4E:
        jsr     LEBDE                           ; EB4E 20 DE EB                  ..
        lda     oamStaging                      ; EB51 AD 00 02                 ...
        cmp     #$50                            ; EB54 C9 50                    .P
        bcs     LEB5F                           ; EB56 B0 07                    ..
        lda     nmiWaitVar                      ; EB58 A5 3C                    .<
        bne     LEB36                           ; EB5A D0 DA                    ..
        inc     $0598                           ; EB5C EE 98 05                 ...
LEB5F:
        rts                                     ; EB5F 60                       `

; ----------------------------------------------------------------------------
LEB60:
        ldx     #$03                            ; EB60 A2 03                    ..
LEB62:
        lda     LE79A,x                         ; EB62 BD 9A E7                 ...
        sta     NOISE_VOL,x                     ; EB65 9D 0C 40                 ..@
        dex                                     ; EB68 CA                       .
        bne     LEB62                           ; EB69 D0 F7                    ..
        stx     tmp14                           ; EB6B 86 14                    ..
LEB6D:
        lda     #$04                            ; EB6D A9 04                    ..
        ldy     oamStaging,x                    ; EB6F BC 00 02                 ...
        cpy     #$F0                            ; EB72 C0 F0                    ..
        bcs     LEB7B                           ; EB74 B0 05                    ..
        lda     oamStaging+2,x                  ; EB76 BD 02 02                 ...
        and     #$03                            ; EB79 29 03                    ).
LEB7B:
        eor     #$FF                            ; EB7B 49 FF                    I.
        sec                                     ; EB7D 38                       8
        adc     tmp14                           ; EB7E 65 14                    e.
        clc                                     ; EB80 18                       .
        adc     #$04                            ; EB81 69 04                    i.
        sta     tmp14                           ; EB83 85 14                    ..
        inx                                     ; EB85 E8                       .
        inx                                     ; EB86 E8                       .
        inx                                     ; EB87 E8                       .
        inx                                     ; EB88 E8                       .
        bne     LEB6D                           ; EB89 D0 E2                    ..
        lda     tmp14                           ; EB8B A5 14                    ..
        sta     $CD                             ; EB8D 85 CD                    ..
        lsr     a                               ; EB8F 4A                       J
        cmp     #$0F                            ; EB90 C9 0F                    ..
        bcc     LEB96                           ; EB92 90 02                    ..
        lda     #$0F                            ; EB94 A9 0F                    ..
LEB96:
        ora     #$10                            ; EB96 09 10                    ..
        sta     NOISE_VOL                       ; EB98 8D 0C 40                 ..@
        rts                                     ; EB9B 60                       `

; ----------------------------------------------------------------------------
LEB9C:
        tya                                     ; EB9C 98                       .
        asl     a                               ; EB9D 0A                       .
        asl     a                               ; EB9E 0A                       .
        tax                                     ; EB9F AA                       .
        lda     $AA,y                           ; EBA0 B9 AA 00                 ...
        beq     LEBCD                           ; EBA3 F0 28                    .(
        sec                                     ; EBA5 38                       8
        sbc     #$01                            ; EBA6 E9 01                    ..
        sta     $AA,y                           ; EBA8 99 AA 00                 ...
        bne     LEBCD                           ; EBAB D0 20                    . 
        lda     LEA0A,y                         ; EBAD B9 0A EA                 ...
        bmi     LEBBC                           ; EBB0 30 0A                    0.
        inc     oamStaging+3,x                  ; EBB2 FE 03 02                 ...
        lsr     a                               ; EBB5 4A                       J
        lsr     a                               ; EBB6 4A                       J
        eor     #$FF                            ; EBB7 49 FF                    I.
        jmp     LEBC3                           ; EBB9 4C C3 EB                 L..

; ----------------------------------------------------------------------------
LEBBC:
        lsr     a                               ; EBBC 4A                       J
        lsr     a                               ; EBBD 4A                       J
        ora     #$C0                            ; EBBE 09 C0                    ..
        dec     oamStaging+3,x                  ; EBC0 DE 03 02                 ...
LEBC3:
        clc                                     ; EBC3 18                       .
        adc     #$01                            ; EBC4 69 01                    i.
        beq     LEBCA                           ; EBC6 F0 02                    ..
        adc     #$0A                            ; EBC8 69 0A                    i.
LEBCA:
        sta     $AA,y                           ; EBCA 99 AA 00                 ...
LEBCD:
        lda     $3F                             ; EBCD A5 3F                    .?
        and     #$03                            ; EBCF 29 03                    ).
        bne     LEBDD                           ; EBD1 D0 0A                    ..
        lda     oamStaging,x                    ; EBD3 BD 00 02                 ...
        cmp     #$F0                            ; EBD6 C9 F0                    ..
        bcs     LEBDD                           ; EBD8 B0 03                    ..
        inc     oamStaging,x                    ; EBDA FE 00 02                 ...
LEBDD:
        rts                                     ; EBDD 60                       `

; ----------------------------------------------------------------------------
LEBDE:
        jsr     LFF00                           ; EBDE 20 00 FF                  ..
        lda     rngSeed+5                       ; EBE1 A5 5B                    .[
        bmi     LEC1E                           ; EBE3 30 39                    09
        jsr     LEB60                           ; EBE5 20 60 EB                  `.
        lda     #$F0                            ; EBE8 A9 F0                    ..
        ldy     $04AD                           ; EBEA AC AD 04                 ...
        cpy     #$30                            ; EBED C0 30                    .0
        bcs     LEBF3                           ; EBEF B0 02                    ..
        lda     #$10                            ; EBF1 A9 10                    ..
LEBF3:
        sta     tmp14                           ; EBF3 85 14                    ..
        ldy     #$0F                            ; EBF5 A0 0F                    ..
LEBF7:
        ldx     #$03                            ; EBF7 A2 03                    ..
LEBF9:
        lda     $04AA,y                         ; EBF9 B9 AA 04                 ...
        clc                                     ; EBFC 18                       .
        adc     tmp14                           ; EBFD 65 14                    e.
        cmp     #$F0                            ; EBFF C9 F0                    ..
        bcs     LEC06                           ; EC01 B0 03                    ..
        sta     $04AA,y                         ; EC03 99 AA 04                 ...
LEC06:
        dey                                     ; EC06 88                       .
        dex                                     ; EC07 CA                       .
        bne     LEBF9                           ; EC08 D0 EF                    ..
        dey                                     ; EC0A 88                       .
        bpl     LEBF7                           ; EC0B 10 EA                    ..
        lda     $04AD                           ; EC0D AD AD 04                 ...
        and     #$0F                            ; EC10 29 0F                    ).
        sta     tmp14                           ; EC12 85 14                    ..
        lda     $CD                             ; EC14 A5 CD                    ..
        lsr     a                               ; EC16 4A                       J
        and     #$10                            ; EC17 29 10                    ).
        ora     tmp14                           ; EC19 05 14                    ..
        sta     $04A8                           ; EC1B 8D A8 04                 ...
LEC1E:
        lda     #$30                            ; EC1E A9 30                    .0
        jsr     LFF0C                           ; EC20 20 0C FF                  ..
        rts                                     ; EC23 60                       `

; ----------------------------------------------------------------------------
LEC24:
        lda     #$22                            ; EC24 A9 22                    ."
        sta     $0598                           ; EC26 8D 98 05                 ...
LEC29:
        ldy     #$00                            ; EC29 A0 00                    ..
LEC2B:
        jsr     LEB9C                           ; EC2B 20 9C EB                  ..
        lda     oamStaging+1,x                  ; EC2E BD 01 02                 ...
        cmp     $A6                             ; EC31 C5 A6                    ..
        bcc     LEC38                           ; EC33 90 03                    ..
        jsr     LEB09                           ; EC35 20 09 EB                  ..
LEC38:
        lda     oamStaging+2,x                  ; EC38 BD 02 02                 ...
        and     #$03                            ; EC3B 29 03                    ).
        beq     LEC7A                           ; EC3D F0 3B                    .;
        lda     oamStaging,x                    ; EC3F BD 00 02                 ...
        cmp     #$F0                            ; EC42 C9 F0                    ..
        bcs     LEC7A                           ; EC44 B0 34                    .4
        cmp     #$4C                            ; EC46 C9 4C                    .L
        bcs     LEC53                           ; EC48 B0 09                    ..
        jsr     LFF00                           ; EC4A 20 00 FF                  ..
        lda     rngSeed+3                       ; EC4D A5 59                    .Y
        and     #$28                            ; EC4F 29 28                    )(
        bne     LEC7A                           ; EC51 D0 27                    .'
LEC53:
        cpy     $A8                             ; EC53 C4 A8                    ..
        bcs     LEC72                           ; EC55 B0 1B                    ..
        lda     $A6                             ; EC57 A5 A6                    ..
        cmp     oamStaging+1,x                  ; EC59 DD 01 02                 ...
        beq     LEC60                           ; EC5C F0 02                    ..
        bcs     LEC6C                           ; EC5E B0 0C                    ..
LEC60:
        dec     oamStaging+2,x                  ; EC60 DE 02 02                 ...
        lda     oamStaging+2,x                  ; EC63 BD 02 02                 ...
        and     #$03                            ; EC66 29 03                    ).
        beq     LEC77                           ; EC68 F0 0D                    ..
        bne     LEC7A                           ; EC6A D0 0E                    ..
LEC6C:
        sta     oamStaging+1,x                  ; EC6C 9D 01 02                 ...
        jmp     LEC7A                           ; EC6F 4C 7A EC                 Lz.

; ----------------------------------------------------------------------------
LEC72:
        lda     #$F0                            ; EC72 A9 F0                    ..
        sta     oamStaging,x                    ; EC74 9D 00 02                 ...
LEC77:
        dec     $0598                           ; EC77 CE 98 05                 ...
LEC7A:
        iny                                     ; EC7A C8                       .
        cpy     #$22                            ; EC7B C0 22                    ."
        bcc     LEC2B                           ; EC7D 90 AC                    ..
        lda     $3F                             ; EC7F A5 3F                    .?
        bne     LEC87                           ; EC81 D0 04                    ..
        lda     #$20                            ; EC83 A9 20                    . 
        sta     $3F                             ; EC85 85 3F                    .?
LEC87:
        jsr     LEBDE                           ; EC87 20 DE EB                  ..
        lda     $0598                           ; EC8A AD 98 05                 ...
        beq     LEC93                           ; EC8D F0 04                    ..
        lda     nmiWaitVar                      ; EC8F A5 3C                    .<
        bne     LEC29                           ; EC91 D0 96                    ..
LEC93:
        rts                                     ; EC93 60                       `

; ----------------------------------------------------------------------------
LEC94:
        lda     $A8                             ; EC94 A5 A8                    ..
        sta     $0598                           ; EC96 8D 98 05                 ...
LEC99:
        ldy     #$00                            ; EC99 A0 00                    ..
LEC9B:
        jsr     LEB9C                           ; EC9B 20 9C EB                  ..
        lda     oamStaging+1,x                  ; EC9E BD 01 02                 ...
        cmp     $A6                             ; ECA1 C5 A6                    ..
        bcc     LECA8                           ; ECA3 90 03                    ..
        jsr     LEB09                           ; ECA5 20 09 EB                  ..
LECA8:
        lda     oamStaging,x                    ; ECA8 BD 00 02                 ...
        cmp     #$60                            ; ECAB C9 60                    .`
        bcs     LECC7                           ; ECAD B0 18                    ..
        jsr     LFF00                           ; ECAF 20 00 FF                  ..
        lda     rngSeed+3                       ; ECB2 A5 59                    .Y
        and     #$30                            ; ECB4 29 30                    )0
        bne     LECDC                           ; ECB6 D0 24                    .$
        lda     oamStaging+2,x                  ; ECB8 BD 02 02                 ...
        and     #$03                            ; ECBB 29 03                    ).
        cmp     #$03                            ; ECBD C9 03                    ..
        beq     LECC7                           ; ECBF F0 06                    ..
        inc     oamStaging+2,x                  ; ECC1 FE 02 02                 ...
        jmp     LECDC                           ; ECC4 4C DC EC                 L..

; ----------------------------------------------------------------------------
LECC7:
        lda     #$32                            ; ECC7 A9 32                    .2
        cmp     oamStaging+1,x                  ; ECC9 DD 01 02                 ...
        bne     LECD6                           ; ECCC D0 08                    ..
        lda     #$F0                            ; ECCE A9 F0                    ..
        sta     oamStaging,x                    ; ECD0 9D 00 02                 ...
        jmp     LECDC                           ; ECD3 4C DC EC                 L..

; ----------------------------------------------------------------------------
LECD6:
        sta     oamStaging+1,x                  ; ECD6 9D 01 02                 ...
        dec     $0598                           ; ECD9 CE 98 05                 ...
LECDC:
        iny                                     ; ECDC C8                       .
        cpy     $A8                             ; ECDD C4 A8                    ..
        bcc     LEC9B                           ; ECDF 90 BA                    ..
        lda     $3F                             ; ECE1 A5 3F                    .?
        bne     LECE9                           ; ECE3 D0 04                    ..
        lda     #$20                            ; ECE5 A9 20                    . 
        sta     $3F                             ; ECE7 85 3F                    .?
LECE9:
        jsr     LEBDE                           ; ECE9 20 DE EB                  ..
        lda     $0598                           ; ECEC AD 98 05                 ...
        beq     LECF7                           ; ECEF F0 06                    ..
        lda     nmiWaitVar                      ; ECF1 A5 3C                    .<
        bne     LEC99                           ; ECF3 D0 A4                    ..
        beq     LED01                           ; ECF5 F0 0A                    ..
LECF7:
        lda     #$0F                            ; ECF7 A9 0F                    ..
        sta     $04A8                           ; ECF9 8D A8 04                 ...
        lda     #$30                            ; ECFC A9 30                    .0
        .byte   $20,$0C                         ; ECFE 20 0C                     .
; ----------------------------------------------------------------------------
        .byte   $FF                             ; ED00 FF                       .
LED01:
        rts                                     ; ED01 60                       `

; ----------------------------------------------------------------------------
        brk                                     ; ED02 00                       .
        brk                                     ; ED03 00                       .
        brk                                     ; ED04 00                       .
        brk                                     ; ED05 00                       .
        brk                                     ; ED06 00                       .
        .byte   $04                             ; ED07 04                       .
        brk                                     ; ED08 00                       .
        brk                                     ; ED09 00                       .
        brk                                     ; ED0A 00                       .
        .byte   $00,$80,$00,$00,$00,$00,$00,$00 ; ED0B 00 80 00 00 00 00 00 00  ........
        .byte   $00,$20,$00,$80,$00,$00,$00,$00 ; ED13 00 20 00 80 00 00 00 00  . ......
        .byte   $00,$20,$05,$00,$00,$00,$00,$00 ; ED1B 00 20 05 00 00 00 00 00  . ......
        .byte   $00,$00,$00,$40,$00,$00,$00,$00 ; ED23 00 00 00 40 00 00 00 00  ...@....
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; ED2B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; ED33 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; ED3B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; ED43 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; ED4B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; ED53 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; ED5B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; ED63 00 00 00 00 00 00 00 00  ........
        .byte   $00,$08,$02,$00,$10,$00,$00,$00 ; ED6B 00 08 02 00 10 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; ED73 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; ED7B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$80,$00,$00,$00,$00,$00,$00 ; ED83 00 80 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; ED8B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$10,$00,$00,$00,$00,$00,$00 ; ED93 00 10 00 00 00 00 00 00  ........
        .byte   $00,$00,$01,$00,$00,$00,$00,$00 ; ED9B 00 00 01 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EDA3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EDAB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EDB3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$20,$00,$00,$00,$00,$00 ; EDBB 00 00 20 00 00 00 00 00  .. .....
        .byte   $00,$00,$00,$10,$00,$00,$00,$00 ; EDC3 00 00 00 10 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EDCB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$20,$00,$00,$00,$00,$00 ; EDD3 00 00 20 00 00 00 00 00  .. .....
        .byte   $00,$08,$00,$00,$00,$00,$00,$00 ; EDDB 00 08 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EDE3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EDEB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EDF3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$61,$B8,$FB ; EDFB 00 00 00 00 00 61 B8 FB  .....a..
        .byte   $EE,$FF,$FF,$FF,$FF,$1D,$CD,$B4 ; EE03 EE FF FF FF FF 1D CD B4  ........
        .byte   $F7,$F7,$FF,$FF,$FF,$A5,$31,$A4 ; EE0B F7 F7 FF FF FF A5 31 A4  ......1.
        .byte   $EF,$FF,$FF,$FF,$FF,$0D,$45,$A6 ; EE13 EF FF FF FF FF 0D 45 A6  ......E.
        .byte   $FF,$FF,$FF,$FF,$FF,$4A,$09,$FF ; EE1B FF FF FF FF FF 4A 09 FF  .....J..
        .byte   $FF,$FD,$FE,$FF,$FF,$A0,$E9,$ED ; EE23 FF FD FE FF FF A0 E9 ED  ........
        .byte   $F3,$FF,$DF,$FF,$FF,$53,$05,$EB ; EE2B F3 FF DF FF FF 53 05 EB  .....S..
        .byte   $EE,$FF,$FF,$FF,$F6,$4E,$6B,$BD ; EE33 EE FF FF FF F6 4E 6B BD  .....Nk.
        .byte   $F6,$FF,$FF,$FF,$FF,$7B,$0A,$AA ; EE3B F6 FF FF FF FF 7B 0A AA  .....{..
        .byte   $BB,$FF,$FF,$FF,$BF,$E7,$59,$FD ; EE43 BB FF FF FF BF E7 59 FD  ......Y.
        .byte   $FE,$FF,$FF,$FF,$FF,$53,$6C,$FF ; EE4B FE FF FF FF FF 53 6C FF  .....Sl.
        .byte   $37,$FF,$FF,$FF,$FF,$6F,$32,$E9 ; EE53 37 FF FF FF FF 6F 32 E9  7....o2.
        .byte   $F9,$7F,$FF,$FF,$FF,$2E,$54,$FD ; EE5B F9 7F FF FF FF 2E 54 FD  ......T.
        .byte   $BB,$FF,$FF,$FF,$FF,$38,$B3,$BA ; EE63 BB FF FF FF FF 38 B3 BA  .....8..
        .byte   $F2,$FF,$FE,$EF,$FF,$25,$83,$E1 ; EE6B F2 FF FE EF FF 25 83 E1  .....%..
        .byte   $8F,$FF,$FF,$DF,$FF,$CA,$19,$FF ; EE73 8F FF FF DF FF CA 19 FF  ........
        .byte   $FF,$FF,$F7,$FF,$FF,$38,$FD,$F2 ; EE7B FF FF F7 FF FF 38 FD F2  .....8..
        .byte   $99,$FF,$FF,$6F,$FF,$66,$B5,$5F ; EE83 99 FF FF 6F FF 66 B5 5F  ...o.f._
        .byte   $BF,$FF,$FF,$FF,$FE,$CA,$E2,$FE ; EE8B BF FF FF FF FE CA E2 FE  ........
        .byte   $DF,$FF,$FF,$FF,$FF,$48,$A7,$EF ; EE93 DF FF FF FF FF 48 A7 EF  .....H..
        .byte   $DF,$FF,$FF,$FF,$FF,$82,$74,$F5 ; EE9B DF FF FF FF FF 82 74 F5  ......t.
        .byte   $D7,$FF,$FF,$FF,$DB,$A1,$4E,$F3 ; EEA3 D7 FF FF FF DB A1 4E F3  ......N.
        .byte   $C5,$FF,$FF,$FF,$BF,$3E,$D0,$FE ; EEAB C5 FF FF FF BF 3E D0 FE  .....>..
        .byte   $3F,$FF,$FF,$FF,$FF,$BE,$6E,$F7 ; EEB3 3F FF FF FF FF BE 6E F7  ?.....n.
        .byte   $FE,$FF,$FF,$FF,$FF,$11,$A3,$E3 ; EEBB FE FF FF FF FF 11 A3 E3  ........
        .byte   $EB,$FF,$FF,$F7,$FF,$36,$C8,$DE ; EEC3 EB FF FF F7 FF 36 C8 DE  .....6..
        .byte   $B9,$FF,$FF,$FF,$FF,$85,$DB,$EB ; EECB B9 FF FF FF FF 85 DB EB  ........
        .byte   $F9,$FF,$FF,$FF,$FF,$18,$8F,$EB ; EED3 F9 FF FF FF FF 18 8F EB  ........
        .byte   $FE,$FF,$FF,$BF,$FF,$46,$2C,$FD ; EEDB FE FF FF BF FF 46 2C FD  .....F,.
        .byte   $ED,$FF,$FF,$FF,$FF,$BB,$88,$F9 ; EEE3 ED FF FF FF FF BB 88 F9  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$1E,$AA,$F7 ; EEEB FF FF FF FF FF 1E AA F7  ........
        .byte   $B3,$FF,$FF,$F7,$BF,$FF,$EF,$FF ; EEF3 B3 FF FF F7 BF FF EF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$00,$00,$00 ; EEFB FF FF FF FF FF 00 00 00  ........
        .byte   $00,$20,$00,$10,$08,$00,$00,$00 ; EF03 00 20 00 10 08 00 00 00  . ......
        .byte   $00,$02,$00,$00,$10,$00,$00,$00 ; EF0B 00 02 00 00 10 00 00 00  ........
        .byte   $00,$44,$00,$00,$00,$00,$00,$00 ; EF13 00 44 00 00 00 00 00 00  .D......
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EF1B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$01,$00,$00,$00,$00,$00,$00 ; EF23 00 01 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EF2B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EF33 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EF3B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$08,$00,$00,$00,$00,$00,$00 ; EF43 00 08 00 00 00 00 00 00  ........
        .byte   $00,$00,$20,$00,$00,$00,$00,$00 ; EF4B 00 00 20 00 00 00 00 00  .. .....
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EF53 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$10,$00,$00,$00,$00,$00 ; EF5B 00 00 10 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EF63 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EF6B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EF73 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EF7B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EF83 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$10,$00,$00,$00,$00,$00 ; EF8B 00 00 10 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EF93 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EF9B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EFA3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EFAB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EFB3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$20,$00,$00,$00,$00,$00 ; EFBB 00 00 20 00 00 00 00 00  .. .....
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EFC3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EFCB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$10,$04,$00,$00,$00,$00,$00 ; EFD3 00 10 04 00 00 00 00 00  ........
        .byte   $00,$00,$10,$00,$00,$00,$00,$00 ; EFDB 00 00 10 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; EFE3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$80,$00,$00,$00,$00,$00,$00 ; EFEB 00 80 00 00 00 00 00 00  ........
        .byte   $00,$04,$00,$01,$00,$00,$00,$00 ; EFF3 00 04 00 01 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$20,$00,$00 ; EFFB 00 00 00 00 00 20 00 00  ..... ..
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F003 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F00B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F013 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F01B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F023 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F02B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F033 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F03B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F043 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F04B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F053 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F05B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F063 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F06B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F073 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F07B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F083 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F08B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F093 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F09B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F0A3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F0AB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F0B3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F0BB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$03,$CC ; F0C3 00 00 00 00 00 00 03 CC  ........
        .byte   $8C,$AC,$AA,$BC,$02,$AC,$AC,$CC ; F0CB 8C AC AA BC 02 AC AC CC  ........
        .byte   $CC,$CC,$CC,$CC,$CC,$CC,$AC,$2D ; F0D3 CC CC CC CC CC CC AC 2D  .......-
        .byte   $C6,$CC,$98,$9C,$B9,$21,$8C,$C8 ; F0DB C6 CC 98 9C B9 21 8C C8  .....!..
        .byte   $C8,$5B,$C6,$CC,$8C,$9C,$C9,$BC ; F0E3 C8 5B C6 CC 8C 9C C9 BC  .[......
        .byte   $40,$99,$C9,$9C,$AC,$CC,$BC,$60 ; F0EB 40 99 C9 9C AC CC BC 60  @......`
        .byte   $99,$C9,$3B,$C0,$8C,$AC,$9A,$CC ; F0F3 99 C9 3B C0 8C AC 9A CC  ..;.....
        .byte   $1B,$C0,$4B,$C2,$CC,$CC,$C8,$AC ; F0FB 1B C0 4B C2 CC CC C8 AC  ..K.....
        .byte   $CA,$CC,$6B,$C2,$CC,$CC,$CC,$CC ; F103 CA CC 6B C2 CC CC CC CC  ..k.....
        .byte   $88,$8C,$1B,$A4,$AA,$C8,$88,$AC ; F10B 88 8C 1B A4 AA C8 88 AC  ........
        .byte   $BA,$44,$AC,$CC,$C9,$0B,$A0,$AA ; F113 BA 44 AC CC C9 0B A0 AA  .D......
        .byte   $CA,$C9,$BC,$61,$8C,$A8,$CA,$AA ; F11B CA C9 BC 61 8C A8 CA AA  ...a....
        .byte   $CA,$6B,$C0,$CC,$8C,$8C,$A8,$AC ; F123 CA 6B C0 CC 8C 8C A8 AC  .k......
        .byte   $5B,$C0,$8C,$9C,$CC,$5B,$90,$99 ; F12B 5B C0 8C 9C CC 5B 90 99  [....[..
        .byte   $C8,$C9,$BC,$22,$CC,$C9,$C9,$CC ; F133 C8 C9 BC 22 CC C9 C9 CC  ..."....
        .byte   $CC,$AA,$AC,$AA,$CA,$C8,$88,$BC ; F13B CC AA AC AA CA C8 88 BC  ........
        .byte   $23,$CC,$CC,$C8,$99,$C9,$BC,$05 ; F143 23 CC CC C8 99 C9 BC 05  #.......
        .byte   $CC,$98,$9C,$C9,$6B,$C2,$8C,$C8 ; F14B CC 98 9C C9 6B C2 8C C8  ....k...
        .byte   $0B,$A6,$AA,$AC,$1B,$C6,$8C,$88 ; F153 0B A6 AA AC 1B C6 8C 88  ........
        .byte   $9C,$BC,$03,$8C,$CC,$3B,$C2,$CC ; F15B 9C BC 03 8C CC 3B C2 CC  .....;..
        .byte   $C8,$AA,$CC,$4B,$C4,$C9,$99,$BC ; F163 C8 AA CC 4B C4 C9 99 BC  ...K....
        .byte   $61,$8C,$C8,$C8,$CA,$3B,$A6,$AA ; F16B 61 8C C8 C8 CA 3B A6 AA  a....;..
        .byte   $CC,$2B,$80,$8C,$C9,$C9,$0B,$A0 ; F173 CC 2B 80 8C C9 C9 0B A0  .+......
        .byte   $CA,$CC,$0B,$C6,$3B,$C0,$C8,$AA ; F17B CA CC 0B C6 3B C0 C8 AA  ....;...
        .byte   $CA,$9C,$99,$99,$CC,$C8,$BC,$60 ; F183 CA 9C 99 99 CC C8 BC 60  .......`
        .byte   $CA,$BC,$46,$CC,$8C,$98,$C9,$C9 ; F18B CA BC 46 CC 8C 98 C9 C9  ..F.....
        .byte   $6B,$C4,$88,$C8,$C9,$CC,$CC,$BC ; F193 6B C4 88 C8 C9 CC CC BC  k.......
        .byte   $64,$8C,$9C,$CC,$CC,$3B,$C4,$A8 ; F19B 64 8C 9C CC CC 3B C4 A8  d....;..
        .byte   $AA,$CC,$4B,$C2,$CC,$C9,$99,$C9 ; F1A3 AA CC 4B C2 CC C9 99 C9  ..K.....
        .byte   $CC,$6D,$A2,$CA,$CC,$8C,$CC,$5D ; F1AB CC 6D A2 CA CC 8C CC 5D  .m.....]
        .byte   $84,$9C,$99,$C9,$3B,$A2,$AC,$CA ; F1B3 84 9C 99 C9 3B A2 AC CA  ....;...
        .byte   $BC,$05,$8C,$99,$99,$BC,$03,$CC ; F1BB BC 05 8C 99 99 BC 03 CC  ........
        .byte   $BC,$03,$CC,$CC,$C8,$AA,$CA,$CC ; F1C3 BC 03 CC CC C8 AA CA CC  ........
        .byte   $5B,$A6,$AC,$CA,$CC,$BC,$41,$CC ; F1CB 5B A6 AC CA CC BC 41 CC  [.....A.
        .byte   $8C,$88,$AC,$AA,$BC,$63,$AA,$CA ; F1D3 8C 88 AC AA BC 63 AA CA  .....c..
        .byte   $CC,$3B,$C4,$CC,$CC,$A8,$CA,$CA ; F1DB CC 3B C4 CC CC A8 CA CA  .;......
        .byte   $1B,$C6,$8C,$C8,$A8,$CA,$CC,$3B ; F1E3 1B C6 8C C8 A8 CA CC 3B  .......;
        .byte   $C2,$AA,$AC,$BC,$43,$AA,$C8,$CA ; F1EB C2 AA AC BC 43 AA C8 CA  ....C...
        .byte   $CC,$0B,$A0,$CA,$BC,$20,$AA,$CC ; F1F3 CC 0B A0 CA BC 20 AA CC  ..... ..
        .byte   $CC,$2B,$C6,$99,$9C,$C9,$CC,$BC ; F1FB CC 2B C6 99 9C C9 CC BC  .+......
        .byte   $44,$8C,$C9,$C9,$BC,$06,$CC,$C8 ; F203 44 8C C9 C9 BC 06 CC C8  D.......
        .byte   $98,$C9,$CC,$4B,$96,$99,$9C,$BC ; F20B 98 C9 CC 4B 96 99 9C BC  ...K....
        .byte   $02,$CC,$A8,$AC,$CA,$CC,$DC,$21 ; F213 02 CC A8 AC CA CC DC 21  .......!
        .byte   $CC,$CC,$AA,$AA,$CA,$BC,$22,$8C ; F21B CC CC AA AA CA BC 22 8C  ......".
        .byte   $C8,$AA,$CC,$6B,$C6,$C8,$C9,$BC ; F223 C8 AA CC 6B C6 C8 C9 BC  ...k....
        .byte   $65,$99,$99,$CC,$2B,$C0,$C8,$CC ; F22B 65 99 99 CC 2B C0 C8 CC  e...+...
        .byte   $CA,$CC,$CC,$9C,$C9,$BC,$03,$CC ; F233 CA CC CC 9C C9 BC 03 CC  ........
        .byte   $8C,$AC,$AA,$CC,$2B,$A2,$CC,$CC ; F23B 8C AC AA CC 2B A2 CC CC  ....+...
        .byte   $CC,$CC,$CC,$4B,$C4,$CC,$8C,$99 ; F243 CC CC CC 4B C4 CC 8C 99  ...K....
        .byte   $9C,$99,$BC,$05,$CC,$8C,$9C,$99 ; F24B 9C 99 BC 05 CC 8C 9C 99  ........
        .byte   $CC,$CC,$CC,$CC,$AC,$AA,$CC,$BC ; F253 CC CC CC CC AC AA CC BC  ........
        .byte   $65,$CA,$CC,$0B,$94,$99,$CC,$BC ; F25B 65 CA CC 0B 94 99 CC BC  e.......
        .byte   $45,$CC,$CC,$CC,$C8,$99,$9C,$BC ; F263 45 CC CC CC C8 99 9C BC  E.......
        .byte   $21,$8C,$C8,$CC,$9C,$C9,$CC,$AA ; F26B 21 8C C8 CC 9C C9 CC AA  !.......
        .byte   $CA,$AA,$3D,$94,$C9,$3B,$C6,$CC ; F273 CA AA 3D 94 C9 3B C6 CC  ..=..;..
        .byte   $AC,$AA,$CC,$4B,$C4,$C8,$99,$C9 ; F27B AC AA CC 4B C4 C8 99 C9  ...K....
        .byte   $4B,$C4,$C8,$C9,$6B,$C2,$C8,$98 ; F283 4B C4 C8 C9 6B C2 C8 98  K...k...
        .byte   $C9,$BC,$46,$CA,$CA,$CC,$BC,$62 ; F28B C9 BC 46 CA CA CC BC 62  ..F....b
        .byte   $C8,$88,$C9,$BC,$64,$99,$99,$CC ; F293 C8 88 C9 BC 64 99 99 CC  ....d...
        .byte   $CC,$5B,$80,$9C,$99,$C9,$FB,$00 ; F29B CC 5B 80 9C 99 C9 FB 00  .[......
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F2A3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F2AB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F2B3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$80,$FF,$FF,$FF ; F2BB 00 00 00 00 80 FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F2C3 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F2CB FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F2D3 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$00,$00,$00 ; F2DB FF FF FF FF FF 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F2E3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F2EB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F2F3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$FF,$FF,$FF ; F2FB 00 00 00 00 00 FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F303 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F30B FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F313 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$00,$00,$00 ; F31B FF FF FF FF FF 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$01,$00 ; F323 00 00 00 00 00 00 01 00  ........
        .byte   $00,$00,$00,$00,$40,$00,$00,$00 ; F32B 00 00 00 00 40 00 00 00  ....@...
        .byte   $00,$00,$40,$00,$00,$00,$00,$00 ; F333 00 00 40 00 00 00 00 00  ..@.....
        .byte   $00,$00,$00,$00,$00,$FF,$FF,$FF ; F33B 00 00 00 00 00 FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F343 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F34B FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F353 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$00,$00,$00 ; F35B FF FF FF FF FF 00 00 00  ........
        .byte   $00,$00,$00,$00,$80,$00,$00,$00 ; F363 00 00 00 00 80 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F36B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$01,$00,$00,$00 ; F373 00 00 00 00 01 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$FF,$FF,$FF ; F37B 00 00 00 00 00 FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F383 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F38B FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F393 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$00,$00,$00 ; F39B FF FF FF FF FF 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F3A3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F3AB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$10 ; F3B3 00 00 00 00 00 00 00 10  ........
        .byte   $00,$00,$00,$00,$00,$FF,$FF,$FF ; F3BB 00 00 00 00 00 FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F3C3 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F3CB FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F3D3 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$00,$00,$00 ; F3DB FF FF FF FF FF 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F3E3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F3EB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$01,$00,$20 ; F3F3 00 00 00 00 00 01 00 20  ....... 
        .byte   $00,$00,$00,$00,$00,$03,$00,$00 ; F3FB 00 00 00 00 00 03 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F403 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F40B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F413 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F41B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F423 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F42B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F433 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F43B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F443 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F44B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F453 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F45B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F463 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F46B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$33,$00 ; F473 00 00 00 00 00 00 33 00  ......3.
        .byte   $34,$00,$00,$35,$36,$00,$00,$00 ; F47B 34 00 00 35 36 00 00 00  4..56...
        .byte   $37,$38,$38,$34,$00,$00,$00,$00 ; F483 37 38 38 34 00 00 00 00  7884....
        .byte   $00,$00,$00,$00,$33,$33,$00,$36 ; F48B 00 00 00 00 33 33 00 36  ....33.6
        .byte   $35,$00,$00,$00,$33,$37,$38,$00 ; F493 35 00 00 00 33 37 38 00  5...378.
        .byte   $00,$38,$38,$34,$00,$00,$00,$00 ; F49B 00 38 38 34 00 00 00 00  .884....
        .byte   $35,$00,$00,$00,$36,$00,$00,$00 ; F4A3 35 00 00 00 36 00 00 00  5...6...
        .byte   $00,$35,$33,$37,$37,$00,$00,$38 ; F4AB 00 35 33 37 37 00 00 38  .5377..8
        .byte   $35,$33,$36,$00,$34,$34,$35,$00 ; F4B3 35 33 36 00 34 34 35 00  536.445.
        .byte   $00,$00,$37,$37,$00,$35,$35,$34 ; F4BB 00 00 37 37 00 35 35 34  ..77.554
        .byte   $00,$00,$00,$00,$00,$00,$46,$CC ; F4C3 00 00 00 00 00 00 46 CC  ......F.
        .byte   $8C,$99,$C9,$BC,$62,$88,$AC,$AA ; F4CB 8C 99 C9 BC 62 88 AC AA  ....b...
        .byte   $AA,$CC,$CC,$CC,$CC,$CC,$CC,$D9 ; F4D3 AA CC CC CC CC CC CC D9  ........
        .byte   $24,$AA,$BC,$03,$CC,$8C,$99,$CC ; F4DB 24 AA BC 03 CC 8C 99 CC  $.......
        .byte   $BC,$00,$BC,$22,$8C,$8C,$98,$9C ; F4E3 BC 00 BC 22 8C 8C 98 9C  ..."....
        .byte   $C9,$6B,$82,$8C,$AA,$CA,$0B,$A4 ; F4EB C9 6B 82 8C AA CA 0B A4  .k......
        .byte   $CA,$BC,$60,$99,$C9,$5B,$80,$AA ; F4F3 CA BC 60 99 C9 5B 80 AA  ..`..[..
        .byte   $AA,$AC,$1B,$C4,$88,$A8,$AA,$CA ; F4FB AA AC 1B C4 88 A8 AA CA  ........
        .byte   $BA,$41,$BC,$23,$CC,$99,$C9,$0B ; F503 BA 41 BC 23 CC 99 C9 0B  .A.#....
        .byte   $C0,$AA,$CA,$CA,$3B,$82,$CA,$0B ; F50B C0 AA CA CA 3B 82 CA 0B  ....;...
        .byte   $A6,$AA,$CA,$2B,$C4,$C8,$99,$99 ; F513 A6 AA CA 2B C4 C8 99 99  ...+....
        .byte   $BC,$26,$CC,$CC,$88,$C8,$3B,$C6 ; F51B BC 26 CC CC 88 C8 3B C6  .&....;.
        .byte   $8C,$99,$99,$BC,$43,$CC,$8C,$C9 ; F523 8C 99 99 BC 43 CC 8C C9  ....C...
        .byte   $1B,$80,$C9,$3B,$C0,$C8,$B9,$42 ; F52B 1B 80 C9 3B C0 C8 B9 42  ...;...B
        .byte   $CC,$88,$A8,$AA,$CC,$6B,$90,$99 ; F533 CC 88 A8 AA CC 6B 90 99  .....k..
        .byte   $C9,$BC,$62,$AA,$BC,$04,$9C,$99 ; F53B C9 BC 62 AA BC 04 9C 99  ..b.....
        .byte   $9C,$BC,$26,$CC,$AA,$BC,$24,$99 ; F543 9C BC 26 CC AA BC 24 99  ..&...$.
        .byte   $BC,$43,$CC,$C8,$99,$9C,$C9,$5B ; F54B BC 43 CC C8 99 9C C9 5B  .C.....[
        .byte   $C6,$9C,$99,$C9,$2B,$A0,$AC,$CA ; F553 C6 9C 99 C9 2B A0 AC CA  ....+...
        .byte   $A8,$BA,$62,$AA,$AA,$5B,$A2,$CC ; F55B A8 BA 62 AA AA 5B A2 CC  ..b..[..
        .byte   $AA,$CA,$BA,$24,$AA,$CA,$C9,$BC ; F563 AA CA BA 24 AA CA C9 BC  ...$....
        .byte   $02,$CC,$88,$A8,$AC,$AA,$4B,$80 ; F56B 02 CC 88 A8 AC AA 4B 80  ......K.
        .byte   $BC,$45,$8C,$9C,$CC,$4B,$C0,$CC ; F573 BC 45 8C 9C CC 4B C0 CC  .E...K..
        .byte   $C8,$CC,$BC,$06,$88,$9C,$C9,$3B ; F57B C8 CC BC 06 88 9C C9 3B  .......;
        .byte   $92,$99,$99,$CC,$3B,$92,$99,$B9 ; F583 92 99 99 CC 3B 92 99 B9  ....;...
        .byte   $02,$8C,$88,$BC,$61,$8C,$CC,$A8 ; F58B 02 8C 88 BC 61 8C CC A8  ....a...
        .byte   $AC,$BA,$42,$8C,$88,$88,$8C,$6B ; F593 AC BA 42 8C 88 88 8C 6B  ..B....k
        .byte   $86,$88,$AC,$AA,$6B,$C4,$88,$9C ; F59B 86 88 AC AA 6B C4 88 9C  ....k...
        .byte   $99,$B9,$00,$AA,$AA,$3B,$82,$BC ; F5A3 99 B9 00 AA AA 3B 82 BC  .....;..
        .byte   $03,$C9,$3B,$C4,$C8,$99,$99,$C9 ; F5AB 03 C9 3B C4 C8 99 99 C9  ..;.....
        .byte   $CA,$AA,$AA,$1B,$C0,$98,$C9,$3B ; F5B3 CA AA AA 1B C0 98 C9 3B  .......;
        .byte   $C4,$C8,$3B,$B6,$66,$98,$CC,$BC ; F5BB C4 C8 3B B6 66 98 CC BC  ..;.f...
        .byte   $00,$AA,$AC,$CC,$8C,$3B,$92,$C9 ; F5C3 00 AA AC CC 8C 3B 92 C9  .....;..
        .byte   $5B,$A6,$AA,$AA,$BC,$62,$AC,$AC ; F5CB 5B A6 AA AA BC 62 AC AC  [....b..
        .byte   $AA,$8C,$C8,$CC,$4B,$84,$99,$C9 ; F5D3 AA 8C C8 CC 4B 84 99 C9  ....K...
        .byte   $B9,$42,$8C,$AC,$AA,$4B,$80,$9C ; F5DB B9 42 8C AC AA 4B 80 9C  .B...K..
        .byte   $99,$99,$BC,$41,$8C,$88,$CA,$AA ; F5E3 99 99 BC 41 8C 88 CA AA  ...A....
        .byte   $AA,$4B,$C4,$98,$99,$99,$BC,$26 ; F5EB AA 4B C4 98 99 99 BC 26  .K.....&
        .byte   $88,$8C,$99,$BC,$23,$A8,$AC,$6B ; F5F3 88 8C 99 BC 23 A8 AC 6B  ....#..k
        .byte   $90,$C9,$99,$0B,$A6,$CC,$0B,$A6 ; F5FB 90 C9 99 0B A6 CC 0B A6  ........
        .byte   $CC,$BC,$61,$88,$BC,$FF,$FF,$FF ; F603 CC BC 61 88 BC FF FF FF  ..a.....
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FD,$FF ; F60B FF FF FF FF FF FF FD FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F613 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$00,$00,$00 ; F61B FF FF FF FF FF 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F623 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F62B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F633 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$FF,$FF,$FF ; F63B 00 00 00 00 00 FF FF FF  ........
        .byte   $FF,$FF,$7F,$FF,$FF,$FF,$FF,$FF ; F643 FF FF 7F FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$F7,$FF,$FF ; F64B FF FF FF FF FF F7 FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F653 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$00,$00,$00 ; F65B FF FF FF FF FF 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F663 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F66B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F673 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$FF,$FF,$FF ; F67B 00 00 00 00 00 FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F683 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F68B FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F693 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$EF,$FF,$00,$00,$00 ; F69B FF FF FF EF FF 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F6A3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F6AB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F6B3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$FF,$FF,$FF ; F6BB 00 00 00 00 00 FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F6C3 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F6CB FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$DF,$FF ; F6D3 FF FF FF FF FF FF DF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$00,$00,$00 ; F6DB FF FF FF FF FF 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F6E3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F6EB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F6F3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$FF,$FF,$FF ; F6FB 00 00 00 00 00 FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$F7,$FF,$FF ; F703 FF FF FF FF FF F7 FF FF  ........
        .byte   $DF,$FF,$FF,$FF,$FF,$FE,$FF,$FF ; F70B DF FF FF FF FF FE FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F713 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$00,$00,$00 ; F71B FF FF FF FF FF 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F723 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F72B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F733 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$FF,$FF,$FF ; F73B 00 00 00 00 00 FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F743 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$DF ; F74B FF FF FF FF FF FF FF DF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F753 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$00,$00,$00 ; F75B FF FF FF FF FF 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F763 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F76B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F773 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$FF,$FF,$FF ; F77B 00 00 00 00 00 FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE ; F783 FF FF FF FF FF FF FF FE  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F78B FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F793 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$00,$00,$00 ; F79B FF FF FF FF FF 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F7A3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F7AB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F7B3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$FF,$FF,$FF ; F7BB 00 00 00 00 00 FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$F7 ; F7C3 FF FF FF FF FF FF FF F7  ........
        .byte   $FF,$FF,$F7,$FF,$FF,$FF,$FF,$FF ; F7CB FF FF F7 FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; F7D3 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$00,$00,$00 ; F7DB FF FF FF FF FF 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F7E3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F7EB 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; F7F3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00             ; F7FB 00 00 00 00 00           .....
; ----------------------------------------------------------------------------
; can be jumped to using 1E/1F
unknownRoutine01:
        lda     $29                             ; F800 A5 29                    .)
        asl     a                               ; F802 0A                       .
        asl     a                               ; F803 0A                       .
        adc     #$20                            ; F804 69 20                    i 
        sta     PPUADDR                         ; F806 8D 06 20                 .. 
        lda     #$CC                            ; F809 A9 CC                    ..
        sta     PPUADDR                         ; F80B 8D 06 20                 .. 
        lda     $030A                           ; F80E AD 0A 03                 ...
        sta     PPUDATA                         ; F811 8D 07 20                 .. 
        lda     $0314                           ; F814 AD 14 03                 ...
        sta     PPUDATA                         ; F817 8D 07 20                 .. 
        lda     $031E                           ; F81A AD 1E 03                 ...
        sta     PPUDATA                         ; F81D 8D 07 20                 .. 
        lda     $0328                           ; F820 AD 28 03                 .(.
        sta     PPUDATA                         ; F823 8D 07 20                 .. 
        lda     $0332                           ; F826 AD 32 03                 .2.
        sta     PPUDATA                         ; F829 8D 07 20                 .. 
        lda     $033C                           ; F82C AD 3C 03                 .<.
        sta     PPUDATA                         ; F82F 8D 07 20                 .. 
        lda     $0346                           ; F832 AD 46 03                 .F.
        sta     PPUDATA                         ; F835 8D 07 20                 .. 
        lda     $0350                           ; F838 AD 50 03                 .P.
        sta     PPUDATA                         ; F83B 8D 07 20                 .. 
        lda     $035A                           ; F83E AD 5A 03                 .Z.
        sta     PPUDATA                         ; F841 8D 07 20                 .. 
        lda     $0364                           ; F844 AD 64 03                 .d.
        sta     PPUDATA                         ; F847 8D 07 20                 .. 
        lda     $036E                           ; F84A AD 6E 03                 .n.
        sta     PPUDATA                         ; F84D 8D 07 20                 .. 
        lda     $0378                           ; F850 AD 78 03                 .x.
        sta     PPUDATA                         ; F853 8D 07 20                 .. 
        lda     $0382                           ; F856 AD 82 03                 ...
        sta     PPUDATA                         ; F859 8D 07 20                 .. 
        lda     $038C                           ; F85C AD 8C 03                 ...
        sta     PPUDATA                         ; F85F 8D 07 20                 .. 
        lda     $0396                           ; F862 AD 96 03                 ...
        sta     PPUDATA                         ; F865 8D 07 20                 .. 
        lda     $03A0                           ; F868 AD A0 03                 ...
        sta     PPUDATA                         ; F86B 8D 07 20                 .. 
        lda     $03AA                           ; F86E AD AA 03                 ...
        sta     PPUDATA                         ; F871 8D 07 20                 .. 
        lda     $03B4                           ; F874 AD B4 03                 ...
        sta     PPUDATA                         ; F877 8D 07 20                 .. 
        lda     $03BE                           ; F87A AD BE 03                 ...
        sta     PPUDATA                         ; F87D 8D 07 20                 .. 
        lda     $03C8                           ; F880 AD C8 03                 ...
        sta     PPUDATA                         ; F883 8D 07 20                 .. 
        lda     $29                             ; F886 A5 29                    .)
        asl     a                               ; F888 0A                       .
        asl     a                               ; F889 0A                       .
        adc     #$20                            ; F88A 69 20                    i 
        sta     PPUADDR                         ; F88C 8D 06 20                 .. 
        lda     #$CD                            ; F88F A9 CD                    ..
        sta     PPUADDR                         ; F891 8D 06 20                 .. 
        lda     $030B                           ; F894 AD 0B 03                 ...
        sta     PPUDATA                         ; F897 8D 07 20                 .. 
        lda     $0315                           ; F89A AD 15 03                 ...
        sta     PPUDATA                         ; F89D 8D 07 20                 .. 
        lda     $031F                           ; F8A0 AD 1F 03                 ...
        sta     PPUDATA                         ; F8A3 8D 07 20                 .. 
        lda     $0329                           ; F8A6 AD 29 03                 .).
        sta     PPUDATA                         ; F8A9 8D 07 20                 .. 
        lda     $0333                           ; F8AC AD 33 03                 .3.
        sta     PPUDATA                         ; F8AF 8D 07 20                 .. 
        lda     $033D                           ; F8B2 AD 3D 03                 .=.
        sta     PPUDATA                         ; F8B5 8D 07 20                 .. 
        lda     $0347                           ; F8B8 AD 47 03                 .G.
        sta     PPUDATA                         ; F8BB 8D 07 20                 .. 
        lda     $0351                           ; F8BE AD 51 03                 .Q.
        sta     PPUDATA                         ; F8C1 8D 07 20                 .. 
        lda     $035B                           ; F8C4 AD 5B 03                 .[.
        sta     PPUDATA                         ; F8C7 8D 07 20                 .. 
        lda     $0365                           ; F8CA AD 65 03                 .e.
        sta     PPUDATA                         ; F8CD 8D 07 20                 .. 
        lda     $036F                           ; F8D0 AD 6F 03                 .o.
        sta     PPUDATA                         ; F8D3 8D 07 20                 .. 
        lda     $0379                           ; F8D6 AD 79 03                 .y.
        sta     PPUDATA                         ; F8D9 8D 07 20                 .. 
        lda     $0383                           ; F8DC AD 83 03                 ...
        sta     PPUDATA                         ; F8DF 8D 07 20                 .. 
        lda     $038D                           ; F8E2 AD 8D 03                 ...
        sta     PPUDATA                         ; F8E5 8D 07 20                 .. 
        lda     $0397                           ; F8E8 AD 97 03                 ...
        sta     PPUDATA                         ; F8EB 8D 07 20                 .. 
        lda     $03A1                           ; F8EE AD A1 03                 ...
        sta     PPUDATA                         ; F8F1 8D 07 20                 .. 
        lda     $03AB                           ; F8F4 AD AB 03                 ...
        sta     PPUDATA                         ; F8F7 8D 07 20                 .. 
        lda     $03B5                           ; F8FA AD B5 03                 ...
        sta     PPUDATA                         ; F8FD 8D 07 20                 .. 
        lda     $03BF                           ; F900 AD BF 03                 ...
        sta     PPUDATA                         ; F903 8D 07 20                 .. 
        lda     $03C9                           ; F906 AD C9 03                 ...
        sta     PPUDATA                         ; F909 8D 07 20                 .. 
        lda     #$1A                            ; F90C A9 1A                    ..
        sta     jmp1E                           ; F90E 85 1E                    ..
        lda     #$F9                            ; F910 A9 F9                    ..
        sta     jmp1E+1                         ; F912 85 1F                    ..
        jsr     LFF2A                           ; F914 20 2A FF                  *.
        jmp     LFF2D                           ; F917 4C 2D FF                 L-.

; ----------------------------------------------------------------------------
; can be jumped to using 1E/1F
unknownRoutine03:
        lda     $29                             ; F91A A5 29                    .)
        asl     a                               ; F91C 0A                       .
        asl     a                               ; F91D 0A                       .
        adc     #$20                            ; F91E 69 20                    i 
        sta     PPUADDR                         ; F920 8D 06 20                 .. 
        lda     #$CE                            ; F923 A9 CE                    ..
        sta     PPUADDR                         ; F925 8D 06 20                 .. 
        lda     $030C                           ; F928 AD 0C 03                 ...
        sta     PPUDATA                         ; F92B 8D 07 20                 .. 
        lda     $0316                           ; F92E AD 16 03                 ...
        sta     PPUDATA                         ; F931 8D 07 20                 .. 
        lda     $0320                           ; F934 AD 20 03                 . .
        sta     PPUDATA                         ; F937 8D 07 20                 .. 
        lda     $032A                           ; F93A AD 2A 03                 .*.
        sta     PPUDATA                         ; F93D 8D 07 20                 .. 
        lda     $0334                           ; F940 AD 34 03                 .4.
        sta     PPUDATA                         ; F943 8D 07 20                 .. 
        lda     $033E                           ; F946 AD 3E 03                 .>.
        sta     PPUDATA                         ; F949 8D 07 20                 .. 
        lda     $0348                           ; F94C AD 48 03                 .H.
        sta     PPUDATA                         ; F94F 8D 07 20                 .. 
        lda     $0352                           ; F952 AD 52 03                 .R.
        sta     PPUDATA                         ; F955 8D 07 20                 .. 
        lda     $035C                           ; F958 AD 5C 03                 .\.
        sta     PPUDATA                         ; F95B 8D 07 20                 .. 
        lda     $0366                           ; F95E AD 66 03                 .f.
        sta     PPUDATA                         ; F961 8D 07 20                 .. 
        lda     $0370                           ; F964 AD 70 03                 .p.
        sta     PPUDATA                         ; F967 8D 07 20                 .. 
        lda     $037A                           ; F96A AD 7A 03                 .z.
        sta     PPUDATA                         ; F96D 8D 07 20                 .. 
        lda     $0384                           ; F970 AD 84 03                 ...
        sta     PPUDATA                         ; F973 8D 07 20                 .. 
        lda     $038E                           ; F976 AD 8E 03                 ...
        sta     PPUDATA                         ; F979 8D 07 20                 .. 
        lda     $0398                           ; F97C AD 98 03                 ...
        sta     PPUDATA                         ; F97F 8D 07 20                 .. 
        lda     $03A2                           ; F982 AD A2 03                 ...
        sta     PPUDATA                         ; F985 8D 07 20                 .. 
        lda     $03AC                           ; F988 AD AC 03                 ...
        sta     PPUDATA                         ; F98B 8D 07 20                 .. 
        lda     $03B6                           ; F98E AD B6 03                 ...
        sta     PPUDATA                         ; F991 8D 07 20                 .. 
        lda     $03C0                           ; F994 AD C0 03                 ...
        sta     PPUDATA                         ; F997 8D 07 20                 .. 
        lda     $03CA                           ; F99A AD CA 03                 ...
        sta     PPUDATA                         ; F99D 8D 07 20                 .. 
        lda     $29                             ; F9A0 A5 29                    .)
        asl     a                               ; F9A2 0A                       .
        asl     a                               ; F9A3 0A                       .
        adc     #$20                            ; F9A4 69 20                    i 
        sta     PPUADDR                         ; F9A6 8D 06 20                 .. 
        lda     #$CF                            ; F9A9 A9 CF                    ..
        sta     PPUADDR                         ; F9AB 8D 06 20                 .. 
        lda     $030D                           ; F9AE AD 0D 03                 ...
        sta     PPUDATA                         ; F9B1 8D 07 20                 .. 
        lda     $0317                           ; F9B4 AD 17 03                 ...
        sta     PPUDATA                         ; F9B7 8D 07 20                 .. 
        lda     $0321                           ; F9BA AD 21 03                 .!.
        sta     PPUDATA                         ; F9BD 8D 07 20                 .. 
        lda     $032B                           ; F9C0 AD 2B 03                 .+.
        sta     PPUDATA                         ; F9C3 8D 07 20                 .. 
        lda     $0335                           ; F9C6 AD 35 03                 .5.
        sta     PPUDATA                         ; F9C9 8D 07 20                 .. 
        lda     $033F                           ; F9CC AD 3F 03                 .?.
        sta     PPUDATA                         ; F9CF 8D 07 20                 .. 
        lda     $0349                           ; F9D2 AD 49 03                 .I.
        sta     PPUDATA                         ; F9D5 8D 07 20                 .. 
        lda     $0353                           ; F9D8 AD 53 03                 .S.
        sta     PPUDATA                         ; F9DB 8D 07 20                 .. 
        lda     $035D                           ; F9DE AD 5D 03                 .].
        sta     PPUDATA                         ; F9E1 8D 07 20                 .. 
        lda     $0367                           ; F9E4 AD 67 03                 .g.
        sta     PPUDATA                         ; F9E7 8D 07 20                 .. 
        lda     $0371                           ; F9EA AD 71 03                 .q.
        sta     PPUDATA                         ; F9ED 8D 07 20                 .. 
        lda     $037B                           ; F9F0 AD 7B 03                 .{.
        sta     PPUDATA                         ; F9F3 8D 07 20                 .. 
        lda     $0385                           ; F9F6 AD 85 03                 ...
        sta     PPUDATA                         ; F9F9 8D 07 20                 .. 
        lda     $038F                           ; F9FC AD 8F 03                 ...
        sta     PPUDATA                         ; F9FF 8D 07 20                 .. 
        lda     $0399                           ; FA02 AD 99 03                 ...
        sta     PPUDATA                         ; FA05 8D 07 20                 .. 
        lda     $03A3                           ; FA08 AD A3 03                 ...
        sta     PPUDATA                         ; FA0B 8D 07 20                 .. 
        lda     $03AD                           ; FA0E AD AD 03                 ...
        sta     PPUDATA                         ; FA11 8D 07 20                 .. 
        lda     $03B7                           ; FA14 AD B7 03                 ...
        sta     PPUDATA                         ; FA17 8D 07 20                 .. 
        lda     $03C1                           ; FA1A AD C1 03                 ...
        sta     PPUDATA                         ; FA1D 8D 07 20                 .. 
        lda     $03CB                           ; FA20 AD CB 03                 ...
        sta     PPUDATA                         ; FA23 8D 07 20                 .. 
        lda     #$34                            ; FA26 A9 34                    .4
        sta     jmp1E                           ; FA28 85 1E                    ..
        lda     #$FA                            ; FA2A A9 FA                    ..
        sta     jmp1E+1                         ; FA2C 85 1F                    ..
        jsr     LFF2A                           ; FA2E 20 2A FF                  *.
        jmp     LFF2D                           ; FA31 4C 2D FF                 L-.

; ----------------------------------------------------------------------------
; can be jumped to using 1E/1F
unknownRoutine04:
        lda     $29                             ; FA34 A5 29                    .)
        asl     a                               ; FA36 0A                       .
        asl     a                               ; FA37 0A                       .
        adc     #$20                            ; FA38 69 20                    i 
        sta     PPUADDR                         ; FA3A 8D 06 20                 .. 
        lda     #$D0                            ; FA3D A9 D0                    ..
        sta     PPUADDR                         ; FA3F 8D 06 20                 .. 
        lda     $030E                           ; FA42 AD 0E 03                 ...
        sta     PPUDATA                         ; FA45 8D 07 20                 .. 
        lda     $0318                           ; FA48 AD 18 03                 ...
        sta     PPUDATA                         ; FA4B 8D 07 20                 .. 
        lda     $0322                           ; FA4E AD 22 03                 .".
        sta     PPUDATA                         ; FA51 8D 07 20                 .. 
        lda     $032C                           ; FA54 AD 2C 03                 .,.
        sta     PPUDATA                         ; FA57 8D 07 20                 .. 
        lda     $0336                           ; FA5A AD 36 03                 .6.
        sta     PPUDATA                         ; FA5D 8D 07 20                 .. 
        lda     $0340                           ; FA60 AD 40 03                 .@.
        sta     PPUDATA                         ; FA63 8D 07 20                 .. 
        lda     $034A                           ; FA66 AD 4A 03                 .J.
        sta     PPUDATA                         ; FA69 8D 07 20                 .. 
        lda     $0354                           ; FA6C AD 54 03                 .T.
        sta     PPUDATA                         ; FA6F 8D 07 20                 .. 
        lda     $035E                           ; FA72 AD 5E 03                 .^.
        sta     PPUDATA                         ; FA75 8D 07 20                 .. 
        lda     $0368                           ; FA78 AD 68 03                 .h.
        sta     PPUDATA                         ; FA7B 8D 07 20                 .. 
        lda     $0372                           ; FA7E AD 72 03                 .r.
        sta     PPUDATA                         ; FA81 8D 07 20                 .. 
        lda     $037C                           ; FA84 AD 7C 03                 .|.
        sta     PPUDATA                         ; FA87 8D 07 20                 .. 
        lda     $0386                           ; FA8A AD 86 03                 ...
        sta     PPUDATA                         ; FA8D 8D 07 20                 .. 
        lda     $0390                           ; FA90 AD 90 03                 ...
        sta     PPUDATA                         ; FA93 8D 07 20                 .. 
        lda     $039A                           ; FA96 AD 9A 03                 ...
        sta     PPUDATA                         ; FA99 8D 07 20                 .. 
        lda     $03A4                           ; FA9C AD A4 03                 ...
        sta     PPUDATA                         ; FA9F 8D 07 20                 .. 
        lda     $03AE                           ; FAA2 AD AE 03                 ...
        sta     PPUDATA                         ; FAA5 8D 07 20                 .. 
        lda     $03B8                           ; FAA8 AD B8 03                 ...
        sta     PPUDATA                         ; FAAB 8D 07 20                 .. 
        lda     $03C2                           ; FAAE AD C2 03                 ...
        sta     PPUDATA                         ; FAB1 8D 07 20                 .. 
        lda     $03CC                           ; FAB4 AD CC 03                 ...
        sta     PPUDATA                         ; FAB7 8D 07 20                 .. 
        lda     $29                             ; FABA A5 29                    .)
        asl     a                               ; FABC 0A                       .
        asl     a                               ; FABD 0A                       .
        adc     #$20                            ; FABE 69 20                    i 
        sta     PPUADDR                         ; FAC0 8D 06 20                 .. 
        lda     #$D1                            ; FAC3 A9 D1                    ..
        sta     PPUADDR                         ; FAC5 8D 06 20                 .. 
        lda     $030F                           ; FAC8 AD 0F 03                 ...
        sta     PPUDATA                         ; FACB 8D 07 20                 .. 
        lda     $0319                           ; FACE AD 19 03                 ...
        sta     PPUDATA                         ; FAD1 8D 07 20                 .. 
        lda     $0323                           ; FAD4 AD 23 03                 .#.
        sta     PPUDATA                         ; FAD7 8D 07 20                 .. 
        lda     $032D                           ; FADA AD 2D 03                 .-.
        sta     PPUDATA                         ; FADD 8D 07 20                 .. 
        lda     $0337                           ; FAE0 AD 37 03                 .7.
        sta     PPUDATA                         ; FAE3 8D 07 20                 .. 
        lda     $0341                           ; FAE6 AD 41 03                 .A.
        sta     PPUDATA                         ; FAE9 8D 07 20                 .. 
        lda     $034B                           ; FAEC AD 4B 03                 .K.
        sta     PPUDATA                         ; FAEF 8D 07 20                 .. 
        lda     $0355                           ; FAF2 AD 55 03                 .U.
        sta     PPUDATA                         ; FAF5 8D 07 20                 .. 
        lda     $035F                           ; FAF8 AD 5F 03                 ._.
        sta     PPUDATA                         ; FAFB 8D 07 20                 .. 
        lda     $0369                           ; FAFE AD 69 03                 .i.
        sta     PPUDATA                         ; FB01 8D 07 20                 .. 
        lda     $0373                           ; FB04 AD 73 03                 .s.
        sta     PPUDATA                         ; FB07 8D 07 20                 .. 
        lda     $037D                           ; FB0A AD 7D 03                 .}.
        sta     PPUDATA                         ; FB0D 8D 07 20                 .. 
        lda     $0387                           ; FB10 AD 87 03                 ...
        sta     PPUDATA                         ; FB13 8D 07 20                 .. 
        lda     $0391                           ; FB16 AD 91 03                 ...
        sta     PPUDATA                         ; FB19 8D 07 20                 .. 
        lda     $039B                           ; FB1C AD 9B 03                 ...
        sta     PPUDATA                         ; FB1F 8D 07 20                 .. 
        lda     $03A5                           ; FB22 AD A5 03                 ...
        sta     PPUDATA                         ; FB25 8D 07 20                 .. 
        lda     $03AF                           ; FB28 AD AF 03                 ...
        sta     PPUDATA                         ; FB2B 8D 07 20                 .. 
        lda     $03B9                           ; FB2E AD B9 03                 ...
        sta     PPUDATA                         ; FB31 8D 07 20                 .. 
        lda     $03C3                           ; FB34 AD C3 03                 ...
        sta     PPUDATA                         ; FB37 8D 07 20                 .. 
        lda     $03CD                           ; FB3A AD CD 03                 ...
        sta     PPUDATA                         ; FB3D 8D 07 20                 .. 
        lda     #$4E                            ; FB40 A9 4E                    .N
        sta     jmp1E                           ; FB42 85 1E                    ..
        lda     #$FB                            ; FB44 A9 FB                    ..
        sta     jmp1E+1                         ; FB46 85 1F                    ..
        jsr     LFF2A                           ; FB48 20 2A FF                  *.
        jmp     LFF2D                           ; FB4B 4C 2D FF                 L-.

; ----------------------------------------------------------------------------
; can be jumped to using 1E/1F
unknownRoutine05:
        lda     $29                             ; FB4E A5 29                    .)
        asl     a                               ; FB50 0A                       .
        asl     a                               ; FB51 0A                       .
        adc     #$20                            ; FB52 69 20                    i 
        sta     PPUADDR                         ; FB54 8D 06 20                 .. 
        lda     #$D2                            ; FB57 A9 D2                    ..
        sta     PPUADDR                         ; FB59 8D 06 20                 .. 
        lda     $0310                           ; FB5C AD 10 03                 ...
        sta     PPUDATA                         ; FB5F 8D 07 20                 .. 
        lda     $031A                           ; FB62 AD 1A 03                 ...
        sta     PPUDATA                         ; FB65 8D 07 20                 .. 
        lda     $0324                           ; FB68 AD 24 03                 .$.
        sta     PPUDATA                         ; FB6B 8D 07 20                 .. 
        lda     $032E                           ; FB6E AD 2E 03                 ...
        sta     PPUDATA                         ; FB71 8D 07 20                 .. 
        lda     $0338                           ; FB74 AD 38 03                 .8.
        sta     PPUDATA                         ; FB77 8D 07 20                 .. 
        lda     $0342                           ; FB7A AD 42 03                 .B.
        sta     PPUDATA                         ; FB7D 8D 07 20                 .. 
        lda     $034C                           ; FB80 AD 4C 03                 .L.
        sta     PPUDATA                         ; FB83 8D 07 20                 .. 
        lda     $0356                           ; FB86 AD 56 03                 .V.
        sta     PPUDATA                         ; FB89 8D 07 20                 .. 
        lda     $0360                           ; FB8C AD 60 03                 .`.
        sta     PPUDATA                         ; FB8F 8D 07 20                 .. 
        lda     $036A                           ; FB92 AD 6A 03                 .j.
        sta     PPUDATA                         ; FB95 8D 07 20                 .. 
        lda     $0374                           ; FB98 AD 74 03                 .t.
        sta     PPUDATA                         ; FB9B 8D 07 20                 .. 
        lda     $037E                           ; FB9E AD 7E 03                 .~.
        sta     PPUDATA                         ; FBA1 8D 07 20                 .. 
        lda     $0388                           ; FBA4 AD 88 03                 ...
        sta     PPUDATA                         ; FBA7 8D 07 20                 .. 
        lda     $0392                           ; FBAA AD 92 03                 ...
        sta     PPUDATA                         ; FBAD 8D 07 20                 .. 
        lda     $039C                           ; FBB0 AD 9C 03                 ...
        sta     PPUDATA                         ; FBB3 8D 07 20                 .. 
        lda     $03A6                           ; FBB6 AD A6 03                 ...
        sta     PPUDATA                         ; FBB9 8D 07 20                 .. 
        lda     $03B0                           ; FBBC AD B0 03                 ...
        sta     PPUDATA                         ; FBBF 8D 07 20                 .. 
        lda     $03BA                           ; FBC2 AD BA 03                 ...
        sta     PPUDATA                         ; FBC5 8D 07 20                 .. 
        lda     $03C4                           ; FBC8 AD C4 03                 ...
        sta     PPUDATA                         ; FBCB 8D 07 20                 .. 
        lda     $03CE                           ; FBCE AD CE 03                 ...
        sta     PPUDATA                         ; FBD1 8D 07 20                 .. 
        lda     $29                             ; FBD4 A5 29                    .)
        asl     a                               ; FBD6 0A                       .
        asl     a                               ; FBD7 0A                       .
        adc     #$20                            ; FBD8 69 20                    i 
        sta     PPUADDR                         ; FBDA 8D 06 20                 .. 
        lda     #$D3                            ; FBDD A9 D3                    ..
        sta     PPUADDR                         ; FBDF 8D 06 20                 .. 
        lda     $0311                           ; FBE2 AD 11 03                 ...
        sta     PPUDATA                         ; FBE5 8D 07 20                 .. 
        lda     $031B                           ; FBE8 AD 1B 03                 ...
        sta     PPUDATA                         ; FBEB 8D 07 20                 .. 
        lda     $0325                           ; FBEE AD 25 03                 .%.
        sta     PPUDATA                         ; FBF1 8D 07 20                 .. 
        lda     $032F                           ; FBF4 AD 2F 03                 ./.
        sta     PPUDATA                         ; FBF7 8D 07 20                 .. 
        lda     $0339                           ; FBFA AD 39 03                 .9.
        sta     PPUDATA                         ; FBFD 8D 07 20                 .. 
        lda     $0343                           ; FC00 AD 43 03                 .C.
        sta     PPUDATA                         ; FC03 8D 07 20                 .. 
        lda     $034D                           ; FC06 AD 4D 03                 .M.
        sta     PPUDATA                         ; FC09 8D 07 20                 .. 
        lda     $0357                           ; FC0C AD 57 03                 .W.
        sta     PPUDATA                         ; FC0F 8D 07 20                 .. 
        lda     $0361                           ; FC12 AD 61 03                 .a.
        sta     PPUDATA                         ; FC15 8D 07 20                 .. 
        lda     $036B                           ; FC18 AD 6B 03                 .k.
        sta     PPUDATA                         ; FC1B 8D 07 20                 .. 
        lda     $0375                           ; FC1E AD 75 03                 .u.
        sta     PPUDATA                         ; FC21 8D 07 20                 .. 
        lda     $037F                           ; FC24 AD 7F 03                 ...
        sta     PPUDATA                         ; FC27 8D 07 20                 .. 
        lda     $0389                           ; FC2A AD 89 03                 ...
        sta     PPUDATA                         ; FC2D 8D 07 20                 .. 
        lda     $0393                           ; FC30 AD 93 03                 ...
        sta     PPUDATA                         ; FC33 8D 07 20                 .. 
        lda     $039D                           ; FC36 AD 9D 03                 ...
        sta     PPUDATA                         ; FC39 8D 07 20                 .. 
        lda     $03A7                           ; FC3C AD A7 03                 ...
        sta     PPUDATA                         ; FC3F 8D 07 20                 .. 
        lda     $03B1                           ; FC42 AD B1 03                 ...
        sta     PPUDATA                         ; FC45 8D 07 20                 .. 
        lda     $03BB                           ; FC48 AD BB 03                 ...
        sta     PPUDATA                         ; FC4B 8D 07 20                 .. 
        lda     $03C5                           ; FC4E AD C5 03                 ...
        sta     PPUDATA                         ; FC51 8D 07 20                 .. 
        lda     $03CF                           ; FC54 AD CF 03                 ...
        sta     PPUDATA                         ; FC57 8D 07 20                 .. 
        lda     #$68                            ; FC5A A9 68                    .h
        sta     jmp1E                           ; FC5C 85 1E                    ..
        lda     #$FC                            ; FC5E A9 FC                    ..
        sta     jmp1E+1                         ; FC60 85 1F                    ..
        jsr     LFF2A                           ; FC62 20 2A FF                  *.
        jmp     LFF2D                           ; FC65 4C 2D FF                 L-.

; ----------------------------------------------------------------------------
; can be jumped to using 1E/1F
unknownRoutine06:
        lda     $29                             ; FC68 A5 29                    .)
        asl     a                               ; FC6A 0A                       .
        asl     a                               ; FC6B 0A                       .
        adc     #$20                            ; FC6C 69 20                    i 
        sta     PPUADDR                         ; FC6E 8D 06 20                 .. 
        lda     #$D4                            ; FC71 A9 D4                    ..
        sta     PPUADDR                         ; FC73 8D 06 20                 .. 
        lda     $0312                           ; FC76 AD 12 03                 ...
        sta     PPUDATA                         ; FC79 8D 07 20                 .. 
        lda     $031C                           ; FC7C AD 1C 03                 ...
        sta     PPUDATA                         ; FC7F 8D 07 20                 .. 
        lda     $0326                           ; FC82 AD 26 03                 .&.
        sta     PPUDATA                         ; FC85 8D 07 20                 .. 
        lda     $0330                           ; FC88 AD 30 03                 .0.
        sta     PPUDATA                         ; FC8B 8D 07 20                 .. 
        lda     $033A                           ; FC8E AD 3A 03                 .:.
        sta     PPUDATA                         ; FC91 8D 07 20                 .. 
        lda     $0344                           ; FC94 AD 44 03                 .D.
        sta     PPUDATA                         ; FC97 8D 07 20                 .. 
        lda     $034E                           ; FC9A AD 4E 03                 .N.
        sta     PPUDATA                         ; FC9D 8D 07 20                 .. 
        lda     $0358                           ; FCA0 AD 58 03                 .X.
        sta     PPUDATA                         ; FCA3 8D 07 20                 .. 
        lda     $0362                           ; FCA6 AD 62 03                 .b.
        sta     PPUDATA                         ; FCA9 8D 07 20                 .. 
        lda     $036C                           ; FCAC AD 6C 03                 .l.
        sta     PPUDATA                         ; FCAF 8D 07 20                 .. 
        lda     $0376                           ; FCB2 AD 76 03                 .v.
        sta     PPUDATA                         ; FCB5 8D 07 20                 .. 
        lda     $0380                           ; FCB8 AD 80 03                 ...
        sta     PPUDATA                         ; FCBB 8D 07 20                 .. 
        lda     $038A                           ; FCBE AD 8A 03                 ...
        sta     PPUDATA                         ; FCC1 8D 07 20                 .. 
        lda     $0394                           ; FCC4 AD 94 03                 ...
        sta     PPUDATA                         ; FCC7 8D 07 20                 .. 
        lda     $039E                           ; FCCA AD 9E 03                 ...
        sta     PPUDATA                         ; FCCD 8D 07 20                 .. 
        lda     $03A8                           ; FCD0 AD A8 03                 ...
        sta     PPUDATA                         ; FCD3 8D 07 20                 .. 
        lda     $03B2                           ; FCD6 AD B2 03                 ...
        sta     PPUDATA                         ; FCD9 8D 07 20                 .. 
        lda     $03BC                           ; FCDC AD BC 03                 ...
        sta     PPUDATA                         ; FCDF 8D 07 20                 .. 
        lda     $03C6                           ; FCE2 AD C6 03                 ...
        sta     PPUDATA                         ; FCE5 8D 07 20                 .. 
        lda     $03D0                           ; FCE8 AD D0 03                 ...
        sta     PPUDATA                         ; FCEB 8D 07 20                 .. 
        lda     $29                             ; FCEE A5 29                    .)
        asl     a                               ; FCF0 0A                       .
        asl     a                               ; FCF1 0A                       .
        adc     #$20                            ; FCF2 69 20                    i 
        sta     PPUADDR                         ; FCF4 8D 06 20                 .. 
        lda     #$D5                            ; FCF7 A9 D5                    ..
        sta     PPUADDR                         ; FCF9 8D 06 20                 .. 
        lda     $0313                           ; FCFC AD 13 03                 ...
        sta     PPUDATA                         ; FCFF 8D 07 20                 .. 
        lda     $031D                           ; FD02 AD 1D 03                 ...
        sta     PPUDATA                         ; FD05 8D 07 20                 .. 
        lda     $0327                           ; FD08 AD 27 03                 .'.
        sta     PPUDATA                         ; FD0B 8D 07 20                 .. 
        lda     $0331                           ; FD0E AD 31 03                 .1.
        sta     PPUDATA                         ; FD11 8D 07 20                 .. 
        lda     $033B                           ; FD14 AD 3B 03                 .;.
        sta     PPUDATA                         ; FD17 8D 07 20                 .. 
        lda     $0345                           ; FD1A AD 45 03                 .E.
        sta     PPUDATA                         ; FD1D 8D 07 20                 .. 
        lda     $034F                           ; FD20 AD 4F 03                 .O.
        sta     PPUDATA                         ; FD23 8D 07 20                 .. 
        lda     $0359                           ; FD26 AD 59 03                 .Y.
        sta     PPUDATA                         ; FD29 8D 07 20                 .. 
        lda     $0363                           ; FD2C AD 63 03                 .c.
        sta     PPUDATA                         ; FD2F 8D 07 20                 .. 
        lda     $036D                           ; FD32 AD 6D 03                 .m.
        sta     PPUDATA                         ; FD35 8D 07 20                 .. 
        lda     $0377                           ; FD38 AD 77 03                 .w.
        sta     PPUDATA                         ; FD3B 8D 07 20                 .. 
        lda     $0381                           ; FD3E AD 81 03                 ...
        sta     PPUDATA                         ; FD41 8D 07 20                 .. 
        lda     $038B                           ; FD44 AD 8B 03                 ...
        sta     PPUDATA                         ; FD47 8D 07 20                 .. 
        lda     $0395                           ; FD4A AD 95 03                 ...
        sta     PPUDATA                         ; FD4D 8D 07 20                 .. 
        lda     $039F                           ; FD50 AD 9F 03                 ...
        sta     PPUDATA                         ; FD53 8D 07 20                 .. 
        lda     $03A9                           ; FD56 AD A9 03                 ...
        sta     PPUDATA                         ; FD59 8D 07 20                 .. 
        lda     $03B3                           ; FD5C AD B3 03                 ...
        sta     PPUDATA                         ; FD5F 8D 07 20                 .. 
        lda     $03BD                           ; FD62 AD BD 03                 ...
        sta     PPUDATA                         ; FD65 8D 07 20                 .. 
        lda     $03C7                           ; FD68 AD C7 03                 ...
        sta     PPUDATA                         ; FD6B 8D 07 20                 .. 
        lda     $03D1                           ; FD6E AD D1 03                 ...
        sta     PPUDATA                         ; FD71 8D 07 20                 .. 
        lda     #$30                            ; FD74 A9 30                    .0
        sta     jmp1E                           ; FD76 85 1E                    ..
        lda     #$FF                            ; FD78 A9 FF                    ..
        sta     jmp1E+1                         ; FD7A 85 1F                    ..
        lda     #$00                            ; FD7C A9 00                    ..
        sta     $35                             ; FD7E 85 35                    .5
        jsr     LFF2A                           ; FD80 20 2A FF                  *.
        jmp     LFF2D                           ; FD83 4C 2D FF                 L-.

; ----------------------------------------------------------------------------
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FD86 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$06 ; FD8E 00 00 00 00 00 00 00 06  ........
        .byte   $06,$00,$00,$06,$06,$00,$00,$00 ; FD96 06 00 00 06 06 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$02 ; FD9E 00 00 00 00 00 00 00 02  ........
        .byte   $02,$00,$00,$00,$02,$02,$00,$00 ; FDA6 02 00 00 00 02 02 00 00  ........
        .byte   $00,$00,$00,$00,$00,$02,$00,$00 ; FDAE 00 00 00 00 00 02 00 00  ........
        .byte   $02,$02,$00,$00,$02,$00,$00,$00 ; FDB6 02 02 00 00 02 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FDBE 00 00 00 00 00 00 00 00  ........
        .byte   $04,$00,$04,$04,$04,$00,$00,$00 ; FDC6 04 00 04 04 04 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$04,$04 ; FDCE 00 00 00 00 00 00 04 04  ........
        .byte   $00,$00,$00,$04,$00,$00,$00,$04 ; FDD6 00 00 00 04 00 00 00 04  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FDDE 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$04,$04,$04,$00,$04,$00 ; FDE6 00 00 04 04 04 00 04 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$04 ; FDEE 00 00 00 00 00 00 00 04  ........
        .byte   $00,$00,$00,$04,$00,$00,$00,$04 ; FDF6 00 00 00 04 00 00 00 04  ........
        .byte   $04,$00,$00,$00,$00,$00,$00,$00 ; FDFE 04 00 00 00 00 00 00 00  ........
        .byte   $01,$01,$00,$01,$01,$00,$00,$00 ; FE06 01 01 00 01 01 00 00 00  ........
        .byte   $00,$00,$00,$00,$01,$00,$00,$00 ; FE0E 00 00 00 00 01 00 00 00  ........
        .byte   $01,$01,$00,$00,$00,$01,$00,$00 ; FE16 01 01 00 00 00 01 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$03,$00 ; FE1E 00 00 00 00 00 00 03 00  ........
        .byte   $00,$00,$03,$03,$03,$00,$00,$00 ; FE26 00 00 03 03 03 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$03 ; FE2E 00 00 00 00 00 00 00 03  ........
        .byte   $00,$00,$00,$03,$00,$00,$03,$03 ; FE36 00 00 00 03 00 00 03 03  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FE3E 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$03,$03,$03,$00,$00,$00 ; FE46 00 00 03 03 03 00 00 00  ........
        .byte   $03,$00,$00,$00,$00,$00,$00,$03 ; FE4E 03 00 00 00 00 00 00 03  ........
        .byte   $03,$00,$00,$03,$00,$00,$00,$03 ; FE56 03 00 00 03 00 00 00 03  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$05 ; FE5E 00 00 00 00 00 00 00 05  ........
        .byte   $00,$00,$00,$05,$05,$00,$00,$05 ; FE66 00 00 00 05 05 00 00 05  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$05 ; FE6E 00 00 00 00 00 00 00 05  ........
        .byte   $00,$00,$05,$05,$05,$00,$00,$00 ; FE76 00 00 05 05 05 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$05 ; FE7E 00 00 00 00 00 00 00 05  ........
        .byte   $00,$00,$05,$05,$00,$00,$00,$05 ; FE86 00 00 05 05 00 00 00 05  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FE8E 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$05,$05,$05,$00,$00,$05 ; FE96 00 00 05 05 05 00 00 05  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FE9E 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$0A,$0B,$0B,$0C,$00,$00 ; FEA6 00 00 0A 0B 0B 0C 00 00  ........
        .byte   $00,$00,$00,$07,$00,$00,$00,$08 ; FEAE 00 00 00 07 00 00 00 08  ........
        .byte   $00,$00,$00,$08,$00,$00,$00,$09 ; FEB6 00 00 00 08 00 00 00 09  ........
        .byte   $00,$00                         ; FEBE 00 00                    ..
LFEC0:
        .byte   $90                             ; FEC0 90                       .
LFEC1:
        .byte   $FD,$90,$FD,$90,$FD,$90,$FD,$C0 ; FEC1 FD 90 FD 90 FD 90 FD C0  ........
        .byte   $FD,$D0,$FD,$E0,$FD,$F0,$FD,$20 ; FEC9 FD D0 FD E0 FD F0 FD 20  ....... 
        .byte   $FE,$30,$FE,$40,$FE,$50,$FE,$00 ; FED1 FE 30 FE 40 FE 50 FE 00  .0.@.P..
        .byte   $FE,$10,$FE,$00,$FE,$10,$FE,$A0 ; FED9 FE 10 FE 00 FE 10 FE A0  ........
        .byte   $FD,$B0,$FD,$A0,$FD,$B0,$FD,$A0 ; FEE1 FD B0 FD A0 FD B0 FD A0  ........
        .byte   $FE,$B0,$FE,$A0,$FE,$B0,$FE,$60 ; FEE9 FE B0 FE A0 FE B0 FE 60  .......`
        .byte   $FE,$70,$FE,$80,$FE,$90,$FE,$BD ; FEF1 FE 70 FE 80 FE 90 FE BD  .p......
        .byte   $4E,$FF,$FF,$FF,$00,$FF,$F8     ; FEF9 4E FF FF FF 00 FF F8     N......
; ----------------------------------------------------------------------------
LFF00:
        jmp     L9092                           ; FF00 4C 92 90                 L..

; ----------------------------------------------------------------------------
LFF03:
        jmp     L9059                           ; FF03 4C 59 90                 LY.

; ----------------------------------------------------------------------------
        jmp     L9054                           ; FF06 4C 54 90                 LT.

; ----------------------------------------------------------------------------
LFF09:
        jmp     L902E                           ; FF09 4C 2E 90                 L..

; ----------------------------------------------------------------------------
LFF0C:
        jmp     L92DD                           ; FF0C 4C DD 92                 L..

; ----------------------------------------------------------------------------
        jmp     L93C6                           ; FF0F 4C C6 93                 L..

; ----------------------------------------------------------------------------
LFF12:
        jmp     L8FCE                           ; FF12 4C CE 8F                 L..

; ----------------------------------------------------------------------------
        jmp     L9323                           ; FF15 4C 23 93                 L#.

; ----------------------------------------------------------------------------
        jmp     L8353                           ; FF18 4C 53 83                 LS.

; ----------------------------------------------------------------------------
        jmp     L908C                           ; FF1B 4C 8C 90                 L..

; ----------------------------------------------------------------------------
LFF1E:
        jmp     LC3CB                           ; FF1E 4C CB C3                 L..

; ----------------------------------------------------------------------------
LFF21:
        jmp     L8341                           ; FF21 4C 41 83                 LA.

; ----------------------------------------------------------------------------
        jmp     L8F97                           ; FF24 4C 97 8F                 L..

; ----------------------------------------------------------------------------
LFF27:
        jmp     L90F9                           ; FF27 4C F9 90                 L..

; ----------------------------------------------------------------------------
LFF2A:
        jmp     L802C                           ; FF2A 4C 2C 80                 L,.

; ----------------------------------------------------------------------------
LFF2D:
        jmp     L804F                           ; FF2D 4C 4F 80                 LO.

; ----------------------------------------------------------------------------
; can be jumped to using 1E/1F
unknownRoutine07:
        jmp     unknownRoutine02                ; FF30 4C 86 80                 L..

; ----------------------------------------------------------------------------
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF33 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$40,$00,$00,$00 ; FF3B 00 00 00 00 40 00 00 00  ....@...
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF43 00 00 00 00 00 00 00 00  ........
        .byte   $01,$00,$00,$00,$00,$00,$00,$00 ; FF4B 01 00 00 00 00 00 00 00  ........
        .byte   $00,$8C,$20,$81,$61,$00,$00,$00 ; FF53 00 8C 20 81 61 00 00 00  .. .a...
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF5B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF63 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF6B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF73 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF7B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF83 00 00 00 00 00 00 00 00  ........
        .byte   $00,$04,$00,$00,$00,$00,$80,$00 ; FF8B 00 04 00 00 00 00 80 00  ........
        .byte   $00,$20,$F1,$90,$A2,$00,$00,$00 ; FF93 00 20 F1 90 A2 00 00 00  . ......
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF9B 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FFA3 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00             ; FFAB 00 00 00 00 00           .....
LFFB0:
        .byte   $00,$00,$00,$00,$00,$08,$00,$00 ; FFB0 00 00 00 00 00 08 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FFB8 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FFC0 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$04,$00,$00 ; FFC8 00 00 00 00 00 04 00 00  ........
        .byte   $00,$00,$00,$00,$80,$39,$04,$10 ; FFD0 00 00 00 00 80 39 04 10  .....9..
        .byte   $00,$00,$00,$00,$00,$01,$00,$01 ; FFD8 00 00 00 00 00 01 00 01  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FFE0 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$01,$FF,$00 ; FFE8 00 00 00 00 00 01 FF 00  ........
        .byte   $01,$00,$00,$00,$89,$80,$A5,$04 ; FFF0 01 00 00 00 89 80 A5 04  ........
        .byte   $53,$80                         ; FFF8 53 80                    S.
; ----------------------------------------------------------------------------

.segment        "VECTORS": absolute

LFFFA:
        .addr   nmi                             ; FFFA 04 80                    ..
        .addr   reset                           ; FFFC 00 80                    ..
        .addr   irq                             ; FFFE 03 80                    ..

; End of "VECTORS" segment
; ----------------------------------------------------------------------------
.code

