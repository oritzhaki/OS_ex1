#!/bin/bash
# Or Itzhaki 209335058

p1s=50
p2s=50
game_on=true
moves=( -3 -2 -1 0 1 2 3)
game_state=0

#function for printind the board state:
print_board () {
	echo " Player 1: ${p1s}         Player 2: ${p2s} "
	echo " --------------------------------- "
	echo " |       |       #       |       | "
	echo " |       |       #       |       | "
	case $1 in
		${moves[0]})
			echo "O|       |       #       |       | "
			;;
		${moves[1]})
			echo " |   O   |       #       |       | "
			;;
		${moves[2]})
			echo " |       |   O   #       |       | "
			;;
		${moves[3]})
			echo " |       |       O       |       | "
			;;
		${moves[4]})
			echo " |       |       #   O   |       | "
			;;
		${moves[5]})
			echo " |       |       #       |   O   | "
			;;
		${moves[6]})
			echo " |       |       #       |       |O"
			;;
	esac
	echo " |       |       #       |       | "
	echo " |       |       #       |       | "
	echo " --------------------------------- "
}

#function for player input:
get_player_input () {
notval=true
	while $notval
	do
	   echo "PLAYER $1 PICK A NUMBER: "
	   read -s input
	   #check if valid number:
	   local score="p${1}s"
	   if [[ $input =~ ^[0-9]+$ ]] && (("$input" >= 0 && ${!score} >= "$input")); then
	   	notval=false
	   else
	   	echo "NOT A VALID MOVE !"
	   fi
	done
	player_input=$input
}

#function for checking if the game has ended:
check_win () {
	if (($game_state == -3)); then
		echo "PLAYER 2 WINS !"
		return 0
	elif (($game_state == 3)); then
		echo "PLAYER 1 WINS !"
		return 0
	elif (($p1s == 0 && $p2s > 0)); then
		echo "PLAYER 2 WINS !"
		return 0
	elif (($p2s == 0 && $p1s > 0)); then
		echo "PLAYER 1 WINS !"
		return 0
	elif (($p2s == 0 && $p1s == 0)); then
		if (($game_state > 0)); then
			echo "PLAYER 1 WINS !"
			return 0
		elif (($game_state < 0)); then
			echo "PLAYER 2 WINS !"
			return 0
		else
			echo "IT'S A DRAW !"
			return 0
		fi
	else
		return 1
	fi
}

# print starting screen:
print_board $game_state

while $game_on
do
	# player 1 input: 
	get_player_input 1
	p1_choice=$player_input

	# player 2 input: 
	get_player_input 2
	p2_choice=$player_input

	# game tactics:
	if (($p1_choice > $p2_choice)) #player2 looses this round
	then
		if (("$game_state" <= 0)); then
			game_state=1
		else
			((game_state++))
		fi
	elif (($p1_choice < $p2_choice)); then #player1 looses this round
		if (("$game_state" < 0)); then
			((game_state--))
		else
			game_state=-1
		fi
	fi

	#display new game screen and what each player played
	p1s=$((p1s - p1_choice))
	p2s=$((p2s - p2_choice))
	print_board $game_state
	echo -e "       Player 1 played: ${p1_choice}\n       Player 2 played: ${p2_choice}\n\n"

	#check if win and display and exit game if so
	if check_win; then
		break
	fi

done

