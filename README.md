# Doing more with the (B)ourne (A)gain (SH)ell.
### (An intermediate Unix workshop.)

### Contents
1.  Unix-like Operating Systems
2.  Shells
3.  Syntax of a Unix Command 
4.  Data Streams
5.  Defining the `del` Command
6.  Scripts and Script Arguments
7.  Functions
8.  If Statements
9.  Subshells
10. Regular Expressions
11. For Loops
12. Arrays
13. Case Statements
14.	Parsing Delimited Text Files with `awk`
15.	Our Implementation of `del`
16.	Dotfiles
17. Aliases
18. Process Management

## 1. Unix-like Operating Systems

A Unix like operating system is an operating system that behaves more-or-less like the Unix operating system. The first version of Unix was developed between 1969-71 at Bell Labs. It was one of the first operating systems to support multitasking and the first portable operating system written in C instead of processor dependant machine language.

Characteristics of a Unix-like operating system:

- **Everything is a file:** Almost every system device (e.g. storage, the keyboard and mouse) and resource (e.g. GPU or CPU) is abstracted to a **data stream** that can be read and written to like a regular file.

- **Core Utilities:** A set of core **command-line utilities:** that behave similarly to the core Unix utilities (`ls` `grep`, `ssh`).

- **Full or partial adherence to Unix specifications and the POSIX standard:**  A common set of commands and behaviours. **POSIX** is a collection of standards specified by the IEEE Computer Society. They maintain compatibility between operating systems and (broadly) versions of the same operating system by defining a common user-level application programming interface (API), command line shells and utilities.

The relevance of Unix-like operating systems is arguably due to the last of these three points and the advent of open-source and free-software projects. These include the Linux operating system and the GNU (GNU is Not Unix) toolchain, which provides a collection of compilers, libraries, debuggers and core utilities modelled on Unix. 

A few modern Unix-like operating systems are:

* Linux
* Android (which is based on Linux)
* MacOS (versions 10.5 and up are UNIX compliant)
* The Playstation 4 and 5 system software 'Orbis OS' (based on FreeBSD)

The portability, transparency and longevity of Unix-like operating systems make them a popular choice for the development of software tools for scientific computing. Linux is the de-facto standard in supercomputing.

## 2. Shells

A shell is a program that provides a user interface to the services of an operating system. Beneath the shell is the operating system kernel - which acts as a bridge of the between the software installed on the computer and its hardware.

Shells can be graphical (e.g. the Windows desktop environment) or command-line based. Command-line shells offer the advantages of low system overhead, integration with **shell scripting languages** and reproducibility. For this reason, many graphical programs are built on, or offer a collection of equivalent, command-line utilities.

The most common shell is the Borne Again Shell (BASH) - it is the default for most Linux distributions. Another common shell is the Z shell (zsh) - which extends the features of BASH. It is the default shell on current versions of macOS.

### 3. Syntax of a Unix Command

**Command-line utilities** on **Unix-like** operating systems follow the syntax:

	*verb* *adverb(s)* *object(s)*

Or, equivalently:

    [COMMAND] [OPTION(s)] [FILES(s)]

For example:

	ls -A ~/

Where `ls` (list files) is the verb, `-A` (list everything but `.` and `..`) is the adverb and `~/` (the user home directory) is the object. 

**Command line utilities** (or just commands) are a small programs designed for use in a command-line **shell**. When executed, they read input data from the **stdin** (standard in) **data stream** and returns an output the **stdout** (standard output) **data stream**. This predictable behaviour allows for the output of one command to be **piped** to the input of another.


## 4. Data Streams

A data streams transfer data (usually text) from a source (file, device or program) to an outflow in another.

When a BASH session starts, it creates three default data streams which are each assigned an integer file handle (remember, everything is a file).

- **stdin** (file handle 0):    The standard input data stream, most often takes input from the keyboard.

- **stdout** (file handle 1):      The standard output data stream. Passes data to the display by default.

- **stderr** (file handle 2):    The standard error data stream. Passes data to the display by default.

Data streams created by BASH.

The `read` command takes input from stdin.

    read
    This is to stdin

 Command-line utilities output to stdout:

    ls -A .

    total 3
    drwxr-xr-x. 1 edric edric    0 Nov  5 23:05 Videos
    drwxr-xr-x. 1 edric edric 3058 Nov 18 18:38 Downloads
    drwxr-xr-x. 1 edric edric   24 Nov 19 21:32 software

