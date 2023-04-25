#!/bin/bash

#creating global variables:
export WORD=$2
export INIT_PATH=$1

#check if there is enough arguments:
if [ -z "$2" ]; then
    echo "Not enough parameters"

#check if the -r flag is here:
elif [ -z "$3" ]; then
    #Third argument is missing, so process this folder only:
    cd "$1"
    # remove all compiled files, if exist:
    if ls *.out 1> /dev/null 2>&1; then
        rm *.out
    fi
    #find all existing c files that include the word from the second argument, and pipeline them to be compiled:
    if ls *.c 1> /dev/null 2>&1; then
        #grep -ilw "$WORD" *.c | xargs gcc -o myprog.out -w
        grep -ilw "$WORD" *.c | xargs -I {} bash -c 'gcc -o "$(basename {} .c)".out {} -w'
    fi
else
    #recursevely process each directory:
    find "$1" -type d -exec bash -c '
        function process_folder () {
            cd "$1"
            # remove all compiled files, if exist:
            if ls *.out 1> /dev/null 2>&1; then
                rm *.out
            fi
            #first find all existing c files that include the word from the second argument, and pipeline them to be compiled:
            if ls *.c 1> /dev/null 2>&1; then
                grep -ilw "$WORD" *.c | xargs -I {} bash -c '\''gcc -o "$(basename "{}" .c)".out "{}" -w'\''
            fi
            cd "$INIT_PATH"
        }
        process_folder "$1"
    ' _ {} \;
fi
