1 REM >!RunImage
2 REM Cavern Duel Editor
3 REM Version 1.37 (4th December, 1997) Final Release
4 REM First fully multi-tasking version!
5 REM Written and designed by Stephen Scott 1995, 1996, 1997
6 REM Using WimpEd by Joe Taylor © Archimedes World 1992
7 :
8 SYS "Hourglass_On"
9 PROCWimp_Start("CavernEd",1900,2004)
10 PROCUser_SetInitialData
11 PROCCreate_Windows
12 PROCCreate_Menus
13 PROCWimp_MenuDisable(Screen_Menu%,3)
14 SYS "Hourglass_Off"
15 PROCWimp_WaitForEvent
16 PROCWimp_CloseDown
17 END
18 :
19 DEF PROCWimp_Start(TaskName$,wimp_memory%,icon%)
20 DIM wimp% wimp_memory%,icons% icon%
21 IF wimp_memory%<256 THEN wimp_memory%=256
22 icon_memory%=icons%+icon%
23 task$=TaskName$
24 indirect_sprites%=1 : direct_sprites%=1
25 PROCWimp_SetEventVariables
26 ON ERROR PROCWimp_Error:END
27 SYS"Wimp_Initialise",200,&4B534154,TaskName$ TO version%,task%
28 ENDPROC
29 :
30 DEF PROCWimp_SetEventVariables
31 DIM pointer_block% 20
32 interface%=FALSE
33 null%=1  :draw%=2 :  pointer_leaving%=1<<4
34 pointer_entering%=1<<5:mouse%=1<<6:drag%=1<<7
35 key%=1<<8:menu%=1<<9:scroll%=1<<10
36 lose_caret%=1<<11:gain_caret%=1<<12:message%=(1<<17)+(1<<18)
37 recorder%=1<<18:acknowledge%=1<<19:window%=0
38 sprites%=1:version%=0:task%=0
39 Bar_Window%=-2:Bar_Icon%=0:Bar_Menu%=0
40 x_origin%=0:y_origin%=0:SaveWindow%=-3
41 message_quit%=0:message_save%=2:message_load%=3
42 mouse_button%=2:save_event%=0
43 top_line%=0 : bottom_line%=0
44 ENDPROC
45 :
46 DEF PROCUser_SetInitialData
47 DIM screen$(7,3,16,16),youx(2),youy(2),yscx(2),yscy(2)
48 REM Set up 21 teleports (0-20)
49 DIM teletoscx(20),teletoscy(20),teletox(20),teletoy(20)
50 teletoscx()=0:teletoscy()=0:teletox()=0:teletoy()=0
51 DIM tscx(20),tscy(20),tx(20),ty(20),activ(20)
52 tscx()=0:tscy()=0:tx()=0:ty()=0:activ()=0
53 scx=0:scy=0:x=0:y=0
54 drawx=0:drawy=0
55 mouselock=0
56 selected=0
57 clear_selected=0
58 clearing=FALSE
59 loaded%=0
60 myownnumber%=0
61 xpos=0:ypos=0
62 telenum%=0
63 done1=0
64 done2=0
65 protect%=0
66 endloop%=0
67 defined=0
68 red=FALSE
69 green=FALSE
70 X=0:Y=0
71 SCX=0:SCY=0
72 REPEAT
73 screen$(SCX,SCY,X,Y)="0":REM Setup block
74 X+=1:IF X>16 THEN X=0:Y+=1
75 IF Y>16 THEN SCY+=1:X=0:Y=0
76 IF SCY>3 THEN SCX+=1:SCY=0:X=0:Y=0
77 UNTIL SCX>7
78 main%=0:oldicon%=0
79 DIM pal% 120:SYS "OS_File",12,"<CavernEd$Dir>.DesPal",pal%,0
80 update=FALSE:bitching=FALSE
81 tele_open=FALSE:draw$="1":erase$="0":s$=draw$
82 screen_x%=0:screen_y%=0
83 PROCWimp_SpritesPathLoad("<CavernEd$Dir>.DesSprs")
84 DIM pixtrans% 20,scalefac% 20
85 CD%=FALSE:save=FALSE
86 ENDPROC
87 :
88 DEF PROCCreate_Windows
89 infobox%=FNWimp_WindowLoad("info")
90 savebox%=FNWimp_WindowLoad("savebox")
91 checker%=FNWimp_WindowLoad("checker")
92 screen%=FNWimp_WindowLoad("Screen")
93 title%=wimp%!72:wimp%?35=&FF
94 Icons%=FNWimp_WindowLoad("icons")
95 Map%=FNWimp_WindowLoad("map")
96 wimp%!64=sprites%
97 teleports%=FNWimp_WindowLoad("teleports")
98 Bar_Icon%=FNWimp_IconBar("!caverned")
99 ENDPROC
100 :
101 DEF FNWimp_WindowLoad(window$)
102 =FNWimp_WindowLoadFrom(window$,"<Obey$Dir>.Templates")
103 :
104 DEF FNWimp_WindowLoadFrom(window$,template$)
105 LOCAL c%,i%,n%,j%,sp$,sp2$
106 SYS "Wimp_OpenTemplate",,template$
107 SYS "Wimp_LoadTemplate",,wimp%,icons%,icon_memory%,-1,window$,0 TO ,,icons%:PROCWimp_FitOnScreen
108 CASE sprites% OF
109 WHEN 1    : wimp%!64=sprites%
110 OTHERWISE : wimp%!64=FNEvent_Sprites(window%)
111 ENDCASE
112 SYS "Wimp_CreateWindow",,wimp% TO c%
113 SYS "Wimp_CloseTemplate"
114 SYS "Wimp_WhichIcon",c%,wimp%+40,1+2+(1<<8),2+(1<<8)
115 CASE wimp%!40 OF
116 WHEN -1   :
117 OTHERWISE : i%=40
118 REPEAT
119 wimp%!4=wimp%!i% : wimp%!0=c%
120 SYS "Wimp_GetIconState",,wimp%
121 sp$=FNWimp_GetStringAtAddress(wimp%!28)
122 SYS "Wimp_DeleteIcon",,wimp%
123 CASE sprites% OF
124 WHEN 1    : wimp%!32=1
125 OTHERWISE :
126 SYS "OS_SpriteOp",&108,sprites% TO ,,,n%
127 j%=0
128 REPEAT : j%+=1
129 SYS "OS_SpriteOp",&10D,sprites%,pointer_block%,20,j%
130 sp2$=FNWimp_GetStringAtAddress(pointer_block%)
131 UNTIL j%=n% OR sp$=sp2$
132 IF sp$=sp2$ THEN wimp%!32=sprites% ELSE wimp%!32=1
133 ENDCASE
134 wimp%!4=c%
135 SYS "Wimp_CreateIcon",,wimp%+4 TO handle%
136 i%+=4
137 UNTIL (wimp%!i%)=-1
138 ENDCASE
139 =c%
140 :
141 DEF FNWimp_IconBar(Sprite$)
142 LOCAL icon%
143 wimp%!0=-1
144 wimp%!4=0     : wimp%!8=0
145 wimp%!12=68 : wimp%!16=68
146 wimp%!20=&3002
147 $(wimp%+24)=Sprite$
148 SYS "Wimp_CreateIcon",,wimp% TO icon%
149 =icon%
150 :
151 DEF PROCWimp_WaitForEvent
152 LOCAL mask%,event%
153 finished%=FALSE
154 mask%=%111000011001
155 REPEAT
156 SYS"Wimp_Poll",mask%,wimp% TO event%
157 CASE event% OF
158 WHEN0 :
159 WHEN1 : PROCWimp_PollDrawWindow
160 WHEN2 : SYS "Wimp_OpenWindow",,wimp%
161 WHEN3 : PROCWimp_PollCloseWindow
162 WHEN4 :
163 WHEN5 :
164 WHEN6 : PROCWimp_PollMouseClick
165 WHEN7 : PROCWimp_PollSaveMessage
166 WHEN8 : PROCWimp_PollKeyPress
167 WHEN9 : PROCEvent_MenuChoice(menu%)
168 WHEN10:
169 WHEN11:
170 WHEN12:
171 WHEN17,18: PROCWimp_PollMessages
172 WHEN19:PROCack
173 ENDCASE
174 UNTIL finished%
175 ENDPROC
176 :
177 DEF PROCWimp_PollDrawWindow
178 LOCAL more%
179 SYS"Wimp_RedrawWindow",,wimp%TOmore%
180 window%=wimp%!0
181 window_x%=wimp%!4
182 window_y%=wimp%!16
183 scroll_x%=wimp%!20
184 scroll_y%=wimp%!24
185 x_origin%=window_x%-scroll_x%
186 y_origin%=window_y%-scroll_y%
187 WHILE more%
188 IF interface% THEN SYS"Wimp_BorderWindow",,wimp%
189 PROCEvent_Draw(window%,x_origin%,y_origin%)
190 SYS"Wimp_GetRectangle",,wimp%TOmore%
191 ENDWHILE
192 ENDPROC
193 DEF FNEvent_Save(window%)
194 CASE window% OF
195 WHEN savebox% :=TRUE
196 OTHERWISE :=FALSE
197 ENDCASE
198 :
199 DEF FNEvent_Sprites(window%)=sprites%
200 :
201 DEF PROCCreate_Menus
202 Bar_Menu%=FNWimp_MenuCreate("CavernEd\Info>infobox%\Instructions\Quit")
203 menu$="Screen\Info>infobox%\Save>savebox%"
204 Screen_Menu%=FNWimp_MenuCreate(menu$)
205 ENDPROC
206 :
207 DEF FNEvent_Menu(window%)
208 CASE window% OF
209 WHEN Bar_Window% : =Bar_Menu%
210 WHEN screen%     : =Screen_Menu%
211 OTHERWISE        : =FALSE
212 ENDCASE
213 :
214 DEF PROCEvent_WindowClose(window%,buttons%)
215 CASE window% OF
216 WHEN screen%
217 main%=0:iconw%=0:map%=0
218 PROCWimp_WindowClose(Icons%)
219 PROCWimp_WindowClose(Map%)
220 PROCWimp_WindowClose(teleports%)
221 tele_open=FALSE:REM bitching=TRUE
222 ENDCASE
223 ENDPROC
224 :
225 DEF PROCEvent_Draw(window%,x_origin%,y_origin%)
226 CASE window% OF
227 WHEN screen%      : PROCUser_DrawScreenWindow
228 ENDCASE
229 ENDPROC
230 :
231 DEF PROCpixtrans
232 FOR col%=0 TO 15:rgb%=pal%!2
233 SYS"ColourTrans_ReturnColourNumber",rgb% TO colour%
234 ?(pixtrans%+col%)=colour%:pal%+=6:NEXT
235 ENDPROC
236 :
237 DEF PROCUser_DrawScreenWindow
238 $title%="Map ("+STR$(screen_x%)+","+STR$(screen_y%)+")"
239 SYS "Wimp_ReadPixTrans",&100,sprites%,"5",0,0,0,scalefac%,pixtrans%
240 scalefac%!8=1:scalefac%!12=1
241 C=0:D=0
242 FOR Y=15 TO 0 STEP-1
243 FOR X=0 TO 15
244 a$=screen$(screen_x%,screen_y%,X,Y)
245 SYS&2E,256+52,sprites%,a$,(x_origin%+C),(y_origin%+D)-32,8,scalefac%,pixtrans%
246 C+=64
247 NEXT
248 C=0:D-=32
249 NEXT
250 REM Print "tel" sprite at destination of current teleport
251 IF tele_open THEN
252 SYS&2E,256+52,sprites%,"tel",(x_origin%+(teletox(reference))*64),(y_origin%-(16-teletoy(reference))*32),8,scalefac%,pixtrans%
253 ENDIF
254 ENDPROC
255 :
256 DEF PROCEvent_MouseClick(window%,icon%,button%,x%,y%)
257 CASE window% OF
258 WHEN Bar_Window% : PROCUser_MouseBar
259 WHEN checker%    : PROCUser_Mousechecker(button%,icon%)
260 WHEN screen%     : PROCUser_MouseScreen(button%,icon%)
261 WHEN Icons%      : PROCUser_Mouseicons(button%,icon%)
262 WHEN Map%     : PROCUser_Mousemap(button%,icon%)
263 WHEN teleports%  : PROCUser_Mouseteleports(button%,icon%)
264 ENDCASE
265 ENDPROC
266 :
267 DEF PROCUser_MouseBar
268 IF main%=1 OR save=FALSE THEN
269 PROCWimp_WindowBringToTop(screen%)
270 PROCWimp_WindowForceDraw(screen%)
271 ELSE
272 PROCWimp_WindowBringToTop(screen%)
273 main%=1
274 ENDIF
275 IF protect%=0 PROCWimp_WindowBringToTop(Icons%)
276 PROCWimp_WindowBringToTop(Map%):
277 IF bitching=FALSE PROCWimp_IconPutText(Map%,0,"mapdn"):bitching=TRUE:REM Set lower left icon down in map win
278 ENDPROC
279 :
280 DEF PROCUser_Mousechecker(button%,icon%)
281 IF icon%=1 THEN
282 save=TRUE
283 PROCunbox
284 PROCWimp_WindowClose(checker%)
285 update=FALSE
286 PROCWimp_WindowBringToTop(savebox%)
287 A$=FNWimp_IconText(savebox%,1)
288 PROCWimp_IconCaret(savebox%,1,LEN(A$))
289 ENDIF
290 IF icon%=2 THEN
291 PROCunbox
292 update=FALSE
293 PROCWimp_WindowClose(checker%)
294 CD%=TRUE
295 ENDIF
296 IF icon%=3 THEN REM Add routine to cancel & close window
297 PROCunbox
298 PROCWimp_WindowClose(checker%)
299 ENDIF
300 IF CD%=TRUE THEN PROCWimp_CloseDown
301 ENDPROC
302 :
303 DEF PROCUser_MouseScreen(button%,icon%)
304 IF tele_open:PROCclicker:ENDPROC
305 IF protect% THEN ENDPROC
306 CASE button% OF
307 WHEN 4:s$=draw$
308 WHEN 1:s$=erase$
309 ENDCASE
310 update=TRUE
311 mx=wimp%!0:my=wimp%!4
312 !wimp%=screen%:SYS "Wimp_GetWindowState",,wimp%
313 mx=(mx-wimp%!4+wimp%!20)
314 my=-(my-wimp%!16+wimp%!24)
315 mx=mx DIV 64:my=my DIV 32
316 IF my>63 OR mx>127 THEN ENDPROC
317 IF s$="7":IF screen$(screen_x%,screen_y%,mx,(15-my))="7":PROCtel:ENDPROC
318 CASE s$ OF
319 WHEN "7" : REM Staircase teleport
320 REM Location details now fixed into teleport info window
321 found%=0:ref=0
322 FOR find=0 TO 20
323 IF activ(find)=0 THEN found%=1:ref=find:find=20
324 NEXT
325 IF found%=0 THEN VDU7:ENDPROC
326 teletoscx(ref)=screen_x%
327 teletoscy(ref)=screen_y%
328 teletox(ref)=mx
329 teletoy(ref)=(15-my)
330 tscx(ref)=screen_x%
331 tscy(ref)=screen_y%
332 tx(ref)=mx
333 ty(ref)=(15-my)
334 activ(ref)=1
335 telenum%+=1:defined+=1:IF telenum%>20:VDU7:ENDPROC
336 WHEN "17":REM Green player
337 IF screen$(screen_x%,screen_y%,mx,(15-my))="18":VDU7:ENDPROC
338 IF screen$(screen_x%,screen_y%,mx,(15-my))="0"  THEN : ELSE VDU7:ENDPROC
339 IF green:screen$(yscx(1),yscy(1),youx(1),youy(1))="0"
340 PROCWimp_WindowForceDraw(screen%)
341 yscx(1)=screen_x%
342 yscy(1)=screen_y%
343 youx(1)=mx
344 youy(1)=(15-my):green=TRUE
345 WHEN "18":REM Red player
346 IF screen$(screen_x%,screen_y%,mx,(15-my))="17":VDU7:ENDPROC
347 IF screen$(screen_x%,screen_y%,mx,(15-my))="0"  THEN : ELSE VDU7:ENDPROC
348 IF red:screen$(yscx(2),yscy(2),youx(2),youy(2))="0"
349 PROCWimp_WindowForceDraw(screen%)
350 yscx(2)=screen_x%
351 yscy(2)=screen_y%
352 youx(2)=mx
353 youy(2)=(15-my):red=TRUE
354 ENDCASE
355 CASE screen$(screen_x%,screen_y%,mx,(15-my)) OF
356 WHEN "7":PROCerase_teleporter
357 WHEN "17":green=FALSE
358 WHEN "18":red=FALSE
359 ENDCASE
360 screen$(screen_x%,screen_y%,mx,(15-my))=s$
361 SYS "Wimp_ForceRedraw",screen%,mx*64,-(my+1)*32,(mx+1)*64,-(my)*32
362 ENDPROC
363 :
364 DEF PROCclicker
365 mx=wimp%!0:my=wimp%!4
366 !wimp%=screen%:SYS "Wimp_GetWindowState",,wimp%
367 mx=(mx-wimp%!4+wimp%!20)
368 my=-(my-wimp%!16+wimp%!24)
369 mx=mx DIV 64:my=my DIV 32
370 IF my>63 OR mx>127 THEN ENDPROC
371 teletox(reference)=mx
372 teletoy(reference)=(15-my)
373 REM c$=screen$(teletoscx(reference),teletoscy(reference),teletox(reference),teletoy(reference))
374 REM IFc$="1" OR c$="2" OR c$="3" OR c$="4" VDU7:ENDPROC
375 update=TRUE
376 PROCWimp_IconPutText(teleports%,8,STR$(teletox(reference)))
377 PROCWimp_IconPutText(teleports%,9,STR$(teletoy(reference)))
378 PROCWimp_WindowForceDraw(screen%)
379 PROCWimp_WindowClose(screen%)
380 PROCWimp_WindowOpen(screen%)
381 ENDPROC
382 :
383 DEF PROCrub1
384 screen$(screen_x%,screen_y%,mx,(15-my))="0"
385 ENDPROC
386 DEF PROCrub2
387 screen$(screen_x%,screen_y%,mx,(15-my))="0"
388 ENDPROC
389 :
390 DEF PROCtel
391 PROCWimp_WindowClose(Icons%)
392 update=0
393 reference=0
394 IF telenum%<20 THEN f%=telenum%:ELSE f%=20
395 FOR find=0 TO f%
396 IF tscx(find)=screen_x% AND tscy(find)=screen_y% AND tx(find)=mx AND ty(find)=(15-my) AND activ(find)=1 THEN reference=find:found3%=1:find=telenum%
397 NEXT
398 PROCWimp_IconPutText(teleports%,6,STR$(teletoscx(reference)))
399 PROCWimp_IconPutText(teleports%,7,STR$(teletoscy(reference)))
400 PROCWimp_IconPutText(teleports%,8,STR$(teletox(reference)))
401 PROCWimp_IconPutText(teleports%,9,STR$(teletoy(reference)))
402 PROCWimp_WindowOpen(teleports%):tele_open=TRUE
403 PROCWimp_IconPutText(Map%,oldicon%,"mapup"):this%=oldicon%
404 screen_x%=teletoscx(reference):screen_y%=teletoscy(reference)
405 $title%="Map ("+STR$(screen_x%)+","+STR$(screen_y%)+")"
406 PROCupdatemap(1):REM Show teleport destination on map
407 PROCWimp_WindowForceDraw(screen%)
408 PROCWimp_WindowClose(screen%)
409 PROCWimp_WindowOpen(screen%)
410 ENDPROC
411 :
412 DEF PROCerase_teleporter:IF s$="7"THEN ENDPROC
413 find=0
414 REPEAT
415 IF tscx(find)=screen_x% AND tscy(find)=screen_y% AND tx(find)=mx AND ty(find)=(15-my) THEN reference=find
416 find+=1
417 UNTIL find>20
418 IF activ(reference)=0 AND tscy(reference)>0 THEN activ(reference)=0
419 activ(reference)=0:tscx(reference)=0:tscy(reference)=0
420 tx(reference)=0:ty(reference)=0
421 teletoscx(reference)=0:teletoscy(reference)=0
422 teletox(reference)=0:teletoy(reference)=0
423 telenum%-=1:defined-=1
424 IF telenum%<=0 telenum%=0
425 IF defined<=0 defined=0
426 IF defined<1 OR telenum%<1 THEN PROCWimp_WindowClose(teleports%):tele_open=FALSE:PROCWimp_WindowOpen(Icons%)
427 ENDPROC
428 :
429 DEF PROCUser_Mouseicons( button%,icon%)
430 CASE button% OF
431 WHEN 4: REM Select
432 CASE icon% OF
433 REM Path icons
434 WHEN 16:PROCdrawIcon("0")
435 WHEN 17:PROCdrawIcon("5")
436 WHEN 18:PROCdrawIcon("8")
437 WHEN 19:PROCdrawIcon("9")
438 WHEN 20:PROCdrawIcon("16")
439 WHEN 21:PROCdrawIcon("19")
440 REM Item icons
441 WHEN 22:PROCdrawIcon("10")
442 WHEN 23:PROCdrawIcon("11")
443 WHEN 24:PROCdrawIcon("12")
444 WHEN 25:PROCdrawIcon("14")
445 WHEN 26:PROCdrawIcon("13")
446 WHEN 27:PROCdrawIcon("15")
447 REM Wall icons
448 WHEN 28:PROCdrawIcon("1")
449 WHEN 29:PROCdrawIcon("2")
450 WHEN 30:PROCdrawIcon("3")
451 WHEN 31:PROCdrawIcon("4")
452 REM Teleports
453 WHEN 32:PROCdrawIcon("6")
454 WHEN 33:PROCdrawIcon("7")
455 REM Players
456 WHEN 34:PROCdrawIcon("18")
457 WHEN 35:PROCdrawIcon("17")
458 ENDCASE
459 WHEN 1: REM Adjust
460 CASE icon% OF
461 WHEN 16:PROCeraseIcon("0")
462 WHEN 17:PROCeraseIcon("5")
463 WHEN 18:PROCeraseIcon("8")
464 WHEN 19:PROCeraseIcon("9")
465 WHEN 20:PROCeraseIcon("16")
466 WHEN 21:PROCeraseIcon("19")
467 REM Item icons
468 WHEN 22:PROCeraseIcon("10")
469 WHEN 23:PROCeraseIcon("11")
470 WHEN 24:PROCeraseIcon("12")
471 WHEN 25:PROCeraseIcon("14")
472 WHEN 26:PROCeraseIcon("13")
473 WHEN 27:PROCeraseIcon("15")
474 REM Wall icons
475 WHEN 28:PROCeraseIcon("1")
476 WHEN 29:PROCeraseIcon("2")
477 WHEN 30:PROCeraseIcon("3")
478 WHEN 31:PROCeraseIcon("40")
479 REM Teleports
480 WHEN 32:PROCeraseIcon("6")
481 WHEN 33:PROCeraseIcon("7")
482 REM Players
483 WHEN 34:PROCeraseIcon("18")
484 WHEN 35:PROCeraseIcon("17")
485 ENDCASE
486 ENDCASE
487 ENDPROC
488 :
489 DEF PROCdrawIcon(sp$)
490 wimp%!0=Icons%
491 wimp%!4=14
492 SYS "Wimp_GetIconState",,wimp%
493 IF $(wimp%+28)<>sp$ THEN
494 $(wimp%+28)=sp$
495 SYS "Wimp_DeleteIcon",,wimp%
496 wimp%!4=Icons%
497 SYS "Wimp_CreateIcon",,wimp%+4 TO ic%
498 wimp%!0=Icons%
499 wimp%!4=14
500 wimp%!8=0
501 wimp%!12=0
502 SYS "Wimp_SetIconState",,wimp%
503 ENDIF
504 draw$=sp$
505 ENDPROC
506 :
507 DEF PROCeraseIcon(sp$)
508 wimp%!0=Icons%
509 wimp%!4=15
510 SYS "Wimp_GetIconState",,wimp%
511 IF $(wimp%+28)<>sp$ THEN
512 $(wimp%+28)=sp$
513 SYS "Wimp_DeleteIcon",,wimp%
514 wimp%!4=Icons%
515 SYS "Wimp_CreateIcon",,wimp%+4 TO ic%
516 wimp%!0=Icons%
517 wimp%!4=15
518 wimp%!8=0
519 wimp%!12=0
520 SYS "Wimp_SetIconState",,wimp%
521 ENDIF
522 erase$=sp$
523 ENDPROC
524 :
525 DEF PROCUser_Mousemap(button%,icon%)
526 IF tele_open THEN PROCupdatemap(0)
527 PROCWimp_IconPutText(Map%,oldicon%,"mapup")
528 PROCWimp_IconPutText(Map%,icon%,"mapdn")
529 PROCWimp_WindowForceDraw(Map%)
530 oldicon%=icon%
531 CASE icon% OF
532 WHEN 0,1,2,3,4,5,6,7:screen_x%=icon%:screen_y%=0
533 WHEN 8,9,10,11,12,13,14,15:screen_x%=(icon%-8):screen_y%=1
534 WHEN 16,17,18,19,20,21,22,23:screen_x%=(icon%-16):screen_y%=2
535 WHEN 24,25,26,27,28,29,30,31:screen_x%=(icon%-24):screen_y%=3
536 ENDCASE
537 IF tele_open=TRUE THEN
538 teletoscx(reference)=screen_x%
539 teletoscy(reference)=screen_y%
540 PROCWimp_IconPutText(teleports%,6,STR$(teletoscx(reference)))
541 PROCWimp_IconPutText(teleports%,7,STR$(teletoscy(reference)))
542 ENDIF
543 $title%="Map ("+STR$(screen_x%)+","+STR$(screen_y%)+")"
544 PROCWimp_WindowForceDraw(screen%)
545 PROCWimp_WindowClose(screen%)
546 PROCWimp_WindowOpen(screen%)
547 ENDPROC
548 :
549 DEF PROCupdate
550 $title%="Map ("+STR$(teletoscx(reference))+","+STR$(teletoscy(reference))+")"
551 screen_x%=teletoscx(reference):screen_y%=teletoscy(reference)
552 PROCWimp_WindowForceDraw(screen%)
553 PROCWimp_WindowClose(screen%)
554 PROCWimp_WindowOpen(screen%)
555 ENDPROC
556 DEF PROCupdatemap(m)
557 IF m=0:PROCWimp_IconPutText(Map%,(teletoscy(reference)*8)+teletoscx(reference),"mapup"):oldicon%=(teletoscy(reference)*8)+teletoscx(reference)
558 IF m=1:PROCWimp_IconPutText(Map%,(teletoscy(reference)*8)+teletoscx(reference),"mapdn"):oldicon%=(teletoscy(reference)*8)+teletoscx(reference)
559 ENDPROC
560 :
561 DEF PROCUser_Mouseteleports(button%,icon%)
562 CASE icon% OF
563 WHEN 11:
564 IF teletoscx(reference)<7 THEN
565 PROCupdatemap(0)
566 teletoscx(reference)+=1
567 PROCWimp_IconPutText(teleports%,6,STR$(teletoscx(reference)))
568 PROCupdatemap(1):PROCupdate
569 ENDIF
570 WHEN 10:
571 IF teletoscx(reference)>0 THEN
572 PROCupdatemap(0)
573 teletoscx(reference)-=1
574 PROCWimp_IconPutText(teleports%,6,STR$(teletoscx(reference)))
575 PROCupdatemap(1):PROCupdate
576 ENDIF
577 WHEN 13:
578 IF teletoscy(reference)<3 THEN
579 PROCupdatemap(0)
580 teletoscy(reference)+=1
581 PROCWimp_IconPutText(teleports%,7,STR$(teletoscy(reference)))
582 PROCupdatemap(1):PROCupdate
583 ENDIF
584 WHEN 12:
585 IF teletoscy(reference)>0 THEN
586 PROCupdatemap(0)
587 teletoscy(reference)-=1
588 PROCWimp_IconPutText(teleports%,7,STR$(teletoscy(reference)))
589 PROCupdatemap(1):PROCupdate
590 ENDIF
591 WHEN 15:
592 IF teletox(reference)<15 THEN teletox(reference)+=1:PROCWimp_IconPutText(teleports%,8,STR$(teletox(reference))):PROCupdate
593 WHEN 14:
594 IF teletox(reference)>0:teletox(reference)-=1:PROCWimp_IconPutText(teleports%,8,STR$(teletox(reference))):PROCupdate
595 WHEN 17:
596 IF teletoy(reference)<15:teletoy(reference)+=1:PROCWimp_IconPutText(teleports%,9,STR$(teletoy(reference))):PROCupdate
597 WHEN 16:
598 IF teletoy(reference)>0:teletoy(reference)-=1:PROCWimp_IconPutText(teleports%,9,STR$(teletoy(reference))):PROCupdate
599 WHEN 4:REM Cancel icon
600 PROCupdatemap(0)
601 teletoscx(reference)=tscx(reference)
602 teletoscy(reference)=tscy(reference)
603 teletox(reference)=tx(reference)
604 teletoy(reference)=ty(reference)
605 PROCWimp_IconPutText(Map%,this%,"mapdn"):oldicon%=this%
606 PROCWimp_WindowClose(teleports%):tele_open=FALSE
607 PROCWimp_WindowOpen(Icons%):PROCupdate
608 WHEN 5:REM OK icon
609 PROCupdatemap(1)
610 oldicon%=(teletoscy(reference)*8)+teletoscx(reference)
611 PROCWimp_WindowClose(teleports%):tele_open=FALSE
612 PROCWimp_WindowOpen(Icons%):PROCupdate
613 ENDCASE
614 ENDPROC
615 :
616 DEF PROCEvent_KeyPress(window%,icon%,key%)
617 CASE window% OF
618 WHEN teleports%  : PROCUser_KeyPressteleports(icon%,key%)
619 ENDCASE
620 ENDPROC
621 :
622 DEF PROCUser_KeyPressteleports(icon%,key%)
623 CASE key% OF
624 WHEN 13:CASE icon% OF
625 WHEN 6:PROCupdate
626 WHEN 7:PROCupdate
627 WHEN 8:PROCupdate
628 WHEN 9:PROCupdate
629 ENDCASE
630 WHEN 398:PROCmove_caret(icon%,1)
631 WHEN 399:PROCmove_caret(icon%,-1)
632 OTHERWISE
633 SYS "Wimp_ProcessKey",key%
634 ENDCASE
635 ENDPROC
636 :
637 DEF PROCmove_caret(I%,dir%)
638 IF I%=6 AND dir%=-1 PROCWimp_IconCaret(teleports%,6,0):ENDPROC
639 IF I%=6 AND dir%=1 PROCWimp_IconCaret(teleports%,7,0):ENDPROC
640 IF I%=7 AND dir%=-1 PROCWimp_IconCaret(teleports%,6,0):ENDPROC
641 IF I%=7 AND dir%=1 PROCWimp_IconCaret(teleports%,8,0):ENDPROC
642 IF I%=8 AND dir%=-1 PROCWimp_IconCaret(teleports%,7,0):ENDPROC
643 IF I%=8 AND dir%=1 PROCWimp_IconCaret(teleports%,9,0):ENDPROC
644 IF I%=9 AND dir%=-1 PROCWimp_IconCaret(teleports%,8,0):ENDPROC
645 IF I%=9 AND dir%=1 PROCWimp_IconCaret(teleports%,9,0):ENDPROC
646 ENDPROC
647 :
648 DEF PROCEvent_MenuChoice(menu%)
649 CASE menu% OF
650 WHEN Bar_Menu%          : PROCUser_MenuChoiceBar
651 WHEN Screen_Menu%       : PROCUser_MenuChoiceScreen
652 ENDCASE
653 ENDPROC
654 :
655 DEF PROCUser_MenuChoiceBar
656 IF save=FALSE THEN
657 CASE FNWimp_MenuChoice(0) OF
658 WHEN 1 :
659 WHEN 2 : PROCopentext
660 WHEN 3 :
661 IF update=TRUE THEN
662 PROCWimp_WindowBringToTop(checker%)
663 PROCmousebox(checker%)
664 ENDIF
665 IF update=FALSE THEN finished%=TRUE
666 ENDCASE
667 ENDIF
668 ENDPROC
669 :
670 DEF PROCmousebox(w%)
671 wimp%!0=w%
672 SYS "Wimp_GetWindowOutline",,wimp%
673 MOUSE RECTANGLE wimp%!4+2,wimp%!8+2,wimp%!12-wimp%!4-4,wimp%!16-wimp%!8-4
674 ENDPROC
675 :
676 DEF PROCunbox
677 SYS "OS_ReadModeVariable",-1,11 TO ,,xpic
678 SYS "OS_ReadModeVariable",-1,12 TO ,,ypic
679 SYS "OS_ReadModeVariable",-1,4 TO ,,xfact
680 SYS "OS_ReadModeVariable",-1,5 TO ,,yfact
681 MOUSE RECTANGLE 0,0,xpic<<xfact,ypic<<yfact
682 ENDPROC
683 :
684 DEF PROCUser_MenuChoiceScreen
685 CASE FNWimp_MenuChoice(0) OF
686 WHEN 1 :
687 WHEN 2 :
688 WHEN 3 : IF telenum%>0 THEN
689 PROCWimp_WindowOpen(teleports%)
690 PROCWimp_WindowClose(Icons%):tele_open=TRUE
691 PROCWimp_IconPutText(Map%,oldicon%,"mapup")
692 oldicon%=(teletoscy(telenum%)*8)+teletoscx(telenum%)
693 PROCupdatemap(0):PROCupdatemap(1):PROCupdate
694 ENDIF
695 ENDCASE
696 ENDPROC
697 :
698 DEF PROCEvent_LoadFile(file$,type$)
699 IF type$<>"22":PROCWimp_WindowAlert("Cavern Duel Editor","This is not a CaveFile!"):ENDPROC
700 IF update=TRUE THEN
701 check%=FNWimp_WindowCancel("Cavern Duel Editor","The current CaveFile has been modified, are you sure you want to load a new one ?")
702 IF check%=TRUE THEN update=FALSE
703 IF check%=FALSE THEN update=TRUE:ENDPROC
704 ENDIF
705 PROCWimp_IconPutText(savebox%,1,file$)
706 SYS "Hourglass_On"
707 x=0:y=15:scrx=0:scry=0:telenum%=0:backup%=0:defined=0
708 channel=OPENIN(file$)
709 a$=""
710 A$=CHR$(BGET#channel)
711 IF A$="#" THEN protect%=1:PROCWimp_WindowAlert("Cavern Duel Editor","This CaveFile has been protected from alteration. The map editing and saving functions will be disabled!")
712 PROCWimp_WindowClose(screen%)
713 IF protect%:PROCWimp_WindowClose(Icons%)
714 IF protect%:PROCWimp_WindowClose(teleports%):tele_open=FALSE
715 IF A$="*" THEN protect%=0
716 REPEAT
717 y=15
718 REPEAT
719 a$=CHR$(BGET#channel)
720 CASE a$ OF
721 WHEN "A":a$="12"
722 WHEN "B":a$="11"
723 WHEN "C":a$="10"
724 WHEN "D":a$="13"
725 WHEN "E":a$="14"
726 WHEN "F":a$="15"
727 WHEN "G":a$="16"
728 WHEN "P":a$="17":youx(1)=x:youy(1)=y:yscx(1)=scrx:yscy(1)=scry:green=TRUE
729 WHEN "Q":a$="18":youx(2)=x:youy(2)=y:yscx(2)=scrx:yscy(2)=scry:red=TRUE
730 WHEN "H":a$="19"
731 ENDCASE
732 screen$(scrx,scry,x,y)=a$
733 IF a$="7" :PROCread_details_of_teleport:telenum%+=1:backup%+=1:defined+=1
734 x+=1:IF x>15 THEN x=0:y-=1
735 UNTIL y<0
736 a$=CHR$(BGET#channel)
737 IF a$<>"-" THEN SYS "XOS_CLI","Close":PROCWimp_WindowAlert("Cavern Duel Editor","Damaged CaveFile. The load operation has been cancelled."):ENDPROC
738 scry+=1:IF scry>3 THEN scry=0:scrx+=1
739 UNTIL scrx>7
740 SYS "XOS_CLI","Close"
741 telenum%=backup%
742 FOR A%=telenum%+1 TO 20
743 activ(A%)=0
744 teletoscx(A%)=0:teletoscy(A%)=0:teletox(A%)=0:teletoy(A%)=0:tscx(A%)=0:tscy(A%)=0:tx(A%)=0:ty(A%)=0
745 NEXT
746 safe%=TRUE
747 cave_loaded%=TRUE
748 sprite_deleted%=FALSE
749 telenum%=1
750 PROCWimp_IconPutText(teleports%,6,STR$(teletoscx(telenum%)))
751 PROCWimp_IconPutText(teleports%,7,STR$(teletoscy(telenum%)))
752 PROCWimp_IconPutText(teleports%,8,STR$(teletox(telenum%)))
753 PROCWimp_IconPutText(teleports%,9,STR$(teletoy(telenum%)))
754 SYS "Hourglass_Smash"
755 PROCWimp_WindowOpen(screen%)
756 PROCWimp_WindowForceDraw(screen%)
757 PROCWimp_WindowOpen(Map%)
758 PROCWimp_WindowOpen(Icons%)
759 ENDPROC
760 :
761 DEF PROCread_details_of_teleport
762 IF telenum%>20 VDU7:ENDPROC
763 t1$=CHR$(BGET#channel)
764 t2$=CHR$(BGET#channel)
765 t3$=CHR$(BGET#channel):t4$=CHR$(BGET#channel)
766 activ(telenum%)=1
767 teletoscx(telenum%)=ASC(t1$)-65
768 teletoscy(telenum%)=ASC(t2$)-65
769 teletox(telenum%)=ASC(t3$)-65
770 teletoy(telenum%)=ASC(t4$)-65
771 tscx(telenum%)=scrx
772 tscy(telenum%)=scry
773 tx(telenum%)=x
774 ty(telenum%)=y
775 ENDPROC
776 :
777 DEF PROCEvent_SaveFile(file$,window%)
778 CASE window% OF
779 WHEN savebox%
780 IF red=FALSE AND green=TRUE THEN PROCWimp_WindowAlert("Cavern Duel Editor","You haven't defined a location for the red player. The save operation has been cancelled."):PROCWimp_WindowClose(savebox%):PROCWimp_MenuClose:ENDPROC
781 IF green=FALSE AND red=TRUE THEN PROCWimp_WindowAlert("Cavern Duel Editor","You haven't defined a location for the green player. The save operation has been cancelled."):PROCWimp_WindowClose(savebox%):PROCWimp_MenuClose:ENDPROC
782 IF red=FALSE AND green=FALSE THEN PROCWimp_WindowAlert("Cavern Duel Editor","You haven't defined any locations for the red and green players. The save operation has been cancelled."):PROCWimp_WindowClose(savebox%):PROCWimp_MenuClose:ENDPROC
783 LOCAL ERROR
784 ON ERROR LOCAL PROCerr
785 channel=OPENIN(file$)
786 IF channel<>0 THEN
787 check%=FNWimp_WindowCancel("Cavern Duel Editor","This CaveFile already exists. Do you want to overwrite it ?")
788 IF check%=TRUE THEN channel=0
789 CLOSE#channel
790 IF check%=FALSE THEN PROCWimp_WindowClose(savebox%):ENDPROC
791 ENDIF
792 SYS "Hourglass_On"
793 sc2x=0:sc2y=0:x=0:y=0
794 channel=OPENOUT(file$)
795 BPUT#channel,"*";
796 REPEAT
797 x=0:y=15
798 REPEAT:done=0
799 a$=screen$(sc2x,sc2y,x,y)
800 CASE a$ OF
801 WHEN "7":BPUT#channel,a$;:PROCsave_tele_details:done=1
802 WHEN "12":a$="A":done=1:BPUT#channel,a$;
803 WHEN "11":a$="B":done=1:BPUT#channel,a$;
804 WHEN "10":a$="C":done=1:BPUT#channel,a$;
805 WHEN "13":a$="D":done=1:BPUT#channel,a$;
806 WHEN "14":a$="E":done=1:BPUT#channel,a$;
807 WHEN "15":a$="F":done=1:BPUT#channel,a$;
808 WHEN "16":a$="G":done=1:BPUT#channel,a$;
809 WHEN "17":a$="P":done=1:BPUT#channel,a$;
810 WHEN "18":a$="Q":done=1:BPUT#channel,a$;
811 WHEN "19":a$="H":done=1:BPUT#channel,a$;
812 ENDCASE
813 IF done=0 THEN BPUT#channel,a$;
814 x+=1:IF x>15 THEN x=0:y-=1
815 UNTIL y<0
816 BPUT#channel,"-";
817 sc2y+=1:IF sc2y>3 THEN sc2x+=1:sc2y=0
818 UNTIL sc2x>7
819 CLOSE#channel
820 PROCWimp_MenuClose
821 SYS "XOS_CLI","SetType "+file$+" 022"
822 ENDCASE
823 SYS "Hourglass_Off"
824 update=FALSE
825 ENDPROC
826 :
827 DEF PROCerr
828 IF ERR=67785 THEN
829 PROCWimp_WindowErrorBox("Cavern Duel Editor","Your disc is write protected.  Please write enable the disc and click to continue."):SYS"XOS_CLI","Close"
830 ELSE
831 PROCWimp_WIndowErrorBox("Cavern Duel Editor","This file could not be saved into the selected directory."):SYS "XOS_CLI","Close"
832 ENDIF
833 ENDPROC
834 :
835 DEF PROCsave_tele_details:reference=0
836 IF telenum%<21 THEN FOR a%=0TOtelenum%:ELSE FOR a%=0TO20
837 IF tscx(a%)=sc2x AND tscy(a%)=sc2y AND tx(a%)=x AND ty(a%)=y THEN reference=a%:a%=telenum%
838 NEXT
839 BPUT#channel,CHR$(teletoscx(reference)+65);
840 BPUT#channel,CHR$(teletoscy(reference)+65);
841 BPUT#channel,CHR$(teletox(reference)+65);
842 BPUT#channel,CHR$(teletoy(reference)+65);
843 ENDPROC
844 :
845 DEF PROCWimp_WindowAlert(title$,message$)
846 PROCWimp_WindowAlertBox(title$,message$,0)
847 ENDPROC
848 :
849 DEF PROCWimp_WindowAlertBox(title$,message$,button%)
850 LOCAL response%
851 $(wimp%+4)=message$
852 CASE button% OF
853 WHEN 2    : response%=1
854 WHEN 1    : response%=15
855 WHEN 3    : response%=(1<<5)+16
856 WHEN 4    : response%=(1<<6)+16
857 OTHERWISE : response%=16
858 ENDCASE
859 SYS "Wimp_ReportError",wimp%,response%,title$ TO ,response%
860 ENDPROC
861 :
862 DEF FNWimp_WindowCancel(title$,message$)
863 $(wimp%+4)=message$
864 response%=23
865 SYS "Wimp_ReportError",wimp%,response%,title$ TO ,response%
866 =response%-2
867 :
868 DEF PROCWimp_WindowErrorBox(title$,message$)
869 PROCWimp_WindowAlertBox(title$,message$,2)
870 ENDPROC
871 :
872 DEF FNWimp_WindowTitle(window%)
873 wimp%!0=window%
874 SYS "Wimp_GetWindowInfo",,wimp%
875 IF ((wimp%!60)AND&100)=0 ERROR 1,"Title isn't indirected"
876 =$(wimp%!76)
877 :
878 DEF PROCWimp_WindowBringToTop(window%)
879 !wimp%=window%
880 SYS "Wimp_GetWindowState",,wimp%
881 wimp%!28=-1
882 SYS "Wimp_OpenWindow",,wimp%
883 ENDPROC
884 :
885 DEF PROCWimp_WindowClose(window%)
886 !wimp%=window%
887 SYS "Wimp_CloseWindow",,wimp%
888 ENDPROC
889 :
890 DEF PROCWimp_WindowForceDraw(window%)
891 CASE window% OF
892  WHEN -1   : SYS "Wimp_ForceRedraw",-1,0,0,2*1280,2*1024
893 OTHERWISE : SYS "Wimp_ForceRedraw",window%,0,-2*1024,2*512,0
894 ENDCASE
895 ENDPROC
896 :
897 DEF PROCWimp_WindowOpen(window%)
898 !wimp%=window%
899 SYS "Wimp_GetWindowState",,wimp%
900 SYS "Wimp_OpenWindow",,wimp%
901 ENDPROC
902 :
903 PROCWimp_WindowInterface
904 SYS"Wimp_BorderWindow",,wimp%
905 ENDPROC
906 :
907 DEF PROCWimp_IconCaret(window%,icon%,chars%)
908 SYS "Wimp_SetCaretPosition",window%,icon%,,,-1,chars%
909 ENDPROC
910 :
911 DEF FNWimp_IconText(window%,icon%)
912 wimp%!0=window% : wimp%!4=icon%
913 SYS "Wimp_GetIconState",,wimp%
914 IF ((wimp%!24) AND &100)=0 ERROR 1,"Icon isn't indirected"
915 =$(wimp%!28)
916 :
917 DEF FNWimp_IconValidation(window%,icon%)
918 wimp%!0=window% : wimp%!4=icon%
919 SYS "Wimp_GetIconState",,wimp%
920 IF ((wimp%!24) AND &100)=0 ERROR 1,"Icon isn't indirected"
921 =$(wimp%!32)
922 :
923 DEF PROCWimp_IconDisable(window%,icon%)
924 wimp%!0=window% : wimp%!4=icon%
925 wimp%!8=1<<22   : wimp%!12=1<<22
926 SYS "Wimp_SetIconState",,wimp%
927 ENDPROC
928 :
929 DEF PROCWimp_IconEnable(window%,icon%)
930 wimp%!0=window% : wimp%!4=icon%
931 wimp%!8=0       : wimp%!12=1<<22
932 SYS "Wimp_SetIconState",,wimp%
933 ENDPROC
934 :
935 DEF PROCWimp_IconPutSprite(window%,icon%,sprite$)
936 wimp%!0=window%:wimp%!4=icon%
937 SYS "Wimp_GetIconState",,wimp%
938 SYS "Wimp_DeleteIcon",,wimp%
939 wimp%!4=wimp%!8   : wimp%!8=wimp%!12  : wimp%!12=wimp%!16
940 wimp%!16=wimp%!20 : wimp%!20=wimp%!24 : $(wimp%+24)=sprite$
941 SYS "Wimp_CreateIcon",,wimp% TO icon%:ENDPROC
942 :
943 DEF PROCWimp_IconPutText(window%,icon%,text$)
944 wimp%!0=window% : wimp%!4=icon%
945 SYS "Wimp_GetIconState",,wimp%
946 IF ((wimp%!24) AND &100)=0 ERROR 1,"Icon isn't indirected"
947 $(wimp%!28)=text$
948 wimp%!0=window% : wimp%!4=icon%
949 wimp%!8=0 : wimp%!12=0
950 SYS "Wimp_SetIconState",,wimp%
951 ENDPROC
952 :
953 DEF PROCWimp_IconInterfaceStart
954 SYS"Wimp_BorderIcon",,wimp%
955 ENDPROC
956 :
957 DEF PROCWimp_IconInterfaceFinish
958 wimp%!8=0
959 SYS"Wimp_BorderIcon",,wimp%
960 ENDPROC
961 :
962 DEF PROCWimp_MenuAdjustOn(menu%)
963 SYS "Wimp_GetPointerInfo",,pointer_block%
964 IF ((pointer_block%!8)AND1)=1 THEN SYS "Wimp_CreateMenu",,menu%,pointer_block%!0,pointer_block%!4
965 ENDPROC
966 :
967 DEF FNWimp_MenuChoice(level%)
968 =(wimp%!(4*level%))+1
969 :
970 DEF FNWimp_MenuCreate(menu$)
971 IF menu$="Colours" THEN=FNWimp_MenuColours
972 LOCAL menu%,index%,width%,length%,k%,s%
973 DIM menu% 28+FNWimp_MenuNoOfEntries(menu$)*24
974 menu%?12=7   : menu%?13=2  : menu%?14=7 :menu%?15=0
975 menu%!16=140 : menu%!20=44 : menu%!24=0
976 index%=menu%+28
977 $menu%=LEFT$(menu$,INSTR(menu$,"\")-1)
978 width%=LEN(LEFT$(menu$,INSTR(menu$,"\")-1))
979 menu$+="\" : Menu_NoOfEntries%=0
980 WHILE menu$<>""
981 menu$=MID$(menu$,INSTR(menu$,"\")+1)
982 CASE menu$ OF
983 WHEN ""
984 OTHERWISE :
985 !index%=0 : index%!4=-1 : index%!8=&7000021
986 length%=INSTR(menu$,"\")-1
987 k%=INSTR(LEFT$(menu$,length%),">")
988 CASE k% OF
989 WHEN 0
990 OTHERWISE
991 s%=EVAL(MID$(menu$,k%+1,length%-k%))
992 index%!4=s%
993 length%=k%-1
994 ENDCASE
995 $(index%+12)=LEFT$(menu$,length%)
996 IF length%>width% THEN width%=length%
997 index%+=24
998 ENDCASE
999 ENDWHILE
1000 menu%!16=16*(width%+1)
1001 index%!-24=index%!-24 OR &80 : =menu%
1002 :
1003 DEF FNWimp_MenuColours
1004 =FNWimp_MenuCreateColours(" ")
1005 :
1006 DEF FNWimp_MenuCreateColours(title$)
1007 LOCAL x$,men%,j%,i%
1008 x$=title$+"\0\1\2\3\4\5\6\7\8\9\10\11\12\13\14\15"
1009 men%=FNWimp_MenuCreate(x$)
1010 FOR i%=0 TO 15
1011 CASE TRUE OF
1012 WHEN i%<4,i%=9,i%=12,i%=14,i%=15 : j%=7
1013 OTHERWISE : j%=0
1014 ENDCASE
1015 men%?(39+i%*24)=i%*16+j%
1016 PROCWimp_MenuCentre(men%,i%+1)
1017 NEXT
1018 =men%
1019 :
1020 DEF FNWimp_MenuNoOfEntries(menu$)
1021 LOCAL n% ,j% : n%=0 : j%=0
1022 REPEAT
1023 j%=INSTR(menu$,"\",j%+1)
1024 IF j%<>0 THEN n%+=1
1025 UNTIL j%=0
1026 =n%
1027 :
1028 DEF PROCWimp_MenuBackGroundColour(menu%,item%,colour%)
1029 LOCAL fore%,i%
1030 fore%=(menu%?(39+(item%-1)*24))MOD16
1031 i%=((menu%?(39+(item%-1)*24))DIV16)MOD16
1032 menu%?(39+(item%-1)*24)=fore%+16*colour%+i%
1033 ENDPROC
1034 :
1035 DEF PROCWimp_MenuCentre(menu%,item%)
1036 menu%!(36+(item%-1)*24)=menu%!(36+(item%-1)*24)OR(1<<3)
1037 ENDPROC
1038 :
1039 DEF PROCWimp_MenuClose
1040 SYS "Wimp_CreateMenu",-1
1041 ENDPROC
1042 :
1043 DEF PROCWimp_MenuDisable(menu%,item%)
1044 menu%!(36+(item%-1)*24)=menu%!(36+(item%-1)*24)OR(1<<22)
1045 ENDPROC
1046 :
1047 DEF PROCWimp_MenuDottedLine(menu%,item%)
1048 menu%!(28+(item%-1)*24)=(menu%!(28+(item%-1)*24))OR2
1049 ENDPROC
1050 :
1051 DEF PROCWimp_MenuEnable(menu%,item%)
1052 PROCWimp_MenuDisable(menu%,item%)
1053 menu%!(36+(item%-1)*24)=menu%!(36+(item%-1)*24)EOR(1<<22)
1054 ENDPROC
1055 :
1056 DEF PROCWimp_MenuForegroundColour(menu%,item%,colour%)
1057 menu%?(39+(item%-1)*24)=colour%+16*((menu%?(39+(item%-1)*24))DIV16)
1058 ENDPROC
1059 :
1060 DEF PROCWimp_MenuGlue(menu1%,item%,menu2%)
1061 menu1%!(8+item%*24)=menu2%
1062 ENDPROC
1063 :
1064 DEF PROCWimp_MenuItem(menu%,item%,item$)
1065 $(menu%+(40+(item%-1)*24))=LEFT$(item$,12)+CHR$0
1066 ENDPROC
1067 :
1068 DEF PROCWimp_MenuMessage(menu%,item%)
1069 menu%!(28+(item%-1)*24)=(menu%!(28+(item%-1)*24))EOR(1<<3)
1070 ENDPROC
1071 :
1072 DEF PROCWimp_MenuPopUp(Menu%,x%,y%)
1073 menu%=Menu%
1074 SYS "Wimp_CreateMenu",,menu%,x%-64,y%+20
1075 ENDPROC
1076 :
1077 DEF PROCWimp_MenuPopUpBar(x%,y%)
1078 LOCAL n% : n%=0
1079 WHILE ((Bar_Menu%!(28+n%*24))AND%10000000)=0
1080 n%+=1
1081 ENDWHILE
1082 SYS "Wimp_CreateMenu",,Bar_Menu%,x%-64,96+n%*44
1083 menu%=Bar_Menu%
1084 ENDPROC
1085 :
1086 DEF PROCWimp_MenuTick(menu%,item%)
1087 menu%!(28+(item%-1)*24)=(menu%!(28+(item%-1)*24))EOR1
1088 ENDPROC
1089 :
1090 DEF PROCWimp_MenuTitle(menu%,title$)
1091 $menu%=LEFT$(title$,12)+CHR$0
1092 ENDPROC
1093 :
1094 DEF PROCWimp_MenuWrite(menu%,item%,buffer%,val%,BufferLength%)
1095 menu%!(28+(item%-1)*24)=(menu%!(28+(item%-1)*24))OR4
1096 menu%!(36+(item%-1)*24)=menu%!(36+(item%-1)*24)OR&100
1097 menu%!(40+(item%-1)*24)=buffer%
1098 menu%!(44+(item%-1)*24)=val%
1099 menu%!(48+(item%-1)*24)=BufferLength%
1100 ENDPROC
1101 :
1102 DEF PROCWimp_SpritesLoad
1103 PROCWimp_SpritesPathLoad("<Obey$Dir>.Sprites")
1104 direct_sprites%=sprites%
1105 ENDPROC
1106 :
1107 DEF PROCWimp_SpritesPathLoad(pathname$)
1108 LOCAL S%,T%
1109 S%=OPENIN(pathname$):T%=EXT#S%+16:CLOSE#S%
1110 DIM sprites%T%,spname%12
1111 !sprites%=T%:sprites%!8=0
1112 SYS"OS_SpriteOp",&109,sprites%
1113 SYS"OS_SpriteOp",&10A,sprites%,pathname$
1114 ENDPROC
1115 :
1116 DEF FNWimp_FileType(type%)
1117 CASE type%OF
1118 WHEN&FFF:="Text"
1119 WHEN&FFD:="Data"
1120 WHEN&FFB:="Basic"
1121 WHEN&FF9:="Sprite"
1122 WHEN&FED:="Palette"
1123 WHEN&FEC:="Template"
1124 WHEN&AFF:="Draw"
1125 WHEN&1000:="Folder"
1126 WHEN&2000:="Application"
1127 OTHERWISE=STR$~(type%)
1128 ENDCASE
1129 :
1130 DEF FNWimp_GetFilePathName
1131 =FNWimp_GetStringAtAddress(wimp%+44)
1132 :
1133 DEF FNWimp_FileLoad(pathname$)
1134 LOCAL S%,T%,file%
1135 S%=OPENIN pathname$
1136 T%=EXT#S%+16
1137 CLOSE#S%
1138 DIM file%T%
1139 SYS "XOS_CLI","Load"+pathname$+""+STR$~file%)
1140 =file%
1141 ;
1142 DEF FNWimp_GetStringAtAddress(array%)
1143 LOCAL s$:s$=""
1144 WHILE(?array%<>13)AND(?array%<>0):s$+=CHR$(?array%):array%+=1:ENDWHILE:
1145 =s$
1146 :
1147 DEF FNWimp_GetFileFromPathname(f$)
1148 CASE INSTR(f$,".") OF
1149 WHEN 0    :=f$
1150 OTHERWISE :=FNWimp_GetFileFromPathname(RIGHT$(f$,LEN(f$)-INSTR(f$,".")))
1151 ENDCASE
1152 :
1153 DEF PROCWimp_SendToEdit(file$)
1154 LOCAL n%
1155 wimp%!4=&6CC01C0C
1156 wimp%!16=5
1157 wimp%!36=0
1158 wimp%!40=&FFF
1159 $(wimp%+44)=file$+CHR$0
1160 n%=LEN file$+45
1161 IF n%MOD4 THEN !wimp%=4+(n%>>2)<<2 ELSE !wimp%=n%
1162 SYS "Wimp_SendMessage",17,wimp%,0
1163 ENDPROC
1164 :
1165 DEF PROCopentext
1166 !wimp%=256
1167 wimp%!12=0
1168 wimp%!16=5
1169 wimp%!36=0
1170 wimp%!40=&fff
1171 $(wimp%+44)="CavernEd:!Help"
1172 SYS "Wimp_SendMessage",18,wimp%,0
1173 ENDPROC
1174 :
1175 DEF FNWimp_BASICParameters
1176 LOCAL com$,param$,I%
1177 SYS "OS_GetEnv" TO com$
1178 params$=""
1179 I%=INSTR(com$," -quit ")
1180 IF I% THEN params$=MID$(com$,INSTR(com$," ",I%+LEN" -quit ")+1)
1181 =params$
1182 :
1183 DEF PROCWimp_Error
1184 LOCAL X$,x%
1185 ON ERROR OFF
1186 x%=ERL
1187 X$=REPORT$+" at line "+STR$(x%)
1188 DIM ErrorMsg%36
1189 ErrorMsg%!0=36:ErrorMsg%!12=0:ErrorMsg%!16=&81080:ErrorMsg%!20=x%
1190 $(ErrorMsg%+24)="!RunImage"
1191 SYS"Wimp_SendMessage",17,ErrorMsg%
1192 PROCWimp_WindowAlert(task$,X$)
1193 PROCWimp_CloseDown
1194 ENDPROC
1195 :
1196 DEF PROCWimp_CloseDown
1197 SYS"Wimp_CloseDown",task%,"TASK"
1198 ENDPROC
1199 :
1200 DEF PROCWimp_Quit
1201 finished%=TRUE
1202 ENDPROC
1203 :
1204 DEF FNWimp_ReadVariable(Variable$)
1205 LOCAL len%,result%,variable%
1206 $wimp%=Variable$
1207 SYS"OS_ReadVarVal",wimp%,wimp%+255,255,,3TO,,len%
1208 wimp%?(len%+255)=13
1209 =$(wimp%+255)
1210 :
1211 DEF PROCWimp_PollCloseWindow
1212 SYS "Wimp_GetPointerInfo",,wimp%
1213 window%=wimp%!12 : buttons%=wimp%!8
1214 PROCEvent_WindowClose(window%,buttons%)
1215 !wimp%=window% : SYS "Wimp_CloseWindow",,wimp%
1216 ENDPROC
1217 :
1218 DEF PROCWimp_PollMouseClick
1219 button%=wimp%!8:window%=wimp%!12:icon%=wimp%!16:x%=wimp%!0:y%=wimp%!4
1220 CASE button% OF
1221 WHEN2    : PROCWimp_PollMenuPopUp
1222 OTHERWISE: CASE FNEvent_Save(window%) OF
1223 WHEN TRUE : PROCWimp_PollMouseSave
1224 WHEN FALSE: PROCWimp_PollEventMouseClick
1225 ENDCASE
1226 ENDCASE
1227 ENDPROC
1228 :
1229 DEF PROCWimp_PollMenuPopUp
1230 menu%=FNEvent_Menu(window%)
1231 CASE menu%  OF
1232 WHEN FALSE:
1233 OTHERWISE :
1234 CASE window% OF
1235 WHEN -2   : n%=0
1236 WHILE ((Bar_Menu%!(28+n%*24))AND%10000000)=0
1237 n%+=1
1238 ENDWHILE
1239 SYS "Wimp_CreateMenu",,Bar_Menu%,x%-64,140+n%*44
1240 OTHERWISE : SYS"Wimp_CreateMenu",,menu%,x%-64,y%+20
1241 ENDCASE
1242 ENDCASE
1243 ENDPROC
1244 :
1245 DEF PROCWimp_PollMouseSave
1246 CASE icon% OF
1247 WHEN 0 : IF button% AND &50 THEN PROCWimp_PollDragBox(window%)
1248 WHEN 2 : IF button% AND 5 THEN  PROCWimp_PollSaveFile(window%)
1249 ENDCASE
1250 ENDPROC
1251 :
1252 DEF PROCWimp_PollEventMouseClick
1253 IF interface% THEN SYS"Wimp_BorderIcon",,wimp%
1254 PROCEvent_MouseClick(window%,icon%,button%,x%,y%)
1255 CASE  interface% OF
1256 WHEN TRUE :
1257 wimp%!0=x%:wimp%!4=y% : wimp%!8=0
1258 wimp%!12=window% : wimp%!16=icon%
1259 SYS"Wimp_BorderIcon",,wimp%
1260 ENDCASE
1261 ENDPROC
1262 :
1263 DEF PROCWimp_PollSaveFile(window%)
1264 LOCAL file$
1265 wimp%!0=window% : wimp%!4=1 : SYS "Wimp_GetIconState",,wimp%
1266 file$=$(wimp%!28)
1267 CASE INSTR(file$,".") OF
1268 WHEN 0   :
1269 $(wimp%+4)="To save, drag the icon to a directory window"
1270 SYS "Wimp_ReportError",wimp%,16,task$
1271 OTHERWISE:
1272 PROCEvent_SaveFile(file$,window%)
1273 ENDCASE
1274 SYS"Wimp_CreateMenu",-1
1275 IF save=TRUE THEN PROCWimp_CloseDown
1276 ENDPROC
1277 :
1278 DEF PROCWimp_PollDragBox(window%)
1279 LOCAL x%,y%
1280 save%=window%
1281 !wimp%=window%
1282 SYS"Wimp_GetWindowState",,wimp%
1283 x%=wimp%!4-wimp%!20:y%=wimp%!16-wimp%!24
1284 wimp%!4=0
1285 SYS"Wimp_GetIconState",,wimp%
1286 !wimp%=window%
1287 wimp%!4=5
1288 wimp%!8=x%+wimp%!8:wimp%!12=y%+wimp%!12
1289 wimp%!16=x%+wimp%!16:wimp%!20=y%+wimp%!20
1290 wimp%!24=0:wimp%!28=0
1291 wimp%!32=&7FFFFFFF:wimp%!36=&7FFFFFFF
1292 IF version%>=310 THEN
1293 SYS"DragASprite_Start",%11000101,1,"file_022",wimp%+8,wimp%+24
1294 ELSE
1295 SYS"Wimp_DragBox",,wimp%
1296 ENDIF
1297 ENDPROC
1298 :
1299 DEF PROCWimp_PollKeyPress
1300 window%=wimp%!0:icon%=wimp%!4:key%=wimp%!24
1301 CASE FNEvent_Save(window%) OF
1302 WHEN TRUE : PROCWimpPoll_SaveFile(window%)
1303 WHEN FALSE: PROCEvent_KeyPress(window%,icon%,key%)
1304 ENDCASE
1305 ENDPROC
1306 :
1307 DEF PROCWimp_PollSaveMessage
1308 LOCAL file$,window%,icon%,x%,y%
1309 SYS"Wimp_GetPointerInfo",,wimp%
1310 window%=wimp%!12:icon%=wimp%!16:x%=wimp%!0:y%=wimp%!4
1311 wimp%!0=save% : wimp%!4=1 : SYS "Wimp_GetIconState",,wimp%
1312 file$=$(wimp%!28)
1313 file$=FNWimp_GetFileFromPathname(file$)
1314 wimp%!20=window%
1315 wimp%!24=icon%
1316 wimp%!28=x%:wimp%!32=y%
1317 wimp%!36=length%
1318 wimp%!0=64
1319 wimp%!12=0
1320 wimp%!16=1
1321 wimp%!40=&FFF
1322 $(wimp%+44)=file$
1323 SYS"Wimp_SendMessage",17,wimp%,wimp%!20,wimp%!24
1324 ENDPROC
1325 :
1326 DEF PROCWimp_PollMessages
1327 LOCAL file$
1328 file$=FNWimp_GetStringAtAddress(wimp%+44)
1329 CASE wimp%!16 OF
1330 WHEN 0 : finished%=TRUE
1331 WHEN 1 :
1332 WHEN 2 :
1333 wimp%!0=save% : wimp%!4=1 : SYS "Wimp_GetIconState",,wimp%
1334 $(wimp%!28)=file$
1335 wimp%!0=save% : wimp%!4=1 : wimp%!8=0 : wimp%!12=0
1336 SYS "Wimp_SetIconState",,wimp%
1337 SYS "Wimp_SetCaretPosition",save%,1,,,-1,LEN file$
1338 PROCEvent_SaveFile(file$,save%)
1339 IF save=TRUE THEN PROCWimp_CloseDown
1340 WHEN 3
1341 type$=FNWimp_FileType(wimp%!40) : PROCEvent_LoadFile(file$,type$)
1342 ENDCASE
1343 ENDPROC
1344 :
1345 DEF PROCack
1346 IF wimp%!4=task% AND wimp%!16=5 THEN SYS "Wimp_StartTask","Run CavernEd:!Help"
1347 ENDPROC
1348 :
1349 DEF FNWimp_GetStringAtAddress(array%)
1350 LOCAL s$:s$=""
1351 WHILE(?array%<>13)AND(?array%<>0):s$+=CHR$(?array%):array%+=1:ENDWHILE:
1352 =s$
1353 :
1354 DEF FNWimp_GetFileFromPathname(f$)
1355 CASE INSTR(f$,".") OF
1356 WHEN 0    :=f$
1357 OTHERWISE :=FNWimp_GetFileFromPathname(RIGHT$(f$,LEN(f$)-INSTR(f$,".")))
1358 ENDCASE
1359 :
1360 DEF FNWimp_FileType(type%)
1361 CASE type%OF
1362 WHEN&FFF:="Text"
1363 WHEN&FFD:="Data"
1364 WHEN&FFB:="Basic"
1365 WHEN&FF9:="Sprite"
1366 WHEN&FED:="Palette"
1367 WHEN&FEC:="Template"
1368 WHEN&AFF:="Draw"
1369 WHEN&1000:="Folder"
1370 WHEN&2000:="Application"
1371 OTHERWISE=STR$~(type%)
1372 ENDCASE
1373 :
1374 DEF PROCWimp_FitOnScreen
1375 REM The templates were laid out for a high-resolution mode. Move a window
1376 REM whose title bar would be above the top of the screen, or past its right
1377 REM edge, back on screen so it can always be dragged.
1378 LOCAL w%,h%,x%,y%,d%
1379 SYS "OS_ReadModeVariable",-1,11 TO ,,w%
1380 SYS "OS_ReadModeVariable",-1,12 TO ,,h%
1381 SYS "OS_ReadModeVariable",-1,4 TO ,,x%
1382 SYS "OS_ReadModeVariable",-1,5 TO ,,y%
1383 w%=(w%+1)<<x%:h%=(h%+1)<<y%
1384 d%=wimp%!12+48-h%
1385 IF d%>0 THEN wimp%!4-=d%:wimp%!12-=d%
1386 IF wimp%!4<0 THEN wimp%!4=0
1387 d%=wimp%!8-w%
1388 IF d%>0 THEN wimp%!0-=d%:wimp%!8-=d%
1389 IF wimp%!0<0 THEN wimp%!0=0
1390 ENDPROC