Unless they encounter an error:

    ls -A nonexistant

The above returns the error:

    ls: cannot access 'nonexistent': No such file or directory

Which is printed to stderr.

The pipe command `|`, passes stdout to another command and `|&` pipes stderr and stdout to stdin (this can help with debugging).

To redirect stdout:


To redirect and append:

    df -h >> diskusage.txt

More generally, `&[FILE HANDLE FROM]>[FILE HANDLE TO]` redirects the data stream with [FILE HANDLE FROM] to [FILE HANDLE TO].

For instance, to redirect stderr to stdout:

    ls -A nonexistant 2>&1

The `&` before the `1` is important, without it is ambiguous as to wether we are referencing a file named "1".

Data can be sent to a command by redirecting stdin (though this is not very common):

    command < input.txt

To discard the output of a datastream we can redirect it to`\dev\null`, which discards all data written to it.

    command > /dev/null

It's possible to open addition file descriptors, but stdin, stdout and stderr are usually sufficiant.

## 1.4. Why BASH?

BASH is a scripting language. Scripting languages are programming languages that manipulate or automate exisitng systems. For BASH this is the Unix file system, the input and output of command line utilities and  **environment variables** that  control the behaviours of software.

Python is a high-level programming language that can be used as a scripting language. However, for operation on files, BASH is often faster and requires fewer lines of code. For more complex tasks, Python is a better choice as it is more flexible and easier to maintain.

> As a rule-of-thumb, BASH is a good choice for 'set and forget' scripts with fewer than 100 lines. 

## 2. Implementing the `del` command.

The remove command, 

    rm [FILE]

deletes the target `[FILE]` permanently. Great if you meant it - not so great otherwise.

In portion of the workshop, we'll develop a user-defined `del` command that:

1. Sends target FILES(s) to a hidden directory, `.recycle_bin`.

	del [FILE(s)]

2. When passed the -l option lists the N most recently 'recycled' files:

	del -l [N]

3. When passed the -u option undoes the N most recent 'recycles':

	del -u [N]

Where `-l` and `-u` are options and `N` is an integer value.

## 6. BASH Scripts and BASH Script Arguments

A BASH script is a text file containing lines of BASH compatible commands. These scripts start with a *shebang* and the path to the BASH interpreter:

	#!/bin/bash

BASH scripts accept an arbitrary number of whitespace delimited input arguments. These are accessed from within the BASH script like so:

* `$0`, 	        The script (or function) name.
* `$N`, 	        The Nth argument.
* `$#`, 	        The number of variables passed to the script (or function).
* `$*` and `$@`,	All of the positional arguments.

Where `$*` expands to a single string and `$@` expands to a sequence of strings.

___

Example 1: Parsing arguments.

	#!/bin/bash
	echo "The name of the script
	echo "This is the first argument $1."
	echo "There are $# argument(s) in total:"
	echo "$@"

___

## 7. BASH Functions

BASH functions allow the same piece of BASH code to be reused multiple times in a terminal session or script.

### BASH function syntax:

	*function name* () {
	
		*...*
	
		}

Typically, a  BASH function outputs to stdin if sucessful:

    echo 'Everything is fine!'

And outputs to stderr otherwise:

    echo 'Everything is awful!' 1>&2 

Standard practice is to return the exit status of the function (or script) where,

	return 0

indicates success, and `return [N]`, where [N]=1,2,3..., indicates an error.
___

Example 2: A BASH function that returns the number of input arguments.

	#!/bin/bash
	del () {
		echo "There are $# arguments"
		return 0
	}

___

To use a bash function outside of the bash script itself, **source** (read and execute) the script in the current shell environment:

	. ./recycle_bin/recyle_bin.sh

## 8. If Statements

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

## 9. Subshells

In Example 3, the command `$(cd $(dirname ${BASH_SOURCE[0]});pwd)` carries out the following steps.

First, `$( [COMMANDS] )` spawns a new BASH **subshell** that contains only the default enviornment variables.

Next, this fresh subshell executes:

    cd [PATH TO SCRIPT FILE]

Where `[PATH TO SCRIPT FILE]` is the location of the script. Note that environment variable substitution occurs *before* the command is passed to the subshell.

