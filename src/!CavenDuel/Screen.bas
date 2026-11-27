1 REM >Screen
2 REM Cavern Duel's screen, loaded by Game with LIBRARY
3 REM The game is drawn as MODE 12: 1280x1024 graphics units, 640x256 pixels, 16 colours. It draws into a sprite in that mode,
4 REM which is shown scaled up in the middle of the screen, in whatever mode the desktop is in.
5 REM The game's palette goes into the colour table the sprite is shown with, so the screen's own palette never changes, and a fade shows the sprite darker.
6 REM The game changes to MODE 12 itself, with two screen banks and the palette set there, as it always did:
7 REM if CavernDuel$Screen is MODE12, before RISC OS 3.5, or if the screen is too slow to show the sprite quickly.
8 REM The sprite is shown at a whole multiple of its pixels, as RISC OS scales by repeating pixels: other sizes draw some pixels bigger than others. CavernDuel$Screen set to Fill makes it as big as fits instead
9 :
10 DEF PROCscr_init:REM Set up, before anything else, so that errors can be shown. The screen stays as the desktop left it until PROCscr_open
11 LOCAL i%
12 DIM scr_pal% 63,scr_dim% 63,scr_tab% 1023,scr_scale% 15,scr_sel% 255
13 scr_direct%=TRUE:scr_level%=16:scr_tabok%=FALSE:scr_last%=0:scr_s1%=1:scr_s2%=2:scr_fill%=FALSE
14 FOR i%=0 TO 60 STEP 4:scr_pal%!i%=0:NEXT
15 ENDPROC
16 :
17 DEF PROCscr_open:REM Choose how to show the game, and start drawing
18 LOCAL f%,m%,v$
19 v$=FNscr_var("CavernDuel$Screen"):scr_fill%=(v$="FILL" OR v$="Fill" OR v$="fill"):REM Fill: as big as fits, though pixels then differ in size
20 IF v$<>"MODE12" AND v$<>"Mode12" AND v$<>"mode12" THEN SYS &20065,1 TO ,m%;f%:IF (f% AND 1)=0 THEN PROCscr_sprite(m%):REM XOS_ScreenMode 1 reads the mode; it is missing before RISC OS 3.5
21 IF scr_direct% THEN MODE 128+12:MODE 12
22 ENDPROC
23 :
24 DEF PROCscr_sprite(m%):REM Show the game in a sprite in the desktop's mode, m% (a number or a mode selector). scr_direct% stays TRUE if this can't be done
25 LOCAL f%,i%,t%
26 IF m%>=256 THEN PROCscr_copysel(m%) ELSE scr_mode%=m%
27 DIM scr_area% 82000:!scr_area%=82000:scr_area%!8=16:SYS "OS_SpriteOp",&109,scr_area%
28 SYS "XOS_SpriteOp",&10F,scr_area%,"game",0,640,256,12 TO ;f%:IF f% AND 1 THEN ENDPROC
29 SYS "OS_SpriteOp",&13E,scr_area%,"game" TO ,,,i%:DIM scr_save% i%+4:!scr_save%=0:REM Keeps the sprite's colours, text size and so on while output is on the screen
30 PROCscr_measure:VDU 26:SYS "ColourTrans_SetGCOL",0,,,&80,0:CLG:OFF:MOUSE RECTANGLE scr_x%,scr_y%,scr_w%-1,scr_h%-1
31 SYS "OS_SpriteOp",&13C,scr_area%,"game",scr_save% TO scr_r0%,scr_r1%,scr_r2%,scr_r3%:REM Restoring these puts output back on the screen
32 scr_direct%=FALSE:scr_level%=0:VDU 26:COLOUR 135:CLS
33 t%=TIME:FOR i%=1 TO 10:PROCscr_show:NEXT:REM Black, as the palette is
34 IF TIME-t%>25 THEN SYS "OS_SpriteOp",scr_r0%,scr_r1%,scr_r2%,scr_r3%:scr_direct%=TRUE:REM Too slow: over half of each frame's 5cs
35 ENDPROC
36 :
40 DEF PROCscr_copysel(m%):REM Keep a copy of the mode selector at m%, to go back to at the end
41 LOCAL i%
42 FOR i%=0 TO 16 STEP 4:scr_sel%!i%=m%!i%:NEXT
43 WHILE m%!i%<>-1 AND i%<240:scr_sel%!i%=m%!i%:scr_sel%!(i%+4)=m%!(i%+4):i%+=8:ENDWHILE
44 scr_sel%!i%=-1:scr_mode%=scr_sel%
45 ENDPROC
46 :
50 DEF PROCscr_measure:REM Where the game goes on the screen, in graphics units. Normally the largest whole multiple of its pixels that fits, shaped from 5:4 to 10:7, so every pixel is drawn the same size; with Fill, or if none fits, as big as fits
51 LOCAL xe%,ye%,xp%,yp%,w%,h%,kx%,ky%,a%,b%,c%
52 SYS "OS_ReadModeVariable",-1,4 TO ,,xe%:SYS "OS_ReadModeVariable",-1,5 TO ,,ye%:SYS "OS_ReadModeVariable",-1,11 TO ,,xp%:SYS "OS_ReadModeVariable",-1,12 TO ,,yp%
53 w%=(xp%+1)<<xe%:h%=(yp%+1)<<ye%:a%=0
54 FOR kx%=1 TO 16:FOR ky%=1 TO 32:b%=(640*kx%)<<xe%:c%=(256*ky%)<<ye%:IF NOT scr_fill% AND 640*kx%<=xp%+1 AND 256*ky%<=yp%+1 AND 4*b%>=5*c% AND 7*b%<=10*c% AND kx%*ky%>a% THEN a%=kx%*ky%:scr_w%=b%:scr_h%=c%
55 NEXT:NEXT
56 IF a%=0 THEN scr_w%=w%:scr_h%=w%*1024 DIV 1280:IF scr_h%>h% THEN scr_h%=h%:scr_w%=h%*1280 DIV 1024
57 scr_w%=(scr_w%>>xe%)<<xe%:scr_h%=(scr_h%>>ye%)<<ye%:scr_x%=(((w%-scr_w%) DIV 2)>>xe%)<<xe%:scr_y%=(((h%-scr_h%) DIV 2)>>ye%)<<ye%
58 scr_scale%!0=scr_w%>>xe%:scr_scale%!4=scr_h%>>ye%:scr_scale%!8=640:scr_scale%!12=256:REM x then y multipliers, then x and y divisors, in pixels
59 ENDPROC
60 DEF PROCscr_show:REM Put the picture on the screen
61 IF scr_direct% THEN ENDPROC
62 SYS "OS_SpriteOp",scr_r0%,scr_r1%,scr_r2%,scr_r3%
63 IF NOT scr_tabok% THEN PROCscr_table
64 SYS "OS_SpriteOp",&134,scr_area%,"game",scr_x%,scr_y%,0,scr_scale%,scr_tab%
65 SYS "OS_SpriteOp",&13C,scr_area%,"game",scr_save%
66 scr_last%=TIME
67 ENDPROC
68 :
70 DEF PROCscr_table:REM The colour table to show the picture with: the game's palette at scr_level% sixteenths of its brightness. Output must be on the screen, for its colours
71 LOCAL i%
72 FOR i%=0 TO 60 STEP 4:scr_dim%!i%=FNscr_dim(scr_pal%!i%,scr_level%):NEXT
73 SYS "ColourTrans_SelectTable",12,scr_dim%,-1,-1,scr_tab%
74 scr_tabok%=TRUE
75 ENDPROC
76 :
80 DEF FNscr_dim(c%,l%):REM Palette entry c% (&BBGGRR00) at l% sixteenths of its brightness
81 =((((c%>>>24) AND 255)*l% DIV 16)<<24)+((((c%>>>16) AND 255)*l% DIV 16)<<16)+((((c%>>>8) AND 255)*l% DIV 16)<<8)
82 :
90 DEF PROCscr_colour(n%,r%,g%,b%):REM Set colour n% of the game's palette
91 scr_pal%!(n%*4)=(b%<<24)+(g%<<16)+(r%<<8):scr_level%=16:scr_tabok%=FALSE
92 IF scr_direct% THEN COLOUR n%,r%,g%,b%
93 ENDPROC
94 :
100 DEF PROCscr_black:REM Show everything black, until the palette is next set
101 LOCAL i%
102 scr_level%=0:scr_tabok%=FALSE
103 IF scr_direct% THEN FOR i%=0 TO 15:VDU 19,i%,0;0;:NEXT
104 ENDPROC
105 :
110 DEF PROCscr_fade:REM Fade the picture to black
111 WHILE scr_level%>0
112 scr_level%-=1:scr_tabok%=FALSE
113 IF scr_direct% THEN PROCscr_setpal ELSE PROCscr_show
114 WAIT:WAIT
115 ENDWHILE
116 ENDPROC
117 :
120 DEF PROCscr_setpal:REM MODE 12: set the screen's palette to the game's at scr_level% sixteenths of its brightness
121 LOCAL i%,c%
122 FOR i%=0 TO 15:c%=FNscr_dim(scr_pal%!(i%*4),scr_level%):VDU 19,i%,16,(c%>>>8) AND 255,(c%>>>16) AND 255,(c%>>>24) AND 255:NEXT
123 ENDPROC
124 :
130 DEF PROCscr_clear(c%):REM Clear the picture to text background colour c% (both screen banks, in MODE 12)
131 IF scr_direct% THEN SYS 6,112,2:SYS 6,113,2:VDU 26,4:COLOUR c%:CLS:SYS 6,112,1:SYS 6,113,1
132 VDU 26,4:COLOUR c%:CLS
133 scr_s1%=1:scr_s2%=2
134 ENDPROC
135 :
140 DEF PROCscr_frame:REM The game has drawn a frame: show it at the next vsync
141 WAIT
142 IF scr_direct% THEN SYS 6,112,scr_s1%:SYS 6,113,scr_s2%:SWAP scr_s1%,scr_s2% ELSE PROCscr_show
143 ENDPROC
144 :
150 DEF PROCscr_tick:REM While waiting for the player, show the picture now and then, so that changes to it are seen. TIME is sometimes reset, hence ABS
151 IF NOT scr_direct% THEN IF ABS(TIME-scr_last%)>=5 THEN PROCscr_show
152 ENDPROC
153 :
160 DEF PROCscr_mouse(RETURN x%,RETURN y%,RETURN b%):REM Read the mouse, in the game's graphics units
161 MOUSE x%,y%,b%
162 IF NOT scr_direct% THEN x%=(x%-scr_x%)*1280 DIV scr_w%:y%=(y%-scr_y%)*1024 DIV scr_h%
163 ENDPROC
164 :
170 DEF PROCscr_grab(a%,n$,y0%,y1%):REM Copy the picture from y0% to y1%, all the way across, into sprite n$ in sprite area a%
171 LOCAL r0%,r1%,r2%,r3%
172 IF scr_direct% THEN SYS "OS_SpriteOp",&110,a%,n$,0,0,y0%,1280,y1%:ENDPROC
173 IF a%!4=0 THEN SYS "OS_SpriteOp",&10F,a%,n$,0,640,(y1%-y0%) DIV 4+1,12
174 SYS "OS_SpriteOp",&13C,a%,n$,0 TO r0%,r1%,r2%,r3%:REM Grabbing (OS_SpriteOp 16) while output is in a sprite fails, so plot the picture into this one instead
175 SYS "OS_SpriteOp",&122,scr_area%,"game",0,-y0%,0
176 SYS "OS_SpriteOp",r0%,r1%,r2%,r3%
177 ENDPROC
178 :
180 DEF PROCscr_end:REM Leave the screen as the desktop had it. Selecting its mode again makes the desktop redraw itself, as it does after MODE 12
181 IF scr_direct% THEN VDU 20:ENDPROC
182 SYS "OS_SpriteOp",scr_r0%,scr_r1%,scr_r2%,scr_r3%:scr_direct%=TRUE
183 SYS &20065,0,scr_mode%:SYS "XWimp_CommandWindow",-1:REM No "Press SPACE" when the game ends: nothing it printed needs reading
184 ENDPROC
185 :
190 DEF PROCscr_error:REM After an error: MODE 12 on the screen itself, to show it in
191 IF NOT scr_direct% THEN SYS "XOS_SpriteOp",scr_r0%,scr_r1%,scr_r2%,scr_r3%
192 scr_direct%=TRUE:scr_level%=0:MODE 12
193 ENDPROC
194 :
200 DEF FNscr_var(n$):REM A system variable's value, or "" if it isn't set
201 LOCAL l%,f%
202 SYS "XOS_ReadVarVal",n$,scr_tab%,255,0,3 TO ,,l%;f%
203 IF f% AND 1 THEN =""
204 scr_tab%?l%=13
205 =$scr_tab%
