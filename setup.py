#!/usr/bin/env python

import sys, os, shutil
from distutils.core import setup

setup(name='cli2man',
      version='0.2.1',
      description='Converts the help message of a program into a manpage',
      install_requires=['docopt'],
      author='Tobias Glaesser',
      url='https://github.com/tobimensch/cli2man',
      scripts=['cli2man'],
      data_files=[('/usr/share/man/man1/', ['cli2man.1.gz'])]
     )


