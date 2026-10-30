1 REM>DrWimp
2 REM *** Version 5.04 ***
3 REM**  !!!! 18 Dynamic Areas !!!
4 REM © Andrew Ayre 1995-98
5 REM Major updates and additions by Guy Bartle
6 REM © Ray Favre - additions/changes 1999-2006
7 :
8 REM -------------------------------------------------------------------
9 REM Version 5.04 (23 Jan 2018) Bugfix submitted by Martin Avison
10 REM PROCwimp_closedown modified to deal with multiple finding of the
11 REM same font
12 :
13 REM mods by CAFJ - 20 Aug 2014
14 REM Added PROCwimp_getdfileWandH, PROCwimp_getjpegWandH
15 REM Corrected FNwimp_getdfilesize, PROCwint_receivedmess3or5
16 :
17 REM -------------------------------------------------------------------
18 REM Version 5.03 (10-Dec-2012) Bugfix by Chris Johnson
19 REM PROCwint_help did not check the length of the help message being
20 REM returned to the wimp, resulting in a crash if > 236 bytes. Fixed.
21 :
22 REM -------------------------------------------------------------------
23 REM Version 5.02 (01-Jan-2012) Updated by Chris Johnson
24 REM Corrected PROCwint_cleardynamicareas to treat the dynamic area
25 REM address as an unsigned integer, rather than a signed integer. Now
26 REM checks for (address <> 0) rather than (address > 0)
27 :
28 REM -------------------------------------------------------------------
29 REM Version 5.01 (27-Nov-11) Updated by Chris Johnson
30 REM
31 REM Functions involving calls to OS_GBPB 9 and 12 corrected
32 REM to follow the specification in the Programmer's Reference Manual
33 REM
34 REM Now works correctly with filing systems such as Fat32FS
35 REM which do not return an object offset simply incrementing
36 REM by 1 for each object found
37 REM
38 REM Added two new functions
39 REM
40 REM DEF FNwimp_getdirectoryobjectnamebyoffset(dir$,RETURN offset%)
41 REM DEF FNwimp_getdirectoryobjecttypebyoffset(dir$,RETURN offset%)
42 REM
43 REM Modified three functions
44 REM
45 REM DEF FNwimp_countdirectoryobjects(dir$)
46 REM DEF FNwimp_getdirectoryobjectname(dir$,objectnumber%)
47 REM DEF FNwimp_getdirectoryobjecttype(dir$,objectnumber%)
48 :
49 REM -------------------------------------------------------------------
50 REM
51 REM *** CONDITIONS OF USE ***
52 REM --------------------------------------------------------------------
53 REM The Dr Wimp package is distributed on an As Is basis, without
54 REM warranty. No liability can be accepted for any consequential loss or
55 REM damage, however caused, arising from the use of this package.
56 REM
57 REM The Dr Wimp package (apart from the 3rd party utilities as detailed in
58 REM the !!ReadMe!! file) may only be distributed as a whole. For
59 REM conditions of use of these 3rd party applications see their own !Help
60 REM files.
61 REM
62 REM Distribution of the Dr Wimp package (and programs constructed using
63 REM the DrWimp library) by third parties:
64 REM
65 REM Freeware. The DrWimp library may be distributed for free and without
66 REM the documentation, examples, utilities, etc. if it is being used as
67 REM part of a freeware product. (It would be nice if your documentation
68 REM acknowledged Dr Wimp - and don't forget that my web-site has a page
69 REM for links to your Dr Wimp applications, if you let me know .....)
70 REM
71 REM Shareware. Those using Dr Wimp to produce Shareware products must
72 REM donate 10% of the received income from these products to a charity of
73 REM their choice within 6 months of receiving the income. The Shareware
74 REM user-documentation must state prominently that this charity donation
75 REM is being made and also that Dr Wimp was used to produce the product.
76 REM The application's name and author should be notified to the Dr Wimp
77 REM copyright holder but no prior permission or further contact is needed.
78 REM
79 REM Commercial. If you wish to distribute the Dr Wimp package with a
80 REM commercial product (or distribute commercially a program that uses Dr
81 REM Wimp) then a specific licence is needed from the Dr Wimp copyright
82 REM holder.
83 REM
84 REM Public Domain libraries may make a reasonable charge for materials,
85 REM handling, etc. as long as this does not exceed £2.00 (UK) net for the
86 REM Dr Wimp package.
87 REM
88 REM The DrWimp library may be reproduced in part if crunching and mangling
89 REM utilities such as !BSquasher are used, otherwise it must be reproduced
90 REM in whole, complete with its opening REMs containing the Conditions of
91 REM Use and the copyright banner.
92 REM
93 REM If the DrWimp library is being reproduced in full then it may be added
94 REM to the !RunImage (or similar) file, and does not have to be separate.
95 REM
96 REM The author retains copyright of Dr Wimp, documentation and examples at
97 REM all times.
98 REM --------------------------------------------------------------------
99 REM You can download the latest version/upgrades from:
100 REM Web site: http://drwimp.riscos.org/dwapps.html
101 REM --------------------------------------------------------------------
102 SYS "OS_CLI","Echo "
103 SYS "OS_CLI","Echo "
104 SYS "OS_CLI","Echo "+CHR$160+" You've just double-clicked on the Dr Wimp Library"
105 SYS "OS_CLI","Echo "
106 SYS "OS_CLI","Echo "
107 SYS "OS_CLI","Echo "+STRING$(5,CHR$160)+" Version 5.04 (23-Jan-18) "+CHR$(169)+" Ray Favre"
108 SYS "OS_CLI","Echo "
109 SYS "OS_CLI","Echo "
110 END
111 :
112 DEF FNwimp_libversion
113 =(5.00)*100
114 :
115 DEF FNwimp_initialise(n$,wimpmem%,ver%,desktopsave%)
116 LOCAL L%,N%
117 DIM wMsgs% 3
118 wMsgs%!0=0
119 SYS "Wimp_Initialise",ver%,&4B534154,n$,wMsgs% TO wCurrWimpversion%,wTask%
120 wappname$=n$
121 werrtitle$=wappname$+" library"
122 IF wimpmem%<320 THEN wimpmem%=320
123 wCurrOSversion%=FNwimp_osversion
124 wMaxMessagefiles%=16
125 DIM wMessagehandles%(wMaxMessagefiles%,2)
126 FOR N%=1 TO wMaxMessagefiles%
127   wMessagehandles%(N%,0)=-1
128 NEXT
129 wMessagefilecount%=0
130 wMessageout%=-1
131 wTemplatefile$=""
132 DIM wFontbuf% 255
133 DIM wFontbuftemp% 255
134 FOR L%=0 TO 255
135   wFontbuf%?L%=0
136 NEXT L%
137 DIM wTransformtext% 23
138 DIM wBBox% 35
139 DIM wMouseblk% 9
140 DIM wTempblk% 319
141 DIM wTempblk2% 319
142 DIM wScale% 15
143 DIM wSprcoltrans% 299
144 DIM wDmatrix% 23
145 DIM wDbbox% 15
146 DIM wimp% (wimpmem%-1)
147 DIM wPrintblock% 39
148 IF wCurrOSversion%<ver% THEN PROCwimp_error("WIMP","You need RISC OS "+STR$(ver%/100)+" or better to run this application.",1,"",0,0,"Quit"):SYS "Wimp_CloseDown":END
149 wBARTEXT%=FALSE
150 wBANNER%=FALSE
151 NULL%=FALSE
152 wFinished%=FALSE
153 wQuitsender%=-1
154 wPrinting%=FALSE
155 UNUSED%=FALSE
156 wICONISE%=FALSE
157 wSavedrag%=-1
158 wSavew%=-1
159 wSavet$=""
160 wSlidedrag%=-1
161 wSlidew%=-1
162 wSlidei%=-1
163 wIcondrag%=-1
164 wIconw%=-1
165 wIconi%=-1
166 wStartx%=0
167 wStarty%=0
168 wDragbutton%=0
169 wOx%=0
170 wOy%=0
171 wLen%=0
172 wLen2%=0
173 wSwid%=0
174 wShei%=0
175 wToPrinter%=0
176 wPrintFile$=""
177 wPrintFileType%=0
178 wDeleteFile%=0
179 wMaxdynamicareas%=18:REM** Custom change for Calibre **
180 DIM wDynamicarea%(wMaxdynamicareas%+1,1)
181 wDynamics%=0
182 wShutdown%=0
183 wMenuicon%=0
184 wHoldwhan%=0
185 wDesktopsave$=FNwimp_getsysvariable("Obey$Dir")
186 IF desktopsave%=0 THEN wDesktopsave%=FALSE ELSE wDesktopsave%=TRUE
187 wSubmenu%=1
188 wColourblock%=-1
189 wPickerhandle%=0
190 wPickerwindow%=0
191 wSUBMENUCOLOURPICKER%=4
192 wColourdrag%=FALSE
193 wDirbuffer%=-1
194 wFONTMENU%=-1
195 wHeldmenu%=0
196 wFontmenubuflen%=255
197 wFontmenudepth%=0
198 wMaxdepth%=5
199 DIM wMenutree%(wMaxdepth%)
200 FOR N%=0 TO wMaxdepth%
201   wMenutree%(N%)=-1
202 NEXT
203 wConvert%=0
204 wDimsize%=36
205 wDateblk%=0
206 wStartupoption$=""
207 SYS "OS_GetEnv" TO wEnvstr$
208 wStartupfile$=FNwint_extractfiletoloadandstartupoptions(wEnvstr$)
209 PROCuser_initialise
210 IF wTemplatefile$<>"" THEN SYS "Wimp_CloseTemplate"
211 wTemplatefile$=""
212 PROCwint_checkforload(wStartupfile$)
213 =wTask%
214 :
215 DEF PROCwimp_error(title$,error$,from%,spritename$,spritearea%,button%,altbutton$)
216 LOCAL pre$,comma%,type%,flags%
217 IF from%>2 OR from%<0 THEN from%=0
218 pre$=""
219 IF from%=1 THEN pre$="Error from "
220 IF from%=2 THEN pre$="Message from "
221 IF title$="" THEN title$=wappname$
222 IF button%>2 OR button%<1 THEN button%=0
223 IF button%=0 THEN continue%=0:cancel%=0
224 IF button%=1 THEN continue%=1:cancel%=0
225 IF button%=2 THEN continue%=0:cancel%=1
226 IF altbutton$<>"" THEN
227   comma%=INSTR(altbutton$,",")
228   IF comma%>0 THEN
229     altbutton$=LEFT$(altbutton$,comma%-1)
230   ENDIF
231 ENDIF
232 IF altbutton$<>"" THEN continue%=0:cancel%=0
233 type%=2
234 flags%=continue%+(cancel%<<1)+(0<<2)+(0<<3)+(1<<4)+(1<<8)+(type%<<9)
235 wimp%!0=0
236 $(wimp%+4)=error$
237 IF altbutton$="" THEN
238   SYS "Wimp_ReportError",wimp%,flags%,pre$+title$,spritename$,spritearea%,0
239 ELSE
240   SYS "Wimp_ReportError",wimp%,flags%,pre$+title$,spritename$,spritearea%,altbutton$
241 ENDIF
242 ENDPROC
243 :
244 DEF FNwimp_errorchoice(title$,error$,from%,type%,spritename$,spritearea%,continue%,cancel%,extrabutton$)
245 LOCAL return%,pre$,flags%
246 return%=0
247 IF from%>2 OR from%<0 THEN from%=0
248 pre$=""
249 IF from%=1 THEN pre$="Error from "
250 IF from%=2 THEN pre$="Message from "
251 IF title$="" THEN title$=wappname$
252 IF type%>4 OR type%<1 THEN type%=2
253 IF continue%<>0 THEN continue%=1
254 IF cancel%<>0 THEN cancel%=1
255 flags%=continue%+(cancel%<<1)+(0<<2)+(0<<3)+(1<<4)+(1<<8)+(type%<<9)
256 wimp%!0=0
257 $(wimp%+4)=error$
258 IF extrabutton$="" THEN
259   SYS "Wimp_ReportError",wimp%,flags%,pre$+title$,spritename$,spritearea%,0 TO ,return%
260 ELSE
261   SYS "Wimp_ReportError",wimp%,flags%,pre$+title$,spritename$,spritearea%,extrabutton$ TO ,return%
262 ENDIF
263 =return%
264 :
265 DEF PROCwimp_poll
266 LOCAL reason%,mask%
267 wFinished%=FALSE
268 REPEAT
269   IF NULL%=FALSE AND wSlidedrag%=-1 AND wIcondrag%=-1 AND wBANNER%=FALSE THEN
270     mask%=1
271   ELSE
272     mask%=0
273   ENDIF
274   SYS "Wimp_Poll",mask%,wimp% TO reason%,wimp%
275   PROCwint_reasoncodes(reason%)
276 UNTIL wFinished%=TRUE
277 PROCwimp_closedown
278 ENDPROC
279 :
280 DEF PROCwint_reasoncodes(reason%)
281 CASE reason% OF
282   WHEN 0 : PROCwint_pollnull
283   WHEN 1 : PROCwint_pollredrawwindow(wimp%!0)
284   WHEN 2 : PROCwint_pollopenwindow(wimp%!0)
285   WHEN 3 : PROCwint_pollclosewindow(wimp%!0)
286   WHEN 4 : PROCuser_leavingwindow(wimp%!0)
287   WHEN 5 : PROCuser_enteringwindow(wimp%!0)
288   WHEN 6 : PROCwint_pollmouseclick(wimp%!12,wimp%!16,wimp%!8,wimp%!0,wimp%!4)
289   WHEN 7 : PROCwint_pollendofdrag(wimp%!0,wimp%!4,wimp%!8,wimp%!12)
290   WHEN 8 : PROCwint_pollkeypress(wimp%!0,wimp%!4,wimp%!24)
291   WHEN 9 : PROCwint_pollmenuselection
292   WHEN 10
293   WHEN 11
294   WHEN 12
295   WHEN 13
296   WHEN 14
297   WHEN 15
298   WHEN 16
299   WHEN 17,18 : PROCwint_pollmessage(wimp%!16,reason%)
300   WHEN 19 : IF UNUSED%=TRUE THEN PROCuser_wimpmessage(wimp%!16,wimp%,reason%)
301 ENDCASE
302 ENDPROC
303 :
304 DEF PROCwint_pollnull
305 LOCAL time%
306 IF NULL%=TRUE THEN PROCuser_null
307 IF wSlidedrag%<>-1 PROCwint_draggingslider
308 IF wIcondrag%<>-1 PROCwint_draggingicon
309 IF wBANNER%=TRUE THEN
310   SYS "OS_ReadMonotonicTime" TO time%
311   IF time%>wDelaymax% THEN
312     PROCwimp_closewindow(wBanner%)
313     wBANNER%=FALSE
314   ENDIF
315 ENDIF
316 ENDPROC
317 :
318 DEF PROCwint_pollredrawwindow(whan%)
319 LOCAL flag%
320 IF whan%<>wPickerwindow% THEN
321   SYS "Wimp_RedrawWindow",,wimp% TO flag%
322   WHILE flag%
323     PROCwint_savewimp
324     PROCuser_redraw(wimp%!0,wimp%!28,wimp%!32,wimp%!36,wimp%!40,FALSE,0)
325     PROCwint_loadwimp
326     SYS "Wimp_GetRectangle",,wimp% TO flag%
327   ENDWHILE
328 ENDIF
329 ENDPROC
330 :
331 DEF PROCwint_pollopenwindow(whan%)
332 IF whan%<>wPickerwindow% THEN
333   IF wICONISE%=FALSE THEN
334     IF FNuser_pane(whan%)=-1 THEN
335       SYS "Wimp_OpenWindow",,wimp%
336     ELSE
337       PROCwint_windowhaspane
338     ENDIF
339     PROCwint_checkuserpane(whan%,wimp%)
340     PROCwint_checksavewindow(whan%)
341   ENDIF
342   wICONISE%=FALSE
343 ENDIF
344 ENDPROC
345 :
346 DEF PROCwint_windowhaspane
347 LOCAL cstack%
348 IF wimp%!28<>-1 THEN
349   SYS "Wimp_OpenWindow",,wimp%
350 ELSE
351   wimp%!128=wimp%!0
352   SYS "Wimp_GetWindowState",,wimp%+128
353   cstack%=wimp%!(128+28)
354   wimp%!28=cstack%
355   SYS "Wimp_OpenWindow",,wimp%
356   wimp%!28=-1
357 ENDIF
358 ENDPROC
359 :
360 DEF PROCwint_pollclosewindow(whan%)
361 PROCwint_savewimp
362 IF FNuser_preclosewindow(whan%)=1 THEN
363   PROCwint_loadwimp
364   SYS "Wimp_CloseWindow",,wimp%
365   PROCuser_closewindow(whan%)
366 ENDIF
367 ENDPROC
368 :
369 DEF PROCwint_pollmouseclick(whan%,icon%,button%,mousex%,mousey%)
370 LOCAL done%,s%,drag%,write%,ok%,x%,y%
371 wColourdrag%=FALSE
372 IF whan%=wPickerwindow% THEN
373   wColourdrag%=TRUE
374 ELSE
375   done%=0
376   IF (button%=64 OR button%=16) AND (icon%>-1) THEN
377     PROCwint_startdrag(whan%,icon%,button%,mousex%,mousey%)
378     done%=1
379   ENDIF
380   IF done%<>1 THEN
381     IF FNuser_sliderback(whan%,icon%)<>-1 THEN
382       PROCwint_clickedslider(whan%,icon%,mousex%,mousey%)
383       done%=1
384     ENDIF
385   ENDIF
386   IF done%<>1 THEN
387     s%=FNuser_slider(whan%,icon%)
388     IF s%<>-1 THEN
389       PROCwint_clickedslider(whan%,s%,mousex%,mousey%)
390       done%=1
391     ENDIF
392   ENDIF
393   IF done%<>1 THEN
394     IF button%<>2 AND FNuser_savefiletype(whan%)<>"" THEN
395       drag%=0:write%=1:ok%=2
396       PROCuser_saveicon(whan%,drag%,write%,ok%)
397       IF icon%=ok% THEN
398         PROCwint_quicksave(whan%,write%)
399         done%=1
400       ENDIF
401     ENDIF
402   ENDIF
403   IF done%<>1 THEN
404     IF button%<>2 THEN
405       x%=FNwimp_screentowork(whan%,mousex%,0)
406       y%=FNwimp_screentowork(whan%,mousey%,1)
407       PROCuser_mouseclick(whan%,icon%,button%,x%,y%)
408     ELSE
409       PROCwint_menuclick(whan%,icon%,mousex%,mousey%)
410     ENDIF
411   ENDIF
412 ENDIF
413 ENDPROC
414 :
415 DEF PROCwint_menuclick(whan%,icon%,mousex%,mousey%)
416 LOCAL menu%,yalt%
417 wHoldwhan%=0
418 menu%=FNuser_menu(whan%,icon%,mousex%,mousey%)
419 IF menu%<>0 THEN
420   wHoldwhan%=whan%
421   IF (menu% AND 1)=0 THEN
422     IF !(menu%-4)=-1 THEN wFONTMENU%=menu%
423   ENDIF
424   wMenuicon%=icon%
425   CASE whan% OF
426     WHEN -2
427     yalt%=FNwint_iconbardottedlinemenusize(menu%)
428     PROCuser_menuopen(menu%,wHoldwhan%,wMenuicon%)
429     SYS "Wimp_CreateMenu",,menu%,mousex%-64,yalt%
430     OTHERWISE
431     PROCuser_menuopen(menu%,wHoldwhan%,wMenuicon%)
432     SYS "Wimp_CreateMenu",,menu%,mousex%-64,mousey%
433   ENDCASE
434   PROCwint_checksavewindow(menu%)
435   wLastmenu%=menu%
436 ENDIF
437 ENDPROC
438 :
439 DEF FNwint_iconbardottedlinemenusize(menu%)
440 LOCAL menusize%,menuposy%,item%,startbyte%,dottedline%
441 menusize%=FNwimp_menusize(menu%)
442 menuposy%=(menusize%*44)+96
443 FOR item%=1 TO menusize%
444   startbyte%=menu%+28+(24*(item%-1))
445   dottedline%=((?startbyte%>>1) AND 1)
446   IF dottedline%=1 THEN
447     menuposy%+=24
448   ENDIF
449 NEXT
450 =menuposy%
451 :
452 DEF PROCwint_pollendofdrag(dragboxminx%,dragboxminy%,dragboxmaxx%,dragboxmaxy%)
453 IF wColourdrag%=TRUE THEN
454   wColourdrag%=FALSE
455 ELSE
456   IF wSavedrag%=-1 THEN
457     IF wSlidedrag%<>-1 THEN
458       PROCwint_endsliderdrag
459     ELSE
460       PROCwint_endicondrag(dragboxminx%,dragboxminy%,dragboxmaxx%,dragboxmaxy%)
461     ENDIF
462   ELSE
463     PROCwint_endsavedrag
464   ENDIF
465 ENDIF
466 ENDPROC
467 :
468 DEF PROCwint_pollkeypress(whan%,icon%,key%)
469 LOCAL done%,drag%,write%,ok%
470 IF whan%<>wPickerwindow% THEN
471   done%=0
472   IF FNuser_savefiletype(whan%)<>"" AND key%=13 THEN
473     drag%=0:write%=1:ok%=2
474     PROCuser_saveicon(whan%,drag%,write%,ok%)
475     IF icon%=write% THEN
476       PROCwint_quicksave(whan%,write%)
477       done%=1
478     ENDIF
479   ENDIF
480   IF done%<>1 THEN
481     PROCwint_savewimp
482     done%=FNuser_keypress(whan%,icon%,key%)
483     PROCwint_loadwimp
484     IF done%=0 THEN SYS "Wimp_ProcessKey",key%
485   ENDIF
486 ENDIF
487 ENDPROC
488 :
489 DEF PROCwint_pollmenuselection
490 LOCAL font$,fontname%,FontDecode%,A%,N%,Slash%,selection%,menu%,item%
491 IF wLastmenu%<>wHeldmenu% AND wHeldmenu%<>0 THEN
492   FOR N%=0 TO wMaxdepth%
493     wMenutree%(N%)=-1
494   NEXT
495 ENDIF
496 font$=""
497 FontDecode%=FALSE
498 CASE TRUE OF
499   WHEN (wLastmenu%=wFONTMENU%)
500   wFontmenudepth%=0
501   FontDecode%=TRUE
502   WHEN (wFontmenudepth%>0)
503   FontDecode%=TRUE
504   IF wReopened%=TRUE THEN
505     FontDecode%=FNwint_fontmenutree
506   ELSE
507     FontDecode%=FNwint_fontmenuused
508   ENDIF
509   IF FontDecode%=TRUE THEN
510     FOR N%=1 TO wFontmenudepth%
511       wMenutree%(N%) = !(wimp%+4*(N%-1))
512     NEXT
513   ENDIF
514 ENDCASE
515 menu%=0:item%=0
516 IF FontDecode%=TRUE THEN
517   DIM fontname% wFontmenubuflen%-1
518   IF font$<>"" THEN
519     FOR A%=0 TO wFontmenubuflen%-1
520       fontname%?A%=0
521     NEXT
522   ENDIF
523   selection%=wimp%+(4*wFontmenudepth%)
524   SYS "Font_DecodeMenu",0,wFONTMENU%,selection%,fontname%,wFontmenubuflen%
525   font$=FNwint_string(fontname%)
526   font$=RIGHT$(font$,LEN(font$)-2)
527   Slash%=INSTR(font$,"\")
528   IF Slash%>0 THEN font$=LEFT$(font$,Slash%-1)
529   menu%=wFONTMENU%
530 ELSE
531   PROCwint_getmenuanditem(wLastmenu%,menu%,item%)
532   font$=""
533 ENDIF
534 PROCuser_menuselection(menu%,item%,font$)
535 SYS "Wimp_GetPointerInfo",,wimp%
536 IF wimp%!8=1 THEN
537   PROCwint_savewimp
538   PROCuser_menuopen(wLastmenu%,wHoldwhan%,wMenuicon%)
539   PROCwint_loadwimp
540   SYS "Wimp_CreateMenu",,wLastmenu%,wimp%!0-64,wimp%!4+20
541   wReopened%=TRUE
542   wHeldmenu%=wLastmenu%
543 ELSE
544   wFontmenudepth%=0
545   wHeldmenu%=0
546   FOR N%=0 TO wMaxdepth%
547     wMenutree%(N%)=-1
548   NEXT
549 ENDIF
550 ENDPROC
551 :
552 DEF PROCwint_pollmessage(actioncode%,reasoncode%)
553 CASE actioncode% OF
554   WHEN 0      : wFinished%=TRUE
555   WHEN 1      : PROCwint_receivedmess1(wimp%!4,wimp%!8,wimp%!20,wimp%!24,wimp%!28,wimp%!32,wimp%!36,wimp%!40)
556   WHEN 2      : PROCwint_receivedmess2(wimp%!4,wimp%!8,wimp%!20,wimp%!24,wimp%!28,wimp%!32,wimp%+44)
557   WHEN 3,5    : PROCwint_receivedmess3or5(actioncode%,wimp%!4,wimp%!8,wimp%!20,wimp%!24,wimp%!28,wimp%!32,wimp%!36,wimp%!40,wimp%+44)
558   WHEN 4      : PROCwint_receivedmess4
559   WHEN 8      : PROCwint_prequitissued
560   WHEN 10     : PROCwint_desktopsave
561   WHEN &502   : PROCwint_help(wimp%!4,wimp%!8,wimp%!32,wimp%!36,wimp%!20,wimp%!24,wimp%!28)
562   WHEN &400C0 : PROCwint_opensubmenu(wimp%!20,wimp%!24,wimp%!28,wimp%!32)
563   WHEN &400C1 : PROCuser_modechange
564   WHEN &400CC : PROCwint_iconise(wimp%!4,wimp%!8,wimp%!20)
565   WHEN &47700 : PROCwint_colourpickerchoice(wimp%!36)
566   WHEN &47702 : PROCwint_closecolourpicker(wimp%!20)
567   WHEN &80147 : PROCuser_printerchange
568   OTHERWISE
569   IF UNUSED%=TRUE THEN PROCuser_wimpmessage(actioncode%,wimp%,reasoncode%)
570 ENDCASE
571 ENDPROC
572 :
573 DEF PROCwimp_pollidle(durationreal,sec%)
574 LOCAL centisecs%,reason%,oldtime%,newtime%
575 IF sec%=0 THEN centisecs%=ABS(durationreal) ELSE centisecs%=ABS(durationreal*100)
576 wFinished%=FALSE
577 SYS "OS_ReadMonotonicTime" TO oldtime%
578 REPEAT
579   SYS "Wimp_PollIdle",0,wimp%,oldtime% TO reason%,wimp%
580   PROCwint_reasoncodes(reason%)
581   SYS "OS_ReadMonotonicTime" TO newtime%
582   WHILE (newtime%-oldtime%)>=0
583     oldtime%=oldtime%+centisecs%
584   ENDWHILE
585 UNTIL wFinished%=TRUE
586 PROCwimp_closedown
587 ENDPROC
588 :
589 DEF PROCwimp_singlepoll
590 LOCAL reason%
591 SYS "Wimp_Poll",0,wimp% TO reason%,wimp%
592 PROCwint_reasoncodes(reason%)
593 IF wFinished%=TRUE THEN
594   PROCwimp_closedown
595 ENDIF
596 ENDPROC
597 :
598 DEF PROCwimp_singlepollidle(durationreal,sec%)
599 LOCAL centisecs%,reason%,starttime%,currtime%
600 IF sec%=0 THEN centisecs%=ABS(durationreal) ELSE centisecs%=ABS(durationreal*100)
601 SYS "OS_ReadMonotonicTime" TO starttime%
602 REPEAT
603   SYS "Wimp_PollIdle",0,wimp%,starttime%+centisecs% TO reason%,wimp%
604   PROCwint_reasoncodes(reason%)
605   IF wFinished%=TRUE THEN
606     PROCwimp_closedown
607   ENDIF
608   SYS "OS_ReadMonotonicTime" TO currtime%
609 UNTIL currtime%>=starttime%+centisecs%
610 ENDPROC
611 :
612 DEF PROCwimp_quit(type%)
613 IF type%=1 THEN
614   IF wQuitsender%=-1 THEN
615     PROCwimp_error(werrtitle$,"Sorry, but 'PROCwimp_quit(type%)' has been called with 'type%' set to 1 in the wrong circumstances. Please refer to the Dr Wimp Manual.",1,"",0,1,"")
616   ELSE
617     PROCwint_savewimp
618     SYS "Wimp_GetCaretPosition",,wimp%
619     wimp%!24=&1FC
620     SYS "Wimp_SendMessage",8,wimp%,wQuitsender%
621     PROCwint_loadwimp
622     wQuitsender%=-1
623   ENDIF
624 ELSE
625   IF FNuser_quit(0)=1 THEN
626     wFinished%=TRUE
627   ENDIF
628 ENDIF
629 ENDPROC
630 :
631 DEF PROCwint_prequitissued
632 LOCAL justthistask%,type%
633 PROCwint_savewimp
634 justthistask%=(wimp%!20 AND 1)
635 type%=1-justthistask%
636 IF FNuser_quit(type%)=0 THEN
637   PROCwint_loadwimp
638   wQuitsender%=wimp%!4
639   wimp%!12=wimp%!8
640   SYS "Wimp_SendMessage",19,wimp%
641 ENDIF
642 ENDPROC
643 :
644 DEF PROCwimp_closedown
645 LOCAL L%
646 FOR L%=0 TO 255
647   WHILE wFontbuf%?L%
648     SYS "Font_LoseFont",L%
649     wFontbuf%?L% -= 1
650   ENDWHILE
651 NEXT L%
652 PROCwint_cleardynamicareas
653 PROCwint_closemessagefiles
654 IF wTemplatefile$<>"" THEN SYS "Wimp_CloseTemplate"
655 PROCwimp_hourglassoff
656 SYS "Wimp_CloseDown"
657 ENDPROC
658 :
659 DEF FNwimp_loadwindow(file$,win$,sprflag%)
660 LOCAL name%,whan%,icons%,L%,ic%,ind%,spr%,txt%,icondata%,iconsize%,namecheck%
661 DIM name% 11
662 FOR L%=0 TO 255
663   wFontbuftemp%?L%=0
664 NEXT L%
665 IF file$<>wTemplatefile$ THEN
666   IF wTemplatefile$<>"" THEN
667     SYS "Wimp_CloseTemplate"
668   ENDIF
669   SYS "Wimp_OpenTemplate",,file$
670   wTemplatefile$=file$
671 ENDIF
672 whan%=0
673 $name%=win$
674 SYS "Wimp_LoadTemplate",,0,0,0,wFontbuf%,name%,0 TO ,,iconsize%,,,,namecheck%
675 IF namecheck%>0 THEN
676   DIM icondata% iconsize%-1
677   SYS "Wimp_LoadTemplate",,wimp%,icondata%,icondata%+iconsize%,wFontbuftemp%,name%,0 TO ,,icondata%
678   FOR L%=0 TO 255
679     IF wFontbuftemp%?L% THEN wFontbuf%?L%+=1
680   NEXT L%
681   IF sprflag%=0 THEN
682     wimp%!64=1
683   ELSE
684     wimp%!64=sprflag%
685     icons%=wimp%!84
686     IF icons%>0 THEN
687       FOR L%=1 TO icons%
688         ic%=wimp%+((L%-1)*32)+88
689         ind%=((ic%!16)>>8) AND 1
690         spr%=((ic%!16)>>1) AND 1
691         txt%=(ic%!16) AND 1
692         IF ind%=1 AND spr%=1 AND txt%=0 THEN
693           IF (ic%!28)<>0 ic%!24=sprflag%
694         ENDIF
695       NEXT L%
696     ENDIF
697   ENDIF
698   SYS "Wimp_CreateWindow",,wimp% TO whan%
699 ENDIF
700 =whan%
701 :
702 DEF PROCwimp_openwindow(whan%,centre%,stack%)
703 IF centre%<0 OR centre%>2 THEN centre%=0
704 wimp%!0=whan%
705 SYS "Wimp_GetWindowState",,wimp%
706 IF stack%=-3 THEN stack%=wimp%!28
707 IF stack%=-4 THEN stack%=-3
708 IF centre%=1 THEN PROCwint_centrewindow
709 IF centre%=2 THEN PROCwint_pointercentrewindow(whan%)
710 wimp%!28=stack%
711 SYS "Wimp_OpenWindow",,wimp%
712 PROCwint_checkuserpane(whan%,wimp%)
713 PROCwint_checksavewindow(whan%)
714 ENDPROC
715 :
716 DEF PROCwimp_openwindowat(whan%,x%,y%,stack%)
717 LOCAL width%,height%
718 wimp%!0=whan%
719 SYS "Wimp_GetWindowState",,wimp%
720 IF stack%=-3 THEN stack%=wimp%!28
721 IF stack%=-4 THEN stack%=-3
722 width%=wimp%!12-wimp%!4
723 height%=wimp%!16-wimp%!8
724 wimp%!4=x%
725 wimp%!8=y%-height%
726 wimp%!12=x%+width%
727 wimp%!16=y%
728 wimp%!28=stack%
729 SYS "Wimp_OpenWindow",,wimp%
730 PROCwint_checkuserpane(whan%,wimp%)
731 PROCwint_checksavewindow(whan%)
732 ENDPROC
733 :
734 DEF PROCwimp_redrawwindow(whan%)
735 SYS "Wimp_ForceRedraw",whan%,-1E6,-1E6,1E6,1E6
736 ENDPROC
737 :
738 DEF PROCwimp_updatewindow(whan%,minx%,miny%,maxx%,maxy%)
739 SYS "Wimp_ForceRedraw",whan%,minx%,miny%,maxx%,maxy%
740 ENDPROC
741 :
742 DEF FNwimp_iswindowopen(whan%)
743 wimp%!0=whan%
744 SYS "Wimp_GetWindowState",,wimp%
745 =(((wimp%!32>>16) AND 1)=1)
746 :
747 DEF PROCwimp_closewindow(whan%)
748 IF FNuser_preclosewindow(whan%)=1 THEN
749   wimp%!0=whan%
750   SYS "Wimp_CloseWindow",,wimp%
751   PROCuser_closewindow(whan%)
752 ENDIF
753 ENDPROC
754 :
755 DEF FNwimp_getwindowvisiblesize(whan%,side%)
756 LOCAL return%
757 return%=0
758 IF side%<>0 THEN side%=1
759 wimp%!0=whan%
760 SYS "Wimp_GetWindowState",,wimp%
761 return%=wimp%!(side%*4+12)-wimp%!(side%*4+4)
762 =return%
763 :
764 DEF FNwimp_getwindowworksize(whan%,side%)
765 LOCAL return%
766 IF side%<>0 THEN side%=1
767 wimp%!0=whan%
768 SYS "Wimp_GetWindowInfo",,(wimp% OR %1)
769 return%=wimp%!(side%*4+52)-wimp%!(side%*4+44)
770 =return%
771 :
772 DEF FNwimp_getwindowvisiblework(whan%,side%,end%)
773 LOCAL result%
774 IF end%<>0 THEN end%=1
775 IF side%<>0 THEN side%=1
776 wimp%!0=whan%
777 SYS "Wimp_GetWindowState",,wimp%
778 result%=FNwimp_screentowork(whan%,wimp%!(end%*8+side%*4+4),side%)
779 =result%
780 :
781 DEF FNwimp_getwindowvisiblescreen(whan%,side%,end%)
782 LOCAL result%
783 IF end%<>0 THEN end%=1
784 IF side%<>0 THEN side%=1
785 wimp%!0=whan%
786 SYS "Wimp_GetWindowState",,wimp%
787 result%=wimp%!(end%*8+side%*4+4)
788 =result%
789 :
790 DEF PROCwimp_resizewindow(whan%,width%,height%)
791 LOCAL flags%,op%
792 wimp%!0=0:wimp%!4=-height%:wimp%!8=width%:wimp%!12=0
793 SYS "Wimp_SetExtent",whan%,wimp%
794 wimp%!0=whan%
795 SYS "Wimp_GetWindowState",,wimp%
796 flags%=wimp%!32
797 op%=(flags%>>16) AND 1
798 IF op%=0 THEN wimp%!28=-3
799 SYS "Wimp_OpenWindow",,wimp%
800 IF op%=0 THEN
801   wimp%!0=whan%
802   SYS "Wimp_CloseWindow",,wimp%
803 ENDIF
804 ENDPROC
805 :
806 DEF PROCwimp_resizewindowvisible(whan%,width%,height%)
807 LOCAL flags%,open%
808 wimp%!0=whan%
809 SYS "Wimp_GetWindowInfo",,wimp% OR 1
810 SYS "Wimp_SetExtent",whan%,wimp%+44
811 wimp%!0=whan%
812 SYS "Wimp_GetWindowState",,wimp%
813 wimp%!8=wimp%!16-height%
814 wimp%!12=wimp%!4+width%
815 flags%=wimp%!32
816 open%=(flags%>>16) AND 1
817 IF open%=0 THEN wimp%!28=-3
818 SYS "Wimp_OpenWindow",,wimp%
819 IF open%=0 THEN
820   wimp%!0=whan%
821   SYS "Wimp_CloseWindow",,wimp%
822 ELSE
823   PROCwint_checkuserpane(whan%,wimp%)
824 ENDIF
825 ENDPROC
826 :
827 DEF FNwimp_getwindowtitle(whan%)
828 LOCAL return$,titlebar%,titletext%,indirected%
829 return$=""
830 wimp%!0=whan%
831 SYS "Wimp_GetWindowInfo",,(wimp% OR %1)
832 titlebar%=((wimp%!32>>26) AND 1)
833 IF titlebar%=1 THEN
834   titletext%=(wimp%!60 AND 1)
835   IF titletext%=1 THEN
836     indirected%=((wimp%!60>>8) AND 1)
837     IF indirected%=1 THEN
838       return$=FNwint_string(wimp%!76)
839     ELSE
840       return$=FNwint_string(wimp%+76)
841     ENDIF
842   ENDIF
843 ENDIF
844 =return$
845 :
846 DEF PROCwimp_putwindowtitle(whan%,text$)
847 LOCAL flag%,width%,height%,xmin%,ymin%
848 wimp%!0=whan%
849 SYS "Wimp_GetWindowInfo",,(wimp% OR %1)
850 flag%=wimp%!60
851 flag%=(flag%>>8)
852 IF (flag% AND 1)=0 THEN
853   PROCwimp_error(werrtitle$,"Window title is not indirected",1,"",0,1,"")
854 ELSE
855   $(wimp%!76)=text$
856   PROCwint_redrawtitle(whan%)
857 ENDIF
858 ENDPROC
859 :
860 DEF PROCwint_redrawtitle(window%)
861 LOCAL a%,b%,c%,d%,e%,f%
862 IF wCurrOSversion%>=380 THEN
863   SYS "Wimp_ForceRedraw",window%,&4B534154,3
864 ELSE
865   SYS "Wimp_GetCaretPosition",,wimp%
866   a%=wimp%!0:b%=wimp%!4:c%=wimp%!8:d%=wimp%!12:e%=wimp%!16:f%=wimp%!20
867   IF a%=window% THEN window%=-1
868   SYS "XWimp_SetCaretPosition",window%,-1,,,-1
869   SYS "Wimp_SetCaretPosition",a%,b%,c%,d%,e%,f%
870 ENDIF
871 ENDPROC
872 :
873 DEF PROCwimp_scroll(whan%,side%,direction%,distance%)
874 LOCAL cstack%
875 wimp%!0=whan%
876 SYS "Wimp_GetWindowInfo",,(wimp% OR %1)
877 CASE side% OF
878   WHEN 0
879   CASE direction% OF
880     WHEN 0 : IF (wimp%!20-distance%)<wimp%!44 THEN wimp%!20=wimp%!44 ELSE wimp%!20=(wimp%!20-distance%)
881     OTHERWISE : IF (wimp%!20+distance%)>wimp%!52 THEN wimp%!20=wimp%!52 ELSE wimp%!20=(wimp%!20+distance%)
882   ENDCASE
883   OTHERWISE
884   CASE direction% OF
885     WHEN 0 : IF (wimp%!24-distance%)<wimp%!48 THEN wimp%!24=wimp%!48 ELSE wimp%!24=(wimp%!24-distance%)
886     OTHERWISE : IF (wimp%!24+distance%)>wimp%!56 THEN wimp%!24=wimp%!56 ELSE wimp%!24=(wimp%!24+distance%)
887   ENDCASE
888 ENDCASE
889 IF ((wimp%!32 >> 16) AND 1)=1 THEN
890   SYS "Wimp_OpenWindow",,wimp%
891 ELSE
892   SYS "Wimp_OpenWindow",,wimp%
893   SYS "Wimp_CloseWindow",,wimp%
894 ENDIF
895 ENDPROC
896 :
897 DEF FNwimp_getscroll(whan%,side%)
898 LOCAL return%
899 IF side%<>0 THEN side%=1
900 wimp%!0=whan%
901 SYS "Wimp_GetWindowState",,wimp%
902 return%=wimp%!(side%*4+20)
903 =return%
904 :
905 DEF PROCwimp_scrollto(whan%,side%,scrollpos%)
906 IF side%<>0 THEN side%=1
907 wimp%!0=whan%
908 SYS "Wimp_GetWindowState",,wimp%
909 wimp%!(side%*4+20)=scrollpos%
910 SYS "Wimp_OpenWindow",,wimp%
911 IF ((wimp%!32 >> 16) AND 1)=0 THEN
912   SYS "Wimp_CloseWindow",,wimp%
913 ENDIF
914 ENDPROC
915 :
916 DEF PROCwimp_banner(whan%,delay%)
917 LOCAL time%
918 delay%=ABS(delay%)
919 PROCwimp_openwindow(whan%,1,-1)
920 wBANNER%=TRUE
921 SYS "OS_ReadMonotonicTime" TO time%
922 wDelaymax%=(delay%*100)+time%
923 wBanner%=whan%
924 ENDPROC
925 :
926 DEF FNwimp_createwindow(vminx%,vminy%,vmaxx%,vmaxy%,wminx%,wminy%,wmaxx%,wmaxy%,flags%,colourflags%,wbuttontype%,title$,titleflags%,titlefont%,maxind%,spritearea%)
927 LOCAL error$,wflags%,tflags%,len%,name%,whan%,tind%,bits%,wshift%,N%
928 IF ((titleflags%>>4 AND 1)=1) AND (wFontbuf%?titlefont%=0) THEN
929   error$="For creating the window with the title "+CHR$(34)+CHR$(160)+title$+CHR$(160)+CHR$(34)+" bit 4 of 'titleflags%' is set but the font handle in 'titlefont%' is invalid. The window will now be created as if bit 4 was unset."
930   PROCwimp_error(werrtitle$,error$,1,"",0,1,"")
931   titleflags%=(titleflags% EOR %00010000)
932 ENDIF
933 wimp%!0=vminx%:wimp%!4=vminy%:wimp%!8=vmaxx%:wimp%!12=vmaxy%
934 wimp%!16=0:wimp%!20=0
935 wimp%!24=-1
936 wflags%=0
937 wflags%=(1<<31)
938 RESTORE +0
939 FOR bits%=0 TO 16
940   READ wshift%
941   IF ((flags%>>bits%) AND 1) THEN wflags%+=1<<wshift%
942 NEXT
943 DATA 26,25,24,30,28,29,27,4,5,1,6,8,9,12,13,14,15
944 wimp%!28=wflags%
945 FOR N%=0 TO 6
946   wimp%?(38-N%)=colourflags% AND %1111
947   colourflags%=colourflags%>>>4
948 NEXT
949 wimp%?39=0
950 wimp%!40=wminx%:wimp%!44=wminy%:wimp%!48=wmaxx%:wimp%!52=wmaxy%
951 FOR bits%=0 TO 6
952   READ wshift%
953   IF ((titleflags%>>bits%) AND 1) THEN tflags%+=1<<wshift%
954 NEXT
955 DATA 0,1,3,4,6,9,11
956 IF (titleflags%>>7 AND 1) OR LEN(title$)>11 THEN tflags%+=1<<8
957 IF (titleflags%>>4 AND 1) THEN tflags%+=titlefont%<<24
958 wimp%!56=tflags%
959 wimp%!60=wbuttontype%<<12
960 IF spritearea%=0 THEN wimp%!64=1 ELSE wimp%!64=spritearea%
961 wimp%?68=0:wimp%?69=0:wimp%?70=0:wimp%?71=0
962 IF ((tflags%>>8 AND 1)=0) THEN
963   $(wimp%+72)=title$
964 ELSE
965   len%=LEN(title$)+1
966   DIM name% len%-1
967   IF maxind%<len% THEN maxind%=len%
968   $(name%)=title$
969   wimp%!72=name%
970   wimp%!76=-1
971   wimp%!80=maxind%
972 ENDIF
973 wimp%!84=0
974 SYS "Wimp_CreateWindow",,wimp% TO whan%
975 =whan%
976 :
977 DEF PROCwimp_deletewindow(whan%)
978 wimp%!0=whan%
979 SYS "Wimp_DeleteWindow",,wimp%
980 ENDPROC
981 :
982 DEF PROCwint_pointercentrewindow(whan%)
983 LOCAL mx%,my%,width%,height%,xp%,yp%
984 SYS "Wimp_GetPointerInfo",,wimp%
985 mx%=wimp%!0:my%=wimp%!4
986 wimp%!0=whan%
987 SYS "Wimp_GetWindowInfo",,(wimp% OR %1)
988 width%=wimp%!12-wimp%!4:height%=wimp%!16-wimp%!8
989 xp%=mx%-width%/2:yp%=my%-height%/2
990 wimp%!4=xp%:wimp%!8=yp%
991 wimp%!12=xp%+width%:wimp%!16=yp%+height%
992 ENDPROC
993 :
994 DEF PROCwint_centrewindow
995 LOCAL x0%,y0%,x1%,y1%,wwidth%,wheight%,swidth%,sheight%
996 x0%=wimp%!4:y0%=wimp%!8
997 x1%=wimp%!12:y1%=wimp%!16
998 wwidth%=x1%-x0%
999 wheight%=y1%-y0%
1000 swidth%=FNwimp_getscreensize(0)
1001 sheight%=FNwimp_getscreensize(1)
1002 x0%=(swidth%-wwidth%)/2
1003 y0%=(sheight%-wheight%)/2
1004 wimp%!4=x0%:wimp%!8=y0%
1005 x1%=x0%+wwidth%:y1%=y0%+wheight%
1006 wimp%!12=x1%:wimp%!16=y1%
1007 ENDPROC
1008 :
1009 DEF PROCwint_checkuserpane(whan%,wimp%)
1010 LOCAL a%,stack%
1011 stack%=wimp%!28
1012 IF stack%=-3 THEN stack%=-4
1013 PROCuser_openwindow(whan%,wimp%!4,wimp%!16,stack%)
1014 a%=FNuser_pane(whan%)
1015 IF a%<>-1 THEN
1016   wimp%!0=whan%
1017   SYS "Wimp_GetWindowState",,wimp%
1018   wimp%!28=a%
1019   SYS "Wimp_OpenWindow",,wimp%
1020 ENDIF
1021 ENDPROC
1022 :
1023 DEF PROCwint_checksavewindow(whan%)
1024 LOCAL drag%,write%,ok%
1025 IF FNuser_savefiletype(whan%)<>"" THEN
1026   drag%=0:write%=1:ok%=2
1027   PROCuser_saveicon(whan%,drag%,write%,ok%)
1028   PROCwimp_putcaret(whan%,write%,-1)
1029 ENDIF
1030 ENDPROC
1031 :
1032 DEF FNwimp_geticontext(whan%,icon%)
1033 LOCAL return$,flag%
1034 return$=""
1035 wimp%!0=whan%
1036 wimp%!4=icon%
1037 SYS "Wimp_GetIconState",,wimp%
1038 flag%=wimp%!24
1039 flag%=(flag%>>8)
1040 IF (flag% AND 1)=0 THEN
1041   return$=FNwint_string(wimp%+28)
1042 ELSE
1043   return$=FNwint_string(wimp%!28)
1044 ENDIF
1045 =return$
1046 :
1047 DEF PROCwimp_puticontext(whan%,icon%,text$)
1048 LOCAL caret%,flag%,t$,caretwindow%,careticon%,current$,rightcaret%
1049 caret%=FALSE
1050 rightcaret%=FALSE
1051 IF whan%<>-2 THEN
1052   wimp%!0=whan%
1053   wimp%!4=icon%
1054   SYS "Wimp_GetIconState",,wimp%
1055   flag%=wimp%!24
1056   flag%=(flag%>>8)
1057   IF (flag% AND 1)=0 THEN
1058     PROCwimp_error(werrtitle$,"Icon "+STR$icon%+" is not indirected",1,"",0,1,"")
1059   ELSE
1060     current$=$(wimp%!28)
1061     IF text$<>current$ THEN
1062       SYS "Wimp_GetCaretPosition",,wimp%
1063       caretwindow%=wimp%!0
1064       careticon%=wimp%!4
1065       IF caretwindow%=whan% AND careticon%=icon% THEN
1066         caret%=TRUE
1067         index%=wimp%!20
1068         IF index%=LEN(current$) THEN rightcaret%=TRUE
1069         PROCwimp_losecaret
1070       ENDIF
1071       wimp%!0=whan%
1072       wimp%!4=icon%
1073       SYS "Wimp_GetIconState",,wimp%
1074       wimp%!8=0
1075       wimp%!12=0
1076       $(wimp%!28)=LEFT$(text$,(wimp%!36)-1)
1077       SYS "Wimp_SetIconState",,wimp%
1078       IF caret%=TRUE THEN
1079         IF rightcaret%=TRUE THEN index%=LEN(text$)
1080         PROCwimp_putcaret(whan%,icon%,index%)
1081       ENDIF
1082     ENDIF
1083   ENDIF
1084 ENDIF
1085 ENDPROC
1086 :
1087 DEF PROCwimp_puticonfont(whan%,icon%,fonthandle%)
1088 LOCAL outline%,currfont%,caret%,index%
1089 caret%=FALSE
1090 IF fonthandle%>0 THEN
1091   wimp%!0=whan%
1092   wimp%!4=icon%
1093   SYS "Wimp_GetIconState",,wimp%
1094   outline%=(wimp%!(8+16) >> 6) AND 1
1095   IF outline%=1 THEN
1096     currfont%=((wimp%!(8+16)>>24) AND &FFFF)
1097     IF fonthandle%<>currfont% THEN
1098       SYS "Wimp_GetCaretPosition",,wimp%
1099       caretwindow%=wimp%!0
1100       careticon%=wimp%!4
1101       IF caretwindow%=whan% AND careticon%=icon% THEN
1102         caret%=TRUE
1103         index%=wimp%!20
1104         PROCwimp_losecaret
1105       ENDIF
1106       wimp%!0=whan%
1107       wimp%!4=icon%
1108       wimp%!8=fonthandle%<<24
1109       wimp%!12=&FFFF<<24
1110       SYS "Wimp_SetIconState",,wimp%
1111       IF caret%=TRUE THEN
1112         PROCwimp_putcaret(whan%,icon%,index%)
1113       ENDIF
1114     ENDIF
1115   ELSE
1116     PROCwimp_error(werrtitle$,"Icon "+STR$icon%+" was not defined to use outline fonts.",1,"",0,1,"")
1117   ENDIF
1118 ENDIF
1119 ENDPROC
1120 :
1121 DEF PROCwimp_colouricon(whan%,icon%,colour%,background%)
1122 LOCAL outline%,indirect%,text%,valid%,valid$,temp$,first%,pos%,colour$
1123 colour%=colour% MOD 16
1124 wimp%!0=whan%
1125 wimp%!4=icon%
1126 SYS "Wimp_GetIconState",,wimp%
1127 outline%=(wimp%!24>>6) AND 1
1128 indirect%=(wimp%!24>>8) AND 1
1129 text%=(wimp%!24) AND 1
1130 IF outline%=1 THEN
1131   IF indirect%=1 AND text%=1 THEN
1132     valid%=!(wimp%+8+24)
1133     IF valid%<>-1 THEN
1134       valid$=FNwint_string(valid%)
1135       temp$=FNwimp_changecase(valid$,0)
1136       first%=0
1137       IF LEFT$(temp$,1)="f" THEN first%=1
1138       pos%=INSTR(temp$,";f")+1
1139       IF first%=1 OR pos%>1 THEN
1140         IF first%=1 THEN pos%=1
1141         IF colour%<10 THEN
1142           colour$=STR$(colour%)
1143         ELSE
1144           colour$=MID$("123456789abcdef",colour%,1)
1145         ENDIF
1146         IF background%=1 THEN
1147           MID$(valid$,pos%+1,1)=colour$
1148         ELSE
1149           MID$(valid$,pos%+2,1)=colour$
1150         ENDIF
1151         $(valid%)=valid$
1152         wimp%!8=0
1153         wimp%!12=0
1154         SYS "Wimp_SetIconState",,wimp%
1155       ELSE
1156         PROCwimp_error(werrtitle$,"Sorry, but to change an outline font colour the icon must be defined with a validation string including an F-command. See Dr Wimp Manual Section 2.33",1,"",0,1,"")
1157       ENDIF
1158     ELSE
1159       PROCwimp_error(werrtitle$,"Sorry, but to change an outline font colour the icon must be defined with a validation string including an F-command. See Dr Wimp Manual Section 2.33",1,"",0,1,"")
1160     ENDIF
1161   ELSE
1162     PROCwimp_error(werrtitle$,"Sorry, but the icon must be defined to allow text AND indirected data AND with a validation string including an F-command. See Dr Wimp Manual Section 2.33",1,"",0,1,"")
1163   ENDIF
1164 ELSE
1165   IF background%=0 THEN
1166     wimp%!8=colour%<<24
1167     wimp%!12=15<<24
1168   ELSE
1169     wimp%!8=colour%<<28
1170     wimp%!12=15<<28
1171   ENDIF
1172   SYS "Wimp_SetIconState",,wimp%
1173 ENDIF
1174 ENDPROC
1175 :
1176 DEF PROCwimp_iconenable(whan%,icon%,state%)
1177 LOCAL b%
1178 IF state%<0 OR state%>2 THEN state%=1
1179 wimp%!0=whan%
1180 wimp%!4=icon%
1181 SYS "Wimp_GetIconState",,wimp%
1182 b%=(wimp%!24>>22) AND 1
1183 IF state%=2 THEN state%=b%
1184 state%=1-state%
1185 IF b%<>state% THEN
1186   IF state%=1 THEN
1187     SYS "Wimp_GetCaretPosition",,wimp%
1188     IF wimp%!0=whan% AND wimp%!4=icon% THEN SYS "Wimp_SetCaretPosition",-1
1189     wimp%!0=whan%
1190     wimp%!4=icon%
1191   ENDIF
1192   wimp%!8=(state%<<22)
1193   wimp%!12=(1<<22)
1194   SYS "Wimp_SetIconState",,wimp%
1195 ENDIF
1196 ENDPROC
1197 :
1198 DEF PROCwimp_iconselect(whan%,icon%,state%)
1199 LOCAL b%
1200 IF state%<0 OR state%>2 THEN state%=1
1201 wimp%!0=whan%
1202 wimp%!4=icon%
1203 SYS "Wimp_GetIconState",,wimp%
1204 b%=(wimp%!24>>21) AND 1
1205 IF state%=2 THEN state%=1-b%
1206 IF b%<>state% THEN
1207   wimp%!8=(state%<<21)
1208   wimp%!12=(1<<21)
1209   SYS "Wimp_SetIconState",,wimp%
1210 ENDIF
1211 ENDPROC
1212 :
1213 DEF FNwimp_geticonselect(whan%,icon%)
1214 wimp%!0=whan%
1215 wimp%!4=icon%
1216 SYS "Wimp_GetIconState",,wimp%
1217 =(wimp%!24>>21) AND 1
1218 :
1219 DEF FNwimp_geticonsize(whan%,icon%,side%)
1220 LOCAL return%
1221 return%=0
1222 IF side%<>0 THEN side%=1
1223 wimp%!0=whan%
1224 wimp%!4=icon%
1225 SYS "Wimp_GetIconState",,wimp%
1226 return%=wimp%!(side%*4+16)-wimp%!(side%*4+8)
1227 =return%
1228 :
1229 DEF PROCwimp_resizeicon(whan%,icon%,minx%,miny%,maxx%,maxy%)
1230 wimp%!0=whan%
1231 wimp%!4=icon%
1232 SYS "Wimp_GetIconState",,wimp%
1233 SYS "Wimp_ResizeIcon",whan%,icon%,minx%,miny%,maxx%,maxy%
1234 PROCwimp_updatewindow(whan%,wimp%!8,wimp%!12,wimp%!16,wimp%!20)
1235 PROCwimp_updatewindow(whan%,minx%,miny%,maxx%,maxy%)
1236 ENDPROC
1237 :
1238 DEF PROCwimp_moveicon(whan%,icon%,minx%,miny%)
1239 LOCAL width%,height%,maxx%,maxy%
1240 wimp%!0=whan%
1241 wimp%!4=icon%
1242 SYS "Wimp_GetIconState",,wimp%
1243 width%=wimp%!16-wimp%!8
1244 height%=wimp%!20-wimp%!12
1245 maxx%=minx%+width%
1246 maxy%=miny%+height%
1247 SYS "Wimp_ResizeIcon",whan%,icon%,minx%,miny%,maxx%,maxy%
1248 PROCwimp_updatewindow(whan%,wimp%!8,wimp%!12,wimp%!16,wimp%!20)
1249 PROCwimp_updatewindow(whan%,minx%,miny%,maxx%,maxy%)
1250 ENDPROC
1251 :
1252 DEF FNwimp_geticonenable(whan%,icon%)
1253 wimp%!0=whan%
1254 wimp%!4=icon%
1255 SYS "Wimp_GetIconState",,wimp%
1256 =1-((wimp%!24>>22) AND 1)
1257 :
1258 DEF FNwimp_geticonposition(whan%,icon%,coord%)
1259 LOCAL return%
1260 IF coord%<0 THEN coord%=0
1261 IF coord%>3 THEN coord%=3
1262 return%=0
1263 wimp%!0=whan%
1264 wimp%!4=icon%
1265 SYS "Wimp_GetIconState",,wimp%
1266 CASE coord% OF
1267   WHEN 0:return%=wimp%!8
1268   WHEN 1:return%=wimp%!12
1269   WHEN 2:return%=wimp%!16
1270   WHEN 3:return%=wimp%!20
1271 ENDCASE
1272 =return%
1273 :
1274 DEF PROCwimp_iconbit(whan%,icon%,bit%,state%)
1275 LOCAL b%
1276 IF bit%<>23 THEN
1277   IF bit%<0 THEN bit%=0
1278   IF bit%>31 THEN bit%=31
1279   IF state%<0 OR state%>2 THEN state%=1
1280   wimp%!0=whan%
1281   wimp%!4=icon%
1282   SYS "Wimp_GetIconState",,wimp%
1283   b%=(wimp%!24>>bit%) AND 1
1284   IF state%=2 THEN state%=1-b%
1285   IF b%<>state% THEN
1286     wimp%!8=state%<<bit%
1287     wimp%!12=1<<bit%
1288     SYS "Wimp_SetIconState",,wimp%
1289   ENDIF
1290 ENDIF
1291 ENDPROC
1292 :
1293 DEF FNwimp_geticonbit(whan%,icon%,bit%)
1294 LOCAL flags%,state%
1295 IF bit%<0 THEN bit%=0
1296 IF bit%>31 THEN bit%=31
1297 wimp%!0=whan%
1298 wimp%!4=icon%
1299 SYS "Wimp_GetIconState",,wimp%
1300 flags%=wimp%!(8+16)
1301 state%=((flags%>>bit%) AND 1)
1302 =state%
1303 :
1304 DEF FNwimp_createicon(whan%,wminx%,wminy%,wmaxx%,wmaxy%,flags%,esg%,buttontype%,fcol%,bcol%,fhan%,text$,spritename$,spritearea%,maxind%,valid$)
1305 LOCAL error$,icon%
1306 IF ((flags%>>6 AND 1)=1) AND (wFontbuf%?fhan%=0) THEN
1307   error$="For creating the icon at window position "+STR$(wminx%)+"/"+STR$(wminy%)+" bit 6 of 'flags%' is set but the font handle in 'fhan%' is invalid. The window will now be created as if bit 6 was unset but with default outline font colours."
1308   PROCwimp_error(werrtitle$,error$,1,"",0,1,"")
1309   flags%=(flags% EOR %000000001000000)
1310   fcol%=7
1311   bcol%=0
1312 ENDIF
1313 wimp%!0=whan%
1314 PROCwint_defineicon(wminx%,wminy%,wmaxx%,wmaxy%,flags%,esg%,buttontype%,fcol%,bcol%,fhan%,text$,spritename$,spritearea%,maxind%,valid$)
1315 SYS "Wimp_CreateIcon",,wimp% TO icon%
1316 =icon%
1317 :
1318 DEF PROCwimp_ploticon(wminx%,wminy%,wmaxx%,wmaxy%,flags%,esg%,buttontype%,fcol%,bcol%,fhan%,text$,spritename$,spritearea%,maxind%,valid$)
1319 PROCwint_defineicon(wminx%,wminy%,wmaxx%,wmaxy%,flags%,esg%,buttontype%,fcol%,bcol%,fhan%,text$,spritename$,spritearea%,maxind%,valid$)
1320 SYS "Wimp_PlotIcon",,(wimp%+4)
1321 ENDPROC
1322 :
1323 DEF PROCwint_defineicon(wminx%,wminy%,wmaxx%,wmaxy%,flags%,esg%,buttontype%,fcol%,bcol%,fhan%,text$,spritename$,spritearea%,maxind%,valid$)
1324 LOCAL iflags%,len%,buf%,valid%,t%,s%,f%,ind%,loflags%,hiflags%
1325 wimp%!4=wminx%
1326 wimp%!8=wminy%
1327 wimp%!12=wmaxx%
1328 wimp%!16=wmaxy%
1329 iflags%=0
1330 t%=flags%>>0 AND 1
1331 s%=flags%>>1 AND 1
1332 f%=flags%>>6 AND 1
1333 ind%=flags%>>8 AND 1
1334 loflags%=flags% AND %111111111111
1335 hiflags%=flags% AND %111000000000000
1336 iflags%+=loflags%
1337 iflags%+=hiflags%<<9
1338 iflags%+=esg%<<16
1339 IF f% THEN
1340   iflags%+=fhan%<<24
1341 ELSE
1342   iflags%+=fcol%<<24
1343   iflags%+=bcol%<<28
1344 ENDIF
1345 iflags%+=buttontype%<<12
1346 wimp%!20=iflags%
1347 IF t%=1 AND s%=0 AND ind%=0 THEN $(wimp%+24)=text$
1348 IF t%=0 AND s%=1 AND ind%=0 THEN $(wimp%+24)=spritename$
1349 IF t%=1 AND s%=1 AND ind%=0 THEN $(wimp%+24)=spritename$
1350 IF t%=1 AND ind%=1 THEN
1351   len%=LEN(valid$)+1
1352   DIM valid% len%-1
1353   len%=LEN(text$)+1
1354   IF maxind%<len% THEN maxind%=len%
1355   DIM buf% maxind%-1
1356   $(buf%)=text$
1357   $(valid%)=valid$
1358   wimp%!24=buf%
1359   wimp%!28=valid%
1360   wimp%!32=maxind%
1361 ENDIF
1362 IF t%=0 AND s%=1 AND ind%=1 THEN
1363   len%=LEN(spritename$)+1
1364   IF maxind%<len% THEN maxind%=len%
1365   DIM buf% maxind%-1
1366   $(buf%)=spritename$
1367   wimp%!24=buf%
1368   IF spritearea%=0 THEN wimp%!28=1 ELSE wimp%!28=spritearea%
1369   wimp%!32=maxind%
1370 ENDIF
1371 ENDPROC
1372 :
1373 DEF PROCwimp_deleteicon(whan%,icon%,redraw%)
1374 wimp%!0=whan%
1375 wimp%!4=icon%
1376 IF redraw%=1 THEN
1377   SYS "Wimp_GetIconState",,wimp%
1378   minx%=wimp%!8
1379   miny%=wimp%!12
1380   maxx%=wimp%!16
1381   maxy%=wimp%!20
1382 ENDIF
1383 SYS "Wimp_DeleteIcon",,wimp%
1384 IF redraw%=1 THEN PROCwimp_updatewindow(whan%,minx%,miny%,maxx%,maxy%)
1385 ENDPROC
1386 :
1387 DEF PROCwimp_iconhide(whan%,icon%,state%)
1388 LOCAL b%
1389 IF state%<0 OR state%>2 THEN state%=1
1390 wimp%!0=whan%
1391 wimp%!4=icon%
1392 SYS "Wimp_GetIconState",,wimp%
1393 b%=(wimp%!24>>23) AND 1
1394 IF state%=2 THEN state%=1-b%
1395 IF b%<>state% THEN
1396   wimp%!8=(state%<<7)+(state%<<23)
1397   wimp%!12=(1<<7)+(1<<23)
1398   SYS "Wimp_SetIconState",,wimp%
1399 ENDIF
1400 ENDPROC
1401 :
1402 DEF PROCwimp_putcaret(whan%,icon%,index%)
1403 LOCAL flag%,text$,len%
1404 IF icon%>=0 THEN
1405   wimp%!0=whan%
1406   wimp%!4=icon%
1407   SYS "Wimp_GetIconState",,wimp%
1408   flag%=wimp%!24
1409   flag%=(flag%>>12)
1410   flag%=flag% AND &F
1411   IF flag%=14 OR flag%=15 THEN
1412     text$=FNwimp_geticontext(whan%,icon%)
1413     len%=LEN(text$)
1414     IF index%<0 OR index%>len% THEN index%=len%
1415     SYS "Wimp_SetCaretPosition",whan%,icon%,,,-1,index%
1416   ELSE
1417     PROCwimp_error(werrtitle$,"The icon is not writable and therefore cannot take the caret.",1,"",0,1,"")
1418   ENDIF
1419 ELSE
1420   SYS "Wimp_SetCaretPosition",whan%,icon%,,,-1,-1
1421 ENDIF
1422 ENDPROC
1423 :
1424 DEF PROCwimp_losecaret
1425 SYS "Wimp_SetCaretPosition",-1
1426 ENDPROC
1427 :
1428 DEF FNwimp_getcaretposition(choice%)
1429 LOCAL return%
1430 IF choice%<0 THEN choice%=0
1431 IF choice%>4 THEN choice%=4
1432 return%=-1
1433 SYS "Wimp_GetCaretPosition",,wimp%
1434 IF wimp%!0<>-1 THEN
1435   CASE choice% OF
1436     WHEN 0,1,2,3: return%=wimp%!(4*choice%)
1437     WHEN 4: return%=wimp%!20
1438   ENDCASE
1439 ENDIF
1440 =return%
1441 :
1442 DEF PROCwint_startdrag(whan%,icon%,button%,mousex%,mousey%)
1443 LOCAL a%,b%
1444 wSavet$=FNuser_savefiletype(whan%)
1445 IF wSavet$="" THEN
1446   a%=FNuser_sliderback(whan%,icon%)
1447   b%=FNuser_slider(whan%,icon%)
1448   IF a%=-1 AND b%=-1 THEN
1449     IF FNuser_dragicon(whan%,icon%,button%/16)=1 THEN
1450       PROCwint_starticondrag(whan%,icon%,button%,mousex%,mousey%)
1451     ENDIF
1452   ELSE
1453     IF a%=-1 THEN icon%=b%
1454     PROCwint_startsliderdrag(whan%,icon%)
1455   ENDIF
1456 ELSE
1457   PROCwint_startsavedrag(whan%,icon%)
1458 ENDIF
1459 ENDPROC
1460 :
1461 DEF PROCwint_startsavedrag(whan%,icon%)
1462 LOCAL ox%,oy%,t%,i%,spritearea%,spritename$,drag%,write%,ok%,valid$
1463 IF LEN(wSavet$)<4 THEN
1464   wSavew%=whan%
1465   wSavedrag%=whan%
1466   wimp%!0=wSavew%
1467   SYS "Wimp_GetWindowState",,wimp%
1468   ox%=wimp%!4-wimp%!20
1469   oy%=wimp%!16-wimp%!24
1470   drag%=0:write%=1:ok%=2
1471   PROCuser_saveicon(wSavew%,drag%,write%,ok%)
1472   IF drag%=icon% THEN
1473     wimp%!4=drag%
1474     SYS "Wimp_GetIconState",,wimp%
1475     t%=(wimp%!(8+16)) AND 1
1476     i%=(wimp%!(8+16)>>8) AND 1
1477     IF t%=0 THEN
1478       IF i%=0 THEN spritename$=FNwint_string(wimp%+(8+20)):spritearea%=1
1479       IF i%=1 THEN spritename$=FNwint_string(wimp%!(8+20)):spritearea%=wimp%!(8+24)
1480       IF spritearea%<>1 THEN SYS "XOS_SpriteOp",&128,spritearea%,spritename$ TO;f% :IF (f% AND 1)=1 THEN spritearea%=1
1481     ELSE
1482       valid$=$(wimp%!32)
1483       spritearea%=1
1484       spritename$=FNwint_extractspritename(valid$)
1485     ENDIF
1486     wimp%!0=wimp%!8+ox%
1487     wimp%!4=wimp%!12+oy%
1488     wimp%!8=wimp%!16+ox%
1489     wimp%!12=wimp%!20+oy%
1490     SYS "DragASprite_Start",%11001010,spritearea%,spritename$,wimp%
1491   ENDIF
1492 ELSE
1493   PROCwimp_error(werrtitle$,"Filetype string too long in 'DEF FNuser_savefiletype'.",1,"",0,0,"Quit "+wappname$):PROCwimp_closedown:END
1494 ENDIF
1495 ENDPROC
1496 :
1497 DEF FNwint_extractspritename(valid$)
1498 LOCAL name$,pos%
1499 IF INSTR(valid$,";")=0 THEN
1500   name$=RIGHT$(valid$,LEN(valid$)-1)
1501 ELSE
1502   IF INSTR(valid$,"s")=1 OR INSTR(valid$,"S")=1 THEN
1503     name$=""
1504     pos%=1
1505     REPEAT
1506       pos%+=1
1507       IF MID$(valid$,pos%,1)<>";" THEN
1508         name$+=MID$(valid$,pos%,1)
1509       ENDIF
1510     UNTIL MID$(valid$,pos%,1)=";"
1511   ELSE
1512     pos%=0
1513     REPEAT
1514       pos%+=1
1515     UNTIL MID$(valid$,pos%,1)=";" AND (MID$(valid$,pos%+1,1)="s" OR MID$(valid$,pos%+1,1)="S")
1516     name$=""
1517     pos%=pos%+1
1518     REPEAT
1519       pos%+=1
1520       IF MID$(valid$,pos%,1)<>";" THEN
1521         name$+=MID$(valid$,pos%,1)
1522       ENDIF
1523     UNTIL MID$(valid$,pos%,1)=";"
1524   ENDIF
1525 ENDIF
1526 =name$
1527 :
1528 DEF PROCwint_endsavedrag
1529 LOCAL drag%,write%,ok%,whan%,ico%,x%,y%
1530 drag%=0:write%=1:ok%=2
1531 PROCuser_saveicon(wSavew%,drag%,write%,ok%)
1532 SYS "DragASprite_Stop"
1533 SYS "Wimp_GetPointerInfo",,wimp%
1534 whan%=wimp%!12
1535 ico%=wimp%!16
1536 x%=wimp%!0
1537 y%=wimp%!4
1538 leaf$=FNwimp_getleafname(FNwimp_geticontext(wSavew%,write%))
1539 wimp%!0=(44+LEN(leaf$)+4) AND &1FC
1540 wimp%!12=0
1541 wimp%!16=1
1542 wimp%!20=whan%
1543 wimp%!24=ico%
1544 wimp%!28=x%
1545 wimp%!32=y%
1546 wimp%!36=1024
1547 SYS "OS_ReadUnsigned",10,"&"+wSavet$ TO ,,v%
1548 wimp%!40=v%
1549 PROCwint_zeroterminate(wimp%+44,leaf$)
1550 SYS "Wimp_SendMessage",18,wimp%,wimp%!20,wimp%!24
1551 wSavedrag%=-1
1552 ENDPROC
1553 :
1554 DEF PROCwimp_bar(whan%,icon%,len%,dir%)
1555 LOCAL minx%,miny%,maxx%,maxy%,flag%,data1%,data2%,data3%,border%,filled%,oldb%,newend%
1556 wimp%!0=whan%
1557 wimp%!4=icon%
1558 SYS "Wimp_GetIconState",,wimp%
1559 minx%=wimp%!8
1560 miny%=wimp%!12
1561 maxx%=wimp%!16
1562 maxy%=wimp%!20
1563 flag%=wimp%!24
1564 data1%=wimp%!28
1565 data2%=wimp%!32
1566 data3%=wimp%!36
1567 filled%=(flag%>>5) AND 1
1568 border%=(flag%>>2) AND 1
1569 oldb%=(flag%>>11) AND 1
1570 IF len%<0 THEN len%=0
1571 SYS "Wimp_DeleteIcon",,wimp%
1572 IF dir%=0 THEN
1573   newend%=len%+minx%
1574   wimp%!4=minx%:wimp%!8=miny%
1575   wimp%!12=newend%:wimp%!16=maxy%
1576 ELSE
1577   newend%=len%+miny%
1578   wimp%!4=minx%:wimp%!8=miny%
1579   wimp%!12=maxx%:wimp%!16=newend%
1580 ENDIF
1581 wimp%!20=flag%
1582 wimp%!24=data1%
1583 wimp%!28=data2%
1584 wimp%!32=data3%
1585 SYS "Wimp_CreateIcon",,wimp%
1586 wimp%!0=whan%
1587 wimp%!4=icon%
1588 IF len%=0 THEN
1589   PROCwint_zerolengthbar(border%)
1590 ELSE
1591   IF filled%=0 THEN
1592     wimp%!8=32:wimp%!12=32
1593     SYS "Wimp_SetIconState",,wimp%
1594     IF oldb%=1 THEN
1595       wimp%!8=4:wimp%!12=4
1596       SYS "Wimp_SetIconState",,wimp%
1597     ENDIF
1598   ENDIF
1599 ENDIF
1600 IF dir%=0 THEN
1601   IF newend%<maxx% THEN
1602     SYS "Wimp_ForceRedraw",whan%,newend%-2,miny%,maxx%,maxy%
1603   ELSE
1604     SYS "Wimp_ForceRedraw",whan%,maxx%-2,miny%,newend%,maxy%
1605   ENDIF
1606 ELSE
1607   IF newend%<maxy% THEN
1608     SYS "Wimp_ForceRedraw",whan%,minx%,newend%-2,maxx%,maxy%
1609   ELSE
1610     SYS "Wimp_ForceRedraw",whan%,minx%,maxy%-2,maxx%,newend%
1611   ENDIF
1612 ENDIF
1613 ENDPROC
1614 :
1615 DEF PROCwint_zerolengthbar(border%)
1616 wimp%!8=0:wimp%!12=32
1617 SYS "Wimp_SetIconState",,wimp%
1618 IF border%=1 THEN
1619   wimp%!8=2048:wimp%!12=2048
1620   SYS "Wimp_SetIconState",,wimp%
1621   wimp%!8=0:wimp%!12=4
1622   SYS "Wimp_SetIconState",,wimp%
1623 ELSE
1624   wimp%!8=0:wimp%!12=2048
1625   SYS "Wimp_SetIconState",,wimp%
1626 ENDIF
1627 ENDPROC
1628 :
1629 DEF FNwimp_getsliderpcent(whan%,icon%)
1630 LOCAL a%,minx%,miny%,maxx%,maxy%,s1%,s2%,s3%,s4%,pcreal
1631 pcreal=0
1632 a%=FNuser_sliderback(whan%,icon%)
1633 IF a%=-1 THEN
1634   pcreal=0
1635 ELSE
1636   wimp%!0=whan%
1637   wimp%!4=icon%
1638   SYS "Wimp_GetIconState",,wimp%
1639   minx%=wimp%!8:maxx%=wimp%!16
1640   miny%=wimp%!12:maxy%=wimp%!20
1641   s1%=maxx%-minx%:s2%=maxy%-miny%
1642   wimp%!0=whan%
1643   wimp%!4=a%
1644   SYS "Wimp_GetIconState",,wimp%
1645   minx%=wimp%!8:maxx%=wimp%!16
1646   miny%=wimp%!12:maxy%=wimp%!20
1647   s3%=maxx%-minx%:s4%=maxy%-miny%
1648   IF s4%>s3% THEN
1649     pcreal=(s2%/s4%)*100
1650   ELSE
1651     pcreal=(s1%/s3%)*100
1652   ENDIF
1653 ENDIF
1654 =pcreal
1655 :
1656 DEF PROCwimp_putsliderpcent(whan%,icon%,pcreal)
1657 LOCAL a%,s1%,s2%,minx%,maxx%,len%
1658 a%=FNuser_sliderback(whan%,icon%)
1659 IF a%=-1 THEN
1660 ELSE
1661   wimp%!0=whan%
1662   wimp%!4=a%
1663   SYS "Wimp_GetIconState",,wimp%
1664   minx%=wimp%!8:maxx%=wimp%!16
1665   miny%=wimp%!12:maxy%=wimp%!20
1666   s1%=maxx%-minx%:s2%=maxy%-miny%
1667   IF s2%>s1% THEN
1668     len%=(pcreal/100)*s2%
1669     PROCwimp_bar(whan%,icon%,len%,1)
1670   ELSE
1671     len%=(pcreal/100)*s1%
1672     PROCwimp_bar(whan%,icon%,len%,0)
1673   ENDIF
1674 ENDIF
1675 ENDPROC
1676 :
1677 DEF PROCwint_startsliderdrag(whan%,icon%)
1678 LOCAL ox%,oy%,bx1%,by1%,bx2%,by2%
1679 wimp%!0=whan%
1680 SYS "Wimp_GetWindowState",,wimp%
1681 ox%=wimp%!4-wimp%!20
1682 oy%=wimp%!16-wimp%!24
1683 wimp%!0=whan%
1684 wimp%!4=FNuser_sliderback(whan%,icon%)
1685 SYS "Wimp_GetIconState",,wimp%
1686 bx1%=ox%+wimp%!8:by1%=oy%+wimp%!12
1687 bx2%=ox%+wimp%!16:by2%=oy%+wimp%!20
1688 wimp%!0=whan%
1689 wimp%!4=icon%
1690 SYS "Wimp_GetIconState",,wimp%
1691 wimp%!4=7
1692 wimp%!8=ox%+wimp%!8
1693 wimp%!12=oy%+wimp%!12
1694 wimp%!16=ox%+wimp%!16
1695 wimp%!20=oy%+wimp%!20
1696 wimp%!24=bx1%
1697 wimp%!28=by1%
1698 wimp%!32=bx2%
1699 wimp%!36=by2%
1700 SYS "Wimp_DragBox",,wimp%
1701 wSlidedrag%=whan%:wSlidew%=whan%:wSlidei%=icon%:wOx%=ox%:wOy%=oy%:wLen%=-1:wLen2%=-1
1702 wSwid%=bx2%-bx1%:wShei%=by2%-by1%
1703 ENDPROC
1704 :
1705 DEF PROCwint_draggingslider
1706 LOCAL minx%,miny%,maxx%,maxy%,len%,len2%
1707 wimp%!0=wSlidew%
1708 wimp%!4=wSlidei%
1709 SYS "Wimp_GetIconState",,wimp%
1710 minx%=wimp%!8+wOx%:maxx%=wimp%!16+wOx%
1711 miny%=wimp%!12+wOy%:maxy%=wimp%!20+wOy%
1712 SYS "Wimp_GetPointerInfo",,wimp%
1713 len%=wimp%!0-minx%
1714 len2%=wimp%!4-miny%
1715 IF wShei%>wSwid% THEN
1716   IF len2%<>wLen2% THEN
1717     PROCwimp_bar(wSlidew%,wSlidei%,len2%,1)
1718     wLen2%=len2%
1719     PROCuser_slidervalue(wSlidew%,wSlidei%,FNwint_calcsliderpcent(wSlidew%,wSlidei%,wShei%,1),1)
1720   ENDIF
1721 ELSE
1722   IF len%<>wLen% THEN
1723     PROCwimp_bar(wSlidew%,wSlidei%,len%,0)
1724     wLen%=len%
1725     PROCuser_slidervalue(wSlidew%,wSlidei%,FNwint_calcsliderpcent(wSlidew%,wSlidei%,wSwid%,0),0)
1726   ENDIF
1727 ENDIF
1728 ENDPROC
1729 :
1730 DEF PROCwint_endsliderdrag
1731 wSlidedrag%=-1
1732 IF wShei%>wSwid% THEN
1733   PROCuser_slidervalue(wSlidew%,wSlidei%,FNwint_calcsliderpcent(wSlidew%,wSlidei%,wShei%,1),1)
1734 ELSE
1735   PROCuser_slidervalue(wSlidew%,wSlidei%,FNwint_calcsliderpcent(wSlidew%,wSlidei%,wSwid%,0),0)
1736 ENDIF
1737 ENDPROC
1738 :
1739 DEF PROCwint_clickedslider(whan%,icon%,mx%,my%)
1740 LOCAL len%,minx%,miny%,maxx%,maxy%,ox%,oy%,len2%,minxb%,minyb%,maxxb%,maxyb%
1741 IF wimp%!8=2 THEN
1742 ELSE
1743   wimp%!0=whan%
1744   SYS "Wimp_GetWindowState",,wimp%
1745   ox%=wimp%!4-wimp%!20
1746   oy%=wimp%!16-wimp%!24
1747   wimp%!0=whan%
1748   wimp%!4=icon%
1749   SYS "Wimp_GetIconState",,wimp%
1750   minx%=wimp%!8+ox%:maxx%=wimp%!16+ox%
1751   miny%=wimp%!12+oy%:maxy%=wimp%!20+oy%
1752   len%=mx%-minx%:len2%=my%-miny%
1753   wimp%!0=whan%
1754   wimp%!4=FNuser_sliderback(whan%,icon%)
1755   SYS "Wimp_GetIconState",,wimp%
1756   minxb%=wimp%!8+ox%:maxxb%=wimp%!16+ox%
1757   minyb%=wimp%!12+oy%:maxyb%=wimp%!20+oy%
1758   IF (maxyb%-minyb%)>(maxxb%-minxb%) THEN
1759     PROCwimp_bar(whan%,icon%,len2%,1)
1760   ELSE
1761     PROCwimp_bar(whan%,icon%,len%,0)
1762   ENDIF
1763   wimp%!0=whan%
1764   wimp%!4=FNuser_sliderback(whan%,icon%)
1765   SYS "Wimp_GetIconState",,wimp%
1766   IF (maxyb%-minyb%)>(maxxb%-minxb%) THEN
1767     PROCuser_slidervalue(whan%,icon%,FNwint_calcsliderpcent(whan%,icon%,wimp%!20-wimp%!12,1),1)
1768   ELSE
1769     PROCuser_slidervalue(whan%,icon%,FNwint_calcsliderpcent(whan%,icon%,wimp%!16-wimp%!8,0),0)
1770   ENDIF
1771 ENDIF
1772 ENDPROC
1773 :
1774 DEF FNwint_calcsliderpcent(whan%,icon%,w%,dir%)
1775 LOCAL slideh%,slidew%,pc%
1776 pc%=0
1777 wimp%!0=whan%
1778 wimp%!4=icon%
1779 SYS "Wimp_GetIconState",,wimp%
1780 slideh%=wimp%!20-wimp%!12
1781 slidew%=wimp%!16-wimp%!8
1782 IF dir%=0 THEN
1783   pc%=INT((slidew%/w%)*100)
1784 ELSE
1785   pc%=INT((slideh%/w%)*100)
1786 ENDIF
1787 =pc%
1788 :
1789 DEF PROCwint_starticondrag(whan%,icon%,button%,mousex%,mousey%)
1790 LOCAL visminx%,visminy%,vismaxx%,vismaxy%,bx1%,by1%,bx2%,by2%
1791 LOCAL boundsminx%,boundsminy%,boundsmaxx%,boundsmaxy%
1792 LOCAL ox%,oy%,t%,i%,spritearea%,spritename$,drag%,write%,ok%
1793 wimp%!0=whan%
1794 SYS "Wimp_GetWindowState",,wimp%
1795 visminx%=wimp%!4
1796 visminy%=wimp%!8
1797 vismaxx%=wimp%!12
1798 vismaxy%=wimp%!16
1799 ox%=visminx%-wimp%!20
1800 oy%=vismaxy%-wimp%!24
1801 wimp%!0=whan%
1802 wimp%!4=icon%
1803 SYS "Wimp_GetIconState",,wimp%
1804 bx1%=ox%+wimp%!8
1805 by1%=oy%+wimp%!12
1806 bx2%=ox%+wimp%!16
1807 by2%=oy%+wimp%!20
1808 Relminx%=bx1%-mousex%
1809 Relminy%=by1%-mousey%
1810 Relmaxx%=bx2%-mousex%
1811 Relmaxy%=by2%-mousey%
1812 wimp%!4=5
1813 wimp%!8=bx1%
1814 wimp%!12=by1%
1815 wimp%!16=bx2%
1816 wimp%!20=by2%
1817 boundsminx%=visminx%
1818 boundsminy%=visminy%
1819 boundsmaxx%=vismaxx%
1820 boundsmaxy%=vismaxy%
1821 PROCwint_savewimp
1822 PROCuser_seticondragbounds(whan%,icon%,button%/16,mousex%,mousey%,boundsminx%,boundsminy%,boundsmaxx%,boundsmaxy%)
1823 PROCwint_loadwimp
1824 wimp%!24=boundsminx%
1825 wimp%!28=boundsminy%
1826 wimp%!32=boundsmaxx%
1827 wimp%!36=boundsmaxy%
1828 SYS "Wimp_DragBox",,wimp%
1829 wIcondrag%=whan%:wIconw%=whan%:wIconi%=icon%:wDragbutton%=button%/16:wStartx%=mousex%:wStarty%=mousey%
1830 ENDPROC
1831 :
1832 DEF PROCwint_draggingicon
1833 LOCAL x%,y%,overwindow%,overicon%,dragboxminx%,dragboxminy%,dragboxmaxx%,dragboxmaxy%
1834 SYS "Wimp_GetPointerInfo",,wimp%
1835 x%=wimp%!0
1836 y%=wimp%!4
1837 overwindow%=wimp%!12
1838 overicon%=wimp%!16
1839 dragboxminx%=x%+Relminx%
1840 dragboxminy%=y%+Relminy%
1841 dragboxmaxx%=x%+Relmaxx%
1842 dragboxmaxy%=y%+Relmaxy%
1843 PROCuser_draggingicon(wIconw%,wIconi%,wDragbutton%,wStartx%,wStarty%,x%,y%,overwindow%,overicon%,dragboxminx%,dragboxminy%,dragboxmaxx%,dragboxmaxy%)
1844 ENDPROC
1845 :
1846 DEF PROCwint_endicondrag(dragboxminx%,dragboxminy%,dragboxmaxx%,dragboxmaxy%)
1847 LOCAL whan%,icon%,x%,y%
1848 wIcondrag%=-1
1849 SYS "Wimp_GetPointerInfo",,wimp%
1850 whan%=wimp%!12
1851 icon%=wimp%!16
1852 x%=wimp%!0
1853 y%=wimp%!4
1854 PROCuser_endicondrag(wIconw%,wIconi%,wDragbutton%,wStartx%,wStarty%,dragboxminx%,dragboxminy%,dragboxmaxx%,dragboxmaxy%,whan%,icon%,x%,y%)
1855 ENDPROC
1856 :
1857 DEF FNwimp_iconbar(spritename$,text$,maxlen%,pos%)
1858 LOCAL temptext$,return%
1859 IF pos%<0 OR pos%>1 THEN pos%=1
1860 return%=-2
1861 pos%-=2
1862 DIM wIbarSprite% 19
1863 IF text$="" THEN
1864   return%=FNwint_iconbarsp(spritename$,pos%)
1865 ELSE
1866   IF LEN(text$) > maxlen% THEN maxlen%=LEN(text$)
1867   wMaxlen%=maxlen%
1868   DIM wIbarSprtxt% wMaxlen%-1
1869   temptext$=STRING$(wMaxlen%,"8")
1870   $wIbarSprite%="s"+spritename$
1871   $wIbarSprtxt%=temptext$
1872   wimp%!0=pos%
1873   wimp%!4=0
1874   wimp%!8=-16
1875   wimp%!12=128
1876   wimp%!16=88
1877   wimp%!20=&1700310B
1878   wimp%!24=wIbarSprtxt%
1879   wimp%!28=wIbarSprite%
1880   wimp%!32=wMaxlen%+1
1881   wBARTEXT%=TRUE
1882   SYS "Wimp_CreateIcon",,wimp% TO wIbarhan%
1883   PROCwimp_puticonbartext(LEFT$(text$,wMaxlen%))
1884 ENDIF
1885 =return%
1886 :
1887 DEF FNwint_iconbarsp(spritename$,pos%)
1888 $wIbarSprite%=spritename$
1889 wimp%!0=pos%
1890 wimp%!4=0
1891 wimp%!8=0
1892 wimp%!12=68
1893 wimp%!16=80
1894 wimp%!20=&1700310A
1895 wimp%!24=wIbarSprite%
1896 wimp%!28=1
1897 wimp%!32=20
1898 wBARTEXT%=FALSE
1899 SYS "Wimp_CreateIcon",,wimp% TO wIbarhan%
1900 =-2
1901 :
1902 DEF PROCwimp_puticonbartext(text$)
1903 IF wBARTEXT%=TRUE THEN
1904   IF $(wIbarSprtxt%)<>LEFT$(text$,wMaxlen%) THEN
1905     wimp%!0=-2
1906     wimp%!4=wIbarhan%
1907     SYS "Wimp_GetIconState",,wimp%
1908     $(wIbarSprtxt%)=LEFT$(text$,wMaxlen%)
1909     SYS "Wimp_ForceRedraw",-2,wimp%!8,wimp%!12,wimp%!16,wimp%!20
1910   ENDIF
1911 ENDIF
1912 ENDPROC
1913 :
1914 DEF PROCwimp_iconbarsprite(spritename$)
1915 IF wBARTEXT%=FALSE THEN
1916   PROCwint_ibarspritep(spritename$)
1917 ELSE
1918   IF $(wIbarSprite%)<>"s"+spritename$ THEN
1919     $wIbarSprite%="s"+spritename$
1920     wimp%!0=-2
1921     wimp%!4=wIbarhan%
1922     SYS "Wimp_GetIconState",,wimp%
1923     SYS "Wimp_ForceRedraw",-2,wimp%!8,wimp%!12,wimp%!16,wimp%!20
1924   ENDIF
1925 ENDIF
1926 ENDPROC
1927 :
1928 DEF PROCwint_ibarspritep(spritename$)
1929 IF $(wIbarSprite%)<>spritename$ THEN
1930   wimp%!0=-2
1931   wimp%!4=wIbarhan%
1932   SYS "Wimp_GetIconState",,wimp%
1933   $(wimp%!28)=spritename$
1934   SYS "Wimp_ForceRedraw",-2,wimp%!8,wimp%!12,wimp%!16,wimp%!20
1935 ENDIF
1936 ENDPROC
1937 :
1938 DEF FNwimp_createmenu(menu$,size%)
1939 LOCAL menu%,num%,pos%,ptr%,L%,m$,width%,extra%,title$,itemlen%
1940 num%=FNwint_numberofentries(menu$)
1941 num%-=1
1942 IF size%<=num% THEN size%=num%
1943 extra%=size%-num%
1944 DIM menu% (4+28+(size%*24))-1
1945 !menu%=size%
1946 menu%=menu%+4
1947 pos%=INSTR(menu$,"/")
1948 IF pos%=1 THEN
1949   title$=" "
1950 ELSE
1951   title$=LEFT$(menu$,pos%-1)
1952 ENDIF
1953 menu$=RIGHT$(menu$,LEN(menu$)-pos%)
1954 width%=FNwint_titleblockandwidth(menu%,title$,0)
1955 ptr%=menu%+28
1956 FOR L%=1 TO num%
1957   m$=FNwint_decodemenuentry(menu$,L%)
1958   itemlen%=FNwint_menuitemblockandwidth(ptr%,num%,L%,m$,0)
1959   IF itemlen%>width% THEN width%=itemlen%
1960   ptr%+=24
1961 NEXT L%
1962 menu%!16=width%+16
1963 IF extra%>0 THEN
1964   PROCwint_menuextraitems(ptr%,extra%)
1965 ENDIF
1966 =menu%
1967 :
1968 DEF FNwimp_createmenuarray(array$(),size%)
1969 LOCAL num%,extra%,menu%,L%,ptr%,width%,itemlen%,title$,m$,itemtext%,itemlen%
1970 num%=FNwint_getmenuarraysize(array$())
1971 IF size%<num% THEN size%=num%
1972 extra%=size%-num%
1973 DIM menu% (4+28+(24*size%))-1
1974 !menu%=size%
1975 menu%=menu%+4
1976 title$=array$(0)
1977 IF title$="" THEN title$=" "
1978 width%=FNwint_titleblockandwidth(menu%,title$,0)
1979 ptr%=menu%+28
1980 FOR L%=1 TO num%
1981   m$=array$(L%)
1982   itemlen%=FNwint_menuitemblockandwidth(ptr%,num%,L%,m$,0)
1983   IF itemlen%>width% THEN width%=itemlen%
1984   ptr%+=24
1985 NEXT L%
1986 menu%!16=width%+16
1987 IF extra%>0 THEN
1988   PROCwint_menuextraitems(ptr%,extra%)
1989 ENDIF
1990 =menu%
1991 :
1992 DEF FNwimp_createmessagemenu(messagefilehandle%,token$,title$,size%)
1993 LOCAL num%,extra%,menu%,L%,ptr%,width%,itemlen%,m$
1994 num%=FNwimp_getnumberofmessages(messagefilehandle%,token$)
1995 m$=FNwimp_messlookup(messagefilehandle%,token$+"T","","")
1996 IF m$="" THEN m$=FNwimp_messlookup(messagefilehandle%,token$+"t","","")
1997 IF m$<>"" THEN num%-=1
1998 IF title$="" THEN
1999   IF m$="" THEN m$=" "
2000 ELSE
2001   m$=title$
2002 ENDIF
2003 IF size%<num% THEN size%=num%
2004 extra%=size%-num%
2005 DIM menu% (4+28+(24*size%))-1
2006 !menu%=size%
2007 menu%=menu%+4
2008 width%=FNwint_titleblockandwidth(menu%,m$,0)
2009 ptr%=menu%+28
2010 FOR L%=1 TO num%
2011   m$=FNwimp_messlookup(messagefilehandle%,token$+STR$(L%),"","")
2012   itemlen%=FNwint_menuitemblockandwidth(ptr%,num%,L%,m$,0)
2013   IF itemlen%>width% THEN width%=itemlen%
2014   ptr%+=24
2015 NEXT L%
2016 menu%!16=width%+16
2017 IF extra%>0 THEN
2018   PROCwint_menuextraitems(ptr%,extra%)
2019 ENDIF
2020 =menu%
2021 :
2022 DEF PROCwimp_recreatemenu(menu%,menu$)
2023 LOCAL num%,pos%,L%,ptr%,m$,title$,width%,itemlen%
2024 IF !(menu%-4)=-1 THEN
2025   PROCwimp_error(werrtitle$,"Sorry, you can't use 'PROCwimp_recreatemenu' on a Font menu.",1,"",0,1,"")
2026 ELSE
2027   num%=FNwint_numberofentries(menu$)
2028   num%-=1
2029   IF num%>FNwimp_menumaxsize(menu%) THEN
2030     PROCwimp_error(werrtitle$,"Sorry, you are trying to recreate a menu to a larger size than was allowed for when it was created.",1,"",0,1,"")
2031   ELSE
2032     pos%=INSTR(menu$,"/")
2033     IF pos%=1 THEN
2034       title$=" "
2035     ELSE
2036       title$=LEFT$(menu$,pos%-1)
2037     ENDIF
2038     menu$=RIGHT$(menu$,LEN(menu$)-pos%)
2039     width%=FNwint_titleblockandwidth(menu%,title$,1)
2040     ptr%=menu%+28
2041     FOR L%=1 TO num%
2042       pos%=INSTR(menu$,"/")
2043       IF pos%=0 THEN
2044         m$=menu$
2045       ELSE
2046         m$=LEFT$(menu$,pos%-1)
2047         menu$=RIGHT$(menu$,LEN(menu$)-pos%)
2048       ENDIF
2049       itemlen%=FNwint_menuitemblockandwidth(ptr%,num%,L%,m$,1)
2050       IF itemlen%>width% THEN width%=itemlen%
2051       ptr%+=24
2052     NEXT L%
2053     menu%!16=width%+16
2054   ENDIF
2055 ENDIF
2056 ENDPROC
2057 :
2058 DEF PROCwimp_recreatemenuarray(menu%,array$())
2059 LOCAL num%,L%,ptr%,m$,itemlen%,width%,title$
2060 IF !(menu%-4)=-1 THEN
2061   PROCwimp_error(werrtitle$,"Sorry, you can't use 'PROCwimp_recreatemenuarray' on a Font menu.",1,"",0,1,"")
2062 ELSE
2063   num%=FNwint_getmenuarraysize(array$())
2064   IF num%>FNwimp_menumaxsize(menu%) THEN
2065     PROCwimp_error(werrtitle$,"Sorry, you are trying to recreate a menu to a larger size than was allowed for when it was created.",1,"",0,1,"")
2066   ELSE
2067     title$=array$(0)
2068     IF title$="" THEN title$=" "
2069     width%=FNwint_titleblockandwidth(menu%,title$,1)
2070     ptr%=menu%+28
2071     FOR L%=1 TO num%
2072       m$=array$(L%)
2073       itemlen%=FNwint_menuitemblockandwidth(ptr%,num%,L%,m$,1)
2074       IF itemlen%>width% THEN width%=itemlen%
2075       ptr%+=24
2076     NEXT L%
2077     menu%!16=width%+16
2078   ENDIF
2079 ENDIF
2080 ENDPROC
2081 :
2082 DEF PROCwimp_recreatemessagemenu(menu%,messagefilehandle%,token$,title$)
2083 LOCAL num%,L%,ptr%,width%,itemlen%,m$
2084 IF !(menu%-4)=-1 THEN
2085   PROCwimp_error(werrtitle$,"Sorry, you can't use 'PROCwimp_recreatemenuarray' on a Font menu.",1,"",0,1,"")
2086 ELSE
2087   num%=FNwimp_getnumberofmessages(messagefilehandle%,token$)
2088   m$=FNwimp_messlookup(messagefilehandle%,token$+"T","","")
2089   IF m$="" THEN m$=FNwimp_messlookup(messagefilehandle%,token$+"t","","")
2090   IF m$<>"" THEN num%-=1
2091   IF title$="" THEN
2092     IF m$="" THEN m$=" "
2093   ELSE
2094     m$=title$
2095   ENDIF
2096   IF num%>FNwimp_menumaxsize(menu%) THEN
2097     PROCwimp_error(werrtitle$,"Sorry, you are trying to recreate a menu to a larger size than was allowed for when it was created.",1,"",0,1,"")
2098   ELSE
2099     width%=FNwint_titleblockandwidth(menu%,m$,1)
2100     ptr%=menu%+28
2101     FOR L%=1 TO num%
2102       m$=FNwimp_messlookup(messagefilehandle%,token$+STR$(L%),"","")
2103       itemlen%=FNwint_menuitemblockandwidth(ptr%,num%,L%,m$,1)
2104       IF itemlen%>width% THEN width%=itemlen%
2105       ptr%+=24
2106     NEXT L%
2107     menu%!16=width%+16
2108   ENDIF
2109 ENDIF
2110 ENDPROC
2111 :
2112 DEF FNwimp_getnumberofmessages(messagefilehandle%,token$)
2113 LOCAL number%,move%,next%
2114 number%=0
2115 move%=0
2116 REPEAT
2117   SYS "MessageTrans_EnumerateTokens",messagefilehandle%,token$+"*",wMessageout%,256,move% TO ,,next%,,move%
2118   number%+=1
2119 UNTIL next%=0
2120 =number%-1
2121 :
2122 DEF FNwint_getmenuarraysize(array$())
2123 LOCAL count%
2124 count%=0
2125 REPEAT
2126   count%+=1
2127 UNTIL array$(count%)="END"
2128 =count%-1
2129 :
2130 DEF FNwint_titleblockandwidth(menu%,title$,recreate%)
2131 LOCAL titlelen%,titlebuff%,oldtitlelen%,width%
2132 titlelen%=LEN(title$)
2133 IF recreate%=1 THEN
2134   titlebuff%=!menu%
2135   oldtitlelen%=(menu%!8)-1
2136   IF titlelen%>oldtitlelen% THEN DIM titlebuff% titlelen%
2137 ELSE
2138   DIM titlebuff% titlelen%
2139 ENDIF
2140 $titlebuff%=title$
2141 menu%!0=titlebuff%
2142 menu%!8=titlelen%+1
2143 width%=(titlelen%)*16
2144 menu%!12=&00070207
2145 menu%!20=44
2146 menu%!24=0
2147 =width%
2148 :
2149 DEF FNwint_menuitemblockandwidth(pointer%,number%,item%,item$,recreate%)
2150 LOCAL mflags%,itemlen%,itemtext%,olditemlen%
2151 CASE item% OF
2152   WHEN 1: IF item%=number% THEN mflags%=&188 ELSE mflags%=&108
2153   WHEN number%: mflags%=&88
2154   OTHERWISE: mflags%=8
2155 ENDCASE
2156 !pointer%=mflags%
2157 pointer%!4=-1
2158 pointer%!8=&07000121
2159 itemlen%=LEN(item$)
2160 IF recreate%=1 THEN
2161   itemtext%=pointer%!12
2162   olditemlen%=pointer%!20-1
2163   IF itemlen%>olditemlen% THEN DIM itemtext% itemlen%
2164 ELSE
2165   DIM itemtext% itemlen%
2166 ENDIF
2167 $(itemtext%)=item$
2168 pointer%!12=itemtext%
2169 pointer%!16=-1
2170 pointer%!20=itemlen%+1
2171 itemlen%=(LEN(item$)+1)*16
2172 =itemlen%
2173 :
2174 DEF PROCwint_menuextraitems(pointer%,extra%)
2175 LOCAL L%,item$,itemlen%,itemtext%
2176 FOR L%=1 TO extra%
2177   item$=" "
2178   itemlen%=LEN(item$)
2179   DIM itemtext% itemlen%
2180   $(itemtext%)=item$
2181   pointer%!12=itemtext%
2182   pointer%!16=-1
2183   pointer%!20=itemlen%+1
2184   pointer%+=24
2185 NEXT
2186 ENDPROC
2187 :
2188 DEF FNwimp_menusize(menu%)
2189 LOCAL wptr%,end%,count%,flag%
2190 end%=FALSE
2191 wptr%=menu%+4
2192 count%=0
2193 REPEAT
2194   wptr%+=24
2195   count%+=1
2196   flag%=wptr%!0
2197   flag%=flag%>>7
2198   IF (flag% AND 1)=1 THEN end%=TRUE
2199 UNTIL end%=TRUE
2200 =count%
2201 :
2202 DEF FNwimp_menumaxsize(menu%)
2203 return%=0
2204 IF !(menu%-4)=-1 THEN
2205   PROCwimp_error(werrtitle$,"Sorry, you can't use 'FNwimp_menumaxsize' on a Font menu. 0 will be returned.",1,"",0,1,"")
2206 ELSE
2207   return%=!(menu%-4)
2208 ENDIF
2209 =return%
2210 :
2211 DEF FNwimp_getmenutick(menu%,item%)
2212 LOCAL return%,wptr%
2213 IF !(menu%-4)=-1 THEN
2214   PROCwimp_error(werrtitle$,"Sorry, you can't use 'FNwimp_getmenutick' with a Font menu. The return will be 0.",1,"",0,1,"")
2215   return%=0
2216 ELSE
2217   wptr%=(menu%+28)+(24*(item%-1))
2218   return%=wptr%!0 AND 1
2219 ENDIF
2220 =return%
2221 :
2222 DEF PROCwimp_menutick(menu%,item%,state%)
2223 LOCAL wptr%
2224 IF !(menu%-4)=-1 THEN
2225   PROCwimp_error(werrtitle$,"Sorry, you can't use 'PROCwimp_menutick' to alter a Font menu.",1,"",0,1,"")
2226 ELSE
2227   IF state%<0 OR state%>2 THEN state%=1
2228   wptr%=(menu%+28)+(24*(item%-1))
2229   CASE state% OF
2230     WHEN 0:?wptr%=?wptr% AND &FE
2231     WHEN 1:?wptr%=?wptr% OR 1
2232     WHEN 2:?wptr%=?wptr% EOR 1
2233   ENDCASE
2234 ENDIF
2235 ENDPROC
2236 :
2237 DEF PROCwimp_menuenable(menu%,item%,state%)
2238 LOCAL wptr%
2239 IF !(menu%-4)=-1 THEN
2240   PROCwimp_error(werrtitle$,"Sorry, you can't use 'PROCwimp_menuenable' to alter a Font menu.",1,"",0,1,"")
2241 ELSE
2242   IF state%<0 OR state%>2 THEN state%=1
2243   wptr%=(menu%+28)+(24*(item%-1))
2244   CASE state% OF
2245     WHEN 0:wptr%!8=wptr%!8 OR (1<<22)
2246     WHEN 1:wptr%!8=wptr%!8 OR (1<<22)
2247     wptr%!8=wptr%!8 EOR (1<<22)
2248     WHEN 2:wptr%!8=wptr%!8 EOR (1<<22)
2249   ENDCASE
2250 ENDIF
2251 ENDPROC
2252 :
2253 DEF FNwimp_getmenuenable(menu%,item%)
2254 LOCAL return%,wptr%
2255 return%=0
2256 IF !(menu%-4)=-1 THEN
2257   PROCwimp_error(werrtitle$,"Sorry, you can't use 'FNwimp_getmenuenable' with a Font menu. The return will be 0.",1,"",0,1,"")
2258 ELSE
2259   wptr%=(menu%+28)+(24*(item%-1))
2260   return%=1-(wptr%!8>>22 AND 1)
2261 ENDIF
2262 =return%
2263 :
2264 DEF PROCwimp_menudottedline(menu%,item%,on%)
2265 LOCAL wptr%
2266 IF !(menu%-4)=-1 THEN
2267   PROCwimp_error(werrtitle$,"Sorry, you can't use 'PROCwimp_menudottedline' to alter a Font menu.",1,"",0,1,"")
2268 ELSE
2269   wptr%=(menu%+28)+(24*(item%-1))
2270   ?wptr%=(?wptr%) OR 1<<1
2271   IF on%=0 THEN
2272     ?wptr%=(?wptr%) EOR 1<<1
2273   ENDIF
2274 ENDIF
2275 ENDPROC
2276 :
2277 DEF FNwimp_getmenudottedline(menu%,item%)
2278 LOCAL return%,wptr%
2279 return%=0
2280 IF !(menu%-4)=-1 THEN
2281   PROCwimp_error(werrtitle$,"Sorry, you can't use 'FNwimp_getmenudottedline' with a Font menu. The return will be 0.",1,"",0,1,"")
2282 ELSE
2283   wptr%=(menu%+28)+(24*(item%-1))
2284   return%=((wptr%!0>>1) AND 1)
2285 ENDIF
2286 =return%
2287 :
2288 DEF PROCwimp_menuitemcolour(menu%,item%,colour%,background%)
2289 LOCAL ptr%,mask%,offset%
2290 IF !(menu%-4)=-1 THEN
2291   PROCwimp_error(werrtitle$,"Sorry, you can't use 'PROCwimp_menuitemcolour' to alter a Font menu.",1,"",0,1,"")
2292 ELSE
2293   ptr%=(menu%+28)+(24*(item%-1))
2294   IF background%=0 THEN
2295     offset%=24
2296     mask%=&F0FFFFFF
2297   ELSE
2298     offset%=28
2299     mask%=&0FFFFFFF
2300   ENDIF
2301   ptr%!8=ptr%!8 AND mask%
2302   ptr%!8=ptr%!8 OR (colour%<<offset%)
2303 ENDIF
2304 ENDPROC
2305 :
2306 DEF FNwimp_getmenutitle(menu%)
2307 LOCAL return$
2308 IF !(menu%-4)=-1 THEN
2309   PROCwimp_error(werrtitle$,"Sorry, you can't use 'FNwimp_getmenutitle' with a Font menu. The return will be a null string.",1,"",0,1,"")
2310   return$=""
2311 ELSE
2312   return$=FNwint_string(menu%!0)
2313 ENDIF
2314 =return$
2315 :
2316 DEF PROCwimp_putmenutitle(menu%,title$)
2317 LOCAL titlebuff%,newtitlelen%,oldtitlelen%
2318 IF !(menu%-4)=-1 THEN
2319   PROCwimp_error(werrtitle$,"Sorry, you can't use 'PROCwimp_putmenutitle' to alter a Font menu.",1,"",0,1,"")
2320 ELSE
2321   IF title$="" THEN title$=" "
2322   newtitlelen%=LEN(title$)
2323   titlebuff%=!menu%
2324   oldtitlelen%=menu%!8-1
2325   IF newtitlelen%>oldtitlelen% THEN DIM titlebuff% newtitlelen%
2326   !menu%=titlebuff%
2327   $titlebuff%=title$
2328   menu%!8=newtitlelen%+1
2329   PROCwint_calcmenuwidth(menu%)
2330 ENDIF
2331 ENDPROC
2332 :
2333 DEF FNwimp_getmenutext(menu%,item%)
2334 LOCAL p%,return$
2335 IF !(menu%-4)=-1 THEN
2336   PROCwimp_error(werrtitle$,"Sorry, you can't use 'FNwimp_getmenutext' with a Font menu. The return will be a null string.",1,"",0,1,"")
2337   return$=""
2338 ELSE
2339   p%=28+12+((item%-1)*24)
2340   return$=FNwint_string(menu%!p%)
2341 ENDIF
2342 =return$
2343 :
2344 DEF PROCwimp_putmenutext(menu%,item%,text$)
2345 LOCAL p%,itemtext%,newitemlen%,olditemlen%,writable%,itemlen%
2346 IF !(menu%-4)=-1 THEN
2347   PROCwimp_error(werrtitle$,"Sorry, you can't use 'PROCwimp_putmenutext' to alter a Font menu.",1,"",0,1,"")
2348 ELSE
2349   newitemlen%=LEN(text$)
2350   p%=28+12+((item%-1)*24)
2351   itemtext%=menu%!p%
2352   olditemlen%=menu%!(p%+8)-1
2353   writable%=(menu%!(p%-12)>>2) AND 1
2354   IF newitemlen%>olditemlen% THEN
2355     itemlen%=newitemlen%
2356     DIM itemtext% itemlen%
2357   ELSE
2358     IF writable%=1 THEN
2359       itemlen%=olditemlen%
2360     ELSE
2361       itemlen%=newitemlen%
2362     ENDIF
2363   ENDIF
2364   menu%!p%=itemtext%
2365   $(itemtext%)=text$
2366   menu%!(p%+8)=itemlen%+1
2367   PROCwint_calcmenuwidth(menu%)
2368 ENDIF
2369 ENDPROC
2370 :
2371 DEF PROCwimp_putmenuitem(menu%,item%,text$)
2372 LOCAL num%,ptr%,submenu%,L%,M%,itemtext%,itemlen%
2373 IF !(menu%-4)=-1 THEN
2374   PROCwimp_error(werrtitle$,"Sorry, you can't use 'PROCwimp_putmenuitem' to alter a Font menu.",1,"",0,1,"")
2375 ELSE
2376   num%=FNwimp_menusize(menu%)
2377   IF num%<FNwimp_menumaxsize(menu%) THEN
2378     IF item%>(num%+1) THEN item%=num%+1
2379     IF item%<1 THEN item%=1
2380     ptr%=menu%+4
2381     IF item%=num%+1 THEN
2382       ptr%+=24*num%
2383       ptr%!0=ptr%!0 OR (1<<7)
2384       ptr%!0=ptr%!0 EOR (1<<7)
2385       ptr%+=24
2386       ptr%!0=&88
2387     ELSE
2388       ptr%+=24*(num%+1)
2389       FOR L%=(num%+1) TO (item%+1) STEP -1
2390         FOR M%=0 TO 20 STEP 4
2391           ptr%!M%=ptr%!(M%-24)
2392         NEXT M%
2393         IF L%=2 THEN
2394           ptr%!0=ptr%!0 OR (1<<8)
2395           ptr%!0=ptr%!0 EOR (1<<8)
2396         ENDIF
2397         ptr%-=24
2398       NEXT L%
2399       ptr%=(menu%+4)+(24*item%)
2400       IF item%=1 THEN
2401         ptr%!0=&108
2402       ELSE
2403         ptr%!0=&8
2404       ENDIF
2405     ENDIF
2406     ptr%!4=-1
2407     ptr%!8=&07000121
2408     ptr%!16=-1
2409     itemlen%=LEN(text$)
2410     DIM itemtext% itemlen%
2411     $itemtext%=text$
2412     ptr%!12=itemtext%
2413     ptr%!20=itemlen%+1
2414     PROCwint_calcmenuwidth(menu%)
2415   ELSE
2416     PROCwimp_error(werrtitle$,"Sorry, but this menu already has the maximum number of items specified when it was first created.",1,"",0,1,"")
2417   ENDIF
2418 ENDIF
2419 ENDPROC
2420 :
2421 DEF PROCwimp_removemenuitem(menu%,item%)
2422 LOCAL num%,M%,L%,ptr%
2423 IF !(menu%-4)=-1 THEN
2424   PROCwimp_error(werrtitle$,"Sorry, you can't use 'PROCwimp_removemenuitem' to alter a Font menu.",1,"",0,1,"")
2425 ELSE
2426   num%=FNwimp_menusize(menu%)
2427   IF num%<>1 THEN
2428     IF item%<1 THEN item%=1
2429     IF item%>num% THEN item%=num%
2430     ptr%=menu%+4
2431     IF item%=num% THEN
2432       ptr%+=24*(item%-1)
2433       ptr%!0=(ptr%!0 OR (1<<7))
2434     ELSE
2435       ptr%+=24*item%
2436       FOR L%=item% TO num%-1
2437         FOR M%=0 TO 20 STEP 4
2438           ptr%!M%=ptr%!(M%+24)
2439         NEXT M%
2440         ptr%+=24
2441       NEXT L%
2442     ENDIF
2443     menu%!28=menu%!28 OR (1<<8)
2444     PROCwint_calcmenuwidth(menu%)
2445   ENDIF
2446 ENDIF
2447 ENDPROC
2448 :
2449 DEF FNwimp_getmenuitem(menu%,menutext$)
2450 LOCAL return%,match%,menusize%,item%
2451 IF !(menu%-4)=-1 THEN
2452   PROCwimp_error(werrtitle$,"Sorry, you can't use 'FNwimp_getmenuitem' with a Font menu. The return will be 0.",1,"",0,1,"")
2453   return%=0
2454 ELSE
2455   return%=0
2456   match%=FALSE
2457   menusize%=FNwimp_menusize(menu%)
2458   item%=0
2459   REPEAT
2460     item%+=1
2461     IF FNwimp_changecase(menutext$,0)=FNwimp_changecase(FNwimp_getmenutext(menu%,item%),0) THEN match%=TRUE
2462   UNTIL match%=TRUE OR item%=menusize%
2463   IF match%=TRUE THEN return%=item%
2464 ENDIF
2465 =return%
2466 :
2467 DEF PROCwimp_menuwrite(menu%,item%,maxlen%,border%,valid$)
2468 LOCAL num%,currenttext$,itemtext%
2469 IF !(menu%-4)=-1 THEN
2470   PROCwimp_error(werrtitle$,"Sorry, you can't use 'PROCwimp_menuwrite' to alter a Font menu.",1,"",0,1,"")
2471 ELSE
2472   num%=FNwimp_menusize(menu%)
2473   IF item%>num% THEN item%=num%
2474   IF item%<1 THEN item%=1
2475   p%=28+12+((item%-1)*24)
2476   itemtext%=menu%!p%
2477   currenttext$=FNwint_string(itemtext%)
2478   IF LEN(currenttext$)>maxlen% THEN maxlen%=LEN(currenttext$)
2479   DIM itemtext% maxlen%
2480   DIM valid% 47
2481   $(valid%)="Pptr_write;Knar;"+valid$
2482   menu%!p%=itemtext%
2483   $(itemtext%)=currenttext$
2484   menu%!(p%+4)=valid%
2485   menu%!(p%+8)=maxlen%+1
2486   menu%!(p%-12)=menu%!(p%-12) OR 1<<2
2487   menu%?(p%-4)=menu%?(p%-4) OR 1<<2
2488   IF border%=0 THEN menu%?(p%-4)=(menu%?(p%-4) EOR 1<<2)
2489   PROCwint_calcmenuwidth(menu%)
2490 ENDIF
2491 ENDPROC
2492 :
2493 DEF PROCwimp_menupopup(menu%,pos%,x%,y%)
2494 LOCAL xpos%,ypos%,xmax%,ymax%,whan%,menuicon%,yalt%
2495 IF (menu% AND 1)=0 THEN
2496   IF !(menu%-4)=-1 THEN wFONTMENU%=menu%
2497 ENDIF
2498 SYS "Wimp_GetPointerInfo",,wimp%
2499 xpos%=wimp%!0
2500 ypos%=wimp%!4
2501 whan%=wimp%!12
2502 wHoldwhan%=whan%
2503 menuicon%=wimp%!16
2504 IF pos%=4 AND menuicon%<0 THEN pos%=3
2505 PROCwint_savewimp2
2506 PROCuser_menuopen(menu%,wHoldwhan%,menuicon%)
2507 PROCwint_loadwimp2
2508 CASE pos% OF
2509   WHEN 1
2510   yalt%=FNwint_iconbardottedlinemenusize(menu%)
2511   SYS "Wimp_CreateMenu",,menu%,x%-64,yalt%
2512   WHEN 2    : PROCwint_centremenu(menu%)
2513   WHEN 3    : SYS "Wimp_CreateMenu",,menu%,xpos%+54,ypos%+20
2514   WHEN 4
2515   wimp%!0=whan%
2516   wimp%!4=menuicon%
2517   SYS "Wimp_GetIconState",,wimp%
2518   xmax%=wimp%!16
2519   ymax%=wimp%!20
2520   SYS "Wimp_CreateMenu",,menu%,FNwimp_worktoscreen(whan%,xmax%,0),FNwimp_worktoscreen(whan%,ymax%,1)
2521   OTHERWISE : SYS "Wimp_CreateMenu",,menu%,x%,y%
2522 ENDCASE
2523 PROCwint_checksavewindow(menu%)
2524 wLastmenu%=menu%
2525 ENDPROC
2526 :
2527 DEF PROCwimp_menuclose
2528 SYS "Wimp_CreateMenu",,-1
2529 ENDPROC
2530 :
2531 DEF PROCwimp_attachsubmenu(menu%,item%,sub%)
2532 !(menu%+8+(item%*24))=sub%
2533 ENDPROC
2534 :
2535 DEF FNwimp_createfontmenu
2536 LOCAL size%,ind%,fontdyn%,fontmenu%,fontind%
2537 SYS "Font_ListFonts",,0,&80000,,0 TO ,,,size%,,ind%
2538 fontdyn%=FNwimp_createdynamic(size%+8,200000,0,"FontDyn")
2539 fontind%=FNwimp_createdynamic(ind%,100000,0,"FontInd")
2540 fontdyn%!0=fontind%
2541 fontdyn%!4=-1
2542 fontmenu%=fontdyn%+8
2543 SYS "Font_ListFonts",,fontmenu%,&80000,size%,fontind%,ind%
2544 =fontmenu%
2545 :
2546 DEF FNwimp_recreatefontmenu(fontmenu%)
2547 LOCAL oldfontdyn%,oldind%,size%,ind%,newfontdyn%,newind%,newfontmenu%
2548 oldind%=!(fontmenu%-8)
2549 oldfontdyn%=fontmenu%-8
2550 SYS "Font_ListFonts",,0,&80000,,0 TO ,,,size%,,ind%
2551 newfontdyn%=FNwimp_changedynamic(oldfontdyn%,1,size%+8)
2552 newind%=FNwimp_changedynamic(oldind%,1,ind%)
2553 newfontdyn%!0=newind%
2554 newfontdyn%!4=-1
2555 newfontmenu%=newfontdyn%+8
2556 SYS "Font_ListFonts",,newfontmenu%,&80000,size%,newind%,ind%
2557 =newfontmenu%
2558 :
2559 :
2560 :
2561 DEF PROCwint_calcmenuwidth(menu%)
2562 LOCAL title$,width%,wptr%,writable%,itemlen%,item$,flag%
2563 title$=FNwint_string(menu%!0)
2564 width%=(LEN(title$))*16
2565 wptr%=menu%+28
2566 REPEAT
2567   writable%=(wptr%!0>>2) AND 1
2568   IF writable%=1 THEN
2569     itemlen%=(wptr%!20)-1
2570   ELSE
2571     item$=FNwint_string(wptr%!12)
2572     itemlen%=LEN(item$)
2573   ENDIF
2574   IF (itemlen%*16)>width% THEN width%=(itemlen%)*16
2575   flag%=!wptr%
2576   flag%=(flag%>>7)
2577   wptr%+=24
2578 UNTIL (flag% AND 1) =1
2579 menu%!16=width%+16
2580 ENDPROC
2581 :
2582 DEF FNwint_numberofentries(menu$)
2583 LOCAL total%,L%
2584 total%=1
2585 FOR L%=1 TO LEN(menu$)
2586   IF MID$(menu$,L%,1)="/" THEN total%+=1
2587 NEXT L%
2588 =total%
2589 :
2590 DEF FNwint_decodemenuentry(menu$,item%)
2591 LOCAL M%,count%,omenu$
2592 M%=0
2593 count%=1
2594 REPEAT
2595   IF MID$(menu$,M%,1)="/" THEN count%+=1
2596   M%+=1
2597 UNTIL count%=item%
2598 omenu$=menu$
2599 omenu$=RIGHT$(omenu$,LEN(omenu$)-(M%-1))
2600 count%=INSTR(omenu$,"/")
2601 IF count%>0 THEN omenu$=LEFT$(omenu$,count%-1)
2602 =omenu$
2603 :
2604 DEF PROCwint_getmenuanditem(mainmenu%,RETURN menu%,RETURN item%)
2605 LOCAL ptr%
2606 IF (wimp%!4)=-1 THEN
2607   menu%=mainmenu%
2608   item%=(wimp%!0)+1
2609 ELSE
2610   ptr%=0
2611   menu%=mainmenu%
2612   REPEAT
2613     menu%=FNwint_findsubmenuptr(menu%,(wimp%!ptr%)+1)
2614     ptr%+=4
2615   UNTIL (wimp%!(ptr%+4))=-1
2616   item%=(wimp%!ptr%)+1
2617 ENDIF
2618 ENDPROC
2619 :
2620 DEF FNwint_findsubmenuptr(menu%,item%)
2621 LOCAL wptr%
2622 wptr%=menu%+4
2623 wptr%+=24*item%
2624 =wptr%!4
2625 :
2626 DEF PROCwint_centremenu(menu%)
2627 LOCAL x0%,y0%,x1%,y1%,wwidth%,wheight%,swidth%,sheight%,x%,y%
2628 wimp%!0=menu%
2629 SYS "XWimp_GetWindowInfo",,(wimp% OR %1) TO ;flag%
2630 IF (flag% AND 1)=1 THEN
2631   wwidth%=menu%!16
2632   wheight%=44*(FNwimp_menusize(menu%)+1)
2633 ELSE
2634   x0%=wimp%!4:y0%=wimp%!8
2635   x1%=wimp%!12:y1%=wimp%!16
2636   wwidth%=x1%-x0%
2637   wheight%=y1%-y0%
2638 ENDIF
2639 swidth%=FNwimp_getscreensize(0)
2640 sheight%=FNwimp_getscreensize(1)
2641 x%=(swidth%-wwidth%)/2
2642 y%=((sheight%-wheight%)/2)+wheight%
2643 SYS "Wimp_CreateMenu",,menu%,x%,y%
2644 ENDPROC
2645 :
2646 DEF PROCwint_opensubmenu(submenuhandle%,x%,y%,rootmenuitem%)
2647 LOCAL submenunumber%,position%,parentmenuitem%
2648 submenunumber%=0
2649 REPEAT
2650   submenunumber%+=1
2651   position%=(32+(4*(submenunumber%)))
2652 UNTIL wimp%!position%=-1
2653 parentmenuitem%=wimp%!(32+(4*(submenunumber%-1)))
2654 wSubmenu%=submenuhandle%
2655 IF (wSubmenu% AND 1)=0 THEN
2656   IF !(wSubmenu%-4)=-1 THEN wFONTMENU%=wSubmenu%
2657 ENDIF
2658 PROCuser_overmenuarrow(wLastmenu%,rootmenuitem%+1,wSubmenu%,submenunumber%,parentmenuitem%+1,x%,y%)
2659 IF wSubmenu% <> wSUBMENUCOLOURPICKER% THEN
2660   SYS "Wimp_CreateSubMenu",,wSubmenu%,x%,y%
2661   PROCwint_checksavewindow(wSubmenu%)
2662   IF wSubmenu%=wFONTMENU% THEN
2663     wFontmenudepth%=submenunumber%
2664     wReopened%=FALSE
2665   ELSE
2666     wFontmenudepth%=0
2667   ENDIF
2668 ENDIF
2669 ENDPROC
2670 :
2671 DEF FNwint_fontmenutree
2672 LOCAL Return%
2673 Return%=TRUE
2674 FOR N%=1 TO wFontmenudepth%
2675   IF wMenutree%(N%) <> !(wimp%+4*(N%-1)) THEN Return%=FALSE
2676 NEXT
2677 IF !(wimp%+4*(wFontmenudepth%))=-1 THEN Return%=FALSE
2678 IF wLastmenu%<>wHeldmenu% THEN Return%=FALSE
2679 =Return%
2680 :
2681 DEF FNwint_fontmenuused
2682 LOCAL Return%
2683 Return%=TRUE
2684 IF !(wimp%+4*(wFontmenudepth%))=-1 THEN Return%=FALSE
2685 =Return%
2686 :
2687 DEF FNwimp_initmessages(file$)
2688 LOCAL size%,buffer%,messages%,f%,flag%
2689 messages%=-1
2690 IF wMessagefilecount%=wMaxMessagefiles% THEN
2691   PROCwimp_error(werrtitle$,"There are already "+STR$(wMaxMessagefiles%)+" Messages files initiated. You will need to increase the number allowed. (See Section 2.9 of Manual)",1,"",0,1,"")
2692 ELSE
2693   SYS "XMessageTrans_FileInfo",,file$ TO ,,size%;f%
2694   flag%=(f% AND 1)
2695   IF flag%=0 THEN
2696     DIM buffer% size%-1
2697     DIM messages% 255
2698     $(messages%+16)=file$
2699     SYS "MessageTrans_OpenFile",messages%,messages%+16,buffer%
2700     wMessagefilecount%+=1
2701     wMessagehandles%(wMessagefilecount%,0)=messages%
2702     wMessagehandles%(wMessagefilecount%,1)=buffer%
2703     wMessagehandles%(wMessagefilecount%,2)=size%
2704     IF wMessageout%=-1 THEN DIM wMessageout% 255
2705   ELSE
2706     PROCwimp_error(werrtitle$,"Sorry, a file called "+file$+" cannot be found.",1,"",0,0,"Quit "+wappname$)
2707     PROCwimp_closedown:END
2708   ENDIF
2709 ENDIF
2710 =messages%
2711 :
2712 DEF FNwimp_reinitmessages(messhandle%,newfile$)
2713 LOCAL oldsize%,newsize%,buffer%,count%,f%,flag%
2714 count%=0
2715 REPEAT
2716   count%+=1
2717 UNTIL messhandle%=wMessagehandles%(count%,0)
2718 buffer%=wMessagehandles%(count%,1)
2719 oldsize%=wMessagehandles%(count%,2)
2720 SYS "MessageTrans_CloseFile",messhandle%
2721 SYS "XMessageTrans_FileInfo",,newfile$ TO ,,newsize%;f%
2722 flag%=(f% AND 1)
2723 IF flag%=0 THEN
2724   IF newsize%>oldsize% THEN
2725     DIM buffer% newsize%-1
2726   ENDIF
2727   $(messhandle%+16)=newfile$
2728   SYS "MessageTrans_OpenFile",messhandle%,messhandle%+16,buffer%
2729   wMessagehandles%(count%,0)=messhandle%
2730   wMessagehandles%(count%,1)=buffer%
2731   IF newsize%>oldsize% THEN
2732     wMessagehandles%(count%,2)=newsize%
2733   ENDIF
2734 ELSE
2735   PROCwimp_error(werrtitle$,"Sorry, a file called "+newfile$+" cannot be found.",1,"",0,0,"Quit "+wappname$)
2736   PROCwimp_closedown:END
2737 ENDIF
2738 =messhandle%
2739 :
2740 DEF FNwimp_messlookup(messhandle%,token$,p1$,p2$)
2741 LOCAL type%,value$,f%
2742 IF p1$<>"" THEN
2743   type%+=1
2744   IF p2$<>"" THEN type%+=1
2745 ENDIF
2746 CASE type% OF
2747   WHEN 0 : SYS "XMessageTrans_Lookup",messhandle%,token$,wMessageout%,256,0,0,0,0 TO ,,value$ ;f%
2748   WHEN 1 : SYS "XMessageTrans_Lookup",messhandle%,token$,wMessageout%,256,p1$,0,0,0 TO ,,value$ ;f%
2749   WHEN 2 : SYS "XMessageTrans_Lookup",messhandle%,token$,wMessageout%,256,p1$,p2$,0,0 TO ,,value$ ;f%
2750 ENDCASE
2751 IF (f% AND 1)=1 THEN value$=""
2752 =value$
2753 :
2754 DEF PROCwint_closemessagefiles
2755 LOCAL N%
2756 IF wMessagefilecount%>0 THEN
2757   FOR N%=1 TO wMessagefilecount%
2758     SYS "MessageTrans_CloseFile",wMessagehandles%(N%,0)
2759   NEXT
2760 ENDIF
2761 ENDPROC
2762 :
2763 DEF FNwimp_countsprites(spritearea%)
2764 =!(spritearea%+4)
2765 :
2766 DEF FNwimp_loadsprites(spritefile$,address%,warning%)
2767 LOCAL filesize%
2768 filesize%=FNwimp_measurefile(spritefile$,warning%)
2769 IF filesize%>-1 THEN
2770   !address%=filesize%
2771   address%!8=16
2772   SYS "OS_SpriteOp",&10A,address%,spritefile$
2773 ELSE
2774   filesize%=0
2775 ENDIF
2776 =address%+filesize%
2777 :
2778 DEF PROCwimp_savesprites(savepath$,spritearea%)
2779 PROCwimp_hourglasson
2780 SYS "OS_SpriteOp",&10C,spritearea%,savepath$
2781 PROCwimp_hourglassoff
2782 ENDPROC
2783 :
2784 DEF FNwimp_getspritesize(spritename$,spritearea%,side%)
2785 LOCAL width%,height%,XEig%,YEig%,mode%,return%
2786 IF spritearea%=0 THEN
2787   SYS "Wimp_SpriteOp",40,spritearea%,spritename$ TO ,,,width%,height%,,mode%
2788 ELSE
2789   SYS "OS_SpriteOp",256+40,spritearea%,spritename$ TO ,,,width%,height%,,mode%
2790 ENDIF
2791 SYS "OS_ReadModeVariable",mode%,4 TO ,,XEig%
2792 SYS "OS_ReadModeVariable",mode%,5 TO ,,YEig%
2793 width%=width%*(2^XEig%):height%=height%*(2^YEig%)
2794 IF side%=0 THEN
2795   return%=width%
2796 ELSE
2797   return%=height%
2798 ENDIF
2799 =return%
2800 :
2801 DEF FNwimp_getspritename(spritearea%,spritenumber%)
2802 SYS "OS_SpriteOp",256+13,spritearea%,wimp%,256,spritenumber%
2803 =FNwint_string(wimp%)
2804 :
2805 DEF PROCwimp_rendersprite(spritename$,spritearea%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal)
2806 LOCAL width%,height%,XEig%,YEig%,in%,xmult,ymult,xdiv,ydiv,mode%
2807 xscalereal=ABS(xscalereal)
2808 yscalereal=ABS(yscalereal)
2809 IF xscalereal=0 THEN xscalereal=1
2810 IF yscalereal=0 THEN yscalereal=1
2811 IF spritearea%=0 THEN
2812   SYS "Wimp_SpriteOp",40,,spritename$ TO ,,,width%,height%,,mode%
2813 ELSE
2814   SYS "OS_SpriteOp",256+40,spritearea%,spritename$ TO ,,,width%,height%,,mode%
2815 ENDIF
2816 SYS "OS_ReadModeVariable",mode%,4 TO ,,XEig%
2817 SYS "OS_ReadModeVariable",mode%,5 TO ,,YEig%
2818 SYS "OS_ReadModeVariable",mode%,9 TO ,,BPP%
2819 width%=width%*(2^XEig%)
2820 height%=height%*(2^YEig%)
2821 xmult=1
2822 ymult=1
2823 xdiv=1
2824 ydiv=1
2825 PROCwint_scalefactors(xscalereal,yscalereal,xmult,ymult,xdiv,ydiv)
2826 IF BPP%>2 THEN
2827   IF spritearea%=0 THEN
2828     SYS "Wimp_ReadPixTrans",&100,1,spritename$,,,,wScale%,0
2829     SYS "ColourTrans_SelectTable",mode%,-1,-1,-1,wSprcoltrans%
2830   ELSE
2831     SYS "Wimp_ReadPixTrans",&100,spritearea%,spritename$,,,,wScale%,0
2832     SYS "ColourTrans_SelectTable",spritearea%,spritename$,-1,-1,wSprcoltrans%,2
2833   ENDIF
2834 ELSE
2835   IF spritearea%=0 THEN
2836     SYS "Wimp_ReadPixTrans",&100,1,spritename$,,,,wScale%,wSprcoltrans%
2837   ELSE
2838     SYS "Wimp_ReadPixTrans",&100,spritearea%,spritename$,,,,wScale%,wSprcoltrans%
2839   ENDIF
2840 ENDIF
2841 wScale%!0=wScale%!0*xmult
2842 wScale%!4=wScale%!4*ymult
2843 wScale%!8=wScale%!8*xdiv
2844 wScale%!12=wScale%!12*ydiv
2845 in%=FNwint_checkbounds(bx%,by%,bx%+(width%*wScale%!0/wScale%!8),by%+(height%*wScale%!4/wScale%!12),minx%,miny%,maxx%,maxy%)
2846 IF in%=1 THEN
2847   IF spritearea%=0 THEN
2848     SYS "Wimp_SpriteOp",52,,spritename$,bx%,by%,8,wScale%,wSprcoltrans%
2849   ELSE
2850     SYS "OS_SpriteOp",256+52,spritearea%,spritename$,bx%,by%,%1000,wScale%,wSprcoltrans%
2851   ENDIF
2852 ENDIF
2853 ENDPROC
2854 :
2855 DEF PROCwimp_renderwindowsprite(whan%,spritename$,spritearea%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal)
2856 IF wPrinting%=FALSE THEN
2857   bx%=FNwimp_worktoscreen(whan%,bx%,0)
2858   by%=FNwimp_worktoscreen(whan%,by%,1)
2859 ENDIF
2860 PROCwimp_rendersprite(spritename$,spritearea%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal)
2861 ENDPROC
2862 :
2863 DEF PROCwimp_pointer(pointer%,spritearea%,pointer$)
2864 LOCAL ptr$
2865 IF pointer%=0 THEN ptr$="ptr_default"
2866 IF pointer%=1 THEN ptr$=pointer$
2867 pointer%+=1
2868 IF spritearea%=0 THEN
2869   PROCwint_pointerRMA(ptr$,pointer%)
2870 ELSE
2871   SYS "OS_SpriteOp",256+36,spritearea%,ptr$,pointer%
2872 ENDIF
2873 ENDPROC
2874 :
2875 DEF FNwimp_getpointerposition(coord%)
2876 LOCAL x%,y%,b%,return%
2877 MOUSE x%,y%,b%
2878 IF coord%=0 THEN
2879   return%=x%
2880 ELSE
2881   return%=y%
2882 ENDIF
2883 =return%
2884 :
2885 DEF PROCwimp_setpointerposition(x%,y%)
2886 wMouseblk%?0=3
2887 wMouseblk%?1=x% MOD 256:wMouseblk%?2=x% DIV 256
2888 wMouseblk%?3=y% MOD 256:wMouseblk%?4=y% DIV 256
2889 SYS "OS_Word",21,wMouseblk%
2890 ENDPROC
2891 :
2892 DEF PROCwimp_bindpointer(whan%)
2893 LOCAL v%
2894 wMouseblk%?0=1
2895 v%=FNwimp_getwindowvisiblescreen(whan%,0,0)
2896 wMouseblk%?1=v% MOD 256:wMouseblk%?2=v% DIV 256
2897 v%=FNwimp_getwindowvisiblescreen(whan%,1,0)
2898 wMouseblk%?3=v% MOD 256:wMouseblk%?4=v% DIV 256
2899 v%=FNwimp_getwindowvisiblescreen(whan%,0,1)
2900 wMouseblk%?5=v% MOD 256:wMouseblk%?6=v% DIV 256
2901 v%=FNwimp_getwindowvisiblescreen(whan%,1,1)
2902 wMouseblk%?7=v% MOD 256:wMouseblk%?8=v% DIV 256
2903 SYS "OS_Word",21,wMouseblk%
2904 ENDPROC
2905 :
2906 DEF PROCwimp_releasepointer
2907 wMouseblk%?0=1
2908 wMouseblk%?1=0 MOD 256:wMouseblk%?2=0 DIV 256
2909 wMouseblk%?3=0 MOD 256:wMouseblk%?4=0 DIV 256
2910 wMouseblk%?5=FNwimp_getscreensize(0) MOD 256
2911 wMouseblk%?6=FNwimp_getscreensize(0) DIV 256
2912 wMouseblk%?7=FNwimp_getscreensize(1) MOD 256
2913 wMouseblk%?8=FNwimp_getscreensize(1) DIV 256
2914 SYS "OS_Word",21,wMouseblk%
2915 ENDPROC
2916 :
2917 DEF PROCwint_pointerRMA(ptr$,pointer%)
2918 SYS "Wimp_SpriteOp",36,,ptr$,pointer%
2919 ENDPROC
2920 :
2921 DEF PROCwimp_initdfiles
2922 DIM wDcapjoin% 15
2923 DIM wDfn%(255),wDf$(255)
2924 ENDPROC
2925 :
2926 :
2927 REM CJ addition
2928 DEF PROCwimp_getdfileWandH(dfile%, RETURN wid%, RETURN ht%)
2929 REM RISC OS >= 3.5
2930 LOCAL realdfile%
2931 LOCAL xlow%,ylow%,xhigh%,yhigh%
2932 realdfile%=dfile%+4
2933 xlow%=realdfile%!24
2934 ylow%=realdfile%!28
2935 xhigh%=realdfile%!32
2936 yhigh%=realdfile%!36
2937 wid% = (xhigh% >> 8) - (xlow% >> 8)
2938 ht% = (yhigh% >> 8) - (ylow% >> 8)
2939 ENDPROC
2940 :
2941 :
2942 REM Getting draw file info
2943 DEF FNwimp_getdfilesize(dfile%,side%)
2944 LOCAL realdfile%
2945 LOCAL xlow%,ylow%,xhigh%,yhigh%
2946 realdfile%=dfile%+4
2947 return%=0
2948 xlow%=realdfile%!24
2949 ylow%=realdfile%!28
2950 xhigh%=realdfile%!32
2951 yhigh%=realdfile%!36
2952 IF side%=0 THEN
2953   = (xhigh% >> 8) - (xlow% >> 8)
2954 ELSE
2955   = (yhigh% >> 8) - (ylow% >> 8)
2956 ENDIF
2957 :
2958 :
2959 DEF FNwimp_loaddfile(dfilepath$,address%,warning%)
2960 =FNwimp_loadfile(dfilepath$,address%,warning%)
2961 :
2962 DEF PROCwimp_savedfile(path$,dfile%)
2963 PROCwimp_savefile(path$,dfile%,&AFF)
2964 ENDPROC
2965 :
2966 DEF PROCwimp_renderwindow(whan%,dfile%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal,origin%)
2967 IF wPrinting%=FALSE THEN
2968   bx%=FNwimp_worktoscreen(whan%,bx%,0)
2969   by%=FNwimp_worktoscreen(whan%,by%,1)
2970 ENDIF
2971 PROCwimp_render(dfile%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal,origin%)
2972 ENDPROC
2973 :
2974 DEF PROCwimp_render(dfile%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal,origin%)
2975 LOCAL dfilesize%,realdfile%
2976 dfilesize%=dfile%!0
2977 realdfile%=dfile%+4
2978 IF xscalereal=0 THEN xscalereal=1
2979 IF yscalereal=0 THEN yscalereal=1
2980 PROCwint_render360(realdfile%,dfilesize%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal,origin%)
2981 ENDPROC
2982 :
2983 DEF PROCwint_render360(realdfile%,dfilesize%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal,origin%)
2984 LOCAL xoffset%,yoffset%
2985 wDmatrix%!0=&10000*xscalereal
2986 wDmatrix%!4=0
2987 wDmatrix%!8=0
2988 wDmatrix%!12=&10000*yscalereal
2989 wDmatrix%!16=0
2990 wDmatrix%!20=0
2991 SYS "DrawFile_BBox",,realdfile%,dfilesize%,wDmatrix%,wDbbox%
2992 xoffset%=wDbbox%!0/256
2993 yoffset%=wDbbox%!4/256
2994 IF origin%=1 THEN
2995   bx%-=xoffset%
2996   by%-=yoffset%
2997 ENDIF
2998 wDmatrix%!16=bx%*256
2999 wDmatrix%!20=by%*256
3000 SYS "DrawFile_Render",0,realdfile%,dfilesize%,wDmatrix%,0
3001 ENDPROC
3002 :
3003 DEF FNwint_checkbounds(xlow%,ylow%,xhigh%,yhigh%,xbl%,ybl%,xtr%,ytr%)
3004 return%=0
3005 CASE TRUE OF
3006   WHEN (xlow%<=xbl% AND xhigh%>=xtr% AND ylow%<=ybl% AND yhigh%>=ytr%)
3007   return%=1
3008   WHEN (xlow%>=xbl% AND xlow%<=xtr% AND ylow%>=ybl% AND ylow%<=ytr%)
3009   return%=1
3010   WHEN (xhigh%>=xbl% AND xhigh%<=xtr% AND ylow%>=ybl% AND ylow%<=ytr%)
3011   return%=1
3012   WHEN (xlow%>=xbl% AND xlow%<=xtr% AND yhigh%>=ybl% AND yhigh%<=ytr%)
3013   return%=1
3014   WHEN (xhigh%>=xbl% AND xhigh%<=xtr% AND yhigh%>=ybl% AND yhigh%<=ytr%)
3015   return%=1
3016   WHEN (xlow%>=xbl% AND xlow%<=xtr% AND ylow%<=ybl% AND yhigh%>=ytr%)
3017   return%=1
3018   WHEN (xhigh%>=xbl% AND xhigh%<=xtr% AND ylow%<=ybl% AND yhigh%>=ytr%)
3019   return%=1
3020   WHEN (ylow%>=ybl% AND ylow%<=ytr% AND xlow%<=xbl% AND xhigh%>=xtr%)
3021   return%=1
3022   WHEN (yhigh%>=ybl% AND yhigh%<=ytr% AND xlow%<=xbl% AND xhigh%>=xtr%)
3023   return%=1
3024   WHEN (xlow%>xbl% AND xhigh%<xtr% AND ylow%>ybl% AND yhigh%<ytr%)
3025   return%=1
3026 ENDCASE
3027 =return%
3028 :
3029 DEF FNwimp_gettextsize(text$,font$,pointsizex,pointsizey,side%,scalex,scaley)
3030 LOCAL fhan%,f%,return%
3031 return%=0
3032 IF text$<>"" THEN
3033   SYS "XFont_FindFont",,font$,pointsizex*16,pointsizey*16 TO fhan% ;f%
3034   IF (f% AND 1)=1 THEN
3035     return%=0
3036   ELSE
3037     return%=FNwimp_gettextsizeh(text$,fhan%,side%,scalex,scaley)
3038     SYS "Font_LoseFont",fhan%
3039   ENDIF
3040 ENDIF
3041 =return%
3042 :
3043 DEF FNwimp_gettextsizeh(text$,fhan%,side%,scalex,scaley)
3044 LOCAL plotcode%,minx%,miny%,maxx%,maxy%,return%
3045 return%=0
3046 IF text$<>"" AND fhan%>0 THEN
3047   wTransformtext%!0=scalex*65536
3048   wTransformtext%!4=0
3049   wTransformtext%!8=0
3050   wTransformtext%!12=scaley*65536
3051   wTransformtext%!16=0
3052   wTransformtext%!20=0
3053   wBBox%!0=0
3054   wBBox%!4=0
3055   wBBox%!8=0
3056   wBBox%!12=0
3057   wBBox%!16=-1
3058   SYS "Font_SetFont",fhan%
3059   plotcode%=( 1<<18 OR 1<<8 OR 1<<6 OR 1<<5 )
3060   SYS "Font_ScanString",0,text$,plotcode%,&7FFFFFFF,&7FFFFFFF,wBBox%,wTransformtext%
3061   minx%=wBBox%!20
3062   miny%=wBBox%!24
3063   maxx%=wBBox%!28
3064   maxy%=wBBox%!32
3065   SYS "Font_ConverttoOS",,minx%,miny% TO ,minx%,miny%
3066   SYS "Font_ConverttoOS",,maxx%,maxy% TO ,maxx%,maxy%
3067   CASE side% OF
3068     WHEN 0
3069     return%=maxx%-minx%
3070     WHEN 1
3071     return%=maxy%-miny%
3072   ENDCASE
3073 ENDIF
3074 =return%
3075 :
3076 DEF FNwimp_getfont(font$,pointsizex,pointsizey)
3077 LOCAL fhan%,f%,return%
3078 SYS "XFont_FindFont",,font$,pointsizex*16,pointsizey*16 TO fhan% ;f%
3079 IF (f% AND 1)=1 THEN
3080   return%=0
3081 ELSE
3082   return%=fhan%
3083   wFontbuf%?fhan%+=1
3084 ENDIF
3085 =return%
3086 :
3087 DEF PROCwimp_losefont(fhan%)
3088 SYS "Font_LoseFont",fhan%
3089 wFontbuf%?fhan%-=1
3090 ENDPROC
3091 :
3092 DEF FNwimp_fontcolour(fr%,fg%,fb%,br%,bg%,bb%)
3093 =CHR$(19)+CHR$(br%)+CHR$(bg%)+CHR$(bb%)+CHR$(fr%)+CHR$(fg%)+CHR$(fb%)+CHR$(14)
3094 :
3095 DEF FNwimp_fontunderline(on%)
3096 LOCAL return$
3097 return$=""
3098 IF on%=0 THEN
3099   return$=CHR$25+CHR$0+CHR$0
3100 ELSE
3101   return$=CHR$25+CHR$240+CHR$10
3102 ENDIF
3103 =return$
3104 :
3105 DEF FNwimp_fontchangeh(fhan%)
3106 =CHR$26+CHR$fhan%
3107 :
3108 DEF PROCwimp_plotwindowtext(whan%,text$,font$,pointsizex,pointsizey,align%,x%,y%,fr%,fg%,fb%,br%,bg%,bb%,minx%,miny%,maxx%,maxy%,scalex,scaley,blending%)
3109 LOCAL h%,in%,fhan%,f%,width%
3110 IF wPrinting%=FALSE THEN
3111   x%=FNwimp_worktoscreen(whan%,x%,0)
3112   y%=FNwimp_worktoscreen(whan%,y%,1)
3113 ENDIF
3114 SYS "XFont_FindFont",,font$,pointsizex*16,pointsizey*16 TO fhan% ;f%
3115 IF (f% AND 1)=1 THEN
3116   SYS "Font_FindFont",,"Trinity.Medium",pointsizex*16,pointsizey*16,0,0 TO fhan%
3117 ENDIF
3118 h%=FNwimp_gettextsizeh(text$,fhan%,1,scalex,scaley)
3119 CASE align% OF
3120   WHEN 1
3121   width%=FNwimp_gettextsizeh(text$,fhan%,0,scalex,scaley)
3122   x%=x%-(width%/2)
3123   WHEN 2
3124   width%=FNwimp_gettextsizeh(text$,fhan%,0,scalex,scaley)
3125   x%=x%-width%
3126 ENDCASE
3127 in%=FNwint_checkbounds(x%,y%-0.25*h%,1E6,y%+h%,minx%,miny%,maxx%,maxy%)
3128 IF in%=1 THEN
3129   PROCwimp_plottexth(text$,fhan%,0,x%,y%,fr%,fg%,fb%,br%,bg%,bb%,scalex,scaley,blending%)
3130 ENDIF
3131 SYS "Font_LoseFont",fhan%
3132 ENDPROC
3133 :
3134 DEF PROCwimp_plotwindowtexth(whan%,text$,fhan%,align%,x%,y%,fr%,fg%,fb%,br%,bg%,bb%,minx%,miny%,maxx%,maxy%,scalex,scaley,blending%)
3135 LOCAL h%,in%,width%
3136 IF wPrinting%=FALSE THEN
3137   x%=FNwimp_worktoscreen(whan%,x%,0)
3138   y%=FNwimp_worktoscreen(whan%,y%,1)
3139 ENDIF
3140 h%=FNwimp_gettextsizeh(text$,fhan%,1,scalex,scaley)
3141 CASE align% OF
3142   WHEN 1
3143   width%=FNwimp_gettextsizeh(text$,fhan%,0,scalex,scaley)
3144   x%=x%-(width%/2)
3145   WHEN 2
3146   width%=FNwimp_gettextsizeh(text$,fhan%,0,scalex,scaley)
3147   x%=x%-width%
3148 ENDCASE
3149 in%=FNwint_checkbounds(x%,y%-0.25*h%,1E6,y%+h%,minx%,miny%,maxx%,maxy%)
3150 IF in%=1 THEN
3151   PROCwimp_plottexth(text$,fhan%,0,x%,y%,fr%,fg%,fb%,br%,bg%,bb%,scalex,scaley,blending%)
3152 ENDIF
3153 ENDPROC
3154 :
3155 DEF PROCwimp_plottext(text$,font$,pointsizex,pointsizey,align%,x%,y%,fr%,fg%,fb%,br%,bg%,bb%,scalex,scaley,blending%)
3156 LOCAL fhan%,f%,width%
3157 SYS "XFont_FindFont",,font$,pointsizex*16,pointsizey*16 TO fhan% ;f%
3158 IF (f% AND 1)=1 THEN
3159   SYS "Font_FindFont",,"Trinity.Medium",pointsizex*16,pointsizey*16,0,0 TO fhan%
3160 ENDIF
3161 CASE align% OF
3162   WHEN 1
3163   width%=FNwimp_gettextsizeh(text$,fhan%,0,scalex,scaley)
3164   x%=x%-(width%/2)
3165   WHEN 2
3166   width%=FNwimp_gettextsizeh(text$,fhan%,0,scalex,scaley)
3167   x%=x%-width%
3168 ENDCASE
3169 PROCwimp_plottexth(text$,fhan%,0,x%,y%,fr%,fg%,fb%,br%,bg%,bb%,scalex,scaley,blending%)
3170 SYS "Font_LoseFont",fhan%
3171 ENDPROC
3172 :
3173 DEF PROCwimp_plottexth(text$,fhan%,align%,x%,y%,fr%,fg%,fb%,br%,bg%,bb%,scalex,scaley,blending%)
3174 LOCAL width%
3175 CASE align% OF
3176   WHEN 1
3177   width%=FNwimp_gettextsizeh(text$,fhan%,0,scalex,scaley)
3178   x%=x%-(width%/2)
3179   WHEN 2
3180   width%=FNwimp_gettextsizeh(text$,fhan%,0,scalex,scaley)
3181   x%=x%-width%
3182 ENDCASE
3183 SYS "ColourTrans_SetFontColours",fhan%,(bb%<<24)+(bg%<<16)+(br%<<8),(fb%<<24)+(fg%<<16)+(fr%<<8),14
3184 wTransformtext%!0=scalex*65536
3185 wTransformtext%!4=0
3186 wTransformtext%!8=0
3187 wTransformtext%!12=scaley*65536
3188 wTransformtext%!16=0
3189 wTransformtext%!20=0
3190 SYS "Font_Converttopoints",,x%,y% TO ,x%,y%
3191 SYS "Font_CacheAddr" TO fontmanager%
3192 IF (fontmanager% < 335) OR (blending%=0) THEN
3193   plottype%=(1<<6)+(1<<9)
3194 ELSE
3195   plottype%=(1<<6)+(1<<9)+(1<<11)
3196 ENDIF
3197 SYS "Font_Paint",fhan%,text$,plottype%,x%,y%,,wTransformtext%
3198 ENDPROC
3199 :
3200 DEF PROCwimp_deskplotwindowtext(whan%,text$,align%,x%,y%,fr%,fg%,fb%,br%,bg%,bb%,minx%,miny%,maxx%,maxy%)
3201 LOCAL in%
3202 IF wPrinting%=FALSE THEN
3203   x%=FNwimp_worktoscreen(whan%,x%,0)
3204   y%=FNwimp_worktoscreen(whan%,y%,1)
3205 ENDIF
3206 in%=FNwint_checkbounds(x%,y%,1E6,y%+30,minx%,miny%,maxx%,maxy%)
3207 IF in%=1 THEN
3208   PROCwimp_deskplottext(text$,align%,x%,y%,fr%,fg%,fb%,br%,bg%,bb%)
3209 ENDIF
3210 ENDPROC
3211 :
3212 DEF PROCwimp_deskplottext(text$,align%,x%,y%,fr%,fg%,fb%,br%,bg%,bb%)
3213 LOCAL fore%,back%,width%
3214 fore%=(fr%<<8)+(fg%<<16)+(fb%<<24)
3215 back%=(br%<<8)+(bg%<<16)+(bb%<<24)
3216 SYS "Wimp_TextOp",0,fore%,back%
3217 CASE align% OF
3218   WHEN 1
3219   SYS "Wimp_TextOp",1,text$,0 TO width%
3220   SYS "Wimp_TextOp",2,text$,,,x%-(width%/2),y%
3221   WHEN 2
3222   SYS "Wimp_TextOp",2+(1<<31),text$,,,x%,y%
3223   OTHERWISE
3224   SYS "Wimp_TextOp",2,text$,,,x%,y%
3225 ENDCASE
3226 ENDPROC
3227 :
3228 DEF PROCwimp_print(user%,whan%,firstpage%,lastpage%,perpage%,interval%,copies%,orient%,xscale,yscale,order%,invert%)
3229 LOCAL file$,width%,height%,OSwidth%,OSheight%,olastpage%
3230 LOCAL anglereal,scalereal,p%,step%
3231 LOCAL wprnt%,prevprnt%,feat%,fontdec%
3232 LOCAL cancel%,copy%,page%,totpages%,pagepos%,L%
3233 LOCAL scalefactor1,scalefactor2,scalefactor3,scalefactor4,w%,h%
3234 LOCAL more%,cpage%
3235 IF firstpage%<1 THEN firstpage%=1
3236 IF perpage%<1 THEN perpage%=1
3237 IF perpage%>4 THEN perpage%=4
3238 IF perpage%=3 THEN perpage%=2
3239 IF interval%<1 THEN interval%=1
3240 IF copies%<1 THEN copies%=1
3241 IF xscale<0.05 THEN xscale=0.05
3242 IF yscale<0.05 THEN yscale=0.05
3243 IF order%<>0 THEN order%=1
3244 IF invert%<>0 THEN invert%=1
3245 PROCwimp_singlepoll
3246 LOCAL ERROR
3247 ON ERROR LOCAL:RESTORE ERROR:PROCwint_printerror(wprnt%,REPORT$,ERL):ENDPROC
3248 file$="printer:"
3249 SYS "PDriver_PageSize" TO ,width%,height%
3250 SYS "Font_ConverttoOS",,width%,height% TO ,OSwidth%,OSheight%
3251 olastpage%=lastpage%
3252 IF perpage%=4 THEN
3253   IF orient%=0 THEN
3254     IF invert%=0 THEN
3255       anglereal=0
3256     ELSE
3257       anglereal=180
3258     ENDIF
3259   ELSE
3260     IF invert%=0 THEN
3261       anglereal=90
3262     ELSE
3263       anglereal=270
3264     ENDIF
3265   ENDIF
3266   scalereal=50/100
3267   p%=(lastpage%-firstpage%+1) MOD 4
3268   IF p%<>0 THEN lastpage%+=4-p%
3269   step%=4
3270 ENDIF
3271 IF perpage%=2 THEN
3272   IF orient%=0 THEN
3273     IF invert%=0 THEN
3274       anglereal=90
3275     ELSE
3276       anglereal=270
3277     ENDIF
3278   ELSE
3279     IF invert%=0 THEN
3280       anglereal=0
3281     ELSE
3282       anglereal=180
3283     ENDIF
3284   ENDIF
3285   scalereal=FNwimp_getpapersize(0,0)/FNwimp_getpapersize(1,0)
3286   IF ((firstpage%-lastpage%+1) MOD 2)<>0 THEN lastpage%+=1
3287   step%=2
3288 ENDIF
3289 IF perpage%=1 THEN
3290   IF orient%=0 THEN
3291     IF invert%=0 THEN
3292       anglereal=0
3293     ELSE
3294       anglereal=180
3295     ENDIF
3296   ELSE
3297     IF invert%=0 THEN
3298       anglereal=90
3299     ELSE
3300       anglereal=270
3301     ENDIF
3302   ENDIF
3303   scalereal=1
3304   step%=1
3305 ENDIF
3306 wprnt%=OPENOUT(file$)
3307 SYS "PDriver_SelectJob",wprnt% TO prevprnt%
3308 SYS "PDriver_Info" TO ,,,feat%
3309 fontdec%=(feat%>>29 AND 1)
3310 IF fontdec% THEN
3311   PROCuser_declarefonts
3312   SYS "PDriver_DeclareFont",0,0,0
3313 ENDIF
3314 cancel%=0
3315 FOR copy%=1 TO copies%
3316   FOR page%=firstpage% TO lastpage% STEP step%*interval%
3317     SYS "Hourglass_On"
3318     IF cancel%=0 THEN
3319       SYS "PDriver_SelectJob",prevprnt%
3320       wPrinting%=FALSE
3321       IF perpage%=1 THEN
3322         totpages%=(lastpage%-firstpage%+1)*copies%
3323         pagepos%=page%+((copy%-1)*(lastpage%-firstpage%+1))-firstpage%+1
3324         cancel%=FNuser_printing(copy%,page%,totpages%,pagepos%)
3325         PROCwimp_singlepoll
3326       ELSE
3327         FOR L%=1 TO perpage%
3328           IF cancel%=0 THEN
3329             IF page%+(L%-1)<=olastpage% THEN
3330               totpages%=(olastpage%-firstpage%+1)*copies%
3331               pagepos%=page%+(L%-1)+((copy%-1)*(olastpage%-firstpage%+1))-firstpage%+1
3332               cancel%=FNuser_printing(copy%,page%,totpages%,pagepos%)
3333               PROCwimp_singlepoll
3334             ENDIF
3335           ENDIF
3336         NEXT L%
3337       ENDIF
3338       wPrinting%=TRUE
3339       SYS "PDriver_SelectJob",wprnt% TO prevprnt%
3340     ENDIF
3341     scalefactor1=(scalereal*(COSRADanglereal))*2^16
3342     scalefactor2=(scalereal*(SINRADanglereal))*2^16
3343     scalefactor3=(scalereal*(-SINRADanglereal))*2^16
3344     scalefactor4=(scalereal*(COSRADanglereal))*2^16
3345     IF cancel%=0 THEN
3346       IF perpage%=1 THEN
3347         IF orient%=0 THEN
3348           wPrintblock%!0=0
3349           wPrintblock%!4=0
3350           wPrintblock%!8=OSwidth%
3351           wPrintblock%!12=OSheight%
3352           wPrintblock%!16=xscale*scalefactor1
3353           wPrintblock%!20=yscale*scalefactor2
3354           wPrintblock%!24=xscale*scalefactor3
3355           wPrintblock%!28=yscale*scalefactor4
3356           IF invert%=0 THEN
3357             wPrintblock%!32=0
3358             wPrintblock%!36=0
3359           ELSE
3360             wPrintblock%!32=width%
3361             wPrintblock%!36=height%
3362           ENDIF
3363         ELSE
3364           wPrintblock%!0=0
3365           wPrintblock%!4=0
3366           wPrintblock%!8=OSheight%
3367           wPrintblock%!12=OSwidth%
3368           wPrintblock%!16=yscale*scalefactor1
3369           wPrintblock%!20=xscale*scalefactor2
3370           wPrintblock%!24=yscale*scalefactor3
3371           wPrintblock%!28=xscale*scalefactor4
3372           IF invert%=0 THEN
3373             wPrintblock%!32=width%
3374             wPrintblock%!36=0
3375           ELSE
3376             wPrintblock%!32=0
3377             wPrintblock%!36=height%
3378           ENDIF
3379         ENDIF
3380         SYS "PDriver_GiveRectangle",page%,wPrintblock%,wPrintblock%+16,wPrintblock%+32,&FFFFFF00
3381       ENDIF
3382       IF perpage%=2 THEN
3383         FOR L%=1 TO 2
3384           IF page%+(L%-1)<=olastpage% THEN
3385             w%=width%-(width%-(height%*scalereal))
3386             h%=height%/2
3387             IF orient%=0 THEN
3388               wPrintblock%!0=0
3389               wPrintblock%!4=0
3390               wPrintblock%!8=OSwidth%
3391               wPrintblock%!12=OSheight%
3392               wPrintblock%!16=yscale*scalefactor1
3393               wPrintblock%!20=xscale*scalefactor2
3394               wPrintblock%!24=yscale*scalefactor3
3395               wPrintblock%!28=xscale*scalefactor4
3396               CASE L% OF
3397                 WHEN 1
3398                 IF invert%=0 THEN
3399                   IF order%=0 THEN
3400                     wPrintblock%!32=w%
3401                     wPrintblock%!36=0
3402                   ELSE
3403                     wPrintblock%!32=w%
3404                     wPrintblock%!36=h%
3405                   ENDIF
3406                 ELSE
3407                   IF order%=0 THEN
3408                     wPrintblock%!32=0
3409                     wPrintblock%!36=h%
3410                   ELSE
3411                     wPrintblock%!32=0
3412                     wPrintblock%!36=2*h%
3413                   ENDIF
3414                 ENDIF
3415                 WHEN 2
3416                 IF invert%=0 THEN
3417                   IF order%=0 THEN
3418                     wPrintblock%!32=w%
3419                     wPrintblock%!36=h%
3420                   ELSE
3421                     wPrintblock%!32=w%
3422                     wPrintblock%!36=0
3423                   ENDIF
3424                 ELSE
3425                   IF order%=0 THEN
3426                     wPrintblock%!32=0
3427                     wPrintblock%!36=2*h%
3428                   ELSE
3429                     wPrintblock%!32=0
3430                     wPrintblock%!36=h%
3431                   ENDIF
3432                 ENDIF
3433               ENDCASE
3434             ELSE
3435               wPrintblock%!0=0
3436               wPrintblock%!4=0
3437               wPrintblock%!8=OSheight%
3438               wPrintblock%!12=OSwidth%
3439               wPrintblock%!16=xscale*scalefactor1
3440               wPrintblock%!20=yscale*scalefactor2
3441               wPrintblock%!24=xscale*scalefactor3
3442               wPrintblock%!28=yscale*scalefactor4
3443               CASE L% OF
3444                 WHEN 1
3445                 IF invert%=0 THEN
3446                   IF order%=0 THEN
3447                     wPrintblock%!32=0
3448                     wPrintblock%!36=0
3449                   ELSE
3450                     wPrintblock%!32=0
3451                     wPrintblock%!36=h%
3452                   ENDIF
3453                 ELSE
3454                   IF order%=0 THEN
3455                     wPrintblock%!32=w%
3456                     wPrintblock%!36=h%
3457                   ELSE
3458                     wPrintblock%!32=w%
3459                     wPrintblock%!36=2*h%
3460                   ENDIF
3461                 ENDIF
3462                 WHEN 2
3463                 IF invert%=0 THEN
3464                   IF order%=0 THEN
3465                     wPrintblock%!32=0
3466                     wPrintblock%!36=h%
3467                   ELSE
3468                     wPrintblock%!32=0
3469                     wPrintblock%!36=0
3470                   ENDIF
3471                 ELSE
3472                   IF order%=0 THEN
3473                     wPrintblock%!32=w%
3474                     wPrintblock%!36=2*h%
3475                   ELSE
3476                     wPrintblock%!32=w%
3477                     wPrintblock%!36=h%
3478                   ENDIF
3479                 ENDIF
3480               ENDCASE
3481             ENDIF
3482             SYS "PDriver_GiveRectangle",page%+(L%-1),wPrintblock%,wPrintblock%+16,wPrintblock%+32,&FFFFFF00
3483           ENDIF
3484         NEXT L%
3485       ENDIF
3486       IF perpage%=4 THEN
3487         FOR L%=1 TO 4
3488           IF page%+(L%-1)<=olastpage% THEN
3489             IF orient%=0 THEN
3490               wPrintblock%!0=0
3491               wPrintblock%!4=0
3492               wPrintblock%!8=OSwidth%
3493               wPrintblock%!12=OSheight%
3494               wPrintblock%!16=xscale*scalefactor1
3495               wPrintblock%!20=yscale*scalefactor2
3496               wPrintblock%!24=xscale*scalefactor3
3497               wPrintblock%!28=yscale*scalefactor4
3498               CASE L% OF
3499                 WHEN 1
3500                 IF invert%=0 THEN
3501                   IF order%=0 THEN
3502                     wPrintblock%!32=0
3503                     wPrintblock%!36=height%/2
3504                   ELSE
3505                     wPrintblock%!32=0
3506                     wPrintblock%!36=0
3507                   ENDIF
3508                 ELSE
3509                   IF order%=0 THEN
3510                     wPrintblock%!32=width%/2
3511                     wPrintblock%!36=height%
3512                   ELSE
3513                     wPrintblock%!32=width%/2
3514                     wPrintblock%!36=height%/2
3515                   ENDIF
3516                 ENDIF
3517                 WHEN 2
3518                 IF invert%=0 THEN
3519                   IF order%=0 THEN
3520                     wPrintblock%!32=width%/2
3521                     wPrintblock%!36=height%/2
3522                   ELSE
3523                     wPrintblock%!32=0
3524                     wPrintblock%!36=height%/2
3525                   ENDIF
3526                 ELSE
3527                   IF order%=0 THEN
3528                     wPrintblock%!32=width%
3529                     wPrintblock%!36=height%
3530                   ELSE
3531                     wPrintblock%!32=width%/2
3532                     wPrintblock%!36=height%
3533                   ENDIF
3534                 ENDIF
3535                 WHEN 3
3536                 IF invert%=0 THEN
3537                   IF order%=0 THEN
3538                     wPrintblock%!32=0
3539                     wPrintblock%!36=0
3540                   ELSE
3541                     wPrintblock%!32=width%/2
3542                     wPrintblock%!36=0
3543                   ENDIF
3544                 ELSE
3545                   IF order%=0 THEN
3546                     wPrintblock%!32=width%/2
3547                     wPrintblock%!36=height%/2
3548                   ELSE
3549                     wPrintblock%!32=width%
3550                     wPrintblock%!36=height%/2
3551                   ENDIF
3552                 ENDIF
3553                 WHEN 4
3554                 IF invert%=0 THEN
3555                   IF order%=0 THEN
3556                     wPrintblock%!32=width%/2
3557                     wPrintblock%!36=0
3558                   ELSE
3559                     wPrintblock%!32=width%/2
3560                     wPrintblock%!36=height%/2
3561                   ENDIF
3562                 ELSE
3563                   IF order%=0 THEN
3564                     wPrintblock%!32=width%
3565                     wPrintblock%!36=height%/2
3566                   ELSE
3567                     wPrintblock%!32=width%
3568                     wPrintblock%!36=height%
3569                   ENDIF
3570                 ENDIF
3571               ENDCASE
3572             ELSE
3573               wPrintblock%!0=0
3574               wPrintblock%!4=0
3575               wPrintblock%!8=OSheight%
3576               wPrintblock%!12=OSwidth%
3577               wPrintblock%!16=yscale*scalefactor1
3578               wPrintblock%!20=xscale*scalefactor2
3579               wPrintblock%!24=yscale*scalefactor3
3580               wPrintblock%!28=xscale*scalefactor4
3581               CASE L% OF
3582                 WHEN 1
3583                 IF invert%=0 THEN
3584                   IF order%=0 THEN
3585                     wPrintblock%!32=width%/2
3586                     wPrintblock%!36=height%/2
3587                   ELSE
3588                     wPrintblock%!32=width%/2
3589                     wPrintblock%!36=0
3590                   ENDIF
3591                 ELSE
3592                   IF order%=0 THEN
3593                     wPrintblock%!32=0
3594                     wPrintblock%!36=height%
3595                   ELSE
3596                     wPrintblock%!32=0
3597                     wPrintblock%!36=height%/2
3598                   ENDIF
3599                 ENDIF
3600                 WHEN 2
3601                 IF invert%=0 THEN
3602                   IF order%=0 THEN
3603                     wPrintblock%!32=width%
3604                     wPrintblock%!36=height%/2
3605                   ELSE
3606                     wPrintblock%!32=width%/2
3607                     wPrintblock%!36=height%/2
3608                   ENDIF
3609                 ELSE
3610                   IF order%=0 THEN
3611                     wPrintblock%!32=width%/2
3612                     wPrintblock%!36=height%
3613                   ELSE
3614                     wPrintblock%!32=0
3615                     wPrintblock%!36=height%
3616                   ENDIF
3617                 ENDIF
3618                 WHEN 3
3619                 IF invert%=0 THEN
3620                   IF order%=0 THEN
3621                     wPrintblock%!32=width%/2
3622                     wPrintblock%!36=0
3623                   ELSE
3624                     wPrintblock%!32=width%
3625                     wPrintblock%!36=0
3626                   ENDIF
3627                 ELSE
3628                   IF order%=0 THEN
3629                     wPrintblock%!32=0
3630                     wPrintblock%!36=height%/2
3631                   ELSE
3632                     wPrintblock%!32=width%/2
3633                     wPrintblock%!36=height%/2
3634                   ENDIF
3635                 ENDIF
3636                 WHEN 4
3637                 IF invert%=0 THEN
3638                   IF order%=0 THEN
3639                     wPrintblock%!32=width%
3640                     wPrintblock%!36=0
3641                   ELSE
3642                     wPrintblock%!32=width%
3643                     wPrintblock%!36=height%/2
3644                   ENDIF
3645                 ELSE
3646                   IF order%=0 THEN
3647                     wPrintblock%!32=width%/2
3648                     wPrintblock%!36=height%/2
3649                   ELSE
3650                     wPrintblock%!32=width%/2
3651                     wPrintblock%!36=height%
3652                   ENDIF
3653                 ENDIF
3654               ENDCASE
3655             ENDIF
3656             SYS "PDriver_GiveRectangle",page%+(L%-1),wPrintblock%,wPrintblock%+16,wPrintblock%+32,&FFFFFF00
3657           ENDIF
3658         NEXT L%
3659       ENDIF
3660       wPrinting%=TRUE
3661       SYS "PDriver_DrawPage",1,wPrintblock%,0,0 TO more%,,cpage%
3662       IF more%<>0 THEN
3663         REPEAT
3664           IF user%=1 THEN
3665             PROCuser_print(wPrintblock%!0,wPrintblock%!4,wPrintblock%!8,wPrintblock%!12,cpage%)
3666           ELSE
3667             PROCuser_redraw(whan%,wPrintblock%!0,wPrintblock%!4,wPrintblock%!8,wPrintblock%!12,wPrinting%,cpage%)
3668           ENDIF
3669           SYS "PDriver_GetRectangle",,wPrintblock% TO more%,,cpage%
3670         UNTIL more%=0
3671       ENDIF
3672     ENDIF
3673     SYS "Hourglass_Off"
3674   NEXT page%
3675 NEXT copy%
3676 wPrinting%=FALSE
3677 SYS "PDriver_EndJob",wprnt%
3678 CLOSE#wprnt%
3679 RESTORE ERROR
3680 SYS "PDriver_SelectJob",prevprnt%
3681 ENDPROC
3682 :
3683 DEF FNwimp_pdriverpresent
3684 LOCAL present%
3685 present%=TRUE
3686 IF FNwimp_getpdrivername="" THEN present%=FALSE
3687 =present%
3688 :
3689 DEF FNwimp_getpdrivername
3690 LOCAL name%
3691 LOCAL ERROR
3692 ON ERROR LOCAL =""
3693 SYS "PDriver_Info" TO ,,,,name%
3694 =FNwint_string(name%)
3695 :
3696 DEF FNwimp_worktopaper(coord%,side%,orient%)
3697 LOCAL w%,h%,offset%,return%
3698 IF side%=0 THEN
3699   return%=coord%
3700 ELSE
3701   w%=FNwimp_getpapersize(0,0)
3702   h%=FNwimp_getpapersize(1,0)
3703   IF orient%=0 THEN offset%=0 ELSE offset%=h%-w%
3704   return%=h%+coord%-offset%
3705 ENDIF
3706 =return%
3707 :
3708 DEF FNwimp_papertowork(coord%,side%,orient%)
3709 LOCAL w%,h%,offset%,return%
3710 IF side%=0 THEN
3711   return%=coord%
3712 ELSE
3713   w%=FNwimp_getpapersize(0,0)
3714   h%=FNwimp_getpapersize(1,0)
3715   IF orient%=0 THEN offset%=0 ELSE offset%=h%-w%
3716   return%= -(h%-coord%)+offset%
3717 ENDIF
3718 =return%
3719 :
3720 DEF FNwimp_screentopaper(whan%,coord%,side%,orient%)
3721 coord%=FNwimp_screentowork(whan%,coord%,side%)
3722 =FNwimp_worktopaper(coord%,side%,orient%)
3723 :
3724 DEF FNwimp_papertoscreen(whan%,coord%,side%,orient%)
3725 coord%=FNwimp_papertowork(coord%,side%,orient%)
3726 =FNwimp_worktoscreen(whan%,coord%,side%)
3727 :
3728 DEF FNwimp_getpapersize(side%,type%)
3729 LOCAL left%,bottom%,right%,top%,width%,height%,val%
3730 LOCAL OSleft%,OSbottom%,OSright%,OStop%,OSwidth%,OSheight%
3731 SYS "PDriver_PageSize" TO ,width%,height%,left%,bottom%,right%,top%
3732 SYS "Font_ConverttoOS",,left%,bottom% TO ,OSleft%,OSbottom%
3733 SYS "Font_ConverttoOS",,right%,top% TO ,OSright%,OStop%
3734 SYS "Font_ConverttoOS",,width%,height% TO ,OSwidth%,OSheight%
3735 val%=0
3736 IF side%=0 THEN
3737   IF type%=0 THEN val%=OSwidth%
3738   IF type%=1 THEN val%=OSleft%
3739   IF type%=2 THEN val%=OSright%-OSleft%
3740   IF type%=3 THEN val%=OSright%
3741 ELSE
3742   IF type%=0 THEN val%=OSheight%
3743   IF type%=1 THEN val%=OSbottom%
3744   IF type%=2 THEN val%=OStop%-OSbottom%
3745   IF type%=3 THEN val%=OStop%
3746 ENDIF
3747 =val%
3748 :
3749 DEF PROCwimp_declarefont(font$)
3750 SYS "PDriver_DeclareFont",0,font$,0
3751 ENDPROC
3752 :
3753 DEF PROCwimp_declarefonth(fhan%)
3754 SYS "PDriver_DeclareFont",fhan%,,0
3755 ENDPROC
3756 :
3757 DEF PROCwimp_declaredfilefonts(dfile%)
3758 LOCAL top%,len%,obj%,ptr%,font$,c%,OBJDONE%
3759 realdfile%=dfile%+4
3760 fileend%=realdfile%+dfile%!0
3761 SYS "DrawFile_DeclareFonts",,realdfile%,dfile%!0
3762 ENDPROC
3763 :
3764 DEF PROCwint_printerror(wprnt%,e$,l%)
3765 wPrinting%=FALSE
3766 SYS "XPDriver_AbortJob",wprnt%
3767 CLOSE#wprnt%
3768 SYS "Hourglass_Off"
3769 IF l%=0 THEN
3770   PROCwimp_error(werrtitle$,e$+" when trying to print.",1,"",0,1,"")
3771 ELSE
3772   PROCwimp_error(werrtitle$,e$+" at line "+STR$l%+" when trying to print.",1,"",0,1,"")
3773 ENDIF
3774 ENDPROC
3775 :
3776 REM ***********************************************
3777 REM Dynamic area handling
3778 REM ***********************************************
3779 :
3780 DEF FNwimp_createdynamic(size%,maxsize%,drag%,name$)
3781 LOCAL dnum%,darea%
3782 darea%=0
3783 IF wDynamics%<wMaxdynamicareas% THEN
3784   IF drag%<>0 THEN drag%=1
3785   IF maxsize%<-1 THEN maxsize%=-1
3786   IF (maxsize%>-1) AND (maxsize%<size%) THEN maxsize%=size%
3787   $wTempblk%=name$
3788   SYS "XOS_DynamicArea",0,-1,size%,-1,%000110000+((1-drag%)<<7),maxsize%,0,0,wTempblk% TO ,dnum%,,darea%
3789   wDynamics%+=1
3790   wDynamicarea%(wDynamics%,0)=darea%
3791   wDynamicarea%(wDynamics%,1)=dnum%
3792 ELSE
3793   PROCwimp_error(werrtitle$,"Sorry but, with this version of Dr Wimp, a maximum of "+STR$(wMaxdynamicareas%)+" Dynamic areas created with this wimp-function can exist. See Manual Section 2.27 for solution.",1,"",0,1,"")
3794 ENDIF
3795 =darea%
3796 :
3797 DEF FNwimp_changedynamic(darea%,absolute%,size%)
3798 LOCAL f%,csize%,L%,dnum%,pos%,exists%,return%
3799 IF absolute%<>0 THEN absolute%=1
3800 exists%=FALSE
3801 FOR L%=1 TO wDynamics%
3802   IF wDynamicarea%(L%,0)=darea% THEN
3803     dnum%=wDynamicarea%(L%,1)
3804     pos%=L%
3805     exists%=TRUE
3806   ENDIF
3807 NEXT L%
3808 IF exists%=TRUE AND darea%<>0 THEN
3809   f%=0
3810   IF absolute%=1 THEN
3811     csize%=FNwimp_measuredynamic(darea%)
3812     size%-=csize%
3813   ENDIF
3814   SYS "XOS_ChangeDynamicArea",dnum%,size% TO ;f%
3815   IF (f% AND 1)=1 THEN
3816     PROCwint_cleardynamicareas
3817     PROCwimp_error(werrtitle$,"Can't change that area by required amount.",1,"",0,0,"Quit "+wappname$):PROCwimp_closedown:END
3818   ELSE
3819     wDynamicarea%(pos%,0)=darea%
3820     return%=darea%
3821   ENDIF
3822 ELSE
3823   PROCwint_cleardynamicareas
3824   PROCwimp_error(werrtitle$,"Can't find existing Dynamic area with that handle.",1,"",0,0,"Quit "+wappname$):PROCwimp_closedown:END
3825 ENDIF
3826 =return%
3827 :
3828 DEF FNwimp_measuredynamic(darea%)
3829 LOCAL f%, exists%,L%,dasize%,pos%,dnum%,csize%,maxsize%
3830 pos%=0
3831 dasize%=0
3832 exists%=FALSE
3833 FOR L%=1 TO wDynamics%
3834   IF wDynamicarea%(L%,0)=darea% THEN
3835     dnum%=wDynamicarea%(L%,1)
3836     pos%=L%
3837     exists%=TRUE
3838   ENDIF
3839 NEXT L%
3840 IF exists%=TRUE AND darea%<>0 THEN
3841   dnum%=wDynamicarea%(pos%,1)
3842   SYS "XOS_DynamicArea",2,dnum% TO ,,dasize%
3843 ELSE
3844   PROCwint_cleardynamicareas
3845   PROCwimp_error(werrtitle$,"Can't find existing Dynamic area with that handle.",1,"",0,0,"Quit "+wappname$):PROCwimp_closedown:END
3846 ENDIF
3847 =dasize%
3848 :
3849 DEF PROCwimp_deletedynamic(darea%)
3850 LOCAL L%,dnum%,exists%,pos%
3851 exists%=FALSE
3852 pos%=-1
3853 FOR L%=1 TO wDynamics%
3854   IF wDynamicarea%(L%,0)=darea% THEN
3855     dnum%=wDynamicarea%(L%,1)
3856     exists%=TRUE
3857     pos%=L%
3858   ENDIF
3859 NEXT L%
3860 IF exists%=TRUE AND darea%<>0 THEN
3861   SYS "XOS_DynamicArea",1,dnum% TO ;f%
3862   IF pos%<wDynamics% THEN
3863     FOR L%=pos% TO wDynamics%
3864       wDynamicarea%(L%,0)=wDynamicarea%(L%+1,0)
3865       wDynamicarea%(L%,1)=wDynamicarea%(L%+1,1)
3866     NEXT
3867   ENDIF
3868   wDynamicarea%(wDynamics%,0)=0
3869   wDynamicarea%(wDynamics%,1)=0
3870   wDynamics%-=1
3871 ENDIF
3872 ENDPROC
3873 :
3874 DEF PROCwint_cleardynamicareas
3875 LOCAL L%,dnum%
3876 IF wDynamics%>0 THEN
3877   FOR L%=wDynamics% TO 1 STEP -1
3878     IF wDynamicarea%(L%,0)<>0 THEN
3879       dnum%=wDynamicarea%(L%,1)
3880       SYS "XOS_DynamicArea",1,dnum% TO ;f%
3881       REM ignore any errors - we are exiting
3882       wDynamicarea%(L%,0)=0
3883       wDynamicarea%(L%,1)=0
3884     ENDIF
3885   NEXT
3886 ENDIF
3887 wDynamics%=0
3888 ENDPROC
3889 :
3890 DEF FNwimp_getfreeRAM
3891 LOCAL free%
3892 free%=0
3893 SYS "OS_DynamicArea",2,6 TO ,,free%
3894 =free%
3895 :
3896 REM ***********************************************
3897 REM Colour / colour picker handling
3898 REM ***********************************************
3899 :
3900 DEF PROCwimp_opencolourpickermodel(model%,dialoguetype%,value1,value2,value3,value4,none%,x%,y%)
3901 IF wColourblock%=-1 THEN DIM wColourblock% 255
3902 IF dialoguetype% <> 0 THEN dialoguetype%=1
3903 IF model%<0 THEN model%=0
3904 model%=(model% MOD 3)
3905 PROCwint_setcolourblockreservedvalues
3906 IF none%<1 THEN wColourblock%!0-=%1
3907 IF none%>1 THEN wColourblock%!0+=%10
3908 wColourblock%!8=x%
3909 wColourblock%!20=y%
3910 wColourblock%!40=model%
3911 PROCwint_initialcolourconvert(model%,value1,value2,value3,value4)
3912 SYS "ColourPicker_OpenDialogue",dialoguetype%,wColourblock% TO wPickerhandle%,wPickerwindow%
3913 ENDPROC
3914 :
3915 DEF PROCwimp_opencolourpickerrgb(dialoguetype%,red%,green%,blue%,none%,x%,y%)
3916 IF wColourblock%=-1 THEN DIM wColourblock% 255
3917 IF dialoguetype% <> 0 THEN dialoguetype%=1
3918 PROCwint_setcolourblockreservedvalues
3919 IF none%<1 THEN wColourblock%!0-=%1
3920 IF none%>1 THEN wColourblock%!0+=%10
3921 wColourblock%!8=x%
3922 wColourblock%!20=y%
3923 wColourblock%!40=0
3924 wColourblock%?(32+1)=red%
3925 wColourblock%?(32+2)=green%
3926 wColourblock%?(32+3)=blue%
3927 SYS "ColourPicker_OpenDialogue",dialoguetype%,wColourblock% TO wPickerhandle%,wPickerwindow%
3928 ENDPROC
3929 :
3930 DEF PROCwimp_opensubmenucolourpickermodel(model%,value1,value2,value3,value4,none%,x%,y%)
3931 IF wColourblock%=-1 THEN DIM wColourblock% 255
3932 IF model%<0 THEN model%=0
3933 model%=(model% MOD 3)
3934 PROCwint_setcolourblockreservedvalues
3935 IF none%<1 THEN wColourblock%!0-=%1
3936 IF none%>1 THEN wColourblock%!0+=%10
3937 wColourblock%!8=x%
3938 wColourblock%!20=y%
3939 wColourblock%!40=model%
3940 PROCwint_initialcolourconvert(model%,value1,value2,value3,value4)
3941 SYS "ColourPicker_OpenDialogue",3,wColourblock% TO wPickerhandle%,wPickerwindow%
3942 ENDPROC
3943 :
3944 DEF PROCwimp_opensubmenucolourpickerrgb(red%,green%,blue%,none%,x%,y%)
3945 IF wColourblock%=-1 THEN DIM wColourblock% 255
3946 PROCwint_setcolourblockreservedvalues
3947 IF none%<1 THEN wColourblock%!0-=%1
3948 IF none%>1 THEN wColourblock%!0+=%10
3949 wColourblock%!8=x%
3950 wColourblock%!20=y%
3951 wColourblock%!40=0
3952 wColourblock%?(32+1)=red%
3953 wColourblock%?(32+2)=green%
3954 wColourblock%?(32+3)=blue%
3955 SYS "ColourPicker_OpenDialogue",3,wColourblock% TO wPickerhandle%,wPickerwindow%
3956 ENDPROC
3957 :
3958 DEF PROCwint_setcolourblockreservedvalues
3959 wColourblock%!0=%10001
3960 wColourblock%!4=0
3961 wColourblock%!12=&80000000
3962 wColourblock%!16=&7FFFFFFF
3963 wColourblock%!24=0
3964 wColourblock%!28=0
3965 wColourblock%?(32+0)=0
3966 wColourblock%?(32+4)=20
3967 ENDPROC
3968 :
3969 DEF PROCwint_initialcolourconvert(model%,value1,value2,value3,value4)
3970 CASE model% OF
3971   WHEN 0
3972   wColourblock%?(32+1)=value1*255/100
3973   wColourblock%?(32+2)=value2*255/100
3974   wColourblock%?(32+3)=value3*255/100
3975   WHEN 1
3976   SYS "ColourTrans_ConvertCMYKToRGB",(value1/100)*2^16,(value2/100)*2^16,(value3/100)*2^16,(value4/100)*2^16 TO red%,green%,blue%
3977   wColourblock%?(32+1)=255*(red%/&10000)
3978   wColourblock%?(32+2)=255*(green%/&10000)
3979   wColourblock%?(32+3)=255*(blue%/&10000)
3980   WHEN 2
3981   SYS "ColourTrans_ConvertHSVToRGB",((value1 MOD 360) << 16) OR &FFFF,(value2/100)+&FFFF,(value3/100)+&FFFF TO red%,green%,blue%
3982   wColourblock%?(32+1)=255*(red%/&10000)
3983   wColourblock%?(32+2)=255*(green%/&10000)
3984   wColourblock%?(32+3)=255*(blue%/&10000)
3985 ENDCASE
3986 ENDPROC
3987 :
3988 DEF PROCwint_colourpickerchoice(model%)
3989 LOCAL none%,returnvalue1,returnvalue2,returnvalue3,returnvalue4
3990 none%=wimp%!24 AND 1
3991 returnvalue4=-1
3992 PROCuser_colourpickerrgb(wimp%?29,wimp%?30,wimp%?31,none%)
3993 returnvalue2=(wimp%!44/&10000)*100
3994 returnvalue3=(wimp%!48/&10000)*100
3995 CASE model% OF
3996   WHEN 0
3997   returnvalue1=(wimp%!40/&10000)*100
3998   returnvalue4=-1
3999   WHEN 1
4000   returnvalue1=(wimp%!40/&10000)*100
4001   returnvalue4=(wimp%!52/&10000)*100
4002   WHEN 2
4003   returnvalue1=(wimp%!40 >> 16)
4004   returnvalue4=-1
4005 ENDCASE
4006 PROCuser_colourpickermodel(model%,returnvalue1,returnvalue2,returnvalue3,returnvalue4,none%)
4007 ENDPROC
4008 :
4009 DEF PROCwint_closecolourpicker(handle%)
4010 SYS "ColourPicker_CloseDialogue",0,handle%
4011 ENDPROC
4012 :
4013 DEF PROCwimp_savefile(savepath$,handle%,ftype%)
4014 LOCAL realsize%,realfile%,file%,bnt%
4015 realsize%=handle%!0
4016 realfile%=handle%+4
4017 PROCwimp_hourglasson
4018 SYS "OS_Find",&8F,savepath$ TO file%
4019 SYS "OS_GBPB",2,file%,realfile%,realsize% TO ,,,bnt%
4020 SYS "OS_Find",0,file%
4021 PROCwimp_hourglassoff
4022 IF bnt%<>0 THEN
4023   PROCwimp_error(werrtitle$,"Unknown error whilst saving; the file has not been saved correctly.",1,"",0,1,"")
4024 ELSE
4025   SYS "OS_File",18,savepath$,ftype%
4026 ENDIF
4027 ENDPROC
4028 :
4029 DEF PROCwint_receivedmess2(desttask%,inref%,destwhan%,destic%,destx%,desty%,ptr44%)
4030 LOCAL path$,Q%,drag%,write%,ok%,hextype%
4031 path$=FNwint_string(ptr44%)
4032 IF wToPrinter%=0 THEN
4033   drag%=0:write%=1:ok%=2
4034   PROCuser_saveicon(wSavew%,drag%,write%,ok%)
4035   PROCwimp_hourglasson
4036   Q%=FNuser_savedata(path$,wSavew%)
4037   PROCwimp_hourglassoff
4038 ELSE
4039   IF wDeleteFile%=0 THEN
4040     SYS "OS_FSControl",26,wPrintFile$,path$,0
4041   ELSE
4042     SYS "OS_FSControl",26,wPrintFile$,path$,128
4043   ENDIF
4044   hextype%=wPrintFileType%
4045   Q%=1
4046 ENDIF
4047 IF Q%=2 THEN
4048   PROCwimp_error(werrtitle$,REPORT$+" at line "+STR$(ERL)+" when trying to save.",1,"",0,0,"")
4049 ELSE
4050   IF Q%<>0 THEN
4051     IF wToPrinter%=0 THEN
4052       SYS "OS_ReadUnsigned",10,"&"+wSavet$ TO ,,hextype%
4053       SYS "OS_File",18,path$,hextype%
4054     ENDIF
4055     wimp%!0=256
4056     wimp%!12=inref%
4057     wimp%!16=3
4058     wimp%!20=destwhan%
4059     wimp%!24=destic%
4060     wimp%!28=destx%
4061     wimp%!32=desty%
4062     wimp%!36=-1
4063     wimp%!40=hextype%
4064     PROCwint_zeroterminate(wimp%+44,path$)
4065     SYS "Wimp_SendMessage",18,wimp%,desttask%
4066     IF wToPrinter%=0 THEN
4067       IF path$<>"<Wimp$Scrap>" THEN PROCwimp_puticontext(wSavew%,write%,path$)
4068     ENDIF
4069   ENDIF
4070 ENDIF
4071 ENDPROC
4072 :
4073 DEF PROCwint_quicksave(whan%,writeicon%)
4074 LOCAL path$,Q%,type$
4075 type$=FNuser_savefiletype(whan%)
4076 IF LEN(type$)<4 THEN
4077   path$=FNwimp_geticontext(whan%,writeicon%)
4078   IF (INSTR(path$,".")>0) OR (INSTR(path$,":")>0) THEN
4079     PROCwimp_hourglasson
4080     Q%=FNuser_savedata(path$,whan%)
4081     PROCwimp_hourglassoff
4082     IF Q%=2 THEN
4083       PROCwimp_error(werrtitle$,REPORT$+" at line "+STR$(ERL)+" when trying to save.",1,"",0,0,"")
4084     ELSE
4085       IF Q%<>0 THEN
4086         SYS "OS_ReadUnsigned",10,"&"+type$ TO ,,hextype%
4087         SYS "OS_File",18,path$,hextype%
4088       ENDIF
4089     ENDIF
4090   ELSE
4091     PROCwimp_error("Message","To save, drag the icon to a directory/application Filer window.",1,"",0,0,"")
4092   ENDIF
4093 ELSE
4094   PROCwimp_error(werrtitle$,"Filetype string too long in 'DEF FNuser_savefiletype'.",1,"",0,0,"Quit "+wappname$):PROCwimp_closedown:END
4095 ENDIF
4096 ENDPROC
4097 :
4098 DEF  PROCwimp_sendfiletoprinter(filepath$,deletefile%)
4099 LOCAL ftype%,leaf$,lenleaf%,messagelen%
4100 IF FNwimp_pdriverpresent=FALSE THEN
4101   PROCwimp_error(werrtitle$,"Sorry, a printer driver isn't loaded.",1,"",0,1,"")
4102 ELSE
4103   ftype$=FNwimp_testobjectpresent(filepath$,0)
4104   IF ftype$="" OR (LEN(ftype$)>3) THEN
4105     PROCwimp_error(werrtitle$,"Sorry, a file called "+filepath$+" cannot be found.",1,"",0,1,"")
4106   ELSE
4107     wToPrinter%=1
4108     wPrintFile$=filepath$
4109     wDeleteFile%=deletefile%
4110     leaf$=FNwimp_getleafname(filepath$)
4111     SYS "OS_ReadUnsigned",16,ftype$ TO ,,ftype%
4112     wPrintFileType%=ftype%
4113     wimp%!0=(44+LEN(leaf$)+4) AND &1FC
4114     wimp%!12=0
4115     wimp%!16=&80142
4116     wimp%!20=-1
4117     wimp%!24=-1
4118     wimp%!28=0
4119     wimp%!32=0
4120     wimp%!36=-1
4121     wimp%!40=ftype%
4122     PROCwint_zeroterminate(wimp%+44,leaf$)
4123     SYS "Wimp_SendMessage",18,wimp%,0
4124   ENDIF
4125 ENDIF
4126 ENDPROC
4127 :
4128 DEF PROCwint_receivedmess4
4129 IF wToPrinter%=1 THEN
4130   wToPrinter%=0
4131   wPrintFileType%=0
4132   wPrintFile$=""
4133   wDeleteFile%=0
4134 ENDIF
4135 ENDPROC
4136 :
4137 DEF FNwint_getfilesize(path$,warning%)
4138 LOCAL exists%,filelength%
4139 SYS "XOS_File",17,path$ TO exists%,,,,filelength%
4140 IF exists%=0 THEN
4141   IF warning%<>0 THEN
4142     PROCwimp_error(werrtitle$,"Sorry, a file called "+path$+" cannot be found.",1,"",0,1,"")
4143   ENDIF
4144   filelength%=-1
4145 ENDIF
4146 =filelength%
4147 :
4148 DEF FNwimp_measurefile(path$,warning%)
4149 LOCAL return%
4150 return%=0
4151 return%=FNwint_getfilesize(path$,warning%)
4152 IF return%>-1 THEN return%+=4
4153 =return%
4154 :
4155 DEF FNwimp_loadfile(filepath$,address%,warning%)
4156 LOCAL nextloadat%,realsize%,loadat%
4157 nextloadat%=address%
4158 realsize%=FNwint_getfilesize(filepath$,warning%)
4159 IF realsize%>-1 THEN
4160   address%!0=realsize%
4161   loadat%=address%+4
4162   PROCwimp_hourglasson
4163   SYS "OS_Find",&4F,filepath$ TO file%
4164   SYS "OS_GBPB",4,file%,loadat%,realsize%
4165   SYS "OS_Find",0,file%
4166   PROCwimp_hourglassoff
4167   nextloadat%=address%+realsize%+4
4168 ENDIF
4169 =nextloadat%
4170 :
4171 DEF PROCwint_receivedmess3or5(type%,desttask%,inref%,whan%,icon%,x%,y%,size%,ftype%,ptr44%)
4172 LOCAL ftype$,path$,action%,workx%,worky%
4173 PROCwimp_hourglasson
4174 ftype$=STR$~(ftype%)
4175 CASE ftype$ OF
4176   WHEN "1000","2000"
4177   OTHERWISE
4178   ftype$=RIGHT$("00"+ftype$,3)
4179 ENDCASE
4180 path$=FNwint_string(ptr44%)
4181 IF type%=5 THEN
4182   whan%=0:icon%=-1
4183   workx%=-1:worky%=-1
4184 ELSE
4185   workx%=FNwimp_screentowork(whan%,x%,0)
4186   worky%=FNwimp_screentowork(whan%,y%,1)
4187 ENDIF
4188 action%=FNuser_loaddata(path$,whan%,icon%,ftype$,workx%,worky%)
4189 IF action%<>0 THEN PROCwint_dataloadack(path$,desttask%,inref%,whan%,icon%,x%,y%,size%,ftype%)
4190 PROCwimp_hourglassoff
4191 ENDPROC
4192 :
4193 DEF PROCwint_dataloadack(path$,desttask%,inref%,window%,icon%,x%,y%,size%,ftype%)
4194 wimp%!0=256
4195 wimp%!12=inref%
4196 wimp%!16=4
4197 wimp%!20=window%
4198 wimp%!24=icon%
4199 wimp%!28=x%
4200 wimp%!32=y%
4201 wimp%!36=size%
4202 PROCwint_zeroterminate(wimp%+44,path$)
4203 SYS "Wimp_SendMessage",17,wimp%,desttask%
4204 IF path$="<Wimp$Scrap>" THEN SYS "OS_FSControl",27,path$,,%10
4205 ENDPROC
4206 :
4207 DEF PROCwint_receivedmess1(desttask%,inref%,destwhan%,destic%,destx%,desty%,size%,ftype%)
4208 IF desttask%<>wTask% THEN
4209   wimp%!0=256
4210   wimp%!12=inref%
4211   wimp%!16=2
4212   wimp%!20=destwhan%
4213   wimp%!24=destic%
4214   wimp%!28=destx%
4215   wimp%!32=desty%
4216   wimp%!36=-1
4217   wimp%!40=ftype%
4218   PROCwint_zeroterminate(wimp%+44,"<Wimp$Scrap>")
4219   SYS "Wimp_SendMessage",17,wimp%,desttask%
4220 ENDIF
4221 ENDPROC
4222 :
4223 DEF PROCwint_zeroterminate(wptr%,text$)
4224 $wptr%=text$
4225 wptr%?(LEN(text$))=0
4226 ENDPROC
4227 :
4228 DEF FNwimp_testobjectpresent(fullpath$,warning%)
4229 LOCAL return$,objecttype%,ftype%,loadaddr%
4230 return$="1234"
4231 return$=""
4232 SYS "OS_File",23,fullpath$ TO objecttype%,,,,,,ftype%
4233 IF objecttype%<>0 THEN
4234   IF objecttype%<>3 THEN
4235     IF ftype%=-1 THEN
4236       return$="-1"
4237     ELSE
4238       return$=STR$~(ftype%)
4239       WHILE LEN(return$)<3
4240         return$="0"+return$
4241       ENDWHILE
4242     ENDIF
4243   ELSE
4244     SYS "OS_File",17,fullpath$ TO ,,loadaddr%
4245     ftype%=((loadaddr%>>8) AND %111111111111)
4246     return$=STR$~(ftype%)
4247     WHILE LEN(return$)<3
4248       return$="0"+return$
4249     ENDWHILE
4250   ENDIF
4251 ELSE
4252   IF warning%<>0 THEN
4253     PROCwimp_error(werrtitle$,"The object cannot be found.(Null string will be returned.)",1,"",0,1,"")
4254   ENDIF
4255 ENDIF
4256 =return$
4257 :
4258
4259 REM Modified by CAFJ 14/11/2011
4260 DEF FNwimp_countdirectoryobjects(dir$)
4261 LOCAL offset%,f%,dirbuffersize%,read%,obj_read%
4262 dirbuffersize%=256
4263 IF wDirbuffer%=-1 THEN DIM wDirbuffer% dirbuffersize%-1
4264 offset%=0
4265 obj_read%=0
4266 REPEAT
4267   SYS "XOS_GBPB",9,dir$,wDirbuffer%,1,offset%,dirbuffersize% TO ,,,read%,offset%;f%
4268   obj_read% += read%
4269   IF (f% AND 1)=1 THEN offset%=-1
4270 UNTIL offset%=-1
4271 =obj_read%
4272 :
4273
4274 :
4275
4276 REM Modified by CAFJ 14/11/2011
4277 REM The following modified to correctly use the object offset
4278 REM returned in R4 and objects read returned in R3
4279 :
4280 DEF FNwimp_getdirectoryobjectname(dir$,objectnumber%)
4281 LOCAL objectname$,pointer%,f%,dirbuffersize%,read%,obj_read%
4282 IF objectnumber%<1 THEN objectnumber%=1
4283 dirbuffersize%=256
4284 IF wDirbuffer%=-1 THEN DIM wDirbuffer% dirbuffersize%-1
4285 objectname$=""
4286
4287 offset%=0
4288 obj_read%=0
4289 REPEAT
4290   SYS "XOS_GBPB",9,dir$,wDirbuffer%,1,offset%,dirbuffersize% TO ,,,read%,offset%;f%
4291   obj_read% += read%
4292   IF (f% AND 1)=1 THEN offset%=-1
4293 UNTIL (offset%=-1) OR (obj_read%=objectnumber%)
4294
4295 IF offset%<>-1 THEN
4296   pointer%=wDirbuffer%
4297   WHILE ?pointer%>31
4298     pointer%+=1
4299   ENDWHILE
4300   ?pointer%=13
4301   objectname$=FNwint_string(wDirbuffer%)
4302 ENDIF
4303 =objectname$
4304 :
4305
4306 REM Modified by CAFJ 14/11/2011
4307 REM The following modified to correctly use the object offset
4308 REM returned in R4 and objects read returned in R3
4309 :
4310 DEF FNwimp_getdirectoryobjecttype(dir$,objectnumber%)
4311 LOCAL offset1%,offset2%,objecttype%,objectfiletype%,objectfiletypestring$,f%,dirbuffersize%,read%,obj_read%,offset%
4312 IF objectnumber%<1 THEN objectnumber%=1
4313 dirbuffersize%=256
4314 IF wDirbuffer%=-1 THEN DIM wDirbuffer% dirbuffersize%-1
4315 offset1%=20
4316 offset2%=16
4317 objecttype%=0
4318 objectfiletypestring$="1234"
4319 objectfiletypestring$=""
4320
4321 offset%=0
4322 obj_read%=0
4323 REPEAT
4324   SYS "XOS_GBPB",12,dir$,wDirbuffer%,1,offset%,dirbuffersize% TO ,,,read%,offset%;f%
4325   obj_read% += read%
4326   IF (f% AND 1)=1 THEN offset%=-1
4327 UNTIL (offset%=-1) OR (obj_read%=objectnumber%)
4328
4329 IF offset%<>-1 THEN
4330   objecttype%=wDirbuffer%!offset2%
4331   IF objecttype%<>3 THEN
4332     objectfiletype%=wDirbuffer%!offset1%
4333   ELSE
4334     objectfiletype%=((wDirbuffer%!0>>8) AND %111111111111)
4335   ENDIF
4336   objectfiletypestring$=STR$~(objectfiletype%)
4337   WHILE LEN(objectfiletypestring$)<3
4338     objectfiletypestring$="0"+objectfiletypestring$
4339   ENDWHILE
4340 ENDIF
4341 =objectfiletypestring$
4342 :
4343
4344 REM Added by CAFJ 18/11/2011
4345 REM The following is to find the object name from the object offset
4346 REM Returns the new offset for the next call if there is one
4347 :
4348 DEF FNwimp_getdirectoryobjectnamebyoffset(dir$,RETURN offset%)
4349 LOCAL objectname$,pointer%,f%,dirbuffersize%,read%
4350 IF offset%<1 THEN offset%=0
4351 dirbuffersize%=256
4352 IF wDirbuffer%=-1 THEN DIM wDirbuffer% dirbuffersize%-1
4353 objectname$=""
4354 SYS "XOS_GBPB",9,dir$,wDirbuffer%,1,offset%,dirbuffersize% TO ,,,read%,offset%;f%
4355 IF (f% AND 1)=1 THEN offset%=-1
4356
4357 IF offset%<>-1 AND read%<>0 THEN
4358   pointer%=wDirbuffer%
4359   WHILE ?pointer%>31
4360     pointer%+=1
4361   ENDWHILE
4362   ?pointer%=13
4363   objectname$=FNwint_string(wDirbuffer%)
4364 ENDIF
4365 =objectname$
4366 :
4367
4368 REM Added by CAFJ 18/11/2011
4369 REM The following is to find the object type from the object offset
4370 REM Returns the new offset for the next call if there is one
4371 :
4372 DEF FNwimp_getdirectoryobjecttypebyoffset(dir$,RETURN offset%)
4373 LOCAL offset1%,offset2%,objecttype%,objectfiletype%,objectfiletypestring$,f%,dirbuffersize%,read%
4374 IF offset%<1 THEN offset%=0
4375 dirbuffersize%=256
4376 IF wDirbuffer%=-1 THEN DIM wDirbuffer% dirbuffersize%-1
4377 offset1%=20
4378 offset2%=16
4379 objecttype%=0
4380 objectfiletypestring$="1234"
4381 objectfiletypestring$=""
4382
4383 SYS "XOS_GBPB",12,dir$,wDirbuffer%,1,offset%,dirbuffersize% TO ,,,read%,offset%;f%
4384 IF (f% AND 1)=1 THEN offset%=-1
4385
4386 IF offset%<>-1 AND read%<>0 THEN
4387   objecttype%=wDirbuffer%!offset2%
4388   IF objecttype%<>3 THEN
4389     objectfiletype%=wDirbuffer%!offset1%
4390   ELSE
4391     objectfiletype%=((wDirbuffer%!0>>8) AND %111111111111)
4392   ENDIF
4393   objectfiletypestring$=STR$~(objectfiletype%)
4394   WHILE LEN(objectfiletypestring$)<3
4395     objectfiletypestring$="0"+objectfiletypestring$
4396   ENDWHILE
4397 ENDIF
4398 =objectfiletypestring$
4399 :
4400
4401
4402 :
4403 DEF FNwimp_getdirectorypath(pathname$)
4404 LOCAL return$,temp$
4405 return$=""
4406 temp$=FNwimp_getleafname(pathname$)
4407 IF temp$<>pathname$ THEN
4408   return$=LEFT$(pathname$,LEN(pathname$)-LEN(temp$))
4409 ENDIF
4410 =return$
4411 :
4412 DEF FNwimp_getleafname(return$)
4413 WHILE INSTR(return$,".")>0
4414   return$=MID$(return$,INSTR(return$,".")+1)
4415 ENDWHILE
4416 =MID$(return$,INSTR(return$,":")+1)
4417 :
4418 DEF FNwimp_copyobject(sourcepath$,destinationpath$,deletesource%,newer%,restamp%,force%,warning%)
4419 LOCAL return%,exist$,flags%,f%
4420 return%=1
4421 exist$=FNwimp_testobjectpresent(sourcepath$,0)
4422 IF exist$="" THEN
4423   return%=0
4424   IF warning%<>0 THEN
4425     PROCwimp_error(werrtitle$,"Sorry, but the source file '"+sourcepath$+"' cannot be found.",1,"",0,1,"")
4426   ENDIF
4427 ELSE
4428   flags%=0
4429   IF deletesource%<>0 THEN deletesource%=1
4430   IF newer%<>0 THEN newer%=1
4431   IF restamp%<>0 THEN restamp%=1
4432   IF force%<>0 THEN force%=1
4433   flags%+=(1<<14)+(newer%<<12)+(restamp%<<10)+(deletesource%<<7)+(force%<<1)+(1<<0)
4434   PROCwimp_hourglasson
4435   SYS "XOS_FSControl",26,sourcepath$,destinationpath$,flags% TO ;f%
4436   PROCwimp_hourglassoff
4437   IF (f% AND 1)=1 THEN return%=0
4438 ENDIF
4439 =return%
4440 :
4441 DEF FNwimp_deleteobject(path$,force%,warning%)
4442 LOCAL return%,exist$,flags%,f%
4443 return%=1
4444 exist$=FNwimp_testobjectpresent(path$,0)
4445 IF exist$="" THEN
4446   return%=0
4447   IF warning%<>0 THEN
4448     PROCwimp_error(werrtitle$,"Sorry, but '"+path$+"' cannot be found.",1,"",0,1,"")
4449   ENDIF
4450 ELSE
4451   IF force%=1 THEN
4452     flags%=%11
4453   ELSE
4454     flags%=%1
4455   ENDIF
4456   PROCwimp_hourglasson
4457   SYS "XOS_FSControl",27,path$,,flags% TO ;f%
4458   PROCwimp_hourglassoff
4459   IF (f% AND 1)=1 THEN return%=0
4460 ENDIF
4461 =return%
4462 :
4463 DEF PROCwimp_doubleclickobject(path$,warning%)
4464 LOCAL exist$
4465 exist$=FNwimp_testobjectpresent(path$,0)
4466 IF exist$="" THEN
4467   IF warning%<>0 THEN
4468     PROCwimp_error(werrtitle$,"Sorry, but '"+path$+"' cannot be found.",1,"",0,1,"")
4469   ENDIF
4470 ELSE
4471   OSCLI("Filer_Run "+path$)
4472 ENDIF
4473 ENDPROC
4474 :
4475 DEF PROCwimp_setfiletypenumber(file$,ftype%,warning%)
4476 LOCAL exist$
4477 exist$=FNwimp_testobjectpresent(file$,0)
4478 CASE exist$ OF
4479   WHEN ""
4480   IF warning%<>0 THEN
4481     PROCwimp_error(werrtitle$,"Sorry, but the file '"+file$+"' cannot be found.",1,"",0,1,"")
4482   ENDIF
4483   WHEN "1000","2000"
4484   IF warning%<>0 THEN
4485     PROCwimp_error(werrtitle$,"Sorry, but '"+file$+"' is a directory (or application).",1,"",0,1,"")
4486   ENDIF
4487   OTHERWISE
4488   IF ftype%<0 OR ftype%>&FFF THEN ftype%=&FFF
4489   SYS "XOS_File",18,file$,ftype%
4490 ENDCASE
4491 ENDPROC
4492 :
4493 DEF PROCwimp_setfiletypehexstring(file$,ftype$,warning%)
4494 LOCAL ftype%
4495 IF LEFT$(ftype$,1)<>"&" THEN ftype$="&"+ftype$
4496 SYS "XOS_ReadUnsigned",,ftype$ TO ,,ftype%
4497 PROCwimp_setfiletypenumber(file$,ftype%,warning%)
4498 ENDPROC
4499 :
4500 DEF PROCwimp_createdirectory(dir$,warning%)
4501 LOCAL create%,parentdir$,exist$,leafname$
4502 create%=TRUE
4503 parentdir$=LEFT$(FNwimp_getdirectorypath(dir$))
4504 exist$=FNwimp_testobjectpresent(parentdir$,0)
4505 IF exist$="" OR LEN(exist$)<4 THEN
4506   create%=FALSE
4507   IF warning%<>0 THEN
4508     PROCwimp_error(werrtitle$,"Sorry, but the intended parent directory '"+parentdir$+"' cannot be found (or already exists as a file).",1,"",0,1,"")
4509   ENDIF
4510 ENDIF
4511 IF create%=TRUE THEN
4512   leafname$=FNwimp_getleafname(dir$)
4513   exist$=FNwimp_testobjectpresent(dir$,0)
4514   IF exist$<>"" AND LEN(exist$)<4 THEN
4515     create%=FALSE
4516     IF warning%<>0 THEN
4517       PROCwimp_error(werrtitle$,"Sorry, but a file with the intended directory name '"+leafname$+"' already exists.",1,"",0,1,"")
4518     ENDIF
4519   ENDIF
4520 ENDIF
4521 IF create%=TRUE THEN
4522   SYS "XOS_File",8,dir$,,,0
4523 ENDIF
4524 ENDPROC
4525 :
4526 DEF FNwimp_renameobject(existingpath$,newpath$,warning%)
4527 LOCAL rename%,exist$,newparentdir$,f%
4528 rename%=1
4529 exist$=FNwimp_testobjectpresent(existingpath$,0)
4530 IF exist$="" THEN
4531   rename%=0
4532   IF warning%<>0 THEN
4533     PROCwimp_error(werrtitle$,"Sorry, but the object '"+existingpath$+"' cannot be found.",1,"",0,1,"")
4534   ENDIF
4535 ENDIF
4536 IF rename%=1 THEN
4537   exist$=FNwimp_testobjectpresent(newpath$,0)
4538   IF exist$<>"" THEN
4539     rename%=0
4540     IF warning%<>0 THEN
4541       PROCwimp_error(werrtitle$,"Sorry, but the intended renamed object '"+newpath$+"' already exists.",1,"",0,1,"")
4542     ENDIF
4543   ENDIF
4544 ENDIF
4545 IF rename%=1 THEN
4546   newparentdir$=LEFT$(FNwimp_getdirectorypath(newpath$))
4547   exist$=FNwimp_testobjectpresent(newparentdir$,0)
4548   IF exist$="" THEN
4549     rename%=0
4550     IF warning%<>0 THEN
4551       PROCwimp_error(werrtitle$,"Sorry, but the intended directory '"+newparentdir$+"' cannot be found.",1,"",0,1,"")
4552     ENDIF
4553   ENDIF
4554 ENDIF
4555 IF rename%=1 THEN
4556   flags%=1<<7
4557   SYS "XOS_FSControl",26,existingpath$,newpath$,flags% TO ;f%
4558   IF (f% AND 1)=1 THEN rename%=0
4559 ENDIF
4560 =rename%
4561 :
4562 DEF FNwimp_getobjecttypenumber(fullpath$,warning%)
4563 LOCAL return%,objecttype%,ftype%,loadaddr%
4564 return%=0
4565 SYS "OS_File",23,fullpath$ TO objecttype%,,,,,,ftype%
4566 IF objecttype%=0 THEN
4567   IF warning%<>0 THEN
4568     PROCwimp_error(werrtitle$,"Sorry, but the object '"+fullpath$+"' cannot be found.",1,"",0,1,"")
4569   ENDIF
4570 ELSE
4571   IF objecttype%<>3 THEN
4572     return%=ftype%
4573   ELSE
4574     SYS "OS_File",17,fullpath$ TO ,,loadaddr%
4575     ftype%=((loadaddr%>>8) AND %111111111111)
4576     return%=ftype%
4577   ENDIF
4578 ENDIF
4579 =return%
4580 :
4581 DEF FNwimp_getobjecttypehexstring(fullpath$,warning%)
4582 LOCAL return$
4583 return$=""
4584 return$=FNwimp_testobjectpresent(fullpath$,warning%)
4585 =return$
4586 :
4587 DEF PROCwimp_opendirectory(dir$,default%,topx%,topy%,width%,height%,iconsize%,sortby%,warning%)
4588 LOCAL test$,param$,size$,sort$
4589 IF RIGHT$(dir$)="." THEN dir$=LEFT$(dir$)
4590 test$=FNwimp_testobjectpresent(dir$,0)
4591 IF LEN(test$)<4 THEN
4592   IF warning%<>0 THEN
4593     PROCwimp_error(werrtitle$,"Sorry, but '"+dir$+"' cannot be found - or it is not a directory.",1,"",0,1,"")
4594   ENDIF
4595 ELSE
4596   param$=" "
4597   IF default%=0 THEN
4598     IF iconsize%<1 THEN iconsize%=1
4599     IF iconsize%>3 THEN iconsize%=3
4600     IF sortby%<1 THEN sortby%=1
4601     IF sortby%>4 THEN sortby%=4
4602     size$=MID$("-si-li-fi",((iconsize%-1)*3)+1,3)
4603     sort$=MID$("-sn-st-sd-ss",((sortby%-1)*3)+1,3)
4604     param$+=STR$(topx%)+" "+STR$(topy%)+" "+STR$(width%)+" "+STR$(height%)+" "+size$+" "+sort$
4605   ENDIF
4606   SYS "OS_CLI","Filer_OpenDir "+dir$+param$
4607 ENDIF
4608 ENDPROC
4609 :
4610 DEF PROCwimp_closedirectory(dir$)
4611 IF RIGHT$(dir$)="." THEN dir$=LEFT$(dir$)
4612 SYS "OS_CLI","Filer_CloseDir "+dir$
4613 ENDPROC
4614 :
4615 DEF FNwimp_getscreensize(side%)
4616 LOCAL Eig%,s%
4617 IF side%<>0 THEN side%=1
4618 SYS "OS_ReadModeVariable",-1,side%+4 TO ,,Eig%
4619 SYS "OS_ReadModeVariable",-1,side%+11 TO ,,s%
4620 =(s%+1)<<Eig%
4621 :
4622 DEF FNwimp_getscreenres(direction%)
4623 LOCAL return%
4624 IF direction%<>0 THEN direction%=1
4625 SYS "OS_ReadModeVariable",-1,(11+direction%) TO ,,return%
4626 =return%+1
4627 :
4628 DEF FNwimp_worktoscreen(whan%,coord%,side%)
4629 LOCAL f%,return%
4630 return%=0
4631 IF side%<>0 THEN side%=1
4632 wimp%!0=whan%
4633 SYS "XWimp_GetWindowInfo",,(wimp% OR %1) TO ;f%
4634 IF (f% AND 1)=0 THEN
4635   return%=coord%+wimp%!(side%*12+4)-wimp%!(side%*4+20)
4636 ENDIF
4637 =return%
4638 :
4639 DEF FNwimp_screentowork(whan%,coord%,side%)
4640 LOCAL f%,return%
4641 IF side%<>0 THEN side%=1
4642 return%=0
4643 wimp%!0=whan%
4644 SYS "XWimp_GetWindowInfo",,(wimp% OR %1) TO ;f%
4645 IF (f% AND 1)=0 THEN
4646   return%=coord%+wimp%!(side%*4+20)-wimp%!(side%*12+4)
4647 ENDIF
4648 =return%
4649 :
4650 DEF FNwimp_lengthtoOS(lengthreal,scalereal,inch%)
4651 LOCAL returnreal
4652 IF inch%=0 THEN
4653   returnreal=((lengthreal/25.4)*180)*(scalereal/100)
4654 ELSE
4655   returnreal=(lengthreal*180)*(scalereal/100)
4656 ENDIF
4657 =returnreal
4658 :
4659 DEF FNwimp_OStolength(osreal,scalereal,inch%)
4660 LOCAL returnreal
4661 IF inch%=0 THEN
4662   returnreal=((osreal/180)*25.4)*(scalereal/100)
4663 ELSE
4664   returnreal=(osreal/180)*(scalereal/100)
4665 ENDIF
4666 =returnreal
4667 :
4668 DEF FNwimp_getdaydatetime(choice%)
4669 LOCAL choice$,current$
4670 choice$=""
4671 IF choice%<0 THEN choice%=0
4672 IF choice%>3 THEN choice%=3
4673 current$=FNwint_getcurrentdateandtime
4674 CASE choice% OF
4675   WHEN 0:choice$=current$
4676   WHEN 1:choice$=LEFT$(current$,3)
4677   WHEN 2:choice$=MID$(current$,5,11)
4678   WHEN 3:choice$=RIGHT$(current$,8)
4679 ENDCASE
4680 =choice$
4681 :
4682 DEF FNwint_getcurrentdateandtime
4683 LOCAL format$
4684 format$="%W3 %DY %M3 %CE%YR %24:%MI:%SE"
4685 IF wDateblk%=0 THEN
4686   DIM wDateblk% 4,wResult% 63
4687 ENDIF
4688 ?wDateblk%=3
4689 SYS"OS_Word",14,wDateblk% TO ,wDateblk%
4690 SYS "Territory_ConvertDateAndTime",-1,wDateblk%,wResult%,64,format$ TO wResult%
4691 =FNwint_string(wResult%)
4692 :
4693 DEF FNwimp_roundfloat(areal)
4694 LOCAL a%,diffreal
4695 a%=areal
4696 diffreal=areal-a%
4697 IF ABS(diffreal)>=0.5 THEN
4698   IF areal<0 THEN
4699     a%=a%-1
4700   ELSE
4701     a%=a%+1
4702   ENDIF
4703 ENDIF
4704 =a%
4705 :
4706 DEF FNwimp_decplacesstr(number,decplaces%)
4707 LOCAL result$,return$,e$,e%,sign%,scale,@%
4708 @%="G10.9"
4709 sign%=SGN(number)
4710 result$=STR$(number)
4711 e%=INSTR(result$,"E")
4712 scale=10^(decplaces%+1)
4713 IF e%<>0 THEN
4714   e$=MID$(result$,e%)
4715   result$=LEFT$(result$,e%-1)
4716 ENDIF
4717 number=(ABS(VAL(result$))*scale)+0.5
4718 @%="+F25."+STR$(decplaces%)
4719 result$=STR$((number/scale)*sign%)
4720 IF INSTR(result$,".")=0 result$+="."
4721 IF decplaces%=0 THEN
4722   result$=STR$(VAL(result$))
4723   result$=LEFT$(result$,INSTR(result$,".")-1)
4724 ELSE
4725   result$=result$+STRING$(decplaces%,"0")
4726   result$=LEFT$(result$,INSTR(result$,".")+decplaces%)
4727 ENDIF
4728 return$=result$+e$
4729 =return$
4730 :
4731 DEF FNwimp_decplacesnum(number,decplaces%)
4732 LOCAL returnreal
4733 returnreal=VAL(FNwimp_decplacesstr(number,decplaces%))
4734 =returnreal
4735 :
4736 DEF FNwimp_numtodecstring(number%)
4737 LOCAL return$
4738 IF wConvert%=0 THEN DIM wConvert% wDimsize%-1
4739 return$=""
4740 SYS "OS_ConvertCardinal4",number%,wConvert%,wDimsize%
4741 return$=FNwint_string(wConvert%)
4742 =return$
4743 :
4744 DEF FNwimp_numtosigneddecstring(number%)
4745 LOCAL return$
4746 IF wConvert%=0 THEN DIM wConvert% wDimsize%-1
4747 return$=""
4748 SYS "OS_ConvertInteger4",number%,wConvert%,wDimsize%
4749 return$=FNwint_string(wConvert%)
4750 =return$
4751 :
4752 DEF FNwimp_numtohexstring(number%,digits%,prefix%)
4753 LOCAL return$
4754 IF wConvert%=0 THEN DIM wConvert% wDimsize%-1
4755 IF digits%<1 THEN digits%=1
4756 IF digits%>8 THEN digits%=8
4757 CASE digits% OF
4758   WHEN 3,5,7
4759   digits%+=1
4760 ENDCASE
4761 return$=""
4762 SYS "OS_ConvertHex"+STR$(digits%),number%,wConvert%,wDimsize%
4763 return$=FNwint_string(wConvert%)
4764 IF prefix%<>0 THEN return$="&"+return$
4765 =return$
4766 :
4767 DEF FNwimp_numtobinstring(number%,digits%,prefix%)
4768 LOCAL return$
4769 IF wConvert%=0 THEN DIM wConvert% wDimsize%-1
4770 IF digits%<1 THEN digits%=1
4771 IF digits%>4 THEN digits%=4
4772 return$=""
4773 SYS "OS_ConvertBinary"+STR$(digits%),number%,wConvert%,wDimsize%
4774 return$=FNwint_string(wConvert%)
4775 IF prefix%<>0 THEN return$="%"+return$
4776 =return$
4777 :
4778 DEF FNwimp_changecase(string$,upper%)
4779 LOCAL x%,table%,char%
4780 IF upper%<>0 THEN
4781   SYS "Territory_UpperCaseTable",-1 TO table%
4782 ELSE
4783   SYS "Territory_LowerCaseTable",-1 TO table%
4784 ENDIF
4785 FOR x%=1 TO LEN(string$)
4786   char%=ASC(MID$(string$,x%,1))
4787   MID$(string$,x%,1)=CHR$(table%?char%)
4788 NEXT
4789 =string$
4790 :
4791 REM Bugfix by Chris Johnson (10-Dec-2012)
4792 DEF PROCwint_help(desttask%,inref%,whan%,icon%,mousex%,mousey%,button%)
4793 LOCAL help$,menu%,item%,sub%,len%
4794 help$=""
4795 SYS "Wimp_GetMenuState",1,wimp%,whan%,icon%
4796 IF wimp%!0<>-1 THEN
4797   menu%=0:item%=0
4798   PROCwint_getmenuanditem(wLastmenu%,menu%,item%)
4799   sub%=!(menu%+8+(item%*24))
4800   IF sub%=whan% THEN
4801     help$=FNuser_help(whan%,icon%)
4802   ELSE
4803     help$=FNuser_menuhelp(menu%,item%)
4804   ENDIF
4805 ELSE
4806   help$=FNuser_help(whan%,icon%)
4807 ENDIF
4808 IF help$<>"" THEN
4809   REM following condition added by CAFJ
4810   IF LEN(help$) > 235 THEN
4811     help$ = LEFT$(help$,235)
4812   ENDIF
4813   wimp%!0=(LEN(help$)+24) AND NOT 3
4814   wimp%!12=inref%
4815   wimp%!16=&503
4816   PROCwint_zeroterminate(wimp%+20,help$)
4817   SYS "Wimp_SendMessage",17,wimp%,desttask%
4818 ENDIF
4819 ENDPROC
4820 :
4821 DEF PROCwimp_setsysvariable(var$,val$)
4822 SYS "XOS_SetVarVal",var$,val$,LEN(val$)
4823 ENDPROC
4824 :
4825 DEF PROCwimp_unsetsysvariable(var$)
4826 SYS "XOS_SetVarVal",var$,,-1
4827 ENDPROC
4828 :
4829 DEF FNwimp_testsysvariable(sysvar$)
4830 LOCAL return%,len%
4831 return%=TRUE
4832 $wimp%=sysvar$
4833 SYS "XOS_ReadVarVal",wimp%,wimp%+255,-1,,3 TO ,,len%
4834 IF len%=0 THEN return%=FALSE
4835 =return%
4836 :
4837 DEF FNwimp_getsysvariable(sysvar$)
4838 LOCAL return$,len%
4839 return$=""
4840 IF FNwimp_testsysvariable(sysvar$)=TRUE THEN
4841   $wimp%=sysvar$
4842   SYS "OS_ReadVarVal",wimp%,wimp%+255,255,,3 TO ,,len%
4843   wimp%?(len%+255)=13
4844   return$=FNwint_string(wimp%+255)
4845 ENDIF
4846 =return$
4847 :
4848 DEF FNwimp_istaskrunning(taskname$)
4849 LOCAL nextstart%,buffersize%,task$
4850 return%=FALSE
4851 buffersize%=16
4852 nextstart%=0
4853 REPEAT
4854   SYS "TaskManager_EnumerateTasks",nextstart%,wimp%,buffersize% TO nextstart%
4855   SYS "XOS_GenerateError",wimp%!4 TO task$
4856 UNTIL nextstart%<0 OR task$=taskname$
4857 IF task$=taskname$ THEN return%=TRUE
4858 =return%
4859 :
4860 DEF FNwimp_createstringblock(n%,l%,da%)
4861 LOCAL blk%
4862 l%+=2
4863 n%+=1
4864 blocksize%=((n%*l%)+8)-1
4865 IF da%<>0 THEN
4866   blk%=FNwimp_createdynamic(blocksize%,blocksize%,0,wappname$+" String block")
4867 ELSE
4868   DIM blk% blocksize%
4869 ENDIF
4870 !blk%=l%
4871 blk%!4=n%-1
4872 =blk%
4873 :
4874 DEF PROCwimp_putinstringblock(blk%,item$,n%,error%)
4875 LOCAL l%,highest%
4876 highest%=blk%!4
4877 IF (n%<1 OR n%>highest%) AND (error%<>0) THEN
4878   PROCwimp_error(werrtitle$,"Sorry, but you have specified a string position outside the defined block range of 1-"+STR$(highest%)+". No action will be taken.",1,"",0,1,"")
4879 ELSE
4880   IF n%<1 THEN n%=1
4881   IF n%>highest% THEN n%=highest%
4882   l%=!blk%
4883   $(blk%+(n%*l%)+8)=LEFT$(item$,l%)
4884 ENDIF
4885 ENDPROC
4886 :
4887 DEF FNwimp_getfromstringblock(blk%,n%,error%)
4888 LOCAL l%,value$,highest%
4889 value$=""
4890 highest%=blk%!4
4891 IF (n%<1 OR n%>highest%) AND (error%<>0) THEN
4892   PROCwimp_error(werrtitle$,"Sorry, but you have specified a position outside the defined block range of 1-"+STR$(highest%)+". The returned value will be a null string.",1,"",0,1,"")
4893 ELSE
4894   IF n%<1 THEN n%=1
4895   IF n%>highest% THEN n%=highest%
4896   l%=!blk%
4897   value$=FNwint_string(blk%+(n%*l%)+8)
4898 ENDIF
4899 =value$
4900 :
4901 DEF PROCwimp_setstringblock(block%,string$)
4902 LOCAL N%,max%
4903 max%=block%!4
4904 FOR N%=1 TO max%
4905   PROCwimp_putinstringblock(block%,string$,N%,0)
4906 NEXT
4907 ENDPROC
4908 :
4909 DEF FNwimp_createintegerblock(n%,da%)
4910 LOCAL blk%
4911 n%+=1
4912 blocksize%=(4*n%)-1
4913 IF da%<>0 THEN
4914   blk%=FNwimp_createdynamic(blocksize%,blocksize%,0,wappname$+" Integer block")
4915 ELSE
4916   DIM blk% blocksize%
4917 ENDIF
4918 blk%!0=n%-1
4919 =blk%
4920 :
4921 DEF PROCwimp_putinintegerblock(blk%,value%,n%,error%)
4922 LOCAL highest%
4923 highest%=blk%!0
4924 IF (n%<1 OR n%>highest%) AND (error%<>0) THEN
4925   PROCwimp_error(werrtitle$,"Sorry, but you have specified an integer position outside the defined block range of 1-"+STR$(highest%)+". No action will be taken.",1,"",0,1,"")
4926 ELSE
4927   IF n%<1 THEN n%=1
4928   IF n%>highest% THEN n%=highest%
4929   blk%!((n%+1)*4)=value%
4930 ENDIF
4931 ENDPROC
4932 :
4933 DEF FNwimp_getfromintegerblock(blk%,n%,error%)
4934 LOCAL highest%,value%
4935 value%=0
4936 highest%=blk%!0
4937 IF (n%<1 OR n%>highest%) AND (error%<>0) THEN
4938   PROCwimp_error(werrtitle$,"Sorry, but you have specified a position outside the defined block range of 1-"+STR$(highest%)+". The returned value will be 0.",1,"",0,1,"")
4939 ELSE
4940   IF n%<1 THEN n%=1
4941   IF n%>highest% THEN n%=highest%
4942   value%=blk%!((n%+1)*4)
4943 ENDIF
4944 =value%
4945 :
4946 DEF PROCwimp_setintegerblock(block%,value%)
4947 LOCAL N%,max%
4948 max%=block%!0
4949 FOR N%=1 TO max%
4950   PROCwimp_putinintegerblock(block%,value%,N%,0)
4951 NEXT
4952 ENDPROC
4953 :
4954 DEF PROCwint_savewimp
4955 SYS "Wimp_TransferBlock",wTask%,wimp%,wTask%,wTempblk%,320
4956 ENDPROC
4957 :
4958 DEF PROCwint_loadwimp
4959 SYS "Wimp_TransferBlock",wTask%,wTempblk%,wTask%,wimp%,320
4960 ENDPROC
4961 :
4962 DEF PROCwint_savewimp2
4963 SYS "Wimp_TransferBlock",wTask%,wimp%,wTask%,wTempblk2%,320
4964 ENDPROC
4965 :
4966 DEF PROCwint_loadwimp2
4967 SYS "Wimp_TransferBlock",wTask%,wTempblk2%,wTask%,wimp%,320
4968 ENDPROC
4969 :
4970 DEF PROCwimp_hourglasson
4971 SYS "Hourglass_On"
4972 ENDPROC
4973 :
4974 DEF PROCwimp_hourglassoff
4975 SYS "Hourglass_Off"
4976 ENDPROC
4977 :
4978 DEF PROCwimp_hourglasspercentage(percent%)
4979 SYS "Hourglass_Percentage",percent%
4980 ENDPROC
4981 :
4982 DEF PROCwimp_setcolour(r%,g%,b%,background%)
4983 LOCAL c%,flags%
4984 c%=(b%<<24)+(g%<<16)+(r%<<8)
4985 IF background%<>0 THEN background%=1
4986 flags%=(1<<8)+(background%<<7)
4987 SYS "ColourTrans_SetGCOL",c%,,,flags%,0
4988 ENDPROC
4989 :
4990 DEF PROCwimp_plotwindowline(window%,point1x%,point1y%,point2x%,point2y%,type%)
4991 IF wPrinting%=FALSE THEN
4992   point1x%=FNwimp_worktoscreen(window%,point1x%,0)
4993   point1y%=FNwimp_worktoscreen(window%,point1y%,1)
4994   point2x%=FNwimp_worktoscreen(window%,point2x%,0)
4995   point2y%=FNwimp_worktoscreen(window%,point2y%,1)
4996 ENDIF
4997 MOVE point1x%,point1y%
4998 PLOT (type%*16)+5,point2x%,point2y%
4999 ENDPROC
5000 :
5001 DEF PROCwimp_plotwindowrectangle(window%,bottomleftx%,bottomlefty%,width%,height%,fill%)
5002 IF wPrinting%=FALSE THEN
5003   bottomleftx%=FNwimp_worktoscreen(window%,bottomleftx%,0)
5004   bottomlefty%=FNwimp_worktoscreen(window%,bottomlefty%,1)
5005 ENDIF
5006 IF fill%=0 THEN
5007   RECTANGLE bottomleftx%,bottomlefty%,width%,height%
5008 ELSE
5009   RECTANGLE FILL bottomleftx%,bottomlefty%,width%,height%
5010 ENDIF
5011 ENDPROC
5012 :
5013 DEF PROCwimp_plotwindowcircle(window%,centrex%,centrey%,radius%,fill%)
5014 IF wPrinting%=FALSE THEN
5015   centrex%=FNwimp_worktoscreen(window%,centrex%,0)
5016   centrey%=FNwimp_worktoscreen(window%,centrey%,1)
5017 ENDIF
5018 IF fill%=0 THEN
5019   CIRCLE centrex%,centrey%,radius%
5020 ELSE
5021   CIRCLE FILL centrex%,centrey%,radius%
5022 ENDIF
5023 ENDPROC
5024 :
5025 DEF PROCwimp_plotwindowellipse(window%,centrex%,centrey%,semimajor%,semiminor%,rotatedegrees,fill%)
5026 LOCAL rads
5027 IF wPrinting%=FALSE THEN
5028   centrex%=FNwimp_worktoscreen(window%,centrex%,0)
5029   centrey%=FNwimp_worktoscreen(window%,centrey%,1)
5030 ENDIF
5031 rads=RAD(rotatedegrees)
5032 IF fill%=0 THEN
5033   ELLIPSE centrex%,centrey%,semimajor%,semiminor%,rads
5034 ELSE
5035   ELLIPSE FILL centrex%,centrey%,semimajor%,semiminor%,rads
5036 ENDIF
5037 ENDPROC
5038 :
5039 DEF PROCwimp_plotwindowtriangle(window%,point1x%,point1y%,point2x%,point2y%,point3x%,point3y%,fill%)
5040 IF wPrinting%=FALSE THEN
5041   point1x%=FNwimp_worktoscreen(window%,point1x%,0)
5042   point1y%=FNwimp_worktoscreen(window%,point1y%,1)
5043   point2x%=FNwimp_worktoscreen(window%,point2x%,0)
5044   point2y%=FNwimp_worktoscreen(window%,point2y%,1)
5045   point3x%=FNwimp_worktoscreen(window%,point3x%,0)
5046   point3y%=FNwimp_worktoscreen(window%,point3y%,1)
5047 ENDIF
5048 MOVE point1x%,point1y%
5049 IF fill%=1 THEN
5050   MOVE point2x%,point2y%
5051   PLOT &55,point3x%,point3y%
5052 ELSE
5053   DRAW point2x%,point2y%
5054   DRAW point3x%,point3y%
5055   DRAW point1x%,point1y%
5056 ENDIF
5057 ENDPROC
5058 :
5059 DEF PROCwimp_increaseslot(n%)
5060 starthimem%=HIMEM
5061 END=HIMEM+n%
5062 new%=HIMEM
5063 IF HIMEM-starthimem%<n% THEN PROCwimp_error(werrtitle$,"Failed to grab "+STR$n%+" bytes (only "+STR$(HIMEM-starthimem%)+" bytes grabbed). New WimpSlot size is "+STR$(INT((HIMEM-PAGE)/1024)+4)+"k.",1,"",0,1,"")
5064 ENDPROC
5065 :
5066 DEF PROCwimp_starttask(command$)
5067 SYS "Wimp_StartTask",command$
5068 ENDPROC
5069 :
5070 DEF PROCwimp_pause(seconds)
5071 LOCAL starttime%,endtime%
5072 seconds=ABS(seconds)
5073 SYS "OS_ReadMonotonicTime" TO starttime%
5074 REPEAT
5075   SYS "OS_ReadMonotonicTime" TO endtime%
5076 UNTIL endtime% > (starttime%+(seconds*100))
5077 ENDPROC
5078 :
5079 DEF FNwint_string(wptr%)
5080 LOCAL a$
5081 SYS "OS_WriteN",wptr%,0 TO a$
5082 =a$
5083 :
5084 DEF FNwint_extractfiletoloadandstartupoptions(envstr$)
5085 LOCAL a$,L%,i%,temp$,leaf$,dir$,o%
5086 a$=envstr$
5087 FOR L%=1 TO 3
5088   i%=INSTR(a$," ")
5089   a$=RIGHT$(a$,LEN(a$)-i%)
5090 NEXT L%
5091 IF a$<>"" THEN
5092   i%=INSTR(a$," ")
5093   IF i%>0 THEN
5094     temp$=LEFT$(a$,i%-1)
5095   ELSE
5096     temp$=a$
5097   ENDIF
5098   leaf$=FNwimp_getleafname(temp$)
5099   dir$=LEFT$(temp$,LEN(temp$)-LEN(leaf$))
5100   SYS "OS_File",21,leaf$,,,dir$ TO o%
5101   IF o%=1 THEN
5102     IF i%>0 THEN
5103       wStartupoption$+=RIGHT$(a$,LEN(a$)-i%)
5104     ELSE
5105       wStartupoption$+=""
5106     ENDIF
5107     a$=temp$
5108   ELSE
5109     wStartupoption$+=a$
5110     a$=""
5111   ENDIF
5112 ENDIF
5113 =a$
5114 :
5115 DEF PROCwint_checkforload(startupfile$)
5116 LOCAL leaf$,dir$,ftype%,ftype$,dummy%
5117 IF startupfile$<>"" THEN
5118   leaf$=FNwimp_getleafname(startupfile$)
5119   dir$=LEFT$(startupfile$,LEN(startupfile$)-LEN(leaf$))
5120   SYS "OS_File",21,leaf$,,,dir$ TO ,,,,,,ftype%
5121   ftype$=RIGHT$("00"+STR$~(ftype%),3)
5122   dummy%=FNuser_loaddata(startupfile$,0,-1,ftype$,-1,-1)
5123 ENDIF
5124 ENDPROC
5125 :
5126 DEF PROCwint_desktopsave
5127 LOCAL string$
5128 LOCAL ERROR
5129 ON ERROR LOCAL wimp%!12=wimp%!8:SYS "Wimp_SendMessage",19,wimp%,wimp%!4:RESTORE ERROR:ENDPROC
5130 IF wDesktopsave%=TRUE THEN
5131   string$="Run "+wDesktopsave$+CHR$(10)
5132   SYS "XOS_GBPB",2,wimp%!20,string$,LEN(string$)
5133 ENDIF
5134 RESTORE ERROR
5135 ENDPROC
5136 :
5137 DEF PROCwint_iconise(desttask%,inref%,window%)
5138 LOCAL text$,spritename$
5139 IF window%<>0 THEN
5140   wICONISE%=TRUE
5141   PROCwimp_closewindow(window%)
5142   text$=FNwimp_getwindowtitle(window%)
5143   IF text$="" OR INSTR(text$,"untitled")>0 THEN
5144     text$=wappname$
5145   ENDIF
5146   spritename$=wappname$
5147   IF LEN(spritename$)>7 THEN
5148     spritename$=LEFT$(spritename$,7)
5149   ENDIF
5150   PROCuser_iconise(window%,text$,spritename$)
5151   IF LEN(spritename$)>7 THEN
5152     PROCwimp_error(werrtitle$,"Your intended customised iconiser sprite name has more than 7 characters, so the Wimp will display a default icon instead.",1,"",0,1,"")
5153   ENDIF
5154   wimp%!0=256
5155   wimp%!12=inref%
5156   wimp%!16=&400CC
5157   wimp%!20=window%
5158   wimp%!24=0
5159   PROCwint_zeroterminate(wimp%+28,spritename$)
5160   PROCwint_zeroterminate(wimp%+36,text$)
5161   SYS "Wimp_SendMessage",17,wimp%,desttask%
5162 ENDIF
5163 ENDPROC
5164 :
5165 DEF FNwimp_osversion
5166 LOCAL mod%,a$,a%
5167 SYS "OS_Module",18,"UtilityModule" TO ,,,mod%
5168 mod%+=(mod%!&14)
5169 a$=FNwint_string(mod%)
5170 a$=MID$(a$,INSTR(a$,CHR$(9))+1)
5171 a$=MID$(a$,1,1)+MID$(a$,3,2)
5172 a%=VAL(a$)
5173 =a%
5174 :
5175 DEF PROCwint_scalefactors(xscalereal,yscalereal,RETURN xmult, RETURN ymult,RETURN xdiv,RETURN ydiv)
5176 LOCAL xi%,yi%,x$,y$,xii%,yii%
5177 xi%=xscalereal
5178 yi%=yscalereal
5179 x$=STR$xscalereal
5180 y$=STR$yscalereal
5181 xii%=INSTR(x$,".")
5182 yii%=INSTR(y$,".")
5183 x$=LEFT$(RIGHT$(x$,LEN(x$)-xii%),6)
5184 y$=LEFT$(RIGHT$(y$,LEN(y$)-yii%),6)
5185 IF xii%=0 THEN x$=""
5186 IF yii%=0 THEN y$=""
5187 xmult=VAL(STR$xi%+x$)
5188 ymult=VAL(STR$yi%+y$)
5189 xdiv=10^LEN(x$)
5190 ydiv=10^LEN(y$)
5191 ENDPROC
5192 :
5193 DEF FNwimp_loadjpegfile(jpegfilepath$,address%,warning%)
5194 =FNwimp_loadfile(jpegfilepath$,address%,warning%)
5195 :
5196 DEF PROCwimp_savejpeg(savepath$,jpeghandle%)
5197 PROCwimp_savefile(savepath$,jpeghandle%,&C85)
5198 ENDPROC
5199 :
5200 REM getting jpeg info
5201 DEF PROCwimp_getjpegWandH(jpeghandle%, RETURN width%, RETURN height%, dpi90%)
5202 LOCAL realsize%,realfile%
5203 LOCAL ro%,xden%,yden%
5204 realsize%=jpeghandle%!0
5205 realfile%=jpeghandle%+4
5206 value%=0
5207 ro%=1
5208 SYS "JPEG_Info",ro%,realfile%,realsize% TO ,,width%,height%,xden%,yden%
5209 IF dpi90%<>0 THEN
5210   xden%=90
5211   yden%=90
5212 ENDIF
5213 width%=FNwimp_lengthtoOS((width%/xden%),100,1)
5214 height%=FNwimp_lengthtoOS((height%/yden%),100,1)
5215 ENDPROC
5216 :
5217 :
5218 DEF FNwimp_getjpegsize(jpeghandle%,side%,dpi90%)
5219 LOCAL realsize%,realfile%
5220 LOCAL ro%,width%,height%,xden%,yden%,value%
5221 realsize%=jpeghandle%!0
5222 realfile%=jpeghandle%+4
5223 value%=0
5224 ro%=1
5225 SYS "JPEG_Info",ro%,realfile%,realsize% TO ,,width%,height%,xden%,yden%
5226 IF dpi90%<>0 THEN
5227   xden%=90
5228   yden%=90
5229 ENDIF
5230 IF side%=0 THEN
5231   value%=FNwimp_lengthtoOS((width%/xden%),100,1)
5232 ELSE
5233   value%=FNwimp_lengthtoOS((height%/yden%),100,1)
5234 ENDIF
5235 =value%
5236 :
5237 DEF FNwimp_getjpegsizefile(jpegfilepath$,side%,dpi90%,warning%)
5238 LOCAL value%,ro%,width%,height%,xden%,yden%,f%,flag%
5239 value%=0
5240 ro%=1
5241 SYS "XJPEG_FileInfo",ro%,jpegfilepath$ TO ,,width%,height%,xden%,yden%;f%
5242 flag%=(f% AND 1)
5243 IF flag%=0 THEN
5244   IF dpi90%<>0 THEN
5245     xden%=90
5246     yden%=90
5247   ENDIF
5248   IF side%=0 THEN
5249     value%=FNwimp_lengthtoOS((width%/xden%),100,1)
5250   ELSE
5251     value%=FNwimp_lengthtoOS((height%/yden%),100,1)
5252   ENDIF
5253 ELSE
5254   IF warning%<>0 THEN
5255     PROCwimp_error(werrtitle$,"Sorry, a file called "+jpegfilepath$+" cannot be found. A size of 0 will be returned.",1,"",0,1,"")
5256   ENDIF
5257 ENDIF
5258 =value%
5259 :
5260 DEF PROCwimp_renderwindowjpeg(window%,jpeghandle%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal)
5261 IF wPrinting%=FALSE THEN
5262   bx%=FNwimp_worktoscreen(window%,bx%,0)
5263   by%=FNwimp_worktoscreen(window%,by%,1)
5264 ENDIF
5265 PROCwimp_renderjpeg(jpeghandle%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal)
5266 ENDPROC
5267 :
5268 DEF PROCwimp_renderjpeg(jpeghandle%,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal)
5269 LOCAL realsize%,realfile%
5270 LOCAL r1%
5271 realsize%=jpeghandle%!0
5272 realfile%=jpeghandle%+4
5273 wDmatrix%!0=&10000*xscalereal
5274 wDmatrix%!4=0
5275 wDmatrix%!8=0
5276 wDmatrix%!12=&10000*yscalereal
5277 wDmatrix%!16=bx%*256
5278 wDmatrix%!20=by%*256
5279 r1%=%110
5280 SYS "JPEG_PlotTransformed",realfile%,r1%,wDmatrix%,realsize%
5281 ENDPROC
5282 :
5283 DEF PROCwimp_renderwindowjpegfile(window%,jpegfilepath$,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal,warning%)
5284 IF wPrinting%=FALSE THEN
5285   bx%=FNwimp_worktoscreen(window%,bx%,0)
5286   by%=FNwimp_worktoscreen(window%,by%,1)
5287 ENDIF
5288 PROCwimp_renderjpegfile(jpegfilepath$,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal,warning%)
5289 ENDPROC
5290 :
5291 DEF PROCwimp_renderjpegfile(jpegfilepath$,bx%,by%,minx%,miny%,maxx%,maxy%,xscalereal,yscalereal,warning%)
5292 LOCAL xmult,ymult,xdiv,ydiv,r4%,f%,flag%
5293 xmult=1
5294 ymult=1
5295 xdiv=1
5296 ydiv=1
5297 PROCwint_scalefactors(xscalereal,yscalereal,xmult,ymult,xdiv,ydiv)
5298 wScale%!0=xmult
5299 wScale%!4=ymult
5300 wScale%!8=xdiv
5301 wScale%!12=ydiv
5302 r4%=%11
5303 SYS "XJPEG_PlotFileScaled",jpegfilepath$,bx%,by%,wScale%,r4% TO ;f%
5304 flag%=(f% AND 1)
5305 IF (flag%=1) AND (warning%<>0) THEN
5306   PROCwimp_error(werrtitle$,"Sorry, a file called "+jpegfilepath$+" cannot be found.",1,"",0,1,"")
5307 ENDIF
5308 ENDPROC
