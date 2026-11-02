Cavern Duel
===========

A two-player maze game for RISC OS, by Graeme and Stephen Scott.
Website: https://www.sassquad.net/cavernduel

!CavenDuel is the game and !CavernEd is its cave editor. Double-click
!CavenDuel, then click its icon on the icon bar. Click !Help for the
full instructions.


Installing
----------

Unpack this zip file on RISC OS, using !SparkFS or !Infozip, and copy
!CavenDuel and !CavernEd to your hard disc. Unpacking it on another
computer first would lose the RISC OS file types.


Playing on two machines
-----------------------

Install the game on both machines, and connect them to the same
network. Each machine plays one player, so each player needs their own
machine and keyboard.

1. On one machine, choose the settings and cave, then click Host. Its
   address appears along the bottom of the menu.
2. On the other machine, click Join, type that address and press
   Return.

The game starts on both machines with the host's settings and cave, and
a message on each says which player it plays. Tab cancels while
connecting, and ends the game on both machines.

If the game says the Internet module isn't loaded, turn on TCP/IP in
Configure's Network settings and restart the machine. The game connects
on TCP port 30123, so a firewall on the host needs to allow it.
