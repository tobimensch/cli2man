README CLI2MAN
--------------

Cli2Man parses a program's --help option output and tries to put together a half-decent manpage. The author of this script was a user of help2man, which is more than a decade old and can still be recommended. But when it didn't work like the author wished and fixing the bugs in the PERL source code seemed impossible, because it was poorly documented code with mindblowing use of cryptic regex, the idea was to write a simple parser like docopt is parsing --help messages to generate CLI.

The author simply took the docopt source and started hacking and after a couple of hours everything started to work amazingly good. This speed of development was possible, because the docopt authors already had done the hard work of writing the parser.

Unfortunately the docopt parser isn't very permissive, but rather strict. For example the ArgumentParser of Python that the author was using produces slightly _malformated_ --help pages and therefore Cli2Man has to introduce a lot of hacks to make foreign --help messages somehow work with the docopt parser.

As output format the choice was the mdoc macros for manpages, because the author had seen a nice presentation on their beauty just a couple of hours earlier. MDoc is more of a semantic format that's designed for manpages, while the man format that's the default on Linux distributions is more like a typesetting format. But this shouldn't be a problem, since usually all Linux distributions (groff is doing this work on Linux) should be able to handle manpages with mdoc macros fine. And on BSDs mdoc/mandoc is now the default. And should you still have a problem with the mdoc format, well, there's a converter from mdoc to man in mandoc (and probably also in groff).

INSTALLING
----------

Install requirements:
- python
- docopt module
 - https://github.com/docopt/docopt
 - drop docopt.py into cli2man directory
 - or simply run: pip install docopt==0.6.1
 - docopt is in the Fedora repository,
   so it's probably in other distributions's
   repositories, too