Finally,

    pwd

returns the absolute path to the folder that contains the script to the originating (parent) shell.

## 10. Regular Expressions

Regular expressions are sequences of characters that specify a search pattern. For example, `*.dat` refers to any file ending in `.dat` and `?.dat` to any file ending with `.dat` with a prefix that is zero or more characters long.

Regular expressions use the special characters `.?*+{|()[\^$`.

### A (selective) summary of regular expression syntax:

* `.` 	matches any single character zero or one times.
* `?`, 	match to a single preceeding character.
* `*`,	 the preceding item is matched zero or more times.
* `+`,	 the preceding item is matched once or twice.
* `{n}`	 the preceding item is matched exactly n times.
* `|`,	 joins regular expressions and returns whatever matches either of the two strings.
* `[]`,	matches against a list or range of characters. e.g. `[^adf]` matches to anything that is not a `d` or `f` and `[0-9A-Za-z]` matches to all alphanumeric characters

A special character may be included as a normal character in a regular expression by preceding (`escaping`) it with a `\` character.

Not all BASH commands support the full range of regular expressions. However, the `.`, `?` and `*` operators are (almost) universally recognised for `shell pattern matching.

___

Example 4: Pattern matching to identify option flags (e.g. -l and -u).

	echo $@ | grep -Eq '\-[a-zA-Z]?[0-9]+'

___

## 11. For Loops

A BASH for loop applies the same sequence of operations multiple times while iterating through a sequence.

### For loop syntax 1:

	 for OUTPUT in $(*command*)
	
	 do
	
			*commands*
	
	 done

e.g.:

	for i in $(seq 0 10)
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
		if $(echo $input | grep -Eq '\-[a-zA-Z]?[0-9]+')
		then
			echo "Input '$input' is an option."
		else
			echo "Input '$input' is (probably) a path."
		fi
	done

___

## 12. Arrays

BASH arrays are a sequence of indexable strings separated.

For example,

	SEQ1=(2 4 6 8 10 12)
or

	SEQ1=( "First Element" "Second Element" "Third Element")

### A (selective) summary of BASH array syntax:

* `arr=()`, 	 empty array.
* `arr=(1 2 3)`, 	 initialise array.
* `${arr[2]}`, 	 retrieve the third element (Note: BASH arrays are 0-indexed).
* `${arr[@]}`, 	retrieve all elements.
* `${!arr[@]}`, 	 retrieve array indices.
* `${#arr[@]}`, 	 calculate the array size.
* `arr[0]=3`, 	 overwrite the first element.
* `arr+=(4)`, 	 append value(s).
* `str=$(ls)`, 	 save ls output as a string.
* `arr=($(ls))`, 	 save ls output as an array of files.
* `${arr[@]:S:N}`, 	 Retrieve N elements starting at index S.
___

Example 6: Classify arguments as options and files. Append the corresponding matched file to the FILES and OPTIONS arrays.

	FILES=()
	OPTIONs=()

	for input in $@
	do
		if $(echo $input | grep -Eq '\-[a-zA-Z]?[0-9]+')
		then
			OPTIONs+=($input)
		else
			FILES+=($input)
		fi
	done
___

## 13. Case Statements

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


## 14. Parsing Delimited Text Files with 'awk'.

Sections 3 to 9 defined the main control structures needed to implement `del`. However, we need a means of tracking the 'recycled' files and their original location. To achieve this, we will use a log file in the `.recycle_bin` directory called `.recycle_log` that will store the file size, file path in `.recycle_bin` and the original file path in a single line for each recycled file.

___

Example 8: Recycle files and write to `$LOG_DIR`.

	for FILE in ${FILES[@]}
	do
		if [ -e $FILE ]
		then
			NEW_PATH="$RECYCLE_BIN_DIR/$(date +%s)_$FILE"
			OLD_PATH="$(cd $(dirname $FILE);pwd)/$(basename "$FILE")"
			echo $(du "$OLD_PATH" | cut -f1)  "$NEW_PATH" "$OLD_PATH"  $LOG_DIR
			mv $FILE $NEW_PATH
		else
			echo "File '$FILE' does not exist!"
		fi
	done

___

We will use the `awk` command to parse this log file. Awk is a scripting language used for manipulating data and generating reports. It supports variables, numeric functions, string functions and logical operators.

