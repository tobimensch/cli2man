README CLI2MAN
--------------

Cli2Man parses a program's --help option output and tries to put together a half-decent manpage. The author of this script was a user of help2man, which is more than a decade old and can still be recommended. But when it didn't work like the author wished and fixing the bugs in the PERL source code seemed impossible, because it was poorly documented code with mindblowing use of cryptic regex, the idea was to write a simple parser like docopt is parsing --help messages to generate CLI.

The author simply took the docopt source and started hacking and after a couple of hours everything started to work amazingly good. This speed of development was possible, because the docopt authors already had done the hard work of writing the parser.

Unfortunately the docopt parser isn't very permissive, but rather strict. For example the ArgumentParser of Python that the author was using produces slightly _malformated_ --help pages and therefore Cli2Man has to introduce a lot of hacks to make foreign --help messages somehow work with the docopt parser.

As output format the choice was the mdoc macros for manpages, because the author had seen a nice presentation on their beauty just a couple of hours earlier. MDoc is more of a semantic format that's designed for manpages, while the man format that's the default on Linux distributions is more like a typesetting format. But this shouldn't be a problem, since usually all Linux distributions (groff is doing this work on Linux) should be able to handle manpages with mdoc macros fine. And on BSDs mdoc/mandoc is now the default. And should you still have a problem with the mdoc format, well, there's a converter from mdoc to man in mandoc (and probably also in groff).

INSTALLING
----------

- Get Cli2Man
- Extract
- run:

```
    python setup.py install
```

HOW TO USE IT
-------------

Get mdoc output of any program with --help:

    cli2man program

Write manpage to file:

    cli2man program -o manpage

View temporary manpage:

    cli2man program -m

View manpage just written to file:

    cli2man program -m -o manpage

Currently cli2man doesn't try to find more than one options section on it's own (it's searching for "options" and
"optional arguments"), so if you have a differently named option section or you have multiple option sections
you want to do something like this:

    cli2man program --option-section "Advanced Options" --option-section "Next Level Options"

If you have sections that are more like plain text and more about explaining things and info and that aren't
listing options, then you want to tell cli2man differently about them:

    cli2man program --option-section "Advanced Options" --option-section "Next Level Options" --info-section "examples" --info-section "environment"

All these sections have in common that cli2man parses for something that looks roughly like this:

    MySection:
      Section text

DEVELOPMENT / BUGS:
-------------------

Cli2Man is in very early development stages, and is basically docopt + a lot of dirty hacking. But you can generate manpages, if the input is compatible with docopt or if you're lucky enough. The chances aren't bad. But there are glitches. So don't get your hopes too high. The good news is that Cli2Man is written in python and improving it should be possible rather fast. As said before, it was written in a couple of hours. 

What's not working right now is ordering sections. The --include option is not final, right now you can import MDoc formated files, but maybe we should allow Markdown or something like that.

The parser at the moment doesn't read the description from --help. Will be fixed soon, though.

Many missing features, like reading Copyright info and so on, but that's really high priority stuff.

You're welcome to contribute.

CLI:
----

Realized with the great Docopt:

```
usage: cli2man ( <command> | -i FILE | --stdin ) [options] [--option-section NAME ...] [--info-section NAME ...]
       cli2man --version

Use the help message of a command to create a manpage.

Options:
  -h, --help                   show this help message and exit
  -o FILE, --output FILE       write to file instead of stdout     
  -i FILE, --input FILE        read CLI-help input from file    
  --stdin                      read CLI-help input from stdin      
  --info-section NAME ...      parse non-option sections
  --option-section NAME ...    parse option sections other than "Options:"
  -m, --open-in-man            open the output in man   
  -s NUM, --section NUM        section number for manual page
  --volume VOLUME              volume title for manual page
  -I FILE, --include FILE      include material from FILE
  -v, --version                display version information
```

LICENSE:
--------

MIT:

```
Copyright (c) 2012 Vladimir Keleshev, <vladimir@keleshev.com>
Copyright (c) 2014 Tobias Glaesser

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to
whom the Software is furnished to do so, subject to the
following conditions:

The above copyright notice and this permission notice shall
be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

