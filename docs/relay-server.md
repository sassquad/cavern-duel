# Setting up the internet relay

How to run `tools/relay.py` on a Linux server, so that games chosen with **Host**,
then **I**, find it at `relay.sassquad.net`. The relay is one Python file
with no other software to install. It runs as a background service that starts
when the server does.

These steps are for Ubuntu or Debian, the usual choices for a small VPS. Other
Linux versions differ only in the firewall commands (step 4).

## What you need

- The VPS's **IPv4 address**, and its IPv6 address if it has one. Both are on
  the server's page in the IONOS control panel.
- An **SSH login** to the VPS, as `root` or as a user who can use `sudo`.
- A Mac terminal in this repository, for copying the files across.

Don't put the server's password in a chat or a file. Type it only when SSH
asks for it. Better still, set up an SSH key (step 7).

## 1. Point the name at the VPS

In the IONOS control panel, go to **Domains & SSL**, choose **sassquad.net**,
then **DNS**, and add a record:

| Type | Host name | Points to | TTL |
|---|---|---|---|
| A | `relay` | the VPS's IPv4 address | 1 hour |

If the VPS has an IPv6 address, add an **AAAA** record for `relay` pointing to
it as well.

If IONOS asks you to create the subdomain first, do so under **Subdomains**,
without connecting it to your web hosting. If it then adds records of its own
for `relay`, edit its **A** record to the VPS's IPv4 address. Then delete its
**AAAA** record, or point it at the VPS's IPv6 address. Mail records (MX, and
TXT starting `v=spf1`) can stay: they don't affect the relay.

Leave `cavernduel.sassquad.net` alone: it serves the Cavern Duel web page.

To check from the Mac, once the change has spread (up to an hour):

```bash
dig +short relay.sassquad.net
```

This should print only the VPS's address.

## 2. Check the server

Log in from the Mac, using the VPS's address until the name works:

```bash
ssh root@VPS-ADDRESS
```

Then, on the server, check the Linux version and Python 3.8 or later:

```bash
cat /etc/os-release
```

```bash
python3 --version
```

If `python3` isn't found, install it:

```bash
sudo apt update && sudo apt install -y python3
```

Log out with `exit`.

## 3. Copy the relay across

From the Mac, in this repository:

```bash
scp tools/relay.py tools/cavernduel-relay.service root@VPS-ADDRESS:/tmp/
```

Then log in again and install them:

```bash
sudo install -d /opt/cavernduel
```

```bash
sudo install -m 644 /tmp/relay.py /opt/cavernduel/relay.py
```

```bash
sudo install -m 644 /tmp/cavernduel-relay.service /etc/systemd/system/cavernduel-relay.service
```

```bash
sudo systemctl daemon-reload && sudo systemctl enable --now cavernduel-relay
```

Check that it's running:

```bash
systemctl status cavernduel-relay
```

It should say `active (running)`, and its last line should be
`relay waiting on port 30123`. Press Q to leave.

The service runs the relay as a user made up just for it, with no login and no
right to change any files. It restarts the relay if it ever stops.

## 4. Open port 30123

Players reach the relay on TCP port 30123, so two firewalls must let it in.

**The IONOS firewall.** In the control panel, go to **Network**, then
**Firewall Policies**, and choose the policy the VPS uses. Add a rule:

| Protocol | Port | Allowed from |
|---|---|---|
| TCP | 30123 | all |

Leave the existing SSH rule (port 22) as it is.

**The server's own firewall, if it has one.** On the server:

```bash
sudo ufw status
```

If it says `Status: active`:

```bash
sudo ufw allow 30123/tcp
```

If it says `inactive`, or `ufw` isn't installed, there's nothing to do. On
Linux versions that use `firewalld` instead:

```bash
sudo firewall-cmd --permanent --add-port=30123/tcp && sudo firewall-cmd --reload
```

## 5. Try it from the Mac

In one Mac terminal, in this repository, start a pretend host:

```bash
python3 tools/netpeer.py host relay.sassquad.net --room
```

It prints a room code. In a second terminal, join with that code:

```bash
python3 tools/netpeer.py join relay.sassquad.net --room ABCD
```

Both should print frames until you press Ctrl-C. On the server,
`systemctl status cavernduel-relay` now shows `game 1 started`.

Then try the game itself. In RPCEmu, make sure `CavernDuel$Server` isn't set
(restart the machine, or press F12 and type `*Unset CavernDuel$Server`). Click
**Host**, then press **I**, and a room code should appear.

## 6. Looking after it

See what it has been doing (it logs games starting, never addresses):

```bash
journalctl -u cavernduel-relay --since today
```

Restart it, for example after copying a new `relay.py` across as in step 3.
Games in progress end:

```bash
sudo systemctl restart cavernduel-relay
```

Stop it, and stop it starting with the server:

```bash
sudo systemctl disable --now cavernduel-relay
```

The limits on connections, rooms and data are at the top of `relay.py`, and
[network-play.md](network-play.md) explains them.

## 7. Keeping the server safe

- **Security updates.** Install them automatically:

  ```bash
  sudo apt install -y unattended-upgrades && sudo dpkg-reconfigure -f noninteractive unattended-upgrades
  ```

- **SSH keys instead of a password.** If you don't already have a key on the
  Mac, make one with `ssh-keygen -t ed25519`, then copy it to the server with
  `ssh-copy-id root@VPS-ADDRESS`. Once logging in no longer asks for the
  password, password logins can be switched off on the server.
