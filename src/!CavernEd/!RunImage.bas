1 REM >!RunImage
2 REM Cavern Duel Editor
3 REM Version 1.38 (30th October, 2026) Desktop code moved to Dr Wimp 5.04
4 REM Version 1.37 (4th December, 1997) Final Release
5 REM Written and designed by Stephen Scott 1995, 1996, 1997
6 REM Desktop code by Dr Wimp: Andrew Ayre, Guy Bartle and Ray Favre
7 :
8 LIBRARY "<CavernEd$Dir>.DrWimp"
9 :
10 appname$="CavernEd":app_title$="Cavern Duel Editor"
11 ON ERROR PROCwimp_error(appname$,REPORT$+" at line "+STR$(ERL),1,"",0,0,"Quit "+appname$):PROCuser_error:PROCwimp_closedown:END
12 task%=FNwimp_initialise(appname$,4000,310,0)
13 PROCwimp_poll
14 END
15 :
16 REM ==================== Dr Wimp events ====================
17 :
18 DEF PROCuser_error
19 PROCunbox
20 ENDPROC
21 :
22 DEF PROCuser_initialise
23 REM ed% is the editor's own block; wimp% belongs to Dr Wimp
24 DIM ed% 255
25 PROCUser_SetInitialData
26 PROCCreate_Windows
27 PROCCreate_Menus
28 icon_bar%=FNwimp_iconbar("!caverned","",0,1)
29 ENDPROC
30 :
31 DEF FNuser_quit(type%)
32 IF update=FALSE THEN =1
33 REM Ask whether to save the changed cave first
34 quit_type%=type%
35 PROCopen(checker%)
36 PROCmousebox(checker%)
37 =0
38 :
39 DEF PROCuser_redraw(window%,minx%,miny%,maxx%,maxy%,printing%,page%)
40 IF window%=screen% THEN PROCdraw_cave(FNwimp_worktoscreen(window%,0,0),FNwimp_worktoscreen(window%,0,1))
41 ENDPROC
42 :
43 DEF PROCuser_mouseclick(window%,icon%,button%,workx%,worky%)
44 CASE window% OF
45 WHEN -2          : PROCUser_MouseBar
46 WHEN checker%    : PROCUser_Mousechecker(icon%)
47 WHEN screen%     : PROCUser_MouseScreen(button%,workx%,worky%)
48 WHEN Icons%      : PROCUser_Mouseicons(button%,icon%)
49 WHEN Map%        : PROCUser_Mousemap(icon%)
50 WHEN teleports%  : PROCUser_Mouseteleports(icon%)
51 ENDCASE
52 ENDPROC
53 :
54 DEF FNuser_menu(window%,icon%,screenx%,screeny%)
55 CASE window% OF
56 WHEN -2      : =Bar_Menu%
57 WHEN screen% : =Screen_Menu%
58 ENDCASE
59 =0
60 :
61 DEF PROCuser_openwindow(window%,x%,y%,stack%)
62 ENDPROC
63 :
64 DEF PROCuser_closewindow(window%)
65 CASE window% OF
66 WHEN screen%
67 main%=0
68 PROCwimp_closewindow(Icons%)
69 PROCwimp_closewindow(Map%)
70 PROCwimp_closewindow(teleports%)
71 tele_open=FALSE
72 WHEN savebox% : save=FALSE
73 WHEN checker% : PROCunbox
74 ENDCASE
75 ENDPROC
76 :
77 DEF FNuser_preclosewindow(window%)
78 =1
79 :
80 DEF FNuser_keypress(window%,icon%,key%)
81 IF window%<>teleports% THEN =0
82 CASE key% OF
83 WHEN 13  : IF icon%>=6 AND icon%<=9 THEN PROCupdate
84 WHEN 398 : PROCmove_caret(icon%,1)
85 WHEN 399 : PROCmove_caret(icon%,-1)
86 OTHERWISE: =0
87 ENDCASE
88 =1
89 :
90 DEF PROCuser_menuselection(menu%,item%,font$)
91 IF menu%=Bar_Menu% AND save=FALSE THEN
92 CASE item% OF
93 WHEN 2 : PROCwimp_starttask("Run CavernEd:!Help")
94 WHEN 3 : PROCwimp_quit(0)
95 ENDCASE
96 ENDIF
97 ENDPROC
98 :
99 DEF FNuser_savefiletype(window%)
100 IF window%=savebox% THEN ="022"
101 =""
102 :
103 DEF PROCuser_saveicon(window%,RETURN drag%,RETURN write%,RETURN ok%)
104 REM The savebox template uses Dr Wimp's default icons 0, 1 and 2
105 ENDPROC
106 :
107 DEF FNuser_savedata(path$,window%)
108 LOCAL ERROR
109 IF red=FALSE AND green=TRUE THEN PROCsave_refused("You haven't defined a location for the red player. The save operation has been cancelled."):=0
110 IF green=FALSE AND red=TRUE THEN PROCsave_refused("You haven't defined a location for the green player. The save operation has been cancelled."):=0
111 IF red=FALSE AND green=FALSE THEN PROCsave_refused("You haven't defined any locations for the red and green players. The save operation has been cancelled."):=0
112 IF path$<>"<Wimp$Scrap>" THEN
113 channel=OPENIN(path$)
114 IF channel<>0 THEN
115 CLOSE#channel:channel=0
116 IF NOT FNconfirm("This CaveFile already exists. Do you want to overwrite it ?") THEN PROCwimp_closewindow(savebox%):=0
117 ENDIF
118 ENDIF
119 channel=0
120 ON ERROR LOCAL PROCsave_failed:=0
121 PROCwrite_cave(path$)
122 PROCwimp_menuclose
123 update=FALSE
124 REM Saving from the "changed cave" box on Quit: carry on quitting
125 IF save THEN save=FALSE:PROCwimp_quit(quit_type%)
126 =1
127 :
128 DEF FNuser_help(window%,icon%)
129 =""
130 :
131 DEF FNuser_menuhelp(menu%,item%)
132 =""
133 :
134 DEF FNuser_loaddata(path$,window%,icon%,ftype$,workx%,worky%)
135 IF ftype$<>"022" THEN
136 REM window% is 0 when the Filer offers a file it is opening; stay quiet then
137 IF window%<>0 THEN PROCalert("This is not a CaveFile!")
138 =0
139 ENDIF
140 PROCload_cave(path$)
141 =1
142 :
143 DEF PROCuser_enteringwindow(window%)
144 ENDPROC
145 :
146 DEF PROCuser_leavingwindow(window%)
147 ENDPROC
148 :
149 DEF FNuser_pane(window%)
150 =-1
151 :
152 DEF PROCuser_null
153 ENDPROC
154 :
155 DEF PROCuser_menuopen(menu%,window%,icon%)
156 ENDPROC
157 :
158 DEF PROCuser_overmenuarrow(rootmenu%,rootmenuitem%,RETURN nextsubmenu%,nextsubmenunumber%,parentmenuitem%,x%,y%)
159 ENDPROC
160 :
161 DEF FNuser_sliderback(window%,icon%)
162 =-1
163 :
164 DEF FNuser_slider(window%,icon%)
165 =-1
166 :
167 DEF PROCuser_slidervalue(window%,icon%,pcent%,dir%)
168 ENDPROC
169 :
170 DEF PROCuser_modechange
171 ENDPROC
172 :
173 DEF PROCuser_declarefonts
174 ENDPROC
175 :
176 DEF PROCuser_print(minx%,miny%,maxx%,maxy%,page%)
177 ENDPROC
178 :
179 DEF FNuser_printing(copy%,page%,totpages%,pagepos%)
180 =0
181 :
182 DEF PROCuser_printerchange
183 ENDPROC
184 :
185 DEF PROCuser_colourpickerrgb(red%,green%,blue%,none%)
186 ENDPROC
187 :
188 DEF PROCuser_colourpickermodel(model%,value1,value2,value3,value4,none%)
189 ENDPROC
190 :
191 DEF PROCuser_wimpmessage(messagenumber%,block%,reasoncode%)
192 ENDPROC
193 :
194 DEF PROCuser_iconise(window%,RETURN text$,RETURN sprite$)
195 ENDPROC
196 :
197 DEF FNuser_dragicon(window%,icon%,button%)
198 =0
199 :
200 DEF PROCuser_seticondragbounds(startwindow%,dragicon%,dragbutton%,startmousex%,startmousey%,RETURN boundsminx%,RETURN boundsminy%,RETURN boundsmaxx%,RETURN boundsmaxy%)
201 ENDPROC
202 :
203 DEF PROCuser_draggingicon(startwindow%,dragicon%,dragbutton%,startmousex%,startmousey%,mousex%,mousey%,overwindow%,overicon%,dragboxminx%,dragboxminy%,dragboxmaxx%,dragboxmaxy%)
204 ENDPROC
205 :
206 DEF PROCuser_endicondrag(startwindow%,dragicon%,dragbutton%,startmousex%,startmousey%,dragboxminx%,dragboxminy%,dragboxmaxx%,dragboxmaxy%,endwindow%,endicon%,endmousex%,endmousey%)
207 ENDPROC
208 :
209 REM ==================== Setting up ====================
210 :
211 DEF PROCUser_SetInitialData
212 DIM screen$(7,3,16,16),youx(2),youy(2),yscx(2),yscy(2)
213 REM Set up 21 teleports (0-20)
214 DIM teletoscx(20),teletoscy(20),teletox(20),teletoy(20)
215 teletoscx()=0:teletoscy()=0:teletox()=0:teletoy()=0
216 DIM tscx(20),tscy(20),tx(20),ty(20),activ(20)
217 tscx()=0:tscy()=0:tx()=0:ty()=0:activ()=0
218 scx=0:scy=0:x=0:y=0
219 telenum%=0
220 protect%=0
221 defined=0
222 red=FALSE
223 green=FALSE
224 X=0:Y=0
225 SCX=0:SCY=0
226 REPEAT
227 screen$(SCX,SCY,X,Y)="0":REM Setup block
228 X+=1:IF X>16 THEN X=0:Y+=1
229 IF Y>16 THEN SCY+=1:X=0:Y=0
230 IF SCY>3 THEN SCX+=1:SCY=0:X=0:Y=0
231 UNTIL SCX>7
232 main%=0:oldicon%=0:reference=0:this%=0
233 update=FALSE:bitching=FALSE
234 tele_open=FALSE:draw$="1":erase$="0":s$=draw$
235 screen_x%=0:screen_y%=0
236 PROCload_sprites("<CavernEd$Dir>.DesSprs")
237 DIM pixtrans% 20,scalefac% 20
238 save=FALSE:quit_type%=0
239 ENDPROC
240 :
241 DEF PROCCreate_Windows
242 LOCAL t$
243 t$="<CavernEd$Dir>.Templates"
244 REM Icons in the map and icons windows are sprites from DesSprs
245 infobox%=FNwimp_loadwindow(t$,"info",0)
246 savebox%=FNwimp_loadwindow(t$,"savebox",0)
247 checker%=FNwimp_loadwindow(t$,"checker",0)
248 screen%=FNwimp_loadwindow(t$,"Screen",0)
249 Icons%=FNwimp_loadwindow(t$,"icons",sprites%)
250 Map%=FNwimp_loadwindow(t$,"map",sprites%)
251 teleports%=FNwimp_loadwindow(t$,"teleports",0)
252 ENDPROC
253 :
254 DEF PROCCreate_Menus
255 Bar_Menu%=FNwimp_createmenu("CavernEd/Info/Instructions/Quit",0)
256 PROCwimp_attachsubmenu(Bar_Menu%,1,infobox%)
257 Screen_Menu%=FNwimp_createmenu("Screen/Info/Save",0)
258 PROCwimp_attachsubmenu(Screen_Menu%,1,infobox%)
259 PROCwimp_attachsubmenu(Screen_Menu%,2,savebox%)
260 ENDPROC
261 :
262 DEF PROCload_sprites(pathname$)
263 LOCAL S%,T%
264 S%=OPENIN(pathname$):T%=EXT#S%+16:CLOSE#S%
265 DIM sprites% T%
266 !sprites%=T%:sprites%!8=0
267 SYS "OS_SpriteOp",&109,sprites%
268 SYS "OS_SpriteOp",&10A,sprites%,pathname$
269 ENDPROC
270 :
271 REM ==================== Windows ====================
272 :
273 DEF PROCopen(w%)
274 REM Open at the top of the stack, keeping the title bar on screen: the
275 REM templates were laid out for a high-resolution mode
276 LOCAL x%,y%,width%,sw%,sh%
277 !ed%=w%:SYS "Wimp_GetWindowState",,ed%
278 x%=ed%!4:y%=ed%!16:width%=ed%!12-ed%!4
279 sw%=FNscreen(11,4):sh%=FNscreen(12,5)
280 IF y%+48>sh% THEN y%=sh%-48
281 IF x%+width%>sw% THEN x%=sw%-width%
282 IF x%<0 THEN x%=0
283 PROCwimp_openwindowat(w%,x%,y%,-1)
284 ENDPROC
285 :
286 DEF FNscreen(limit%,eig%)
287 REM Screen width (11,4) or height (12,5) in OS units
288 LOCAL n%,e%
289 SYS "OS_ReadModeVariable",-1,limit% TO ,,n%
290 SYS "OS_ReadModeVariable",-1,eig% TO ,,e%
291 =(n%+1)<<e%
292 :
293 DEF PROCset_title
294 PROCwimp_putwindowtitle(screen%,"Map ("+STR$(screen_x%)+","+STR$(screen_y%)+")")
295 ENDPROC
296 :
297 DEF PROCshow_screen
298 PROCset_title
299 PROCwimp_redrawwindow(screen%)
300 ENDPROC
301 :
302 DEF PROCalert(message$)
303 PROCwimp_error(app_title$,message$,0,"",0,1,"")
304 ENDPROC
305 :
306 DEF FNconfirm(message$)
307 =FNwimp_errorchoice(app_title$,message$,0,4,"",0,1,1,"")=1
308 :
309 DEF PROCmousebox(w%)
310 !ed%=w%
311 SYS "Wimp_GetWindowOutline",,ed%
312 MOUSE RECTANGLE ed%!4+2,ed%!8+2,ed%!12-ed%!4-4,ed%!16-ed%!8-4
313 ENDPROC
314 :
315 DEF PROCunbox
316 MOUSE RECTANGLE 0,0,FNscreen(11,4),FNscreen(12,5)
317 ENDPROC
318 :
319 REM ==================== Drawing the cave ====================
320 :
321 DEF PROCdraw_cave(x_origin%,y_origin%)
322 LOCAL C,D,X,Y,a$
323 SYS "Wimp_ReadPixTrans",&100,sprites%,"5",0,0,0,scalefac%,pixtrans%
324 scalefac%!8=1:scalefac%!12=1
325 C=0:D=0
326 FOR Y=15 TO 0 STEP-1
327 FOR X=0 TO 15
328 a$=screen$(screen_x%,screen_y%,X,Y)
329 SYS&2E,256+52,sprites%,a$,(x_origin%+C),(y_origin%+D)-32,8,scalefac%,pixtrans%
330 C+=64
331 NEXT
332 C=0:D-=32
333 NEXT
334 REM Print "tel" sprite at destination of current teleport
335 IF tele_open THEN
336 SYS&2E,256+52,sprites%,"tel",(x_origin%+(teletox(reference))*64),(y_origin%-(16-teletoy(reference))*32),8,scalefac%,pixtrans%
337 ENDIF
338 ENDPROC
339 :
340 REM ==================== Mouse clicks ====================
341 :
342 DEF PROCUser_MouseBar
343 PROCopen(screen%)
344 PROCshow_screen
345 main%=1
346 IF protect%=0 PROCopen(Icons%)
347 PROCopen(Map%)
348 IF bitching=FALSE PROCwimp_puticontext(Map%,0,"mapdn"):bitching=TRUE:REM Set lower left icon down in map win
349 ENDPROC
350 :
351 DEF PROCUser_Mousechecker(icon%)
352 CASE icon% OF
353 WHEN 1 : REM Save, then carry on quitting
354 save=TRUE
355 PROCunbox
356 PROCwimp_closewindow(checker%)
357 PROCopen(savebox%)
358 WHEN 2 : REM Discard
359 PROCunbox
360 update=FALSE
361 PROCwimp_closewindow(checker%)
362 PROCwimp_quit(quit_type%)
363 WHEN 3 : REM Cancel
364 PROCunbox
365 PROCwimp_closewindow(checker%)
366 ENDCASE
367 ENDPROC
368 :
369 DEF PROCUser_MouseScreen(button%,workx%,worky%)
370 IF tele_open:PROCclicker(workx%,worky%):ENDPROC
371 IF protect% THEN ENDPROC
372 CASE button% OF
373 WHEN 4:s$=draw$
374 WHEN 1:s$=erase$
375 ENDCASE
376 mx=workx% DIV 64:my=(-worky%) DIV 32
377 IF mx<0 OR mx>15 OR my<0 OR my>15 THEN ENDPROC
378 update=TRUE
379 IF s$="7":IF screen$(screen_x%,screen_y%,mx,(15-my))="7":PROCtel:ENDPROC
380 CASE s$ OF
381 WHEN "7" : REM Staircase teleport
382 REM Location details now fixed into teleport info window
383 found%=0:ref=0
384 FOR find=0 TO 20
385 IF activ(find)=0 THEN found%=1:ref=find:find=20
386 NEXT
387 IF found%=0 THEN VDU7:ENDPROC
388 teletoscx(ref)=screen_x%
389 teletoscy(ref)=screen_y%
390 teletox(ref)=mx
391 teletoy(ref)=(15-my)
392 tscx(ref)=screen_x%
393 tscy(ref)=screen_y%
394 tx(ref)=mx
395 ty(ref)=(15-my)
396 activ(ref)=1
397 telenum%+=1:defined+=1:IF telenum%>20:VDU7:ENDPROC
398 WHEN "17":REM Green player
399 IF screen$(screen_x%,screen_y%,mx,(15-my))="18":VDU7:ENDPROC
400 IF screen$(screen_x%,screen_y%,mx,(15-my))="0"  THEN : ELSE VDU7:ENDPROC
401 IF green:screen$(yscx(1),yscy(1),youx(1),youy(1))="0"
402 PROCwimp_redrawwindow(screen%)
403 yscx(1)=screen_x%
404 yscy(1)=screen_y%
405 youx(1)=mx
406 youy(1)=(15-my):green=TRUE
407 WHEN "18":REM Red player
408 IF screen$(screen_x%,screen_y%,mx,(15-my))="17":VDU7:ENDPROC
409 IF screen$(screen_x%,screen_y%,mx,(15-my))="0"  THEN : ELSE VDU7:ENDPROC
410 IF red:screen$(yscx(2),yscy(2),youx(2),youy(2))="0"
411 PROCwimp_redrawwindow(screen%)
412 yscx(2)=screen_x%
413 yscy(2)=screen_y%
414 youx(2)=mx
415 youy(2)=(15-my):red=TRUE
416 ENDCASE
417 CASE screen$(screen_x%,screen_y%,mx,(15-my)) OF
418 WHEN "7":PROCerase_teleporter
419 WHEN "17":green=FALSE
420 WHEN "18":red=FALSE
421 ENDCASE
422 screen$(screen_x%,screen_y%,mx,(15-my))=s$
423 PROCwimp_updatewindow(screen%,mx*64,-(my+1)*32,(mx+1)*64,-my*32)
424 ENDPROC
425 :
426 DEF PROCclicker(workx%,worky%)
427 mx=workx% DIV 64:my=(-worky%) DIV 32
428 IF mx<0 OR mx>15 OR my<0 OR my>15 THEN ENDPROC
429 teletox(reference)=mx
430 teletoy(reference)=(15-my)
431 update=TRUE
432 PROCwimp_puticontext(teleports%,8,STR$(teletox(reference)))
433 PROCwimp_puticontext(teleports%,9,STR$(teletoy(reference)))
434 PROCwimp_redrawwindow(screen%)
435 ENDPROC
436 :
437 DEF PROCtel
438 PROCwimp_closewindow(Icons%)
439 update=0
440 reference=0
441 IF telenum%<20 THEN f%=telenum%:ELSE f%=20
442 FOR find=0 TO f%
443 IF tscx(find)=screen_x% AND tscy(find)=screen_y% AND tx(find)=mx AND ty(find)=(15-my) AND activ(find)=1 THEN reference=find:found3%=1:find=telenum%
444 NEXT
445 PROCwimp_puticontext(teleports%,6,STR$(teletoscx(reference)))
446 PROCwimp_puticontext(teleports%,7,STR$(teletoscy(reference)))
447 PROCwimp_puticontext(teleports%,8,STR$(teletox(reference)))
448 PROCwimp_puticontext(teleports%,9,STR$(teletoy(reference)))
449 PROCopen(teleports%):tele_open=TRUE
450 PROCwimp_puticontext(Map%,oldicon%,"mapup"):this%=oldicon%
451 screen_x%=teletoscx(reference):screen_y%=teletoscy(reference)
452 PROCupdatemap(1):REM Show teleport destination on map
453 PROCshow_screen
454 ENDPROC
455 :
456 DEF PROCerase_teleporter:IF s$="7"THEN ENDPROC
457 find=0
458 REPEAT
459 IF tscx(find)=screen_x% AND tscy(find)=screen_y% AND tx(find)=mx AND ty(find)=(15-my) THEN reference=find
460 find+=1
461 UNTIL find>20
462 activ(reference)=0:tscx(reference)=0:tscy(reference)=0
463 tx(reference)=0:ty(reference)=0
464 teletoscx(reference)=0:teletoscy(reference)=0
465 teletox(reference)=0:teletoy(reference)=0
466 telenum%-=1:defined-=1
467 IF telenum%<=0 telenum%=0
468 IF defined<=0 defined=0
469 IF defined<1 OR telenum%<1 THEN PROCwimp_closewindow(teleports%):tele_open=FALSE:PROCopen(Icons%)
470 ENDPROC
471 :
472 DEF PROCUser_Mouseicons(button%,icon%)
473 CASE button% OF
474 WHEN 4: REM Select
475 CASE icon% OF
476 REM Path icons
477 WHEN 16:PROCdrawIcon("0")
478 WHEN 17:PROCdrawIcon("5")
479 WHEN 18:PROCdrawIcon("8")
480 WHEN 19:PROCdrawIcon("9")
481 WHEN 20:PROCdrawIcon("16")
482 WHEN 21:PROCdrawIcon("19")
483 REM Item icons
484 WHEN 22:PROCdrawIcon("10")
485 WHEN 23:PROCdrawIcon("11")
486 WHEN 24:PROCdrawIcon("12")
487 WHEN 25:PROCdrawIcon("14")
488 WHEN 26:PROCdrawIcon("13")
489 WHEN 27:PROCdrawIcon("15")
490 REM Wall icons
491 WHEN 28:PROCdrawIcon("1")
492 WHEN 29:PROCdrawIcon("2")
493 WHEN 30:PROCdrawIcon("3")
494 WHEN 31:PROCdrawIcon("4")
495 REM Teleports
496 WHEN 32:PROCdrawIcon("6")
497 WHEN 33:PROCdrawIcon("7")
498 REM Players
499 WHEN 34:PROCdrawIcon("18")
500 WHEN 35:PROCdrawIcon("17")
501 ENDCASE
502 WHEN 1: REM Adjust
503 CASE icon% OF
504 WHEN 16:PROCeraseIcon("0")
505 WHEN 17:PROCeraseIcon("5")
506 WHEN 18:PROCeraseIcon("8")
507 WHEN 19:PROCeraseIcon("9")
508 WHEN 20:PROCeraseIcon("16")
509 WHEN 21:PROCeraseIcon("19")
510 REM Item icons
511 WHEN 22:PROCeraseIcon("10")
512 WHEN 23:PROCeraseIcon("11")
513 WHEN 24:PROCeraseIcon("12")
514 WHEN 25:PROCeraseIcon("14")
515 WHEN 26:PROCeraseIcon("13")
516 WHEN 27:PROCeraseIcon("15")
517 REM Wall icons
518 WHEN 28:PROCeraseIcon("1")
519 WHEN 29:PROCeraseIcon("2")
520 WHEN 30:PROCeraseIcon("3")
521 WHEN 31:PROCeraseIcon("4")
522 REM Teleports
523 WHEN 32:PROCeraseIcon("6")
524 WHEN 33:PROCeraseIcon("7")
525 REM Players
526 WHEN 34:PROCeraseIcon("18")
527 WHEN 35:PROCeraseIcon("17")
528 ENDCASE
529 ENDCASE
530 ENDPROC
531 :
532 DEF PROCdrawIcon(sp$)
533 PROCset_tile_icon(14,sp$)
534 draw$=sp$
535 ENDPROC
536 :
537 DEF PROCeraseIcon(sp$)
538 PROCset_tile_icon(15,sp$)
539 erase$=sp$
540 ENDPROC
541 :
542 DEF PROCset_tile_icon(icon%,sp$)
543 REM Icons 14 and 15 show the Select and Adjust tiles: rebuild with the new sprite
544 ed%!0=Icons%:ed%!4=icon%
545 SYS "Wimp_GetIconState",,ed%
546 IF $(ed%+28)<>sp$ THEN
547 $(ed%+28)=sp$
548 SYS "Wimp_DeleteIcon",,ed%
549 ed%!4=Icons%
550 SYS "Wimp_CreateIcon",,ed%+4
551 ed%!0=Icons%:ed%!4=icon%:ed%!8=0:ed%!12=0
552 SYS "Wimp_SetIconState",,ed%
553 ENDIF
554 ENDPROC
555 :
556 DEF PROCUser_Mousemap(icon%)
557 IF icon%<0 THEN ENDPROC
558 IF tele_open THEN PROCupdatemap(0)
559 PROCwimp_puticontext(Map%,oldicon%,"mapup")
560 PROCwimp_puticontext(Map%,icon%,"mapdn")
561 oldicon%=icon%
562 screen_x%=icon% MOD 8:screen_y%=icon% DIV 8
563 IF tele_open=TRUE THEN
564 teletoscx(reference)=screen_x%
565 teletoscy(reference)=screen_y%
566 PROCwimp_puticontext(teleports%,6,STR$(teletoscx(reference)))
567 PROCwimp_puticontext(teleports%,7,STR$(teletoscy(reference)))
568 ENDIF
569 PROCshow_screen
570 ENDPROC
571 :
572 DEF PROCupdate
573 screen_x%=teletoscx(reference):screen_y%=teletoscy(reference)
574 PROCshow_screen
575 ENDPROC
576 :
577 DEF PROCupdatemap(m)
578 IF m=0:PROCwimp_puticontext(Map%,(teletoscy(reference)*8)+teletoscx(reference),"mapup"):oldicon%=(teletoscy(reference)*8)+teletoscx(reference)
579 IF m=1:PROCwimp_puticontext(Map%,(teletoscy(reference)*8)+teletoscx(reference),"mapdn"):oldicon%=(teletoscy(reference)*8)+teletoscx(reference)
580 ENDPROC
581 :
582 DEF PROCUser_Mouseteleports(icon%)
583 CASE icon% OF
584 WHEN 11:
585 IF teletoscx(reference)<7 THEN
586 PROCupdatemap(0)
587 teletoscx(reference)+=1
588 PROCwimp_puticontext(teleports%,6,STR$(teletoscx(reference)))
589 PROCupdatemap(1):PROCupdate
590 ENDIF
591 WHEN 10:
592 IF teletoscx(reference)>0 THEN
593 PROCupdatemap(0)
594 teletoscx(reference)-=1
595 PROCwimp_puticontext(teleports%,6,STR$(teletoscx(reference)))
596 PROCupdatemap(1):PROCupdate
597 ENDIF
598 WHEN 13:
599 IF teletoscy(reference)<3 THEN
600 PROCupdatemap(0)
601 teletoscy(reference)+=1
602 PROCwimp_puticontext(teleports%,7,STR$(teletoscy(reference)))
603 PROCupdatemap(1):PROCupdate
604 ENDIF
605 WHEN 12:
606 IF teletoscy(reference)>0 THEN
607 PROCupdatemap(0)
608 teletoscy(reference)-=1
609 PROCwimp_puticontext(teleports%,7,STR$(teletoscy(reference)))
610 PROCupdatemap(1):PROCupdate
611 ENDIF
612 WHEN 15:
613 IF teletox(reference)<15 THEN teletox(reference)+=1:PROCwimp_puticontext(teleports%,8,STR$(teletox(reference))):PROCupdate
614 WHEN 14:
615 IF teletox(reference)>0:teletox(reference)-=1:PROCwimp_puticontext(teleports%,8,STR$(teletox(reference))):PROCupdate
616 WHEN 17:
617 IF teletoy(reference)<15:teletoy(reference)+=1:PROCwimp_puticontext(teleports%,9,STR$(teletoy(reference))):PROCupdate
618 WHEN 16:
619 IF teletoy(reference)>0:teletoy(reference)-=1:PROCwimp_puticontext(teleports%,9,STR$(teletoy(reference))):PROCupdate
620 WHEN 4:REM Cancel icon
621 PROCupdatemap(0)
622 teletoscx(reference)=tscx(reference)
623 teletoscy(reference)=tscy(reference)
624 teletox(reference)=tx(reference)
625 teletoy(reference)=ty(reference)
626 PROCwimp_puticontext(Map%,this%,"mapdn"):oldicon%=this%
627 PROCwimp_closewindow(teleports%):tele_open=FALSE
628 PROCopen(Icons%):PROCupdate
629 WHEN 5:REM OK icon
630 PROCupdatemap(1)
631 oldicon%=(teletoscy(reference)*8)+teletoscx(reference)
632 PROCwimp_closewindow(teleports%):tele_open=FALSE
633 PROCopen(Icons%):PROCupdate
634 ENDCASE
635 ENDPROC
636 :
637 DEF PROCmove_caret(I%,dir%)
638 IF I%=6 AND dir%=-1 PROCwimp_putcaret(teleports%,6,0):ENDPROC
639 IF I%=6 AND dir%=1 PROCwimp_putcaret(teleports%,7,0):ENDPROC
640 IF I%=7 AND dir%=-1 PROCwimp_putcaret(teleports%,6,0):ENDPROC
641 IF I%=7 AND dir%=1 PROCwimp_putcaret(teleports%,8,0):ENDPROC
642 IF I%=8 AND dir%=-1 PROCwimp_putcaret(teleports%,7,0):ENDPROC
643 IF I%=8 AND dir%=1 PROCwimp_putcaret(teleports%,9,0):ENDPROC
644 IF I%=9 AND dir%=-1 PROCwimp_putcaret(teleports%,8,0):ENDPROC
645 IF I%=9 AND dir%=1 PROCwimp_putcaret(teleports%,9,0):ENDPROC
646 ENDPROC
647 :
648 REM ==================== Loading and saving caves ====================
649 :
650 DEF PROCload_cave(file$)
651 IF update=TRUE THEN
652 IF NOT FNconfirm("The current CaveFile has been modified, are you sure you want to load a new one ?") THEN ENDPROC
653 update=FALSE
654 ENDIF
655 PROCwimp_puticontext(savebox%,1,file$)
656 x=0:y=15:scrx=0:scry=0:telenum%=0:backup%=0:defined=0
657 channel=OPENIN(file$)
658 a$=""
659 A$=CHR$(BGET#channel)
660 IF A$="#" THEN protect%=1:PROCalert("This CaveFile has been protected from alteration. The map editing and saving functions will be disabled!")
661 PROCwimp_closewindow(screen%)
662 IF protect%:PROCwimp_closewindow(Icons%)
663 IF protect%:PROCwimp_closewindow(teleports%):tele_open=FALSE
664 IF A$="*" THEN protect%=0
665 REPEAT
666 y=15
667 REPEAT
668 a$=CHR$(BGET#channel)
669 CASE a$ OF
670 WHEN "A":a$="12"
671 WHEN "B":a$="11"
672 WHEN "C":a$="10"
673 WHEN "D":a$="13"
674 WHEN "E":a$="14"
675 WHEN "F":a$="15"
676 WHEN "G":a$="16"
677 WHEN "P":a$="17":youx(1)=x:youy(1)=y:yscx(1)=scrx:yscy(1)=scry:green=TRUE
678 WHEN "Q":a$="18":youx(2)=x:youy(2)=y:yscx(2)=scrx:yscy(2)=scry:red=TRUE
679 WHEN "H":a$="19"
680 ENDCASE
681 screen$(scrx,scry,x,y)=a$
682 IF a$="7" :PROCread_details_of_teleport:telenum%+=1:backup%+=1:defined+=1
683 x+=1:IF x>15 THEN x=0:y-=1
684 UNTIL y<0
685 a$=CHR$(BGET#channel)
686 IF a$<>"-" THEN CLOSE#channel:channel=0:PROCalert("Damaged CaveFile. The load operation has been cancelled."):ENDPROC
687 scry+=1:IF scry>3 THEN scry=0:scrx+=1
688 UNTIL scrx>7
689 CLOSE#channel:channel=0
690 telenum%=backup%
691 FOR A%=telenum%+1 TO 20
692 activ(A%)=0
693 teletoscx(A%)=0:teletoscy(A%)=0:teletox(A%)=0:teletoy(A%)=0:tscx(A%)=0:tscy(A%)=0:tx(A%)=0:ty(A%)=0
694 NEXT
695 telenum%=1
696 PROCwimp_puticontext(teleports%,6,STR$(teletoscx(telenum%)))
697 PROCwimp_puticontext(teleports%,7,STR$(teletoscy(telenum%)))
698 PROCwimp_puticontext(teleports%,8,STR$(teletox(telenum%)))
699 PROCwimp_puticontext(teleports%,9,STR$(teletoy(telenum%)))
700 PROCopen(screen%)
701 PROCshow_screen
702 PROCopen(Map%)
703 IF protect%=0 THEN PROCopen(Icons%)
704 ENDPROC
705 :
706 DEF PROCread_details_of_teleport
707 IF telenum%>20 VDU7:ENDPROC
708 t1$=CHR$(BGET#channel)
709 t2$=CHR$(BGET#channel)
710 t3$=CHR$(BGET#channel):t4$=CHR$(BGET#channel)
711 activ(telenum%)=1
712 teletoscx(telenum%)=ASC(t1$)-65
713 teletoscy(telenum%)=ASC(t2$)-65
714 teletox(telenum%)=ASC(t3$)-65
715 teletoy(telenum%)=ASC(t4$)-65
716 tscx(telenum%)=scrx
717 tscy(telenum%)=scry
718 tx(telenum%)=x
719 ty(telenum%)=y
720 ENDPROC
721 :
722 DEF PROCwrite_cave(file$)
723 sc2x=0:sc2y=0:x=0:y=0
724 channel=OPENOUT(file$)
725 BPUT#channel,"*";
726 REPEAT
727 x=0:y=15
728 REPEAT:done=0
729 a$=screen$(sc2x,sc2y,x,y)
730 CASE a$ OF
731 WHEN "7":BPUT#channel,a$;:PROCsave_tele_details:done=1
732 WHEN "12":a$="A":done=1:BPUT#channel,a$;
733 WHEN "11":a$="B":done=1:BPUT#channel,a$;
734 WHEN "10":a$="C":done=1:BPUT#channel,a$;
735 WHEN "13":a$="D":done=1:BPUT#channel,a$;
736 WHEN "14":a$="E":done=1:BPUT#channel,a$;
737 WHEN "15":a$="F":done=1:BPUT#channel,a$;
738 WHEN "16":a$="G":done=1:BPUT#channel,a$;
739 WHEN "17":a$="P":done=1:BPUT#channel,a$;
740 WHEN "18":a$="Q":done=1:BPUT#channel,a$;
741 WHEN "19":a$="H":done=1:BPUT#channel,a$;
742 ENDCASE
743 IF done=0 THEN BPUT#channel,a$;
744 x+=1:IF x>15 THEN x=0:y-=1
745 UNTIL y<0
746 BPUT#channel,"-";
747 sc2y+=1:IF sc2y>3 THEN sc2x+=1:sc2y=0
748 UNTIL sc2x>7
749 CLOSE#channel:channel=0
750 ENDPROC
751 :
752 DEF PROCsave_tele_details:reference=0
753 IF telenum%<21 THEN FOR a%=0TOtelenum%:ELSE FOR a%=0TO20
754 IF tscx(a%)=sc2x AND tscy(a%)=sc2y AND tx(a%)=x AND ty(a%)=y THEN reference=a%:a%=telenum%
755 NEXT
756 BPUT#channel,CHR$(teletoscx(reference)+65);
757 BPUT#channel,CHR$(teletoscy(reference)+65);
758 BPUT#channel,CHR$(teletox(reference)+65);
759 BPUT#channel,CHR$(teletoy(reference)+65);
760 ENDPROC
761 :
762 DEF PROCsave_refused(message$)
763 PROCalert(message$)
764 PROCwimp_closewindow(savebox%)
765 PROCwimp_menuclose
766 ENDPROC
767 :
768 DEF PROCsave_failed
769 IF channel<>0 THEN CLOSE#channel:channel=0
770 IF ERR=67785 THEN
771 PROCwimp_error(app_title$,"Your disc is write protected.  Please write enable the disc and click to continue.",0,"",0,1,"")
772 ELSE
773 PROCwimp_error(app_title$,"This file could not be saved into the selected directory.",0,"",0,1,"")
774 ENDIF
775 ENDPROC
