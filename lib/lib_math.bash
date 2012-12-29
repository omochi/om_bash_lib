#!/bin/bash

math_max(){
	if (( $1 > $2 )) ; then 
		echo $1
	else
		echo $2
	fi
	return 0
}
math_min(){
	if (( $1 < $2 )) ; then
		echo $1
	else
		echo $2
	fi
	return 0
}
math_clamp(){
	echo $(math_max $2 $(math_min $1 $3))
	return 0
}
