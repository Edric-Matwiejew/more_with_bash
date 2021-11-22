# Doing More with the (B)ourne (A)gain (SH)ell:
### An intermediate Unix workshop.

### Contents
1.  The Structure of Unix Commands
2.  Defining a 'del' Command
3.  BASH Scripts and BASH Script Arguments
4.  BASH Functions
5.  BASH If Statements
6.  Regular Expressions
7.  BASH For Loops
8.  BASH Arrays
9.	Parsing Delimited Text Files with 'awk'
10.	Implementing 'del'
11.	Dotfiles
12. Aliases
13. Process Management

## 1. The Structure of Unix Commands

Unix commands follow a general strucutre:

	*verb* *adverb(s)* *object(s)*

For example in:

	ls -A ~/

The command 'ls' is the verb, '-A' is the adverb and '~/' (the user home directory) is the object. More generally, we refer to these components as:

[COMMAND] [OPTION(s)] [FILES(s)]

In general, a Unix-like command is a small program that reads an input string from the "standard input" (stdin) and returns an output string to the "standard output" (stdout). This predictable behaviour supports the piping of output from one command to another.

## 2. Defining a 'del' command.

The remove command 'rm FILE' deletes the target FILE permanently on Unix-like operating systems. Great if you know what you're doing - but what if you change your mind later?

In this workshop, we will develop a user-defined  'del' command that:

1. Sends target FILES(s) to a hidden 'recycle bin' directory '.recycle_bin':

	del [FILE(s)]

2. When passed the -l option lists the N most recently 'recycled' files:

	del -lN

3. When passed the -u option undoes the N most recent 'recycles':

	del -uN

Where '-l' and '-u' are options and 'N' is an integer value.

## 3. BASH Scripts and BASH Script Arguments

A BASH script is a text file containing lines of BASH compatible commands. These scripts start with a "shebang" and the path to the BASH interpreter:

	#!/bin/bash

When given the needed file permissions, we can execute the script like any other program using the './' command.

BASH scripts accept an arbitrary number of whitespace delimited input arguments. These are accessed from within the BASH script like so:

* $0, 	the script (or function) name.
* $N, 	the Nth arguments.
* $#, 	the number of variables passed to the script (or function).
* $* and $@,	all of the positional arguments.

Where '$*' expands to a single string and '$@' expands to a sequence of strings.

___

Example 1: Parsing arguments.

	#!/bin/bash
	echo "The name of the script
	echo "This is the first argument $1."
	echo "There are $# argument(s) in total:"
	echo "$@"

___

## 4. BASH Functions

BASH functions allow the same piece of BASH code to be reused multiple times in a terminal session or script. They are also able to accept arguments as described in Section 4. Multiple BASH functions can be defined in the same script.

### BASH function syntax:

	*function name* () {
	
		*...*
	
		}

The result of a BASH function should be output to stdin, which can be done using the 'echo' command.

Standard practice is to return the exit status of the function (or script) where,

	return 0

indicates success, and 'return N', where N=2,3..., indicates an error.
___

Example 2: A BASH function that returns the number of input arguments.

	#!/bin/bash
	del () {
		echo "There are $# arguments"
		return 0
	}

___

To use the 'del' command outside of the bash script itself, 'source' (read and execute) the script in the current shell environment:

	. ./recycle_bin/recyle_bin.sh

## 5. If Statements

If statements allow us to write BASH scripts with conditional behaviour.

### If statement syntax:

	 if [ *some test* ]
	
	 then
	
		*conditional block 1*
	
	 elif [ *some other test* ]
	
	 then
	
		*conditional block 2*
	
	 else
	
		*conditional block 3*
	
	 fi

The square brackets reference the command 'test'. Look up the man page of 'test' to see the logical operations it supports.

### A (selective) summary of logical expertions:

* ! EXPRESSION, 	logical negation of EXPRESSION.
* -n STRING,	true if the length of STRING is greater than zero.
* -z STRING, 	true if the length of STRING is zero.
* STRING1 = STRING2, 	true if STRING1 is equal to STRING2.
* -e FILE,	true if FILE exists.
* INTEGER1 -eq INTEGER2, 	true if INTEGER1 is equal to INTEGER2.
* -d FILE, 	true if FILE exists and it is a directory
* INTEGER1 -gt INTEGER2,	true if INTEGER1 is greater than INTEGER2.
* INTEGER1 -lt INTEGER2,	true if INTEGER1 is less than INTEGER2.
* INTEGER -eq INTEGER2,		true if INTEGER1 is equal to INTEGER2.

Note:  '=' is different from '-eq',  [ 001 = 1 ] will return false as it performs a string comparison, whereas [ 001 -eq 1 ] will return true as it performs a numerical comparison.

