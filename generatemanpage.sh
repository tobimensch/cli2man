#/bin/sh
./cli2man ./cli2man -o auto --gzip
cat cli2man.1.gz | gunzip | mandoc -Thtml > cli2man_manpage.html

