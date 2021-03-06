my_symbol="?";
enemy_symbol="?";
my_move=0;

declare -A map;
for ((i=0;i<3;i++)) do
    for ((j=0;j<3;j++)) do
        map[$i,$j]="_";
    done;
done;

pipe=/tmp/mypipe;
trap "rm -f $pipe" EXIT
if [[ ! -p $pipe ]]; then
    mknod $pipe p;
	my_symbol="x";
	enemy_symbol="o";
	my_move=1;
	echo "---You are x---";
else
	my_symbol="o";
	enemy_symbol="x";
	echo "---You are o---";
fi;

function checkExistCell(){
	for ((i=0;i<3;i++)) do
		for ((j=0;j<3;j++)) do
			if [[ "${map[$i,$j]}" == "_" ]]; then
				return 1;
			fi;
		done;
	done;
	return 0;
}

function searchWinner(){
	#search for the winner by rows
	for ((i=0;i<3;i++)) do
		have_winner=1;
		for ((j=0;j<2;j++)) do
			if [[ "${map[$i,$j]}" == "_" ]]; then
				have_winner=0;
				break;
			fi;
			if [[ "${map[$i,$j]}" != "${map[$i,$((j+1))]}" ]]; then
				have_winner=0;
				break;
			fi;
		done;

		if [[ $have_winner == 1 ]]; then
			if [[ "${map[$i,$j]}" == "x" ]]; then
				return 1;
			elif [[ "${map[$i,$j]}" == "o" ]]; then
				return 2;
			fi;
		fi;
	done;
	
	#search for the winner by columns
	for ((i=0;i<3;i++)) do
		have_winner=1;
		for ((j=0;j<2;j++)) do
			if [[ "$map[$j,$i]" == "_" ]]; then
				have_winner=0;
				break;
			fi;
			if [[ "${map[$j,$i]}" != "${map[$((j+1)),$i]}" ]]; then
				have_winner=0;
				break;
			fi;
		done;
		
		if [[ $have_winner == 1 ]]; then
			if [[ "${map[$j,$i]}" == "x" ]]; then
				return 1;
			elif [[ "${map[$j,$i]}" == "o" ]]; then
				return 2;
			fi;
		fi;
	done;
	
	#search for the winner in the usual diagonal
	if [[ "${map[0,0]}" == "${map[1,1]}" && "${map[1,1]}" == "${map[2,2]}" ]]; then
		if [[ "${map[0,0]}" == "x" ]]; then
			return 1;
		elif [[ "${map[0,0]}" == "o" ]]; then
			return 2;
		fi;
	fi;
	
	#search for the winner in the reverse diagonal
	if [[ "${map[0,2]}" == "${map[1,1]}" && "${map[1,1]}" == "${map[2,0]}" ]]; then
		if [[ "${map[0,2]}" == "x" ]]; then
			return 1;
		elif [[ "${map[0,2]}" == "o" ]]; then
			return 2;
		fi;
	fi;
	return 0;
}


while true; do
	if [[ $my_move == 1 ]]; then
		#processing my move
		echo "Go >>";		
		read row column;
		if [[ $row > 3 || $column > 3 ]]; then
			echo "Cell does not exist";
			continue;
		fi;
		if [[ "${map[$(($row-1)),$(($column-1))]}" != "_" ]]; then
			echo "This cell is not empty";
			continue;
		fi;
		map[$(($row-1)),$(($column-1))]=$my_symbol;	
		echo $row $column > $pipe;
		my_move=0;
	else
		#processing enemy move
		echo "Wait...";
		read row column < $pipe;		
		map[$(($row-1)),$(($column-1))]=$enemy_symbol;
		my_move=1;
	fi;
	
	#printing a map
	for ((i=0;i<3;i++)) do
		echo ${map[$i,0]} ${map[$i,1]} ${map[$i,2]};
	done;
	
	checkExistCell;
	exist_cell=$?;
	if [[ $exist_cell == 0 ]]; then
		echo "Friendship won!";
		break;
	fi;
	
	searchWinner;
	winner=$?;
	if [[ $winner == 0 ]]; then
		continue;
	fi;
	
	#processing end of game 
	if [[ $winner == 1 && "${my_symbol}" == "x" ]]; then
		echo "Winner!!!";
		break;
	elif [[ $winner == 2 && "${my_symbol}" == "o" ]]; then
		echo "Winner!!!";
		break;
	else
		echo "Loser!!!";
		break;
	fi;
done;
