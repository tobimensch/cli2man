#/bin/sh
./cli2man ./cli2man -o auto --gzip
man2html -r ./cli2man.1.gz | sed 's/<I>\,\([^<]*\)/<I>\1replaceme/' | sed 's/\/replaceme//' > cli2man_manpage.html