Install Cli2Man:
- [Get Cli2Man](https://github.com/tobimensch/cli2man/archive/master.zip)
- Extract
- run:

```
    python setup.py install
```

HOW TO USE IT
-------------

### The basics

Get mdoc output of any program with --help:

    cli2man program

Write manpage to file:

    cli2man program -o manpage

View temporary manpage:

    cli2man program -m

View manpage just written to file:

    cli2man program -m -o manpage

### Handling sections

Currently cli2man doesn't try to find more than one options section on it's own (it's searching for "options" and
"optional arguments"), so if you have a differently named option section or you have multiple option sections
you want to do something like this:

``` shell
cli2man program --option-section "Advanced Options" --option-section "Next Level Options"
```

If you have sections that are more like plain text and more about explaining things and info and that aren't
listing options, then you want to tell cli2man differently about them:

``` shell
cli2man program --info-section "examples" --info-section "environment" --option-section "Advanced Options" --option-section "Next Level Options"
```

All these sections have in common that cli2man parses for something that looks roughly like this:

    MySection:
      Section text

cli2man has a internal default section order of common section names. To view the defaults run this:

    cli2man --print-order

To change the order you use --set-order followed by a comma separated list of section names. Combine it with
--print-order to test the result:

```
cli2man --print-order --set-order "NAME,USAGE,OPTIONS,DESCRIPTION,EXAMPLES,COPYRIGHT"
```

Everything that's not defined in the order will simply appended to the end of the manpage.

Finally here's a real example where cli2man generates its own manpage and the OPTIONS and DESCRIPTION sections are swapped:

```
cli2man cli2man -m --set-order "NAME,SYNOPSIS,OPTIONS,DESCRIPTION"
```

### Automatic filenames and gunzip compression

Usually manpages have the format progname.section and often they're compressed with gzip.
If you want that file format, run cli2man as follows:

    cli2man cli2man -o auto --gzip 

You get a file cli2man.1.gz in the current directory.

Just adding .gz to the output file name will result in a gzip compressed file, too.

    cli2man cli2man -o my_awesome_manpage.gz

### Saving your current config

When you have found the optimal options in the CLI, you may want to create
a script so that you can regenerate your manpage quickly and improve your cli2man configuration
later.

There's a command line option for that:

``` shell
#The --create-script option saves all the other command line options in an executable script
cli2man cli2man -o auto --gzip -I some_additional_stuff --info-section examples --option-section "Even more options" --create-script generate_manpage.sh
```  

INCLUDING EXTRA MATERIAL IN YOUR MANPAGE / MINI MDOC TUTORIAL
-------------------------------------------------------------

Writing manpages with MDoc by hand isn't really hard, that's why Cli2Man outputs MDoc.

Let's say you want to include a section USAGE in your manpage, where you exactly describe
what you can do with a program and how everything works.

Create a new file myprog_section_usage.mdoc like this:

```
.Sh USAGE
.Pp
Writing manpages with MDoc by hand isn't really hard, that's why Cli2Man outputs MDoc.
.Pp
Let's say you want to include a section USAGE in your manpage, where you exactly describe
what you can do with a program and how everything works.
...
```

As you see the line

     .Sh USAGE

Creates a new section "USAGE" in the manpage.
Lines starting with a dot and two letters (like .Sh/.Pp) are macros and they sometimes take
parameters and sometimes not.

While .Sh SECTION starts a new section, the .Pp macro simply states that a new paragraph is beginning here.

If you want a list of items with nice identation, something like this will work:

```
.Sh USAGE
.Pp
.Bl -tag -width Ds
.It the first item

Text belonging to the first item
.It the second item

Text belonging to the second
.El

```

To include your new section in the manpage run cli2man like this:

    cli2man myprog -o auto --gzip -m -I myprog_section_usage.mdoc

If you're not happy with the order the new section appears in, try this:

``` shell
cli2man myprog -o auto --gzip -m -I myprog_section_usage.mdoc --set-order "NAME,USAGE,SYNOPSIS,DESCRIPTION"
```

The sections in your include file are parsed and ordered according to the section order settings. When a section
doesn't exist in the section order it will not be included in the manpage, so **if you're using any non-standard
section names you'll have to modify the section order**.

For more information on mdoc, visit:
- http://mdocml.bsd.lv/man/mdoc.7.html
- http://www.openbsd.org/papers/eurobsdcon2014-mandoc-slides.pdf

There are also tools to convert other formats to mdoc:
- Convert Plain Old Documentation / POD format to mdoc: http://mdocml.bsd.lv/pod2mdoc/
 - it's a simple markup language you can pick up as fast as markdown
 - convert Markdown to POD and then convert POD to mdoc: http://search.cpan.org/~keedi/Markdown-Pod-0.003/bin/markdown2pod
- Convert Docbook to mdoc: http://mdocml.bsd.lv/docbook2mdoc/

The cli2man author started a new project to convert markdown directly to mdoc:
- https://github.com/tobimensch/markdown2mdoc
 - it's working but there are some markdown features that aren't supported (yet)
  - tables aren't supported yet
   (given mdoc's limitations all markdown features will never be supported)

DEVELOPMENT / BUGS:
-------------------

Cli2Man is in very early development stages, and is basically docopt + a lot of dirty hacking. But you can generate manpages, if the input is compatible with docopt or if you're lucky enough. The chances aren't bad. But there are glitches. So don't get your hopes too high. The good news is that Cli2Man is written in python and improving it should be possible rather fast. As said before, it was written in a couple of hours. 

The --include option is not final, right now you can import MDoc formated files, but maybe we should allow Markdown or something like that.

Many missing features, like reading Copyright info and so on, but that's really high priority stuff.

You're welcome to contribute.

CLI:
----

Realized with the great Docopt:

```
usage: cli2man ( <command> | -i FILE | --stdin ) [options]
               [--option-section NAME ...] [--info-section NAME ...]
               [--set-order SECTIONS] [--gzip]
       cli2man --print-order [--set-order SECTIONS]
       cli2man --version

Use the help message of a command to create a manpage.

Options:
  -h, --help                   show this help message and exit
  -o FILE, --output FILE       write to file instead of stdout.
                               when FILE is set to "auto" the    
                               format is: command.section(.gz)
  -i FILE, --input FILE        read CLI-help input from file    
  --stdin                      read CLI-help input from stdin      
  --info-section NAME ...      parse non-option sections
  --option-section NAME ...    parse option sections other than "Options:"
  -m, --open-in-man            open the output in man   
  -s NUM, --section NUM        section number for manual page (default: 1)
  --volume VOLUME              volume title for manual page
  --os OS                      operating system name (default: UNIX)
  -I FILE, --include FILE      include material from FILE
  --gzip                       compress file output
  --set-order SECTIONS         comma separated list of sections
  --create-script FILE         creates manpage generation shell script
                               based on current CLI-settings
  --print-order                prints section order
                               default order if non is set by user
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

