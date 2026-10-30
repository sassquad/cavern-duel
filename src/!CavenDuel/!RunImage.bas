1 REM Cavern Duel - !RunImage
2 REM Prepared by Stephen Scott using DrWimp 4.70, upgraded to DrWimp 5.04
3 REM Thanks to Andy Southgate for WIMP code of previous versions
4 REM V1.271 (26-Feb-2011)
5 REM (c) 1994-2011
6
7 LIBRARY "<CavenDuel$Dir>.DrWimp"
8
9 appname$="CavenDuel"
10 ver$="1.271 (26-Feb-2011)"
11
12 ON ERROR PROCwimp_error(appname$,REPORT$+" at line "+STR$(ERL),1,"",0,1,""):PROCuser_error:PROCwimp_closedown:END
13 task%=FNwimp_initialise(appname$,7000,360,0)
14 PROCwimp_poll
15 END
16 :
17 DEF PROCuser_error
18 ENDPROC
19 :
20 DEF PROCuser_initialise
21 info%=FNwimp_loadwindow("<CavenDuel$Dir>.Templates","info",0)
22 PROCwimp_puticontext(info%,0,"Cavern Duel")
23 PROCwimp_puticontext(info%,1,"2 player arcade action")
24 PROCwimp_puticontext(info%,2,"Graeme and Stephen Scott")
25 PROCwimp_puticontext(info%,4,ver$)
26 bar%=FNwimp_iconbar("!"+appname$,"",0,1)
27 barmenu%=FNwimp_createmenu("Cavern Duel/Info/Instructions/Quit",0)
28 PROCwimp_attachsubmenu(barmenu%,1,info%)
29 REM SYS "XOS_CLI","Set Game$Path CavenDuel:Screens.Default"
30 PROCwimp_starttask("Set Game$Path CavenDuel:Screens.Default")
31 ENDPROC
32 :
33 DEF FNuser_quit(type%)
34 =1
35 :
36 DEF PROCuser_redraw(window%,minx%,miny%,maxx%,maxy%,printing%,page%)
37 ENDPROC
38 :
39 DEF PROCuser_mouseclick(window%,icon%,button%,workx%,worky%)
40 IF window%=bar% PROCplay
41 ENDPROC
42 :
43 DEF FNuser_menu(window%,icon%,screenx%,screeny%)
44 return%=0
45 CASE window% OF
46 WHEN bar%:return%=barmenu%
47 ENDCASE
48 =return%
49 :
50 DEF PROCuser_openwindow(window%,x%,y%,stack%)
51 ENDPROC
52 :
53 DEF PROCuser_closewindow(window%)
54 ENDPROC
55 :
56 DEF FNuser_preclosewindow(window%)
57 =1
58 :
59 DEF FNuser_keypress(window%,icon%,key%)
60 =0
61 :
62 DEF PROCuser_menuselection(menu%,item%,font$)
63 IF menu%=barmenu% AND item%=2 PROCwimp_starttask("Run CavenDuel:!Help")
64 IF menu%=barmenu% AND item%=3 PROCwimp_quit(0)
65 ENDPROC
66 :
67 DEF FNuser_savefiletype(window%)
68 =""
69 :
70 DEF PROCuser_saveicon(window%,RETURN drag%,RETURN write%,RETURN ok%)
71 ENDPROC
72 :
73 DEF FNuser_savedata(path$,window%)
74 LOCAL ERROR
75 ON ERROR LOCAL =2
76 =0
77 :
78 DEF FNuser_help(window%,icon%)
79 =""
80 :
81 DEF FNuser_menuhelp(menu%,item%)
82 =""
83 :
84 DEF FNuser_loaddata(path$,window%,icon%,ftype$,workx%,worky%)
85 LOCAL return%,L%
86 return%=0
87 IF ftype$="022" THEN
88 REM SYS "XOS_CLI","Set Game$Path "+path$
89 PROCwimp_starttask("Set Game$Path "+path$)
90 PROCwimp_hourglassoff
91 PROCplay
92 return%=1
93 ENDIF
94 =return%
95 :
96 DEF PROCuser_enteringwindow(window%)
97 ENDPROC
98 :
99 DEF PROCuser_leavingwindow(window%)
100 ENDPROC
101 :
102 DEF FNuser_pane(window%)
103 =-1
104 :
105 DEF PROCuser_null
106 ENDPROC
107 :
108 DEF PROCuser_menuopen(menu%,window%,icon%)
109 ENDPROC
110 :
111 DEF PROCuser_overmenuarrow(rootmenu%,rootmenuitem%,RETURN nextsubmenu%,nextsubmenunumber%,parentmenuitem%,x%,y%)
112 ENDPROC
113 :
114 DEF FNuser_sliderback(window%,icon%)
115 =-1
116 :
117 DEF FNuser_slider(window%,icon%)
118 =-1
119 :
120 DEF PROCuser_slidervalue(window%,icon%,pcent%,dir%)
121 ENDPROC
122 :
123 DEF PROCuser_modechange
124 ENDPROC
125 :
126 DEF PROCuser_declarefonts
127 ENDPROC
128 :
129 DEF PROCuser_print(minx%,miny%,maxx%,maxy%,page%)
130 ENDPROC
131 :
132 DEF FNuser_printing(copy%,page%,totpages%,pagepos%)
133 =0
134 :
135 DEF PROCuser_printerchange
136 ENDPROC
137 :
138 DEF PROCuser_colourpickerrgb(red%,green%,blue%,none%)
139 ENDPROC
140 :
141 DEF PROCuser_colourpickermodel(model%,value1,value2,value3,value4,none%)
142 ENDPROC
143 :
144 DEF PROCuser_wimpmessage(messagenumber%,block%,reasoncode%)
145 ENDPROC
146 :
147 DEF PROCuser_iconise(window%,RETURN text$,RETURN sprite$)
148 ENDPROC
149 :
150 DEF FNuser_dragicon(window%,icon%,button%)
151 =0
152 :
153 DEF PROCuser_seticondragbounds(startwindow%,dragicon%,dragbutton%,startmousex%,startmousey%,RETURN boundsminx%,RETURN boundsminy%,RETURN boundsmaxx%,RETURN boundsmaxy%)
154 ENDPROC
155 :
156 DEF PROCuser_draggingicon(startwindow%,dragicon%,dragbutton%,startmousex%,startmousey%,mousex%,mousey%,overwindow%,overicon%,dragboxminx%,dragboxminy%,dragboxmaxx%,dragboxmaxy%)
157 ENDPROC
158 :
159 DEF PROCuser_endicondrag(startwindow%,dragicon%,dragbutton%,startmousex%,startmousey%,dragboxminx%,dragboxminy%,dragboxmaxx%,dragboxmaxy%,endwindow%,endicon%,endmousex%,endmousey%)
160 ENDPROC
161
162 DEF PROCplay
163 SYS "Hourglass_On"
164 VOICES 8
165 REM SYS "Wimp_StartTask","Obey -c <CavenDuel$Dir>.!RunGame"
166 PROCwimp_starttask("Obey -c <CavenDuel$Dir>.!RunGame")
167 ENDPROC
