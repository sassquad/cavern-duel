1 REM >!RunImage
2 REM Cavern Duel
3 REM Version 1.271 (26th February 2011)
4 REM Copyright held by authors. Distribute freely, but do not alter any internal files!
5 REM Written by Graeme and Stephen Scott © 1994-2011
6 REM See documentation for contact details
7 version$="Version 1.271 (26th February 2011)"
8 ON ERROR MODE12:SYS "Hourglass_Off":REPORT:PRINT" at line ";ERL:IF GET:PROCtidy:END
9 SYS "OS_Byte",229,1: REM Disable Escape
10 PROCarrays
11 PROCinitgrab
12 PROCinitfader
13 :
14 MODE 128+12
15 MODE 12
16 OFF
17 PROCcolours(1)
18 PROCintro
19 PROCmenu
20 :
21 REPEAT
22 PROCdronening
23 PROCmouse
24 UNTIL end
25 PROCtidy
26 END
27 :
28 DEF PROCarrays
29 DIM block% 64,scale% 15
30 DIM fname$(25)
31 DIM screen$(7,3,16,16)
32 DIM YOUX(2),YOUY(2),pad%(2)
33 DIM move(2)
34 DIM dire$(2)
35 DIM anim(2)
36 DIM screenx(2),screeny(2)
37 DIM energy(2),shield(2),weapon$(2),reduce_shield(2)
38 DIM fire1range(16),fire2range(16)
39 DIM activbul(16),activdos(16)
40 DIM firefr1(16),firefr2(16)
41 DIM fire1x(16),fire1y(16),fire1scx(16),fire1scy(16),fire1dir(16)
42 DIM fire2x(16),fire2y(16),fire2scx(16),fire2scy(16),fire2dir(16)
43 DIM teletoscx(20),teletoscy(20),teletox(20),teletoy(20)
44 DIM tscx(20),tscy(20),tx(20),ty(20)
45 DIM obj_remem$(200)
46 DIM obj_scx(200),obj_scy(200),obj_x(200),obj_y(200)
47 foodval=50
48 weapval=20
49 televal=5
50 shldval=10
51 numofobjs=0
52 dodrone=0
53 ENDPROC
54
55 DEF PROCinitgrab
56 g$="g1":gg$="g2":size%=43000
57 DIM grab% size%,grabtwo% size%
58 grab%!0=size%:grabtwo%!0=size%
59 grab%!8=16:grabtwo%!8=16
60 SYS 46,&109,grab%
61 SYS 46,&109,grabtwo%
62 s1%=1:s2%=2:s3%=1:s4%=2
63 width%=16:width2%=16
64 height%=16:height2%=16
65 ENDPROC
66 :
67 DEF PROCinitfader
68 REM 16 Colour mode fader.
69 REM by Matthew Edgar
70 REM (c) The Micro User September/November 1990
71 ptr=1:done=3:sixteen=4:colour=5
72 DIM code% 256:FOR pass=0 TO 2 STEP 2
73 P%=code%:[OPT pass
74 .fade
75 STMFD R13!,{R0-R5,R14}
76 MOV done,#16
77 MOV sixteen,#16
78 .wait
79 MOV R0,#19
80 SWI "OS_Byte" \ wait...
81 SWI "OS_Byte" \ ...and again
82 MOV colour,#15
83 ADR ptr,data
84 .nextcolour
85 STRB colour,[ptr]
86 MOV R0,#11
87 SWI "OS_Word"    \ read palette
88 .red
89 LDRB R0,[ptr,#2] \ current value
90 SUBS R0,R0,sixteen
91 MOVMI R0,#0      \ find new value
92 STRB R0,[ptr,#2] \ store new value
93 .green
94 LDRB R0,[ptr,#3] \ current value
95 SUBS R0,R0,sixteen
96 MOVMI R0,#0      \ find new value
97 STRB R0,[ptr,#3] \ store new value
98 .blue
99 LDRB R0,[ptr,#4] \ current value
100 SUBS R0,R0,sixteen
101 MOVMI R0,#0      \ find new value
102 STRB R0,[ptr,#4] \ store new value
103 STRB sixteen,[ptr,#1] \ define colour from RGB values
104 MOV R0,#12
105 SWI "OS_Word" \ write palette
106 SUBS colour,colour,#1
107 BGE nextcolour
108 BL border
109 SUBS done,done,#1
110 BNE wait
111 LDMFD R13!,{R0-R5,PC}:.border
112 STMFD R13!,{R0-R3,R14}:MOV R0,ptr
113 MOV R1,#24:STRB R1,[R0,#1]
114 SWI "OS_ReadPalette":MOV R1,#2
115 .loop:MOV R2,R2,ROR #8
116 AND R3,R2,#&FF:SUBS R3,R3,sixteen
117 MOVMI R3,#0:STRB R3,[R0,R1]
118 ADD R1,R1,#1:CMP R1,#5:BNE loop
119 MOV ptr,R0:MOV R0,#12
120 SWI "OS_Word"
121 LDMFD R13!,{R0-R3,PC}
122 .data
123 EQUD 0:EQUD 0
124 ]:NEXT
125 ENDPROC
126 :
127 DEF PROCcolours(pal%)
128 CASE pal% OF
129 WHEN 1: REM Title screen palette
130 COLOUR 0,255,255,255
131 COLOUR 1,221,221,221
132 COLOUR 2,187,187,187
133 COLOUR 3,153,153,153
134 COLOUR 4,119,119,119
135 COLOUR 5,85,85,85
136 COLOUR 6,51,51,51
137 COLOUR 7,0,0,0
138 COLOUR 8,0,68,153
139 COLOUR 9,238,0,0
140 COLOUR 10,0,204,0
141 COLOUR 11,221,0,0
142 COLOUR 12,238,238,187
143 COLOUR 13,85,136,0
144 COLOUR 14,255,187,0
145 COLOUR 15,0,187,255
146 WHEN 2: REM Ingame palette
147 COLOUR 0,255,255,255
148 COLOUR 1,221,221,221
149 COLOUR 2,187,187,187
150 COLOUR 3,136,136,136
151 COLOUR 4,85,85,85
152 COLOUR 5,255,255,0
153 COLOUR 6,221,0,221
154 COLOUR 7,0,0,0
155 COLOUR 8,170,119,0
156 COLOUR 9,204,0,0
157 COLOUR 10,0,204,0
158 COLOUR 11,102,0,187
159 COLOUR 12,136,68,0
160 COLOUR 13,170,0,0
161 COLOUR 14,0,170,0
162 COLOUR 15,0,255,255
163 WHEN 3: REM Menu palette
164 COLOUR 0,240,240,240
165 COLOUR 1,208,208,208
166 COLOUR 2,176,176,176
167 COLOUR 3,144,144,144
168 COLOUR 4,112,112,112
169 COLOUR 5,80,80,80
170 COLOUR 6,48,48,48
171 COLOUR 7,0,0,0
172 COLOUR 8,0,96,0
173 COLOUR 9,224,224,0
174 COLOUR 10,0,192,0
175 COLOUR 11,208,0,0
176 COLOUR 12,224,224,176
177 COLOUR 13,80,128,0
178 COLOUR 14,240,176,0
179 COLOUR 15,160,0,0
180 ENDCASE
181 ENDPROC
182 :
183 DEF PROCintro
184 REM 6th-7th August, 1994
185 skip%=FALSE
186 SYS "OS_File",5,"CavenDuel:Graphics.IntroSprs" TO ,,,,room%
187 DIM sprites% room%+32
188 !sprites%=room%+32
189 sprites%!4=0
190 sprites%!8=16
191 sprites%!12=16
192 SYS 46,&10A,sprites%,"CavenDuel:Graphics.IntroSprs"
193 SYS "Hourglass_Off"
194 MOUSE OFF
195 SYS 46,&122,sprites%,"title",0,0,0
196 COLOUR135:COLOUR11:OFF
197 PRINT TAB(23,24)"© Graeme & Stephen Scott 1994-2011.":PRINT TAB(24,30);version$
198 PROCloadsprites("CavenDuel:Graphics.GameSprs")
199 PROCloadscreens("<Game$Path>")
200 VOICES 8:CALL fade:PROCclearbanks
201 ENDPROC
202 :
203 DEF PROCwait(T)
204 LOCAL x%,y%,b%
205 M=FALSE
206 T%=TIME
207 REPEAT MOUSE x%,y%,b%
208 IF b%<>0skip%=TRUE
209 UNTIL TIME>T%+T ORskip%
210 ENDPROC
211 ::
212 DEF PROCloadscreens(filename$)
213 numofobjs=0:x=0:y=15:scrx=0:scry=0:telenum%=0
214 channel=OPENIN filename$:a$=""
215 a$=CHR$(BGET#channel)
216 REPEAT
217 y=15
218 REPEAT:IF dodrone=1 THEN PROCdronening
219 a$=CHR$(BGET#channel)
220 CASE a$ OF
221 WHEN "A":a$="12"
222 WHEN "B":a$="11"
223 WHEN "C":a$="10"
224 WHEN "D":a$="13"
225 WHEN "E":a$="14"
226 WHEN "F":a$="15"
227 WHEN "G":a$="16"
228 WHEN "H":a$="19"
229 WHEN "P":screenx(1)=scrx:screeny(1)=scry:YOUX(1)=x:YOUY(1)=y:remem1sx=screenx(1):remem1sy=screeny(1):remem1x=YOUX(1):remem1y=YOUY(1):a$="0"
230 WHEN "Q":screenx(2)=scrx:screeny(2)=scry:YOUX(2)=x:YOUY(2)=y:rememdossx=screenx(2):rememdossy=screeny(2):rememdosx=YOUX(2):rememdosy=YOUY(2):a$="0"
231 ENDCASE
232 screen$(scrx,scry,x,y)=a$:REM VDU5:PROCshadow("Map ("+STR$(scrx)+","+STR$(scry)+","+STR$(x)+","+STR$(y)+")",12*32,70,14,8):VDU4
233 CASE a$ OF
234 WHEN "7" :telenum%=telenum%+1:PROCreadteleport
235 WHEN "10","11","12","13","14","15":numofobjs+=1:PROCremobject
236 ENDCASE
237 x+=1:IF x>15 THEN x=0:y-=1
238 UNTIL y<0
239 a$=CHR$(BGET#channel)
240 IF a$<>"-" THEN SYS "XOS_CLI","Close":VDU7:END
241 scry+=1:IF scry>3 THEN scry=0:scrx+=1
242 UNTIL scrx>7
243 SYS "XOS_CLI","Close"
244 ENDPROC
245 :
246 DEF PROCreadteleport
247 IF telenum%>20 THEN ENDPROC
248 t1$=CHR$(BGET#channel):t2$=CHR$(BGET#channel)
249 t3$=CHR$(BGET#channel):t4$=CHR$(BGET#channel)
250 teletoscx(telenum%)=ASC(t1$)-65:teletoscy(telenum%)=ASC(t2$)-65
251 teletox(telenum%)=ASC(t3$)-65:teletoy(telenum%)=ASC(t4$)-65
252 tscx(telenum%)=scrx:tscy(telenum%)=scry
253 tx(telenum%)=x:ty(telenum%)=y
254 ENDPROC
255 :
256 DEF PROCremobject
257 IF numofobjs>200 THEN VDU7:ENDPROC
258 obj_remem$(numofobjs)=a$
259 obj_scx(numofobjs)=scrx:obj_scy(numofobjs)=scry
260 obj_x(numofobjs)=x:obj_y(numofobjs)=y
261 ENDPROC
262 :
263 DEF PROCloadsprites(S$)
264 SYS "OS_File",5,S$ TO ,,,,size%
265 DIM area% size%+32
266 area%!0=size%+32:area%!4=0:area%!8=16:area%!12=16
267 SYS 46,&109,area%
268 SYS 46,&10A,area%,S$
269 DIM B%(26)
270 PROCset("0",B%(0),h%,w%)
271 PROCset("1",B%(1),h%,w%)
272 PROCset("2",B%(2),h%,w%)
273 PROCset("3",B%(3),h%,w%)
274 PROCset("5",B%(5),h%,w%)
275 PROCset("6",B%(6),h%,w%)
276 PROCset("7",B%(7),h%,w%)
277 PROCset("8",B%(8),h%,w%)
278 PROCset("9",B%(9),h%,w%)
279 PROCset("10",B%(10),h%,w%)
280 PROCset("11",B%(11),h%,w%)
281 PROCset("12",B%(12),h%,w%)
282 PROCset("13",B%(13),h%,w%)
283 PROCset("14",B%(14),h%,w%)
284 PROCset("15",B%(15),h%,w%)
285 PROCset("16",B%(16),h%,w%)
286 PROCset("19",B%(19),h%,w%)
287 PROCset("wep0",B%(20),h%,w%)
288 PROCset("wep1",B%(21),h%,w%)
289 PROCset("wep2",B%(22),h%,w%)
290 PROCset("wep3",B%(23),h%,w%)
291 PROCset("wep4",B%(24),h%,w%)
292 PROCset("40",B%(17),h%,w%)
293 PROCset("41",B%(18),h%,w%)
294 ENDPROC
295 :
296 DEF PROCset(string$,RETURN value%,RETURN width%,RETURN height%)
297 SYS 46,&118,area%,string$ TO,,value%:SYS 46,&128,area%,string$ TO,,,width%,height%
298 ENDPROC
299 :
300 DEF PROCmenu
301 FOR I%=1TO15:VDU19,I%,0;0;:NEXT
302 drone%=0
303 done1=0:done2=0:done3=0:done4=0
304 !scale%=1:scale%!4=1:scale%!8=1:scale%!12=1
305 end=FALSE
306 step=1
307 screen=1
308 REM SYS 6,112,screen:COLOUR135:CLS:SYS 6,113,screen
309 PROCcolours(3)
310 PROCdrawtitle
311 PROCdrawknights
312 PROCdrawkeys
313 PROCdrawboxes
314 SYS&2E,36+256,area%,"ptr_sword",1,0,0
315 VDU5
316 MOUSE ON:OFF
317 ENDPROC
318 :
319 DEF PROCdrawtitle
320 !scale%=6:scale%!4=2
321 scale%!8=2:scale%!12=2
322 SYS 46,&134,area%,"words",0,940,0,scale%
323 ENDPROC
324 :
325 DEF PROCdrawknights
326 !scale%=4:scale%!4=4:scale%!8=3
327 scale%!12=3:SYS 46,&134,area%,"red",900,450,0,scale%
328 SYS 46,&134,area%,"green",100,450,0,scale%
329 ENDPROC
330 :
331 DEF PROCdrawkeys
332 VDU5:PROCsize(16,8)
333 PROCshadow("KEYS",18*32,430,1,8)
334 PROCshadow("Player 1",100,420,1,8)
335 PROCshadow("Player 2",900,420,1,8):PROCsize(8,8)
336 PROCshadow("Z - Left",164,380,10,4)
337 PROCshadow("X - Right",164,348,10,4)
338 PROCshadow("F - Up",164,316,10,4)
339 PROCshadow("C - Down",164,284,10,4)
340 PROCshadow("G - Fire",164,252,10,4)
341 PROCshadow("B/Keypad 1 - Left",900,380,11,4)
342 PROCshadow("N/Keypad 2 - Right",900,348,11,4)
343 PROCshadow("K/Keypad 6 - Up",900,316,11,4)
344 PROCshadow("M/Keypad 3 - Down",900,284,11,4)
345 PROCshadow("L/Keypad + - Fire",900,252,11,4)
346 PROCshadow("Delete - Pause",400,380,0,4)
347 PROCshadow("  Copy - Unpause",400,348,0,4)
348 PROCshadow("     S - Sound on",400,316,0,4)
349 PROCshadow("     Q - Sound off",400,284,0,4)
350 PROCshadow("     Tab - Return to main menu",400-32,252,0,4)
351 REM
352 PROCshadow("© Graeme & Stephen Scott 1994-2011",(23*16),80,9,4)
353 PROCshadow("Visit www.sassquad.net for the latest updates",(17.5*16),32,9,4)
354 VDU4
355 ENDPROC
356 :
357 DEF PROCdrawboxes
358 VDU5:GCOL 1:RECTANGLE400,480,480,400:GCOL11:RECTANGLE416,496,216,168:GCOL15:RECTANGLE FILL424,512,200,48:GCOL11:RECTANGLE416,580+116,216,168:GCOL15:RECTANGLE FILL424,712,200,48
359 GCOL11:RECTANGLE648,496,216,168:GCOL15:RECTANGLE FILL656,512,200,48:GCOL11:RECTANGLE648,580+116,216,168:GCOL15:RECTANGLE FILL656,712,200,48:PROCsize(32,8):PROCshadow(STR$(foodval),424,752,12,8):PROCshadow(STR$(weapval),424,552,12,8)
360 PROCshadow(STR$(televal),656,752,12,8):PROCshadow(STR$(shldval),656,552,12,8):PROCsize(8,8):PROCshadow("Select to increase, Adjust to decrease",336,920,0,4)
361 PROCshadow("Food",492,848,11,4):SYS46,&122,area%,"pro3b",500,782,8:PROCshadow("Weapons",468,648,11,4):SYS46,&122,area%,"wep0b",500,582,8:PROCshadow("Teleports",660+24,848,11,4):SYS46,&122,area%,"pro1b",736,782,8
362 PROCshadow("Shields",700,648,11,4):SYS 46,&122,area%,"pro0b",736,582,8:
363 GCOL12:RECTANGLE0,120,224,64:PROCshadow("Instructions",16,120+48,9,4):
364 GCOL12:RECTANGLE224+128,120,224,64:GCOL11:RECTANGLE FILL224+130,124,220,56:PROCshadow("Play",(224+128)+(5*16),120+48,14,4)
365 GCOL12:RECTANGLE(2*224)+(2*128),120,224,64:PROCshadow("Desktop",(2*224)+(2*128)+(3.5*16),120+48,14,4):
366 PROCshadow("Load cave",(3*224)+(3*128)+(2*16),120+48,9,4):GCOL12:RECTANGLE(3*224)+(3*128)-8,120,224,64:PROCsize(32,8):VDU4
367 ENDPROC
368 :
369 DEF PROCdronening:REM Attaching a voice cuts off the channel's sound, so only attach it just before each groan
370 drone%=TIME
371 IF done1=0:IF drone%>0:SYS "XOS_CLI","Channel. 2 ARG":SOUND2,-15,&100,100:done1=1
372 IF done2=0:IF drone%>480:SYS "XOS_CLI","Channel. 2 ARG":SOUND2,-15,&200,100:done2=1
373 IF done3=0:IF drone%>880:SYS "XOS_CLI","Channel. 2 ARG":SOUND2,-15,&300,100:done3=1
374 IF done4=0:IF drone%>1290:SYS "XOS_CLI","Channel. 2 ARG":SOUND2,-15,&200,100:done4=1
375 IF drone%>1730:drone%=0:TIME=0:done1=0:done2=0:done3=0:done4=0
376 ENDPROC
377 :
378 DEF PROCmouse
379 IF screen=1 AND INKEY-99:CALL fade:PROCclearbanks2:PROCplay:CALL fade:PROCclearbanks:PROCmenu:ENDPROC
380 LOCAL MX%,MY%,but%
381 MOUSE MX%,MY%,but%
382 IF but%=0 THEN ENDPROC
383 IF but%=4 step=1
384 IF but%=1 step=-1
385 CASE screen OF
386 WHEN 1:
387 food=FNrange(424,712,200,48):weap=FNrange(424,512,200,48)
388 tran=FNrange(656,712,200,48):shld=FNrange(656,512,200,48)
389 play=FNrange((224+128),120,224,64)
390 help=FNrange(0,120,224,64)
391 quit=FNrange((2*224)+(2*128),120,224,64)
392 new=FNrange((3*224)+(3*128)-8,120,224,64)
393 IF food GCOL15:RECTANGLE FILL424,712,200,48:foodval+=step:PROCcheckvals:PROCshadow(STR$(foodval),424,752,12,8)
394 IF weap GCOL15:RECTANGLE FILL424,512,200,48:weapval+=step:PROCcheckvals:PROCshadow(STR$(weapval),424,552,12,8)
395 IF tran GCOL15:RECTANGLE FILL656,712,200,48:televal+=step:PROCcheckvals:PROCshadow(STR$(televal),656,752,12,8)
396 IF shld GCOL15:RECTANGLE FILL656,512,200,48:shldval+=step:PROCcheckvals:PROCshadow(STR$(shldval),656,552,12,8)
397 IF play CALL fade:PROCclearbanks2:PROCplay:CALL fade:PROCclearbanks:PROCmenu:ENDPROC
398 IF help CALL fade:PROCinstruct:CALL fade:PROCclearbanks:PROCmenu:ENDPROC
399 IF new CALL fade:PROCloadnewcaves:CALL fade:PROCclearbanks:PROCmenu:ENDPROC
400 IF quit CALL fade:PROCquit:ENDPROC
401 WHEN 2:
402 yes=FNrange(250,250,160,64)
403 no=FNrange(930,250,160,64)
404 IF yes THEN end=TRUE
405 IF no THEN CALL fade:PROCclearbanks:PROCmenu:ENDPROC
406 ENDCASE
407 ENDPROC
408 :
409 DEF PROCinstruct
410 VDU5,24,0;0;1279;940;:GCOL 135:CLG:VDU26:PROCsize(16,8)
411 PROCshadow("INSTRUCTIONS",28*16,908,12,8):PROCsize(8,8)
412 PROCshadow("You have knocked over the pint glass of Big Biceps McCrinkle, the strongest",40,850,9,4)
413 PROCshadow("warrior in the land. Insulted, he demands a duel to the death within the caverns",0,850-32,9,4)
414 PROCshadow("situated beneath the kingdom's mountain range.",17*16,850-64,9,4)
415 PROCshadow("Both players must find each other, picking up any suitable weapons and armour",24,850-128,9,4)
416 PROCshadow("before battling it out until one player's energy level reaches zero, and the",32,850-160,9,4)
417 PROCshadow("last one standing wins the duel.",24*16,850-192,9,4)
418 PROCshadow("Collecting food and red potion bottles increases your energy. Collecting shields",0,850-256,9,4):
419 PROCshadow("increases your resistance to your opponent's chosen weapon. Collecting green",32,(850-256)-32,9,4)
420 PROCshadow("potion bottles teleport you to random locations. Use the teleports to transport",8,(850-256)-64,9,4)
421 PROCshadow("you to predefined locations. Be aware of the fact that some walls are not solid!",0,(850-256)-96,9,4)
422 REM PROCshadow("solid!",37*16,(850-256)-128,9,4)
423 PROCshadow("The weapons you will come across can either be thrown, fired or held.",5.5*16,(850-256)-128,9,4)
424 PROCshadow("As a rule, held weapons are less effective than the others, particularly if",40,(850-256)-192,9,4)
425 PROCshadow("the opponent has an obviously more powerful weapon. But it is up to you to",48,(850-256)-224,9,4)
426 PROCshadow("find out which weapons are the best.",22*16,850-512,9,4)
427 PROCshadow("When you play, the screen is divided into two parts. The top half is for",64,(850-544)-32,9,4)
428 PROCshadow("player one, the bottom half for player two. For each half, there is a status",32,(850-544)-64,9,4)
429 PROCshadow("box, showing the currently held weapon, a magic map to show your opponent rough",8,(850-544)-96,9,4)
430 PROCshadow("location, the player's energy level and armour strength. You can carry a maximum",0,(850-544)-128,9,4)
431 PROCshadow("of five shields at any one time. Good Luck!",18.5*16,(850-544)-160,9,4):
432 GCOL 12:RECTANGLE 352,32,560,64:GCOL 11:RECTANGLE FILL 354,36,556,56
433 PROCshadow("Click mouse button to continue...",368,80,12,4)
434 PROCcolours(3)
435 REPEAT
436 MOUSE X,Y,Z
437 PROCdronening
438 UNTIL Z<>0
439 ENDPROC
440 :
441 DEF PROCquit
442 screen=2:VDU 5,24,0;0;1279;940;:GCOL135:CLG:VDU26
443 PROCdrawknights:PROCsize(16,8)
444 PROCshadow("Are you sure you want to return",9*16,400,14,8)
445 PROCshadow("to the desktop ?",24*16,400-40,14,8)
446 GCOL 12:RECTANGLE 250,250,160,64
447 PROCshadow("YES",250+32,250+48,12,8)
448 GCOL 11:RECTANGLE 930,250,160,64
449 PROCshadow("NO",930+48,250+48,11,8)
450 PROCcolours(3)
451 ENDPROC
452
453 DEF PROCloadnewcaves
454 VDU 5,24,0;0;1279;940;
455 GCOL 135
456 CLG
457 PROCdrawknights
458 PROCsize(16,8)
459 PROCshadow("Select a new set of caves to load",7*16,400,14,8)
460 PROCsize(8,8)
461 myownnumber%=0
462 datafiles%=FNreadfiles("CavenDuel:Screens",&022)
463 PROCcolours(3)
464 printx=250
465 printy=280
466 mapnum=1
467 loaded=0
468 REPEAT
469 GCOL11
470 RECTANGLE FILL printx,printy,192,40
471 VDU5
472 GCOL0
473 MOVEprintx+16,printy+32
474 PRINT fname$(mapnum)
475 printx+=212
476 mapnum+=1
477 IF printx>1025:printx=250:printy-=52
478 UNTIL mapnum>datafiles%
479 :
480 REPEAT
481 MOUSE X,Y,Z
482 PROCdronening
483 x2=250
484 y2=280
485 FOR a=1TOdatafiles%
486 IF X>x2 AND X<x2+192 AND Y>y2 AND Y<y2+40 AND Z=4:SOUND6,-15,190+(a*5),10:PROCloadnewscreens
487 x2+=212
488 IF x2>1025:x2=250:y2-=52
489 NEXT
490 UNTIL loaded=1
491 CALL fade
492 ENDPROC
493 :
494 DEF PROCloadnewscreens
495 SYS&2E,36+256,area%,"ptr_wait",1,0,0
496 GCOL7
497 RECTANGLE FILL0,360,1280,50
498 VDU5
499 :
500 REM Clearing teleporters
501 PROCshadow("Clearing teleports",26*16,400,14,8)
502 teletoscx()=0
503 teletoscy()=0
504 teletox()=0
505 teletoy()=0
506 tscx()=0
507 tscy()=0
508 tx()=0
509 ty()=0
510 :
511 GCOL7
512 RECTANGLE FILL0,360,1280,50
513 PROCshadow("Loading screens - "+fname$(a),26*16,400,14,8)
514 PROCloadscreens("CavenDuel:Screens."+fname$(a))
515 loaded=1
516 SYS "XOS_CLI","Set Game$Path CavenDuel:Screens."+fname$(a)
517 ENDPROC
518 :
519 DEF FNreadfiles(dir$,filetype%)
520 LOCAL curfile%,file%,name$,name%,number%
521 curfile%=1:fname$()="":file%=0:REPEAT
522 SYS "OS_GBPB",10,dir$,block%,1,file%,63,"*" TO ,,,number%
523 name$="":name%=&14
524 WHILE block%?name%<>0
525 name$+=CHR$(block%?name%)
526 name%+=1
527 ENDWHILE
528 IF ((!block% >>> 8)AND &FFF)=filetype%:fname$(curfile%)=name$:curfile%+=1
529 file%+=1:myownnumber%+=1
530 UNTIL number%<>1
531 =curfile%-2
532 :
533 DEF PROCcheckvals
534 IF foodval>120 foodval=120
535 IF foodval<=5  foodval=5
536 IF weapval>30  weapval=30
537 IF weapval<=4  weapval=4
538 IF televal>10  televal=10
539 IF televal<=0  televal=0
540 IF shldval>20  shldval=20
541 IF shldval<=0  shldval=0
542 ENDPROC
543 :
544 DEF FNrange(RX,RY,RW,RH)
545 LOCAL XT,YT
546 XT=FALSE
547 IF MX%>RX AND MX%<(RX+RW):XT=TRUE
548 IF MY%>RY AND MY%<(RY+RH):YT=TRUE
549 IF (XT=FALSE) OR (YT=FALSE): =FALSE
550 MOVE RX,RY
551 PLOT &62,RW,RH
552 T%=TIME:REPEAT UNTIL TIME>T%+7
553 MOVE RX,RY
554 PLOT &62,RW,RH
555 =TRUE
556 :
557 DEF PROCsize(x%,y%):VDU 23,17,7,6,x%;y%|
558 ENDPROC
559 :
560 DEF PROCshadow(text$,x,y,col,gap)
561 VDU5
562 GCOL 7
563 MOVE x+gap,y-gap
564 PRINT text$
565 GCOL col
566 MOVE x,y
567 PRINT text$
568 VDU4
569 OFF
570 ENDPROC
571 :
572 DEF PROCtidy
573 CALL fade
574 SYS "Hourglass_Off":
575 MOUSE OFF:VDU26:COLOUR128:CLS
576 SYS "OS_Byte",15,0
577 VDU 20
578 ENDPROC
579 :
580 DEF PROCplay
581 CLS:FOR I%=0TO15:VDU19,I%,0;0;:NEXT:PROCclearbanks
582 MOUSE OFF
583 gapfire=0:PROCseed(TIME):REM A networked game will seed both machines with the same number
584 REM Recall pre-positioned objects
585 FOR obj=1 TO numofobjs
586 screen$(obj_scx(obj),obj_scy(obj),obj_x(obj),obj_y(obj))=obj_remem$(obj)
587 NEXT
588 PROCdrawgraphics
589 PROCplaceobjects
590 PROCsetupplayers
591 player%=1
592 PROCscreen(screenx(player%),screeny(player%),player%)
593 SOUND1,-15,&2000,100
594 player%=2
595 PROCscreen(screenx(player%),screeny(player%),player%)
596 SOUND1,-15,&1000,100
597 GCOL 63 TINT 192:LINE 0,508,1280,508
598 PROCgrab(1):PROCgrab(2)
599 player%=1:SYS 46,&122,area%,"1d0",YOUX(player%)*64,512+YOUY(player%)*32,8
600 player%=2:SYS 46,&122,area%,"2d0",YOUX(player%)*64,YOUY(player%)*32-4,8
601 PROCcolours(2)
602 :
603 REPEAT
604 SYS 46,&222,grab%,bg%,0,0,0
605 SYS 46,&222,grabtwo%,bg2%,0,512,0
606 PROCreadkeys:REM Every key is read here, once a frame; the game below only looks at pad%() and ctl%
607 IF energy(1)>0:IF keycheckrate=1:PROCkeys1
608 gapdo=0
609 weptype=0
610 IF weapon$(1)="wep1" OR weapon$(1)="wep4" THEN
611 gapdo=1
612 weptype=1
613 ELSE
614 weptype=2
615 PROCgap_fire
616 ENDIF
617 IF gapdo=0 THEN
618 PROCcheckweps
619 ELSE
620 IF weptype=1:IF pad%(1) AND 16:IF energy(1)>0:IF keycheckrate=1:PROCfire1
621 IF weptype=2:IF pad%(1) AND 16:IF energy(1)>0:IF gapdo=1:PROCfire1
622 PROCcheckweps
623 ENDIF
624 :
625 IF energy(2)>0:IF keycheckrate=1:PROCkeys2
626 IF pad%(2) AND 16:IF energy(2)>0:IF keycheckrate=1:PROCfire2
627 PROCcheckweps2
628 IF ctl% AND 1 THEN REPEAT UNTIL INKEY-106
629 IF ctl% AND 2:SYS "XOS_CLI","SPEAKER OFF"
630 IF ctl% AND 4:SYS "XOS_CLI","SPEAKER ON"
631 IF ctl% AND 8:end%=1:SYS "XOS_CLI","CHANNEL. 2 ARG":SOUND2,-15,&100,100
632 player%=1:PROCprint:PROCprintbuls1
633 player%=2:PROCprint:PROCprintbuls1
634 PROCprintother
635 keycheckrate+=1:IF keycheckrate>1 THEN keycheckrate=0
636 IF hit1=1:hitcounter1=0:hit1=2
637 IF hit2=1:hitcounter2=0:hit2=2
638 IF hit1=2:hitcounter1+=1:PROCdrawblood_pl1
639 IF hit2=2:hitcounter2+=1:PROCdrawblood_pl2
640 IF hit1=2:IF hitcounter1>10:hit1=0:hitcounter1=0
641 IF hit2=2:IF hitcounter2>10:hit2=0:hitcounter2=0
642 PROCprintenergy
643 PROCprintmaps
644 IF energy(1)<=0 OR energy(2)<=0:counttillend%+=1:PROCprintwinner
645 IF counttillend%=1:SOUND2,-15,&1000,100:PROCfindwinner
646 TIME=0:REPEAT UNTIL TIME=5:REM Time Delay to get speed the same (removed for VRPC-SE)
647 WAIT
648 SYS 6,112,s1%
649 SYS 6,113,s2%
650 SWAP s1%,s2%
651 UNTIL end%=1 OR counttillend%>90
652 creds=1
653 :
654 REM Clear map of waste.
655 scrposx=0:scrposy=0
656 REPEAT
657 FOR A=0TO15 :FOR B=0TO15:what$=screen$(scrposx,scrposy,A,B)
658 CASE what$ OF
659 WHEN "10","11","12","13","14","15","wep0","wep1","wep2","wep3","wep4":screen$(scrposx,scrposy,A,B)="0"
660 ENDCASE
661 NEXT:NEXT
662 scrposx+=1:IF scrposx>7 THEN scrposx=0:scrposy+=1
663 UNTIL scrposy>3
664 ENDPROC
665 :
666 DEF PROCgap_fire:gapdo=0
667 gapfire+=1
668 IF gapfire>3:gapfire=0:gapdo=1
669 ENDPROC
670 :
671 DEF PROCkeys1
672 player%=1
673 IF pad%(1) AND 1:YOUX(player%)-=1:move(player%)=0:dire$(player%)="l":buld1=3:PROCcheck:PROCcheckarea:anim(player%)=anim(player%)+1:PROCprint:PROCclear:ENDPROC
674 IF pad%(1) AND 2:YOUX(player%)+=1:move(player%)=1:dire$(player%)="r":buld1=1:PROCcheck:PROCcheckarea:anim(player%)=anim(player%)+1:PROCprint:PROCclear:ENDPROC
675 IF pad%(1) AND 4:YOUY(player%)+=1:move(player%)=2:dire$(player%)="u":buld1=0:PROCcheck:PROCcheckarea:anim(player%)=anim(player%)+1:PROCprint:PROCclear:ENDPROC
676 IF pad%(1) AND 8:YOUY(player%)-=1:move(player%)=3:dire$(player%)="d":buld1=2:PROCcheck:PROCcheckarea:anim(player%)=anim(player%)+1:PROCprint:PROCclear
677 ENDPROC
678 :
679 DEF PROCkeys2
680 player%=2
681 IF pad%(2) AND 1:YOUX(player%)-=1:move(player%)=0:dire$(player%)="l":buld2=3:PROCcheck:PROCcheckarea:anim(player%)+=1:PROCprint:ENDPROC
682 IF pad%(2) AND 2:YOUX(player%)+=1:move(player%)=1:dire$(player%)="r":buld2=1:PROCcheck:PROCcheckarea:anim(player%)+=1:PROCprint:ENDPROC
683 IF pad%(2) AND 4:YOUY(player%)+=1:move(player%)=2:dire$(player%)="u":buld2=0:PROCcheck:PROCcheckarea:anim(player%)+=1:PROCprint:ENDPROC
684 IF pad%(2) AND 8:YOUY(player%)-=1:move(player%)=3:dire$(player%)="d":buld2=2:PROCcheck:PROCcheckarea:anim(player%)+=1:PROCprint
685 ENDPROC
686 :
687 DEF PROCscreen(E,F,PLAY%)
688 C=0:D=994
689 IF PLAY%=2 THEN C=0:D=476
690 X=0:Y=15
691 REPEAT
692 a$=screen$(E,F,X,Y)
693 CASE a$ OF
694 WHEN "wep0":a%=20
695 WHEN "wep1":a%=21
696 WHEN "wep2":a%=22
697 WHEN "wep3":a%=23
698 WHEN "wep4":a%=24
699 WHEN "4":r%=FNrnd(2)-1:a%=17+r%
700 OTHERWISE:a%=VAL(a$)
701 ENDCASE
702 IF a%>19 AND a%<25 OR a%>5 AND a%<16 OR a%=19 THEN
703 SYS 46,&222,area%,B%(0),C,D,0:SYS 46,&222,area%,B%(a%),C,D,8
704 ELSE
705 SYS 46,&222,area%,B%(a%),C,D,0
706 ENDIF
707 X=X+1:C+=64:IF X>15 THEN Y=Y-1:X=0:C=0:D-=32
708 UNTIL Y<0
709 PROCgrab(PLAY%)
710 ENDPROC
711 :
712 DEF PROCremobject
713 IF numofobjs>200 THEN VDU7:ENDPROC
714 obj_remem$(numofobjs)=a$
715 obj_scx(numofobjs)=scrx:obj_scy(numofobjs)=scry
716 obj_x(numofobjs)=x:obj_y(numofobjs)=y
717 ENDPROC
718 :
719 DEF PROCcheck :b=0:dontdraw=0
720 IF YOUX(player%)<0 :screenx(player%)-=1:YOUX(player%)=15:b=0:PROCcheckarea2:IF dontdraw=0 :PROCscreen(screenx(player%),screeny(player%),player%)
721 IF YOUX(player%)>15 :screenx(player%)+=1:YOUX(player%)=0:b=1:PROCcheckarea2:IF dontdraw=0 :PROCscreen(screenx(player%),screeny(player%),player%)
722 IF YOUY(player%)>15 :screeny(player%)+=1:YOUY(player%)=0:b=2:PROCcheckarea2:IF dontdraw=0 :PROCscreen(screenx(player%),screeny(player%),player%)
723 IF YOUY(player%)<0 :screeny(player%)-=1:YOUY(player%)=15:b=3:PROCcheckarea2:IF dontdraw=0 :PROCscreen(screenx(player%),screeny(player%),player%)
724 ENDPROC
725 :
726 DEF PROCcheckarea2
727 s$=screen$(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%))
728 IF b=0 :IF s$="1" OR s$="2" OR s$="3" OR s$="4" OR s$="19" THEN YOUX(player%)=0:screenx(player%)+=1:dontdraw=1
729 IF b=1 :IF s$="1" OR s$="2" OR s$="3" OR s$="4" OR s$="19" THEN YOUX(player%)=15:screenx(player%)-=1:dontdraw=1
730 IF b=2 :IF s$="1" OR s$="2" OR s$="3" OR s$="4" OR s$="19" THEN YOUY(player%)=15:screeny(player%)-=1:dontdraw=1
731 IF b=3 :IF s$="1" OR s$="2" OR s$="3" OR s$="4" OR s$="19" THEN YOUY(player%)=0:screeny(player%)+=1:dontdraw=1
732 ENDPROC
733 :
734 DEF PROCclear
735 f$=screen$(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%))
736 IF f$="wep0" OR f$="wep1" OR f$="wep2" OR  f$="wep3" OR  f$="wep4":ENDPROC
737 :
738 IF player%=1:SYS 46,&122,area%,screen$(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%)),YOUX(player%)*64,512+YOUY(player%)*32,8
739 IF player%=2:SYS 46,&122,area%,screen$(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%)),YOUX(player%)*64,(YOUY(player%)*32)-4,8
740 IF player%=1:IF screenx(2)=screenx(1) AND screeny(2)=screeny(1):SYS 46,256+34,area%,screen$(screenx(1),screeny(1),YOUX(1),YOUY(1)),YOUX(1)*64,(YOUY(1)*32)-4,8
741 IF player%=2:IF screenx(1)=screenx(2) AND screeny(1)=screeny(2):SYS 46,256+34,area%,screen$(screenx(2),screeny(2),YOUX(2),YOUY(2)),YOUX(2)*64,512+(YOUY(2)*32),8
742 ENDPROC
743 :
744 DEF PROCcheckarea
745 s$=screen$(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%))
746 IF move(player%)=0:PROCcheckforobjects:IF s$="1" OR s$="2" OR s$="3" OR s$="4" OR s$="19" THEN YOUX(player%)+=1:PROCcheck
747 IF move(player%)=1:PROCcheckforobjects:IF s$="1" OR s$="2" OR s$="3" OR s$="4" OR s$="19" THEN YOUX(player%)-=1:PROCcheck
748 IF move(player%)=2:PROCcheckforobjects:IF s$="1" OR s$="2" OR s$="3" OR s$="4" OR s$="19" THEN YOUY(player%)-=1:PROCcheck
749 IF move(player%)=3:PROCcheckforobjects:IF s$="1" OR s$="2" OR s$="3" OR s$="4" OR s$="19" THEN YOUY(player%)+=1:PROCcheck
750 ENDPROC
751 :
752 DEF PROCprint
753 IF anim(player%)>1:anim(player%)=0
754 name2$=STR$(player%)+dire$(player%)
755 IF player%=1 AND energy(1)>0:SYS 46,&122,area%,name2$+STR$(anim(player%)),YOUX(player%)*64,512+YOUY(player%)*32,8
756 IF player%=1 AND energy(1)<=0:SYS 46,&122,area%,"death",YOUX(player%)*64,512+YOUY(player%)*32,8
757 IF player%=2 AND energy(2)>0:SYS 46,&122,area%,name2$+STR$(anim(player%)),YOUX(player%)*64,(YOUY(player%)*32)-4,8
758 IF player%=2 AND energy(2)<=0:SYS 46,&122,area%,"death",YOUX(player%)*64,(YOUY(player%)*32)-4,8
759 ENDPROC
760 :
761 DEF PROCprintother
762 name2$="2"+dire$(2)
763 IF screenx(1)=screenx(2) AND screeny(1)=screeny(2) AND energy(2)>0:SYS 46,&122,area%,name2$+STR$(anim(2)),YOUX(2)*64,512+(YOUY(2)*32),8
764 IF screenx(1)=screenx(2) AND screeny(1)=screeny(2) AND energy(2)<=0:SYS 46,&122,area%,"death",YOUX(2)*64,512+(YOUY(2)*32),8
765 name2$="1"+dire$(1)
766 IF screenx(2)=screenx(1) AND screeny(2)=screeny(1) AND energy(1)>0:SYS 46,&122,area%,name2$+STR$(anim(1)),YOUX(1)*64,(YOUY(1)*32)-4,8
767 IF screenx(2)=screenx(1) AND screeny(2)=screeny(1) AND energy(1)<=0:SYS 46,&122,area%,"death",YOUX(1)*64,(YOUY(1)*32)-4,8
768 ENDPROC
769 :
770 DEF PROCcheckforobjects
771 CASE s$ OF
772 WHEN "10","11","12","13","14","15":PROCdeleteobject
773 WHEN "wep0","wep1","wep2","wep3","wep4":PROCsortwepchange
774 WHEN "6":PROCrandomteleport
775 WHEN "7":PROCteleport_to_set_position
776 ENDCASE
777 ENDPROC
778 :
779 DEF PROCdeleteobject
780 CASE s$ OF
781 WHEN "10" : PROCgetshield
782 WHEN "11" : PROCgetapple
783 WHEN "12" : PROCgetfish
784 WHEN "15" : PROCgettrans
785 WHEN "13" : PROCgetpotion
786 WHEN "14" : PROCgetsandwich
787 ENDCASE
788 ENDPROC
789 :
790 REM Part for collecting a shield.
791 DEF PROCgetshield
792 SYS "XOS_CLI","CHANNEL. 5 ObjGet"
793 IF shield(player%)<6:SOUND5,-15,&1000,100:shield(player%)+=1
794 IF shield(player%)<6:screen$(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%))="0"
795 IF shield(player%)<6:PROCclearblock(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%),player%)
796 IF shield(player%)<6:IF screenx(1)=screenx(2) AND screeny(1)=screeny(2):PROCcol2
797 IF shield(player%)<6 PROCgrab(player%)
798 IF shield(player%)>=6:SOUND5,-15,&200,100:shield(player%)-=1
799 PROCprint
800 ENDPROC
801 :
802 REM Part for collecting a teleporter.
803 DEF PROCgettrans
804 SYS "XOS_CLI","CHANNEL. 5 Rotate"
805 SOUND5,-15,&1000,100
806 screen$(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%))="0"
807 PROCclearblock(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%),player%)
808 IF screenx(1)=screenx(2) AND screeny(1)=screeny(2):PROCcol2
809 PROCgrab(player%)
810 PROCprint
811 PROCrandomteleport
812 ENDPROC
813 :
814 REM Part for collecting a potion bottle.
815 DEF PROCgetpotion
816 SYS "XOS_CLI","CHANNEL. 5 Rotate"
817 SOUND5,-15,&2000,100
818 screen$(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%))="0"
819 PROCclearblock(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%),player%)
820 IF screenx(1)=screenx(2) AND screeny(1)=screeny(2):PROCcol2
821 PROCgrab(player%)
822 PROCprint
823 energy(player%)+=8
824 ENDPROC
825 :
826 REM Part for collecting a sandwich.
827 DEF PROCgetsandwich
828 SYS "XOS_CLI","CHANNEL. 5 ObjGet"
829 SOUND5,-15,&2000,100
830 screen$(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%))="0"
831 PROCclearblock(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%),player%)
832 IF screenx(1)=screenx(2) AND screeny(1)=screeny(2):PROCcol2
833 PROCgrab(player%)
834 PROCprint
835 energy(player%)+=4
836 ENDPROC
837 :
838 REM Part for collecting a fish.
839 DEF PROCgetfish
840 SYS "XOS_CLI","CHANNEL. 5 ObjGet"
841 SOUND5,-15,&4000,10
842 screen$(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%))="0"
843 PROCclearblock(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%),player%)
844 IF screenx(1)=screenx(2) AND screeny(1)=screeny(2):PROCcol2
845 PROCgrab(player%)
846 PROCprint
847 energy(player%)+=6
848 ENDPROC
849 :
850 REM Part for collecting an apple.
851 DEF PROCgetapple
852 SYS "XOS_CLI","CHANNEL. 5 ObjGet"
853 SOUND5,-15,&3000,10
854 screen$(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%))="0"
855 PROCclearblock(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%),player%)
856 IF screenx(1)=screenx(2) AND screeny(1)=screeny(2):PROCcol2
857 PROCgrab(player%)
858 PROCprint
859 energy(player%)+=4
860 ENDPROC
861 :
862 DEF PROCcol2
863 IF player%=1:PROCclearblock(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%),2):PROCgrab(2)
864 IF player%=2:PROCclearblock(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%),1):PROCgrab(1)
865 ENDPROC
866 :
867 DEF PROCrandomteleport
868 SYS "XOS_CLI","CHANNEL. 4 Hit"
869 SOUND4,-15,&1000,100
870 :
871 REPEAT
872 R1%=FNrnd(8)-1:R2%=FNrnd(4)-1:R3%=FNrnd(15):R4%=FNrnd(15)
873 UNTIL screen$(R1%,R2%,R3%,R4%)="0" OR screen$(R1%,R2%,R3%,R4%)="5":screenx(player%)=R1%:screeny(player%)=R2%:YOUX(player%)=R3%:YOUY(player%)=R4%
874 PROCscreen(screenx(player%),screeny(player%),player%):PROCgrab(player%)
875 ENDPROC
876 :
877 DEF PROCteleport_to_set_position
878 FOR tele%=0TOtelenum%
879 IF tscx(tele%)=screenx(player%) AND tscy(tele%)=screeny(player%) AND tx(tele%)=YOUX(player%) AND ty(tele%)=YOUY(player%):PROCshift_to_position
880 NEXT
881 ENDPROC
882 :
883 DEF PROCshift_to_position
884 SYS "XOS_CLI","CHANNEL. 4 Hit":SOUND4,-15,&1000,100
885 REM Remove 'REM' commands here if you want a failure rate on teleporters
886 REM Z%=RND(3)-1
887 REM IF Z%=1:PROCrandomteleport:ENDPROC
888 screenx(player%)=teletoscx(tele%):screeny(player%)=teletoscy(tele%)
889 YOUX(player%)=teletox(tele%):YOUY(player%)=teletoy(tele%)
890 PROCscreen(screenx(player%),screeny(player%),player%):PROCgrab(player%)
891 ENDPROC
892 :
893 DEF PROCfire1
894 IF weapon$(1)="0" THEN ENDPROC
895 IF fire1>10:fire1=0
896 IF activbul(fire1)=1 THEN
897 fire1+=1
898 ELSE
899 activbul(fire1)=1
900 fire1x(fire1)=YOUX(1):fire1y(fire1)=YOUY(1)
901 fire1scx(fire1)=screenx(1):fire1scy(fire1)=screeny(1)
902 fire1dir(fire1)=buld1:fire1range(fire1)=-1:firefr1(fire1)=0
903 REM fire1+=1:IF fire1>10 THEN fire1=0
904 SYS "XOS_CLI","CHANNEL. 7 Fire"
905 IF weapon$(1)="wep4":SOUND7,-15,&200,100
906 IF weapon$(1)="wep3":SOUND7,-15,&1000,100
907 IF weapon$(1)="wep2":SOUND7,-15,&500,100
908 IF weapon$(1)="wep1":SOUND7,-10,&1500,100
909 IF weapon$(1)="wep0":SOUND7,-15,&1000,100
910 ENDIF
911 ENDPROC
912 :
913 DEF PROCfire2
914 IF weapon$(2)="0":ENDPROC
915 IF fire2>10:fire2=0
916 IF activdos(fire2)=1 THEN
917 fire2+=1
918 ELSE
919 activdos(fire2)=1
920 fire2x(fire2)=YOUX(2):fire2y(fire2)=YOUY(2)
921 fire2scx(fire2)=screenx(2):fire2scy(fire2)=screeny(2)
922 fire2dir(fire2)=buld2:fire2range(fire2)=0:firefr2(fire2)=0
923 SYS "XOS_CLI","CHANNEL. 8 Fire"
924 IF weapon$(2)="wep4":SOUND8,-15,&200,100
925 IF weapon$(2)="wep3":SOUND8,-15,&1000,100
926 IF weapon$(2)="wep2":SOUND8,-15,&500,100
927 IF weapon$(2)="wep1":SOUND8,-10,&200,100
928 IF weapon$(2)="wep0":SOUND8,-15,&1000,10
929 ENDIF
930 ENDPROC
931 :
932 DEF PROCcheckweps
933   bollets2%=0
934   REPEAT
935     IF activbul(bollets2%)<>0 THEN
936       IF fire1dir(bollets2%)=0:fire1y(bollets2%)+=1
937       IF fire1dir(bollets2%)=2:fire1y(bollets2%)-=1
938       IF fire1dir(bollets2%)=1:fire1x(bollets2%)+=1
939       IF fire1dir(bollets2%)=3:fire1x(bollets2%)-=1
940       IF fire1x(bollets2%)<0:fire1scx(bollets2%)-=1:fire1x(bollets2%)=15
941       IF fire1x(bollets2%)>15:fire1scx(bollets2%)+=1:fire1x(bollets2%)=0
942       IF fire1y(bollets2%)<0:fire1scy(bollets2%)-=1:fire1y(bollets2%)=15
943       IF fire1y(bollets2%)>15:fire1scy(bollets2%)+=1:fire1y(bollets2%)=0
944       PROCcheckblock(fire1scx(bollets2%),fire1scy(bollets2%),fire1x(bollets2%),fire1y(bollets2%))
945       IF feedback$="1" OR feedback$="2" OR feedback$="3" OR feedback$="4" OR feedback$="6" OR feedback$="7" :activbul(bollets2%)=0:SYS "XOS_CLI","CHANNEL. 5 Sides":SOUND5,-15,&2000,100
946       fire1range(bollets2%)+=1:PROCcheckrange
947     ENDIF
948     bollets2%+=1
949   UNTIL bollets2%>10
950   ENDPROC
951   :
952   DEF PROCcheckweps2
953     bullets%=0
954     REPEAT
955     IF activdos(bullets%)<>0 THEN
956       IF fire2dir(bullets%)=0:fire2y(bullets%)+=1
957       IF fire2dir(bullets%)=2:fire2y(bullets%)-=1
958       IF fire2dir(bullets%)=1:fire2x(bullets%)+=1
959       IF fire2dir(bullets%)=3:fire2x(bullets%)-=1
960       IF fire2x(bullets%)<0:fire2scx(bullets%)-=1:fire2x(bullets%)=15
961       IF fire2x(bullets%)>15:fire2scx(bullets%)+=1:fire2x(bullets%)=0
962       IF fire2y(bullets%)<0:fire2scy(bullets%)-=1:fire2y(bullets%)=15
963       IF fire2y(bullets%)>15:fire2scy(bullets%)+=1:fire2y(bullets%)=0
964       PROCcheckblock(fire2scx(bullets%),fire2scy(bullets%),fire2x(bullets%),fire2y(bullets%))
965       IF feedback$="1" OR feedback$="2" OR feedback$="3" OR feedback$="4" OR feedback$="6" OR feedback$="7" :activdos(bullets%)=0:SYS "XOS_CLI","CHANNEL. 6 Sides":SOUND6,-15,&2000,100
966       fire2range(bullets%)+=1:PROCcheckrange2
967     ENDIF
968     bullets%+=1
969   UNTIL bullets%>10
970   ENDPROC
971 :
972 DEF PROCcheckrange
973 IF weapon$(1)="wep0":IF fire1range(bollets2%)=16:fire1range(bollets2%)=0:PROCresetfire2(1)
974 IF weapon$(1)="wep1":IF fire1range(bollets2%)=1:fire1range(bollets2%)=-1:PROCresetfire2(1)
975 IF weapon$(1)="wep2":IF fire1range(bollets2%)=48:fire1range(bollets2%)=0:PROCresetfire2(1)
976 IF weapon$(1)="wep3":IF fire1range(bollets2%)=10:fire1range(bollets2%)=0:PROCresetfire2(1)
977 IF weapon$(1)="wep4":IF fire1range(bollets2%)=1:fire1range(bollets2%)=-1:PROCresetfire2(1)
978 ENDPROC
979 DEF PROCcheckrange2
980 IF weapon$(2)="wep0":IF fire2range(bullets%)=16:fire2range(bullets%)=0:PROCresetfire2(2)
981 IF weapon$(2)="wep1":IF fire2range(bullets%)=2:fire2range(bullets%)=0:PROCresetfire2(2)
982 IF weapon$(2)="wep2":IF fire2range(bullets%)=48:fire2range(bullets%)=0:PROCresetfire2(2)
983 IF weapon$(2)="wep3":IF fire2range(bullets%)=10:fire2range(bullets%)=0:PROCresetfire2(2)
984 IF weapon$(2)="wep4":IF fire2range(bullets%)=2:fire2range(bullets%)=0:PROCresetfire2(2)
985 ENDPROC
986 :
987 DEF PROCclearblock(scx,scy,z,x,pl%)
988 CASE screen$(scx,scy,z,x) OF
989 WHEN "wep0","wep1","wep2","wep3","wep4","6","7","8":PROCsort_out_other_blocks:ENDPROC
990 ENDCASE
991 :
992 IF pl%=1:SYS 46,&222,area%,B%(0),z*64,512+x*32,0:SYS 46,&122,area%,screen$(scx,scy,z,x),z*64,512+x*32,8
993 IF pl%=2:SYS 46,&222,area%,B%(0),z*64,x*32-4,0:SYS 46,&122,area%,screen$(scx,scy,z,x),z*64,x*32-4,8
994 ENDPROC
995 :
996 DEF PROCsort_out_other_blocks
997 IF pl%=1:SYS 46,&222,area%,B%(0),z*64,512+x*32,0
998 IF pl%=1:SYS 46,&122,area%,screen$(scx,scy,z,x),z*64,512+x*32,8
999 IF pl%=2:SYS 46,&222,area%,B%(0),z*64,x*32-4,0
1000 IF pl%=2:SYS 46,&122,area%,screen$(scx,scy,z,x),z*64,x*32-4,8
1001 ENDPROC
1002 :
1003 DEF PROCcheckblock(scx,scy,z,x)
1004 feedback$=screen$(scx,scy,z,x)
1005 ENDPROC
1006 :
1007 DEF PROCprintbuls1
1008 CASE player% OF
1009 WHEN 1:IF weapon$(1)<>"0":PROCprintbuls1_1
1010 WHEN 2:IF weapon$(2)<>"0":PROCprintbuls1_2
1011 ENDCASE
1012 ENDPROC
1013 :
1014 DEF PROCprintbuls1_1
1015   bolls%=0
1016   REPEAT
1017     IF activbul(bolls%)<>0 THEN
1018       firefr1(bolls%)+=1
1019       IF firefr1(bolls%)>3:firefr1(bolls%)=0
1020       IF screenx(1)=fire1scx(bolls%) AND screeny(1)=fire1scy(bolls%) THEN
1021         IF weapon$(1)="wep0" THEN
1022           SYS 46,&122,area%,weapon$(1)+STR$(firefr1(bolls%)),fire1x(bolls%)*64,512+fire1y(bolls%)*32,8
1023         ELSE
1024           SYS 46,&122,area%,weapon$(1)+STR$(fire1dir(bolls%)),fire1x(bolls%)*64,512+fire1y(bolls%)*32,8
1025         ENDIF
1026       ENDIF
1027       IF YOUX(2)=fire1x(bolls%) AND YOUY(2)=fire1y(bolls%) AND screenx(2)=fire1scx(bolls%) AND screeny(2)=fire1scy(bolls%):PROChitplayer1
1028       IF screenx(2)=fire1scx(bolls%) AND screeny(2)=fire1scy(bolls%):PROCprintotherbuls
1029     ENDIF
1030     bolls%+=1
1031   UNTIL bolls%=11
1032 ENDPROC
1033 :
1034 DEF PROCprintotherbuls
1035   IF weapon$(1)="wep0" THEN
1036     SYS 46,&122,area%,weapon$(1)+STR$(firefr1(bolls%)),fire1x(bolls%)*64,fire1y(bolls%)*32-4,8
1037   ELSE
1038     SYS 46,&122,area%,weapon$(1)+STR$(fire1dir(bolls%)),fire1x(bolls%)*64,fire1y(bolls%)*32-4,8
1039   ENDIF
1040 ENDPROC
1041 :
1042 DEF PROCprintbuls1_2
1043   bolls%=0
1044   REPEAT
1045     IF activdos(bolls%)<>0 THEN
1046       firefr2(bolls%)+=1
1047       IF firefr2(bolls%)>3:firefr2(bolls%)=0
1048       IF screenx(2)=fire2scx(bolls%) AND screeny(2)=fire2scy(bolls%) THEN
1049         IF weapon$(2)="wep0" THEN
1050           SYS 46,&122,area%,weapon$(2)+STR$(firefr2(bolls%)),fire2x(bolls%)*64,fire2y(bolls%)*32-4,8
1051         ELSE
1052           SYS 46,&122,area%,weapon$(2)+STR$(fire2dir(bolls%)),fire2x(bolls%)*64,fire2y(bolls%)*32-4,8
1053         ENDIF
1054       ENDIF
1055       IF fire2x(bolls%)=YOUX(1) AND fire2y(bolls%)=YOUY(1) AND fire2scx(bolls%)=screenx(1) AND fire2scy(bolls%)=screeny(1):PROChitplayer2
1056       IF screenx(1)=fire2scx(bolls%) AND screeny(1)=fire2scy(bolls%):PROCprintotherbuls2
1057     ENDIF
1058     bolls%+=1
1059   UNTIL bolls%=11
1060 ENDPROC
1061 :
1062 DEF PROCprintotherbuls2
1063   IF weapon$(2)="wep0" THEN
1064     SYS 46,&122,area%,weapon$(2)+STR$(firefr2(bolls%)),fire2x(bolls%)*64,512+fire2y(bolls%)*32,8
1065   ELSE
1066     SYS 46,&122,area%,weapon$(2)+STR$(fire2dir(bolls%)),fire2x(bolls%)*64,512+fire2y(bolls%)*32,8
1067   ENDIF
1068 ENDPROC
1069 :
1070 REM Grab Screen
1071 DEF PROCgrab(pl%)
1072 IF pl%=1:SYS46,&110,grabtwo%,gg$,0,0,512,1280,1023:SYS46,&118,grabtwo%,gg$ TO,,bg2%:SYS46,&128,grabtwo%,gg$ TO,,,width2%,height2%
1073 IF pl%=2:SYS46,&110,grab%,g$,0,0,0,1280,508:SYS46,&118,grab%,g$ TO,,bg%:SYS46,&128,grab%,g$ TO,,,width%,height%
1074 ENDPROC
1075 :
1076 DEF PROCsortwepchange
1077 copy$=screen$(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%))
1078 backup$=copy$:screen$(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%))=weapon$(player%):weapon$(player%)=backup$
1079 SYS "XOS_CLI","CHANNEL. 4 Hit"
1080 SOUND4,-15,&400,100
1081 PROCclearblock(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%),player%)
1082 IF screenx(1)=screenx(2) AND screeny(1)=screeny(2):PROCsort2
1083 PROCgrab(player%):PROCprint
1084 ENDPROC
1085 :
1086 DEF PROCsort2
1087 IF player%=1:PROCclearblock(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%),2):PROCgrab(2)
1088 IF player%=2 THEN PROCclearblock(screenx(player%),screeny(player%),YOUX(player%),YOUY(player%),1):PROCgrab(1)
1089 ENDPROC
1090 :
1091 DEF PROCresetbul(p%)
1092 CASE p% OF
1093 WHEN 1:
1094 fire1scy(bolls%)=0:fire1scx(bolls%)=0
1095 fire1y(bolls%)=0:fire1x(bolls%)=0
1096 activbul(bolls%)=0
1097 WHEN 2:
1098 fire2scy(bolls%)=0:fire2scx(bolls%)=0
1099 fire2y(bolls%)=0:fire2x(bolls%)=0
1100 activdos(bolls%)=0
1101 ENDCASE
1102 ENDPROC
1103 :
1104 DEF PROCresetfire2(p%)
1105 CASE p% OF
1106 WHEN 1:
1107 fire1scy(bollets2%)=0:fire1scx(bollets2%)=0
1108 fire1y(bollets2%)=0:fire1x(bollets2%)=0
1109 activbul(bollets2%)=0:fire1range(bollets2%)=0
1110 WHEN 2:
1111 fire2scy(bullets%)=0:fire2scx(bullets%)=0
1112 fire2y(bullets%)=0:fire2x(bullets%)=0
1113 activdos(bullets%)=0:fire2range(bullets%)=0
1114 ENDCASE
1115 ENDPROC
1116 :
1117 DEF PROCprintenergy
1118 GCOL5
1119 IF energy(1)>0 AND energy(1)<184:RECTANGLE FILL1050,560,50,energy(1)
1120 IF energy(2)>0 AND energy(2)<184:RECTANGLE FILL1050,48,50,energy(2)
1121 IF energy(2)>=184:GCOL5:RECTANGLE FILL1050,48,50,184:GCOL7:LINE1075,48,1075,48+184:LINE1050,48+92,1075,48+184:LINE1100,48+92,1075,48+184
1122 IF energy(1)>=184:GCOL5:RECTANGLE FILL1050,560,50,184:GCOL7:LINE1075,560,1075,560+184:LINE1050,560+92,1075,560+184:LINE1100,560+92,1075,560+184
1123 :
1124 IF shield(2)=5:GCOL 11:RECTANGLE FILL1200,52,50,184
1125 IF shield(1)=5:GCOL 11:RECTANGLE FILL1200,564,50,184
1126 :
1127 IF shield(2)>0 THEN PROCprint_shields_2
1128 IF shield(1)>0 THEN PROCprint_shields_1
1129 IF weapon$(1)="0" THEN : ELSE SYS46,&122,area%,weapon$(1),1122,866,8
1130 IF weapon$(2)="0" THEN : ELSE SYS46,&122,area%,weapon$(2),1122,346,8
1131 ENDPROC
1132 :
1133 DEF PROCprintmaps
1134   REM use screenx(player%),screeny(player%) to determine position
1135   GCOL7:RECTANGLE FILL 1112,260,80,40
1136   RECTANGLE FILL 1112,780,80,40
1137   GCOL10:RECTANGLE FILL (1112+(screenx(1)*10)),(260+(screeny(1)*12)),10,5
1138   GCOL9:RECTANGLE FILL (1112+(screenx(2)*10)),(780+(screeny(2)*12)),10,5
1139 ENDPROC
1140 :
1141 DEF PROCprint_shields_2
1142 Y=0
1143 IF shield(2)<6 THEN
1144 FOR A%=1TOshield(2)
1145 SYS 46,&122,area%,"10",1192,56+Y,8
1146 Y+=36
1147 NEXT
1148 ENDIF
1149 ENDPROC
1150 :
1151 DEF PROCprint_shields_1
1152 Y=0
1153 IF shield(1)<6 THEN
1154 FOR A%=1TOshield(1)
1155 SYS 46,&122,area%,"10",1192,568+Y,8
1156 Y+=36
1157 NEXT
1158 ENDIF
1159 ENDPROC
1160 :
1161 DEF PROChitplayer1
1162 IF energy(2)>0 THEN
1163 IF energy(2)>0 AND shield(2)>0:SYS "XOS_CLI","CHANNEL. 6 Sides":SOUND6,-15,&4000,100
1164 IF energy(2)>0 AND shield(2)=0:SYS "XOS_CLI","CHANNEL. 2 ARG":SOUND2,-15,&3000,1
1165 ENDIF
1166 PROCresetbul(1)
1167 IF shield(2)<>0 THEN
1168 CASE weapon$(1) OF
1169 WHEN"wep0":reduce_shield(2)+=3
1170 WHEN"wep1":reduce_shield(2)+=2
1171 WHEN"wep2":reduce_shield(2)+=1
1172 WHEN"wep3":reduce_shield(2)+=0.5
1173 WHEN"wep4":reduce_shield(2)+=3
1174 ENDCASE
1175 IF reduce_shield(2)>5:reduce_shield(2)=0:shield(2)-=1
1176 ENDPROC
1177 ELSE
1178 IF weapon$(1)="wep0":energy(2)-=16
1179 IF weapon$(1)="wep1":energy(2)-=12
1180 IF weapon$(1)="wep2":energy(2)-=8
1181 IF weapon$(1)="wep3":energy(2)-=4
1182 IF weapon$(1)="wep4":energy(2)-=16
1183 hit2=1
1184 ENDIF
1185 ENDPROC
1186 :
1187 DEF PROChitplayer2
1188 IF energy(1)>0 THEN
1189 IF energy(1)>0 AND shield(1)>0:SYS "XOS_CLI","CHANNEL. 5 Sides":SOUND5,-15,&4000,100
1190 IF energy(1)>0 AND shield(1)=0:SYS "XOS_CLI","CHANNEL. 3 ARG":SOUND3,-15,&2000,1
1191 ENDIF
1192 PROCresetbul(2)
1193 IF shield(1)<>0 THEN
1194 CASE weapon$(2) OF
1195 WHEN"wep0":reduce_shield(1)+=3
1196 WHEN"wep1":reduce_shield(1)+=2
1197 WHEN"wep2":reduce_shield(1)+=1
1198 WHEN"wep3":reduce_shield(1)+=0.5
1199 WHEN"wep4":reduce_shield(1)+=3
1200 ENDCASE
1201 IF reduce_shield(1)>5:reduce_shield(1)=0:shield(1)-=1
1202 ENDPROC
1203 ELSE
1204 IF weapon$(2)="wep0":energy(1)-=16
1205 IF weapon$(2)="wep1":energy(1)-=12
1206 IF weapon$(2)="wep2":energy(1)-=8
1207 IF weapon$(2)="wep3":energy(1)-=4
1208 IF weapon$(2)="wep4":energy(1)-=16
1209 hit1=1
1210 ENDIF
1211 ENDPROC
1212 :
1213 DEF PROCdrawblood_pl1
1214 SYS46,&122,area%,"gore"+STR$(FNrnd(2)-1),YOUX(1)*64,512+YOUY(1)*32,8
1215 IF screenx(1)=screenx(2) AND screeny(1)=screeny(2):SYS46,&122,area%,"gore"+STR$(FNrnd(2)-1),YOUX(1)*64,YOUY(1)*32-4,8
1216 ENDPROC
1217 :
1218 DEF PROCdrawblood_pl2
1219 SYS46,&122,area%,"gore"+STR$(FNrnd(2)-1),YOUX(2)*64,YOUY(2)*32-4,8
1220 IF energy(2)>0 AND shield(2)=0 AND screenx(2)=screenx(1) AND screeny(2)=screeny(1):SYS46,&122,area%,"gore"+STR$(FNrnd(2)-1),YOUX(2)*64,512+YOUY(2)*32,8
1221 ENDPROC
1222 :
1223 DEF PROCfindwinner
1224 IF energy(1)<=0 AND energy(2)>0:playertwowin=TRUE
1225 IF energy(2)<=0 AND energy(1)>0:playeronewin=TRUE
1226 IF energy(1)<=0 AND energy(2)<=0:playerdraw=TRUE
1227 ENDPROC
1228 :
1229 DEF PROCprintwinner
1230 IF playeronewin OR playertwowin:speed-=2.2
1231 IF playerdraw:speed-=1.6
1232 IF speed<0:speed=0
1233 c+=speed
1234 IF playeronewin:PROCprintonewin(c)
1235 IF playertwowin:PROCprinttwowin(c)
1236 IF playerdraw:PROCprintdraw(c)
1237 IF ctl% AND 16:counttillend%=90
1238 ENDPROC
1239 :
1240 DEF PROCprintonewin(x)
1241 SYS46,&122,area%,"announce",x+80,210,8
1242 SYS46,&122,area%,"announce",x+80,710,8
1243 SYS46,&122,area%,"player1",x+320,706,8
1244 SYS46,&122,area%,"player2",x+314,206,8
1245 SYS46,&122,area%,"winner",x+600,710,8
1246 SYS46,&122,area%,"loser",x+600,210,8
1247 ENDPROC
1248 :
1249 DEF PROCprinttwowin(x)
1250 SYS46,&122,area%,"announce",x+80,210,8
1251 SYS46,&122,area%,"announce",x+80,710,8
1252 SYS46,&122,area%,"player1",x+320,706,8
1253 SYS46,&122,area%,"player2",x+314,206,8
1254 SYS46,&122,area%,"loser",x+600,710,8
1255 SYS46,&122,area%,"winner",x+600,210,8
1256 ENDPROC
1257 :
1258 DEF PROCprintdraw(x)
1259 SYS46,&122,area%,"draw!",x,210,8
1260 SYS46,256+34,area%,"draw!",x,710,8
1261 ENDPROC
1262 :
1263 DEF PROCdrawgraphics
1264 SYS46,&122,area%,"statforplay1",1030,516,8
1265 SYS46,&122,area%,"statforplay2",1030,0,8
1266 SYS46,&122,area%,"health",1058,12,8
1267 SYS46,&122,area%,"health",1058,524,8
1268 SYS46,&122,area%,"shield",1192,8,8
1269 SYS46,&122,area%,"shield",1192,524,8
1270 GCOL7
1271 RECTANGLE FILL1200,52,50,184
1272 RECTANGLE FILL1200,564,50,184
1273 RECTANGLE FILL1118,862,68,36
1274 RECTANGLE FILL1118,342,68,36
1275 RECTANGLE FILL1050,48,50,184
1276 RECTANGLE FILL1050,560,50,184
1277 GCOL0
1278 RECTANGLE1200,52,48,184
1279 RECTANGLE1202,52,48,184
1280 RECTANGLE1200,564,48,184
1281 RECTANGLE1202,564,48,184
1282 RECTANGLE1118,862,68,36
1283 RECTANGLE1118,342,68,36
1284 ENDPROC
1285 :
1286 DEF PROCsetupplayers
1287 screenx(1)=remem1sx
1288 screeny(1)=remem1sy
1289 screenx(2)=rememdossx
1290 screeny(2)=rememdossy
1291 YOUX(1)=remem1x
1292 YOUX(2)=rememdosx
1293 YOUY(1)=remem1y
1294 YOUY(2)=rememdosy
1295 xpos=0:ypos=0:anim()=0:energy()=50:shield()=0:weapon$()="0"
1296 fire1range()=0:fire2range()=0:firefr1()=0:firefr2()=0
1297 fire1=0:fire2=0:buld1=2:buld2=2
1298 dire$()="d":player%=1:keycheckrate=0:no1%=0:no2%=0
1299 checkdone%=0:noprint%=0:pause%=0:end%=0:counttillend%=0
1300 playeronewin=FALSE:playertwowin=FALSE:playerdraw=FALSE
1301 speed=60:c=-800
1302 hit1=0:hit2=0
1303 hitcounter1=0:hitcounter2=0
1304 ENDPROC
1305 :
1306 DEF PROCload_screens
1307 ab%=0:cd%=0
1308 REPEAT
1309 PROCloadscreen(ab%,cd%)
1310 ab%+=1:IF ab%>7:cd%+=1:ab%=0
1311 UNTIL cd%>3
1312 ENDPROC
1313 :
1314 REM Place game objects on map
1315 DEF PROCplaceobjects
1316 FOR abcd%=1 TO foodval
1317 REPEAT
1318 R1%=FNrnd(8)-1:R2%=FNrnd(4)-1:R3%=FNrnd(15):R4%=FNrnd(15):obj$=STR$(FNrnd(4)-1+11)
1319 UNTIL screen$(R1%,R2%,R3%,R4%)="0"
1320 screen$(R1%,R2%,R3%,R4%)=obj$
1321 NEXT
1322 :
1323 REM Place shields on map
1324 FOR abcd%=1 TO shldval
1325 REPEAT
1326 R1%=FNrnd(8)-1:R2%=FNrnd(4)-1:R3%=FNrnd(15):R4%=FNrnd(15):obj$="10"
1327 UNTIL screen$(R1%,R2%,R3%,R4%)="0"
1328 screen$(R1%,R2%,R3%,R4%)=obj$
1329 NEXT
1330 :
1331 REM Place teleporter potions on map.
1332 FOR abcd%=1 TO televal
1333 REPEAT
1334 R1%=FNrnd(8)-1:R2%=FNrnd(4)-1:R3%=FNrnd(15):R4%=FNrnd(15)
1335 UNTIL screen$(R1%,R2%,R3%,R4%)="0"
1336 screen$(R1%,R2%,R3%,R4%)="15"
1337 NEXT
1338 :
1339 REM Place weapons on map
1340 FOR abcde%=1 TO weapval
1341 REPEAT
1342 R1%=FNrnd(8)-1:R2%=FNrnd(4)-1:R3%=FNrnd(15):R4%=FNrnd(15):obj$="wep"+STR$(FNrnd(5)-1)
1343 UNTIL screen$(R1%,R2%,R3%,R4%)="0"
1344 screen$(R1%,R2%,R3%,R4%)=obj$
1345 NEXT
1346 ENDPROC
1347 :
1348 DEF PROCclearbanks
1349 SYS6,112,1
1350 SYS6,113,1
1351 VDU26:VDU4:COLOUR135:CLS
1352 SYS6,112,2
1353 SYS6,113,2
1354 COLOUR135:CLS
1355 SYS6,113,1
1356 SYS6,112,1
1357 ENDPROC
1358 :
1359 DEF PROCclearbanks2
1360 SYS6,112,1
1361 SYS6,113,1
1362 VDU26:VDU4:COLOUR128:CLS
1363 SYS6,112,2
1364 SYS6,113,2
1365 COLOUR128:CLS
1366 SYS6,113,1
1367 SYS6,112,1
1368 ENDPROC
1369 :
1370 DEF PROCreadkeys:REM Pads: 1 left, 2 right, 4 up, 8 down, 16 fire. ctl%: 1 pause, 2 sound off, 4 sound on, 8 quit, 16 skip winner
1371 pad%(1)=-(INKEY-98)-2*(INKEY-67)-4*(INKEY-68)-8*(INKEY-83)-16*(INKEY-84)
1372 pad%(2)=-(INKEY-108 OR INKEY-101)-2*(INKEY-125 OR INKEY-86)-4*(INKEY-27 OR INKEY-71)-8*(INKEY-109 OR INKEY-102)-16*(INKEY-59 OR INKEY-87)
1373 ctl%=-(INKEY-90)-2*(INKEY-17)-4*(INKEY-82)-8*(INKEY-97)-16*(INKEY-99)
1374 ENDPROC
1375 :
1376 DEF PROCseed(s%):REM The game's own random numbers: the same seed always gives the same game, unlike RND
1377 rnd%=s%:IF rnd%=0 THEN rnd%=1
1378 ENDPROC
1379 :
1380 DEF FNrnd(n%):REM 1 to n%, like RND(n%), from a xorshift generator
1381 rnd%=rnd% EOR (rnd%<<13)
1382 rnd%=rnd% EOR (rnd%>>>17)
1383 rnd%=rnd% EOR (rnd%<<5)
1384 =(rnd%>>>1) MOD n%+1
