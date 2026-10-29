1 REM>DrWimp
2 REM © Andrew Ayre 1995-98
3 REM Major updates and additions by Guy Bartle
4 REM © Ray Favre - additions/changes 1999-2006
5 REM Version 4.70 (01-March-07)
6 REM
7 REM *** CONDITIONS OF USE ***
8 REM --------------------------------------------------------------------
9 REM The Dr Wimp package is distributed on an As Is basis, without
10 REM warranty. No liability can be accepted for any consequential loss or
11 REM damage, however caused, arising from the use of this package.
12 REM
13 REM The Dr Wimp package (apart from the 3rd party utilities as detailed in
14 REM the !!ReadMe!! file) may only be distributed as a whole. For
15 REM conditions of use of these 3rd party applications see their own !Help
16 REM files.
17 REM
18 REM Distribution of the Dr Wimp package (and programs constructed using
19 REM the DrWimp library) by third parties:
20 REM
21 REM Freeware. The DrWimp library may be distributed for free and without
22 REM the documentation, examples, utilities, etc. if it is being used as
23 REM part of a freeware product. (It would be nice if your documentation
24 REM acknowledged Dr Wimp - and don't forget that my web-site has a page
25 REM for links to your Dr Wimp applications, if you let me know .....)
26 REM
27 REM Shareware. Those using Dr Wimp to produce Shareware products must
28 REM donate 10% of the received income from these products to a charity of
29 REM their choice within 6 months of receiving the income. The Shareware
30 REM user-documentation must state prominently that this charity donation
31 REM is being made and also that Dr Wimp was used to produce the product.
32 REM The application's name and author should be notified to the Dr Wimp
33 REM copyright holder but no prior permission or further contact is needed.
34 REM
35 REM Commercial. If you wish to distribute the Dr Wimp package with a
36 REM commercial product (or distribute commercially a program that uses Dr
37 REM Wimp) then a specific licence is needed from the Dr Wimp copyright
38 REM holder.
39 REM
40 REM Public Domain libraries may make a reasonable charge for materials,
41 REM handling, etc. as long as this does not exceed £2.00 (UK) net for the
42 REM Dr Wimp package.
43 REM
44 REM The DrWimp library may be reproduced in part if crunching and mangling
45 REM utilities such as !BSquasher are used, otherwise it must be reproduced
46 REM in whole, complete with its opening REMs containing the Conditions of
47 REM Use and the copyright banner.
48 REM
49 REM If the DrWimp library is being reproduced in full then it may be added
50 REM to the !RunImage (or similar) file, and does not have to be separate.
51 REM
52 REM The author retains copyright of Dr Wimp, documentation and examples at
53 REM all times.
54 REM REM --------------------------------------------------------------------
55 REM You can download the latest version/upgrades from:
56 REM Web site: http://www.rayfavre.me.uk/
57 REM Or contact Ray Favre at:
58 REM 26 West Drayton Park Avenue, West Drayton, Middlesex, UB7 7QA, UK
59 REM email: drwimp@rayfavre.me.uk
60 REM --------------------------------------------------------------------
61 SYS "OS_CLI","Echo "
62 SYS "OS_CLI","Echo "
63 SYS "OS_CLI","Echo "+CHR$160+" You've just double-clicked on the Dr Wimp Library"
64 SYS "OS_CLI","Echo "
65 SYS "OS_CLI","Echo "
66 SYS "OS_CLI","Echo "+STRING$(5,CHR$160)+" Version 4.70 (01-Mar-07) "+CHR$(169)+" Ray Favre"
67 SYS "OS_CLI","Echo "
68 SYS "OS_CLI","Echo "
69 END
70 :
71 DEF FNwimp_libversion
72 =(4.70)*100
73 :
74 DEF FNwimp_initialise(n$,wimpmem%,ver%,desktopsave%)
75 LOCAL L%,N%
76 DIM wMsgs% 3
77 wMsgs%!0=0
78 SYS "Wimp_Initialise",ver%,&4B534154,n$,wMsgs% TO wCurrWimpversion%,wTask%
79 wappname$=n$
80 IF wimpmem%<320 THEN wimpmem%=320
81 wCurrOSversion%=FNwimp_osversion
82 wMaxMessagefiles%=16
83 DIM wMessagehandles%(wMaxMessagefiles%,2)
84 FOR N%=1 TO wMaxMessagefiles%
85     wMessagehandles%(N%,0)=-1
86 NEXT
87 wMessagefilecount%=0
88 wMessageout%=-1
89 wTemplatefile$=""
90 DIM wFontbuf% 255
91 DIM wFontbuftemp% 255
92 FOR L%=0 TO 255
93     wFontbuf%?L%=0
94 NEXT L%
95 DIM wTransformtext% 23
96 DIM wBBox% 35
97 DIM wMouseblk% 9
98 DIM wTempblk% 319
99 DIM wTempblk2% 319
100 DIM wScale% 15
101 DIM wSprcoltrans% 299
102 DIM wDmatrix% 23
103 DIM wDbbox% 15
104 DIM wimp% (wimpmem%-1)
105 DIM wPrintblock% 39
106 IF wCurrOSversion%<ver% THEN PROCwimp_error("WIMP","You need RISC OS "+STR$(ver%/100)+" or better to run this application.",1,1):SYS "Wimp_CloseDown":END
107 wBARTEXT%=FALSE
108 wBANNER%=FALSE
109 NULL%=FALSE
110 wFinished%=FALSE
111 wQuitsender%=-1
112 wPrinting%=FALSE
113 UNUSED%=FALSE
114 wICONISE%=FALSE
115 wSavedrag%=-1
116 wSavew%=-1
117 wSlidedrag%=-1
118 wSlidew%=-1
119 wSlidei%=-1
120 wIcondrag%=-1
121 wIconw%=-1
122 wIconi%=-1
123 wStartx%=0
124 wStarty%=0
125 wDragbutton%=0
126 wOx%=0
127 wOy%=0
128 wLen%=0
129 wLen2%=0
130 wSwid%=0
131 wShei%=0
132 wToPrinter%=0
133 wPrintFile$=""
134 wPrintFileType%=0
135 wDeleteFile%=0
136 wMaxdynamicareas%=16
137 DIM wDynamicarea%(wMaxdynamicareas%+1,1)
138 wDynamics%=0
139 wShutdown%=0
140 wMenuicon%=0
141 wHoldwhan%=0
142 wDesktopsave$=FNwimp_getsysvariable("Obey$Dir")
143 IF desktopsave%=0 THEN wDesktopsave%=FALSE ELSE wDesktopsave%=TRUE
144 wSubmenu%=1
145 SYS "OS_GetEnv" TO wEnvstr$
146 wColourblock%=-1
147 wPickerhandle%=0
148 wPickerwindow%=0
149 wSUBMENUCOLOURPICKER%=4
150 wColourdrag%=FALSE
151 wDirbuffer%=-1
152 wFONTMENU%=-1
153 wHeldmenu%=0
154 wFontmenubuflen%=255
155 wFontmenudepth%=0
156 wMaxdepth%=5
157 DIM wMenutree%(wMaxdepth%)
158 FOR N%=0 TO wMaxdepth%
159     wMenutree%(N%)=-1
160 NEXT
161 wConvert%=0
162 wDimsize%=36
163 wDateblk%=0
164 wStartupoption$=""
165 PROCuser_initialise
166 IF wTemplatefile$<>"" THEN SYS "Wimp_CloseTemplate"
167 wTemplatefile$=""
168 PROCwint_checkforload
169 =wTask%
170 :
171 DEF PROCwimp_error(title$,error$,button%,from%)
172 LOCAL pre$,flags%,ok%,cancel%
173 IF button%>2 OR button%<1 THEN button%=1
174 IF from%>2 OR from%<0 THEN from%=0
175 pre$=""
176 IF from%=1 THEN pre$="Error from "
177 IF from%=2 THEN pre$="Message from "
178 IF title$="" THEN title$=wappname$+" library"
179 from%=ABS(1-from%)
180 IF button%=1 THEN ok%=1:cancel%=0
181 IF button%=2 THEN ok%=0:cancel%=1
182 flags%=ok%+(cancel%<<1)+(0<<2)+(0<<3)+(1<<4)
183 wimp%!0=0
184 $(wimp%+4)=error$
185 SYS "Wimp_ReportError",wimp%,flags%,pre$+title$
186 ENDPROC
187 :
188 DEF FNwimp_errorchoice(title$,error$,from%)
189 LOCAL pre$,flags%,response%,return%
190 IF from%>2 OR from%<0 THEN from%=0
191 return%=FALSE
192 pre$=""
193 IF from%=2 THEN from%=0:pre$="Message from "
194 from%=ABS(1-from%)
195 flags%=1+(1<<1)+(0<<2)+(0<<3)+(from%<<4)
196 wimp%!0=0
197 $(wimp%+4)=error$
198 SYS "Wimp_ReportError",wimp%,flags%,pre$+title$ TO ,response%
199 IF response%=1 THEN return%=TRUE
200 =return%
201 :
202 DEF PROCwimp_poll
203 LOCAL reason%,mask%
204 wFinished%=FALSE
205 REPEAT
206     IF NULL%=FALSE AND wSlidedrag%=-1 AND wIcondrag%=-1 AND wBANNER%=FALSE THEN
207         mask%=1
208     ELSE
209         mask%=0
210     ENDIF
211     SYS "Wimp_Poll",mask%,wimp% TO reason%,wimp%
212     PROCwint_reasoncodes(reason%)
213 UNTIL wFinished%=TRUE
214 PROCwimp_closedown
215 ENDPROC
216 :
217 DEF PROCwint_reasoncodes(reason%)
218 CASE reason% OF
219     WHEN 0 : PROCwint_pollnull
220     WHEN 1 : PROCwint_pollredrawwindow(wimp%!0)
221     WHEN 2 : PROCwint_pollopenwindow(wimp%!0)
222     WHEN 3 : PROCwint_pollclosewindow(wimp%!0)
223     WHEN 4 : PROCuser_leavingwindow(wimp%!0)
224     WHEN 5 : PROCuser_enteringwindow(wimp%!0)
225     WHEN 6 : PROCwint_pollmouseclick(wimp%!12,wimp%!16,wimp%!8,wimp%!0,wimp%!4)
226     WHEN 7 : PROCwint_pollendofdrag(wimp%!0,wimp%!4,wimp%!8,wimp%!12)
227     WHEN 8 : PROCwint_pollkeypress(wimp%!0,wimp%!4,wimp%!24)
228     WHEN 9 : PROCwint_pollmenuselection
229     WHEN 10
230     WHEN 11
231     WHEN 12
232     WHEN 13
233     WHEN 14
234     WHEN 15
235     WHEN 16
236     WHEN 17,18 : PROCwint_pollmessage(wimp%!16,reason%)
237     WHEN 19 : IF UNUSED%=TRUE THEN PROCuser_wimpmessage(wimp%!16,wimp%,reason%)
238 ENDCASE
239 ENDPROC
240 :
241 DEF PROCwint_pollnull
242 LOCAL time%
243 IF NULL%=TRUE THEN PROCuser_null
244 IF wSlidedrag%<>-1 PROCwint_draggingslider
245 IF wIcondrag%<>-1 PROCwint_draggingicon
246 IF wBANNER%=TRUE THEN
247     SYS "OS_ReadMonotonicTime" TO time%
248     IF time%>wDelaymax% THEN
249         PROCwimp_closewindow(wBanner%)
250         wBANNER%=FALSE
251     ENDIF
252 ENDIF
253 ENDPROC
254 :
255 DEF PROCwint_pollredrawwindow(whan%)
256 LOCAL flag%
257 IF whan%<>wPickerwindow% THEN
258     SYS "Wimp_RedrawWindow",,wimp% TO flag%
259     WHILE flag%
260         PROCwint_savewimp
261         PROCuser_redraw(wimp%!0,wimp%!28,wimp%!32,wimp%!36,wimp%!40,FALSE,0)
262         PROCwint_loadwimp
263         SYS "Wimp_GetRectangle",,wimp% TO flag%
264     ENDWHILE
265 ENDIF
266 ENDPROC
267 :
268 DEF PROCwint_pollopenwindow(whan%)
269 IF whan%<>wPickerwindow% THEN
270     IF wICONISE%=FALSE THEN
271         IF FNuser_pane(whan%)=-1 THEN
272             SYS "Wimp_OpenWindow",,wimp%
273         ELSE
274             PROCwint_windowhaspane
275         ENDIF
276         PROCwint_checkuserpane(whan%,wimp%)
277         PROCwint_checksavewindow(whan%)
278     ENDIF
279     wICONISE%=FALSE
280 ENDIF
281 ENDPROC
282 :
283 DEF PROCwint_windowhaspane
284 LOCAL cstack%
285 IF wimp%!28<>-1 THEN
286     SYS "Wimp_OpenWindow",,wimp%
287 ELSE
288     wimp%!128=wimp%!0
289     SYS "Wimp_GetWindowState",,wimp%+128
290     cstack%=wimp%!(128+28)
291     wimp%!28=cstack%
292     SYS "Wimp_OpenWindow",,wimp%
293     wimp%!28=-1
294 ENDIF
295 ENDPROC
296 :
297 DEF PROCwint_pollclosewindow(whan%)
298 PROCwint_savewimp
299 IF FNuser_preclosewindow(whan%)=1 THEN
300     PROCwint_loadwimp
301     SYS "Wimp_CloseWindow",,wimp%
302     PROCuser_closewindow(whan%)
303 ENDIF
304 ENDPROC
305 :
306 DEF PROCwint_pollmouseclick(whan%,icon%,button%,mousex%,mousey%)
307 LOCAL done%,s%,drag%,write%,ok%,x%,y%
308 wColourdrag%=FALSE
309 IF whan%=wPickerwindow% THEN
310     wColourdrag%=TRUE
311 ELSE
312     done%=0
313     IF (button%=64 OR button%=16) AND (icon%>-1) THEN
314         PROCwint_startdrag(whan%,icon%,button%,mousex%,mousey%)
315         done%=1
316     ENDIF
317     IF done%<>1 THEN
318         IF FNuser_sliderback(whan%,icon%)<>-1 THEN
319             PROCwint_clickedslider(whan%,icon%,mousex%,mousey%)
320             done%=1
321         ENDIF
322     ENDIF
323     IF done%<>1 THEN
324         s%=FNuser_slider(whan%,icon%)
325         IF s%<>-1 THEN
326             PROCwint_clickedslider(whan%,s%,mousex%,mousey%)
327             done%=1
328         ENDIF
329     ENDIF
330     IF done%<>1 THEN
331         IF button%<>2 AND FNuser_savefiletype(whan%)<>"" THEN
332             drag%=0:write%=1:ok%=2
333             PROCuser_saveicon(whan%,drag%,write%,ok%)
334             IF icon%=ok% THEN
335                 PROCwint_quicksave(whan%,write%)
336                 done%=1
337             ENDIF
338         ENDIF
339     ENDIF
340     IF done%<>1 THEN
341         IF button%<>2 THEN
342             x%=FNwimp_screentowork(whan%,mousex%,0)
343             y%=FNwimp_screentowork(whan%,mousey%,1)
344             PROCuser_mouseclick(whan%,icon%,button%,x%,y%)
345         ELSE
346             PROCwint_menuclick(whan%,icon%,mousex%,mousey%)
347         ENDIF
348     ENDIF
349 ENDIF
350 ENDPROC
351 :
352 DEF PROCwint_menuclick(whan%,icon%,mousex%,mousey%)
353 LOCAL menu%,yalt%
354 wHoldwhan%=0
355 menu%=FNuser_menu(whan%,icon%,mousex%,mousey%)
356 IF menu%<>0 THEN
357     wHoldwhan%=whan%
358     IF (menu% AND 1)=0 THEN
359         IF !(menu%-4)=-1 THEN wFONTMENU%=menu%
360     ENDIF
361     wMenuicon%=icon%
362     CASE whan% OF
363         WHEN -2
364         yalt%=FNwint_iconbardottedlinemenusize(menu%)
365         PROCuser_menuopen(menu%,wHoldwhan%,wMenuicon%)
366         SYS "Wimp_CreateMenu",,menu%,mousex%-64,yalt%
367         OTHERWISE
368         PROCuser_menuopen(menu%,wHoldwhan%,wMenuicon%)
369         SYS "Wimp_CreateMenu",,menu%,mousex%-64,mousey%
370     ENDCASE
371     PROCwint_checksavewindow(menu%)
372     wLastmenu%=menu%
373 ENDIF
374 ENDPROC
375 :
376 DEF FNwint_iconbardottedlinemenusize(menu%)
377 LOCAL menusize%,menuposy%,item%,startbyte%,dottedline%
378 menusize%=FNwimp_menusize(menu%)
379 menuposy%=(menusize%*44)+96
380 FOR item%=1 TO menusize%
381     startbyte%=menu%+28+(24*(item%-1))
382     dottedline%=((?startbyte%>>1) AND 1)
383     IF dottedline%=1 THEN
384         menuposy%+=24
385     ENDIF
386 NEXT
387 =menuposy%
388 :
389 DEF PROCwint_pollendofdrag(dragboxminx%,dragboxminy%,dragboxmaxx%,dragboxmaxy%)
390 IF wColourdrag%=TRUE THEN
391     wColourdrag%=FALSE
392 ELSE
393     IF wSavedrag%=-1 THEN
394         IF wSlidedrag%<>-1 THEN
395             PROCwint_endsliderdrag
396         ELSE
397             PROCwint_endicondrag(dragboxminx%,dragboxminy%,dragboxmaxx%,dragboxmaxy%)
398         ENDIF
399     ELSE
400         PROCwint_endsavedrag
401     ENDIF
402 ENDIF
403 ENDPROC
404 :
405 DEF PROCwint_pollkeypress(whan%,icon%,key%)
406 LOCAL done%,drag%,write%,ok%
407 IF whan%<>wPickerwindow% THEN
408     done%=0
409     IF FNuser_savefiletype(whan%)<>"" AND key%=13 THEN
410         drag%=0:write%=1:ok%=2
411         PROCuser_saveicon(whan%,drag%,write%,ok%)
412         IF icon%=write% THEN
413             PROCwint_quicksave(whan%,write%)
414             done%=1
415         ENDIF
416     ENDIF
417     IF done%<>1 THEN
418         PROCwint_savewimp
419         done%=FNuser_keypress(whan%,icon%,key%)
420         PROCwint_loadwimp
421         IF done%=0 THEN SYS "Wimp_ProcessKey",key%
422     ENDIF
423 ENDIF
424 ENDPROC
425 :
426 DEF PROCwint_pollmenuselection
427 LOCAL font$,fontname%,FontDecode%,A%,N%,Slash%,selection%,menu%,item%
428 IF wLastmenu%<>wHeldmenu% AND wHeldmenu%<>0 THEN
429     FOR N%=0 TO wMaxdepth%
430         wMenutree%(N%)=-1
431     NEXT
432 ENDIF
433 font$=""
434 FontDecode%=FALSE
435 CASE TRUE OF
436     WHEN (wLastmenu%=wFONTMENU%)
437     wFontmenudepth%=0
438     FontDecode%=TRUE
439     WHEN (wFontmenudepth%>0)
440     FontDecode%=TRUE
441     IF wReopened%=TRUE THEN
442         FontDecode%=FNwint_fontmenutree
443     ELSE
444         FontDecode%=FNwint_fontmenuused
445     ENDIF
446     IF FontDecode%=TRUE THEN
447         FOR N%=1 TO wFontmenudepth%
448             wMenutree%(N%) = !(wimp%+4*(N%-1))
449         NEXT
450     ENDIF
451 ENDCASE
452 menu%=0:item%=0
453 IF FontDecode%=TRUE THEN
454     DIM fontname% wFontmenubuflen%-1
455     IF font$<>"" THEN
456         FOR A%=0 TO wFontmenubuflen%-1
457             fontname%?A%=0
458         NEXT
459     ENDIF
460     selection%=wimp%+(4*wFontmenudepth%)
461     SYS "Font_DecodeMenu",0,wFONTMENU%,selection%,fontname%,wFontmenubuflen%
462     font$=FNwint_string(fontname%)
463     font$=RIGHT$(font$,LEN(font$)-2)
464     Slash%=INSTR(font$,"\")
465     IF Slash%>0 THEN font$=LEFT$(font$,Slash%-1)
466     menu%=wFONTMENU%
467 ELSE
468     PROCwint_getmenuanditem(wLastmenu%,menu%,item%)
469     font$=""
470 ENDIF
471 PROCuser_menuselection(menu%,item%,font$)
472 SYS "Wimp_GetPointerInfo",,wimp%
473 IF wimp%!8=1 THEN
474     PROCwint_savewimp
475     PROCuser_menuopen(wLastmenu%,wHoldwhan%,wMenuicon%)
476     PROCwint_loadwimp
477     SYS "Wimp_CreateMenu",,wLastmenu%,wimp%!0-64,wimp%!4+20
478     wReopened%=TRUE
479     wHeldmenu%=wLastmenu%
480 ELSE
481     wFontmenudepth%=0
482     wHeldmenu%=0
483     FOR N%=0 TO wMaxdepth%
484         wMenutree%(N%)=-1
485     NEXT
486 ENDIF
487 ENDPROC
488 :
489 DEF PROCwint_pollmessage(actioncode%,reasoncode%)
490 CASE actioncode% OF
491     WHEN 0      : wFinished%=TRUE
492     WHEN 1      : PROCwint_receivedmess1(wimp%!4,wimp%!8,wimp%!20,wimp%!24,wimp%!28,wimp%!32,wimp%!36,wimp%!40)
493     WHEN 2      : PROCwint_receivedmess2(wimp%!4,wimp%!8,wimp%!20,wimp%!24,wimp%!28,wimp%!32,wimp%+44)
494     WHEN 3,5    : PROCwint_receivedmess3or5(actioncode%,wimp%!4,wimp%!8,wimp%!20,wimp%!24,wimp%!28,wimp%!32,wimp%!36,wimp%!40,wimp%+44)
495     WHEN 4      : PROCwint_receivedmess4
496     WHEN 8      : PROCwint_prequitissued
497     WHEN 10     : PROCwint_desktopsave
498     WHEN &502   : PROCwint_help(wimp%!4,wimp%!8,wimp%!32,wimp%!36,wimp%!20,wimp%!24,wimp%!28)
499     WHEN &400C0 : PROCwint_opensubmenu(wimp%!20,wimp%!24,wimp%!28,wimp%!32)
500     WHEN &400C1 : PROCuser_modechange
501     WHEN &400CC : PROCwint_iconise(wimp%!4,wimp%!8,wimp%!20)
502     WHEN &47700 : PROCwint_colourpickerchoice(wimp%!36)
503     WHEN &47702 : PROCwint_closecolourpicker(wimp%!20)
504     WHEN &80147 : PROCuser_printerchange
505     OTHERWISE
506     IF UNUSED%=TRUE THEN PROCuser_wimpmessage(actioncode%,wimp%,reasoncode%)
507 ENDCASE
508 ENDPROC
509 :
510 DEF PROCwimp_pollidle(durationreal,sec%)
511 LOCAL centisecs%,reason%,oldtime%,newtime%
512 IF sec%=0 THEN centisecs%=ABS(durationreal) ELSE centisecs%=ABS(durationreal*100)
513 wFinished%=FALSE
514 SYS "OS_ReadMonotonicTime" TO oldtime%
515 REPEAT
516     SYS "Wimp_PollIdle",0,wimp%,oldtime% TO reason%,wimp%
517     PROCwint_reasoncodes(reason%)
518     SYS "OS_ReadMonotonicTime" TO newtime%
519     WHILE (newtime%-oldtime%)>=0
520         oldtime%=oldtime%+centisecs%
521     ENDWHILE
522 UNTIL wFinished%=TRUE
523 PROCwimp_closedown
524 ENDPROC
525 :
526 DEF PROCwimp_singlepoll
527 LOCAL reason%
528 SYS "Wimp_Poll",0,wimp% TO reason%,wimp%
529 PROCwint_reasoncodes(reason%)
530 IF wFinished%=TRUE THEN
531     PROCwimp_closedown
532 ENDIF
533 ENDPROC
534 :
535 DEF PROCwimp_singlepollidle(durationreal,sec%)
536 LOCAL centisecs%,reason%,starttime%,currtime%
537 IF sec%=0 THEN centisecs%=ABS(durationreal) ELSE centisecs%=ABS(durationreal*100)
538 SYS "OS_ReadMonotonicTime" TO starttime%
539 REPEAT
540     SYS "Wimp_PollIdle",0,wimp%,starttime%+centisecs% TO reason%,wimp%
541     PROCwint_reasoncodes(reason%)
542     IF wFinished%=TRUE THEN
543         PROCwimp_closedown
544     ENDIF
545     SYS "OS_ReadMonotonicTime" TO currtime%
546 UNTIL currtime%>=starttime%+centisecs%
547 ENDPROC
548 :
549 DEF PROCwimp_quit(type%)
550 IF type%=1 THEN
551     IF wQuitsender%=-1 THEN
552         PROCwimp_error("","Sorry, but 'PROCwimp_quit(type%)' has been called with 'type%' set to 1 in the wrong circumstances. Please refer to the Dr Wimp Manual.",1,1)
553     ELSE
554         PROCwint_savewimp
555         SYS "Wimp_GetCaretPosition",,wimp%
556         wimp%!24=&1FC
557         SYS "Wimp_SendMessage",8,wimp%,wQuitsender%
558         PROCwint_loadwimp
559         wQuitsender%=-1
560     ENDIF
561 ELSE
562     IF FNuser_quit(0)=1 THEN
563         wFinished%=TRUE
564     ENDIF
565 ENDIF
566 ENDPROC
567 :
568 DEF PROCwint_prequitissued
569 LOCAL justthistask%,type%
570 PROCwint_savewimp
571 justthistask%=(wimp%!20 AND 1)
572 type%=1-justthistask%
573 IF FNuser_quit(type%)=0 THEN
574     PROCwint_loadwimp
575     wQuitsender%=wimp%!4
576     wimp%!12=wimp%!8
577     SYS "Wimp_SendMessage",19,wimp%
578 ENDIF
579 ENDPROC
580 :
581 DEF PROCwimp_closedown
582 LOCAL L%
583 FOR L%=0 TO 255
584     IF wFontbuf%?L% THEN SYS "Font_LoseFont",L%
585 NEXT L%
586 PROCwint_cleardynamicareas
587 PROCwint_closemessagefiles
588 IF wTemplatefile$<>"" THEN SYS "Wimp_CloseTemplate"
589 PROCwimp_hourglassoff
590 SYS "Wimp_CloseDown"
591 ENDPROC
592 :
593 DEF FNwimp_loadwindow(file$,win$,sprflag%)
594 LOCAL name%,whan%,icons%,L%,ic%,ind%,spr%,txt%,icondata%,iconsize%,namecheck%
595 DIM name% 11
596 FOR L%=0 TO 255
597     wFontbuftemp%?L%=0
598 NEXT L%
599 IF file$<>wTemplatefile$ THEN
600     IF wTemplatefile$<>"" THEN
601         SYS "Wimp_CloseTemplate"
602     ENDIF
603     SYS "Wimp_OpenTemplate",,file$
604     wTemplatefile$=file$
605 ENDIF
606 whan%=0
607 $name%=win$
608 SYS "Wimp_LoadTemplate",,0,0,0,wFontbuf%,name%,0 TO ,,iconsize%,,,,namecheck%
609 IF namecheck%>0 THEN
610     DIM icondata% iconsize%-1
611     SYS "Wimp_LoadTemplate",,wimp%,icondata%,icondata%+iconsize%,wFontbuftemp%,name%,0 TO ,,icondata%
612     FOR L%=0 TO 255
613         IF wFontbuftemp%?L% THEN wFontbuf%?L%+=1
614     NEXT L%
615     IF sprflag%=0 THEN
616         wimp%!64=1
617     ELSE
618         wimp%!64=sprflag%
619         icons%=wimp%!84
620         IF icons%>0 THEN
621             FOR L%=1 TO icons%
622                 ic%=wimp%+((L%-1)*32)+88
623                 ind%=((ic%!16)>>8) AND 1
624                 spr%=((ic%!16)>>1) AND 1
625                 txt%=(ic%!16) AND 1
626                 IF ind%=1 AND spr%=1 AND txt%=0 THEN
627                     IF (ic%!28)<>0 ic%!24=sprflag%
628                 ENDIF
629             NEXT L%
630         ENDIF
631     ENDIF
632     SYS "Wimp_CreateWindow",,wimp% TO whan%
633 ENDIF
634 =whan%
635 :
636 DEF PROCwimp_openwindow(whan%,centre%,stack%)
637 IF centre%<0 OR centre%>2 THEN centre%=0
638 wimp%!0=whan%
639 SYS "Wimp_GetWindowState",,wimp%
640 IF stack%=-3 THEN stack%=wimp%!28
641 IF stack%=-4 THEN stack%=-3
642 IF centre%=1 THEN PROCwint_centrewindow
643 IF centre%=2 THEN PROCwint_pointercentrewindow(whan%)
644 wimp%!28=stack%
645 SYS "Wimp_OpenWindow",,wimp%
646 PROCwint_checkuserpane(whan%,wimp%)
647 PROCwint_checksavewindow(whan%)
648 ENDPROC
649 :
650 DEF PROCwimp_openwindowat(whan%,x%,y%,stack%)
651 LOCAL width%,height%
652 wimp%!0=whan%
653 SYS "Wimp_GetWindowState",,wimp%
654 IF stack%=-3 THEN stack%=wimp%!28
655 IF stack%=-4 THEN stack%=-3
656 width%=wimp%!12-wimp%!4
657 height%=wimp%!16-wimp%!8
658 wimp%!4=x%
659 wimp%!8=y%-height%
660 wimp%!12=x%+width%
661 wimp%!16=y%
662 wimp%!28=stack%
663 SYS "Wimp_OpenWindow",,wimp%
664 PROCwint_checkuserpane(whan%,wimp%)
665 PROCwint_checksavewindow(whan%)
666 ENDPROC
667 :
668 DEF PROCwimp_redrawwindow(whan%)
669 SYS "Wimp_ForceRedraw",whan%,-1E6,-1E6,1E6,1E6
670 ENDPROC
671 :
672 DEF PROCwimp_updatewindow(whan%,minx%,miny%,maxx%,maxy%)
673 SYS "Wimp_ForceRedraw",whan%,minx%,miny%,maxx%,maxy%
674 ENDPROC
675 :
676 DEF FNwimp_iswindowopen(whan%)
677 wimp%!0=whan%
678 SYS "Wimp_GetWindowState",,wimp%
679 =(((wimp%!32>>16) AND 1)=1)
680 :
681 DEF PROCwimp_closewindow(whan%)
682 IF FNuser_preclosewindow(whan%)=1 THEN
683     wimp%!0=whan%
684     SYS "Wimp_CloseWindow",,wimp%
685     PROCuser_closewindow(whan%)
686 ENDIF
687 ENDPROC
688 :
689 DEF FNwimp_getwindowvisiblesize(whan%,side%)
690 LOCAL return%
691 return%=0
692 wimp%!0=whan%
693 SYS "Wimp_GetWindowState",,wimp%
694 IF side%=0 THEN
695     return%=(wimp%!12-wimp%!4)
696 ELSE
697     return%=wimp%!16-wimp%!8
698 ENDIF
699 =return%
700 :
701 DEF FNwimp_getwindowworksize(whan%,side%)
702 LOCAL return%
703 wimp%!0=whan%
704 SYS "Wimp_GetWindowInfo",,(wimp% OR %1)
705 IF side%=0 THEN
706     return%=wimp%!52-wimp%!44
707 ELSE
708     return%=wimp%!56-wimp%!48
709 ENDIF
710 =return%
711 :
712 DEF FNwimp_getwindowvisiblework(whan%,side%,end%)
713 LOCAL result%
714 wimp%!0=whan%
715 SYS "Wimp_GetWindowState",,wimp%
716 CASE side% OF
717     WHEN 0
718     CASE end% OF
719         WHEN 0 : result%=FNwimp_screentowork(whan%,wimp%!4,0)
720         OTHERWISE: result%=FNwimp_screentowork(whan%,wimp%!12,0)
721     ENDCASE
722     OTHERWISE
723     CASE end% OF
724         WHEN 0 : result%=FNwimp_screentowork(whan%,wimp%!8,1)
725         OTHERWISE: result%=FNwimp_screentowork(whan%,wimp%!16,1)
726     ENDCASE
727 ENDCASE
728 =result%
729 :
730 DEF FNwimp_getwindowvisiblescreen(whan%,side%,end%)
731 LOCAL result%
732 wimp%!0=whan%
733 SYS "Wimp_GetWindowState",,wimp%
734 CASE side% OF
735     WHEN 0
736     CASE end% OF
737         WHEN 0 : result%=wimp%!4
738         OTHERWISE : result%=wimp%!12
739     ENDCASE
740     OTHERWISE
741     CASE end% OF
742         WHEN 0 : result%=wimp%!8
743         OTHERWISE: result%=wimp%!16
744     ENDCASE
745 ENDCASE
746 =result%
747 :
748 DEF PROCwimp_resizewindow(whan%,width%,height%)
749 LOCAL flags%,op%
750 wimp%!0=0:wimp%!4=-height%:wimp%!8=width%:wimp%!12=0
751 SYS "Wimp_SetExtent",whan%,wimp%
752 wimp%!0=whan%
753 SYS "Wimp_GetWindowState",,wimp%
754 flags%=wimp%!32
755 op%=(flags%>>16) AND 1
756 IF op%=0 THEN wimp%!28=-3
757 SYS "Wimp_OpenWindow",,wimp%
758 IF op%=0 THEN
759     wimp%!0=whan%
760     SYS "Wimp_CloseWindow",,wimp%
761 ENDIF
762 ENDPROC
763 :
764 DEF PROCwimp_resizewindowvisible(whan%,width%,height%)
765 LOCAL flags%,open%
766 wimp%!0=whan%
767 SYS "Wimp_GetWindowInfo",,wimp% OR 1
768 SYS "Wimp_SetExtent",whan%,wimp%+44
769 wimp%!0=whan%
770 SYS "Wimp_GetWindowState",,wimp%
771 wimp%!8=wimp%!16-height%
772 wimp%!12=wimp%!4+width%
773 flags%=wimp%!32
774 open%=(flags%>>16) AND 1
775 IF open%=0 THEN wimp%!28=-3
776 SYS "Wimp_OpenWindow",,wimp%
777 IF open%=0 THEN
778     wimp%!0=whan%
779     SYS "Wimp_CloseWindow",,wimp%
780 ELSE
781     PROCwint_checkuserpane(whan%,wimp%)
782 ENDIF
783 ENDPROC
784 :
785 DEF FNwimp_getwindowtitle(whan%)
786 LOCAL return$,titlebar%,titletext%,indirected%
787 return$=""
788 wimp%!0=whan%
789 SYS "Wimp_GetWindowInfo",,(wimp% OR %1)
790 titlebar%=((wimp%!32>>26) AND 1)
791 IF titlebar%=1 THEN
792     titletext%=(wimp%!60 AND 1)
793     IF titletext%=1 THEN
794         indirected%=((wimp%!60>>8) AND 1)
795         IF indirected%=1 THEN
796             return$=FNwint_string(wimp%!76)
797         ELSE
798             return$=FNwint_string(wimp%+76)
799         ENDIF
800     ENDIF
801 ENDIF
802 =return$
803 :
804 DEF PROCwimp_putwindowtitle(whan%,text$)
805 LOCAL flag%,width%,height%,xmin%,ymin%
806 wimp%!0=whan%
807 SYS "Wimp_GetWindowInfo",,(wimp% OR %1)
808 flag%=wimp%!60
809 flag%=(flag%>>8)
810 IF (flag% AND 1)=0 THEN
811     PROCwimp_error("","Window title is not indirected",1,1)
812 ELSE
813     $(wimp%!76)=text$
814     PROCwint_redrawtitle(whan%)
815 ENDIF
816 ENDPROC
817 :
818 DEF PROCwint_redrawtitle(window%)
819 LOCAL a%,b%,c%,d%,e%,f%
820 IF FNwimp_osversion>=380 THEN
821     SYS "Wimp_ForceRedraw",window%,&4B534154,3
822 ELSE
823     SYS "Wimp_GetCaretPosition",,wimp%
824     a%=wimp%!0:b%=wimp%!4:c%=wimp%!8:d%=wimp%!12:e%=wimp%!16:f%=wimp%!20
825     IF a%=window% THEN window%=-1
826     SYS "XWimp_SetCaretPosition",window%,-1,,,-1
827     SYS "Wimp_SetCaretPosition",a%,b%,c%,d%,e%,f%
828 ENDIF
829 ENDPROC
830 :
831 DEF PROCwimp_scroll(whan%,side%,direction%,distance%)
832 LOCAL cstack%
833 wimp%!0=whan%
834 SYS "Wimp_GetWindowInfo",,(wimp% OR %1)
835 CASE side% OF
836     WHEN 0
837     CASE direction% OF
838         WHEN 0 : IF (wimp%!20-distance%)<wimp%!44 THEN wimp%!20=wimp%!44 ELSE wimp%!20=(wimp%!20-distance%)
839         OTHERWISE : IF (wimp%!20+distance%)>wimp%!52 THEN wimp%!20=wimp%!52 ELSE wimp%!20=(wimp%!20+distance%)
840     ENDCASE
841     OTHERWISE
842     CASE direction% OF
843         WHEN 0 : IF (wimp%!24-distance%)<wimp%!48 THEN wimp%!24=wimp%!48 ELSE wimp%!24=(wimp%!24-distance%)
844         OTHERWISE : IF (wimp%!24+distance%)>wimp%!56 THEN wimp%!24=wimp%!56 ELSE wimp%!24=(wimp%!24+distance%)
845     ENDCASE
846 ENDCASE
847 IF ((wimp%!32 >> 16) AND 1)=1 THEN
848     SYS "Wimp_OpenWindow",,wimp%
849 ELSE
850     SYS "Wimp_OpenWindow",,wimp%
851     SYS "Wimp_CloseWindow",,wimp%
852 ENDIF
853 ENDPROC
854 :
855 DEF FNwimp_getscroll(whan%,side%)
856 LOCAL return%
857 wimp%!0=whan%
858 SYS "Wimp_GetWindowState",,wimp%
859 IF side%=0 THEN
860     return%=wimp%!20
861 ELSE
862     return%=wimp%!24
863 ENDIF
864 =return%
865 :
866 DEF PROCwimp_scrollto(whan%,side%,scrollpos%)
867 wimp%!0=whan%
868 SYS "Wimp_GetWindowState",,wimp%
869 IF side%=0 THEN
870     wimp%!20=scrollpos%
871 ELSE
872     wimp%!24=scrollpos%
873 ENDIF
874 IF ((wimp%!32 >> 16) AND 1)=1 THEN
875     SYS "Wimp_OpenWindow",,wimp%
876 ELSE
877     SYS "Wimp_OpenWindow",,wimp%
878     SYS "Wimp_CloseWindow",,wimp%
879 ENDIF
880 ENDPROC
881 :
882 DEF PROCwimp_banner(whan%,delay%)
883 LOCAL time%
884 delay%=ABS(delay%)
885 PROCwimp_openwindow(whan%,1,-1)
886 wBANNER%=TRUE
887 SYS "OS_ReadMonotonicTime" TO time%
888 wDelaymax%=(delay%*100)+time%
889 wBanner%=whan%
890 ENDPROC
891 :
892 DEF FNwimp_createwindow(vminx%,vminy%,vmaxx%,vmaxy%,wminx%,wminy%,wmaxx%,wmaxy%,flags%,colourflags%,wbuttontype%,title$,titleflags%,titlefont%,maxind%,spritearea%)
893 LOCAL error$,wflags%,tflags%,len%,name%,whan%,tind%,bits%,wshift%,N%
894 IF ((titleflags%>>4 AND 1)=1) AND (wFontbuf%?titlefont%=0) THEN
895     error$="For creating the window with the title "+CHR$(34)+CHR$(160)+title$+CHR$(160)+CHR$(34)+" bit 4 of 'titleflags%' is set but the font handle in 'titlefont%' is invalid. The window will now be created as if bit 4 was unset."
896     PROCwimp_error("",error$,1,2)
897     titleflags%=(titleflags% EOR %00010000)
898 ENDIF
899 wimp%!0=vminx%:wimp%!4=vminy%:wimp%!8=vmaxx%:wimp%!12=vmaxy%
900 wimp%!16=0:wimp%!20=0
901 wimp%!24=-1
902 wflags%=0
903 wflags%=(1<<31)
904 RESTORE +0
905 FOR bits%=0 TO 16
906     READ wshift%
907     IF ((flags%>>bits%) AND 1) THEN wflags%+=1<<wshift%
908 NEXT
909 DATA 26,25,24,30,28,29,27,4,5,1,6,8,9,12,13,14,15
910 wimp%!28=wflags%
911 FOR N%=0 TO 6
912     wimp%?(38-N%)=colourflags% AND %1111
913     colourflags%=colourflags%>>>4
914 NEXT
915 wimp%?39=0
916 wimp%!40=wminx%:wimp%!44=wminy%:wimp%!48=wmaxx%:wimp%!52=wmaxy%
917 FOR bits%=0 TO 6
918     READ wshift%
919     IF ((titleflags%>>bits%) AND 1) THEN tflags%+=1<<wshift%
920 NEXT
921 DATA 0,1,3,4,6,9,11
922 IF (titleflags%>>7 AND 1) OR LEN(title$)>11 THEN tflags%+=1<<8
923 IF (titleflags%>>4 AND 1) THEN tflags%+=titlefont%<<24
924 wimp%!56=tflags%
925 wimp%!60=wbuttontype%<<12
926 IF spritearea%=0 THEN wimp%!64=1 ELSE wimp%!64=spritearea%
927 wimp%?68=0:wimp%?69=0:wimp%?70=0:wimp%?71=0
928 IF ((tflags%>>8 AND 1)=0) THEN
929     $(wimp%+72)=title$
930 ELSE
931     len%=LEN(title$)+1
932     DIM name% len%-1
933     IF maxind%<len% THEN maxind%=len%
934     $(name%)=title$
935     wimp%!72=name%
936     wimp%!76=-1
937     wimp%!80=maxind%
938 ENDIF
939 wimp%!84=0
940 SYS "Wimp_CreateWindow",,wimp% TO whan%
941 =whan%
942 :
943 DEF PROCwimp_deletewindow(whan%)
944 wimp%!0=whan%
945 SYS "Wimp_DeleteWindow",,wimp%
946 ENDPROC
947 :
948 DEF PROCwint_pointercentrewindow(whan%)
949 LOCAL mx%,my%,width%,height%,xp%,yp%
950 SYS "Wimp_GetPointerInfo",,wimp%
951 mx%=wimp%!0:my%=wimp%!4
952 wimp%!0=whan%
953 SYS "Wimp_GetWindowInfo",,(wimp% OR %1)
954 width%=wimp%!12-wimp%!4:height%=wimp%!16-wimp%!8
955 xp%=mx%-width%/2:yp%=my%-height%/2
956 wimp%!4=xp%:wimp%!8=yp%
957 wimp%!12=xp%+width%:wimp%!16=yp%+height%
958 ENDPROC
959 :
960 DEF PROCwint_centrewindow
961 LOCAL x0%,y0%,x1%,y1%,wwidth%,wheight%,swidth%,sheight%
962 x0%=wimp%!4:y0%=wimp%!8
963 x1%=wimp%!12:y1%=wimp%!16
964 wwidth%=x1%-x0%
965 wheight%=y1%-y0%
966 swidth%=FNwimp_getscreensize(0)
967 sheight%=FNwimp_getscreensize(1)
968 x0%=(swidth%-wwidth%)/2
969 y0%=(sheight%-wheight%)/2
970 wimp%!4=x0%:wimp%!8=y0%
971 x1%=x0%+wwidth%:y1%=y0%+wheight%
972 wimp%!12=x1%:wimp%!16=y1%
973 ENDPROC
974 :
975 DEF PROCwint_checkuserpane(whan%,wimp%)
976 LOCAL a%,stack%
977 stack%=wimp%!28
978 IF stack%=-3 THEN stack%=-4
979 PROCuser_openwindow(whan%,wimp%!4,wimp%!16,stack%)
980 a%=FNuser_pane(whan%)
981 IF a%<>-1 THEN
982     wimp%!0=whan%
983     SYS "Wimp_GetWindowState",,wimp%
984     wimp%!28=a%
985     SYS "Wimp_OpenWindow",,wimp%
986 ENDIF
987 ENDPROC
988 :
989 DEF PROCwint_checksavewindow(whan%)
990 LOCAL drag%,write%,ok%
991 IF FNuser_savefiletype(whan%)<>"" THEN
992     drag%=0:write%=1:ok%=2
993     PROCuser_saveicon(whan%,drag%,write%,ok%)
994     PROCwimp_putcaret(whan%,write%,-1)
995 ENDIF
996 ENDPROC
997 :
998 DEF FNwimp_geticontext(whan%,icon%)
999 LOCAL return$,flag%
1000 return$=""
1001 wimp%!0=whan%
1002 wimp%!4=icon%
1003 SYS "Wimp_GetIconState",,wimp%
1004 flag%=wimp%!24
1005 flag%=(flag%>>8)
1006 IF (flag% AND 1)=0 THEN
1007     return$=FNwint_string(wimp%+28)
1008 ELSE
1009     return$=FNwint_string(wimp%!28)
1010 ENDIF
1011 =return$
1012 :
1013 DEF PROCwimp_puticontext(whan%,icon%,text$)
1014 LOCAL caret%,flag%,t$,caretwindow%,careticon%,current$,rightcaret%
1015 caret%=FALSE
1016 rightcaret%=FALSE
1017 IF whan%<>-2 THEN
1018     wimp%!0=whan%
1019     wimp%!4=icon%
1020     SYS "Wimp_GetIconState",,wimp%
1021     flag%=wimp%!24
1022     flag%=(flag%>>8)
1023     IF (flag% AND 1)=0 THEN
1024         PROCwimp_error("","Icon "+STR$icon%+" is not indirected",1,1)
1025     ELSE
1026         current$=$(wimp%!28)
1027         IF text$<>current$ THEN
1028             SYS "Wimp_GetCaretPosition",,wimp%
1029             caretwindow%=wimp%!0
1030             careticon%=wimp%!4
1031             IF caretwindow%=whan% AND careticon%=icon% THEN
1032                 caret%=TRUE
1033                 index%=wimp%!20
1034                 IF index%=LEN(current$) THEN rightcaret%=TRUE
1035                 PROCwimp_losecaret
1036             ENDIF
1037             wimp%!0=whan%
1038             wimp%!4=icon%
1039             SYS "Wimp_GetIconState",,wimp%
1040             wimp%!8=0
1041             wimp%!12=0
1042             $(wimp%!28)=LEFT$(text$,(wimp%!36)-1)
1043             SYS "Wimp_SetIconState",,wimp%
1044             IF caret%=TRUE THEN
1045                 IF rightcaret%=TRUE THEN index%=LEN(text$)
1046                 PROCwimp_putcaret(whan%,icon%,index%)
1047             ENDIF
1048         ENDIF
1049     ENDIF
1050 ENDIF
1051 ENDPROC
1052 :
1053 DEF PROCwimp_puticonfont(whan%,icon%,fonthandle%)
1054 LOCAL outline%,currfont%,caret%,index%
1055 caret%=FALSE
1056 IF fonthandle%>0 THEN
1057     wimp%!0=whan%
1058     wimp%!4=icon%
1059     SYS "Wimp_GetIconState",,wimp%
1060     outline%=(wimp%!(8+16) >> 6) AND 1
1061     IF outline%=1 THEN
1062         currfont%=((wimp%!(8+16)>>24) AND &FFFF)
1063         IF fonthandle%<>currfont% THEN
1064             SYS "Wimp_GetCaretPosition",,wimp%
1065             caretwindow%=wimp%!0
1066             careticon%=wimp%!4
1067             IF caretwindow%=whan% AND careticon%=icon% THEN
1068                 caret%=TRUE
1069                 index%=wimp%!20
1070                 PROCwimp_losecaret
1071             ENDIF
1072             wimp%!0=whan%
1073             wimp%!4=icon%
1074             wimp%!8=fonthandle%<<24
1075             wimp%!12=&FFFF<<24
1076             SYS "Wimp_SetIconState",,wimp%
1077             IF caret%=TRUE THEN
1078                 PROCwimp_putcaret(whan%,icon%,index%)
1079             ENDIF
1080         ENDIF
1081     ELSE
1082         PROCwimp_error("","Icon "+STR$icon%+" was not defined to use outline fonts.",1,1)
1083     ENDIF
1084 ENDIF
1085 ENDPROC
1086 :
1087 DEF PROCwimp_colouricon(whan%,icon%,colour%,background%)
1088 LOCAL outline%,indirect%,text%,valid%,valid$,temp$,first%,pos%,colour$
1089 colour%=colour% MOD 16
1090 wimp%!0=whan%
1091 wimp%!4=icon%
1092 SYS "Wimp_GetIconState",,wimp%
1093 outline%=(wimp%!24>>6) AND 1
1094 indirect%=(wimp%!24>>8) AND 1
1095 text%=(wimp%!24) AND 1
1096 IF outline%=1 THEN
1097     IF indirect%=1 AND text%=1 THEN
1098         valid%=!(wimp%+8+24)
1099         IF valid%<>-1 THEN
1100             valid$=FNwint_string(valid%)
1101             temp$=FNwimp_changecase(valid$,0)
1102             first%=0
1103             IF LEFT$(temp$,1)="f" THEN first%=1
1104             pos%=INSTR(temp$,";f")+1
1105             IF first%=1 OR pos%>1 THEN
1106                 IF first%=1 THEN pos%=1
1107                 IF colour%<10 THEN
1108                     colour$=STR$(colour%)
1109                 ELSE
1110                     colour$=MID$("123456789abcdef",colour%,1)
1111                 ENDIF
1112                 IF background%=1 THEN
1113                     MID$(valid$,pos%+1,1)=colour$
1114                 ELSE
1115                     MID$(valid$,pos%+2,1)=colour$
1116                 ENDIF
1117                 $(valid%)=valid$
1118                 wimp%!8=0
1119                 wimp%!12=0
1120                 SYS "Wimp_SetIconState",,wimp%
1121             ELSE
1122                 PROCwimp_error("","Sorry, but to change an outline font colour the icon must be defined with a validation string including an F-command. See Dr Wimp Manual Section 2.33",1,1)
1123             ENDIF
1124         ELSE
1125             PROCwimp_error("","Sorry, but to change an outline font colour the icon must be defined with a validation string including an F-command. See Dr Wimp Manual Section 2.33",1,1)
1126         ENDIF
1127     ELSE
1128         PROCwimp_error("","Sorry, but the icon must be defined to allow text AND indirected data AND with a validation string including an F-command. See Dr Wimp Manual Section 2.33",1,1)
1129     ENDIF
1130 ELSE
1131     IF background%=0 THEN
1132         wimp%!8=colour%<<24
1133         wimp%!12=15<<24
1134     ELSE
1135         wimp%!8=colour%<<28
1136         wimp%!12=15<<28
1137     ENDIF
1138     SYS "Wimp_SetIconState",,wimp%
1139 ENDIF
1140 ENDPROC
1141 :
1142 DEF PROCwimp_iconenable(whan%,icon%,state%)
1143 LOCAL b%
1144 IF state%<0 OR state%>2 THEN state%=1
1145 wimp%!0=whan%
1146 wimp%!4=icon%
1147 SYS "Wimp_GetIconState",,wimp%
1148 b%=(wimp%!24>>22) AND 1
1149 IF state%=2 THEN state%=b%
1150 state%=1-state%
1151 IF b%<>state% THEN
1152     IF state%=1 THEN
1153         SYS "Wimp_GetCaretPosition",,wimp%
1154         IF wimp%!0=whan% AND wimp%!4=icon% THEN SYS "Wimp_SetCaretPosition",-1
1155         wimp%!0=whan%
1156         wimp%!4=icon%
1157     ENDIF
1158     wimp%!8=(state%<<22)
1159     wimp%!12=(1<<22)
1160     SYS "Wimp_SetIconState",,wimp%
1161 ENDIF
1162 ENDPROC
1163 :
1164 DEF PROCwimp_iconselect(whan%,icon%,state%)
1165 LOCAL b%
1166 IF state%<0 OR state%>2 THEN state%=1
1167 wimp%!0=whan%
1168 wimp%!4=icon%
1169 SYS "Wimp_GetIconState",,wimp%
1170 b%=(wimp%!24>>21) AND 1
1171 IF state%=2 THEN state%=1-b%
1172 IF b%<>state% THEN
1173     wimp%!8=(state%<<21)
1174     wimp%!12=(1<<21)
1175     SYS "Wimp_SetIconState",,wimp%
1176 ENDIF
1177 ENDPROC
1178 :
1179 DEF FNwimp_geticonselect(whan%,icon%)
1180 wimp%!0=whan%
1181 wimp%!4=icon%
1182 SYS "Wimp_GetIconState",,wimp%
1183 =(wimp%!24>>21) AND 1
1184 :
1185 DEF FNwimp_geticonsize(whan%,icon%,side%)
1186 LOCAL return%
1187 return%=0
1188 wimp%!0=whan%
1189 wimp%!4=icon%
1190 SYS "Wimp_GetIconState",,wimp%
1191 IF side%=0 THEN
1192     return%=wimp%!16-wimp%!8
1193 ELSE
1194     return%=wimp%!20-wimp%!12
1195 ENDIF
1196 =return%
1197 :
1198 DEF PROCwimp_resizeicon(whan%,icon%,minx%,miny%,maxx%,maxy%)
1199 wimp%!0=whan%
1200 wimp%!4=icon%
1201 SYS "Wimp_GetIconState",,wimp%
1202 SYS "Wimp_ResizeIcon",whan%,icon%,minx%,miny%,maxx%,maxy%
1203 PROCwimp_updatewindow(whan%,wimp%!8,wimp%!12,wimp%!16,wimp%!20)
1204 PROCwimp_updatewindow(whan%,minx%,miny%,maxx%,maxy%)
1205 ENDPROC
1206 :
1207 DEF PROCwimp_moveicon(whan%,icon%,minx%,miny%)
1208 LOCAL width%,height%,maxx%,maxy%
1209 wimp%!0=whan%
1210 wimp%!4=icon%
1211 SYS "Wimp_GetIconState",,wimp%
1212 width%=wimp%!16-wimp%!8
1213 height%=wimp%!20-wimp%!12
1214 maxx%=minx%+width%
1215 maxy%=miny%+height%
1216 SYS "Wimp_ResizeIcon",whan%,icon%,minx%,miny%,maxx%,maxy%
1217 PROCwimp_updatewindow(whan%,wimp%!8,wimp%!12,wimp%!16,wimp%!20)
1218 PROCwimp_updatewindow(whan%,minx%,miny%,maxx%,maxy%)
1219 ENDPROC
1220 :
1221 DEF FNwimp_geticonenable(whan%,icon%)
1222 wimp%!0=whan%
1223 wimp%!4=icon%
1224 SYS "Wimp_GetIconState",,wimp%
1225 =1-((wimp%!24>>22) AND 1)
1226 :
1227 DEF FNwimp_geticonposition(whan%,icon%,coord%)
1228 LOCAL return%
1229 IF coord%<0 THEN coord%=0
1230 IF coord%>3 THEN coord%=3
1231 return%=0
1232 wimp%!0=whan%
1233 wimp%!4=icon%
1234 SYS "Wimp_GetIconState",,wimp%
1235 CASE coord% OF
1236     WHEN 0:return%=wimp%!8
1237     WHEN 1:return%=wimp%!12
1238     WHEN 2:return%=wimp%!16
1239     WHEN 3:return%=wimp%!20
1240 ENDCASE
1241 =return%
1242 :
1243 DEF PROCwimp_iconbit(whan%,icon%,bit%,state%)
1244 LOCAL b%
1245 IF bit%<>23 THEN
1246     IF bit%<0 THEN bit%=0
1247     IF bit%>31 THEN bit%=31
1248     IF state%<0 OR state%>2 THEN state%=1
1249     wimp%!0=whan%
1250     wimp%!4=icon%
1251     SYS "Wimp_GetIconState",,wimp%
1252     b%=(wimp%!24>>bit%) AND 1
1253     IF state%=2 THEN state%=1-b%
1254     IF b%<>state% THEN
1255         wimp%!8=state%<<bit%
1256         wimp%!12=1<<bit%
1257         SYS "Wimp_SetIconState",,wimp%
1258     ENDIF
1259 ENDIF
1260 ENDPROC
1261 :
1262 DEF FNwimp_geticonbit(whan%,icon%,bit%)
1263 LOCAL flags%,state%
1264 IF bit%<0 THEN bit%=0
1265 IF bit%>31 THEN bit%=31
1266 wimp%!0=whan%
1267 wimp%!4=icon%
1268 SYS "Wimp_GetIconState",,wimp%
1269 flags%=wimp%!(8+16)
1270 state%=((flags%>>bit%) AND 1)
1271 =state%
1272 :
1273 DEF FNwimp_createicon(whan%,wminx%,wminy%,wmaxx%,wmaxy%,flags%,esg%,buttontype%,fcol%,bcol%,fhan%,text$,spritename$,spritearea%,maxind%,valid$)
1274 LOCAL error$,icon%
1275 IF ((flags%>>6 AND 1)=1) AND (wFontbuf%?fhan%=0) THEN
1276     error$="For creating the icon at window position "+STR$(wminx%)+"/"+STR$(wminy%)+" bit 6 of 'flags%' is set but the font handle in 'fhan%' is invalid. The window will now be created as if bit 6 was unset but with default outline font colours."
1277     PROCwimp_error("",error$,1,2)
1278     flags%=(flags% EOR %000000001000000)
1279     fcol%=7
1280     bcol%=0
1281 ENDIF
1282 wimp%!0=whan%
1283 PROCwint_defineicon(wminx%,wminy%,wmaxx%,wmaxy%,flags%,esg%,buttontype%,fcol%,bcol%,fhan%,text$,spritename$,spritearea%,maxind%,valid$)
1284 SYS "Wimp_CreateIcon",,wimp% TO icon%
1285 =icon%
1286 :
1287 DEF PROCwimp_ploticon(wminx%,wminy%,wmaxx%,wmaxy%,flags%,esg%,buttontype%,fcol%,bcol%,fhan%,text$,spritename$,spritearea%,maxind%,valid$)
1288 PROCwint_defineicon(wminx%,wminy%,wmaxx%,wmaxy%,flags%,esg%,buttontype%,fcol%,bcol%,fhan%,text$,spritename$,spritearea%,maxind%,valid$)
1289 SYS "Wimp_PlotIcon",,(wimp%+4)
1290 ENDPROC
1291 :
1292 DEF PROCwint_defineicon(wminx%,wminy%,wmaxx%,wmaxy%,flags%,esg%,buttontype%,fcol%,bcol%,fhan%,text$,spritename$,spritearea%,maxind%,valid$)
1293 LOCAL iflags%,len%,buf%,valid%,t%,s%,f%,ind%,loflags%,hiflags%
1294 wimp%!4=wminx%
1295 wimp%!8=wminy%
1296 wimp%!12=wmaxx%
1297 wimp%!16=wmaxy%
1298 iflags%=0
1299 t%=flags%>>0 AND 1
1300 s%=flags%>>1 AND 1
1301 f%=flags%>>6 AND 1
1302 ind%=flags%>>8 AND 1
1303 loflags%=flags% AND %111111111111
1304 hiflags%=flags% AND %111000000000000
1305 iflags%+=loflags%
1306 iflags%+=hiflags%<<9
1307 iflags%+=esg%<<16
1308 IF f% THEN
1309     iflags%+=fhan%<<24
1310 ELSE
1311     iflags%+=fcol%<<24
1312     iflags%+=bcol%<<28
1313 ENDIF
1314 iflags%+=buttontype%<<12
1315 wimp%!20=iflags%
1316 IF t%=1 AND s%=0 AND ind%=0 THEN $(wimp%+24)=text$
1317 IF t%=0 AND s%=1 AND ind%=0 THEN $(wimp%+24)=spritename$
1318 IF t%=1 AND s%=1 AND ind%=0 THEN $(wimp%+24)=spritename$
1319 IF t%=1 AND ind%=1 THEN
1320     len%=LEN(valid$)+1
1321     DIM valid% len%-1
1322     len%=LEN(text$)+1
1323     IF maxind%<len% THEN maxind%=len%
1324     DIM buf% maxind%-1
1325     $(buf%)=text$
1326     $(valid%)=valid$
1327     wimp%!24=buf%
1328     wimp%!28=valid%
1329     wimp%!32=maxind%
1330 ENDIF
1331 IF t%=0 AND s%=1 AND ind%=1 THEN
1332     len%=LEN(spritename$)+1
1333     IF maxind%<len% THEN maxind%=len%
1334     DIM buf% maxind%-1
1335     $(buf%)=spritename$
1336     wimp%!24=buf%
1337     IF spritearea%=0 THEN wimp%!28=1 ELSE wimp%!28=spritearea%
1338     wimp%!32=maxind%
1339 ENDIF
1340 ENDPROC
1341 :
1342 DEF PROCwimp_deleteicon(whan%,icon%,redraw%)
1343 wimp%!0=whan%
1344 wimp%!4=icon%
1345 IF redraw%=1 THEN
1346     SYS "Wimp_GetIconState",,wimp%
1347     minx%=wimp%!8
1348     miny%=wimp%!12
1349     maxx%=wimp%!16
1350     maxy%=wimp%!20
1351 ENDIF
1352 SYS "Wimp_DeleteIcon",,wimp%
1353 IF redraw%=1 THEN PROCwimp_updatewindow(whan%,minx%,miny%,maxx%,maxy%)
1354 ENDPROC
1355 :
1356 DEF PROCwimp_iconhide(whan%,icon%,state%)
1357 LOCAL b%
1358 IF state%<0 OR state%>2 THEN state%=1
1359 wimp%!0=whan%
1360 wimp%!4=icon%
1361 SYS "Wimp_GetIconState",,wimp%
1362 b%=(wimp%!24>>23) AND 1
1363 IF state%=2 THEN state%=1-b%
1364 IF b%<>state% THEN
1365     wimp%!8=(state%<<7)+(state%<<23)
1366     wimp%!12=(1<<7)+(1<<23)
1367     SYS "Wimp_SetIconState",,wimp%
1368 ENDIF
1369 ENDPROC
1370 :
1371 DEF PROCwimp_putcaret(whan%,icon%,index%)
1372 LOCAL flag%,text$,len%
1373 IF icon%>=0 THEN
1374     wimp%!0=whan%
1375     wimp%!4=icon%
1376     SYS "Wimp_GetIconState",,wimp%
1377     flag%=wimp%!24
1378     flag%=(flag%>>12)
1379     flag%=flag% AND &F
1380     IF flag%=14 OR flag%=15 THEN
1381         text$=FNwimp_geticontext(whan%,icon%)
1382         len%=LEN(text$)
1383         IF index%<0 OR index%>len% THEN index%=len%
1384         SYS "Wimp_SetCaretPosition",whan%,icon%,,,-1,index%
1385     ELSE
1386         PROCwimp_error("","The icon is not writable and therefore cannot take the caret.",1,1)
1387     ENDIF
1388 ELSE
1389     SYS "Wimp_SetCaretPosition",whan%,icon%,,,-1,-1
1390 ENDIF
1391 ENDPROC
1392 :
1393 DEF PROCwimp_losecaret
1394 SYS "Wimp_SetCaretPosition",-1
1395 ENDPROC
1396 :
1397 DEF FNwimp_getcaretposition(choice%)
1398 LOCAL return%
1399 IF choice%<0 THEN choice%=0
1400 IF choice%>4 THEN choice%=4
1401 return%=-1
1402 SYS "Wimp_GetCaretPosition",,wimp%
1403 IF wimp%!0<>-1 THEN
1404     CASE choice% OF
1405         WHEN 0,1,2,3: return%=wimp%!(4*choice%)
1406         WHEN 4: return%=wimp%!20
1407     ENDCASE
1408 ENDIF
1409 =return%
1410 :
1411 DEF PROCwint_startdrag(whan%,icon%,button%,mousex%,mousey%)
1412 LOCAL a%,b%
1413 wsavet$=FNuser_savefiletype(whan%)
1414 IF wsavet$="" THEN
1415     a%=FNuser_sliderback(whan%,icon%)
1416     b%=FNuser_slider(whan%,icon%)
1417     IF a%=-1 AND b%=-1 THEN
1418         IF FNuser_dragicon(whan%,icon%,button%/16)=1 THEN
1419             PROCwint_starticondrag(whan%,icon%,button%,mousex%,mousey%)
1420         ENDIF
1421     ELSE
1422         IF a%=-1 THEN icon%=b%
1423         PROCwint_startsliderdrag(whan%,icon%)
1424     ENDIF
1425 ELSE
1426     PROCwint_startsavedrag(whan%,icon%)
1427 ENDIF
1428 ENDPROC
1429 :
1430 DEF PROCwint_startsavedrag(whan%,icon%)
1431 LOCAL ox%,oy%,t%,i%,spritearea%,spritename$,drag%,write%,ok%,valid$
1432 IF LEN(wsavet$)<4 THEN
1433     wSavew%=whan%
1434     wSavedrag%=whan%
1435     wimp%!0=wSavew%
1436     SYS "Wimp_GetWindowState",,wimp%
1437     ox%=wimp%!4-wimp%!20
1438     oy%=wimp%!16-wimp%!24
1439     drag%=0:write%=1:ok%=2
1440     PROCuser_saveicon(wSavew%,drag%,write%,ok%)
1441     IF drag%=icon% THEN
1442         wimp%!4=drag%
1443         SYS "Wimp_GetIconState",,wimp%
1444         t%=(wimp%!(8+16)) AND 1
1445         i%=(wimp%!(8+16)>>8) AND 1
1446         IF t%=0 THEN
1447             IF i%=0 THEN spritename$=FNwint_string(wimp%+(8+20)):spritearea%=1
1448             IF i%=1 THEN spritename$=FNwint_string(wimp%!(8+20)):spritearea%=wimp%!(8+24)
1449             IF spritearea%<>1 THEN SYS "XOS_SpriteOp",&128,spritearea%,spritename$ TO;f% :IF (f% AND 1)=1 THEN spritearea%=1
1450         ELSE
1451             valid$=$(wimp%!32)
1452             spritearea%=1
1453             spritename$=FNwint_extractspritename(valid$)
1454         ENDIF
1455         wimp%!0=wimp%!8+ox%
1456         wimp%!4=wimp%!12+oy%
1457         wimp%!8=wimp%!16+ox%
1458         wimp%!12=wimp%!20+oy%
1459         SYS "DragASprite_Start",%11001010,spritearea%,spritename$,wimp%
1460     ENDIF
1461 ELSE
1462     PROCwimp_error("","Filetype string too long in 'DEF FNuser_savefiletype'.",1,1):PROCwimp_closedown:END
1463 ENDIF
1464 ENDPROC
1465 :
1466 DEF FNwint_extractspritename(valid$)
1467 LOCAL name$,pos%
1468 IF INSTR(valid$,";")=0 THEN
1469     name$=RIGHT$(valid$,LEN(valid$)-1)
1470 ELSE
1471     IF INSTR(valid$,"s")=1 OR INSTR(valid$,"S")=1 THEN
1472         name$=""
1473         pos%=1
1474         REPEAT
1475             pos%+=1
1476             IF MID$(valid$,pos%,1)<>";" THEN
1477                 name$+=MID$(valid$,pos%,1)
1478             ENDIF
1479         UNTIL MID$(valid$,pos%,1)=";"
1480     ELSE
1481         pos%=0
1482         REPEAT
1483             pos%+=1
1484         UNTIL MID$(valid$,pos%,1)=";" AND (MID$(valid$,pos%+1,1)="s" OR MID$(valid$,pos%+1,1)="S")
1485         name$=""
1486         pos%=pos%+1
1487         REPEAT
1488             pos%+=1
1489             IF MID$(valid$,pos%,1)<>";" THEN
1490                 name$+=MID$(valid$,pos%,1)
1491             ENDIF
1492         UNTIL MID$(valid$,pos%,1)=";"
1493     ENDIF
1494 ENDIF
1495 =name$
1496 :
1497 DEF PROCwint_endsavedrag
1498 LOCAL drag%,write%,ok%,whan%,ico%,x%,y%
1499 drag%=0:write%=1:ok%=2
1500 PROCuser_saveicon(wSavew%,drag%,write%,ok%)
1501 SYS "DragASprite_Stop"
1502 SYS "Wimp_GetPointerInfo",,wimp%
1503 whan%=wimp%!12
1504 ico%=wimp%!16
1505 x%=wimp%!0
1506 y%=wimp%!4
1507 PROCwint_zeroterminate(wimp%+44,FNwimp_getleafname(FNwimp_geticontext(wSavew%,write%)))
1508 wimp%!20=whan%
1509 wimp%!24=ico%
1510 wimp%!28=x%
1511 wimp%!32=y%
1512 wimp%!36=1024
1513 wimp%!0=64
1514 wimp%!12=0
1515 wimp%!16=1
1516 SYS "OS_ReadUnsigned",10,"&"+wsavet$ TO ,,v%
1517 wimp%!40=v%
1518 SYS "Wimp_SendMessage",18,wimp%,wimp%!20,wimp%!24
1519 wSavedrag%=-1
1520 ENDPROC
1521 :
1522 DEF PROCwimp_bar(whan%,icon%,len%,dir%)
1523 LOCAL minx%,miny%,maxx%,maxy%,flag%,data1%,data2%,data3%,border%,filled%,oldb%,newend%
1524 wimp%!0=whan%
1525 wimp%!4=icon%
1526 SYS "Wimp_GetIconState",,wimp%
1527 minx%=wimp%!8
1528 miny%=wimp%!12
1529 maxx%=wimp%!16
1530 maxy%=wimp%!20
1531 flag%=wimp%!24
1532 data1%=wimp%!28
1533 data2%=wimp%!32
1534 data3%=wimp%!36
1535 filled%=(flag%>>5) AND 1
1536 border%=(flag%>>2) AND 1
1537 oldb%=(flag%>>11) AND 1
1538 IF len%<0 THEN len%=0
1539 SYS "Wimp_DeleteIcon",,wimp%
1540 IF dir%=0 THEN
1541     newend%=len%+minx%
1542     wimp%!4=minx%:wimp%!8=miny%
1543     wimp%!12=newend%:wimp%!16=maxy%
1544 ELSE
1545     newend%=len%+miny%
1546     wimp%!4=minx%:wimp%!8=miny%
1547     wimp%!12=maxx%:wimp%!16=newend%
1548 ENDIF
1549 wimp%!20=flag%
1550 wimp%!24=data1%
1551 wimp%!28=data2%
1552 wimp%!32=data3%
1553 SYS "Wimp_CreateIcon",,wimp%
1554 wimp%!0=whan%
1555 wimp%!4=icon%
1556 IF len%=0 THEN
1557     PROCwint_zerolengthbar(border%)
1558 ELSE
1559     IF filled%=0 THEN
1560         wimp%!8=32:wimp%!12=32
1561         SYS "Wimp_SetIconState",,wimp%
1562         IF oldb%=1 THEN
1563             wimp%!8=4:wimp%!12=4
1564             SYS "Wimp_SetIconState",,wimp%
1565         ENDIF
1566     ENDIF
1567 ENDIF
1568 IF dir%=0 THEN
1569     IF newend%<maxx% THEN
1570         SYS "Wimp_ForceRedraw",whan%,newend%-2,miny%,maxx%,maxy%
1571     ELSE
1572         SYS "Wimp_ForceRedraw",whan%,maxx%-2,miny%,newend%,maxy%
1573     ENDIF
1574 ELSE
1575     IF newend%<maxy% THEN
1576         SYS "Wimp_ForceRedraw",whan%,minx%,newend%-2,maxx%,maxy%
1577     ELSE
1578         SYS "Wimp_ForceRedraw",whan%,minx%,maxy%-2,maxx%,newend%
1579     ENDIF
1580 ENDIF
1581 ENDPROC
1582 :
1583 DEF PROCwint_zerolengthbar(border%)
1584 wimp%!8=0:wimp%!12=32
1585 SYS "Wimp_SetIconState",,wimp%
1586 IF border%=1 THEN
1587     wimp%!8=2048:wimp%!12=2048
1588     SYS "Wimp_SetIconState",,wimp%
1589     wimp%!8=0:wimp%!12=4
1590     SYS "Wimp_SetIconState",,wimp%
1591 ELSE
1592     wimp%!8=0:wimp%!12=2048
1593     SYS "Wimp_SetIconState",,wimp%
1594 ENDIF
1595 ENDPROC
1596 :
1597 DEF FNwimp_getsliderpcent(whan%,icon%)
1598 LOCAL a%,minx%,miny%,maxx%,maxy%,s1%,s2%,s3%,s4%,pcreal
1599 pcreal=0
1600 a%=FNuser_sliderback(whan%,icon%)
1601 IF a%=-1 THEN
1602     pcreal=0
1603 ELSE
1604     wimp%!0=whan%
1605     wimp%!4=icon%
1606     SYS "Wimp_GetIconState",,wimp%
1607     minx%=wimp%!8:maxx%=wimp%!16
1608     miny%=wimp%!12:maxy%=wimp%!20
1609     s1%=maxx%-minx%:s2%=maxy%-miny%
1610     wimp%!0=whan%
1611     wimp%!4=a%
1612     SYS "Wimp_GetIconState",,wimp%
1613     minx%=wimp%!8:maxx%=wimp%!16
1614     miny%=wimp%!12:maxy%=wimp%!20
1615     s3%=maxx%-minx%:s4%=maxy%-miny%
1616     IF s4%>s3% THEN
1617         pcreal=(s2%/s4%)*100
1618     ELSE
1619         pcreal=(s1%/s3%)*100
1620     ENDIF
1621 ENDIF
1622 =pcreal
1623 :
1624 DEF PROCwimp_putsliderpcent(whan%,icon%,pcreal)
1625 LOCAL a%,s1%,s2%,minx%,maxx%,len%
1626 a%=FNuser_sliderback(whan%,icon%)
1627 IF a%=-1 THEN
1628 ELSE
1629     wimp%!0=whan%
1630     wimp%!4=a%
1631     SYS "Wimp_GetIconState",,wimp%
1632     minx%=wimp%!8:maxx%=wimp%!16
1633     miny%=wimp%!12:maxy%=wimp%!20
1634     s1%=maxx%-minx%:s2%=maxy%-miny%
1635     IF s2%>s1% THEN
1636         len%=(pcreal/100)*s2%
1637         PROCwimp_bar(whan%,icon%,len%,1)
1638     ELSE
1639         len%=(pcreal/100)*s1%
1640         PROCwimp_bar(whan%,icon%,len%,0)
1641     ENDIF
1642 ENDIF
1643 ENDPROC
1644 :
1645 DEF PROCwint_startsliderdrag(whan%,icon%)
1646 LOCAL ox%,oy%,bx1%,by1%,bx2%,by2%
1647 wimp%!0=whan%
1648 SYS "Wimp_GetWindowState",,wimp%
1649 ox%=wimp%!4-wimp%!20
1650 oy%=wimp%!16-wimp%!24
1651 wimp%!0=whan%
1652 wimp%!4=FNuser_sliderback(whan%,icon%)
1653 SYS "Wimp_GetIconState",,wimp%
1654 bx1%=ox%+wimp%!8:by1%=oy%+wimp%!12
1655 bx2%=ox%+wimp%!16:by2%=oy%+wimp%!20
1656 wimp%!0=whan%
1657 wimp%!4=icon%
1658 SYS "Wimp_GetIconState",,wimp%
1659 wimp%!4=7
1660 wimp%!8=ox%+wimp%!8
1661 wimp%!12=oy%+wimp%!12
1662 wimp%!16=ox%+wimp%!16
1663 wimp%!20=oy%+wimp%!20
1664 wimp%!24=bx1%
1665 wimp%!28=by1%
1666 wimp%!32=bx2%
1667 wimp%!36=by2%
1668 SYS "Wimp_DragBox",,wimp%
1669 wSlidedrag%=whan%:wSlidew%=whan%:wSlidei%=icon%:wOx%=ox%:wOy%=oy%:wLen%=-1:wLen2%=-1
1670 wSwid%=bx2%-bx1%:wShei%=by2%-by1%
1671 ENDPROC
1672 :
1673 DEF PROCwint_draggingslider
1674 LOCAL minx%,miny%,maxx%,maxy%,len%,len2%
1675 wimp%!0=wSlidew%
1676 wimp%!4=wSlidei%
1677 SYS "Wimp_GetIconState",,wimp%
1678 minx%=wimp%!8+wOx%:maxx%=wimp%!16+wOx%
1679 miny%=wimp%!12+wOy%:maxy%=wimp%!20+wOy%
1680 SYS "Wimp_GetPointerInfo",,wimp%
1681 len%=wimp%!0-minx%
1682 len2%=wimp%!4-miny%
1683 IF wShei%>wSwid% THEN
1684     IF len2%<>wLen2% THEN
1685         PROCwimp_bar(wSlidew%,wSlidei%,len2%,1)
1686         wLen2%=len2%
1687         PROCuser_slidervalue(wSlidew%,wSlidei%,FNwint_calcsliderpcent(wSlidew%,wSlidei%,wShei%,1),1)
1688     ENDIF
1689 ELSE
1690     IF len%<>wLen% THEN
1691         PROCwimp_bar(wSlidew%,wSlidei%,len%,0)
1692         wLen%=len%
1693         PROCuser_slidervalue(wSlidew%,wSlidei%,FNwint_calcsliderpcent(wSlidew%,wSlidei%,wSwid%,0),0)
1694     ENDIF
1695 ENDIF
1696 ENDPROC
1697 :
1698 DEF PROCwint_endsliderdrag
1699 wSlidedrag%=-1
1700 IF wShei%>wSwid% THEN
1701     PROCuser_slidervalue(wSlidew%,wSlidei%,FNwint_calcsliderpcent(wSlidew%,wSlidei%,wShei%,1),1)
1702 ELSE
1703     PROCuser_slidervalue(wSlidew%,wSlidei%,FNwint_calcsliderpcent(wSlidew%,wSlidei%,wSwid%,0),0)
1704 ENDIF
1705 ENDPROC
1706 :
1707 DEF PROCwint_clickedslider(whan%,icon%,mx%,my%)
1708 LOCAL len%,minx%,miny%,maxx%,maxy%,ox%,oy%,len2%,minxb%,minyb%,maxxb%,maxyb%
1709 IF wimp%!8=2 THEN
1710 ELSE
1711     wimp%!0=whan%
1712     SYS "Wimp_GetWindowState",,wimp%
1713     ox%=wimp%!4-wimp%!20
1714     oy%=wimp%!16-wimp%!24
1715     wimp%!0=whan%
1716     wimp%!4=icon%
1717     SYS "Wimp_GetIconState",,wimp%
1718     minx%=wimp%!8+ox%:maxx%=wimp%!16+ox%
1719     miny%=wimp%!12+oy%:maxy%=wimp%!20+oy%
1720     len%=mx%-minx%:len2%=my%-miny%
1721     wimp%!0=whan%
1722     wimp%!4=FNuser_sliderback(whan%,icon%)
1723     SYS "Wimp_GetIconState",,wimp%
1724     minxb%=wimp%!8+ox%:maxxb%=wimp%!16+ox%
1725     minyb%=wimp%!12+oy%:maxyb%=wimp%!20+oy%
1726     IF (maxyb%-minyb%)>(maxxb%-minxb%) THEN
1727         PROCwimp_bar(whan%,icon%,len2%,1)
1728     ELSE
1729         PROCwimp_bar(whan%,icon%,len%,0)
1730     ENDIF
1731     wimp%!0=whan%
1732     wimp%!4=FNuser_sliderback(whan%,icon%)
1733     SYS "Wimp_GetIconState",,wimp%
1734     IF (maxyb%-minyb%)>(maxxb%-minxb%) THEN
1735         PROCuser_slidervalue(whan%,icon%,FNwint_calcsliderpcent(whan%,icon%,wimp%!20-wimp%!12,1),1)
1736     ELSE
1737         PROCuser_slidervalue(whan%,icon%,FNwint_calcsliderpcent(whan%,icon%,wimp%!16-wimp%!8,0),0)
1738     ENDIF
1739 ENDIF
1740 ENDPROC
1741 :
1742 DEF FNwint_calcsliderpcent(whan%,icon%,w%,dir%)
1743 LOCAL slideh%,slidew%,pc%
1744 pc%=0
1745 wimp%!0=whan%
1746 wimp%!4=icon%
1747 SYS "Wimp_GetIconState",,wimp%
1748 slideh%=wimp%!20-wimp%!12
1749 slidew%=wimp%!16-wimp%!8
1750 IF dir%=0 THEN
1751     pc%=INT((slidew%/w%)*100)
1752 ELSE
1753     pc%=INT((slideh%/w%)*100)
1754 ENDIF
1755 =pc%
1756 :
1757 DEF PROCwint_starticondrag(whan%,icon%,button%,mousex%,mousey%)
1758 LOCAL visminx%,visminy%,vismaxx%,vismaxy%,bx1%,by1%,bx2%,by2%
1759 LOCAL boundsminx%,boundsminy%,boundsmaxx%,boundsmaxy%
1760 LOCAL ox%,oy%,t%,i%,spritearea%,spritename$,drag%,write%,ok%
1761 wimp%!0=whan%
1762 SYS "Wimp_GetWindowState",,wimp%
1763 visminx%=wimp%!4
1764 visminy%=wimp%!8
1765 vismaxx%=wimp%!12
1766 vismaxy%=wimp%!16
1767 ox%=visminx%-wimp%!20
1768 oy%=vismaxy%-wimp%!24
1769 wimp%!0=whan%
1770 wimp%!4=icon%
1771 SYS "Wimp_GetIconState",,wimp%
1772 bx1%=ox%+wimp%!8
1773 by1%=oy%+wimp%!12
1774 bx2%=ox%+wimp%!16
1775 by2%=oy%+wimp%!20
1776 Relminx%=bx1%-mousex%
1777 Relminy%=by1%-mousey%
1778 Relmaxx%=bx2%-mousex%
1779 Relmaxy%=by2%-mousey%
1780 wimp%!4=5
1781 wimp%!8=bx1%
1782 wimp%!12=by1%
1783 wimp%!16=bx2%
1784 wimp%!20=by2%
1785 boundsminx%=visminx%
1786 boundsminy%=visminy%
1787 boundsmaxx%=vismaxx%
1788 boundsmaxy%=vismaxy%
1789 PROCwint_savewimp
1790 PROCuser_seticondragbounds(whan%,icon%,button%/16,mousex%,mousey%,boundsminx%,boundsminy%,boundsmaxx%,boundsmaxy%)
1791 PROCwint_loadwimp
1792 wimp%!24=boundsminx%
1793 wimp%!28=boundsminy%
1794 wimp%!32=boundsmaxx%
1795 wimp%!36=boundsmaxy%
1796 SYS "Wimp_DragBox",,wimp%
1797 wIcondrag%=whan%:wIconw%=whan%:wIconi%=icon%:wDragbutton%=button%/16:wStartx%=mousex%:wStarty%=mousey%
1798 ENDPROC
1799 :
1800 DEF PROCwint_draggingicon
1801 LOCAL x%,y%,overwindow%,overicon%,dragboxminx%,dragboxminy%,dragboxmaxx%,dragboxmaxy%
1802 SYS "Wimp_GetPointerInfo",,wimp%
1803 x%=wimp%!0
1804 y%=wimp%!4
1805 overwindow%=wimp%!12
1806 overicon%=wimp%!16
1807 dragboxminx%=x%+Relminx%
1808 dragboxminy%=y%+Relminy%
1809 dragboxmaxx%=x%+Relmaxx%
1810 dragboxmaxy%=y%+Relmaxy%
1811 PROCuser_draggingicon(wIconw%,wIconi%,wDragbutton%,wStartx%,wStarty%,x%,y%,overwindow%,overicon%,dragboxminx%,dragboxminy%,dragboxmaxx%,dragboxmaxy%)
1812 ENDPROC
1813 :
1814 DEF PROCwint_endicondrag(dragboxminx%,dragboxminy%,dragboxmaxx%,dragboxmaxy%)
1815 LOCAL whan%,icon%,x%,y%
1816 wIcondrag%=-1
1817 SYS "Wimp_GetPointerInfo",,wimp%
1818 whan%=wimp%!12
1819 icon%=wimp%!16
1820 x%=wimp%!0
1821 y%=wimp%!4
1822 PROCuser_endicondrag(wIconw%,wIconi%,wDragbutton%,wStartx%,wStarty%,dragboxminx%,dragboxminy%,dragboxmaxx%,dragboxmaxy%,whan%,icon%,x%,y%)
1823 ENDPROC
1824 :
1825 DEF FNwimp_iconbar(spritename$,text$,maxlen%,pos%)
1826 LOCAL temptext$,return%
1827 IF pos%<0 OR pos%>1 THEN pos%=1
1828 return%=-2
1829 pos%-=2
1830 DIM wIbarSprite% 19
1831 IF text$="" THEN
1832     return%=FNwint_iconbarsp(spritename$,pos%)
1833 ELSE
1834     IF LEN(text$) > maxlen% THEN maxlen%=LEN(text$)
1835     wMaxlen%=maxlen%
1836     DIM wIbarSprtxt% wMaxlen%-1
1837     temptext$=STRING$(wMaxlen%,"8")
1838     $wIbarSprite%="s"+spritename$
1839     $wIbarSprtxt%=temptext$
1840     wimp%!0=pos%
1841     wimp%!4=0
1842     wimp%!8=-16
1843     wimp%!12=128
1844     wimp%!16=88
1845     wimp%!20=&1700310B
1846     wimp%!24=wIbarSprtxt%
1847     wimp%!28=wIbarSprite%
1848     wimp%!32=wMaxlen%+1
1849     wBARTEXT%=TRUE
1850     SYS "Wimp_CreateIcon",,wimp% TO wIbarhan%
1851     PROCwimp_puticonbartext(LEFT$(text$,wMaxlen%))
1852 ENDIF
1853 =return%
1854 :
1855 DEF FNwint_iconbarsp(spritename$,pos%)
1856 $wIbarSprite%=spritename$
1857 wimp%!0=pos%
1858 wimp%!4=0
1859 wimp%!8=0
1860 wimp%!12=68
1861 wimp%!16=80
1862 wimp%!20=&1700310A
1863 wimp%!24=wIbarSprite%
1864 wimp%!28=1
1865 wimp%!32=20
1866 wBARTEXT%=FALSE
1867 SYS "Wimp_CreateIcon",,wimp% TO wIbarhan%
1868 =-2
1869 :
1870 DEF PROCwimp_puticonbartext(text$)
1871 IF wBARTEXT%=TRUE THEN
1872     IF $(wIbarSprtxt%)<>LEFT$(text$,wMaxlen%) THEN
1873         wimp%!0=-2
1874         wimp%!4=wIbarhan%
1875         SYS "Wimp_GetIconState",,wimp%
1876         $(wIbarSprtxt%)=LEFT$(text$,wMaxlen%)
1877         SYS "Wimp_ForceRedraw",-2,wimp%!8,wimp%!12,wimp%!16,wimp%!20
1878     ENDIF
1879 ENDIF
1880 ENDPROC
1881 :
1882 DEF PROCwimp_iconbarsprite(spritename$)
1883 IF wBARTEXT%=FALSE THEN
1884     PROCwint_ibarspritep(spritename$)
1885 ELSE
1886     IF $(wIbarSprite%)<>"s"+spritename$ THEN
1887         $wIbarSprite%="s"+spritename$
1888         wimp%!0=-2
1889         wimp%!4=wIbarhan%
1890         SYS "Wimp_GetIconState",,wimp%
1891         SYS "Wimp_ForceRedraw",-2,wimp%!8,wimp%!12,wimp%!16,wimp%!20
1892     ENDIF
1893 ENDIF
1894 ENDPROC
1895 :
1896 DEF PROCwint_ibarspritep(spritename$)
1897 IF $(wIbarSprite%)<>spritename$ THEN
1898     wimp%!0=-2
1899     wimp%!4=wIbarhan%
1900     SYS "Wimp_GetIconState",,wimp%
1901     $(wimp%!28)=spritename$
1902     SYS "Wimp_ForceRedraw",-2,wimp%!8,wimp%!12,wimp%!16,wimp%!20
1903 ENDIF
1904 ENDPROC
1905 :
1906 DEF FNwimp_createmenu(menu$,size%)
1907 LOCAL menu%,num%,pos%,ptr%,L%,m$,width%,extra%,title$,itemlen%
1908 num%=FNwint_numberofentries(menu$)
1909 num%-=1
1910 IF size%<=num% THEN size%=num%
1911 extra%=size%-num%
1912 DIM menu% (4+28+(size%*24))-1
1913 !menu%=size%
1914 menu%=menu%+4
1915 pos%=INSTR(menu$,"/")
1916 IF pos%=1 THEN
1917     title$=" "
1918 ELSE
1919     title$=LEFT$(menu$,pos%-1)
1920 ENDIF
1921 menu$=RIGHT$(menu$,LEN(menu$)-pos%)
1922 width%=FNwint_titleblockandwidth(menu%,title$,0)
1923 ptr%=menu%+28
1924 FOR L%=1 TO num%
1925     m$=FNwint_decodemenuentry(menu$,L%)
1926     itemlen%=FNwint_menuitemblockandwidth(ptr%,num%,L%,m$,0)
1927     IF itemlen%>width% THEN width%=itemlen%
1928     ptr%+=24
1929 NEXT L%
1930 menu%!16=width%+16
1931 IF extra%>0 THEN
1932     PROCwint_menuextraitems(ptr%,extra%)
1933 ENDIF
1934 =menu%
1935 :
1936 DEF FNwimp_createmenuarray(array$(),size%)
1937 LOCAL num%,extra%,menu%,L%,ptr%,width%,itemlen%,title$,m$,itemtext%,itemlen%
1938 num%=FNwint_getmenuarraysize(array$())
1939 IF size%<num% THEN size%=num%
1940 extra%=size%-num%
1941 DIM menu% (4+28+(24*size%))-1
1942 !menu%=size%
1943 menu%=menu%+4
1944 title$=array$(0)
1945 IF title$="" THEN title$=" "
1946 width%=FNwint_titleblockandwidth(menu%,title$,0)
1947 ptr%=menu%+28
1948 FOR L%=1 TO num%
1949     m$=array$(L%)
1950     itemlen%=FNwint_menuitemblockandwidth(ptr%,num%,L%,m$,0)
1951     IF itemlen%>width% THEN width%=itemlen%
1952     ptr%+=24
1953 NEXT L%
1954 menu%!16=width%+16
1955 IF extra%>0 THEN
1956     PROCwint_menuextraitems(ptr%,extra%)
1957 ENDIF
1958 =menu%
1959 :
1960 DEF FNwimp_createmessagemenu(messagefilehandle%,token$,title$,size%)
1961 LOCAL num%,extra%,menu%,L%,ptr%,width%,itemlen%,m$
1962 num%=FNwimp_getnumberofmessages(messagefilehandle%,token$)
1963 m$=FNwimp_messlookup(messagefilehandle%,token$+"T","","")
1964 IF m$="" THEN m$=FNwimp_messlookup(messagefilehandle%,token$+"t","","")
1965 IF m$<>"" THEN num%-=1
1966 IF title$="" THEN
1967     IF m$="" THEN m$=" "
1968 ELSE
1969     m$=title$
1970 ENDIF
1971 IF size%<num% THEN size%=num%
1972 extra%=size%-num%
1973 DIM menu% (4+28+(24*size%))-1
1974 !menu%=size%
1975 menu%=menu%+4
1976 width%=FNwint_titleblockandwidth(menu%,m$,0)
1977 ptr%=menu%+28
1978 FOR L%=1 TO num%
1979     m$=FNwimp_messlookup(messagefilehandle%,token$+STR$(L%),"","")
1980     itemlen%=FNwint_menuitemblockandwidth(ptr%,num%,L%,m$,0)
1981     IF itemlen%>width% THEN width%=itemlen%
1982     ptr%+=24
1983 NEXT L%
1984 menu%!16=width%+16
1985 IF extra%>0 THEN
1986     PROCwint_menuextraitems(ptr%,extra%)
1987 ENDIF
1988 =menu%
1989 :
1990 DEF PROCwimp_recreatemenu(menu%,menu$)
1991 LOCAL num%,pos%,L%,ptr%,m$,title$,width%,itemlen%
1992 IF !(menu%-4)=-1 THEN
1993     PROCwimp_error("","Sorry, you can't use 'PROCwimp_recreatemenu' on a Font menu.",1,1)
1994 ELSE
1995     num%=FNwint_numberofentries(menu$)
1996     num%-=1
1997     IF num%>FNwimp_menumaxsize(menu%) THEN
1998         PROCwimp_error("","Sorry, you are trying to recreate a menu to a larger size than was allowed for when it was created.",1,1)
1999     ELSE
2000         pos%=INSTR(menu$,"/")
2001         IF pos%=1 THEN
2002             title$=" "
2003         ELSE
2004             title$=LEFT$(menu$,pos%-1)
2005         ENDIF
2006         menu$=RIGHT$(menu$,LEN(menu$)-pos%)
2007         width%=FNwint_titleblockandwidth(menu%,title$,1)
2008         ptr%=menu%+28
2009         FOR L%=1 TO num%
2010             pos%=INSTR(menu$,"/")
2011             IF pos%=0 THEN
2012                 m$=menu$
2013             ELSE
2014                 m$=LEFT$(menu$,pos%-1)
2015                 menu$=RIGHT$(menu$,LEN(menu$)-pos%)
2016             ENDIF
2017             itemlen%=FNwint_menuitemblockandwidth(ptr%,num%,L%,m$,1)
2018             IF itemlen%>width% THEN width%=itemlen%
2019             ptr%+=24
2020         NEXT L%
2021         menu%!16=width%+16
2022     ENDIF
2023 ENDIF
2024 ENDPROC
2025 :
2026 DEF PROCwimp_recreatemenuarray(menu%,array$())
2027 LOCAL num%,L%,ptr%,m$,itemlen%,width%,title$
2028 IF !(menu%-4)=-1 THEN
2029     PROCwimp_error("","Sorry, you can't use 'PROCwimp_recreatemenuarray' on a Font menu.",1,1)
2030 ELSE
2031     num%=FNwint_getmenuarraysize(array$())
2032     IF num%>FNwimp_menumaxsize(menu%) THEN
2033         PROCwimp_error("","Sorry, you are trying to recreate a menu to a larger size than was allowed for when it was created.",1,1)
2034     ELSE
2035         title$=array$(0)
2036         IF title$="" THEN title$=" "
2037         width%=FNwint_titleblockandwidth(menu%,title$,1)
2038         ptr%=menu%+28
2039         FOR L%=1 TO num%
2040             m$=array$(L%)
2041             itemlen%=FNwint_menuitemblockandwidth(ptr%,num%,L%,m$,1)
2042             IF itemlen%>width% THEN width%=itemlen%
2043             ptr%+=24
2044         NEXT L%
2045         menu%!16=width%+16
2046     ENDIF
2047 ENDIF
2048 ENDPROC
2049 :
2050 DEF PROCwimp_recreatemessagemenu(menu%,messagefilehandle%,token$,title$)
2051 LOCAL num%,L%,ptr%,width%,itemlen%,m$
2052 IF !(menu%-4)=-1 THEN
2053     PROCwimp_error("","Sorry, you can't use 'PROCwimp_recreatemenuarray' on a Font menu.",1,1)
2054 ELSE
2055     num%=FNwimp_getnumberofmessages(messagefilehandle%,token$)
2056     m$=FNwimp_messlookup(messagefilehandle%,token$+"T","","")
2057     IF m$="" THEN m$=FNwimp_messlookup(messagefilehandle%,token$+"t","","")
2058     IF m$<>"" THEN num%-=1
2059     IF title$="" THEN
2060         IF m$="" THEN m$=" "
2061     ELSE
2062         m$=title$
2063     ENDIF
2064     IF num%>FNwimp_menumaxsize(menu%) THEN
2065         PROCwimp_error("","Sorry, you are trying to recreate a menu to a larger size than was allowed for when it was created.",1,1)
2066     ELSE
2067         width%=FNwint_titleblockandwidth(menu%,m$,1)
2068         ptr%=menu%+28
2069         FOR L%=1 TO num%
2070             m$=FNwimp_messlookup(messagefilehandle%,token$+STR$(L%),"","")
2071             itemlen%=FNwint_menuitemblockandwidth(ptr%,num%,L%,m$,1)
2072             IF itemlen%>width% THEN width%=itemlen%
2073             ptr%+=24
2074         NEXT L%
2075         menu%!16=width%+16
2076     ENDIF
2077 ENDIF
2078 ENDPROC
2079 :
2080 DEF FNwimp_getnumberofmessages(messagefilehandle%,token$)
2081 LOCAL number%,move%,next%
2082 number%=0
2083 move%=0
2084 REPEAT
2085     SYS "MessageTrans_EnumerateTokens",messagefilehandle%,token$+"*",wMessageout%,256,move% TO ,,next%,,move%
2086     number%+=1
2087 UNTIL next%=0
2088 =number%-1
2089 :
2090 DEF FNwint_getmenuarraysize(array$())
2091 LOCAL count%
2092 count%=0
2093 REPEAT
2094     count%+=1
2095 UNTIL array$(count%)="END"
2096 =count%-1
2097 :
2098 DEF FNwint_titleblockandwidth(menu%,title$,recreate%)
2099 LOCAL titlelen%,titlebuff%,oldtitlelen%,width%
2100 titlelen%=LEN(title$)
2101 IF recreate%=1 THEN
2102     titlebuff%=!menu%
2103     oldtitlelen%=(menu%!8)-1
2104     IF titlelen%>oldtitlelen% THEN DIM titlebuff% titlelen%
2105 ELSE
2106     DIM titlebuff% titlelen%
2107 ENDIF
2108 $titlebuff%=title$
2109 menu%!0=titlebuff%
2110 menu%!8=titlelen%+1
2111 width%=(titlelen%)*16
2112 menu%!12=&00070207
2113 menu%!20=44
2114 menu%!24=0
2115 =width%
2116 :
2117 DEF FNwint_menuitemblockandwidth(pointer%,number%,item%,item$,recreate%)
2118 LOCAL mflags%,itemlen%,itemtext%,olditemlen%
2119 CASE item% OF
2120     WHEN 1: IF item%=number% THEN mflags%=&188 ELSE mflags%=&108
2121     WHEN number%: mflags%=&88
2122     OTHERWISE: mflags%=8
2123 ENDCASE
2124 !pointer%=mflags%
2125 pointer%!4=-1
2126 pointer%!8=&07000121
2127 itemlen%=LEN(item$)
2128 IF recreate%=1 THEN
2129     itemtext%=pointer%!12
2130     olditemlen%=pointer%!20-1
2131     IF itemlen%>olditemlen% THEN DIM itemtext% itemlen%
2132 ELSE
2133     DIM itemtext% itemlen%
2134 ENDIF
2135 $(itemtext%)=item$
2136 pointer%!12=itemtext%
2137 pointer%!16=-1
2138 pointer%!20=itemlen%+1
2139 itemlen%=(LEN(item$)+1)*16
2140 =itemlen%
2141 :
2142 DEF PROCwint_menuextraitems(pointer%,extra%)
2143 LOCAL L%,item$,itemlen%,itemtext%
2144 FOR L%=1 TO extra%
2145     item$=" "
2146     itemlen%=LEN(item$)
2147     DIM itemtext% itemlen%
2148     $(itemtext%)=item$
2149     pointer%!12=itemtext%
2150     pointer%!16=-1
2151     pointer%!20=itemlen%+1
2152     pointer%+=24
2153 NEXT
2154 ENDPROC
2155 :
2156 DEF FNwimp_menusize(menu%)
2157 LOCAL wptr%,end%,count%,flag%
2158 end%=FALSE
2159 wptr%=menu%+4
2160 count%=0
2161 REPEAT
2162     wptr%+=24
2163     count%+=1
2164     flag%=wptr%!0
2165     flag%=flag%>>7
2166     IF (flag% AND 1)=1 THEN end%=TRUE
2167 UNTIL end%=TRUE
2168 =count%
2169 :
2170 DEF FNwimp_menumaxsize(menu%)
2171 return%=0
2172 IF !(menu%-4)=-1 THEN
2173     PROCwimp_error("","Sorry, you can't use 'FNwimp_menumaxsize' on a Font menu. 0 will be returned.",1,1)
2174 ELSE
2175     return%=!(menu%-4)
2176 ENDIF
2177 =return%
2178 :
2179 DEF FNwimp_getmenutick(menu%,item%)
2180 LOCAL return%,wptr%
2181 IF !(menu%-4)=-1 THEN
2182     PROCwimp_error("","Sorry, you can't use 'FNwimp_getmenutick' with a Font menu. The return will be 0.",1,1)
2183     return%=0
2184 ELSE
2185     wptr%=(menu%+28)+(24*(item%-1))
2186     return%=wptr%!0 AND 1
2187 ENDIF
2188 =return%
2189 :
2190 DEF PROCwimp_menutick(menu%,item%,state%)
2191 LOCAL wptr%
2192 IF !(menu%-4)=-1 THEN
2193     PROCwimp_error("","Sorry, you can't use 'PROCwimp_menutick' to alter a Font menu.",1,1)
2194 ELSE
2195     IF state%<0 OR state%>2 THEN state%=1
2196     wptr%=(menu%+28)+(24*(item%-1))
2197     CASE state% OF
2198         WHEN 0:?wptr%=?wptr% AND &FE
2199         WHEN 1:?wptr%=?wptr% OR 1
2200         WHEN 2:?wptr%=?wptr% EOR 1
2201     ENDCASE
2202 ENDIF
2203 ENDPROC
2204 :
2205 DEF PROCwimp_menuenable(menu%,item%,state%)
2206 LOCAL wptr%
2207 IF !(menu%-4)=-1 THEN
2208     PROCwimp_error("","Sorry, you can't use 'PROCwimp_menuenable' to alter a Font menu.",1,1)
2209 ELSE
2210     IF state%<0 OR state%>2 THEN state%=1
2211     wptr%=(menu%+28)+(24*(item%-1))
2212     CASE state% OF
2213         WHEN 0:wptr%!8=wptr%!8 OR (1<<22)
2214         WHEN 1:wptr%!8=wptr%!8 OR (1<<22)
2215         wptr%!8=wptr%!8 EOR (1<<22)
2216         WHEN 2:wptr%!8=wptr%!8 EOR (1<<22)
2217     ENDCASE
2218 ENDIF
2219 ENDPROC
2220 :
2221 DEF FNwimp_getmenuenable(menu%,item%)
2222 LOCAL return%,wptr%
2223 return%=0
2224 IF !(menu%-4)=-1 THEN
2225     PROCwimp_error("","Sorry, you can't use 'FNwimp_getmenuenable' with a Font menu. The return will be 0.",1,1)
2226 ELSE
2227     wptr%=(menu%+28)+(24*(item%-1))
2228     return%=1-(wptr%!8>>22 AND 1)
2229 ENDIF
2230 =return%
2231 :
2232 DEF PROCwimp_menudottedline(menu%,item%,on%)
2233 LOCAL wptr%
2234 IF !(menu%-4)=-1 THEN
2235     PROCwimp_error("","Sorry, you can't use 'PROCwimp_menudottedline' to alter a Font menu.",1,1)
2236 ELSE
2237     wptr%=(menu%+28)+(24*(item%-1))
2238     ?wptr%=(?wptr%) OR 1<<1
2239     IF on%=0 THEN
2240         ?wptr%=(?wptr%) EOR 1<<1
2241     ENDIF
2242 ENDIF
2243 ENDPROC
2244 :
2245 DEF FNwimp_getmenudottedline(menu%,item%)
2246 LOCAL return%,wptr%
2247 return%=0
2248 IF !(menu%-4)=-1 THEN
2249     PROCwimp_error("","Sorry, you can't use 'FNwimp_getmenudottedline' with a Font menu. The return will be 0.",1,1)
2250 ELSE
2251     wptr%=(menu%+28)+(24*(item%-1))
2252     return%=((wptr%!0>>1) AND 1)
2253 ENDIF
2254 =return%
2255 :
2256 DEF PROCwimp_menuitemcolour(menu%,item%,colour%,background%)
2257 LOCAL ptr%,mask%,offset%
2258 IF !(menu%-4)=-1 THEN
2259     PROCwimp_error("","Sorry, you can't use 'PROCwimp_menuitemcolour' to alter a Font menu.",1,1)
2260 ELSE
2261     ptr%=(menu%+28)+(24*(item%-1))
2262     IF background%=0 THEN
2263         offset%=24
2264         mask%=&F0FFFFFF
2265     ELSE
2266         offset%=28
2267         mask%=&0FFFFFFF
2268     ENDIF
2269     ptr%!8=ptr%!8 AND mask%
2270     ptr%!8=ptr%!8 OR (colour%<<offset%)
2271 ENDIF
2272 ENDPROC
2273 :
2274 DEF FNwimp_getmenutitle(menu%)
2275 LOCAL return$
2276 IF !(menu%-4)=-1 THEN
2277     PROCwimp_error("","Sorry, you can't use 'FNwimp_getmenutitle' with a Font menu. The return will be a null string.",1,1)
2278     return$=""
2279 ELSE
2280     return$=FNwint_string(menu%!0)
2281 ENDIF
2282 =return$
2283 :
2284 DEF PROCwimp_putmenutitle(menu%,title$)
2285 LOCAL titlebuff%,newtitlelen%,oldtitlelen%
2286 IF !(menu%-4)=-1 THEN
2287     PROCwimp_error("","Sorry, you can't use 'PROCwimp_putmenutitle' to alter a Font menu.",1,1)
2288 ELSE
2289     IF title$="" THEN title$=" "
2290     newtitlelen%=LEN(title$)
2291     titlebuff%=!menu%
2292     oldtitlelen%=menu%!8-1
2293     IF newtitlelen%>oldtitlelen% THEN DIM titlebuff% newtitlelen%
2294     !menu%=titlebuff%
2295     $titlebuff%=title$
2296     menu%!8=newtitlelen%+1
2297     PROCwint_calcmenuwidth(menu%)
2298 ENDIF
2299 ENDPROC
2300 :
2301 DEF FNwimp_getmenutext(menu%,item%)
2302 LOCAL p%,return$
2303 IF !(menu%-4)=-1 THEN
2304     PROCwimp_error("","Sorry, you can't use 'FNwimp_getmenutext' with a Font menu. The return will be a null string.",1,1)
2305     return$=""
2306 ELSE
2307     p%=28+12+((item%-1)*24)
2308     return$=FNwint_string(menu%!p%)
2309 ENDIF
2310 =return$
2311 :
2312 DEF PROCwimp_putmenutext(menu%,item%,text$)
2313 LOCAL p%,itemtext%,newitemlen%,olditemlen%,writable%,itemlen%
2314 IF !(menu%-4)=-1 THEN
2315     PROCwimp_error("","Sorry, you can't use 'PROCwimp_putmenutext' to alter a Font menu.",1,1)
2316 ELSE
2317     newitemlen%=LEN(text$)
2318     p%=28+12+((item%-1)*24)
2319     itemtext%=menu%!p%
2320     olditemlen%=menu%!(p%+8)-1
2321     writable%=(menu%!(p%-12)>>2) AND 1
2322     IF newitemlen%>olditemlen% THEN
2323         itemlen%=newitemlen%
2324         DIM itemtext% itemlen%
2325     ELSE
2326         IF writable%=1 THEN
2327             itemlen%=olditemlen%
2328         ELSE
2329             itemlen%=newitemlen%
2330         ENDIF
2331     ENDIF
2332     menu%!p%=itemtext%
2333     $(itemtext%)=text$
2334     menu%!(p%+8)=itemlen%+1
2335     PROCwint_calcmenuwidth(menu%)
2336 ENDIF
2337 ENDPROC
2338 :
2339 DEF PROCwimp_putmenuitem(menu%,item%,text$)
2340 LOCAL num%,ptr%,submenu%,L%,M%,itemtext%,itemlen%
2341 IF !(menu%-4)=-1 THEN
2342     PROCwimp_error("","Sorry, you can't use 'PROCwimp_putmenuitem' to alter a Font menu.",1,1)
2343 ELSE
2344     num%=FNwimp_menusize(menu%)
2345     IF num%<FNwimp_menumaxsize(menu%) THEN
2346         IF item%>(num%+1) THEN item%=num%+1
2347         IF item%<1 THEN item%=1
2348         ptr%=menu%+4
2349         IF item%=num%+1 THEN
2350             ptr%+=24*num%
2351             ptr%!0=ptr%!0 OR (1<<7)
2352             ptr%!0=ptr%!0 EOR (1<<7)
2353             ptr%+=24
2354             ptr%!0=&88
2355         ELSE
2356             ptr%+=24*(num%+1)
2357             FOR L%=(num%+1) TO (item%+1) STEP -1
2358                 FOR M%=0 TO 20 STEP 4
2359                     ptr%!M%=ptr%!(M%-24)
2360                 NEXT M%
2361                 IF L%=2 THEN
2362                     ptr%!0=ptr%!0 OR (1<<8)
2363                     ptr%!0=ptr%!0 EOR (1<<8)
2364                 ENDIF
2365                 ptr%-=24
2366             NEXT L%
2367             ptr%=(menu%+4)+(24*item%)
2368             IF item%=1 THEN
2369                 ptr%!0=&108
2370             ELSE
2371                 ptr%!0=&8
2372             ENDIF
2373         ENDIF
2374         ptr%!4=-1
2375         ptr%!8=&07000121
2376         ptr%!16=-1
2377         itemlen%=LEN(text$)
2378         DIM itemtext% itemlen%
2379         $itemtext%=text$
2380         ptr%!12=itemtext%
2381         ptr%!20=itemlen%+1
2382         PROCwint_calcmenuwidth(menu%)
2383     ELSE
2384         PROCwimp_error("","Sorry, but this menu already has the maximum number of items specified when it was first created.",1,1)
2385     ENDIF
2386 ENDIF
2387 ENDPROC
2388 :
2389 DEF PROCwimp_removemenuitem(menu%,item%)
2390 LOCAL num%,M%,L%,ptr%
2391 IF !(menu%-4)=-1 THEN
2392     PROCwimp_error("","Sorry, you can't use 'PROCwimp_removemenuitem' to alter a Font menu.",1,1)
2393 ELSE
2394     num%=FNwimp_menusize(menu%)
2395     IF num%<>1 THEN
2396         IF item%<1 THEN item%=1
2397         IF item%>num% THEN item%=num%
2398         ptr%=menu%+4
2399         IF item%=num% THEN
2400             ptr%+=24*(item%-1)
2401             ptr%!0=(ptr%!0 OR (1<<7))
2402         ELSE
2403             ptr%+=24*item%
2404             FOR L%=item% TO num%-1
2405                 FOR M%=0 TO 20 STEP 4
2406                     ptr%!M%=ptr%!(M%+24)
2407                 NEXT M%
2408                 ptr%+=24
2409             NEXT L%
2410         ENDIF
2411         menu%!28=menu%!28 OR (1<<8)
2412         PROCwint_calcmenuwidth(menu%)
2413     ENDIF
2414 ENDIF
2415 ENDPROC
2416 :
2417 DEF FNwimp_getmenuitem(menu%,menutext$)
2418 LOCAL return%,match%,menusize%,item%
2419 IF !(menu%-4)=-1 THEN
2420     PROCwimp_error("","Sorry, you can't use 'FNwimp_getmenuitem' with a Font menu. The return will be 0.",1,1)
2421     return%=0
2422 ELSE
2423     return%=0
2424     match%=FALSE
2425     menusize%=FNwimp_menusize(menu%)
2426     item%=0
2427     REPEAT
2428         item%+=1
2429         IF FNwimp_changecase(menutext$,0)=FNwimp_changecase(FNwimp_getmenutext(menu%,item%),0) THEN match%=TRUE
2430     UNTIL match%=TRUE OR item%=menusize%
2431     IF match%=TRUE THEN return%=item%
2432 ENDIF
2433 =return%
2434 :
2435 DEF PROCwimp_menuwrite(menu%,item%,maxlen%,border%,valid$)
2436 LOCAL num%,currenttext$,itemtext%
2437 IF !(menu%-4)=-1 THEN
2438     PROCwimp_error("","Sorry, you can't use 'PROCwimp_menuwrite' to alter a Font menu.",1,1)
2439 ELSE
2440     num%=FNwimp_menusize(menu%)
2441     IF item%>num% THEN item%=num%
2442     IF item%<1 THEN item%=1
2443     p%=28+12+((item%-1)*24)
2444     itemtext%=menu%!p%
2445     currenttext$=FNwint_string(itemtext%)
2446     IF LEN(currenttext$)>maxlen% THEN maxlen%=LEN(currenttext$)
2447     DIM itemtext% maxlen%
2448     DIM valid% 47
2449     $(valid%)="Pptr_write;Knar;"+valid$
2450     menu%!p%=itemtext%
2451     $(itemtext%)=currenttext$
2452     menu%!(p%+4)=valid%
2453     menu%!(p%+8)=maxlen%+1
2454     menu%!(p%-12)=menu%!(p%-12) OR 1<<2
2455     menu%?(p%-4)=menu%?(p%-4) OR 1<<2
2456     IF border%=0 THEN menu%?(p%-4)=(menu%?(p%-4) EOR 1<<2)
2457     PROCwint_calcmenuwidth(menu%)
2458 ENDIF
2459 ENDPROC
2460 :
2461 DEF PROCwimp_menupopup(menu%,pos%,x%,y%)
2462 LOCAL xpos%,ypos%,xmax%,ymax%,whan%,menuicon%,yalt%
2463 IF (menu% AND 1)=0 THEN
2464     IF !(menu%-4)=-1 THEN wFONTMENU%=menu%
2465 ENDIF
2466 SYS "Wimp_GetPointerInfo",,wimp%
2467 xpos%=wimp%!0
2468 ypos%=wimp%!4
2469 whan%=wimp%!12
2470 wHoldwhan%=whan%
2471 menuicon%=wimp%!16
2472 IF pos%=4 AND menuicon%<0 THEN pos%=3
2473 PROCwint_savewimp2
2474 PROCuser_menuopen(menu%,wHoldwhan%,menuicon%)
2475 PROCwint_loadwimp2
2476 CASE pos% OF
2477     WHEN 1
2478     yalt%=FNwint_iconbardottedlinemenusize(menu%)
2479     SYS "Wimp_CreateMenu",,menu%,x%-64,yalt%
2480     WHEN 2    : PROCwint_centremenu(menu%)
2481     WHEN 3    : SYS "Wimp_CreateMenu",,menu%,xpos%+54,ypos%+20
2482     WHEN 4
2483     wimp%!0=whan%
2484     wimp%!4=menuicon%
2485     SYS "Wimp_GetIconState",,wimp%
2486     xmax%=wimp%!16
2487     ymax%=wimp%!20
2488     SYS "Wimp_CreateMenu",,menu%,FNwimp_worktoscreen(whan%,xmax%,0),FNwimp_worktoscreen(whan%,ymax%,1)
2489     OTHERWISE : SYS "Wimp_CreateMenu",,menu%,x%,y%
2490 ENDCASE
2491 PROCwint_checksavewindow(menu%)
2492 wLastmenu%=menu%
2493 ENDPROC
2494 :
2495 DEF PROCwimp_menuclose
2496 SYS "Wimp_CreateMenu",,-1
2497 ENDPROC
2498 :
2499 DEF PROCwimp_attachsubmenu(menu%,item%,sub%)
2500 !(menu%+8+(item%*24))=sub%
2501 ENDPROC
2502 :
2503 DEF FNwimp_createfontmenu
2504 LOCAL size%,ind%,fontdyn%,fontmenu%,fontind%
2505 SYS "Font_ListFonts",,0,&80000,,0 TO ,,,size%,,ind%
2506 fontdyn%=FNwimp_createdynamic(size%+8,200000,0,"FontDyn")
2507 fontind%=FNwimp_createdynamic(ind%,100000,0,"FontInd")
2508 fontdyn%!0=fontind%
2509 fontdyn%!4=-1
2510 fontmenu%=fontdyn%+8
2511 SYS "Font_ListFonts",,fontmenu%,&80000,size%,fontind%,ind%
2512 =fontmenu%
2513 :
2514 DEF FNwimp_recreatefontmenu(fontmenu%)
2515 LOCAL oldfontdyn%,oldind%,size%,ind%,newfontdyn%,newind%,newfontmenu%
2516 oldind%=!(fontmenu%-8)
2517 oldfontdyn%=fontmenu%-8
2518 SYS "Font_ListFonts",,0,&80000,,0 TO ,,,size%,,ind%
2519 newfontdyn%=FNwimp_changedynamic(oldfontdyn%,1,size%+8)
2520 newind%=FNwimp_changedynamic(oldind%,1,ind%)
2521 newfontdyn%!0=newind%
2522 newfontdyn%!4=-1
2523 newfontmenu%=newfontdyn%+8
2524 SYS "Font_ListFonts",,newfontmenu%,&80000,size%,newind%,ind%
2525 =newfontmenu%
2526 :
2527 DEF PROCwint_calcmenuwidth(menu%)
2528 LOCAL title$,width%,wptr%,writable%,itemlen%,item$,flag%
2529 title$=FNwint_string(menu%!0)
2530 width%=(LEN(title$))*16
2531 wptr%=menu%+28
2532 REPEAT
2533     writable%=(wptr%!0>>2) AND 1
2534     IF writable%=1 THEN
2535         itemlen%=(wptr%!20)-1
2536     ELSE
2537         item$=FNwint_string(wptr%!12)
2538         itemlen%=LEN(item$)
2539     ENDIF
2540     IF (itemlen%*16)>width% THEN width%=(itemlen%)*16
2541     flag%=!wptr%
2542     flag%=(flag%>>7)
2543     wptr%+=24
2544 UNTIL (flag% AND 1) =1
2545 menu%!16=width%+16
2546 ENDPROC
2547 :
2548 DEF FNwint_numberofentries(menu$)
2549 LOCAL total%,L%
2550 total%=1
2551 FOR L%=1 TO LEN(menu$)
2552     IF MID$(menu$,L%,1)="/" THEN total%+=1
2553 NEXT L%
2554 =total%
2555 :
2556 DEF FNwint_decodemenuentry(menu$,item%)
2557 LOCAL M%,count%,omenu$
2558 M%=0
2559 count%=1
2560 REPEAT
2561     IF MID$(menu$,M%,1)="/" THEN count%+=1
2562     M%+=1
2563 UNTIL count%=item%
2564 omenu$=menu$
2565 omenu$=RIGHT$(omenu$,LEN(omenu$)-(M%-1))
2566 count%=INSTR(omenu$,"/")
2567 IF count%>0 THEN omenu$=LEFT$(omenu$,count%-1)
2568 =omenu$
2569 :
2570 DEF PROCwint_getmenuanditem(mainmenu%,RETURN menu%,RETURN item%)
2571 LOCAL ptr%
2572 IF (wimp%!4)=-1 THEN
2573     menu%=mainmenu%
2574     item%=(wimp%!0)+1
2575 ELSE
2576     ptr%=0
2577     menu%=mainmenu%
2578     REPEAT
2579         menu%=FNwint_findsubmenuptr(menu%,(wimp%!ptr%)+1)
2580         ptr%+=4
2581     UNTIL (wimp%!(ptr%+4))=-1
2582     item%=(wimp%!ptr%)+1
2583 ENDIF
2584 ENDPROC
2585 :
2586 DEF FNwint_findsubmenuptr(menu%,item%)
2587 LOCAL wptr%
2588 wptr%=menu%+4
2589 wptr%+=24*item%
2590 =wptr%!4
2591 :
2592 DEF PROCwint_centremenu(menu%)
2593 LOCAL x0%,y0%,x1%,y1%,wwidth%,wheight%,swidth%,sheight%,x%,y%
2594 wimp%!0=menu%
2595 SYS "XWimp_GetWindowInfo",,(wimp% OR %1) TO ;flag%
2596 IF (flag% AND 1)=1 THEN
2597     wwidth%=menu%!16
2598     wheight%=44*(FNwimp_menusize(menu%)+1)
2599 ELSE
2600     x0%=wimp%!4:y0%=wimp%!8
2601     x1%=wimp%!12:y1%=wimp%!16
2602     wwidth%=x1%-x0%
2603     wheight%=y1%-y0%
2604 ENDIF
2605 swidth%=FNwimp_getscreensize(0)
2606 sheight%=FNwimp_getscreensize(1)
2607 x%=(swidth%-wwidth%)/2
2608 y%=((sheight%-wheight%)/2)+wheight%
2609 SYS "Wimp_CreateMenu",,menu%,x%,y%
2610 ENDPROC
2611 :
2612 DEF PROCwint_opensubmenu(submenuhandle%,x%,y%,rootmenuitem%)
2613 LOCAL submenunumber%,position%,parentmenuitem%
2614 submenunumber%=0
2615 REPEAT
2616     submenunumber%+=1
2617     position%=(32+(4*(submenunumber%)))
2618 UNTIL wimp%!position%=-1
2619 parentmenuitem%=wimp%!(32+(4*(submenunumber%-1)))
2620 wSubmenu%=submenuhandle%
2621 IF (wSubmenu% AND 1)=0 THEN
2622     IF !(wSubmenu%-4)=-1 THEN wFONTMENU%=wSubmenu%
2623 ENDIF
2624 PROCuser_overmenuarrow(wLastmenu%,rootmenuitem%+1,wSubmenu%,submenunumber%,parentmenuitem%+1,x%,y%)
2625 IF wSubmenu% <> wSUBMENUCOLOURPICKER% THEN
2626     SYS "Wimp_CreateSubMenu",,wSubmenu%,x%,y%
2627     PROCwint_checksavewindow(wSubmenu%)
2628     IF wSubmenu%=wFONTMENU% THEN
2629         wFontmenudepth%=submenunumber%
2630         wReopened%=FALSE
2631     ELSE
2632         wFontmenudepth%=0
2633     ENDIF
2634 ENDIF
2635 ENDPROC
2636 :
2637 DEF FNwint_fontmenutree
2638 LOCAL Return%
2639 Return%=TRUE
2640 FOR N%=1 TO wFontmenudepth%
2641     IF wMenutree%(N%) <> !(wimp%+4*(N%-1)) THEN Return%=FALSE
2642 NEXT
2643 IF !(wimp%+4*(wFontmenudepth%))=-1 THEN Return%=FALSE
2644 IF wLastmenu%<>wHeldmenu% THEN Return%=FALSE
2645 =Return%
2646 :
2647 DEF FNwint_fontmenuused
2648 LOCAL Return%
2649 Return%=TRUE
2650 IF !(wimp%+4*(wFontmenudepth%))=-1 THEN Return%=FALSE
2651 =Return%
2652 :
2653 DEF FNwimp_initmessages(file$)
2654 LOCAL size%,buffer%,messages%,f%,flag%
2655 messages%=-1
2656 IF wMessagefilecount%=wMaxMessagefiles% THEN
2657     PROCwimp_error("","There are already "+STR$(wMaxMessagefiles%)+" Messages files initiated. You will need to increase the number allowed. (See Section 2.9 of Manual)",1,1)
2658 ELSE
2659     SYS "XMessageTrans_FileInfo",,file$ TO ,,size%;f%
2660     flag%=(f% AND 1)
2661     IF flag%=0 THEN
2662         DIM buffer% size%-1
2663         DIM messages% 255
2664         $(messages%+16)=file$
2665         SYS "MessageTrans_OpenFile",messages%,messages%+16,buffer%
2666         wMessagefilecount%+=1
2667         wMessagehandles%(wMessagefilecount%,0)=messages%
2668         wMessagehandles%(wMessagefilecount%,1)=buffer%
2669         wMessagehandles%(wMessagefilecount%,2)=size%
2670         IF wMessageout%=-1 THEN DIM wMessageout% 255
2671     ELSE
2672         PROCwimp_error("","Sorry, a file called "+file$+" cannot be found.",1,1)
2673         PROCwimp_closedown:END
2674     ENDIF
2675 ENDIF
2676 =messages%
2677 :
2678 DEF FNwimp_reinitmessages(messhandle%,newfile$)
2679 LOCAL oldsize%,newsize%,buffer%,count%,f%,flag%
2680 count%=0
2681 REPEAT
2682     count%+=1
2683 UNTIL messhandle%=wMessagehandles%(count%,0)
2684 buffer%=wMessagehandles%(count%,1)
2685 oldsize%=wMessagehandles%(count%,2)
2686 SYS "MessageTrans_CloseFile",messhandle%
2687 SYS "XMessageTrans_FileInfo",,newfile$ TO ,,newsize%;f%
2688 flag%=(f% AND 1)
2689 IF flag%=0 THEN
2690     IF newsize%>oldsize% THEN
2691         DIM buffer% newsize%-1
2692     ENDIF
2693     $(messhandle%+16)=newfile$
2694     SYS "MessageTrans_OpenFile",messhandle%,messhandle%+16,buffer%
2695     wMessagehandles%(count%,0)=messhandle%
2696     wMessagehandles%(count%,1)=buffer%
2697     IF newsize%>oldsize% THEN
2698         wMessagehandles%(count%,2)=newsize%
2699     ENDIF
2700 ELSE
2701     PROCwimp_error("","Sorry, a file called "+newfile$+" cannot be found.",1,1)
2702     PROCwimp_closedown:END
2703 ENDIF
2704 =messhandle%
2705 :
2706 DEF FNwimp_messlookup(messhandle%,token$,p1$,p2$)
2707 LOCAL type%,value$,f%
2708 IF p1$<>"" THEN
2709     type%+=1
2710     IF p2$<>"" THEN type%+=1
2711 ENDIF
2712 CASE type% OF
2713     WHEN 0 : SYS "XMessageTrans_Lookup",messhandle%,token$,wMessageout%,256,0,0,0,0 TO ,,value$ ;f%
2714     WHEN 1 : SYS "XMessageTrans_Lookup",messhandle%,token$,wMessageout%,256,p1$,0,0,0 TO ,,value$ ;f%
2715     WHEN 2 : SYS "XMessageTrans_Lookup",messhandle%,token$,wMessageout%,256,p1$,p2$,0,0 TO ,,value$ ;f%
2716 ENDCASE
2717 IF (f% AND 1)=1 THEN value$=""
2718 =value$
2719 :
2720 DEF PROCwint_closemessagefiles
2721 LOCAL N%
2722 IF wMessagefilecount%>0 THEN
2723     FOR N%=1 TO wMessagefilecount%
2724         SYS "MessageTrans_CloseFile",wMessagehandles%(N%,0)
2725     NEXT
2726 ENDIF
2727 ENDPROC
2728 :
2729 DEF FNwimp_countsprites(spritearea%)
2730 =!(spritearea%+4)
2731 :
2732 DEF FNwimp_loadsprites(spritefile$,address%,warning%)
2733 LOCAL filesize%
2734 filesize%=FNwimp_measurefile(spritefile$,warning%)
2735 IF filesize%>-1 THEN
2736     !address%=filesize%
2737     address%!8=16
2738     SYS "OS_SpriteOp",&10A,address%,spritefile$
2739 ELSE
2740     filesize%=0
2741 ENDIF
2742 =address%+filesize%
2743 :
2744 DEF PROCwimp_savesprites(savepath$,spritearea%)
2745 PROCwimp_hourglasson
2746 SYS "OS_SpriteOp",&10C,spritearea%,savepath$
2747 PROCwimp_hourglassoff
2748 ENDPROC
2749 :
2750 DEF FNwimp_getspritesize(spritename$,spritearea%,side%)
2751 LOCAL width%,height%,XEig%,YEig%,mode%,return%
2752 IF spritearea%=0 THEN
2753     SYS "Wimp_SpriteOp",40,spritearea%,spritename$ TO ,,,width%,height%,,mode%
2754 ELSE
2755     SYS "OS_SpriteOp",256+40,spritearea%,spritename$ TO ,,,width%,height%,,mode%
2756 ENDIF
2757 SYS "OS_ReadModeVariable",mode%,4 TO ,,XEig%
2758 SYS "OS_ReadModeVariable",mode%,5 TO ,,YEig%
2759 width%=width%*(2^XEig%):height%=height%*(2^YEig%)
2760 IF side%=0 THEN
2761     return%=width%
2762 ELSE
2763     return%=height%
2764 ENDIF
2765 =return%
2766 :
2767 DEF FNwimp_getspritename(spritearea%,spritenumber%)
2768 SYS "OS_SpriteOp",256+13,spritearea%,wimp%,256,spritenumber%
2769 =FNwint_string(wimp%)
2770 :
2771 DEF PROCwimp_rendersprite(spritename$,spritearea%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal)
2772 LOCAL width%,height%,XEig%,YEig%,in%,xmult,ymult,xdiv,ydiv,mode%
2773 xscalereal=ABS(xscalereal)
2774 yscalereal=ABS(yscalereal)
2775 IF xscalereal=0 THEN xscalereal=1
2776 IF yscalereal=0 THEN yscalereal=1
2777 IF spritearea%=0 THEN
2778     SYS "Wimp_SpriteOp",40,,spritename$ TO ,,,width%,height%,,mode%
2779 ELSE
2780     SYS "OS_SpriteOp",256+40,spritearea%,spritename$ TO ,,,width%,height%,,mode%
2781 ENDIF
2782 SYS "OS_ReadModeVariable",mode%,4 TO ,,XEig%
2783 SYS "OS_ReadModeVariable",mode%,5 TO ,,YEig%
2784 SYS "OS_ReadModeVariable",mode%,9 TO ,,BPP%
2785 width%=width%*(2^XEig%)
2786 height%=height%*(2^YEig%)
2787 xmult=1
2788 ymult=1
2789 xdiv=1
2790 ydiv=1
2791 PROCwint_scalefactors(xscalereal,yscalereal,xmult,ymult,xdiv,ydiv)
2792 IF BPP%>2 THEN
2793     IF spritearea%=0 THEN
2794         SYS "Wimp_ReadPixTrans",&100,1,spritename$,,,,wScale%,0
2795         SYS "ColourTrans_SelectTable",mode%,-1,-1,-1,wSprcoltrans%
2796     ELSE
2797         SYS "Wimp_ReadPixTrans",&100,spritearea%,spritename$,,,,wScale%,0
2798         SYS "ColourTrans_SelectTable",spritearea%,spritename$,-1,-1,wSprcoltrans%,2
2799     ENDIF
2800 ELSE
2801     IF spritearea%=0 THEN
2802         SYS "Wimp_ReadPixTrans",&100,1,spritename$,,,,wScale%,wSprcoltrans%
2803     ELSE
2804         SYS "Wimp_ReadPixTrans",&100,spritearea%,spritename$,,,,wScale%,wSprcoltrans%
2805     ENDIF
2806 ENDIF
2807 wScale%!0=wScale%!0*xmult
2808 wScale%!4=wScale%!4*ymult
2809 wScale%!8=wScale%!8*xdiv
2810 wScale%!12=wScale%!12*ydiv
2811 in%=FNwint_checkbounds(bx%,by%,bx%+(width%*wScale%!0/wScale%!8),by%+(height%*wScale%!4/wScale%!12),minx%,miny%,maxx%,maxy%)
2812 IF in%=1 THEN
2813     IF spritearea%=0 THEN
2814         SYS "Wimp_SpriteOp",52,,spritename$,bx%,by%,8,wScale%,wSprcoltrans%
2815     ELSE
2816         SYS "OS_SpriteOp",256+52,spritearea%,spritename$,bx%,by%,%1000,wScale%,wSprcoltrans%
2817     ENDIF
2818 ENDIF
2819 ENDPROC
2820 :
2821 DEF PROCwimp_renderwindowsprite(whan%,spritename$,spritearea%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal)
2822 IF wPrinting%=FALSE THEN
2823     bx%=FNwimp_worktoscreen(whan%,bx%,0)
2824     by%=FNwimp_worktoscreen(whan%,by%,1)
2825 ENDIF
2826 PROCwimp_rendersprite(spritename$,spritearea%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal)
2827 ENDPROC
2828 :
2829 DEF PROCwimp_pointer(pointer%,spritearea%,pointer$)
2830 LOCAL ptr$
2831 IF pointer%=0 THEN ptr$="ptr_default"
2832 IF pointer%=1 THEN ptr$=pointer$
2833 pointer%+=1
2834 IF spritearea%=0 THEN
2835     PROCwint_pointerRMA(ptr$,pointer%)
2836 ELSE
2837     SYS "OS_SpriteOp",256+36,spritearea%,ptr$,pointer%
2838 ENDIF
2839 ENDPROC
2840 :
2841 DEF FNwimp_getpointerposition(coord%)
2842 LOCAL x%,y%,b%,return%
2843 MOUSE x%,y%,b%
2844 IF coord%=0 THEN
2845     return%=x%
2846 ELSE
2847     return%=y%
2848 ENDIF
2849 =return%
2850 :
2851 DEF PROCwimp_setpointerposition(x%,y%)
2852 wMouseblk%?0=3
2853 wMouseblk%?1=x% MOD 256:wMouseblk%?2=x% DIV 256
2854 wMouseblk%?3=y% MOD 256:wMouseblk%?4=y% DIV 256
2855 SYS "OS_Word",21,wMouseblk%
2856 ENDPROC
2857 :
2858 DEF PROCwimp_bindpointer(whan%)
2859 LOCAL v%
2860 wMouseblk%?0=1
2861 v%=FNwimp_getwindowvisiblescreen(whan%,0,0)
2862 wMouseblk%?1=v% MOD 256:wMouseblk%?2=v% DIV 256
2863 v%=FNwimp_getwindowvisiblescreen(whan%,1,0)
2864 wMouseblk%?3=v% MOD 256:wMouseblk%?4=v% DIV 256
2865 v%=FNwimp_getwindowvisiblescreen(whan%,0,1)
2866 wMouseblk%?5=v% MOD 256:wMouseblk%?6=v% DIV 256
2867 v%=FNwimp_getwindowvisiblescreen(whan%,1,1)
2868 wMouseblk%?7=v% MOD 256:wMouseblk%?8=v% DIV 256
2869 SYS "OS_Word",21,wMouseblk%
2870 ENDPROC
2871 :
2872 DEF PROCwimp_releasepointer
2873 wMouseblk%?0=1
2874 wMouseblk%?1=0 MOD 256:wMouseblk%?2=0 DIV 256
2875 wMouseblk%?3=0 MOD 256:wMouseblk%?4=0 DIV 256
2876 wMouseblk%?5=FNwimp_getscreensize(0) MOD 256
2877 wMouseblk%?6=FNwimp_getscreensize(0) DIV 256
2878 wMouseblk%?7=FNwimp_getscreensize(1) MOD 256
2879 wMouseblk%?8=FNwimp_getscreensize(1) DIV 256
2880 SYS "OS_Word",21,wMouseblk%
2881 ENDPROC
2882 :
2883 DEF PROCwint_pointerRMA(ptr$,pointer%)
2884 SYS "Wimp_SpriteOp",36,,ptr$,pointer%
2885 ENDPROC
2886 :
2887 DEF PROCwimp_initdfiles
2888 DIM wDcapjoin% 15
2889 DIM wDfn%(255),wDf$(255)
2890 ENDPROC
2891 :
2892 DEF FNwimp_getdfilesize(dfile%,side%)
2893 LOCAL realdfile%,return%
2894 LOCAL xlow%,ylow%,xhigh%,yhigh%,x1%,y1%,x2%,y2%
2895 realdfile%=dfile%+4
2896 return%=0
2897 xlow%=realdfile%!24
2898 ylow%=realdfile%!28
2899 xhigh%=realdfile%!32
2900 yhigh%=realdfile%!36
2901 SYS "Font_ConverttoOS",,xlow%*72000/46080,ylow%*72000/46080 TO ,x1%,y1%
2902 SYS "Font_ConverttoOS",,xhigh%*72000/46080,yhigh%*72000/46080 TO ,x2%,y2%
2903 IF side%=0 THEN
2904     return%=x2%-x1%
2905 ELSE
2906     return%=y2%-y1%
2907 ENDIF
2908 =return%
2909 :
2910 DEF FNwimp_loaddfile(dfilepath$,address%,warning%)
2911 =FNwimp_loadfile(dfilepath$,address%,warning%)
2912 :
2913 DEF PROCwimp_savedfile(path$,dfile%)
2914 PROCwimp_savefile(path$,dfile%,&AFF)
2915 ENDPROC
2916 :
2917 DEF PROCwimp_renderwindow(whan%,dfile%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal,origin%)
2918 IF wPrinting%=FALSE THEN
2919     bx%=FNwimp_worktoscreen(whan%,bx%,0)
2920     by%=FNwimp_worktoscreen(whan%,by%,1)
2921 ENDIF
2922 PROCwimp_render(dfile%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal,origin%)
2923 ENDPROC
2924 :
2925 DEF PROCwimp_render(dfile%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal,origin%)
2926 LOCAL dfilesize%,realdfile%
2927 dfilesize%=dfile%!0
2928 realdfile%=dfile%+4
2929 IF xscalereal=0 THEN xscalereal=1
2930 IF yscalereal=0 THEN yscalereal=1
2931 PROCwint_render360(realdfile%,dfilesize%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal,origin%)
2932 ENDPROC
2933 :
2934 DEF PROCwint_render360(realdfile%,dfilesize%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal,origin%)
2935 LOCAL xoffset%,yoffset%
2936 wDmatrix%!0=&10000*xscalereal
2937 wDmatrix%!4=0
2938 wDmatrix%!8=0
2939 wDmatrix%!12=&10000*yscalereal
2940 wDmatrix%!16=0
2941 wDmatrix%!20=0
2942 SYS "DrawFile_BBox",,realdfile%,dfilesize%,wDmatrix%,wDbbox%
2943 xoffset%=wDbbox%!0/256
2944 yoffset%=wDbbox%!4/256
2945 IF origin%=1 THEN
2946     bx%-=xoffset%
2947     by%-=yoffset%
2948 ENDIF
2949 wDmatrix%!16=bx%*256
2950 wDmatrix%!20=by%*256
2951 SYS "DrawFile_Render",0,realdfile%,dfilesize%,wDmatrix%,0
2952 ENDPROC
2953 :
2954 DEF FNwint_checkbounds(xlow%,ylow%,xhigh%,yhigh%,xbl%,ybl%,xtr%,ytr%)
2955 return%=0
2956 CASE TRUE OF
2957     WHEN (xlow%<=xbl% AND xhigh%>=xtr% AND ylow%<=ybl% AND yhigh%>=ytr%)
2958     return%=1
2959     WHEN (xlow%>=xbl% AND xlow%<=xtr% AND ylow%>=ybl% AND ylow%<=ytr%)
2960     return%=1
2961     WHEN (xhigh%>=xbl% AND xhigh%<=xtr% AND ylow%>=ybl% AND ylow%<=ytr%)
2962     return%=1
2963     WHEN (xlow%>=xbl% AND xlow%<=xtr% AND yhigh%>=ybl% AND yhigh%<=ytr%)
2964     return%=1
2965     WHEN (xhigh%>=xbl% AND xhigh%<=xtr% AND yhigh%>=ybl% AND yhigh%<=ytr%)
2966     return%=1
2967     WHEN (xlow%>=xbl% AND xlow%<=xtr% AND ylow%<=ybl% AND yhigh%>=ytr%)
2968     return%=1
2969     WHEN (xhigh%>=xbl% AND xhigh%<=xtr% AND ylow%<=ybl% AND yhigh%>=ytr%)
2970     return%=1
2971     WHEN (ylow%>=ybl% AND ylow%<=ytr% AND xlow%<=xbl% AND xhigh%>=xtr%)
2972     return%=1
2973     WHEN (yhigh%>=ybl% AND yhigh%<=ytr% AND xlow%<=xbl% AND xhigh%>=xtr%)
2974     return%=1
2975     WHEN (xlow%>xbl% AND xhigh%<xtr% AND ylow%>ybl% AND yhigh%<ytr%)
2976     return%=1
2977 ENDCASE
2978 =return%
2979 :
2980 DEF FNwimp_gettextsize(text$,font$,pointsizex,pointsizey,side%,scalex,scaley)
2981 LOCAL fhan%,f%,return%
2982 return%=0
2983 IF text$<>"" THEN
2984     SYS "XFont_FindFont",,font$,pointsizex*16,pointsizey*16 TO fhan% ;f%
2985     IF (f% AND 1)=1 THEN
2986         return%=0
2987     ELSE
2988         return%=FNwimp_gettextsizeh(text$,fhan%,side%,scalex,scaley)
2989         SYS "Font_LoseFont",fhan%
2990     ENDIF
2991 ENDIF
2992 =return%
2993 :
2994 DEF FNwimp_gettextsizeh(text$,fhan%,side%,scalex,scaley)
2995 LOCAL plotcode%,minx%,miny%,maxx%,maxy%,return%
2996 return%=0
2997 IF text$<>"" AND fhan%>0 THEN
2998     wTransformtext%!0=scalex*65536
2999     wTransformtext%!4=0
3000     wTransformtext%!8=0
3001     wTransformtext%!12=scaley*65536
3002     wTransformtext%!16=0
3003     wTransformtext%!20=0
3004     wBBox%!0=0
3005     wBBox%!4=0
3006     wBBox%!8=0
3007     wBBox%!12=0
3008     wBBox%!16=-1
3009     SYS "Font_SetFont",fhan%
3010     plotcode%=( 1<<18 OR 1<<8 OR 1<<6 OR 1<<5 )
3011     SYS "Font_ScanString",0,text$,plotcode%,&7FFFFFFF,&7FFFFFFF,wBBox%,wTransformtext%
3012     minx%=wBBox%!20
3013     miny%=wBBox%!24
3014     maxx%=wBBox%!28
3015     maxy%=wBBox%!32
3016     SYS "Font_ConverttoOS",,minx%,miny% TO ,minx%,miny%
3017     SYS "Font_ConverttoOS",,maxx%,maxy% TO ,maxx%,maxy%
3018     CASE side% OF
3019         WHEN 0
3020         return%=maxx%-minx%
3021         WHEN 1
3022         return%=maxy%-miny%
3023     ENDCASE
3024 ENDIF
3025 =return%
3026 :
3027 DEF FNwimp_getfont(font$,pointsizex,pointsizey)
3028 LOCAL fhan%,f%,return%
3029 SYS "XFont_FindFont",,font$,pointsizex*16,pointsizey*16 TO fhan% ;f%
3030 IF (f% AND 1)=1 THEN
3031     return%=0
3032 ELSE
3033     return%=fhan%
3034     wFontbuf%?fhan%+=1
3035 ENDIF
3036 =return%
3037 :
3038 DEF PROCwimp_losefont(fhan%)
3039 SYS "Font_LoseFont",fhan%
3040 wFontbuf%?fhan%-=1
3041 ENDPROC
3042 :
3043 DEF FNwimp_fontcolour(fr%,fg%,fb%,br%,bg%,bb%)
3044 =CHR$(19)+CHR$(br%)+CHR$(bg%)+CHR$(bb%)+CHR$(fr%)+CHR$(fg%)+CHR$(fb%)+CHR$(14)
3045 :
3046 DEF FNwimp_fontunderline(on%)
3047 LOCAL return$
3048 return$=""
3049 IF on%=0 THEN
3050     return$=CHR$25+CHR$0+CHR$0
3051 ELSE
3052     return$=CHR$25+CHR$240+CHR$10
3053 ENDIF
3054 =return$
3055 :
3056 DEF FNwimp_fontchangeh(fhan%)
3057 =CHR$26+CHR$fhan%
3058 :
3059 DEF PROCwimp_plotwindowtext(whan%,text$,font$,pointsizex,pointsizey,align%,x%,y%,fr%,fg%,fb%,br%,bg%,bb%,minx%,miny%,maxx%,maxy%,scalex,scaley,blending%)
3060 LOCAL h%,in%,fhan%,f%,width%
3061 IF wPrinting%=FALSE THEN
3062     x%=FNwimp_worktoscreen(whan%,x%,0)
3063     y%=FNwimp_worktoscreen(whan%,y%,1)
3064 ENDIF
3065 SYS "XFont_FindFont",,font$,pointsizex*16,pointsizey*16 TO fhan% ;f%
3066 IF (f% AND 1)=1 THEN
3067     SYS "Font_FindFont",,"Trinity.Medium",pointsizex*16,pointsizey*16,0,0 TO fhan%
3068 ENDIF
3069 h%=FNwimp_gettextsizeh(text$,fhan%,1,scalex,scaley)
3070 CASE align% OF
3071     WHEN 1
3072     width%=FNwimp_gettextsizeh(text$,fhan%,0,scalex,scaley)
3073     x%=x%-(width%/2)
3074     WHEN 2
3075     width%=FNwimp_gettextsizeh(text$,fhan%,0,scalex,scaley)
3076     x%=x%-width%
3077 ENDCASE
3078 in%=FNwint_checkbounds(x%,y%-0.25*h%,1E6,y%+h%,minx%,miny%,maxx%,maxy%)
3079 IF in%=1 THEN
3080     PROCwimp_plottexth(text$,fhan%,0,x%,y%,fr%,fg%,fb%,br%,bg%,bb%,scalex,scaley,blending%)
3081 ENDIF
3082 SYS "Font_LoseFont",fhan%
3083 ENDPROC
3084 :
3085 DEF PROCwimp_plotwindowtexth(whan%,text$,fhan%,align%,x%,y%,fr%,fg%,fb%,br%,bg%,bb%,minx%,miny%,maxx%,maxy%,scalex,scaley,blending%)
3086 LOCAL h%,in%,width%
3087 IF wPrinting%=FALSE THEN
3088     x%=FNwimp_worktoscreen(whan%,x%,0)
3089     y%=FNwimp_worktoscreen(whan%,y%,1)
3090 ENDIF
3091 h%=FNwimp_gettextsizeh(text$,fhan%,1,scalex,scaley)
3092 CASE align% OF
3093     WHEN 1
3094     width%=FNwimp_gettextsizeh(text$,fhan%,0,scalex,scaley)
3095     x%=x%-(width%/2)
3096     WHEN 2
3097     width%=FNwimp_gettextsizeh(text$,fhan%,0,scalex,scaley)
3098     x%=x%-width%
3099 ENDCASE
3100 in%=FNwint_checkbounds(x%,y%-0.25*h%,1E6,y%+h%,minx%,miny%,maxx%,maxy%)
3101 IF in%=1 THEN
3102     PROCwimp_plottexth(text$,fhan%,0,x%,y%,fr%,fg%,fb%,br%,bg%,bb%,scalex,scaley,blending%)
3103 ENDIF
3104 ENDPROC
3105 :
3106 DEF PROCwimp_plottext(text$,font$,pointsizex,pointsizey,align%,x%,y%,fr%,fg%,fb%,br%,bg%,bb%,scalex,scaley,blending%)
3107 LOCAL fhan%,f%,width%
3108 SYS "XFont_FindFont",,font$,pointsizex*16,pointsizey*16 TO fhan% ;f%
3109 IF (f% AND 1)=1 THEN
3110     SYS "Font_FindFont",,"Trinity.Medium",pointsizex*16,pointsizey*16,0,0 TO fhan%
3111 ENDIF
3112 CASE align% OF
3113     WHEN 1
3114     width%=FNwimp_gettextsizeh(text$,fhan%,0,scalex,scaley)
3115     x%=x%-(width%/2)
3116     WHEN 2
3117     width%=FNwimp_gettextsizeh(text$,fhan%,0,scalex,scaley)
3118     x%=x%-width%
3119 ENDCASE
3120 PROCwimp_plottexth(text$,fhan%,0,x%,y%,fr%,fg%,fb%,br%,bg%,bb%,scalex,scaley,blending%)
3121 SYS "Font_LoseFont",fhan%
3122 ENDPROC
3123 :
3124 DEF PROCwimp_plottexth(text$,fhan%,align%,x%,y%,fr%,fg%,fb%,br%,bg%,bb%,scalex,scaley,blending%)
3125 LOCAL width%
3126 CASE align% OF
3127     WHEN 1
3128     width%=FNwimp_gettextsizeh(text$,fhan%,0,scalex,scaley)
3129     x%=x%-(width%/2)
3130     WHEN 2
3131     width%=FNwimp_gettextsizeh(text$,fhan%,0,scalex,scaley)
3132     x%=x%-width%
3133 ENDCASE
3134 SYS "ColourTrans_SetFontColours",fhan%,(bb%<<24)+(bg%<<16)+(br%<<8),(fb%<<24)+(fg%<<16)+(fr%<<8),14
3135 wTransformtext%!0=scalex*65536
3136 wTransformtext%!4=0
3137 wTransformtext%!8=0
3138 wTransformtext%!12=scaley*65536
3139 wTransformtext%!16=0
3140 wTransformtext%!20=0
3141 SYS "Font_Converttopoints",,x%,y% TO ,x%,y%
3142 SYS "Font_CacheAddr" TO fontmanager%
3143 IF (fontmanager% < 335) OR (blending%=0) THEN
3144     plottype%=(1<<6)+(1<<9)
3145 ELSE
3146     plottype%=(1<<6)+(1<<9)+(1<<11)
3147 ENDIF
3148 SYS "Font_Paint",fhan%,text$,plottype%,x%,y%,,wTransformtext%
3149 ENDPROC
3150 :
3151 DEF PROCwimp_deskplotwindowtext(whan%,text$,align%,x%,y%,fr%,fg%,fb%,br%,bg%,bb%,minx%,miny%,maxx%,maxy%)
3152 LOCAL in%
3153 IF wPrinting%=FALSE THEN
3154     x%=FNwimp_worktoscreen(whan%,x%,0)
3155     y%=FNwimp_worktoscreen(whan%,y%,1)
3156 ENDIF
3157 in%=FNwint_checkbounds(x%,y%,1E6,y%+30,minx%,miny%,maxx%,maxy%)
3158 IF in%=1 THEN
3159     PROCwimp_deskplottext(text$,align%,x%,y%,fr%,fg%,fb%,br%,bg%,bb%)
3160 ENDIF
3161 ENDPROC
3162 :
3163 DEF PROCwimp_deskplottext(text$,align%,x%,y%,fr%,fg%,fb%,br%,bg%,bb%)
3164 LOCAL fore%,back%,width%
3165 fore%=(fr%<<8)+(fg%<<16)+(fb%<<24)
3166 back%=(br%<<8)+(bg%<<16)+(bb%<<24)
3167 SYS "Wimp_TextOp",0,fore%,back%
3168 CASE align% OF
3169     WHEN 1
3170     SYS "Wimp_TextOp",1,text$,0 TO width%
3171     SYS "Wimp_TextOp",2,text$,,,x%-(width%/2),y%
3172     WHEN 2
3173     SYS "Wimp_TextOp",2+(1<<31),text$,,,x%,y%
3174     OTHERWISE
3175     SYS "Wimp_TextOp",2,text$,,,x%,y%
3176 ENDCASE
3177 ENDPROC
3178 :
3179 DEF PROCwimp_print(user%,whan%,firstpage%,lastpage%,perpage%,copies%,orient%)
3180 LOCAL file$,width%,height%,OSwidth%,OSheight%,olastpage%
3181 LOCAL anglereal,scalereal,p%,step%
3182 LOCAL wprnt%,prevprnt%,feat%,fontdec%
3183 LOCAL cancel%,copy%,page%,totpages%,pagepos%,L%
3184 LOCAL w%,h%
3185 LOCAL more%,cpage%
3186 IF firstpage%<1 THEN firstpage%=1
3187 IF perpage%<1 THEN perpage%=1
3188 IF perpage%>4 THEN perpage%=4
3189 IF perpage%=3 THEN perpage%=2
3190 IF copies%<1 THEN copies%=1
3191 PROCwimp_singlepoll
3192 LOCAL ERROR
3193 ON ERROR LOCAL:RESTORE ERROR:PROCwint_printerror(wprnt%,REPORT$,ERL):ENDPROC
3194 file$="printer:"
3195 SYS "PDriver_PageSize" TO ,width%,height%
3196 SYS "Font_ConverttoOS",,width%,height% TO ,OSwidth%,OSheight%
3197 olastpage%=lastpage%
3198 IF perpage%=4 THEN
3199     IF orient%=0 THEN
3200         anglereal=0
3201     ELSE
3202         anglereal=90
3203     ENDIF
3204     scalereal=50
3205     p%=(lastpage%-firstpage%+1) MOD 4
3206     IF p%<>0 THEN lastpage%+=4-p%
3207     step%=4
3208 ENDIF
3209 IF perpage%=2 THEN
3210     IF orient%=0 THEN
3211         anglereal=90
3212     ELSE
3213         anglereal=0
3214     ENDIF
3215     scalereal=FNwimp_getpapersize(0,0)/FNwimp_getpapersize(1,0)
3216     IF ((firstpage%-lastpage%+1) MOD 2)<>0 THEN lastpage%+=1
3217     step%=2
3218 ENDIF
3219 IF perpage%=1 THEN
3220     IF orient%=0 THEN
3221         anglereal=0
3222     ELSE
3223         anglereal=90
3224     ENDIF
3225     scalereal=1
3226     step%=1
3227 ENDIF
3228 wprnt%=OPENOUT(file$)
3229 SYS "PDriver_SelectJob",wprnt% TO prevprnt%
3230 SYS "PDriver_Info" TO ,,,feat%
3231 fontdec%=(feat%>>29 AND 1)
3232 IF fontdec% THEN
3233     PROCuser_declarefonts
3234     SYS "PDriver_DeclareFont",0,0,0
3235 ENDIF
3236 cancel%=0
3237 FOR copy%=1 TO copies%
3238     FOR page%=firstpage% TO lastpage% STEP step%
3239         SYS "Hourglass_On"
3240         IF cancel%=0 THEN
3241             SYS "PDriver_SelectJob",prevprnt%
3242             wPrinting%=FALSE
3243             IF perpage%=1 THEN
3244                 totpages%=(lastpage%-firstpage%+1)*copies%
3245                 pagepos%=page%+((copy%-1)*(lastpage%-firstpage%+1))-firstpage%+1
3246                 cancel%=FNuser_printing(copy%,page%,totpages%,pagepos%)
3247                 PROCwimp_singlepoll
3248             ELSE
3249                 FOR L%=1 TO perpage%
3250                     IF cancel%=0 THEN
3251                         IF page%+(L%-1)<=olastpage% THEN
3252                             totpages%=(olastpage%-firstpage%+1)*copies%
3253                             pagepos%=page%+(L%-1)+((copy%-1)*(olastpage%-firstpage%+1))-firstpage%+1
3254                             cancel%=FNuser_printing(copy%,page%,totpages%,pagepos%)
3255                             PROCwimp_singlepoll
3256                         ENDIF
3257                     ENDIF
3258                 NEXT L%
3259             ENDIF
3260             wPrinting%=TRUE
3261             SYS "PDriver_SelectJob",wprnt% TO prevprnt%
3262         ENDIF
3263         IF cancel%=0 THEN
3264             IF perpage%=1 THEN
3265                 wPrintblock%!16=(scalereal*(COSRADanglereal))*2^16
3266                 wPrintblock%!20=(scalereal*(SINRADanglereal))*2^16
3267                 wPrintblock%!24=(scalereal*(-SINRADanglereal))*2^16
3268                 wPrintblock%!28=(scalereal*(COSRADanglereal))*2^16
3269                 IF orient%=0 THEN
3270                     wPrintblock%!0=0
3271                     wPrintblock%!4=0
3272                     wPrintblock%!8=OSwidth%
3273                     wPrintblock%!12=OSheight%
3274                     wPrintblock%!32=0
3275                     wPrintblock%!36=0
3276                 ELSE
3277                     wPrintblock%!0=0
3278                     wPrintblock%!4=0
3279                     wPrintblock%!8=OSheight%
3280                     wPrintblock%!12=OSwidth%
3281                     wPrintblock%!32=width%
3282                     wPrintblock%!36=0
3283                 ENDIF
3284                 SYS "PDriver_GiveRectangle",page%,wPrintblock%,wPrintblock%+16,wPrintblock%+32,&FFFFFF00
3285             ENDIF
3286             IF perpage%=2 THEN
3287                 FOR L%=1 TO 2
3288                     IF page%+(L%-1)<=olastpage% THEN
3289                         wPrintblock%!16=(scalereal*(COSRADanglereal))*2^16
3290                         wPrintblock%!20=(scalereal*(SINRADanglereal))*2^16
3291                         wPrintblock%!24=(scalereal*(-SINRADanglereal))*2^16
3292                         wPrintblock%!28=(scalereal*(COSRADanglereal))*2^16
3293                         w%=width%-(width%-(height%*scalereal))
3294                         IF orient%=0 THEN
3295                             wPrintblock%!0=0
3296                             wPrintblock%!4=0
3297                             wPrintblock%!8=OSwidth%
3298                             wPrintblock%!12=OSheight%
3299                             IF L%=1 THEN wPrintblock%!32=w%:wPrintblock%!36=0
3300                             IF L%=2 THEN h%=height%/2:wPrintblock%!32=w%:wPrintblock%!36=h%
3301                         ELSE
3302                             wPrintblock%!0=0
3303                             wPrintblock%!4=0
3304                             wPrintblock%!8=OSheight%
3305                             wPrintblock%!12=OSwidth%
3306                             IF L%=1 THEN wPrintblock%!32=0:wPrintblock%!36=0
3307                             IF L%=2 THEN h%=height%/2:wPrintblock%!32=0:wPrintblock%!36=h%
3308                         ENDIF
3309                         SYS "PDriver_GiveRectangle",page%+(L%-1),wPrintblock%,wPrintblock%+16,wPrintblock%+32,&FFFFFF00
3310                     ENDIF
3311                 NEXT L%
3312             ENDIF
3313             IF perpage%=4 THEN
3314                 FOR L%=1 TO 4
3315                     IF page%+(L%-1)<=olastpage% THEN
3316                         IF orient%=0 THEN
3317                             wPrintblock%!0=0
3318                             wPrintblock%!4=0
3319                             wPrintblock%!8=OSwidth%
3320                             wPrintblock%!12=OSheight%
3321                             wPrintblock%!16=2^15
3322                             wPrintblock%!20=0
3323                             wPrintblock%!24=0
3324                             wPrintblock%!28=2^15
3325                             IF L%=1 THEN wPrintblock%!32=0:wPrintblock%!36=height%/2
3326                             IF L%=2 THEN wPrintblock%!32=width%/2:wPrintblock%!36=height%/2
3327                             IF L%=3 THEN wPrintblock%!32=0:wPrintblock%!36=0
3328                             IF L%=4 THEN wPrintblock%!32=width%/2:wPrintblock%!36=0
3329                         ELSE
3330                             wPrintblock%!0=0
3331                             wPrintblock%!4=0
3332                             wPrintblock%!8=OSheight%
3333                             wPrintblock%!12=OSwidth%
3334                             wPrintblock%!16=(COSRADanglereal)*2^15
3335                             wPrintblock%!20=(SINRADanglereal)*2^15
3336                             wPrintblock%!24=(-SINRADanglereal)*2^15
3337                             wPrintblock%!28=(COSRADanglereal)*2^15
3338                             IF L%=1 THEN wPrintblock%!32=width%/2:wPrintblock%!36=height%/2
3339                             IF L%=2 THEN wPrintblock%!32=width%:wPrintblock%!36=height%/2
3340                             IF L%=3 THEN wPrintblock%!32=width%/2:wPrintblock%!36=0
3341                             IF L%=4 THEN wPrintblock%!32=width%:wPrintblock%!36=0
3342                         ENDIF
3343                         SYS "PDriver_GiveRectangle",page%+(L%-1),wPrintblock%,wPrintblock%+16,wPrintblock%+32,&FFFFFF00
3344                     ENDIF
3345                 NEXT L%
3346             ENDIF
3347             wPrinting%=TRUE
3348             SYS "PDriver_DrawPage",1,wPrintblock%,0,0 TO more%,,cpage%
3349             IF more%<>0 THEN
3350                 REPEAT
3351                     IF user%=1 THEN
3352                         PROCuser_print(wPrintblock%!0,wPrintblock%!4,wPrintblock%!8,wPrintblock%!12,cpage%)
3353                     ELSE
3354                         PROCuser_redraw(whan%,wPrintblock%!0,wPrintblock%!4,wPrintblock%!8,wPrintblock%!12,wPrinting%,cpage%)
3355                     ENDIF
3356                     SYS "PDriver_GetRectangle",,wPrintblock% TO more%,,cpage%
3357                 UNTIL more%=0
3358             ENDIF
3359         ENDIF
3360         SYS "Hourglass_Off"
3361     NEXT page%
3362 NEXT copy%
3363 wPrinting%=FALSE
3364 SYS "PDriver_EndJob",wprnt%
3365 CLOSE#wprnt%
3366 RESTORE ERROR
3367 SYS "PDriver_SelectJob",prevprnt%
3368 ENDPROC
3369 :
3370 DEF FNwimp_pdriverpresent
3371 LOCAL present%
3372 present%=TRUE
3373 IF FNwimp_getpdrivername="" THEN present%=FALSE
3374 =present%
3375 :
3376 DEF FNwimp_getpdrivername
3377 LOCAL name%
3378 LOCAL ERROR
3379 ON ERROR LOCAL =""
3380 SYS "PDriver_Info" TO ,,,,name%
3381 =FNwint_string(name%)
3382 :
3383 DEF FNwimp_worktopaper(coord%,side%,orient%)
3384 LOCAL w%,h%,offset%,return%
3385 IF side%=0 THEN
3386     return%=coord%
3387 ELSE
3388     w%=FNwimp_getpapersize(0,0)
3389     h%=FNwimp_getpapersize(1,0)
3390     IF orient%=0 THEN offset%=0 ELSE offset%=h%-w%
3391     return%=h%+coord%-offset%
3392 ENDIF
3393 =return%
3394 :
3395 DEF FNwimp_papertowork(coord%,side%,orient%)
3396 LOCAL w%,h%,offset%,return%
3397 IF side%=0 THEN
3398     return%=coord%
3399 ELSE
3400     w%=FNwimp_getpapersize(0,0)
3401     h%=FNwimp_getpapersize(1,0)
3402     IF orient%=0 THEN offset%=0 ELSE offset%=h%-w%
3403     return%= -(h%-coord%)+offset%
3404 ENDIF
3405 =return%
3406 :
3407 DEF FNwimp_screentopaper(whan%,coord%,side%,orient%)
3408 coord%=FNwimp_screentowork(whan%,coord%,side%)
3409 =FNwimp_worktopaper(coord%,side%,orient%)
3410 :
3411 DEF FNwimp_papertoscreen(whan%,coord%,side%,orient%)
3412 coord%=FNwimp_papertowork(coord%,side%,orient%)
3413 =FNwimp_worktoscreen(whan%,coord%,side%)
3414 :
3415 DEF FNwimp_getpapersize(side%,type%)
3416 LOCAL left%,bottom%,right%,top%,width%,height%,val%
3417 LOCAL OSleft%,OSbottom%,OSright%,OStop%,OSwidth%,OSheight%
3418 SYS "PDriver_PageSize" TO ,width%,height%,left%,bottom%,right%,top%
3419 SYS "Font_ConverttoOS",,left%,bottom% TO ,OSleft%,OSbottom%
3420 SYS "Font_ConverttoOS",,right%,top% TO ,OSright%,OStop%
3421 SYS "Font_ConverttoOS",,width%,height% TO ,OSwidth%,OSheight%
3422 val%=0
3423 IF side%=0 THEN
3424     IF type%=0 THEN val%=OSwidth%
3425     IF type%=1 THEN val%=OSleft%
3426     IF type%=2 THEN val%=OSright%-OSleft%
3427     IF type%=3 THEN val%=OSright%
3428 ELSE
3429     IF type%=0 THEN val%=OSheight%
3430     IF type%=1 THEN val%=OSbottom%
3431     IF type%=2 THEN val%=OStop%-OSbottom%
3432     IF type%=3 THEN val%=OStop%
3433 ENDIF
3434 =val%
3435 :
3436 DEF PROCwimp_declarefont(font$)
3437 SYS "PDriver_DeclareFont",0,font$,0
3438 ENDPROC
3439 :
3440 DEF PROCwimp_declarefonth(fhan%)
3441 SYS "PDriver_DeclareFont",fhan%,,0
3442 ENDPROC
3443 :
3444 DEF PROCwimp_declaredfilefonts(dfile%)
3445 LOCAL top%,len%,obj%,ptr%,font$,c%,OBJDONE%
3446 realdfile%=dfile%+4
3447 fileend%=realdfile%+dfile%!0
3448 SYS "DrawFile_DeclareFonts",,realdfile%,dfile%!0
3449 ENDPROC
3450 :
3451 DEF PROCwint_printerror(wprnt%,e$,l%)
3452 wPrinting%=FALSE
3453 SYS "XPDriver_AbortJob",wprnt%
3454 CLOSE#wprnt%
3455 SYS "Hourglass_Off"
3456 IF l%=0 THEN
3457     PROCwimp_error("",e$+" when trying to print.",1,1)
3458 ELSE
3459     PROCwimp_error("",e$+" at line "+STR$l%+" when trying to print.",1,1)
3460 ENDIF
3461 ENDPROC
3462 :
3463 DEF FNwimp_createdynamic(size%,maxsize%,drag%,name$)
3464 LOCAL dnum%,darea%
3465 darea%=0
3466 IF wDynamics%<wMaxdynamicareas% THEN
3467     IF drag%<>0 THEN drag%=1
3468     IF maxsize%<-1 THEN maxsize%=-1
3469     IF (maxsize%>-1) AND (maxsize%<size%) THEN maxsize%=size%
3470     $wTempblk%=name$
3471     SYS "XOS_DynamicArea",0,-1,size%,-1,%000110000+((1-drag%)<<7),maxsize%,0,0,wTempblk% TO ,dnum%,,darea%
3472     wDynamics%+=1
3473     wDynamicarea%(wDynamics%,0)=darea%
3474     wDynamicarea%(wDynamics%,1)=dnum%
3475 ELSE
3476     PROCwimp_error("","Sorry but, with this version of Dr Wimp, a maximum of "+STR$(wMaxdynamicareas%)+" Dynamic areas created with this wimp-function can exist. See Manual Section 2.27 for solution.",1,1)
3477 ENDIF
3478 =darea%
3479 :
3480 DEF FNwimp_changedynamic(darea%,absolute%,size%)
3481 LOCAL f%,csize%,L%,dnum%,pos%,exists%,return%
3482 IF absolute%<>0 THEN absolute%=1
3483 exists%=FALSE
3484 FOR L%=1 TO wDynamics%
3485     IF wDynamicarea%(L%,0)=darea% THEN
3486         dnum%=wDynamicarea%(L%,1)
3487         pos%=L%
3488         exists%=TRUE
3489     ENDIF
3490 NEXT L%
3491 IF exists%=TRUE AND darea%<>0 THEN
3492     f%=0
3493     IF absolute%=1 THEN
3494         csize%=FNwimp_measuredynamic(darea%)
3495         size%-=csize%
3496     ENDIF
3497     SYS "XOS_ChangeDynamicArea",dnum%,size% TO ;f%
3498     IF (f% AND 1)=1 THEN
3499         PROCwint_cleardynamicareas
3500         PROCwimp_error("","Can't change that area by required amount.",1,1):PROCwimp_closedown:END
3501     ELSE
3502         wDynamicarea%(pos%,0)=darea%
3503         return%=darea%
3504     ENDIF
3505 ELSE
3506     PROCwint_cleardynamicareas
3507     PROCwimp_error("","Can't find existing Dynamic area with that handle.",1,1):PROCwimp_closedown:END
3508 ENDIF
3509 =return%
3510 :
3511 DEF FNwimp_measuredynamic(darea%)
3512 LOCAL exists%,L%,dasize%,pos%,dnum%,csize%,maxsize%
3513 pos%=0
3514 dasize%=0
3515 exists%=FALSE
3516 FOR L%=1 TO wDynamics%
3517     IF wDynamicarea%(L%,0)=darea% THEN
3518         dnum%=wDynamicarea%(L%,1)
3519         pos%=L%
3520         exists%=TRUE
3521     ENDIF
3522 NEXT L%
3523 IF exists%=TRUE AND darea%<>0 THEN
3524     dnum%=wDynamicarea%(pos%,1)
3525     SYS "OS_DynamicArea",2,dnum% TO ,,dasize%
3526 ELSE
3527     PROCwint_cleardynamicareas
3528     PROCwimp_error("","Can't find existing Dynamic area with that handle.",1,1):PROCwimp_closedown:END
3529 ENDIF
3530 =dasize%
3531 :
3532 DEF PROCwimp_deletedynamic(darea%)
3533 LOCAL L%,dnum%,exists%,pos%
3534 exists%=FALSE
3535 pos%=-1
3536 FOR L%=1 TO wDynamics%
3537     IF wDynamicarea%(L%,0)=darea% THEN
3538         dnum%=wDynamicarea%(L%,1)
3539         exists%=TRUE
3540         pos%=L%
3541     ENDIF
3542 NEXT L%
3543 IF exists%=TRUE AND darea%<>0 THEN
3544     SYS "OS_DynamicArea",1,dnum%
3545     IF pos%<wDynamics% THEN
3546         FOR L%=pos% TO wDynamics%
3547             wDynamicarea%(L%,0)=wDynamicarea%(L%+1,0)
3548             wDynamicarea%(L%,1)=wDynamicarea%(L%+1,1)
3549         NEXT
3550     ENDIF
3551     wDynamicarea%(wDynamics%,0)=0
3552     wDynamicarea%(wDynamics%,1)=0
3553     wDynamics%-=1
3554 ENDIF
3555 ENDPROC
3556 :
3557 DEF PROCwint_cleardynamicareas
3558 LOCAL L%
3559 IF wDynamics%>0 THEN
3560     FOR L%=wDynamics% TO 1 STEP -1
3561         IF wDynamicarea%(L%,0)>0 THEN PROCwimp_deletedynamic(wDynamicarea%(L%,0))
3562     NEXT
3563 ENDIF
3564 ENDPROC
3565 :
3566 DEF PROCwimp_opencolourpickermodel(model%,dialoguetype%,value1,value2,value3,value4,none%,x%,y%)
3567 IF wColourblock%=-1 THEN DIM wColourblock% 255
3568 IF dialoguetype% <> 0 THEN dialoguetype%=1
3569 IF model%<0 THEN model%=0
3570 model%=(model% MOD 3)
3571 PROCwint_setcolourblockreservedvalues
3572 IF none%<1 THEN wColourblock%!0-=%1
3573 IF none%>1 THEN wColourblock%!0+=%10
3574 wColourblock%!8=x%
3575 wColourblock%!20=y%
3576 wColourblock%!40=model%
3577 PROCwint_initialcolourconvert(model%,value1,value2,value3,value4)
3578 SYS "ColourPicker_OpenDialogue",dialoguetype%,wColourblock% TO wPickerhandle%,wPickerwindow%
3579 ENDPROC
3580 :
3581 DEF PROCwimp_opencolourpickerrgb(dialoguetype%,red%,green%,blue%,none%,x%,y%)
3582 IF wColourblock%=-1 THEN DIM wColourblock% 255
3583 IF dialoguetype% <> 0 THEN dialoguetype%=1
3584 PROCwint_setcolourblockreservedvalues
3585 IF none%<1 THEN wColourblock%!0-=%1
3586 IF none%>1 THEN wColourblock%!0+=%10
3587 wColourblock%!8=x%
3588 wColourblock%!20=y%
3589 wColourblock%!40=0
3590 wColourblock%?(32+1)=red%
3591 wColourblock%?(32+2)=green%
3592 wColourblock%?(32+3)=blue%
3593 SYS "ColourPicker_OpenDialogue",dialoguetype%,wColourblock% TO wPickerhandle%,wPickerwindow%
3594 ENDPROC
3595 :
3596 DEF PROCwimp_opensubmenucolourpickermodel(model%,value1,value2,value3,value4,none%,x%,y%)
3597 IF wColourblock%=-1 THEN DIM wColourblock% 255
3598 IF model%<0 THEN model%=0
3599 model%=(model% MOD 3)
3600 PROCwint_setcolourblockreservedvalues
3601 IF none%<1 THEN wColourblock%!0-=%1
3602 IF none%>1 THEN wColourblock%!0+=%10
3603 wColourblock%!8=x%
3604 wColourblock%!20=y%
3605 wColourblock%!40=model%
3606 PROCwint_initialcolourconvert(model%,value1,value2,value3,value4)
3607 SYS "ColourPicker_OpenDialogue",3,wColourblock% TO wPickerhandle%,wPickerwindow%
3608 ENDPROC
3609 :
3610 DEF PROCwimp_opensubmenucolourpickerrgb(red%,green%,blue%,none%,x%,y%)
3611 IF wColourblock%=-1 THEN DIM wColourblock% 255
3612 PROCwint_setcolourblockreservedvalues
3613 IF none%<1 THEN wColourblock%!0-=%1
3614 IF none%>1 THEN wColourblock%!0+=%10
3615 wColourblock%!8=x%
3616 wColourblock%!20=y%
3617 wColourblock%!40=0
3618 wColourblock%?(32+1)=red%
3619 wColourblock%?(32+2)=green%
3620 wColourblock%?(32+3)=blue%
3621 SYS "ColourPicker_OpenDialogue",3,wColourblock% TO wPickerhandle%,wPickerwindow%
3622 ENDPROC
3623 :
3624 DEF PROCwint_setcolourblockreservedvalues
3625 wColourblock%!0=%10001
3626 wColourblock%!4=0
3627 wColourblock%!12=&80000000
3628 wColourblock%!16=&7FFFFFFF
3629 wColourblock%!24=0
3630 wColourblock%!28=0
3631 wColourblock%?(32+0)=0
3632 wColourblock%?(32+4)=20
3633 ENDPROC
3634 :
3635 DEF PROCwint_initialcolourconvert(model%,value1,value2,value3,value4)
3636 CASE model% OF
3637     WHEN 0
3638     wColourblock%?(32+1)=value1*255/100
3639     wColourblock%?(32+2)=value2*255/100
3640     wColourblock%?(32+3)=value3*255/100
3641     WHEN 1
3642     SYS "ColourTrans_ConvertCMYKToRGB",(value1/100)*2^16,(value2/100)*2^16,(value3/100)*2^16,(value4/100)*2^16 TO red%,green%,blue%
3643     wColourblock%?(32+1)=255*(red%/&10000)
3644     wColourblock%?(32+2)=255*(green%/&10000)
3645     wColourblock%?(32+3)=255*(blue%/&10000)
3646     WHEN 2
3647     SYS "ColourTrans_ConvertHSVToRGB",((value1 MOD 360) << 16) OR &FFFF,(value2/100)+&FFFF,(value3/100)+&FFFF TO red%,green%,blue%
3648     wColourblock%?(32+1)=255*(red%/&10000)
3649     wColourblock%?(32+2)=255*(green%/&10000)
3650     wColourblock%?(32+3)=255*(blue%/&10000)
3651 ENDCASE
3652 ENDPROC
3653 :
3654 DEF PROCwint_colourpickerchoice(model%)
3655 LOCAL none%,returnvalue1,returnvalue2,returnvalue3,returnvalue4
3656 none%=wimp%!24 AND 1
3657 returnvalue4=-1
3658 PROCuser_colourpickerrgb(wimp%?29,wimp%?30,wimp%?31,none%)
3659 returnvalue2=(wimp%!44/&10000)*100
3660 returnvalue3=(wimp%!48/&10000)*100
3661 CASE model% OF
3662     WHEN 0
3663     returnvalue1=(wimp%!40/&10000)*100
3664     returnvalue4=-1
3665     WHEN 1
3666     returnvalue1=(wimp%!40/&10000)*100
3667     returnvalue4=(wimp%!52/&10000)*100
3668     WHEN 2
3669     returnvalue1=(wimp%!40 >> 16)
3670     returnvalue4=-1
3671 ENDCASE
3672 PROCuser_colourpickermodel(model%,returnvalue1,returnvalue2,returnvalue3,returnvalue4,none%)
3673 ENDPROC
3674 :
3675 DEF PROCwint_closecolourpicker(handle%)
3676 SYS "ColourPicker_CloseDialogue",0,handle%
3677 ENDPROC
3678 :
3679 DEF PROCwimp_savefile(savepath$,handle%,ftype%)
3680 LOCAL realsize%,realfile%,file%,bnt%
3681 realsize%=handle%!0
3682 realfile%=handle%+4
3683 PROCwimp_hourglasson
3684 SYS "OS_Find",&8F,savepath$ TO file%
3685 SYS "OS_GBPB",2,file%,realfile%,realsize% TO ,,,bnt%
3686 SYS "OS_Find",0,file%
3687 PROCwimp_hourglassoff
3688 IF bnt%<>0 THEN
3689     PROCwimp_error("","Unknown error whilst saving; the file has not been saved correctly.",1,1)
3690 ELSE
3691     SYS "OS_File",18,savepath$,ftype%
3692 ENDIF
3693 ENDPROC
3694 :
3695 DEF PROCwint_receivedmess2(desttask%,inref%,destwhan%,destic%,destx%,desty%,ptr44%)
3696 LOCAL path$,Q%,drag%,write%,ok%,hextype%
3697 path$=FNwint_string(ptr44%)
3698 IF wToPrinter%=0 THEN
3699     drag%=0:write%=1:ok%=2
3700     PROCuser_saveicon(wSavew%,drag%,write%,ok%)
3701     PROCwimp_hourglasson
3702     Q%=FNuser_savedata(path$,wSavew%)
3703     PROCwimp_hourglassoff
3704 ELSE
3705     IF wDeleteFile%=0 THEN
3706         SYS "OS_FSControl",26,wPrintFile$,path$,0
3707     ELSE
3708         SYS "OS_FSControl",26,wPrintFile$,path$,128
3709     ENDIF
3710     hextype%=wPrintFileType%
3711     Q%=1
3712 ENDIF
3713 IF Q%=2 THEN
3714     PROCwimp_error("",REPORT$+" at line "+STR$(ERL)+" when trying to save.",1,0)
3715 ELSE
3716     IF Q%<>0 THEN
3717         IF wToPrinter%=0 THEN
3718             SYS "OS_ReadUnsigned",10,"&"+wsavet$ TO ,,hextype%
3719             SYS "OS_File",18,path$,hextype%
3720         ENDIF
3721         wimp%!0=256
3722         wimp%!12=inref%
3723         wimp%!16=3
3724         wimp%!20=destwhan%
3725         wimp%!24=destic%
3726         wimp%!28=destx%
3727         wimp%!32=desty%
3728         wimp%!36=-1
3729         wimp%!40=hextype%
3730         PROCwint_zeroterminate(wimp%+44,path$)
3731         SYS "Wimp_SendMessage",18,wimp%,desttask%
3732         IF wToPrinter%=0 THEN
3733             IF path$<>"<Wimp$Scrap>" THEN PROCwimp_puticontext(wSavew%,write%,path$)
3734         ENDIF
3735     ENDIF
3736 ENDIF
3737 ENDPROC
3738 :
3739 DEF PROCwint_quicksave(whan%,writeicon%)
3740 LOCAL path$,Q%,type$
3741 type$=FNuser_savefiletype(whan%)
3742 IF LEN(type$)<4 THEN
3743     path$=FNwimp_geticontext(whan%,writeicon%)
3744     IF (INSTR(path$,".")>0) OR (INSTR(path$,":")>0) THEN
3745         PROCwimp_hourglasson
3746         Q%=FNuser_savedata(path$,whan%)
3747         PROCwimp_hourglassoff
3748         IF Q%=2 THEN
3749             PROCwimp_error("",REPORT$+" at line "+STR$(ERL)+" when trying to save.",1,0)
3750         ELSE
3751             IF Q%<>0 THEN
3752                 SYS "OS_ReadUnsigned",10,"&"+type$ TO ,,hextype%
3753                 SYS "OS_File",18,path$,hextype%
3754             ENDIF
3755         ENDIF
3756     ELSE
3757         PROCwimp_error("Message","To save, drag the icon to a directory/application Filer window.",1,0)
3758     ENDIF
3759 ELSE
3760     PROCwimp_error("","Filetype string too long in 'DEF FNuser_savefiletype'.",1,1):PROCwimp_closedown:END
3761 ENDIF
3762 ENDPROC
3763 :
3764 DEF  PROCwimp_sendfiletoprinter(filepath$,deletefile%)
3765 LOCAL ftype%,leaf$,lenleaf%,messagelen%
3766 IF FNwimp_pdriverpresent=FALSE THEN
3767     PROCwimp_error("","Sorry, a printer driver isn't loaded.",1,1)
3768 ELSE
3769     ftype$=FNwimp_testobjectpresent(filepath$,0)
3770     IF ftype$="" OR (LEN(ftype$)>3) THEN
3771         PROCwimp_error("","Sorry, a file called "+filepath$+" cannot be found.",1,1)
3772     ELSE
3773         wToPrinter%=1
3774         wPrintFile$=filepath$
3775         wDeleteFile%=deletefile%
3776         leaf$=FNwimp_getleafname(filepath$)
3777         SYS "OS_ReadUnsigned",16,ftype$ TO ,,ftype%
3778         wPrintFileType%=ftype%
3779         wimp%!12=0
3780         wimp%!16=&80142
3781         wimp%!20=-1
3782         wimp%!24=-1
3783         wimp%!28=0
3784         wimp%!32=0
3785         wimp%!36=-1
3786         wimp%!40=ftype%
3787         PROCwint_zeroterminate(wimp%+44,leaf$)
3788         lenleaf%=LEN(leaf$)+1
3789         IF (lenleaf% MOD 4) <>0 THEN lenleaf%=4*((lenleaf% DIV 4)+1)
3790         messagelen%=44+lenleaf%
3791         wimp%!0=messagelen%
3792         SYS "Wimp_SendMessage",18,wimp%,0
3793     ENDIF
3794 ENDIF
3795 ENDPROC
3796 :
3797 DEF PROCwint_receivedmess4
3798 IF wToPrinter%=1 THEN
3799     wToPrinter%=0
3800     wPrintFileType%=0
3801     wPrintFile$=""
3802     wDeleteFile%=0
3803 ENDIF
3804 ENDPROC
3805 :
3806 DEF FNwint_getfilesize(path$,warning%)
3807 LOCAL exists%,filelength%
3808 SYS "XOS_File",17,path$ TO exists%,,,,filelength%
3809 IF exists%=0 THEN
3810     IF warning%<>0 THEN
3811         PROCwimp_error("","Sorry, a file called "+path$+" cannot be found.",1,1)
3812     ENDIF
3813     filelength%=-1
3814 ENDIF
3815 =filelength%
3816 :
3817 DEF FNwimp_measurefile(path$,warning%)
3818 LOCAL return%
3819 return%=0
3820 return%=FNwint_getfilesize(path$,warning%)
3821 IF return%>-1 THEN return%+=4
3822 =return%
3823 :
3824 DEF FNwimp_loadfile(filepath$,address%,warning%)
3825 LOCAL nextloadat%,realsize%,loadat%
3826 nextloadat%=address%
3827 realsize%=FNwint_getfilesize(filepath$,warning%)
3828 IF realsize%>-1 THEN
3829     address%!0=realsize%
3830     loadat%=address%+4
3831     PROCwimp_hourglasson
3832     SYS "OS_Find",&4F,filepath$ TO file%
3833     SYS "OS_GBPB",4,file%,loadat%,realsize%
3834     SYS "OS_Find",0,file%
3835     PROCwimp_hourglassoff
3836     nextloadat%=address%+realsize%+4
3837 ENDIF
3838 =nextloadat%
3839 :
3840 DEF PROCwint_receivedmess3or5(type%,desttask%,inref%,whan%,icon%,x%,y%,size%,ftype%,ptr44%)
3841 LOCAL ftype$,path$,action%,workx%,worky%
3842 PROCwimp_hourglasson
3843 ftype$=STR$~(ftype%)
3844 CASE ftype$ OF
3845     WHEN "1000","2000"
3846     OTHERWISE
3847     ftype$=RIGHT$("00"+ftype$,3)
3848 ENDCASE
3849 path$=FNwint_string(ptr44%)
3850 IF type%=5 THEN
3851     whan%=0:icon%=-1
3852     workx%=-1:worky%=-1
3853 ELSE
3854     workx%=FNwimp_screentowork(whan%,x%,0)
3855     worky%=FNwimp_screentowork(whan%,y%,1)
3856 ENDIF
3857 action%=FNuser_loaddata(path$,whan%,icon%,ftype$,workx%,worky%)
3858 IF action%=1 THEN PROCwint_dataloadack(path$,desttask%,inref%,whan%,icon%,x%,y%,size%,ftype%)
3859 PROCwimp_hourglassoff
3860 ENDPROC
3861 :
3862 DEF PROCwint_dataloadack(path$,desttask%,inref%,window%,icon%,x%,y%,size%,ftype%)
3863 wimp%!0=256
3864 wimp%!12=inref%
3865 wimp%!16=4
3866 wimp%!20=window%
3867 wimp%!24=icon%
3868 wimp%!28=x%
3869 wimp%!32=y%
3870 wimp%!36=size%
3871 PROCwint_zeroterminate(wimp%+44,path$)
3872 SYS "Wimp_SendMessage",17,wimp%,desttask%
3873 IF path$="<Wimp$Scrap>" THEN SYS "OS_FSControl",27,path$,,%10
3874 ENDPROC
3875 :
3876 DEF PROCwint_receivedmess1(desttask%,inref%,destwhan%,destic%,destx%,desty%,size%,ftype%)
3877 IF desttask%<>wTask% THEN
3878     wimp%!0=256
3879     wimp%!12=inref%
3880     wimp%!16=2
3881     wimp%!20=destwhan%
3882     wimp%!24=destic%
3883     wimp%!28=destx%
3884     wimp%!32=desty%
3885     wimp%!36=-1
3886     wimp%!40=ftype%
3887     PROCwint_zeroterminate(wimp%+44,"<Wimp$Scrap>")
3888     SYS "Wimp_SendMessage",17,wimp%,desttask%
3889 ENDIF
3890 ENDPROC
3891 :
3892 DEF PROCwint_zeroterminate(wptr%,text$)
3893 $wptr%=text$
3894 wptr%?(LEN(text$))=0
3895 ENDPROC
3896 :
3897 DEF FNwimp_testobjectpresent(fullpath$,warning%)
3898 LOCAL return$,objecttype%,ftype%,loadaddr%
3899 return$="1234"
3900 return$=""
3901 SYS "OS_File",23,fullpath$ TO objecttype%,,,,,,ftype%
3902 IF objecttype%<>0 THEN
3903     IF objecttype%<>3 THEN
3904         IF ftype%=-1 THEN
3905             return$="-1"
3906         ELSE
3907             return$=STR$~(ftype%)
3908             WHILE LEN(return$)<3
3909                 return$="0"+return$
3910             ENDWHILE
3911         ENDIF
3912     ELSE
3913         SYS "OS_File",17,fullpath$ TO ,,loadaddr%
3914         ftype%=((loadaddr%>>8) AND %111111111111)
3915         return$=STR$~(ftype%)
3916         WHILE LEN(return$)<3
3917             return$="0"+return$
3918         ENDWHILE
3919     ENDIF
3920 ELSE
3921     IF warning%<>0 THEN
3922         PROCwimp_error("","The object cannot be found.(Null string will be returned.)",1,1)
3923     ENDIF
3924 ENDIF
3925 =return$
3926 :
3927 DEF FNwimp_countdirectoryobjects(dir$)
3928 LOCAL objects%,finishflag%,f%,dirbuffersize%
3929 dirbuffersize%=256
3930 IF wDirbuffer%=-1 THEN DIM wDirbuffer% dirbuffersize%-1
3931 objects%=-1
3932 REPEAT
3933     objects%+=1
3934     SYS "XOS_GBPB",9,dir$,wDirbuffer%,1,objects%,dirbuffersize% TO ,,,,finishflag%;f%
3935     IF (f% AND 1)=1 THEN finishflag%=-1:objects%=-1
3936 UNTIL finishflag%=-1
3937 =objects%
3938 :
3939 DEF FNwimp_getdirectoryobjectname(dir$,objectnumber%)
3940 LOCAL objectname$,finishflag%,pointer%,f%,dirbuffersize%
3941 IF objectnumber%<1 THEN objectnumber%=1
3942 dirbuffersize%=256
3943 IF wDirbuffer%=-1 THEN DIM wDirbuffer% dirbuffersize%-1
3944 objectname$=""
3945 SYS "XOS_GBPB",9,dir$,wDirbuffer%,1,(objectnumber%-1),dirbuffersize% TO ,,,,finishflag%;f%
3946 IF (f% AND 1)=1 THEN finishflag%=-1
3947 IF finishflag%<>-1 THEN
3948     pointer%=wDirbuffer%
3949     WHILE ?pointer%>31
3950         pointer%+=1
3951     ENDWHILE
3952     ?pointer%=13
3953     objectname$=FNwint_string(wDirbuffer%)
3954 ENDIF
3955 =objectname$
3956 :
3957 DEF FNwimp_getdirectoryobjecttype(dir$,objectnumber%)
3958 LOCAL finishflag%,offset1%,offset2%,objecttype%,objectfiletype%,objectfiletypestring$,f%,dirbuffersize%
3959 IF objectnumber%<1 THEN objectnumber%=1
3960 dirbuffersize%=256
3961 IF wDirbuffer%=-1 THEN DIM wDirbuffer% dirbuffersize%-1
3962 offset1%=20
3963 offset2%=16
3964 objecttype%=0
3965 objecttypestring$="1234"
3966 objecttypestring$=""
3967 SYS "XOS_GBPB",12,dir$,wDirbuffer%,1,(objectnumber%-1),dirbuffersize% TO ,,,,finishflag%;f%
3968 IF (f% AND 1)=1 THEN finishflag%=-1
3969 IF finishflag%<>-1 THEN
3970     objecttype%=wDirbuffer%!offset2%
3971     IF objecttype%<>3 THEN
3972         objectfiletype%=wDirbuffer%!offset1%
3973     ELSE
3974         objectfiletype%=((wDirbuffer%!0>>8) AND %111111111111)
3975     ENDIF
3976     objectfiletypestring$=STR$~(objectfiletype%)
3977     WHILE LEN(objectfiletypestring$)<3
3978         objectfiletypestring$="0"+objectfiletypestring$
3979     ENDWHILE
3980 ENDIF
3981 =objectfiletypestring$
3982 :
3983 DEF FNwimp_getdirectorypath(pathname$)
3984 LOCAL return$,temp$
3985 return$=""
3986 temp$=FNwimp_getleafname(pathname$)
3987 IF temp$<>pathname$ THEN
3988     return$=LEFT$(pathname$,LEN(pathname$)-LEN(temp$))
3989 ENDIF
3990 =return$
3991 :
3992 DEF FNwimp_getleafname(return$)
3993 WHILE INSTR(return$,".")>0
3994     return$=MID$(return$,INSTR(return$,".")+1)
3995 ENDWHILE
3996 =MID$(return$,INSTR(return$,":")+1)
3997 :
3998 DEF FNwimp_copyobject(sourcepath$,destinationpath$,deletesource%,newer%,restamp%,force%,warning%)
3999 LOCAL return%,exist$,flags%,f%
4000 return%=1
4001 exist$=FNwimp_testobjectpresent(sourcepath$,0)
4002 IF exist$="" THEN
4003     return%=0
4004     IF warning%<>0 THEN
4005         PROCwimp_error("","Sorry, but the source file '"+sourcepath$+"' cannot be found.",1,1)
4006     ENDIF
4007 ELSE
4008     flags%=0
4009     IF deletesource%<>0 THEN deletesource%=1
4010     IF newer%<>0 THEN newer%=1
4011     IF restamp%<>0 THEN restamp%=1
4012     IF force%<>0 THEN force%=1
4013     flags%+=(1<<14)+(newer%<<12)+(restamp%<<10)+(deletesource%<<7)+(force%<<1)+(1<<0)
4014     PROCwimp_hourglasson
4015     SYS "XOS_FSControl",26,sourcepath$,destinationpath$,flags% TO ;f%
4016     PROCwimp_hourglassoff
4017     IF (f% AND 1)=1 THEN return%=0
4018 ENDIF
4019 =return%
4020 :
4021 DEF FNwimp_deleteobject(path$,force%,warning%)
4022 LOCAL return%,exist$,flags%,f%
4023 return%=1
4024 exist$=FNwimp_testobjectpresent(path$,0)
4025 IF exist$="" THEN
4026     return%=0
4027     IF warning%<>0 THEN
4028         PROCwimp_error("","Sorry, but '"+path$+"' cannot be found.",1,1)
4029     ENDIF
4030 ELSE
4031     IF force%=1 THEN
4032         flags%=%11
4033     ELSE
4034         flags%=%1
4035     ENDIF
4036     PROCwimp_hourglasson
4037     SYS "XOS_FSControl",27,path$,,flags% TO ;f%
4038     PROCwimp_hourglassoff
4039     IF (f% AND 1)=1 THEN return%=0
4040 ENDIF
4041 =return%
4042 :
4043 DEF PROCwimp_doubleclickobject(path$,warning%)
4044 LOCAL exist$
4045 exist$=FNwimp_testobjectpresent(path$,0)
4046 IF exist$="" THEN
4047     IF warning%<>0 THEN
4048         PROCwimp_error("","Sorry, but '"+path$+"' cannot be found.",1,1)
4049     ENDIF
4050 ELSE
4051     OSCLI("Filer_Run "+path$)
4052 ENDIF
4053 ENDPROC
4054 :
4055 DEF PROCwimp_setfiletypenumber(file$,ftype%,warning%)
4056 LOCAL exist$
4057 exist$=FNwimp_testobjectpresent(file$,0)
4058 CASE exist$ OF
4059     WHEN ""
4060     IF warning%<>0 THEN
4061         PROCwimp_error("","Sorry, but the file '"+file$+"' cannot be found.",1,1)
4062     ENDIF
4063     WHEN "1000","2000"
4064     IF warning%<>0 THEN
4065         PROCwimp_error("","Sorry, but '"+file$+"' is a directory (or application).",1,1)
4066     ENDIF
4067     OTHERWISE
4068     IF ftype%<0 OR ftype%>&FFF THEN ftype%=&FFF
4069     SYS "XOS_File",18,file$,ftype%
4070 ENDCASE
4071 ENDPROC
4072 :
4073 DEF PROCwimp_setfiletypehexstring(file$,ftype$,warning%)
4074 LOCAL ftype%
4075 IF LEFT$(ftype$,1)<>"&" THEN ftype$="&"+ftype$
4076 SYS "XOS_ReadUnsigned",,ftype$ TO ,,ftype%
4077 PROCwimp_setfiletypenumber(file$,ftype%,warning%)
4078 ENDPROC
4079 :
4080 DEF PROCwimp_createdirectory(dir$,warning%)
4081 LOCAL create%,parentdir$,exist$,leafname$
4082 create%=TRUE
4083 parentdir$=LEFT$(FNwimp_getdirectorypath(dir$))
4084 exist$=FNwimp_testobjectpresent(parentdir$,0)
4085 IF exist$="" OR LEN(exist$)<4 THEN
4086     create%=FALSE
4087     IF warning%<>0 THEN
4088         PROCwimp_error("","Sorry, but the intended parent directory '"+parentdir$+"' cannot be found (or already exists as a file).",1,1)
4089     ENDIF
4090 ENDIF
4091 IF create%=TRUE THEN
4092     leafname$=FNwimp_getleafname(dir$)
4093     exist$=FNwimp_testobjectpresent(dir$,0)
4094     IF exist$<>"" AND LEN(exist$)<4 THEN
4095         create%=FALSE
4096         IF warning%<>0 THEN
4097             PROCwimp_error("","Sorry, but a file with the intended directory name '"+leafname$+"' already exists.",1,1)
4098         ENDIF
4099     ENDIF
4100 ENDIF
4101 IF create%=TRUE THEN
4102     SYS "XOS_File",8,dir$,,,0
4103 ENDIF
4104 ENDPROC
4105 :
4106 DEF FNwimp_renameobject(existingpath$,newpath$,warning%)
4107 LOCAL rename%,exist$,newparentdir$,f%
4108 rename%=1
4109 exist$=FNwimp_testobjectpresent(existingpath$,0)
4110 IF exist$="" THEN
4111     rename%=0
4112     IF warning%<>0 THEN
4113         PROCwimp_error("","Sorry, but the object '"+existingpath$+"' cannot be found.",1,1)
4114     ENDIF
4115 ENDIF
4116 IF rename%=1 THEN
4117     exist$=FNwimp_testobjectpresent(newpath$,0)
4118     IF exist$<>"" THEN
4119         rename%=0
4120         IF warning%<>0 THEN
4121             PROCwimp_error("","Sorry, but the intended renamed object '"+newpath$+"' already exists.",1,1)
4122         ENDIF
4123     ENDIF
4124 ENDIF
4125 IF rename%=1 THEN
4126     newparentdir$=LEFT$(FNwimp_getdirectorypath(newpath$))
4127     exist$=FNwimp_testobjectpresent(newparentdir$,0)
4128     IF exist$="" THEN
4129         rename%=0
4130         IF warning%<>0 THEN
4131             PROCwimp_error("","Sorry, but the intended directory '"+newparentdir$+"' cannot be found.",1,1)
4132         ENDIF
4133     ENDIF
4134 ENDIF
4135 IF rename%=1 THEN
4136     SYS "XOS_FSControl",25,existingpath$,newpath$ TO ;f%
4137     IF (f% AND 1)=1 THEN rename%=0
4138 ENDIF
4139 =rename%
4140 :
4141 DEF FNwimp_getobjecttypenumber(fullpath$,warning%)
4142 LOCAL return%,objecttype%,ftype%,loadaddr%
4143 return%=0
4144 SYS "OS_File",23,fullpath$ TO objecttype%,,,,,,ftype%
4145 IF objecttype%=0 THEN
4146     IF warning%<>0 THEN
4147         PROCwimp_error("","Sorry, but the object '"+fullpath$+"' cannot be found.",1,1)
4148     ENDIF
4149 ELSE
4150     IF objecttype%<>3 THEN
4151         return%=ftype%
4152     ELSE
4153         SYS "OS_File",17,fullpath$ TO ,,loadaddr%
4154         ftype%=((loadaddr%>>8) AND %111111111111)
4155         return%=ftype%
4156     ENDIF
4157 ENDIF
4158 =return%
4159 :
4160 DEF FNwimp_getobjecttypehexstring(fullpath$,warning%)
4161 LOCAL return$
4162 return$=""
4163 return$=FNwimp_testobjectpresent(fullpath$,warning%)
4164 =return$
4165 :
4166 DEF PROCwimp_opendirectory(dir$,default%,topx%,topy%,width%,height%,iconsize%,sortby%,warning%)
4167 LOCAL test$,param$,size$,sort$
4168 IF RIGHT$(dir$)="." THEN dir$=LEFT$(dir$)
4169 test$=FNwimp_testobjectpresent(dir$,0)
4170 IF LEN(test$)<4 THEN
4171     IF warning%<>0 THEN
4172         PROCwimp_error("","Sorry, but '"+dir$+"' cannot be found - or it is not a directory.",1,1)
4173     ENDIF
4174 ELSE
4175     param$=" "
4176     IF default%=0 THEN
4177         IF iconsize%<1 THEN iconsize%=1
4178         IF iconsize%>3 THEN iconsize%=3
4179         IF sortby%<1 THEN sortby%=1
4180         IF sortby%>4 THEN sortby%=4
4181         size$=MID$("-si-li-fi",((iconsize%-1)*3)+1,3)
4182         sort$=MID$("-sn-st-sd-ss",((sortby%-1)*3)+1,3)
4183         param$+=STR$(topx%)+" "+STR$(topy%)+" "+STR$(width%)+" "+STR$(height%)+" "+size$+" "+sort$
4184     ENDIF
4185     SYS "OS_CLI","Filer_OpenDir "+dir$+param$
4186 ENDIF
4187 ENDPROC
4188 :
4189 DEF PROCwimp_closedirectory(dir$)
4190 IF RIGHT$(dir$)="." THEN dir$=LEFT$(dir$)
4191 SYS "OS_CLI","Filer_CloseDir "+dir$
4192 ENDPROC
4193 :
4194 DEF FNwimp_getscreensize(side%)
4195 LOCAL Eig%,s%
4196 IF side%<>0 THEN side%=1
4197 SYS "OS_ReadModeVariable",-1,side%+4 TO ,,Eig%
4198 SYS "OS_ReadModeVariable",-1,side%+11 TO ,,s%
4199 =(s%+1)<<Eig%
4200 :
4201 DEF FNwimp_getscreenres(direction%)
4202 LOCAL return%
4203 IF direction%<>0 THEN direction%=1
4204 SYS "OS_ReadModeVariable",-1,(11+direction%) TO ,,return%
4205 =return%+1
4206 :
4207 DEF FNwimp_worktoscreen(whan%,coord%,side%)
4208 LOCAL f%,return%
4209 return%=0
4210 wimp%!0=whan%
4211 SYS "XWimp_GetWindowInfo",,(wimp% OR %1) TO ;f%
4212 IF (f% AND 1)=1 THEN
4213     return%=0
4214 ELSE
4215     IF side%=0 THEN
4216         return%=coord%+wimp%!4-wimp%!20
4217     ELSE
4218         return%=coord%+wimp%!16-wimp%!24
4219     ENDIF
4220 ENDIF
4221 =return%
4222 :
4223 DEF FNwimp_screentowork(whan%,coord%,side%)
4224 LOCAL f%,return%
4225 return%=0
4226 wimp%!0=whan%
4227 SYS "XWimp_GetWindowInfo",,(wimp% OR %1) TO ;f%
4228 IF (f% AND 1)=1 THEN
4229     return%=0
4230 ELSE
4231     IF side%=0 THEN
4232         return%=coord%+wimp%!20-wimp%!4
4233     ELSE
4234         return%=coord%+wimp%!24-wimp%!16
4235     ENDIF
4236 ENDIF
4237 =return%
4238 :
4239 DEF FNwimp_lengthtoOS(lengthreal,scalereal,inch%)
4240 LOCAL returnreal
4241 IF inch%=0 THEN
4242     returnreal=((lengthreal/25.4)*180)*(scalereal/100)
4243 ELSE
4244     returnreal=(lengthreal*180)*(scalereal/100)
4245 ENDIF
4246 =returnreal
4247 :
4248 DEF FNwimp_OStolength(osreal,scalereal,inch%)
4249 LOCAL returnreal
4250 IF inch%=0 THEN
4251     returnreal=((osreal/180)*25.4)*(scalereal/100)
4252 ELSE
4253     returnreal=(osreal/180)*(scalereal/100)
4254 ENDIF
4255 =returnreal
4256 :
4257 DEF FNwimp_getdaydatetime(choice%)
4258 LOCAL choice$,current$
4259 choice$=""
4260 IF choice%<0 THEN choice%=0
4261 IF choice%>3 THEN choice%=3
4262 current$=FNwint_getcurrentdateandtime
4263 CASE choice% OF
4264     WHEN 0:choice$=current$
4265     WHEN 1:choice$=LEFT$(current$,3)
4266     WHEN 2:choice$=MID$(current$,5,11)
4267     WHEN 3:choice$=RIGHT$(current$,8)
4268 ENDCASE
4269 =choice$
4270 :
4271 DEF FNwint_getcurrentdateandtime
4272 LOCAL format$
4273 format$="%W3 %DY %M3 %CE%YR %24:%MI:%SE"
4274 IF wDateblk%=0 THEN
4275     DIM wDateblk% 4,wResult% 63
4276 ENDIF
4277 ?wDateblk%=3
4278 SYS"OS_Word",14,wDateblk% TO ,wDateblk%
4279 SYS "Territory_ConvertDateAndTime",-1,wDateblk%,wResult%,64,format$ TO wResult%
4280 =FNwint_string(wResult%)
4281 :
4282 DEF FNwimp_roundfloat(areal)
4283 LOCAL a%,diffreal
4284 a%=areal
4285 diffreal=areal-a%
4286 IF ABS(diffreal)>=0.5 THEN
4287     IF areal<0 THEN
4288         a%=a%-1
4289     ELSE
4290         a%=a%+1
4291     ENDIF
4292 ENDIF
4293 =a%
4294 :
4295 DEF FNwimp_decplacesstr(number,decplaces%)
4296 LOCAL result$,return$,e$,e%,sign%,scale,@%
4297 @%="G10.9"
4298 sign%=SGN(number)
4299 result$=STR$(number)
4300 e%=INSTR(result$,"E")
4301 scale=10^(decplaces%+1)
4302 IF e%<>0 THEN
4303     e$=MID$(result$,e%)
4304     result$=LEFT$(result$,e%-1)
4305 ENDIF
4306 number=(ABS(VAL(result$))*scale)+0.5
4307 @%="+F25."+STR$(decplaces%)
4308 result$=STR$((number/scale)*sign%)
4309 IF INSTR(result$,".")=0 result$+="."
4310 IF decplaces%=0 THEN
4311     result$=STR$(VAL(result$))
4312     result$=LEFT$(result$,INSTR(result$,".")-1)
4313 ELSE
4314     result$=result$+STRING$(decplaces%,"0")
4315     result$=LEFT$(result$,INSTR(result$,".")+decplaces%)
4316 ENDIF
4317 return$=result$+e$
4318 =return$
4319 :
4320 DEF FNwimp_decplacesnum(number,decplaces%)
4321 LOCAL returnreal
4322     returnreal=VAL(FNwimp_decplacesstr(number,decplaces%))
4323 =returnreal
4324 :
4325 DEF FNwimp_numtodecstring(number%)
4326 LOCAL return$
4327 IF wConvert%=0 THEN DIM wConvert% wDimsize%-1
4328 return$=""
4329 SYS "OS_ConvertCardinal4",number%,wConvert%,wDimsize%
4330 return$=FNwint_string(wConvert%)
4331 =return$
4332 :
4333 DEF FNwimp_numtosigneddecstring(number%)
4334 LOCAL return$
4335 IF wConvert%=0 THEN DIM wConvert% wDimsize%-1
4336 return$=""
4337 SYS "OS_ConvertInteger4",number%,wConvert%,wDimsize%
4338 return$=FNwint_string(wConvert%)
4339 =return$
4340 :
4341 DEF FNwimp_numtohexstring(number%,digits%,prefix%)
4342 LOCAL return$
4343 IF wConvert%=0 THEN DIM wConvert% wDimsize%-1
4344 IF digits%<1 THEN digits%=1
4345 IF digits%>8 THEN digits%=8
4346 CASE digits% OF
4347     WHEN 3,5,7
4348     digits%+=1
4349 ENDCASE
4350 return$=""
4351 SYS "OS_ConvertHex"+STR$(digits%),number%,wConvert%,wDimsize%
4352 return$=FNwint_string(wConvert%)
4353 IF prefix%<>0 THEN return$="&"+return$
4354 =return$
4355 :
4356 DEF FNwimp_numtobinstring(number%,digits%,prefix%)
4357 LOCAL return$
4358 IF wConvert%=0 THEN DIM wConvert% wDimsize%-1
4359 IF digits%<1 THEN digits%=1
4360 IF digits%>4 THEN digits%=4
4361 return$=""
4362 SYS "OS_ConvertBinary"+STR$(digits%),number%,wConvert%,wDimsize%
4363 return$=FNwint_string(wConvert%)
4364 IF prefix%<>0 THEN return$="%"+return$
4365 =return$
4366 :
4367 DEF FNwimp_changecase(string$,upper%)
4368 LOCAL x%,table%,char%
4369 IF upper%<>0 THEN
4370     SYS "Territory_UpperCaseTable",-1 TO table%
4371 ELSE
4372     SYS "Territory_LowerCaseTable",-1 TO table%
4373 ENDIF
4374 FOR x%=1 TO LEN(string$)
4375     char%=ASC(MID$(string$,x%,1))
4376     MID$(string$,x%,1)=CHR$(table%?char%)
4377 NEXT
4378 =string$
4379 :
4380 DEF PROCwint_help(desttask%,inref%,whan%,icon%,mousex%,mousey%,button%)
4381 LOCAL help$,menu%,item%,sub%,len%
4382 help$=""
4383 SYS "Wimp_GetMenuState",1,wimp%,whan%,icon%
4384 IF wimp%!0<>-1 THEN
4385     menu%=0:item%=0
4386     PROCwint_getmenuanditem(wLastmenu%,menu%,item%)
4387     sub%=!(menu%+8+(item%*24))
4388     IF sub%=whan% THEN
4389         help$=FNuser_help(whan%,icon%)
4390     ELSE
4391         help$=FNuser_menuhelp(menu%,item%)
4392     ENDIF
4393 ELSE
4394     help$=FNuser_help(whan%,icon%)
4395 ENDIF
4396 IF help$<>"" THEN
4397     wimp%!0=(LEN(help$)+24) AND NOT 3
4398     wimp%!12=inref%
4399     wimp%!16=&503
4400     PROCwint_zeroterminate(wimp%+20,help$)
4401     SYS "Wimp_SendMessage",17,wimp%,desttask%
4402 ENDIF
4403 ENDPROC
4404 :
4405 DEF PROCwimp_setsysvariable(var$,val$)
4406 SYS "XOS_SetVarVal",var$,val$,LEN(val$)
4407 ENDPROC
4408 :
4409 DEF PROCwimp_unsetsysvariable(var$)
4410 SYS "XOS_SetVarVal",var$,,-1
4411 ENDPROC
4412 :
4413 DEF FNwimp_testsysvariable(sysvar$)
4414 LOCAL return%,len%
4415 return%=TRUE
4416 $wimp%=sysvar$
4417 SYS "XOS_ReadVarVal",wimp%,wimp%+255,-1,,3 TO ,,len%
4418 IF len%=0 THEN return%=FALSE
4419 =return%
4420 :
4421 DEF FNwimp_getsysvariable(sysvar$)
4422 LOCAL return$,len%
4423 return$=""
4424 IF FNwimp_testsysvariable(sysvar$)=TRUE THEN
4425     $wimp%=sysvar$
4426     SYS "OS_ReadVarVal",wimp%,wimp%+255,255,,3 TO ,,len%
4427     wimp%?(len%+255)=13
4428     return$=FNwint_string(wimp%+255)
4429 ENDIF
4430 =return$
4431 :
4432 DEF FNwimp_istaskrunning(taskname$)
4433 LOCAL nextstart%,buffersize%,task$
4434 return%=FALSE
4435 buffersize%=16
4436 nextstart%=0
4437 REPEAT
4438     SYS "TaskManager_EnumerateTasks",nextstart%,wimp%,buffersize% TO nextstart%
4439     SYS "XOS_GenerateError",wimp%!4 TO task$
4440 UNTIL nextstart%<0 OR task$=taskname$
4441 IF task$=taskname$ THEN return%=TRUE
4442 =return%
4443 :
4444 DEF FNwimp_createstringblock(n%,l%,da%)
4445 LOCAL blk%
4446 l%+=2
4447 n%+=1
4448 blocksize%=((n%*l%)+8)-1
4449 IF da%<>0 THEN
4450     blk%=FNwimp_createdynamic(blocksize%,blocksize%,0,wappname$+" String block")
4451 ELSE
4452     DIM blk% blocksize%
4453 ENDIF
4454 !blk%=l%
4455 blk%!4=n%-1
4456 =blk%
4457 :
4458 DEF PROCwimp_putinstringblock(blk%,item$,n%,error%)
4459 LOCAL l%,highest%
4460 highest%=blk%!4
4461 IF (n%<1 OR n%>highest%) AND (error%<>0) THEN
4462     PROCwimp_error("","Sorry, but you have specified a string position outside the defined block range of 1-"+STR$(highest%)+". No action will be taken.",1,1)
4463 ELSE
4464     IF n%<1 THEN n%=1
4465     IF n%>highest% THEN n%=highest%
4466     l%=!blk%
4467     $(blk%+(n%*l%)+8)=LEFT$(item$,l%)
4468 ENDIF
4469 ENDPROC
4470 :
4471 DEF FNwimp_getfromstringblock(blk%,n%,error%)
4472 LOCAL l%,value$,highest%
4473 value$=""
4474 highest%=blk%!4
4475 IF (n%<1 OR n%>highest%) AND (error%<>0) THEN
4476     PROCwimp_error("","Sorry, but you have specified a position outside the defined block range of 1-"+STR$(highest%)+". The returned value will be a null string.",1,1)
4477 ELSE
4478     IF n%<1 THEN n%=1
4479     IF n%>highest% THEN n%=highest%
4480     l%=!blk%
4481     value$=FNwint_string(blk%+(n%*l%)+8)
4482 ENDIF
4483 =value$
4484 :
4485 DEF PROCwimp_setstringblock(block%,string$)
4486 LOCAL N%,max%
4487 max%=block%!4
4488 FOR N%=1 TO max%
4489     PROCwimp_putinstringblock(block%,string$,N%,0)
4490 NEXT
4491 ENDPROC
4492 :
4493 DEF FNwimp_createintegerblock(n%,da%)
4494 LOCAL blk%
4495 n%+=1
4496 blocksize%=(4*n%)-1
4497 IF da%<>0 THEN
4498     blk%=FNwimp_createdynamic(blocksize%,blocksize%,0,wappname$+" Integer block")
4499 ELSE
4500     DIM blk% blocksize%
4501 ENDIF
4502 blk%!0=n%-1
4503 =blk%
4504 :
4505 DEF PROCwimp_putinintegerblock(blk%,value%,n%,error%)
4506 LOCAL highest%
4507 highest%=blk%!0
4508 IF (n%<1 OR n%>highest%) AND (error%<>0) THEN
4509     PROCwimp_error("","Sorry, but you have specified an integer position outside the defined block range of 1-"+STR$(highest%)+". No action will be taken.",1,1)
4510 ELSE
4511     IF n%<1 THEN n%=1
4512     IF n%>highest% THEN n%=highest%
4513     blk%!((n%+1)*4)=value%
4514 ENDIF
4515 ENDPROC
4516 :
4517 DEF FNwimp_getfromintegerblock(blk%,n%,error%)
4518 LOCAL highest%,value%
4519 value%=0
4520 highest%=blk%!0
4521 IF (n%<1 OR n%>highest%) AND (error%<>0) THEN
4522     PROCwimp_error("","Sorry, but you have specified a position outside the defined block range of 1-"+STR$(highest%)+". The returned value will be 0.",1,1)
4523 ELSE
4524     IF n%<1 THEN n%=1
4525     IF n%>highest% THEN n%=highest%
4526     value%=blk%!((n%+1)*4)
4527 ENDIF
4528 =value%
4529 :
4530 DEF PROCwimp_setintegerblock(block%,value%)
4531 LOCAL N%,max%
4532 max%=block%!0
4533 FOR N%=1 TO max%
4534     PROCwimp_putinintegerblock(block%,value%,N%,0)
4535 NEXT
4536 ENDPROC
4537 :
4538 DEF PROCwint_savewimp
4539 SYS "Wimp_TransferBlock",wTask%,wimp%,wTask%,wTempblk%,320
4540 ENDPROC
4541 :
4542 DEF PROCwint_loadwimp
4543 SYS "Wimp_TransferBlock",wTask%,wTempblk%,wTask%,wimp%,320
4544 ENDPROC
4545 :
4546 DEF PROCwint_savewimp2
4547 SYS "Wimp_TransferBlock",wTask%,wimp%,wTask%,wTempblk2%,320
4548 ENDPROC
4549 :
4550 DEF PROCwint_loadwimp2
4551 SYS "Wimp_TransferBlock",wTask%,wTempblk2%,wTask%,wimp%,320
4552 ENDPROC
4553 :
4554 DEF PROCwimp_hourglasson
4555 SYS "Hourglass_On"
4556 ENDPROC
4557 :
4558 DEF PROCwimp_hourglassoff
4559 SYS "Hourglass_Off"
4560 ENDPROC
4561 :
4562 DEF PROCwimp_hourglasspercentage(percent%)
4563 SYS "Hourglass_Percentage",percent%
4564 ENDPROC
4565 :
4566 DEF PROCwimp_setcolour(r%,g%,b%,background%)
4567 LOCAL c%,flags%
4568 c%=(b%<<24)+(g%<<16)+(r%<<8)
4569 IF background%<>0 THEN background%=1
4570 flags%=(1<<8)+(background%<<7)
4571 SYS "ColourTrans_SetGCOL",c%,,,flags%,0
4572 ENDPROC
4573 :
4574 DEF PROCwimp_plotwindowline(window%,point1x%,point1y%,point2x%,point2y%,type%)
4575 IF wPrinting%=FALSE THEN
4576     point1x%=FNwimp_worktoscreen(window%,point1x%,0)
4577     point1y%=FNwimp_worktoscreen(window%,point1y%,1)
4578     point2x%=FNwimp_worktoscreen(window%,point2x%,0)
4579     point2y%=FNwimp_worktoscreen(window%,point2y%,1)
4580 ENDIF
4581 MOVE point1x%,point1y%
4582 PLOT (type%*16)+5,point2x%,point2y%
4583 ENDPROC
4584 :
4585 DEF PROCwimp_plotwindowrectangle(window%,bottomleftx%,bottomlefty%,width%,height%,fill%)
4586 IF wPrinting%=FALSE THEN
4587     bottomleftx%=FNwimp_worktoscreen(window%,bottomleftx%,0)
4588     bottomlefty%=FNwimp_worktoscreen(window%,bottomlefty%,1)
4589 ENDIF
4590 IF fill%=0 THEN
4591     RECTANGLE bottomleftx%,bottomlefty%,width%,height%
4592 ELSE
4593     RECTANGLE FILL bottomleftx%,bottomlefty%,width%,height%
4594 ENDIF
4595 ENDPROC
4596 :
4597 DEF PROCwimp_plotwindowcircle(window%,centrex%,centrey%,radius%,fill%)
4598 IF wPrinting%=FALSE THEN
4599     centrex%=FNwimp_worktoscreen(window%,centrex%,0)
4600     centrey%=FNwimp_worktoscreen(window%,centrey%,1)
4601 ENDIF
4602 IF fill%=0 THEN
4603     CIRCLE centrex%,centrey%,radius%
4604 ELSE
4605     CIRCLE FILL centrex%,centrey%,radius%
4606 ENDIF
4607 ENDPROC
4608 :
4609 DEF PROCwimp_plotwindowellipse(window%,centrex%,centrey%,semimajor%,semiminor%,rotatedegrees,fill%)
4610 LOCAL rads
4611 IF wPrinting%=FALSE THEN
4612     centrex%=FNwimp_worktoscreen(window%,centrex%,0)
4613     centrey%=FNwimp_worktoscreen(window%,centrey%,1)
4614 ENDIF
4615 rads=RAD(rotatedegrees)
4616 IF fill%=0 THEN
4617     ELLIPSE centrex%,centrey%,semimajor%,semiminor%,rads
4618 ELSE
4619     ELLIPSE FILL centrex%,centrey%,semimajor%,semiminor%,rads
4620 ENDIF
4621 ENDPROC
4622 :
4623 DEF PROCwimp_plotwindowtriangle(window%,point1x%,point1y%,point2x%,point2y%,point3x%,point3y%,fill%)
4624 IF wPrinting%=FALSE THEN
4625     point1x%=FNwimp_worktoscreen(window%,point1x%,0)
4626     point1y%=FNwimp_worktoscreen(window%,point1y%,1)
4627     point2x%=FNwimp_worktoscreen(window%,point2x%,0)
4628     point2y%=FNwimp_worktoscreen(window%,point2y%,1)
4629     point3x%=FNwimp_worktoscreen(window%,point3x%,0)
4630     point3y%=FNwimp_worktoscreen(window%,point3y%,1)
4631 ENDIF
4632 MOVE point1x%,point1y%
4633 IF fill%=1 THEN
4634     MOVE point2x%,point2y%
4635     PLOT &55,point3x%,point3y%
4636 ELSE
4637     DRAW point2x%,point2y%
4638     DRAW point3x%,point3y%
4639     DRAW point1x%,point1y%
4640 ENDIF
4641 ENDPROC
4642 :
4643 DEF PROCwimp_increaseslot(n%)
4644 starthimem%=HIMEM
4645 END=HIMEM+n%
4646 new%=HIMEM
4647 IF HIMEM-starthimem%<n% THEN PROCwimp_error("","Failed to grab "+STR$n%+" bytes (only "+STR$(HIMEM-starthimem%)+" bytes grabbed). New WimpSlot size is "+STR$(INT((HIMEM-PAGE)/1024)+4)+"k.",1,2)
4648 ENDPROC
4649 :
4650 DEF PROCwimp_starttask(command$)
4651 SYS "Wimp_StartTask",command$
4652 ENDPROC
4653 :
4654 DEF PROCwimp_pause(seconds)
4655 LOCAL starttime%,endtime%
4656 seconds=ABS(seconds)
4657 SYS "OS_ReadMonotonicTime" TO starttime%
4658 REPEAT
4659     SYS "OS_ReadMonotonicTime" TO endtime%
4660 UNTIL endtime% > (starttime%+(seconds*100))
4661 ENDPROC
4662 :
4663 DEF FNwint_string(wptr%)
4664 LOCAL a$
4665 SYS "OS_WriteN",wptr%,0 TO a$
4666 =a$
4667 :
4668 DEF PROCwint_checkforload
4669 LOCAL a$,L%,i%,file$,p$,o%,ftype%,ftype$
4670 a$=wEnvstr$
4671 FOR L%=1 TO 3
4672     i%=INSTR(a$," ")
4673     a$=RIGHT$(a$,LEN(a$)-i%)
4674 NEXT L%
4675 IF a$<>"" THEN
4676     REPEAT
4677         i%=INSTR(a$," ")
4678         IF i%>0 THEN
4679             wStartupoption$+=LEFT$(a$,i%)
4680             a$=RIGHT$(a$,LEN(a$)-i%)
4681         ENDIF
4682     UNTIL i%=0
4683     IF a$<>"" THEN
4684         file$=FNwimp_getleafname(a$)
4685         p$=LEFT$(a$,LEN(a$)-LEN(file$))
4686         SYS "OS_File",21,file$,,,p$ TO o%,,,,,,ftype%
4687         IF o%=1 THEN
4688             ftype$=RIGHT$("00"+STR$~(ftype%),3)
4689             i%=FNuser_loaddata(a$,0,-1,ftype$,-1,-1)
4690         ENDIF
4691     ENDIF
4692 ENDIF
4693 ENDPROC
4694 :
4695 DEF PROCwint_desktopsave
4696 LOCAL string$
4697 LOCAL ERROR
4698 ON ERROR LOCAL wimp%!12=wimp%!8:SYS "Wimp_SendMessage",19,wimp%,wimp%!4:RESTORE ERROR:ENDPROC
4699 IF wDesktopsave%=TRUE THEN
4700     string$="Run "+wDesktopsave$+CHR$(10)
4701     SYS "XOS_GBPB",2,wimp%!20,string$,LEN(string$)
4702 ENDIF
4703 RESTORE ERROR
4704 ENDPROC
4705 :
4706 DEF PROCwint_iconise(desttask%,inref%,window%)
4707 LOCAL text$,spritename$
4708 IF window%<>0 THEN
4709     wICONISE%=TRUE
4710     PROCwimp_closewindow(window%)
4711     text$=FNwimp_getwindowtitle(window%)
4712     IF text$="" OR INSTR(text$,"untitled")>0 THEN
4713         text$=wappname$
4714     ENDIF
4715     spritename$=wappname$
4716     IF LEN(spritename$)>7 THEN
4717         spritename$=LEFT$(spritename$,7)
4718     ENDIF
4719     PROCuser_iconise(window%,text$,spritename$)
4720     IF LEN(spritename$)>7 THEN
4721         PROCwimp_error("","Your intended customised iconiser sprite name has more than 7 characters, so the Wimp will display a default icon instead.",1,1)
4722     ENDIF
4723     wimp%!0=256
4724     wimp%!12=inref%
4725     wimp%!16=&400CC
4726     wimp%!20=window%
4727     wimp%!24=0
4728     PROCwint_zeroterminate(wimp%+28,spritename$)
4729     PROCwint_zeroterminate(wimp%+36,text$)
4730     SYS "Wimp_SendMessage",17,wimp%,desttask%
4731 ENDIF
4732 ENDPROC
4733 :
4734 DEF FNwimp_osversion
4735 LOCAL mod%,a$,a%
4736 SYS "OS_Module",18,"UtilityModule" TO ,,,mod%
4737 mod%+=(mod%!&14)
4738 a$=FNwint_string(mod%)
4739 a$=MID$(a$,INSTR(a$,CHR$(9))+1)
4740 a$=MID$(a$,1,1)+MID$(a$,3,2)
4741 a%=VAL(a$)
4742 =a%
4743 :
4744 DEF PROCwint_scalefactors(xscalereal,yscalereal,RETURN xmult, RETURN ymult,RETURN xdiv,RETURN ydiv)
4745 LOCAL xi%,yi%,x$,y$,xii%,yii%
4746 xi%=xscalereal
4747 yi%=yscalereal
4748 x$=STR$xscalereal
4749 y$=STR$yscalereal
4750 xii%=INSTR(x$,".")
4751 yii%=INSTR(y$,".")
4752 x$=LEFT$(RIGHT$(x$,LEN(x$)-xii%),6)
4753 y$=LEFT$(RIGHT$(y$,LEN(y$)-yii%),6)
4754 IF xii%=0 THEN x$=""
4755 IF yii%=0 THEN y$=""
4756 xmult=VAL(STR$xi%+x$)
4757 ymult=VAL(STR$yi%+y$)
4758 xdiv=10^LEN(x$)
4759 ydiv=10^LEN(y$)
4760 ENDPROC
4761 :
4762 DEF FNwimp_loadjpegfile(jpegfilepath$,address%,warning%)
4763 =FNwimp_loadfile(jpegfilepath$,address%,warning%)
4764 :
4765 DEF PROCwimp_savejpeg(savepath$,jpeghandle%)
4766 PROCwimp_savefile(savepath$,jpeghandle%,&C85)
4767 ENDPROC
4768 :
4769 DEF FNwimp_getjpegsize(jpeghandle%,side%)
4770 LOCAL realsize%,realfile%
4771 LOCAL ro%,width%,height%,xden%,yden%,value%
4772 realsize%=jpeghandle%!0
4773 realfile%=jpeghandle%+4
4774 ro%=1
4775 SYS "JPEG_Info",ro%,realfile%,realsize% TO ,,width%,height%,xden%,yden%
4776 IF side%=0 THEN
4777     value%=FNwimp_lengthtoOS((width%/90),100,1)
4778 ELSE
4779     value%=FNwimp_lengthtoOS((height%/90),100,1)
4780 ENDIF
4781 =value%
4782 :
4783 DEF FNwimp_getjpegsizefile(jpegfilepath$,side%,warning%)
4784 LOCAL value%,ro%,width%,height%,xden%,yden%,f%,flag%
4785 value%=0
4786 ro%=1
4787 SYS "XJPEG_FileInfo",ro%,jpegfilepath$ TO ,,width%,height%,xden%,yden%;f%
4788 flag%=(f% AND 1)
4789 IF flag%=0 THEN
4790     IF side%=0 THEN
4791         value%=FNwimp_lengthtoOS((width%/90),100,1)
4792     ELSE
4793         value%=FNwimp_lengthtoOS((height%/90),100,1)
4794     ENDIF
4795 ELSE
4796     IF warning%<>0 THEN
4797         PROCwimp_error("","Sorry, a file called "+jpegfilepath$+" cannot be found. A size of 0 will be returned.",1,1)
4798     ENDIF
4799 ENDIF
4800 =value%
4801 :
4802 DEF PROCwimp_renderwindowjpeg(window%,jpeghandle%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal)
4803 IF wPrinting%=FALSE THEN
4804     bx%=FNwimp_worktoscreen(window%,bx%,0)
4805     by%=FNwimp_worktoscreen(window%,by%,1)
4806 ENDIF
4807 PROCwimp_renderjpeg(jpeghandle%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal)
4808 ENDPROC
4809 :
4810 DEF PROCwimp_renderjpeg(jpeghandle%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal)
4811 LOCAL realsize%,realfile%
4812 LOCAL xmult,ymult,xdiv,ydiv,r4%
4813 realsize%=jpeghandle%!0
4814 realfile%=jpeghandle%+4
4815 xmult=1
4816 ymult=1
4817 xdiv=1
4818 ydiv=1
4819 PROCwint_scalefactors(xscalereal,yscalereal,xmult,ymult,xdiv,ydiv)
4820 wScale%!0=xmult
4821 wScale%!4=ymult
4822 wScale%!8=xdiv
4823 wScale%!12=ydiv
4824 r4%=%11
4825 SYS "JPEG_PlotScaled",realfile%,bx%,by%,wScale%,realsize%,r4%
4826 ENDPROC
4827 :
4828 DEF PROCwimp_renderwindowjpegfile(window%,jpegfilepath$,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal,warning%)
4829 IF wPrinting%=FALSE THEN
4830     bx%=FNwimp_worktoscreen(window%,bx%,0)
4831     by%=FNwimp_worktoscreen(window%,by%,1)
4832 ENDIF
4833 PROCwimp_renderjpegfile(jpegfilepath$,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal,warning%)
4834 ENDPROC
4835 :
4836 DEF PROCwimp_renderjpegfile(jpegfilepath$,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal,warning%)
4837 LOCAL xmult,ymult,xdiv,ydiv,r4%,f%,flag%
4838 xmult=1
4839 ymult=1
4840 xdiv=1
4841 ydiv=1
4842 PROCwint_scalefactors(xscalereal,yscalereal,xmult,ymult,xdiv,ydiv)
4843 wScale%!0=xmult
4844 wScale%!4=ymult
4845 wScale%!8=xdiv
4846 wScale%!12=ydiv
4847 r4%=%11
4848 SYS "XJPEG_PlotFileScaled",jpegfilepath$,bx%,by%,wScale%,r4% TO ;f%
4849 flag%=(f% AND 1)
4850 IF (flag%=1) AND (warning%<>0) THEN
4851     PROCwimp_error("","Sorry, a file called "+jpegfilepath$+" cannot be found.",1,1)
4852 ENDIF
4853 ENDPROC
