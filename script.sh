#!/bin/bash
function publickey(){
	key=$(gpg --list-secret-keys --keyid-format=long|awk '/sec/{if (length($2)>0) print $2}')
	a=1
	while IFS= read -r line;
	do
		if [[ "$1" == "$a" ]]; then
			echo "Enter the following in your git gpg portion"
			out=${line##*/}
			echo out
			gpg --armor --export $out
			git config --global user.signingkey $out
			git config --global commit.gpgsign true
			break
		fi
	export a=$((a+1))
	done<<<"$key"
}
useID=$(gpg --list-secret-keys --keyid-format=long|awk '/uid/{if (length($3)>0) print $3}')
echo "enter 0 if you want to generate new gpg key. Otherwise input 1,2,3 respectively for particular user ID"
a=1
arr=()
while IFS= read -r line;
	do echo  "${a} '${line}'";
	export a=$((a+1))
	arr+=("${line}")
done<<<"$useID"
no_of_keys=$((a-1))
read val
if [[ $val -gt $no_of_keys ]];then
	echo "Please enter a valid key"
elif [[ $val == 0 ]]; then
	gpg --default-new-key-algo rsa4096 --gen-key
	export no_of_keys=$((no_of_keys+1))
	useID=$(gpg --list-secret-keys --keyid-format=long|awk '/uid/{if (length($3)>0) print$3}')
	a=1
	while IFS= read -r line;
	do
		if [[ "$a" == "$no_of_keys" ]]; then
		echo "$a"
		echo "$no_of_keys"
			if ! [[ "$line" =~ [^a-zA-Z0-9] ]]; then
				publickey "$no_of_keys"
			else
				echo "userID can only be alphanumeric"
				gpg --delete-secret-key $line
			fi
		fi
		export a=$((a+1))
	done<<<"$useID"

else 
	publickey $val
fi