___

Example 3: Create the '.recycle_bin' directory if it doesn't exist.

	#!/bin/bash

	SCRIPT_DIR="$(cd $(dirname ${BASH_SOURCE[0]});pwd)"

	RECYCLE_BIN_DIR="$SCRIPT_DIR/.recycle_bin"

	if [ ! -e "$RECYCLE_BIN_DIR" ]
	then
		mkdir $RECYCLE_BIN_DIR
	echo "Created new recycle bin directory at :" $RECYCLE_BIN_DIR
	fi
___

## 6. Regular Expressions

Regular expressions are sequences of characters that specify a search pattern. For example, '*.dat' refers to any file ending in '.dat' and '?.dat' to any file ending with '.dat' with a prefix that is zero or more characters long.

Regular expressions use the special characters '.?*+{|()[\^$'.

### A (selective) summary of regular expression syntax:

* '.', 	matches any single character.
* '?', 	the preceding item is matched at most once.
* '*',	 the preceding item is matched zero or more times.
* '+',	 the preceding item is matched once or twice.
* '{n}'	 the preceding item is matched exactly n times.
* '|',	 joins regular expressions and returns whatever matches either of the two strings.
* [],	matches against a list or range of characters. e.g. '[^adf]' matches to anything that is not a d or f and '[0-9A-Za-z]' matches to all alphanumeric characters

A special character may be included as a normal character in a regular expression by preceding ('escaping') it with a '\' character.

Not all BASH commands support the full range of regular expressions. However, the '.', '?' and '*' operators are (almost) universally recognised for 'shell pattern matching'.

___

Example 4: Pattern matching to identify option flags (e.g. -l and -u).

	echo "$@" | grep -Eq '\-[a-zA-Z?][0-9*]'

___

## 7. BASH For Loops

A BASH for loop applies the same sequence of operations multiple times while iterating through a sequence.

### For loop syntax 1:

	 for OUTPUT in $(*command*)
	
	 do
	
			*commands*
	
	 done

e.g.:

	for i in $(step 0 10)
	do
		echo $i
	done

or

### For loop syntax 2:

	 for (( *initializer*; *condition*; *step* ))
	
	 do
	
		 *commands*
	
	 done

e.g.:

	for (( c=1; c*=5; c++ ))
	do
		echo $c
	done

___

Example 5: Classifying input arguments.

	for input in $@
	do
		if $(echo $input | grep -Eq '\-[a-zA-Z?][0-9*]')
		then
			echo "Input '$input' is an option."
		else
			echo "Input '$input' is (probably) a path."
		fi
	done

___

## 8. BASH Arrays

BASH arrays are a sequence of indexable strings separated.

For example,

	SEQ1=(2 4 6 8 10 12)
or

	SEQ1=( "First Element" "Second Element" "Third Element")

### A (selective) summary of BASH array syntax:

* arr=(), 	 empty array.
* arr=(1 2 3), 	 initialise array.
* ${arr[2]}, 	 retrieve the third element (Note: BASH arrays are 0-indexed).
* ${arr[@]}, 	retrieve all elements.
* ${!arr[@]}, 	 retrieve array indices.
* ${#arr[@]}, 	 calculate the array size.
* arr[0]=3, 	 overwrite the first element.
* arr+=(4), 	 append value(s).
* str=$(ls), 	 save ls output as a string.
* arr=($(ls)), 	 save ls output as an array of files.
* ${arr[@]:S:N}, 	 Retrieve N elements starting at index S.
___

Example 6: Classify arguments as options and files. Append the corresponding matched file to the FILES and OPTIONS arrays.

	FILES=()
	OPTIONs=()

	for input in $@
	do
		if $(echo $input | grep -Eq '\-[a-zA-Z?][0-9*]')
		then
			OPTIONs+=($input)
		else
			FILES+=($input)
		fi
	done
___

## 8. Case Statements

Case statements are another way of implementing logical branching. They are easier to write and read in many instances than a long sequence of 'if' and 'elif' statements.

### case syntax:

	 case *option* in
	
		*pattern 1*)
	
			*commands*
	
			;;
	
		*pattern 2*)
	
			*commands*
	
			;;
	
		*pattern n*)
	
			*commands*
	
			;;
	
	 esac
	
Note: Case statement patterns support shell pattern matching only ('*', '?' and '.').

___

Example 7: A case statement defining option-dependant behaviour in 'del.

	OPTION=${OPTIONS[0]}

	case $OPTION in

		-l*)
			echo "This option will list recylced files."
			return 0
			;;

		-u*)
			echo "This option will restore recycled files."
			return 0
			;;
		*)
			echo "ERROR: Option not recognised"
			return 1
			;;

	esac

