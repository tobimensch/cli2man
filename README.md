README CLI2MAN
--------------

Cli2Man parses a program's --help option output and tries to put together a half-decent manpage. The author of this script was a user of help2man, which is more than a decade old and can still be recommended. But when it didn't work like the author wished and fixing the bugs in the PERL source code seemed impossible, because it was poorly documented code with mindblowing use of cryptic regex, the idea was to write a simple parser like docopt is parsing --help messages to generate CLI.

The author simply took the docopt source and started hacking and after a couple of hours everything started to work amazingly good. This speed of development was possible, because the docopt authors already had done the hard work of writing the parser.

Unfortunately the docopt parser isn't very permissive, but rather strict. For example the ArgumentParser of Python that the author was using produces slightly _malformated_ --help pages and therefore Cli2Man has to introduce a lot of hacks to make foreign --help messages somehow work with the docopt parser.

As output format the choice was the mdoc macros for manpages, because the author had seen a nice presentation on their beauty just a couple of hours earlier. MDoc is more of a semantic format that's designed for manpages, while the man format that's the default on Linux distributions is more like a typesetting format. But this shouldn't be a problem, since usually all Linux distributions (groff is doing this work on Linux) should be able to handle manpages with mdoc macros fine. And on BSDs mdoc/mandoc is now the default. And should you still have a problem with the mdoc format, well, there's a superb converter from mdoc to man in [mandoc](http://mdocml.bsd.lv/).

INSTALLING
----------

Install requirements:

- python
- [docopt](https://github.com/docopt/docopt)

Install Cli2Man:

```
    pip install cli2man
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

    cli2man program -mo manpage

Cli2Man now includes an experimental markdown formatter:

    cli2man program -Tmarkdown -o manpage.md

### Handling sections

Currently cli2man doesn't try to find more than one options section on its own (it's searching for "options" and
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

``` shell
cli2man --print-order --set-order "NAME,USAGE,OPTIONS,DESCRIPTION,EXAMPLES,COPYRIGHT"
```

Everything that's not defined in the order will simply appended to the end of the manpage.

Finally here's a real example where cli2man generates its own manpage and the OPTIONS and DESCRIPTION sections are swapped:

``` shell
cli2man cli2man -m --set-order "NAME,SYNOPSIS,OPTIONS,DESCRIPTION"
```

> NOTE: There's a standard order of sections that all manpages should stick to. Cli2Man tries to keep a standardized list of sections.
When you change the standard order or when you use custom non-standard sections inbetween standard sections, make sure that you have good reasons to do so.

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
cli2man cli2man -mzo auto -I some_additional_stuff --info-section examples --option-section "Even more options" --create-script generate_manpage.sh
```  

INCLUDING EXTRA MATERIAL IN YOUR MANPAGE / MINI MDOC TUTORIAL
-------------------------------------------------------------

Writing manpages with MDoc by hand isn't really hard, that's why Cli2Man outputs MDoc.

Let's say you want to include a section AUTHORS in your manpage.

Create a new file myprog_more_info.mdoc like this:

```
.Sh AUTHORS
Mikee Mike <mike@internet.net>
Anika An <ani@www.org>
.Pp
Special thanks go to contributors not mentioned here!
.Pp
See the full list of contributors at:
http://theproject.org/THANKS
...
```

As you see the line

     .Sh AUTHORS

Creates a new section "AUTHORS" in the manpage.
Lines starting with a dot and two letters (like .Sh/.Pp) are macros and they sometimes take
parameters and sometimes not.

While .Sh SECTION starts a new section, the .Pp macro simply states that a new paragraph is beginning here.

If you want a list of items with nice identation, something like this will work:

```
.Sh SECTION
.Bl -tag -width Ds
.It the first item
Text belonging to the first item
.It the second item
Text belonging to the second
.El
```

To include your new section in the manpage run cli2man like this:

    cli2man myprog -mzo auto -I myprog_more_info.mdoc

If you're not happy with the order the new section appears in, try this:

``` shell
cli2man myprog -mzo auto -I myprog_more_info.mdoc --set-order "NAME,AUTHORS,SYNOPSIS,DESCRIPTION"
```

The sections in your include file are parsed and ordered according to the section order settings. When a section
doesn't exist in the section order it will not be included in the manpage, so **if you're using any non-standard
section names you'll have to modify the section order**.
This is a feature and not a bug, because some people may not want to include all the sections from the include
file in the manpage.

> NOTE: There's a standard order of sections that all manpages should stick to. Cli2Man tries to keep a standardized list of sections.
When you change the standard order or when you use custom non-standard sections inbetween standard sections, make sure that you have good reasons to do so.

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

CONVERTING CLI2MAN CREATED MANPAGES TO HTML AND OTHER FORMATS
-------------------------------------------------------------

There a couple of different tools for converting manpages to HTML.

- there are multiple tools called man2html
 - the author of cli2man used to use one of them, which was good, but not great
- there's groff -Thtml
 - the output **looks good**, you can use stylesheets to have it look like you want
 - there were problems using the generated html on the github project page, it just didn't look right
- and there's mandoc -Thtml
 - it produces very clean html and you can also use stylesheets to modify the look
 - it worked like a charm on the github project page. So far the only tool where it wasn't neccessary to make any manual modifications.
 - **that's why mandoc is strongly recommended**

On top of that:

 - mandoc -Tpdf produces very good looking pdf files.
 - mandoc -Tman converts your cli2man created mdoc macro manpages into excellent man macro manpages
  - the conversion is so good, that there's no way that anybody can tell that there was some converting under the hood.
  - therefore: If you should run into a system that can only use man macro manpages (i.e. Solaris), you can still use cli2man.

There's just a tiny little problem for Linux users:
***mandoc is a BSD thing and many Linux distros unfortunately don't have it in the repository***

The good news is:
**compiling it isn't difficult at all, if you're able to read a README**

Learn about mandoc:

- newest release tarball: http://mdocml.bsd.lv/snapshots/mdocml.tar.gz
- homepage: http://mdocml.bsd.lv/
- user manual: http://mdocml.bsd.lv/man/mandoc.1.html
- ports of mandoc for different OSs: http://mdocml.bsd.lv/ports.html
- [mandoc on Open Suse buildsystem](https://build.opensuse.org/package/show/home:jesseadams/mdocml) (packages for Ubuntu, Fedora and many more):
 - there seem to be only source packages though
 - you could take a look at .spec files and debian.rules etc. there to create real packages for distributions

RPM/DEB/TGZ x86_64 packages created with checkinstall and alien:
- as a temporary solution the author of cli2man created mandoc packages
- mandoc is statically linked in all of them
- installs to /usr/local
- should work with most x86_64 Linux installations, in theory...
 - [RPM](https://github.com/tobimensch/cli2man/blob/master/mandoc_packages/mdocml-1.13.1-1.x86_64.rpm)
  - only tested on Fedora20/21
 - [DEB](https://github.com/tobimensch/cli2man/blob/master/mandoc_packages/mdocml_1.13.1-1_amd64.deb)
  - untested
 - [TGZ](https://github.com/tobimensch/cli2man/blob/master/mandoc_packages/mdocml-1.13.1.x86_64.tgz)
  - a slackware package, but can also be simply extracted
- packages will probably not be kept uptodate. Created on December 2, 2014.

cli2man now also has an experimental markdown formatter, that you can use like this:

    cli2man prog -Tmarkdown -o markdown.md

Markdown doesn't really seem to be the best choice for a manpage, but it's very common on the internet and there are lots of
converters for it, so you could also try to convert from markdown to HTML or even Latex and many more formats.

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
  -m, --open-in-man            open the output in man
  -z, --gzip                   compress file output
  -o FILE, --output FILE       write to file instead of stdout.
                               when FILE is set to "auto" the    
                               format is: command.section(.gz)
  -i FILE, --input FILE        read CLI-help input from file
  --stdin                      read CLI-help input from stdin     
  --info-section NAME ...      parse non-option sections
  --option-section NAME ...    parse option sections other than "Options:"
  -I FILE, --include FILE      include material from FILE
  --print-order                prints section order
                               default order if non is set by user
  --set-order SECTIONS         comma separated list of sections
  -s NUM, --section NUM        section number for manual page (default: 1)
  --arch ARCH                  set architecture for manual page
  --os OS                      operating system name
  --see-also PAGES             comma separated list of manpages
                               i.e. --see-also mandoc,mdoc7
                               without number at the end, section 1 is assumed
  -T FORMAT                    set output format (default: mdoc)
                               -Tmarkdown EXPERIMENTAL
                               -Tmdoc
  --create-script FILE         creates manpage generation shell script
                               based on current CLI-settings
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