Awk allows a programmer to write tiny programs to search for a pattern on each line of a file and carry out an action when that pattern is detected.

Some `awk` examples:

* `awk '{print}' [FILE]`, 	print the contents of `[FILE]` to stdout.
* `awk '{print $1}' [FILE]`, 	print the first column of `[FILE]`, by default white space is treated as the separator.
* `awk '{print $1 ""$3}' [FILE]`,	 print the first and the third column of `[FILE]` with a space in-between.
* `awk '/example/ {print}' [FILE]`,	 print all lines in `[FILE]` that contain the word example.
* `awk '[0-9]/{print}' [FILE]`,	 print all lines in `[FILE]` that contain numbers.
* `awk ‘^[0-9]/{print}’ [FILE]`,	 print all lines in `[FILE]` that start with a number
* `awk -F',' '{sum+=$1} END{print sum;}' [FILE]`,	sum the first column of `[FILE]` using `,` as the column delimiter.

___

Example 9: Sum the first column (file size) of the `del` log file.

	tail -n4 ~/recycle_bin/.recycle_bin/.recycle_log | awk '{size+=$1} END{print size}'

___

## 15. Our Implementation of `del`

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

## 16. Dotfiles

The behaviour of a Unix system is controlled through the setting of environment variables. For instance, we have already encountered the HOME variable, which contains the path to the current user's home directory:

	echo $HOME

Another important variable is the $PATH directory.

	echo $PATH

This contains a list of locations that Unix searches for executable files (starting from the first directory). For instance, if we use the command `/whereis` to search for the location of the `grep` program:

	whereis 'grep'

We see that it is located under `/bin`.

	echo $PATH | grep ':/bin:'

Which is one of the default locations included in PATH.

Let's bring our attention back to the HOME environment variable. This variable is important for several reasons:

1. On all Unix systems, the user will have read, write and execute permissions in the HOME directory.
2. HOME is (typically) the location of user-specific programs.
3. HOME is (typically) the location for user-specific configuration files.

Configuration files are hidden files in the Unix file system. Hidden files in Unix start with a `.`. For this reason, they are often referred to as `dotfiles`.

From with the user's home directory, the command:

	ls -a

typically displays several dotfiles.

The most notable of these is perhaps `.bashrc`. This dotfile is 'sourced' whenever a new Bash session is launched (e.g. when the terminal window is opened).

To have `del` avaliable whenever we start a terminal session we can append,

	. ~/recycle_bin/recycle_bin.sh

to `.bashrc`.

## 17. Aliases

Aliases are user-defined commands built out of a sequence of terminal commands; with them, we can define 'shortcuts' to longer commands.

### Alias syntax:

	 alias *shortcut name*=*command*

e.g.:

	alias rm='rm -i'

will prompt the user for confirmation before deleting the file.

Aliases are a great way of making your system more comfortable to use. Modifications to .bashrc are the simplest way to change the behaviour of your Unix shell.

Be sure to do so with care, though. Comment on any changes, and add new commands to the bottom of the file wherever possible. Even better is to store your custom environment variables in a file that is 'sourced' by .bashrc.

## 18. Process Management

Unix-like operating systems are multitasking - something that we experience if using the desktop environment of macOS or a Linux distribution.

Consider the following command,

	watch -n1 'cat /proc/meminfo | grep MemFree'

which shows the current free RAM, updated every 1 second.

A program that we can see in the terminal is running in the `foreground`; to abort a program running in the foreground, we can use `Ctrl+c`.

To suspend the task, we can instead use `ctrl+Z`, at which point we see output that gives the process number (JOB SPEC) and the status of the process.

Let's run another version of the command that instead looks at the amount of cached memory:

	watch -n1 'cat /proc/meminfo | grep -w Cached'

which we will also suspend.

To start one of these processes back up, we use the `foreground` command,

	fg 1

or the background command

	bg 1

Which will start the process running in the background. 'bg [job spec]' is equivalent to starting a command with `&`

	watch -t -n1 "date +'%H:%M:%S' | tee -a loged" &*/dev/null &

To see a list of foreground and background processes with their corresponding 'job spec':

	jobs

To end a non-responsive job, we can retrieve the process IDs,

	jobs -p

and issue the `kill` command. For example, given a PID of `1484`:

	kill -KILL 1484

*