___


## 9. Parsing Delimited Text Files with 'awk'.

Sections 3 to 9 defined the main control structures needed to implement 'del'. However, we need a means of tracking the 'recycled' files and their original location. To achieve this, we will use a log file in the '.recycle_bin' directory called '.recycle_log' that will store the file size, file path in '.recycle_bin' and the original file path in a single line for each recycled file.

___

Example 8: Recycle files and write to LOG_DIR.

	for FILE in ${FILES[@]}
	do
		if [ -e $FILE ]
		then
			NEW_PATH="$RECYCLE_BIN_DIR/$(date +%s)_$FILE"
			OLD_PATH="$(cd $(dirname ${BASH_SOURCE[0]});pwd)/$(basename "$FILE")"
			echo $(du "$OLD_PATH" | cut -f1)  "$NEW_PATH" "$OLD_PATH"  $LOG_DIR
			mv $FILE $NEW_PATH
		else
			echo "File '$FILE' does not exist!"
		fi
	done

___

We will use the 'awk' command to parse this log file. Awk is a scripting language used for manipulating data and generating reports. It supports variables, numeric functions, string functions and logical operators.

Awk allows a programmer to write tiny programs to search for a pattern on each line of a file and carry out an action when that pattern is detected.

Some 'awk' examples:

* awk '{print}' FILE, 	print the contents of FILE to stdout.
* awk '{print $1}' FILE, 	print the first column of FILE, by default white space is treated as the separator.
* awk '{print $1 ""$3}' FILE,	 print the first and the third column of FILE with a space in-between.
* awk '/example/ {print}' FILE,	 print all lines in FILE that contain the word example.
* awk '[0-9]/{print}' FILE,	 print all lines in FILE that contain numbers.
* awk ‘^[0-9]/{print}’ FILE,	 print all lines in FILE that start with a number
* awk -F',' '{sum+=$1} END{print sum;}' FILE,	sum the first column of FILE using ',' as the column delimiter.

___

Example 9: Sum the first column (file size) of the 'del' log file.

	tail -n4 ~/recycle_bin/.recycle_bin/.recycle_log | awk '{size+=$1} END{print size}'

___

## 10.  Implementing 'del'

___

