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

Install the game on both machines. They can be on the same network, or
anywhere on the internet. Each machine plays one player, so each player
needs their own machine and keyboard.

1. On one machine, choose the settings and cave, then click Host.
   Press H to play on your home network: the machine's address appears
   along the bottom of the menu. Or press I to play over the internet:
   a four-letter room code appears instead.
2. On the other machine, click Join, type that address or room code
   and press Return.

The game starts on both machines with the host's settings and cave, and
a message on each says which player it plays. Tab cancels while
connecting, and ends the game on both machines.

If the game says the Internet module isn't loaded, turn on TCP/IP in
Configure's Network settings and restart the machine. On a home network
the game connects on TCP port 30123, so a firewall on the host needs to
allow it. Over the internet, both machines connect out to the Cavern
Duel relay, so there's nothing to set up on your router. A room closes
if nobody joins it within 15 minutes.
