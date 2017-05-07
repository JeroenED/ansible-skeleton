#!/bin/bash
IFS=$'\n'

command=${1}
if [ -z "${2+x}" ]; then vagrantenv="."; else vagrantenv=${2}; fi

cd ${vagrantenv} 

status=($(vagrant status))

alllines=()

for line in ${status[*]}
do
	if [[ $line == *"(vmware_workstation)"* ]]; then
		if [[ $command == "up" && $line == *"  not running"* || $command == "halt" && $line == *"  running"* || $command == "ssh" && $line == *"  running"* || $command == "provision" && $line == *"  running"* ]]; then
			alllines+=($line)
		fi
	fi
done

if [[ ${#alllines[*]} -gt 1 ]]; then

	for item in ${alllines[*]}
	do
	    echo $item
	done


	echo -ne "Please choose the your machine [default: ALL]: "
	read -a input

else

	IFS=' '
	read -a fullline <<< ${alllines}
	input=${fullline[0]}

fi
	
if [[ ${#input[@]} -eq 0 ]]; then
	for item in ${alllines[*]}
	do
	    input+=("${item%% *}")
	done
fi
if [[ ${#input[@]} -ge 2 && $command == "ssh" ]]; then
	echo "The SSH can only be used on 1 machine. All other machines will be ignored"
	machines=(${input[0]})
else
	machines=${input[*]}
fi

for machine in ${machines[*]}
do 
	echo '';
	status=`vagrant status $machine 2>&1`
	if [[ -n `echo ${status} | grep "not running"` && $command != 'up'  && $command != 'halt' ]]; then
	 	echo "Vagrant machine ${machine} is not running, booting it now"
		vagrant up ${machine}
	fi
	vagrant ${command} ${machine}
done
