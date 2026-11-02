1 REM >Net
2 REM Cavern Duel network play, loaded by Game with LIBRARY
3 REM Both machines run the whole game in lockstep and swap each player's controls every frame over TCP.
4 REM The host plays player 1 and picks the random seed; whoever joins plays player 2.
5 REM Until the menu has a network option, set CavernDuel$Net before starting the game:
6 REM   host              wait for the other player to connect, on port 30123
7 REM   host <address>    connect out to a relay (tools/netpeer.py) as player 1
8 REM   join <address>    connect to the host or relay as player 2
9 REM <address> is a numeric IP address, with :<port> on the end if it isn't 30123.
10 REM Each frame each side sends two bytes: its controls (1 left, 2 right, 4 up, 8 down, 16 fire, 32 quit, 64 skip winner)
11 REM and a check of the game's state (0 for no check). Controls take effect net_delay% frames after they are sent,
12 REM on both machines at once, so a little network lag doesn't slow the game down.
13 :
14 DEF PROCnet_init
15 DIM net_addr% 15,net_io% 63,net_qin%(7),net_qck%(7)
16 net_sock%=-1:net_listen%=-1:net_player%=0:net_seed%=0:net_frame%=0:net_why$=""
17 net_port%=30123:net_delay%=2:net_version%=1
18 ENDPROC
19 :
20 DEF FNnet_connect(seed%):REM TRUE when ready to play: straight away for a game on one machine, or once the other player is connected
21 LOCAL cfg$,role$,host$,i%,f%
22 PROCnet_close:net_why$="":net_seed%=seed%:net_player%=0
23 cfg$=FNnet_var("CavernDuel$Net")
24 IF cfg$="" THEN =TRUE
25 role$=LEFT$(cfg$,4):host$=MID$(cfg$,6):net_port%=30123
26 IF role$<>"host" AND role$<>"join" OR role$="join" AND host$="" THEN net_why$="CavernDuel$Net should be: host, host <address> or join <address>":=FALSE
27 SYS "XOS_SWINumberFromString",,"Socket_Creat" TO ;f%
28 IF f% AND 1 THEN net_why$="No network: the Internet module isn't loaded":=FALSE
29 i%=INSTR(host$,":"):IF i% THEN net_port%=VAL(MID$(host$,i%+1)):host$=LEFT$(host$,i%-1)
30 IF role$="host" THEN net_player%=1 ELSE net_player%=2
31 IF host$="" THEN PROCnet_accept ELSE PROCnet_dial(host$)
32 IF net_why$="" THEN PROCnet_hello
33 IF net_why$="" THEN =TRUE
34 PROCnet_close:net_player%=0
35 =FALSE
36 :
37 DEF FNnet_player:REM 1 or 2 for the side this machine plays in a network game, 0 for a game on one machine
38 =net_player%
39 :
40 DEF FNnet_seed:REM The random seed for the game: the host's, in a network game
41 =net_seed%
42 :
43 DEF FNnet_lost:REM TRUE once the network game can't go on
44 =net_why$<>""
45 :
46 DEF FNnet_why:REM Why the network game couldn't start or go on
47 =net_why$
48 :
49 DEF PROCnet_swap(RETURN mine%,check%,RETURN theirs%):REM Send this frame's controls and state check; get back both sides' controls for the frame being played now
50 LOCAL i%
51 IF net_why$<>"" THEN mine%=0:theirs%=0:ENDPROC
52 i%=(net_frame%+net_delay%) MOD 8:net_qin%(i%)=mine%:net_qck%(i%)=check%
53 ?net_io%=mine%:net_io%?1=check%:PROCnet_send(2)
54 PROCnet_recv(2)
55 i%=net_frame% MOD 8:mine%=net_qin%(i%):theirs%=0
56 IF net_why$<>"" THEN ENDPROC
57 theirs%=?net_io%
58 IF net_io%?1<>0 AND net_qck%(i%)<>0 AND net_io%?1<>net_qck%(i%) THEN net_why$="The two games have drifted apart (frame "+STR$net_frame%+")"
59 net_frame%+=1
60 ENDPROC
61 :
62 DEF PROCnet_close
63 IF net_sock%>=0 THEN SYS "XSocket_Close",net_sock%:net_sock%=-1
64 IF net_listen%>=0 THEN SYS "XSocket_Close",net_listen%:net_listen%=-1
65 ENDPROC
66 :
67 DEF PROCnet_accept:REM Host: wait for the other player to connect
68 LOCAL s%,e%,f%
69 PROCuser_netstatus("Waiting for player 2 on port "+STR$net_port%+" - Tab cancels")
70 net_listen%=FNnet_socket:IF net_listen%<0 THEN ENDPROC
71 !net_io%=1:SYS "XSocket_Setsockopt",net_listen%,&FFFF,4,net_io%,4:REM SO_REUSEADDR, so the port can be used again straight after a game
72 PROCnet_address(net_port%)
73 SYS "XSocket_Bind",net_listen%,net_addr%,16 TO e%;f%
74 IF f% AND 1 THEN PROCnet_fail(e%,"Can't use port "+STR$net_port%):ENDPROC
75 SYS "XSocket_Listen",net_listen%,1 TO e%;f%
76 IF f% AND 1 THEN PROCnet_fail(e%,"Can't use port "+STR$net_port%):ENDPROC
77 REPEAT
78 !net_io%=16:SYS "XSocket_Accept",net_listen%,net_io%+4,net_io% TO s%;f%
79 IF f% AND 1 THEN IF FNnet_errno(s%)<>35 THEN PROCnet_fail(s%,"Waiting for player 2"):ENDPROC
80 IF INKEY-97 THEN net_why$="Cancelled":ENDPROC
81 UNTIL (f% AND 1)=0
82 net_sock%=s%
83 SYS "XSocket_Close",net_listen%:net_listen%=-1
84 PROCnet_ready
85 ENDPROC
86 :
87 DEF PROCnet_dial(host$):REM Connect to the host or relay, trying again every second until it answers; the status line says why each try failed
88 LOCAL e%,f%,n%,t%,try%,why$
89 IF FNnet_ip(host$)=FALSE THEN net_why$="Use a numeric address, like 192.168.1.20, not "+host$:ENDPROC
90 REPEAT
91 try%+=1:PROCuser_netstatus("Connecting to "+host$+":"+STR$net_port%+" (try "+STR$try%+why$+") - Tab cancels")
92 net_sock%=FNnet_socket:IF net_sock%<0 THEN ENDPROC
93 SYS "XSocket_Connect",net_sock%,net_addr%,16 TO e%;f%
94 IF f% AND 1 THEN n%=FNnet_errno(e%) ELSE n%=0
95 IF n%=36 THEN n%=FNnet_connected:REM EINPROGRESS
96 IF net_why$<>"" THEN ENDPROC
97 IF n%<>0 THEN
98 SYS "XSocket_Close",net_sock%:net_sock%=-1
99 why$=", "+FNnet_errname(n%)
100 IF n%<>60 AND n%<>61 AND n%<>64 THEN net_why$="Can't connect to "+host$+why$:ENDPROC:REM Only timed out, refused and host down are worth another try
101 t%=TIME:REPEAT:IF INKEY-97 THEN net_why$="Cancelled":ENDPROC
102 UNTIL TIME-t%>100
103 ENDIF
104 UNTIL n%=0
105 PROCnet_ready
106 ENDPROC
107 :
108 DEF FNnet_connected:REM Wait up to 5 seconds for a connection in progress; 0 if it connected, or why not. Asking Socket_Connect again doesn't work on RISC OS 3.71
109 LOCAL r%,f%,t%,i%
110 t%=TIME
111 REPEAT
112 FOR i%=0 TO 28 STEP 4:net_io%!i%=0:NEXT
113 net_io%!(net_sock% DIV 32*4)=1<<(net_sock% MOD 32)
114 net_io%!32=0:net_io%!36=0:REM Don't let Socket_Select wait
115 SYS "XSocket_Select",net_sock%+1,0,net_io%,0,net_io%+32 TO r%;f%
116 IF f% AND 1 THEN =FNnet_errno(r%)
117 IF INKEY-97 THEN net_why$="Cancelled":=-1
118 IF r%=0 AND TIME-t%>500 THEN =60
119 UNTIL r%>0
120 net_io%!44=4:SYS "XSocket_Getsockopt",net_sock%,&FFFF,&1007,net_io%+40,net_io%+44 TO r%;f%:REM SO_ERROR
121 IF f% AND 1 THEN =FNnet_errno(r%)
122 =net_io%!40
123 :
124 DEF FNnet_errname(n%):REM What a connection error means; Socket_Getsockopt gives only the number
125 CASE n% OF
126 WHEN 60:="timed out"
127 WHEN 61:="refused"
128 WHEN 64:="host is down"
129 WHEN 65:="no route to host"
130 ENDCASE
131 ="error "+STR$n%
132 :
133 DEF PROCnet_ready:REM Connected: send each frame at once rather than waiting to fill a packet
134 !net_io%=1:SYS "XSocket_Ioctl",net_sock%,&8004667E,net_io%:REM FIONBIO
135 !net_io%=1:SYS "XSocket_Setsockopt",net_sock%,6,1,net_io%,4:REM TCP_NODELAY
136 ENDPROC
137 :
138 DEF PROCnet_hello:REM Swap greetings; the host sends its seed so both machines lay out the same game
139 LOCAL i%
140 PROCuser_netstatus("Connected - starting the game")
141 $net_io%="CD"+MID$("HJ",net_player%,1):net_io%?3=net_version%:net_io%!4=net_seed%
142 IF net_player%=1 THEN PROCnet_send(8) ELSE PROCnet_send(4)
143 IF net_player%=1 THEN PROCnet_recv(4) ELSE PROCnet_recv(8)
144 IF net_why$<>"" THEN ENDPROC
145 IF ?net_io%<>67 OR net_io%?1<>68 THEN net_why$="The other end isn't Cavern Duel":ENDPROC
146 IF net_io%?2=ASC(MID$("HJ",net_player%,1)) THEN net_why$="Both players are set to "+MID$("hostjoin",net_player%*4-3,4):ENDPROC
147 IF net_io%?3<>net_version% THEN net_why$="The other player has a different version of Cavern Duel":ENDPROC
148 IF net_player%=2 THEN net_seed%=net_io%!4
149 FOR i%=0 TO 7:net_qin%(i%)=0:net_qck%(i%)=0:NEXT
150 FOR i%=0 TO 2*net_delay%-1:net_io%?i%=0:NEXT
151 PROCnet_send(2*net_delay%):REM The frames before the first one, which nobody pressed anything in
152 net_frame%=0
153 ENDPROC
154 :
155 DEF PROCnet_send(n%):REM Send n% bytes from net_io%
156 LOCAL done%,r%,f%,t%
157 t%=TIME
158 WHILE done%<n% AND net_why$=""
159 SYS "XSocket_Send",net_sock%,net_io%+done%,n%-done%,0 TO r%;f%
160 IF f% AND 1 THEN
161 IF FNnet_errno(r%)<>35 THEN PROCnet_fail(r%,"Lost the connection")
162 ELSE
163 done%+=r%:t%=TIME
164 ENDIF
165 IF TIME-t%>1000 THEN net_why$="The other player stopped responding"
166 ENDWHILE
167 ENDPROC
168 :
169 DEF PROCnet_recv(n%):REM Wait for n% bytes into net_io%; after a second's wait, Tab gives up
170 LOCAL done%,r%,f%,t%
171 t%=TIME
172 WHILE done%<n% AND net_why$=""
173 SYS "XSocket_Recv",net_sock%,net_io%+done%,n%-done%,0 TO r%;f%
174 IF f% AND 1 THEN
175 IF FNnet_errno(r%)<>35 THEN PROCnet_fail(r%,"Lost the connection")
176 ELSE
177 IF r%=0 THEN net_why$="The other player left the game"
178 done%+=r%:t%=TIME
179 ENDIF
180 IF TIME-t%>1000 THEN net_why$="The other player stopped responding"
181 IF TIME-t%>100 AND INKEY-97 THEN net_why$="You left the game"
182 ENDWHILE
183 ENDPROC
184 :
185 DEF FNnet_socket:REM A new non-blocking TCP socket, or -1
186 LOCAL s%,f%
187 SYS "XSocket_Creat",2,1,0 TO s%;f%
188 IF f% AND 1 THEN PROCnet_fail(s%,"No network"):=-1
189 !net_io%=1:SYS "XSocket_Ioctl",s%,&8004667E,net_io%:REM FIONBIO
190 =s%
191 :
192 DEF PROCnet_address(port%):REM net_addr% becomes a 4.3BSD sockaddr_in for any address: family 2, then the port in network byte order
193 LOCAL i%
194 FOR i%=0 TO 15:net_addr%?i%=0:NEXT
195 ?net_addr%=2:net_addr%?2=port%>>>8:net_addr%?3=port% AND 255
196 ENDPROC
197 :
198 DEF FNnet_ip(ip$):REM Put the address in ip$ and net_port% into net_addr%; FALSE if ip$ isn't four numbers 0 to 255
199 LOCAL i%,d%,n%
200 PROCnet_address(net_port%)
201 FOR i%=0 TO 3
202 d%=INSTR(ip$+".",".")
203 n%=VAL(LEFT$(ip$,d%-1))
204 IF d%=1 OR n%>255 OR LEFT$(ip$,d%-1)<>STR$n% THEN =FALSE
205 net_addr%?(4+i%)=n%:ip$=MID$(ip$,d%+1)
206 NEXT
207 =ip$=""
208 :
209 DEF FNnet_var(name$):REM A system variable's value, or "" if it isn't set
210 LOCAL len%,f%
211 SYS "XOS_ReadVarVal",name$,net_io%,63,0,3 TO ,,len%;f%
212 IF f% AND 1 THEN =""
213 net_io%?len%=13
214 =$net_io%
215 :
216 DEF FNnet_errno(e%):REM The Unix error number in an Internet module error block
217 =!e% AND 255
218 :
219 DEF PROCnet_fail(e%,what$)
220 net_why$=what$+" ("+FNnet_text(e%)+")"
221 ENDPROC
222 :
223 DEF FNnet_text(e%):REM The message in an error block
224 LOCAL p%,s$
225 p%=e%+4:WHILE ?p%>=32:s$+=CHR$?p%:p%+=1:ENDWHILE
226 =s$
