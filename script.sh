#!/bin/bash\
useID=$(gpg --list-secret-keys --keyid-format=long|awk '/uid/{if (length($3)>0) print $3}')
echo "enter 0 if you want to generate new gpg key. Otherwise input 1,2,3 respectively for particular user ID"
a=1
while IFS= read -r line;
	do echo  "${a} '${line}'";
	export a=$((a+1))
done<<<"$useID"
no_of_keys=a
read val
key=$(gpg --list-secret-keys --keyid-format=long|awk '/sec/{if (length($2)>0) print $2}')
a=1
while IFS= read -r line;
do
	if [[ "$val" == "$a" ]]; then
		echo "Enter the following in your git gpg portion"
		out=${line##*/}
		echo out
		gpg --armor --export $out
		git config --global user.signingkey $out
		git config --global commit.gpgsign true
		break
	elif [[ "$val" > "$no_of_keys" ]];then
		echo "Please enter a valid key"
		break
	fi
	export a=$((a+1))
done<<<"$key"
if [[ "$val" == "0" ]]; then
gpg --default-new-key-algo rsa4096 --gen-key
key=$(gpg --list-secret-keys --keyid-format=long|awk '/sec/{if (length($2)>0) print $2}')
a=1
export no_of_keys=$((no_of_keys+1))
while IFS= read -r line;
do
if [[ "$no_of_keys" == "$a" ]]; then
	echo "paste the following in your gpg region"
        out=${line##*/}
        echo out
        gpg --armor --export $out
        git config --global user.signingkey $out
        git config --global commit.gpgsign true
        break
fi
export a=$((a+1))
done<<<"$key"
fi