Example 10: An implementation of 'del'.

	#!/bin/bash
	
	SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}");pwd)"
	RECYCLE_BIN_DIR="$SCRIPT_DIR/.recycle_bin"
	LOG_PATH="$RECYCLE_BIN_DIR/.recycle_log"
	
	if [ ! -e "$RECYCLE_BIN_DIR" ]
	then
		mkdir "$RECYCLE_BIN_DIR"
		echo "Created new recycle bin directory at :" "$RECYCLE_BIN_DIR"
	fi
	
	del () {
	
		# get the number after an option flag.
		get_number () {
		
			N_OPTION=$(echo $1| sed 's/[^0-9]//g')
			N_LOG=$(cat "$LOG_PATH" | wc -l)
		
			if [ $N_OPTION -gt $N_LOG ]
			then
				echo $N_LOG
			else
				echo $N_OPTION
			fi
			}
	
		if [ ! -e "$LOG_PATH" ]
		then
			touch "$LOG_PATH"
		fi
	
		if $( echo $@ | grep -q '\-h' ) || $( echo $@ | grep -q '\--help' )
		then
			echo "Usage: del [OPTION]... [FILE]..."
			echo "Move FILE(s) to a recycle bin folder."
			echo
			echo "  -lN,     list the last N recycled FILES."
			echo "  -uN,    Restore (undo) the last N recycled FILES."
			echo ""
			echo "If no OPTION is present, FILE(s) is moved to a 'recycle bin' directory:"
			echo "RECYCLE_BIN_DIR='$RECYCLE_BIN_DIR'"
			echo
			echo "(This function was sourced from '$RECYCLE_BIN_SOURCE'.)"
			return 0
		fi
	
		FILES=()
		OPTIONs=()
	
		for INPUT in $@
		do
			if echo "$INPUT" | grep -Eq '\-[a-zA-Z?][0-9*]'
			then
				OPTIONs+=("$INPUT")
			else
				FILES+=("$INPUT")
			fi
		done
	
		if [ ${#OPTIONs[@]} -gt 1 ]
		then
	
			echo "ERROR: More than than 1 OPTION."
			return 1
	
		elif [ ${#OPTIONs[@]} -eq 1 ]
		then
	
			OPTION=${OPTIONs[0]}
	
			case $OPTION in
	
				-l*)
					tail -n$(get_number "$OPTION") "$LOG_PATH"
					return 0
					;;
	
				-u*)
					N=$(get_number "$OPTION")
					mv_from=($(tail -n$N "$LOG_PATH" | awk '{print $2}'))
					mv_to=($(tail -n$N "$LOG_PATH" | awk '{print $3}'))
	
					for i in $(seq 0 $((N - 1)))
					do
						mv "${mv_from[$i]}" "${mv_to[$i]}"
	
						if [ ! -e "${mv_from[$i]}" ]
						then
							M=$(grep -n "${mv_from[$i]}" "$LOG_PATH" | cut -f1 -d:)
							sed -i -e "${M}d" "$LOG_PATH"
						fi
	
					done
					return 0
					;;
				*)
					echo "ERROR: Option not recognised"
					return 1
					;;
	
			esac
		fi
	
		#if no OPTION is passed, delete FILES
		for FILE in ${FILES[@]}
		do
			if [ -e "$FILE" ]
			then
				NEW_PATH="$RECYCLE_BIN_DIR/$(date +%s)_$FILE"
				OLD_PATH="$(cd $(dirname ${BASH_SOURCE[0]});pwd)/$(basename "$FILE")"
				echo $(du "$OLD_PATH" | cut -f1)  "$NEW_PATH" "$OLD_PATH" >> "$LOG_PATH"
				mv "$FILE" "$NEW_PATH"
			else
				echo "File '$FILE' does not exist!"
			fi
		done
	
		unset -f get_number
		return 0
	
	}
	
	echo "Defined the 'del' command, use 'del --help' for info on its usage."

## 11. Dotfiles

The behaviour of a Unix system is controlled through the setting of environment variables. For instance, we have already encountered the HOME variable, which contains the path to the current user's home directory:

	echo $HOME

Another important variable is the $PATH directory.

	echo $PATH

This contains a list of locations that Unix searches for executable files (starting from the first directory). For instance, if we use the command' 'whereis' to search for the location of the 'grep' program:

	whereis 'grep'

We see that it is located under '/bin'.

	echo $PATH | grep ':/bin:'

Which is one of the default locations included in PATH.

Let's bring our attention back to the HOME environment variable. This variable is important for several reasons:

1. On all Unix systems, the user will have read, write and execute permissions in the HOME directory.
2. HOME is (typically) the location of user-specific programs.
3. HOME is (typically) the location for user-specific configuration files.

Configuration files are hidden files in the Unix file system. Hidden files in Unix start with a '.'. For this reason, they are often referred to as 'dotfiles'.

From with the user's home directory, the command:

	ls -a

typically displays several dotfiles.

The most notable of these is perhaps '.bashrc'. This dotfile is 'sourced' whenever a new Bash session is launched (e.g. when the terminal window is opened).

To have 'del' avaliable whenever we start a terminal session we can append,

	. ~/recycle_bin/recycle_bin.sh

to '.bashrc'.

## 12. Aliases

Aliases are user-defined commands built out of a sequence of terminal commands; with them, we can define 'shortcuts' to longer commands.

### Alias syntax:

	 alias *shortcut name*=*command*

e.g.:

	alias rm='rm -i'

will prompt the user for confirmation before deleting the file.

Aliases are a great way of making your system more comfortable to use. Modifications to .bashrc are the simplest way to change the behaviour of your Unix shell.

Be sure to do so with care, though. Comment on any changes, and add new commands to the bottom of the file wherever possible. Even better is to store your custom environment variables in a file that is 'sourced' by .bashrc.

## 13. Process Management

Unix-like operating systems are multitasking - something that we experience if using the desktop environment of macOS or a Linux distribution.

Consider the following command,

	watch -n1 'cat /proc/meminfo | grep MemFree'

which shows the current free RAM, updated every 1 second.

A program that we can see in the terminal is running in the 'foreground'; to abort a program running in the foreground, we can use 'Ctrl+c'.

To suspend the task, we can instead use 'ctrl+Z', at which point we see output that gives the process number (JOB SPEC) and the status of the process.

Let's run another version of the command that instead looks at the amount of cached memory:

	watch -n1 'cat /proc/meminfo | grep -w Cached'

which we will also suspend.

To start one of these processes back up, we use the 'foreground' command,

	fg 1

or the background command

	bg 1

Which will start the process running in the background. bg ['job spec'] is equivalent to starting a command with '&'

watch -t -n1 "date +'%H:%M:%S' | tee -a loged" &*/dev/null &

To see a list of foreground and background processes with their corresponding' job spec':

jobs

To end a non-responsive job, we can retrieve the process IDs,

jobs -p

and issue the 'kill' command. For example, given a PID of '1484':

kill -KILL 1484
