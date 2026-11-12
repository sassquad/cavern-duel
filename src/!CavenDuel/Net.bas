1 REM >Net
2 REM Cavern Duel network play, loaded by Game with LIBRARY
3 REM Both machines run the whole game in lockstep and swap each player's controls every frame over TCP.
4 REM The host plays player 1 and picks the random seed; whoever joins plays player 2.
5 REM The Host and Join buttons on the menu start a game. An address is a numeric IP address or a name, with :<port> on the end if it isn't 30123.
6 REM If CavernDuel$Relay holds an address, Host connects out to a relay there (tools/netpeer.py) instead of waiting on port 30123. Over the internet, both connect to tools/relay.py, which pairs them by a room code.
7 REM Each frame each side sends two bytes: its controls (1 left, 2 right, 4 up, 8 down, 16 fire, 32 quit, 64 skip winner)
8 REM and a check of the game's state (0 for no check). Controls take effect net_delay% frames after they are sent (the host times the connection and picks this),
9 REM on both machines at once, so a little network lag doesn't slow the game down.
10 :
11 DEF PROCnet_init
12 DIM net_addr% 15,net_io% 63,net_ifs% 255,net_qin%(7),net_qck%(7)
13 net_sock%=-1:net_listen%=-1:net_player%=0:net_seed%=0:net_frame%=0:net_why$="":net_room$=""
14 net_port%=30123:net_delay%=2:net_version%=3:net_wait%=1000
15 ENDPROC
16 :
17 DEF FNnet_connect(role%,host$,room$,seed%):REM role% 0 for one machine, 1 to host, 2 to join; TRUE once ready. host$ is who to connect to, "" for a host to wait. room$ is for the internet relay: "+" opens a room, a code joins one
18 LOCAL i%,f%
19 PROCnet_close:net_why$="":net_seed%=seed%:net_player%=0:net_room$=room$
20 IF role%=0 THEN =TRUE
21 SYS "XOS_SWINumberFromString",,"Socket_Creat" TO ;f%
22 IF f% AND 1 THEN net_why$="No network: the Internet module isn't loaded":=FALSE
23 net_port%=30123:i%=INSTR(host$,":"):IF i% THEN net_port%=VAL(MID$(host$,i%+1)):host$=LEFT$(host$,i%-1)
24 net_player%=role%
25 IF host$="" THEN PROCnet_accept ELSE PROCnet_dial(host$):IF net_why$="" AND net_room$<>"" THEN PROCnet_enterroom
26 IF net_why$="" THEN PROCnet_hello
27 IF net_why$="" THEN =TRUE
28 PROCnet_close:net_player%=0
29 =FALSE
30 :
31 DEF PROCnet_begin:REM Everything is ready: send the frames before the first one, which nobody pressed anything in
32 LOCAL i%
33 FOR i%=0 TO 7:net_qin%(i%)=0:net_qck%(i%)=0:NEXT
34 FOR i%=0 TO 2*net_delay%-1:net_io%?i%=0:NEXT
35 PROCnet_send(net_io%,2*net_delay%)
36 net_frame%=0
37 ENDPROC
38 :
39 DEF PROCnet_stop(why$):REM The network game can't go on
40 net_why$=why$
41 ENDPROC
42 :
43 DEF FNnet_player:REM 1 or 2 for the side this machine plays in a network game, 0 for a game on one machine
44 =net_player%
45 :
46 DEF FNnet_seed:REM The random seed for the game: the host's, in a network game
47 =net_seed%
48 :
49 DEF FNnet_lost:REM TRUE once the network game can't go on
50 =net_why$<>""
51 :
52 DEF FNnet_why:REM Why the network game couldn't start or go on
53 =net_why$
54 :
55 DEF PROCnet_swap(RETURN mine%,check%,RETURN theirs%):REM Send this frame's controls and state check; get back both sides' controls for the frame being played now
56 LOCAL i%
57 IF net_why$<>"" THEN mine%=0:theirs%=0:ENDPROC
58 i%=(net_frame%+net_delay%) MOD 8:net_qin%(i%)=mine%:net_qck%(i%)=check%
59 ?net_io%=mine%:net_io%?1=check%:PROCnet_send(net_io%,2)
60 PROCnet_recv(net_io%,2)
61 i%=net_frame% MOD 8:mine%=net_qin%(i%):theirs%=0
62 IF net_why$<>"" THEN ENDPROC
63 theirs%=?net_io%
64 IF net_io%?1<>0 AND net_qck%(i%)<>0 AND net_io%?1<>net_qck%(i%) THEN net_why$="The two games have drifted apart (frame "+STR$net_frame%+")"
65 net_frame%+=1
66 ENDPROC
67 :
68 DEF PROCnet_close
69 IF net_sock%>=0 THEN SYS "XSocket_Close",net_sock%:net_sock%=-1
70 IF net_listen%>=0 THEN SYS "XSocket_Close",net_listen%:net_listen%=-1
71 ENDPROC
72 :
73 DEF PROCnet_accept:REM Host: wait for the other player to connect
74 LOCAL s%,e%,f%,ip$
75 ip$=FNnet_myip
76 PROCuser_netstatus(FNnet_waiting(ip$))
77 net_listen%=FNnet_socket:IF net_listen%<0 THEN ENDPROC
78 !net_io%=1:SYS "XSocket_Setsockopt",net_listen%,&FFFF,4,net_io%,4:REM SO_REUSEADDR, so the port can be used again straight after a game
79 PROCnet_address(net_port%)
80 SYS "XSocket_Bind",net_listen%,net_addr%,16 TO e%;f%
81 IF f% AND 1 THEN PROCnet_fail(e%,"Can't use port "+STR$net_port%):ENDPROC
82 SYS "XSocket_Listen",net_listen%,1 TO e%;f%
83 IF f% AND 1 THEN PROCnet_fail(e%,"Can't use port "+STR$net_port%):ENDPROC
84 REPEAT
85 !net_io%=16:SYS "XSocket_Accept",net_listen%,net_io%+4,net_io% TO s%;f%
86 IF f% AND 1 THEN IF FNnet_errno(s%)<>35 THEN PROCnet_fail(s%,"Waiting for player 2"):ENDPROC
87 IF INKEY-97 THEN net_why$="Cancelled":ENDPROC
88 UNTIL (f% AND 1)=0
89 net_sock%=s%
90 SYS "XSocket_Close",net_listen%:net_listen%=-1
91 PROCnet_ready
92 ENDPROC
93 :
94 DEF PROCnet_dial(host$):REM Connect to the host or relay, trying again every second until it answers; the status line says why each try failed
95 LOCAL e%,f%,n%,t%,try%,why$
96 IF FNnet_lookup(host$)=FALSE THEN ENDPROC
97 REPEAT
98 try%+=1:PROCuser_netstatus("Connecting to "+host$+":"+STR$net_port%+" (try "+STR$try%+why$+") - Tab cancels")
99 net_sock%=FNnet_socket:IF net_sock%<0 THEN ENDPROC
100 SYS "XSocket_Connect",net_sock%,net_addr%,16 TO e%;f%
101 IF f% AND 1 THEN n%=FNnet_errno(e%) ELSE n%=0
102 IF n%=36 THEN n%=FNnet_connected:REM EINPROGRESS
103 IF net_why$<>"" THEN ENDPROC
104 IF n%<>0 THEN
105 SYS "XSocket_Close",net_sock%:net_sock%=-1
106 why$=", "+FNnet_errname(n%)
107 IF n%<>60 AND n%<>61 AND n%<>64 THEN net_why$="Can't connect to "+host$+why$:ENDPROC:REM Only timed out, refused and host down are worth another try
108 t%=TIME:REPEAT:IF INKEY-97 THEN net_why$="Cancelled":ENDPROC
109 UNTIL TIME-t%>100
110 ENDIF
111 UNTIL n%=0
112 PROCnet_ready
113 ENDPROC
114 :
115 DEF FNnet_connected:REM Wait up to 5 seconds for a connection in progress; 0 if it connected, or why not. Asking Socket_Connect again doesn't work on RISC OS 3.71
116 LOCAL r%,f%,t%,i%
117 t%=TIME
118 REPEAT
119 FOR i%=0 TO 28 STEP 4:net_io%!i%=0:NEXT
120 net_io%!(net_sock% DIV 32*4)=1<<(net_sock% MOD 32)
121 net_io%!32=0:net_io%!36=0:REM Don't let Socket_Select wait
122 SYS "XSocket_Select",net_sock%+1,0,net_io%,0,net_io%+32 TO r%;f%
123 IF f% AND 1 THEN =FNnet_errno(r%)
124 IF INKEY-97 THEN net_why$="Cancelled":=-1
125 IF r%=0 AND TIME-t%>500 THEN =60
126 UNTIL r%>0
127 net_io%!44=4:SYS "XSocket_Getsockopt",net_sock%,&FFFF,&1007,net_io%+40,net_io%+44 TO r%;f%:REM SO_ERROR
128 IF f% AND 1 THEN =FNnet_errno(r%)
129 =net_io%!40
130 :
131 DEF FNnet_errname(n%):REM What a connection error means; Socket_Getsockopt gives only the number
132 CASE n% OF
133 WHEN 60:="timed out"
134 WHEN 61:="refused"
135 WHEN 64:="host is down"
136 WHEN 65:="no route to host"
137 ENDCASE
138 ="error "+STR$n%
139 :
140 DEF PROCnet_ready:REM Connected: send each frame at once rather than waiting to fill a packet
141 !net_io%=1:SYS "XSocket_Ioctl",net_sock%,&8004667E,net_io%:REM FIONBIO
142 !net_io%=1:SYS "XSocket_Setsockopt",net_sock%,6,1,net_io%,4:REM TCP_NODELAY
143 ENDPROC
144 :
145 DEF PROCnet_hello:REM Swap greetings; the host sends its seed so both machines lay out the same game. No time limit: through a relay, the other player may not have connected yet
146 IF net_player%=2 OR net_room$="" THEN PROCuser_netstatus("Connected - waiting for the other player - Tab cancels"):REM A host in a room keeps its code on show
147 net_wait%=&7FFFFFFF:$net_io%="CD"+MID$("HJ",net_player%,1):net_io%?3=net_version%:net_io%!4=net_seed%
148 IF net_player%=1 THEN PROCnet_send(net_io%,8) ELSE PROCnet_send(net_io%,4)
149 IF net_player%=1 THEN PROCnet_recv(net_io%,4) ELSE PROCnet_recv(net_io%,8)
150 net_wait%=1000:PROCnet_nohello:IF net_why$<>"" THEN ENDPROC
151 IF ?net_io%<>67 OR net_io%?1<>68 THEN net_why$="The other end isn't Cavern Duel":ENDPROC
152 IF net_io%?2=ASC(MID$("HJ",net_player%,1)) THEN net_why$="Both players are set to "+MID$("hostjoin",net_player%*4-3,4):ENDPROC
153 IF net_io%?3<>net_version% THEN net_why$="The other player has a different version of Cavern Duel":ENDPROC
154 IF net_player%=2 THEN net_seed%=net_io%!4
155 PROCnet_setdelay:ENDPROC
156 :
157 DEF PROCnet_send(p%,n%):REM Send n% bytes from p%
158 LOCAL done%,r%,f%,t%
159 t%=TIME
160 WHILE done%<n% AND net_why$=""
161 SYS "XSocket_Send",net_sock%,p%+done%,n%-done%,0 TO r%;f%
162 IF f% AND 1 THEN
163 IF FNnet_errno(r%)<>35 THEN PROCnet_fail(r%,"Lost the connection")
164 ELSE
165 done%+=r%:t%=TIME
166 ENDIF
167 IF TIME-t%>1000 THEN net_why$="The other player stopped responding"
168 ENDWHILE
169 ENDPROC
170 :
171 DEF PROCnet_recv(p%,n%):REM Wait for n% bytes into p%; after a second's wait, Tab gives up
172 LOCAL done%,r%,f%,t%
173 t%=TIME
174 WHILE done%<n% AND net_why$=""
175 SYS "XSocket_Recv",net_sock%,p%+done%,n%-done%,0 TO r%;f%
176 IF f% AND 1 THEN
177 IF FNnet_errno(r%)<>35 THEN PROCnet_fail(r%,"Lost the connection")
178 ELSE
179 IF r%=0 THEN net_why$="The other player left the game"
180 done%+=r%:t%=TIME
181 ENDIF
182 IF TIME-t%>net_wait% THEN net_why$="The other player stopped responding"
183 IF TIME-t%>100 AND INKEY-97 THEN net_why$="You left the game"
184 ENDWHILE
185 ENDPROC
186 :
187 DEF FNnet_socket:REM A new non-blocking TCP socket, or -1
188 LOCAL s%,f%
189 SYS "XSocket_Creat",2,1,0 TO s%;f%
190 IF f% AND 1 THEN PROCnet_fail(s%,"No network"):=-1
191 !net_io%=1:SYS "XSocket_Ioctl",s%,&8004667E,net_io%:REM FIONBIO
192 =s%
193 :
194 DEF PROCnet_address(port%):REM net_addr% becomes a 4.3BSD sockaddr_in for any address: family 2, then the port in network byte order
195 LOCAL i%
196 FOR i%=0 TO 15:net_addr%?i%=0:NEXT
197 ?net_addr%=2:net_addr%?2=port%>>>8:net_addr%?3=port% AND 255
198 ENDPROC
199 :
200 DEF FNnet_ip(ip$):REM Put the address in ip$ and net_port% into net_addr%; FALSE if ip$ isn't four numbers 0 to 255
201 LOCAL i%,d%,n%
202 PROCnet_address(net_port%)
203 FOR i%=0 TO 3
204 d%=INSTR(ip$+".",".")
205 n%=VAL(LEFT$(ip$,d%-1))
206 IF d%=1 OR n%>255 OR LEFT$(ip$,d%-1)<>STR$n% THEN =FALSE
207 net_addr%?(4+i%)=n%:ip$=MID$(ip$,d%+1)
208 NEXT
209 =ip$=""
210 :
211 DEF FNnet_myip:REM This machine's network address, or "" if it can't tell; the first interface that isn't 127.x.x.x
212 LOCAL s%,e%,f%,i%,ip$
213 s%=FNnet_socket:net_why$="":IF s%<0 THEN =""
214 !net_io%=256:net_io%!4=net_ifs%
215 SYS "XSocket_Ioctl",s%,&C0086914,net_io% TO e%;f%:REM SIOCGIFCONF, with 32 bytes for each interface
216 IF (f% AND 1)=0 THEN
217 FOR i%=0 TO !net_io%-32 STEP 32
218 IF net_ifs%?(i%+16)=2 AND net_ifs%?(i%+20)<>127 AND ip$="" THEN ip$=STR$net_ifs%?(i%+20)+"."+STR$net_ifs%?(i%+21)+"."+STR$net_ifs%?(i%+22)+"."+STR$net_ifs%?(i%+23)
219 NEXT
220 ENDIF
221 SYS "XSocket_Close",s%
222 =ip$
223 :
224 DEF FNnet_var(name$):REM A system variable's value, or "" if it isn't set
225 LOCAL len%,f%
226 SYS "XOS_ReadVarVal",name$,net_io%,63,0,3 TO ,,len%;f%
227 IF f% AND 1 THEN =""
228 net_io%?len%=13
229 =$net_io%
230 :
231 DEF FNnet_errno(e%):REM The Unix error number in an Internet module error block
232 =!e% AND 255
233 :
234 DEF PROCnet_fail(e%,what$)
235 net_why$=what$+" ("+FNnet_text(e%)+")"
236 ENDPROC
237 :
238 DEF FNnet_text(e%):REM The message in an error block
239 LOCAL p%,s$
240 p%=e%+4:WHILE ?p%>=32:s$+=CHR$?p%:p%+=1:ENDWHILE
241 =s$
242 :
243 DEF PROCnet_setdelay:REM Five round trips of one byte, timed by the host, which then sends the delay to use. A frame reaches the game in time if it takes under net_delay%+1 frames each way, with a frame to spare here
244 LOCAL i%,t%,worst%
245 FOR i%=1 TO 5
246 t%=TIME
247 IF net_player%=1 THEN PROCnet_send(net_io%,1):PROCnet_recv(net_io%,1) ELSE PROCnet_recv(net_io%,1):PROCnet_send(net_io%,1)
248 IF TIME-t%>worst% THEN worst%=TIME-t%
249 NEXT
250 IF net_why$<>"" THEN ENDPROC
251 IF net_player%=1 THEN
252 net_delay%=(worst%+14) DIV 10-1
253 IF net_delay%<2 THEN net_delay%=2
254 IF net_delay%>6 THEN net_delay%=6:REM Past this, a game slows down rather than feel any worse. net_qin%() must hold net_delay%+1 frames
255 ?net_io%=net_delay%:PROCnet_send(net_io%,1)
256 ELSE
257 PROCnet_recv(net_io%,1):IF net_why$<>"" THEN ENDPROC
258 net_delay%=?net_io%
259 IF net_delay%<2 OR net_delay%>6 THEN net_why$="The other player has a different version of Cavern Duel"
260 ENDIF
261 ENDPROC
262 :
263 DEF PROCnet_enterroom:REM Tell the internet relay to open a room, or which room to join. Then the usual greeting goes through it
264 LOCAL a$
265 IF net_room$="+" THEN $net_io%="CDRH":net_io%?4=1:PROCnet_send(net_io%,5) ELSE $net_io%="CDRJ":net_io%?4=1:$(net_io%+5)=net_room$:PROCnet_send(net_io%,9)
266 PROCnet_recv(net_io%,4):IF net_why$<>"" THEN ENDPROC
267 net_io%?4=13:a$=$net_io%
268 CASE a$ OF
269 WHEN "CDRC":PROCnet_recv(net_io%,4):IF net_why$="" THEN net_io%?4=13:net_room$=$net_io%:PROCuser_netstatus("Your room code is "+net_room$+" - give it to player 2 - Tab cancels")
270 WHEN "CDRY":
271 WHEN "CDRN":net_why$="There's no room "+net_room$+" - check the code with the host"
272 WHEN "CDRB":IF net_room$="+" THEN net_why$="The relay is busy, or you have too many rooms open - try again later" ELSE net_why$="The relay is busy - try again later"
273 WHEN "CDRV":net_why$="The relay needs a different version of Cavern Duel"
274 OTHERWISE:net_why$="That isn't a Cavern Duel relay"
275 ENDCASE
276 ENDPROC
277 :
278 DEF PROCnet_nohello:REM Tab before the game starts cancels it. The relay closes a room nobody joins after 15 minutes, which otherwise looks like the other player leaving
279 IF net_why$="You left the game" THEN net_why$="Cancelled"
280 IF net_player%=1 AND net_room$<>"" AND net_why$="The other player left the game" THEN net_why$="Room "+net_room$+" closed - nobody joined in time"
281 ENDPROC
282 :
283 DEF FNnet_lookup(name$):REM Put name$, a numeric address or a name, and net_port% into net_addr%; FALSE, saying why, if it can't be found
284 LOCAL r%,h%,f%,i%
285 IF FNnet_ip(name$) THEN =TRUE
286 SYS "XOS_SWINumberFromString",,"Resolver_GetHostByName" TO ;f%
287 IF f% AND 1 THEN net_why$="Can't look up "+name$+" - the Resolver module isn't loaded":=FALSE
288 PROCuser_netstatus("Looking up "+name$)
289 SYS "XResolver_GetHostByName",,name$ TO r%,h%;f%:REM Waits for the answer. Resolver_GetHost, which doesn't, gave -1 for every name on RISC OS 5.27
295 IF (f% AND 1) OR r%<>0 OR h%=0 THEN net_why$="Can't find "+name$+" - is the name right, and is the network on?":=FALSE
296 IF h%!8<>2 OR h%!12<>4 THEN net_why$="Can't find "+name$:=FALSE
297 h%=!(h%!16):FOR i%=0 TO 3:net_addr%?(4+i%)=h%?i%:NEXT:REM The first of its addresses
298 =TRUE
299 :
300 DEF FNnet_waiting(ip$):REM What a host shows while it waits. In RPCEmu, RISC OS has an address on the emulator's own network (100.64.0.0/10), which the other player can't use
301 LOCAL a%,b%,d%
302 d%=INSTR(ip$+".","."):a%=VAL(LEFT$(ip$,d%-1)):b%=VAL(MID$(ip$,d%+1)):REM The first two numbers. VAL of the whole address would give 100.113, not 100
303 IF a%=100 AND b%>=64 AND b%<128 THEN ="Waiting for player 2 - give them your computer's address - Tab cancels"
304 IF ip$="" THEN ="Waiting for player 2 - Tab cancels"
305 ="Your address is "+ip$+" - Waiting for player 2 - Tab cancels"
