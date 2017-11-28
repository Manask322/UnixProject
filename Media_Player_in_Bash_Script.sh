ls *.mp3 | cat > ls1.txt 
tr ' ' '\n' < ls1.txt | cat > songtemp.list
cat -n songtemp.list > songList.list
sed 'i\

' ls1.txt > songList1.list

#Initialize flag files
echo "0" | cat > flag
echo "0" | cat > flag1
echo "0" | cat > flagPlaylist
echo "0" | cat > flag3

(

sed '/^ *$/d' songList1.list > songList2.list
declare -A arr
arr=()
for((i=0;i<200;i++))
do
	arr[$i]="0"
done


readarray sa < songList2.list
n=${#sa[@]}


#Pre process the song list
for((j=0;j<$n;j++))
do 
	s=${sa[$j]}

	len=`expr length "$s" `
	sum=0
	for((i=0;i<$len;i++))
	do
		char=${s:$i:1}

		AscValue=`printf "%d" "'$char'"`

		sum=`expr $sum + $AscValue`
	done

	has=`expr $sum % 200`
	if [ ${arr[$has]} = "0" ]
	then
		arr[$has]=$s
	else
		t=0
		while [[ $t -eq 0 ]]; do
			has=`expr $has + 1`
			if [ $has -eq 199 ] ; then
				has=0
			fi
			if [ ${arr[$has]} = "0" ]; then
				arr[$has]=$s
				t=1
			fi
		done
	fi
	
done

while [ 1 -eq 1 ]
do
	
	Son=$(yad --title="Search a Song" --width=80 --posx=1440 --posy=100 --form --field="Enter the Song" --undecorated)
	cat > suggestion.list
	ll=`expr length "$Son"`

	ll=`expr $ll - 1`
	Song=${Son:0:$ll}
	l=`expr length "$Song"`
	sum1=0
	for((i=0;i<$l;i++))
	do
		ch=${Song:$i:1}
		AscVal=`printf "%d" "'$ch'"`
		sum1=`expr $sum1 + $AscVal`
	done
	hass=`expr $sum1 % 200`
	r=0
	if [ ${arr[$hass]} = "$Song" ]
	then
		r=1
		echo $Song | cat > suggestion.list
		echo "1" | cat > flag3
	else

		for((k=0;k<200;k++))
		do
			hass=`expr $hass + 1`
			if [ $hass -eq 199 ] ; then
				hass=0
			fi
			if [ ${arr[$hass]} = "$Song" ]; then
				r=1
				echo $Song | cat > suggestion.list
				echo "1" | cat > flag3
				break
			fi
		done
	fi

	if [ $r -eq 0 ]
	then
		q=0
		ne=0
		alp=(a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
		for((j=0;j<$l;j++))
		do
			t=$j
			for((k=0;k<52;k++))
			do
				sum2=0		
				a="${Song:0:$j}${alp[k]}${Song:$j+1}"
				le=`expr length "$a"`
				for((i=0;i<le;i++))
				do
					cha=${a:$i:1}
					Asc=`printf "%d" "'$cha'"`
					sum2=`expr $sum2 + $Asc`
				done
				hashi=`expr $sum2 % 200`
				if [ ${arr[$hashi]} = "$a" ]
				then
				echo "$a" >> suggestion.list
				q=1
				else
					for((m=0;m<200;m++))
					do
						hashi=`expr $hashi + 1`
						if [ $hashi -eq 199 ] 
						then
							hashi=0
						fi
						if [ ${arr[$hashi]} = "$a" ]
						then
							echo "$a" >> suggestion.list
							q=1
							break
						fi
					done
				fi
				if [ $q -eq 1 ];then
					ne=1
					break 
				fi
			done
			if [ $ne -eq 1 ];then
				break
			fi
		done
	fi
	
echo "1" | cat > flag3
done

) &


#Sub-shell to display suggestions
(

while [ 1 -eq 1 ]
do
	flagSuggest=`head -n 1 flag3`
	if [ $flagSuggest -eq 1 ]
	then
		echo "0" | cat > flag3
		sug=$(yad --list  --pox=10 --posy=100 --height=890 --width=1350 --button=Done:1  --undecorated --column=Suggestions<suggestion.list)
		echo $sug | cat > sugFile
		tr "|" " " < sugFile > res.txt
		sug=$(cat res.txt)
		grep -n $sug songList.list | cut -d ":" -f1 > res2.txt
	fi

done


) & 

#Sub Shell for Create Playlist
(

while [ 1 -eq 1 ]
do

	yad --posx=1630 --width=100 --posy=1000 --button=Create_Playlist:1 --undecorated 
	choiceCP=$?
	if [ $choiceCP -eq 1 ]
	then
		echo 1 | cat > flag
	fi 

done

) &

#Sub shell for selecting songs into playlist
(	

PlaylistNo=$(cat PlaylistNoFile)
while [ 1 -eq 1 ]
do

	n=`head -n 1 flag`
	if test $n -eq 1
	then
		let PlaylistNo=$PlaylistNo+1
		echo $PlaylistNo
		echo $PlaylistNo | cat > PlaylistNoFile
		echo 0 | cat > flag
		yad --button=Add:0  --posx=10 --posy=100 --height=890 --width=1350 --list --checklist --column=Add --column=Songs<songList1.list > PplaylistSelect
		tr -s " " < PplaylistSelect > PsqplaylistSelect
		cut -f2 PsqplaylistSelect > PsongWithPipe
		echo "Playlist_$PlaylistNo" | cat > Ptemp
		Pvar=$(cat Ptemp)
		tr "|" " " < PsongWithPipe > PTRUE
		sed -i 's/TRUE//' PTRUE
		tr '\040' '011' < PTRUE > Psongz
		sed 's/0//g' Psongz | cat > $Pvar
		echo $Pvar | cat >> PlaylistList

	fi
done 

) &



#Box for Album/Genre/Playlist/Artist
(
cat Song_Album.txt | cut -d "|" -f 3 | uniq | cat > Song
cat Song | cat > Album.txt

cat Song_Album.txt | cut -d "|" -f 4 | uniq | cat > Song2
cat Song2 | cat > Genre.txt


cat Song_Album.txt | cut -d "|" -f 2 | uniq | cat > Song3
cat Song3 | cat > Artist.txt

# cat Album.txt
readarray album_array < Album.txt
alength=${#album_array[@]}

for (( i = 0; i < $alength; i++ )); do
	var=${album_array[$i]}
	leng=`expr length "$var"`
	var1=${var:0:leng-1}
	grep $var1 Song_Album.txt | cut -d "|" -f 1 > "$var1"
done

readarray Genre_array < Genre.txt
glength=${#Genre_array[@]}
for (( j = 0; j < $glength; j++ )); do
	var=${Genre_array[$j]}
	leng=`expr length "$var"`
	var2=${var:0:leng-1}	
	grep $var2 Song_Album.txt | cut -d "|" -f 1 > "$var2"
done 

readarray Artist_array < Artist.txt
Arlength=${#Artist_array[@]}

for (( k = 0; k < $Arlength; k++ )); do
	var=${Artist_array[$k]}
	leng=`expr length "$var"`
	var3=${var:0:leng-1}
	grep $var3 Song_Album.txt | cut -d "|" -f 1 > "$var3"
done


while [ 1 -eq 1 ]
do
	yad --width=1700 --posx=10 --posy=20  --height=70 --button=Album:1 --button=Artist:2 --button=Genre:3 --button=Playlist:4 --undecorated --buttons-layout=center
	cho=$?
	case $cho in 
		1)
			albCh=$(yad --list  --button=Close:1 --posx=1440 --width=480 --height=800 --posy=185 --undecorated  --column=List<Album.txt) 
			echo -n "$albCh" | cat  > albChfile
			tr "|" " " < albChfile > Chfile2
			
			;;

		2)
			artCh=$(yad --list  --button=Close:1 --width=480 --height=800 --posx=1440 --posy=185 --undecorated  --column=List<Artist.txt) 
			echo -n "$artCh" | cat  > artChfile
			tr "|" " " < artChfile > Chfile2
			
			;;

		3)
			genCh=$(yad --list  --button=Close:1 --posy=185 --posx=1440 --width=480 --height=800 --undecorated  --column=List<Genre.txt) 
			echo -n "$genCh" | cat  > genChfile
			tr "|" " " < genChfile > Chfile2
			
			;;
		4)
			playCh=$(yad --list  --button=Close:1 --height=800 --width=480 --posx=1440 --posy=185 --undecorated  --column=List<PlaylistList) 
			echo -n "$playCh" | cat  > genChfile
			tr "|" " " < genChfile > Chfile2
		
			;;
			
	esac
	echo "1" > flag1
done

) &


#Subshell for playlist-songs-list

(

while [ 1 -eq 1 ]
do
	

	flagSong=`head -n 1 flag1`
	if [ $flagSong -eq 1 ]
	then
		tr -d '\040'  < Chfile2  > Chfile23 
		Pres=$(cat Chfile23)

		
		schoice=0
		song=$(yad --list  --button=Close:1 --posx=10 --posy=100 --height=890 --width=1350 --undecorated  --column=Songs < $Pres )
		schoice=$?
		if test $schoice -eq 1
		then
			echo "0" | cat > flag1
			echo "0" | cat > flagPlaylist
		else
			echo "1" | cat > flagPlaylist
			echo $Pres | cat > PresFile
			tr "|" " " < PresFile > Pres2File
			Pres=$(cat Pres2File)
			cat $Pres | cat > CurrentPlaylist.list	

			echo $song | cat > res23.txt
			sed -i 's/|//g' res23.txt
			song=$(cat res23.txt)
			echo $song | cat > res.txt
			grep -n "$song" CurrentPlaylist.list | cut -d ":" -f1 | cat > res2.txt
		fi
	fi

done

) &
#Subshell for Songs-List
(

	while [ 1 -eq 1 ]
	do
	
	res=$(yad --list --width=1350 --height=890 --posx=10 --posy=100 --undecorated  --column=Songs<songList.list);
	echo $res | cat > res1.txt;
	cut -d " " -f 1 res1.txt > res2.txt;
	cut -c 3- res1.txt >res.txt;
	
	done
) &

#Subshell for Play-Pause
(

#initialization
isPlayOne=0
waitTime=0
playTime=0
pausedAt=0
x=0
temp=0
count=0
alt=0

clear
yad --width=1300 --posx=10 --posy=1000 --text "Now Playing : --No Song Selected-- "  --button=Previous:1 --button=Play:2 --button=Next:3 --button=Stop:4 --undecorated --buttons-layout=center 
choice=$?


while [ 1 -eq 1 ]
do
var=$(cat res2.txt)
currSong=`tr '|' ' ' < res.txt`
case $choice in
	1)
	isPlayOne=0
	waitTime=0
	playTime=0
	pausedAt=0
	x=0
	temp=0
	alt=0

	if [ $var -eq 1 ];then
		
		#let var1=$var1-1 
		
		flagPlaylistf=`head -n 1 flagPlaylist`
		if test $flagPlaylistf -eq 1
		then
			wc -l CurrentPlaylist.list > new
			tr '\040' '\011' < new > new1
			var=$(cut -f1 new1)
			echo $var | cat > res2.txt
			head -n $var CurrentPlaylist.list | tail -1 > res.txt
		else
			wc -l songList.list > var.list
			var=$( cut -d " " -f 1 var.list )
			echo "$var" | cat > res2.txt
			head -n $var songList.list | tail -1 > newtemp.txt 
			cut -c 8- newtemp.txt > res.txt
		fi
		#cut -d " " -f 2 newtemp.txt > res.txt
		

			#statements
	else
		let var=$var-1
		echo "$var" | cat > res2.txt
		flagPlaylistf=`head -n 1 flagPlaylist`
		if test $flagPlaylistf -eq 1
		then
			head -n $var CurrentPlaylist.list | tail -1 > res.txt
		else
			head -n $var songList.list | tail -1 > newtemp.txt 
		#cut -d " " -f 2 newtemp.txt > res.txt
			cut -c 8- newtemp.txt > res.txt
		fi
	
	fi

	clear
	yad --width=1300 --posx=10 --posy=1000 --text "Now Playing: $var $currSong" --button=Previous:1 --button=Play:2 --button=Next:3 --button=Stop:4 --undecorated --buttons-layout=center
	choice=$?
	
	;;	
	
	2)
	
	if test $alt -eq 1
		then
		temp=$SECONDS
		let pausedAt=$temp-$waitTime
		kill %$count
		
		clear
		yad --width=1300 --posx=10 --posy=1000 --text "Now Playing: $var $currSong" --button=Previous:1 --button=Play:2 --button=Next:3 --button=Stop:4 --undecorated --buttons-layout=center
		choice=$?
		let alt=0
	
	else
		if test $isPlayOne -eq 0;then
			isPlayOne=1
			SECONDS=0
		fi
		let count=$count+1
		let x=$SECONDS-$temp
		let waitTime=$waitTime+$x
		
		mplayer -really-quiet -ss $pausedAt $currSong &
		clear
		yad --width=1300 --posx=10 --posy=1000 --text "Now Playing: $var $currSong" --button=Previous:1 --button=Pause:2 --button=Next:3 --button=Stop:4 --undecorated --buttons-layout=center
		choice=$?
		let alt=1
	fi
	;;
	
	3)
	isPlayOne=0
	waitTime=0
	playTime=0
	pausedAt=0
	x=0
	temp=0
	alt=0
	wc -l songList.list > var.list
	maxLines=$( cut -d " " -f 1 var.list )
	flagPlaylistf=`head -n 1 flagPlaylist`
	if test $flagPlaylistf -eq 1
	then
			wc -l CurrentPlaylist.list > new
			tr '\040' '\011' < new > new1
			maxLines=$(cut -f1 new1)
	fi

	if [ $var -eq $maxLines ];then
		
		let var=1
		echo "$var" | cat > res2.txt
		flagPlaylistf=`head -n 1 flagPlaylist`
		if test $flagPlaylistf -eq 1
		then

			head -n $var CurrentPlaylist.list | tail -1 > res.txt
		else
			head -n $var songList.list | tail -1 > newtemp.txt 
			cut -c 8- newtemp.txt > res.txt
		fi
			#statements
	else
		let var=$var+1
		echo "$var" | cat > res2.txt
		flagPlaylistf=`head -n 1 flagPlaylist`
		if test $flagPlaylistf -eq 1
		then
			head -n $var CurrentPlaylist.list | tail -1 > res.txt
		else
			head -n $var songList.list | tail -1 > newtemp.txt 
		#cut -d " " -f 2 newtemp.txt > res.txt
			cut -c 8- newtemp.txt > res.txt
		fi
	fi

	clear
	yad --width=1300 --posx=10 --posy=1000 --text "Now Playing: $var $currSong " --button=Previous:1 --button=Play:2 --button=Next:3 --button=Stop:4 --undecorated --buttons-layout=center
	choice=$?
	
	;;	

	4)


	kill %$count

	#re-initalize for new song to play
	isPlayOne=0
	waitTime=0
	playTime=0
	pausedAt=0
	x=0
	temp=0
	alt=0
	
	yad --width=1300 --posx=10 --posy=1000 --text "Now Playing: $ var $currSong " --button=Previous:1 --button=Play:2 --button=Next:3 --button=Stop:4 --undecorated --buttons-layout=center
	choice=$?
	;;
	
esac
done

) &

#Volume buttoon
(
while [ 1 -eq 1 ]
do
	a=$(yad --posx=1400 --posy=1000 --width=200 --title="Volume" --scale --undecorated)
	amixer set Master $a%
done
) &

#Sub-shell for Quit Button
yad --posx=1800 --height=70  --button=Quit:1 --undecorated
quitChoice=$?
if test $quitChoice -eq 1
then
	ps -h -o pid | cat > toKill.txt
	killVar=$(cat toKill.txt)
	kill -9 $killVar
fi
