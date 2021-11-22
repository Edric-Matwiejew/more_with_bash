# Doing More with BASH

This workshop builds on from Pawsey's "Introduction to Unix Workshop".

## 1. Unix Commands

Unix commands follow a general form:

	verb adverb(s) object(s)

For example in:

	ls -A ~/

The command 'ls' is the verb, '-A' is the adverb and '~/' (the user home directory) is the object. More generally we refer to these components as:

	[COMMAND] [OPTION(s)] [FILES(s)]

In general, a Unix command reads an input string from the "standard input" (stdin) and returns an output string to the "standard output" (stdout). This predictable behaviour supports the piping of output from one command to another.

## 2. Our Goal for the Workshop: Define the 'del' [COMMAND]

On Unix-like operating systems the remove command 'rm [FILE(s)]' deletes the target files permemently. This is great if you know what you're doing - but what if you change your mind later?

In this workshop we will define a 'del' command that:

1. Sends target [FILE(s)] to a hidden 'recycle bin' directory '.recycle_bin':

	del [FILE(s)]

2. When passed the -l [OPTION] lists the N most recently 'recycled' files:

	del -lN

3. When passed the -u [OPTION] undos the N most recent'recycles':

	del -uN 

Where '-l' and '-u' are exclusive [OPTIONS] and 'N' is an integer value.


## 3. BASH Scripts and BASH Script Arguments.

A BASH script is a text file that contains lines of BASH shell script. These scripts start with a "shebang" and the path to the BASH interpreter:

	#!/bin/bash

This means that, when given the needed file premissions, we are able to execute the script like any other program by using the './' command.

BASH scripts accept an arbitrary number of white-space delimited input arguments. These are accessed from within the BASH script like so:

* $0 function name
* $1, $2, $n, parameters 
* $# number of variables passed to the function 
* $* and $@ contain all of the positional arguments 

Where '$*' expands to a single string and '$@' expands to a sequence of strings. 

___

Example: ~/recycle_bin/recyle_bin.sh

	#!/bin/bash
	echo "This is the first argument $1."
	echo "There are $# argument(s) in total:"
	echo "$@"
	
___


	




