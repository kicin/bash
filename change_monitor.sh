#!/bin/bash

file="$HOME/.config/sk/changes.conf" #plik z zapisanymi badanymi folderami
filepath="$HOME/.config/sk" #sciezka odwolan
outpath="$HOME/Desktop" #sciezka out 
outfile="output.txt" #plik out


cd "$outpath"
touch "$outpath/$outfile" #jesli nie istnieje plik w podanej sciezce to go tworzy

currdate=$(date +%Y-%m-%d-%r)
echo "$currdate" >> "$outfile" #wpisuje datę

while read -r line; do
	
	path="$line"
	cd "$path"
	pathname="$path"
	dirname="${pathname%"${pathname##*[!/]}"}"
	dirname="${dirname##*/}" 
	
	filename="$dirname.txt" #plik z odnośnikiem w folderze config
	cd "$filepath"	
	if [ -s "$filename" ] #sprawdza czy pierwsze odwolanie do folderu
	then
		tempfile="temp.txt"
		touch "$tempfile"

		cd "$path"
		ls -R>"$filepath/$tempfile"

		cd "$filepath"
		if cmp -s "$tempfile" "$filename" #sprawdza, czy zostaly wprowadzone zmiany
		then
			cd "$outpath"
			echo "Nothing changed in folder $dirname" >> "$outfile" #info o braku zmian do pliku out
		else
			cd "$filepath"
			while read -r line2; do
			if grep -q "$line2" "$tempfile"   #sprawdzanie, czy wszystkie pliki z poprzedniego folderu są w aktualnym
			then
				:
			elif [[ "$line2" == *"./"* ]];
			then
				:
			else
				echo "$line2 was deleted from folder $dirname" >> "$outpath/$outfile"
			fi
			done < "$filename"

			while read -r line3; do
			if grep -q "$line3" "$filename" #sprawdzanie, czy pojawiły się nowe pliki
			then
				:
			elif [[ "$line3" == *"./"* ]];
			then
				:
			else
				echo "$line3 was added to folder $dirname" >> "$outpath/$outfile"
			fi
			done < "$tempfile"
		fi
		cd "$filepath"
		cat "$tempfile" > "$filename"
	else  #pierwsze odwolanie do folderu
 		cd "$filepath"
		touch "$filename"
		cd "$path"
		ls -R > "$filepath/$filename" #tworzy plik zztxt z zawartoscia folderu
		cd "$filepath"
		while read -r line2; do
			temp="$line2/$dirname"
			check0="$line2"
			if [ "$check0" == "." ];
			then
				:
			elif [ "$check0" == ".:" ];
			then
				:
			elif [ "$check0" == "" ];
			then
				:
			elif [[ "$check0" == *"./"* ]];
			then
				:
			else
				echo "$check0 was added to folder $dirname" >> "$outpath/$outfile"
			fi
		done < "$filename"
	fi
done < "$file"
