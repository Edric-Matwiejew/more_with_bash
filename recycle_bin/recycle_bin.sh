#!/bin/bash

RECYCLE_BIN_SOURCE="$(cd $(dirname ${BASH_SOURCE[0]});pwd)"
RECYCLE_BIN_SOURCE+=/"$(basename "${BASH_SOURCE[0]}")"

RECYCLE_BIN_DIR="$RECYCLE_BIN_SOURCE/.recycle_bin"

if [ ! -e "$RECYCLE_BIN_DIR" ]
then
	mkdir $RECYCLE_BIN_DIR
	echo "Created new recycle bin directory at :" $RECYCLE_BIN_DIR
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

	LOG_PATH="$RECYCLE_BIN_DIR"/.recycle_log

	# extract the number attached to an OPTION flag.

	if [ ! -e "$LOG_PATH" ]
	then
		touch "$LOG_PATH"
	fi

	if $($(echo $@ | grep -q '\-h') || $(echo $@ | grep -q '\--help'))
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

	for input in $@
	do
		if $(echo $input | grep -Eq '\-[a-zA-Z?][0-9*]')
		then
			OPTIONs+=($input)
		else
			FILES+=($input)
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
				tail -n$(get_number $OPTION) $LOG_PATH
				return 0
				;;

			-u*)
				N=$(get_number $OPTION)
				mv_from=($(tail -n$N $LOG_PATH | awk '{print $2}'))
				mv_to=($(tail -n$N $LOG_PATH | awk '{print $3}'))

				for i in $(seq 0 $((N - 1)))
				do
					mv ${mv_from[$i]} ${mv_to[$i]}

					if [ ! -e ${mv_from[$i]} ]
					then
						M=$(grep -n "${mv_from[$i]}" $LOG_PATH | cut -f1 -d:)
						sed -i -e "${M}d" $LOG_PATH
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
		if [ -e $FILE ]
		then
			NEW_PATH="$RECYCLE_BIN_DIR/$(date +%s)_$FILE"
			OLD_PATH="$(pwd)/$(basename "$FILE")"
			echo $(du "$OLD_PATH" | cut -f1)  "$NEW_PATH" "$OLD_PATH" >> "$LOG_PATH"
			mv $FILE $NEW_PATH
		else
			echo "File '$FILE' does not exist!"
		fi
	done

	unset -f get_number
	return 0

}

echo "Defined the 'del' command, use 'del --help' for info on its usage."
