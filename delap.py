#!/usr/bin/env python

from __future__ import print_function
import re
import time
from os import getenv, path
import sys
import json
import argparse



# https://docs.python.org/3/library/argparse.html
parser = argparse.ArgumentParser(prog = 'delap')
parser.add_argument('--inputfile', '-i', help = 'input file')
parser.add_argument('--outputfile', '-o', help = 'output file', type = str, action = 'store')
parser.add_argument('--action', '-a', help = 'action to take', type = str, action = 'store')
parser.add_argument('--debug', '-d', help = 'debug', action = 'store_const', const = True)
parser.add_argument('--jsondump', '-j', help = 'jsondump', action = 'store_const', const = True)
#
# TODO: load filter param via argument parse somehow

args = parser.parse_args()
if args.debug:
  print('running debug mode')
  print('input file: "{}"'.format(args.inputfile))
  print('output file: "{}"'.format(args.outputfile))

# if args.inputfile == None or args.outputfile == None:
if args.inputfile == None:
  parser.print_help()
  exit(1)

replacers = dict()
nls = '#'
real_nls = '\n'
nonls = '[^#]';
delimiter = '\|';
nodelimiter = '[^\|]';
grammar = '^(?:(' + nodelimiter + '+)' + nls + ')*(' + nonls + '+)' + ': *' + delimiter + nls + '((?:' + nonls + '+' + nls + '?)*)' + nls + nls + '(.*$)'

with open(args.inputfile, 'r') as file:
  data = file.read().replace('\r', '').replace(real_nls, nls)
if args.debug:
  print( data)
# TODO:  pass compile options for performance (optional)
prog = re.compile(grammar)
process = True
while process:
  result = prog.match(data)
  if result == None:
    process = False
  else:
    regular_config = result.group(1)
    data = result.group(4)
    property_name = result.group(2)
    property_values = result.group(3)
    if args.debug:
      print ('data={}'.format(data))
      print ('property_name={}'.format(property_name))
      print ('property_values={}'.format(property_values))


    # in the loop
    s = '\n'
    print('{}:{}'.format(property_name, ','.join(property_values.split(nls))))
    if regular_config != None:
      print( s.join(regular_config.split( nls)))


# after the loop
if re.match(r'\S',data):
  regular_config = data
  s = '\n'
  print( s.join(regular_config.split( nls)))

# export PATH=$PATH:/C/Program\ Files/LibreOffice/program:/c/Program\ Files/LibreOffice/program/python-core-3.7.7/bin
