#! /bin/bash
#
#     ▗▖               ▄▄
#     ▐▌              ▐▛▀
#▐▌ ▐▌▐▙█▙  ▟█▙  █▟█▌▐███ ▐▌ ▐▌▐███▌▐███▌
#▐▌ ▐▌▐▛ ▜▌▐▙▄▟▌ █▘   ▐▌  ▐▌ ▐▌  ▗▛   ▗▛
#▐▌ ▐▌▐▌ ▐▌▐▛▀▀▘ █    ▐▌  ▐▌ ▐▌ ▗▛   ▗▛
#▐▙▄█▌▐█▄█▘▝█▄▄▌ █    ▐▌  ▐▙▄█▌▗█▄▄▖▗█▄▄▖
# ▀▀▝▘▝▘▀▘  ▝▀▀  ▀    ▝▘   ▀▀▝▘▝▀▀▀▘▝▀▀▀▘
#
#
# Fuzzy Finder File Manager
# Created by Christos Angelopoulos in 2021, under GNU GENERAL PUBLIC LICENSE
#load config variables from config file
declare -A V
TOTAL="$(cat $HOME/.config/uberfuzz/uberfuzz.conf|wc -l)"
i=1
while [ $i -le $TOTAL ]
do
		VARIABLE[$i]="$(cat $HOME/.config/uberfuzz/uberfuzz.conf|head -$i|tail +$i|awk '{print $1}')"
		CONF[$i]="$(cat $HOME/.config/uberfuzz/uberfuzz.conf|head -$i|tail +$i|awk '{print $2}')"
		V["${VARIABLE[$i]}"]="${CONF[$i]}"
		((i++))
done
#load previously chosen theme
export FZF_DEFAULT_OPTS="$(cat $HOME/commands/uberfuzz/current_theme.txt)"
#define background and foreground color for kitty
export BACKGROUNDCOLOR="$(cat $HOME/commands/uberfuzz/current_theme.txt|sed 's/^.*,bg://;s/,.*$//')"
#FOREGROUNDCOLOR="$(cat $HOME/commands/uberfuzz/current_theme.txt|sed 's/^.*,fg://;s/,.*$//')"
#kitty @ set-colors background="$BACKGROUNDCOLOR" #foreground="$FOREGROUNDCOLOR"
#write 3 welcome lines to log.txt
echo -e "$(date +%A\ %e\ %B\ %T)""\nWelcome to the FuzzyFinder File Manager\nNeed Help? Press ctrl - h">>$HOME/commands/uberfuzz/log.txt
#zeroing FUNCTIONTIME
FUNCTIONTIME=0
function draw_line(){
#example draw line ╭ 30 ╯Select╰╮
#output ╭───────────────────╯Select╰╮
	X0="$(($2 - 1 - "$(echo $3|wc -m)"))"
	LL=1
	echo -e -n $1
	while [ $LL -le $X0  ]
	do
		echo -e -n "─"
		((LL++))
	done
	echo -e -n $3
 echo
}
function fillout(){
sed 's/$/                                              /g'|sed 's/\(^.\{1,40\}\).*/\1/'|sed 's/^/│/g;s/$/│/g'
}
function boximg(){
draw_line ╭ 43 ╮ ;echo -e "\n\n\n\n\n\n\n\n\n\n\n"|fillout;draw_line ╰ 43 ┬───┬╯
}


######################################################
##   Ueberzug
######################################################
declare -r -x UEBERZUG_FIFO="$(mktemp --dry-run )"
function start_ueberzug {
    mkfifo "${UEBERZUG_FIFO}"
    <"${UEBERZUG_FIFO}" \
        ueberzug layer --parser bash --silent &
    # prevent EOF
    3>"${UEBERZUG_FIFO}" \
        exec
}

function finalise {
    3>&- \
        exec
    &>/dev/null \
        rm "${UEBERZUG_FIFO}"
    &>/dev/null \
        kill $(jobs -p)
}
function draw_preview {
#sample draw_preview 35 35 90 3 /path/image.jpg

    >"${UEBERZUG_FIFO}" declare -A -p cmd=( \
        [action]=add [identifier]="preview" \
        [x]="$1" [y]="$2" \
        [width]="$3" [height]="$4" \
        [scaler]=fit_contain [scaling_position_x]=10 [scaling_position_y]=10 \
        [path]="$5")

}
function draw_icon {
 if [ ! -e $HOME/.cache/uberfuzz/icons/"$BACKGROUNDCOLOR"/ ]
 then
		mkdir $HOME/.cache/uberfuzz/icons/"$BACKGROUNDCOLOR"/
	fi
 if [ ! -e $HOME/.cache/uberfuzz/icons/"$BACKGROUNDCOLOR"/"$5" ]
 then
 	if [ -e $HOME/.cache/uberfuzz/prefer/$5 ]
 	then
 		LOCATED_ICON=$HOME/.cache/uberfuzz/prefer/$5
 	else
 		LOCATED_ICON="$(locate -i $5|grep "256"|grep -v "timeshift"|grep -v "HighContrast"|head -1)"
			if [[ "$LOCATED_ICON" == "" ]]
			then
				echo -e " $5 not found.\n Place prefered icon\nin $HOME/.cache/uberfuzz/icons/prefer/,\n named $5"
			fi
		fi
 convert -thumbnail 256 "$LOCATED_ICON" -background "$BACKGROUNDCOLOR" -flatten $HOME/.cache/uberfuzz/icons/"$BACKGROUNDCOLOR"/"$5";
 fi

    >"${UEBERZUG_FIFO}" declare -A -p cmd=( \
        [action]=add [identifier]="preview" \
        [x]="$1" [y]="$2" \
        [width]="$3" [height]="$4" \
        [scaler]=fit_contain [scaling_position_x]=10 [scaling_position_y]=10 \
        [path]="$HOME/.cache/uberfuzz/icons/$BACKGROUNDCOLOR/$5")

}

export -f draw_preview draw_line fillout boximg finalise start_ueberzug draw_icon

######################################################
cd
#main loop
	while true
	do
	finalise
	start_ueberzug
	P="$(ls -a|fzf \
	--header="$PWD"  \
	--layout=reverse \
	--height=100% \
	--prompt="Go: " \
	--preview-window=70% \
	--bind=right:accept \
	--bind=ctrl-a:select-all+top+toggle+down+toggle+down \
	--bind=ctrl-alt-a:deselect-all \
	--tabstop=1 \
	--no-margin  \
	-m \
	-i \
	--exact \
	--expect=ctrl-o,ctrl-alt-o,ctrl-c,ctrl-v,ctrl-x,ctrl-d,ctrl-r,ctrl-z,alt-z,left,ctrl-h,ctrl-y,ctrl-u,alt-1,alt-2,alt-3,alt-4,alt-5,alt-6,alt-7,alt-8,alt-a,alt-v,alt-c,alt-b,ctrl-n,ctrl-alt-n,space,ctrl-t \
	--preview='if [ "$FZF_PREVIEW_LINES" -ge 20 ] ; then LOGLINES=3 ; else LOGLINES=1; fi \
	;if [[ "$FZF_PREVIEW_COLUMNS" -ge 77 ]] \
	;then  X="$(( (( "$FZF_PREVIEW_COLUMNS" * 7/10 )) - (( "$FZF_PREVIEW_COLUMNS" * 3/10 )) + 50 ))";Y="3";MAXW=$((34 + (($X - 80))*2));MAXH=$(( "$FZF_PREVIEW_LINES" -3 ));fi \
	;if [[ "$FZF_PREVIEW_COLUMNS" -le 33 ]] \
	;then X="19";Y="2";MAXW="39";MAXH="12";boximg;fi \
	;if [[ "$FZF_PREVIEW_COLUMNS" -gt 33 ]] && [[ "$FZF_PREVIEW_COLUMNS" -lt 77 ]] \
	;then X="$(( (( "$FZF_PREVIEW_COLUMNS" * 7/10 )) - (( "$FZF_PREVIEW_COLUMNS" * 3/10 )) + 7 ))";Y="2";MAXW="39";MAXH="12";boximg \
	;fi \
	;draw_line ╭ 43 ╯Log╰╮ \
	;cat $HOME/commands/uberfuzz/log.txt|tail -$LOGLINES|fillout \
	; draw_line ╰ 43 ┬─────────┬╯ \
	; if [[ -d {} ]] \
	; then draw_icon $X $Y $MAXW $MAXH /folder.png && draw_line ╭ 43 ╯Selection╰╮ \
	; echo  "Folder {}"|fillout \
	; echo -e "Size     :"$(du -h -c --exclude=.dbus --exclude=.gvfs --exclude=.cache {}|grep "total"|sed "s/\s.*$//g")""|fillout; echo -e "Contents :"$(ls {}|wc -l)""|fillout;draw_line ╰ 43 ┬────────┬╯ \
	; draw_line ╭ 43 ╯Contents╰╮ &&ls  {} -1|fillout \
	; draw_line ╰ 43 ╯ \
	; elif [[ -f {} ]] \
	; then draw_line ╭ 43 ╯Selection╰╮ \
	; echo -e "File {}"|fillout \
	; draw_line ╰ 43 ┬──────────┬╯ \
	; draw_line ╭ 43 ╯Properties╰╮ &&  echo -e "Mode :"$(ls -l {} |sed "s/ .*//")|fillout && i={} \
	; echo -e "Type :"${i##*.}|fillout && echo -e "Size :" $(ls -shQ {}|sed "s/ .*$//g")|fillout && echo -e "Date :" $(stat -c '%y' {} |sed "s/ .*$//")|fillout && echo -e "Owner:" $(stat --printf='%U' {})|fillout &&  echo -e "Group:" $(stat --printf='%G' {})|fillout && echo -e "Name :" {}|fillout && draw_line ╰ 43 ╯ \
	; if [[ {} == *".jpg" ]] || [[ {} == *".jpeg" ]] ||[[ {} == *".png" ]] || [[ {} == *".svg" ]] ||[[ {} == *".JPG" ]] || [[ {} == *".JPEG" ]] \
	; then if [ ! -e $HOME/.cache/uberfuzz/thumbnails/"$(shasum {})".png ] && [ -s {} ]; then 	convert -thumbnail x362 {}  $HOME/.cache/uberfuzz/thumbnails/"$(shasum {})".png \
	;	fi \
 ;draw_preview $X $Y $MAXW $MAXH $HOME/.cache/uberfuzz/thumbnails/"$(shasum {})".png \
	;elif [[ {} == *".wav" ]] || [[ {} == *".WAV" ]] || [[ {} == *".mp3" ]] ||[[ {} == *".mpeg3" ]] ||[[ {} == *".m3u" ]] || [[ {} == *".flac" ]] || [[ {} == *".opus" ]] || [[ {} == *".best" ]] || [[ {} == *".aac" ]] ||[[ {} == *".ogg" ]] || [[ {} == *".midi" ]] || [[ {} == *".m4a" ]] || [[ {} == *".m4b" ]] \
	;then draw_icon $X $Y $MAXW $MAXH headphones.png; elif [[ {} == *".mpeg" ]]  || [[ {} == *".gif" ]]|| [[ {} == *".mpg" ]] || [[ {} == *".mp4" ]] || [[ {} == *".flv" ]] || [[ {} == *".webm" ]] || [[ {} == *".mkv" ]] || [[ {} == *".avi" ]] ||[[ {} == *".mov" ]] || [[ {} == *".wmv" ]] || [[ {} == *".ape" ]] || [[ {} == *".3gp" ]]\
	; then if [ ! -e $HOME/.cache/uberfuzz/thumbnails/{}.png ] && [ -s {} ] \
	; then ffmpegthumbnailer -i {} -s 256 -o  $HOME/.cache/uberfuzz/thumbnails/{}.png \
	;	fi \
	; draw_preview $X $Y $MAXW $MAXH $HOME/.cache/uberfuzz/thumbnails/{}.png \
	; elif [[ {} == *".exe" ]] || [[ {} == *".sh" ]] \
	;then draw_icon $X $Y $MAXW $MAXH exec.png && draw_line ╭ 43 ╮ && cat {}|fillout && draw_line ╰ 43 ╯ \
	; elif [[ {} == *".txt" ]]||[[ {} == *".epub" ]]||[[ {} == *".desktop" ]]||[[ {} == *".md" ]]||[[ {} == *".xml" ]] \
	;then draw_icon $X $Y $MAXW $MAXH txt.png   \
	; draw_line ╭ 43 ╮ \
	; cat {}|fillout \
	; draw_line ╰ 43 ╯ \
	; elif [[ {} == *".json" ]] \
	; then draw_line ╭ 43 ╮ \
	; cat {}|fillout \
	; echo;draw_line ╰ 43 ╯	\
	; elif [[ {} == *".doc" ]] || [[ {} == *".docx" ]] || [[ {} == *".odt" ]] || [[ {} == *".abw" ]]  || [[ {} == *".rtf" ]] \
	 ; then  draw_icon $X $Y $MAXW $MAXH libreoffice-writer.png   && if  [[ {} == *".odt" ]]  \
	 ; then draw_line ╭ 43 ╮ && odt2txt {}|fillout && draw_line ╰ 43 ╯ \
	 ;	elif  [[ {} == *".doc" ]]||[[ {} == *".docx" ]]||[[ {} == *".rtf" ]] \
	 ; then draw_line ╭ 43 ╮ && catdoc {}|fillout && draw_line ╰ 43 ╯ \
	 ;fi \
	 ;elif [[ {} == *".ods" ]] || [[ {} == *".xls" ]] || [[ {} == *".xlsx" ]] \
	 ; then  draw_icon $X $Y $MAXW $MAXH libreoffice-calc.png   \
	 ;	elif [[ {} == *".ppt" ]] || [[ {} == *".pptx" ]] || [[ {} == *".pps" ]] || [[ {} == *".odp" ]] || [[ {} == *".odg" ]] || [[ {} == *".uop" ]]\
	 ; then  draw_icon $X $Y $MAXW $MAXH libreoffice-impress.png   \
	 ; elif [[ {} == *".pdf" ]]  \
	; then if [ ! -e $HOME/.cache/uberfuzz/thumbnails/"$(shasum {})".png ] && [ -s {} ] \
	; then pdftoppm -f 1 -l 1 -scale-to-x 256  -scale-to-y -1  -singlefile  -png -tiffcompression png {}  $HOME/.cache/uberfuzz/thumbnails/"$(shasum {})" ;	fi \
	;draw_preview $X $Y $MAXW $MAXH $HOME/.cache/uberfuzz/thumbnails/"$(shasum {})".png \
	; draw_line ╭ 43 ╮ \
	; pdftotext -l 3 {} -|fillout \
	; echo;draw_line ╰ 43 ╯ \
	 ; elif [[ {} == *".html" ]] \
	 ;then draw_icon $X $Y $MAXW $MAXH html.png && draw_line ╭ 43 ╮ && cat {}|fillout && draw_line ╰ 43 ╯ \
	 ; elif [[ {} == *".deb" ]] || [[ {} == *".tar" ]] ||[[ {} == *".gz" ]] || [[ {} == *".zip" ]]  || [[ {} == *".rar" ]] \
		; then draw_icon $X $Y $MAXW $MAXH gzip.png \
	 ; else draw_icon $X $Y $MAXW $MAXH txt.png \
	 ; fi ;fi ' )"
	#========================== TIMESTAMP DEFINITION ====================================
	TIMESTAMP=$(date +%s)
	#========================== NAME OF FILE OR DIRECTORY ===============================
	PP="$(echo "$P"|tail +2)"
	#========================== MULTI SELECTION =========================================
	echo "$P">$HOME/commands/uberfuzz/P.txt
	echo "$PP">$HOME/commands/uberfuzz/PP.txt
	TOTAL="$(echo "$PP"|wc -l)"
	i=1
	while [ $i -le $TOTAL ]
	do
	#======================= IMPORTANT =================================================
				LINE="$(cat $HOME/commands/uberfuzz/PP.txt|head -$i|tail +$i)"
	#======================= DIRECTORY PARSING =========================================
				if [[ -d "$LINE" ]] &&  [[ "$(echo "$P"|head -1)" = "" ]]
				then
					cd "$LINE"
					echo "MOVED to ""$PWD">>$HOME/commands/uberfuzz/log.txt
				fi
				#==================== FILE PARSING ==============================================
				if [[ -f "$LINE" ]]
				then
				#==================== Definition of file EXTENSION ==============================
					EXTENSION=$(echo "$LINE"|sed 's/^.*\.//')
					if [ $EXTENSION = txt ] || [ -z $EXTENSION ] || [ $EXTENSION = sh ] || [ $EXTENSION = css ] || [ $EXTENSION = json ] || [ $EXTENSION = md ] || [ $EXTENSION = xml ]
					then
						case $(echo "$P"|head -1) in
						 "${V[_OPEN-WITH_]}")				APP="$(grep "_TEXT_APP" $HOME/.config/uberfuzz/uberfuzz.conf|awk '{print $2}'|fzf	--layout=reverse	 --height=100% 	--preview-window=40%:noborder --preview='Y="3";MAXW=$(("$FZF_PREVIEW_COLUMNS"/2)); MAXH=$(("$FZF_PREVIEW_COLUMNS"/2)) ;X=$(("$FZF_PREVIEW_COLUMNS"*10/6));draw_icon $X $Y $MAXW $MAXH {}.png'	--border -i --prompt="Open with: ")";	echo "Opened "$LINE" with "$APP"">>$HOME/commands/uberfuzz/log.txt;	"$APP" "$LINE"
						 ;;
						 "")	eval ${V[_DEFAULTTEXT_APP_]} "$LINE" &	echo "Opened "$LINE" with "${V[_DEFAULTTEXT_APP_]}"">>$HOME/commands/uberfuzz/log.txt
						 ;;
						esac
					elif [ $EXTENSION = wav ]||[ $EXTENSION = mp3 ]||[ $EXTENSION = m3u ]||[ $EXTENSION = flac ]||[ $EXTENSION = opus ]||[ $EXTENSION = best ]||[ $EXTENSION = aac ]||[ $EXTENSION = ogg ]||[ $EXTENSION = midi ]||[ $EXTENSION = m4a ]||[ $EXTENSION = WAV ]||[ $EXTENSION = mpeg3 ]||[ $EXTENSION = m4b ]
					then
						if [[ "$(echo "$P"|head -1)" == "${V[_OPEN-WITH_]}" ]]
						then
							APP="$(grep "_MEDIA_APP" $HOME/.config/uberfuzz/uberfuzz.conf|awk '{print $2}'|fzf	--layout=reverse	 --height=100% 	--preview-window=40%:noborder --preview='Y="3";MAXW=$(("$FZF_PREVIEW_COLUMNS"/2)); MAXH=$(("$FZF_PREVIEW_COLUMNS"/2)) ;X=$(("$FZF_PREVIEW_COLUMNS"*10/6));  draw_icon $X $Y $MAXW $MAXH {}.png'	--border -i --prompt="Open with: ")"
							finalise
							"$APP" "$LINE"
							echo "Opened "$LINE" with "$APP"">>$HOME/commands/uberfuzz/log.txt
						elif [[ "$(echo "$P"|head -1)" = "" ]]
						then
							finalise
							cat $HOME/.config/uberfuzz/audio_shortcuts.txt
							${V[_DEFAUDIO_APP_]} "$LINE"
							echo "Opened "$LINE" with "${V[_DEFAUDIO_APP_]}"">>$HOME/commands/uberfuzz/log.txt
						fi

					elif [ $EXTENSION = mpeg ]||[ $EXTENSION = mp4 ]||[ $EXTENSION = flv ]||[ $EXTENSION = webm ]||[ $EXTENSION = mkv ]||[ $EXTENSION = avi ]||[ $EXTENSION = mov ]||[ $EXTENSION = wmv ]||[ $EXTENSION = ape ]||[ $EXTENSION = mpg ]||[ $EXTENSION = 3gp ]
					then
						if [[ "$(echo "$P"|head -1)" == "${V[_OPEN-WITH_]}" ]]
						then
							APP="$(grep "_MEDIA_APP" $HOME/.config/uberfuzz/uberfuzz.conf|awk '{print $2}'|fzf	--layout=reverse	 --height=100% 	--preview-window=40%:noborder --preview='Y="3";MAXW=$(("$FZF_PREVIEW_COLUMNS"/2)); MAXH=$(("$FZF_PREVIEW_COLUMNS"/2)) ;X=$(("$FZF_PREVIEW_COLUMNS"*10/6)); draw_icon $X $Y $MAXW $MAXH {}.png'	--border -i --prompt="Open with: ")"
							"$APP" "$LINE"
							echo "Opened "$LINE" with "$APP"">>$HOME/commands/uberfuzz/log.txt
						elif [[ "$(echo "$P"|head -1)" = "" ]]
						then
							finalise
							cat $HOME/.config/uberfuzz/video_shortcuts.txt
							${V[_DEFVIDEO_APP_]} "$LINE"
							echo "Opened "$LINE" with "${V[_DEFVIDEO_APP_]}"">>$HOME/commands/uberfuzz/log.txt
						fi

					elif [ $EXTENSION = png ]||[ $EXTENSION = gif ]||[ $EXTENSION = jpg ]||[ $EXTENSION = jpeg ]||[ $EXTENSION = svg ]||[ $EXTENSION = JPG ]||[ $EXTENSION = JPEG ]
					then
						case "$(echo "$P"|head -1)" in
						"${V[_OPEN-WITH_]}" )	APP="$(grep "_IMAGE_APP" $HOME/.config/uberfuzz/uberfuzz.conf|awk '{print $2}'|fzf	--layout=reverse	 --height=100% 	--preview-window=40%:noborder --preview='Y="3";MAXW=$(("$FZF_PREVIEW_COLUMNS"/2)); MAXH=$(("$FZF_PREVIEW_COLUMNS"/2)) ;X=$(("$FZF_PREVIEW_COLUMNS"*10/6));draw_icon $X $Y $MAXW $MAXH {}.png'	--border -i --prompt="Open with: ")"
							eval "$APP" "$LINE" &
							echo "Opened "$LINE" with "$APP"">>$HOME/commands/uberfuzz/log.txt
							;;
						"" )	eval "${V[_DEFIMAGE_APP_]}" '"$LINE"'
							echo "Opened "$LINE" with "${V[_DEFIMAGE_APP_]}"">>$HOME/commands/uberfuzz/log.txt
						;;
					esac
					elif [ $EXTENSION = xcf ]
					then
						if [[ "$(echo "$P"|head -1)" = "" ]]
						then
								gimp "$LINE" &
								echo "Opened "$LINE" with gimp">>$HOME/commands/uberfuzz/log.txt
						fi
					elif [ $EXTENSION = srt ]
					then
						if [[ "$(echo "$P"|head -1)" = "" ]]
						then
								eval ${V[_SUB_EDITOR_]} "$LINE" &
								echo "Opened "$LINE" with "${V[_SUB_EDITOR_]}"">>$HOME/commands/uberfuzz/log.txt
						fi
					elif [ $EXTENSION = doc ]||[ $EXTENSION = docx ]||[ $EXTENSION = odt ]||[ $EXTENSION = abw ]||[ $EXTENSION = ods ]||[ $EXTENSION = xls ]||[ $EXTENSION = xlsx ]||[ $EXTENSION = ppt ]||[ $EXTENSION = pptx ]||[ $EXTENSION = pps ]||[ $EXTENSION = ppsx ]||[ $EXTENSION = odp ]||[ $EXTENSION = rtf ]
					then
						if [[ "$(echo "$P"|head -1)" = "" ]]
						then
								eval ${V[_DEF_OFFICE_]} "$LINE" &
								echo "Opened "$LINE" with "${V[_DEF_OFFICE_]}"">>$HOME/commands/uberfuzz/log.txt
						fi
					elif [ $EXTENSION = pdf ]||[ $EXTENSION = epub ]
					then
						if [[ "$(echo "$P"|head -1)" = "" ]]
						then
								eval ${V[_DEF_PDF_]} '"$LINE"' &
								echo "Opened "$LINE" with "${V[_DEF_PDF_]}"">>$HOME/commands/uberfuzz/log.txt
						fi
					elif [ $EXTENSION = html ]
					then
						if [[ "$(echo "$P"|head -1)" == "${V[_OPEN-WITH_]}" ]]
						then
							APP="$(grep "_BROWSER" $HOME/.config/uberfuzz/uberfuzz.conf|awk '{print $2}'|fzf	--layout=reverse	 --height=100% 	--preview-window=40%:noborder --preview='Y="3";MAXW=$(("$FZF_PREVIEW_COLUMNS"/2)); MAXH=$(("$FZF_PREVIEW_COLUMNS"/2)) ;X=$(("$FZF_PREVIEW_COLUMNS"*10/6)); draw_icon $X $Y $MAXW $MAXH {}.png'	--border -i --prompt="Open with: ")"
							echo "Opened "$LINE" with "$APP""	>>$HOME/commands/uberfuzz/log.txt
							eval "$APP" "$LINE"&
						elif [[ "$(echo "$P"|head -1)" = "" ]]
						then
								"${V[_DBROWSER_]}" "$LINE"
								echo "Opened "$LINE" with "${V[_DBROWSER_]}"">>$HOME/commands/uberfuzz/log.txt
						fi
					elif 	[[ "$(echo "$P"|head -1)" = "" ]]
					then
						APP="$(ls /usr/share/|fzf	--layout=reverse	 --height=100% 	--preview-window=40%:noborder --preview='Y="3";MAXW=$(("$FZF_PREVIEW_COLUMNS"/2)); MAXH=$(("$FZF_PREVIEW_COLUMNS"/2)) ;X=$(("$FZF_PREVIEW_COLUMNS"*10/6)); draw_icon $X $Y $MAXW $MAXH gnome-system.png'	--border -i --prompt="Open with: ")"
							echo "Opened "$LINE" with "$APP""	>>$HOME/commands/uberfuzz/log.txt
							 "$APP" "$LINE"
					fi
				fi
				#==================== SHORTCUTS ==================================================

						#================== DEFINING COPY function ctrl-c ===============================
						case  "$(echo "$P"|head -1)" in
							"${V[_COPY_]}")	if [ $TIMESTAMP != $FUNCTIONTIME ]
							then
								#ERASE CUT.txt contents
								sed -i 'd' $HOME/commands/uberfuzz/CUT.txt
								#ERASE COPY.txt CONTENTS
								sed -i 'd' $HOME/commands/uberfuzz/COPY.txt
								FUNCTIONTIME=$TIMESTAMP
							fi
							#make sure neither . nor .. are parsed
							if [ "$LINE" != "." ] && [ "$LINE" != ".." ] && [ "$LINE" != "" ]
							then
								#write "$LINE" to COPY.txt
								echo "$(realpath "$LINE")">>$HOME/commands/uberfuzz/COPY.txt
								#write to log.txt
								echo "COPY :""$LINE">>$HOME/commands/uberfuzz/log.txt
							else
								echo "ABORT: Cannot copy '.' '..' or ''">>$HOME/commands/uberfuzz/log.txt
							fi
							;;

						#================== DEFINING PASTE function ctrl-v ===============================
						"${V[_PASTE_]}" ) #make sure that $LINE is a DIRECTORY and NOT a file
										if [ -d "$LINE" ]
										then


												#renaming . and .. directories
												if [ "$LINE" = "." ]

												then
													LINE="$PWD"
													echo "LINE=""$LINE">>$HOME/commands/uberfuzz/log.txt
												fi
												if [ "$LINE" = ".." ]
												then
													LINE="$(dirname "$PWD")"
													echo "LINE=""$LINE">>$HOME/commands/uberfuzz/log.txt
												fi
												#check if COPY.txt is not empty
												if [ "$(cat $HOME/commands/uberfuzz/COPY.txt|wc -l)" != 0 ]
												then
														#parse COPY.txt contents
														COPYLINES="$(cat $HOME/commands/uberfuzz/COPY.txt|wc -l)"
														s=1
														while [ $s -le "$COPYLINES" ]
														do
																COPIED="$(cat $HOME/commands/uberfuzz/COPY.txt|head -$s|tail +$s)"
																#again make sure no "." ".." "" are parsed
																if [ "$COPIED" != "." ] && [ "$COPIED" != ".." ] && [ "$COPIED" != "" ]
																then
																		#define name of File/dir to be pasted
																		PASTED="$(echo "$COPIED"|sed 's/^.*\///g')"
																		f=1
																		#if file already exists, rename it as "copy of"
																		while [[ -f "$COPIED" && -f "$LINE""/""$PASTED" ]] || [[ -d "$COPIED" && -d "$LINE""/""$PASTED" ]]
																		do
																			PASTED="copy ""$f"" of ""$(echo "$COPIED"|sed 's/^.*\///g')"
																			((f++))
																		done
																		cp -r "$COPIED" "$LINE""/""$PASTED"|while [ "$(ls -s --block-size=K "$LINE""/""$PASTED"|sed 's/K.*$//g')"  -lt "$(ls -s --block-size=K "$COPIED"|sed 's/K.*$//g')" ] ; do M0="$(ls -s --block-size=M "$LINE""/""$PASTED"|awk '{print $1}'|sed 's/M.*$//g')";sleep 2;M1="$(ls -s --block-size=M "$LINE""/""$PASTED"|sed 's/M.*$//g')";echo -e -n "Copied  "$(ls -s --block-size=M "$LINE""/""$PASTED"|awk '{print $1}')" of "$(ls -s --block-size=M "$COPIED"|awk '{print $1}')   "$(( ($M1 - $M0) / 2 ))" M/sec "\r "; ((n++));done;echo "*Copied "$COPIED"."
																		echo "PASTED "$PASTED" to "$LINE"">>$HOME/commands/uberfuzz/log.txt
																else
																		echo "ABORT: Cannot paste '.' '..' or ''">>$HOME/commands/uberfuzz/log.txt
																fi
																((s++))
														done
												elif [ "$(cat $HOME/commands/uberfuzz/CUT.txt|wc -l)" != 0 ]
												then
														#parse CUT.txt
														CUTLINES="$(cat $HOME/commands/uberfuzz/CUT.txt|wc -l)"
														s=1
														while [ $s -le "$CUTLINES" ]
														do

																CUT="$(cat $HOME/commands/uberfuzz/CUT.txt|head -$s|tail +$s)"

																#again make sure no "." ".." "" are parsed
																if [ "$CUT" != "." ] && [ "$CUT" != ".." ] && [ "$CUT" != "" ]
																then
																		#define name of File/dir to be pasted
																		PASTED="$(echo "$CUT"|sed 's/^.*\///g')"

																		f=1
																		#if file already exists, rename it as "copy of"
																		while [[ -f "$CUT" && -f "$LINE""/""$PASTED" ]] || [[ -d "$CUT" && -d "$LINE""/""$PASTED" ]]
																		do
																			PASTED="copy ""$f"" of ""$(echo "$COPIED"|sed 's/^.*\///g')"
																			((f++))
																		done
																		mv "$CUT" "$LINE""/""$PASTED"
																		#copy copied address to COPY.txt (for future copying)
																		echo "$(realpath	"$LINE")""/""$PASTED">>$HOME/commands/uberfuzz/COPY.txt

																		echo "PASTED "$PASTED" to "$LINE"">>$HOME/commands/uberfuzz/log.txt
																else
																		echo "ABORT: Cannot paste '.' '..' or ''.">>$HOME/commands/uberfuzz/log.txt
																fi
																((s++))
														done
														#erase CUT.txt content (already copied to COPY.txt)
														sed -i 'd' $HOME/commands/uberfuzz/CUT.txt
												fi

										else
										 echo "Cannot paste to ""$LINE"". It's a file">>$HOME/commands/uberfuzz/log.txt
										fi
										;;

						#================== DEFINING CUT function ctrl-x =================================
						"${V[_CUT_]}")		#specify if LINE belongs to the same selection with the previous LINE
							if [ $TIMESTAMP != $FUNCTIONTIME ]
							then
								sed -i 'd' $HOME/commands/uberfuzz/CUT.txt
								#ERASE CLIP CONTENTS
								sed -i 'd' $HOME/commands/uberfuzz/COPY.txt
								FUNCTIONTIME=$TIMESTAMP
							fi

							#make sure neither "." nor ".." or "" are parsed
							if [ "$LINE" != "." ] && [ "$LINE" != ".." ] && [ "$LINE" != "" ]
							then
								#write "$LINE" to CUT.txt
								echo "$(realpath "$LINE")">>$HOME/commands/uberfuzz/CUT.txt
								#write to log.txt
								echo "CUT :""$LINE">>$HOME/commands/uberfuzz/log.txt
							else
								echo "ABORT: Cannot cut '.' '..' or ''">>$HOME/commands/uberfuzz/log.txt
							fi
							;;
						#================== DEFINING DELETE function ctrl-d ==============================
						"${V[_DELETE_]}" )
						##Uncomment if you want to be prompted for each file before deleting
							#echo "*** DELETE "$LINE" and move it to the TRASH? (y/n)"
							#read REPLY
							#if [ "$REPLY" == "y" ]
							#then
									if [ "$LINE" != "." ] && [ "$LINE" != ".." ] && [ "$LINE" != "" ]
									then
											if [[ -e $HOME/.local/share/Trash/files/"$LINE" ]] || [[ -d $HOME/.local/share/Trash/files/"$LINE" ]]
											then
												mv -v $HOME/.local/share/Trash/files/"$LINE" $HOME/.local/share/Trash/files/"$LINE"_$RANDOM
											fi
											mv -v "$LINE" $HOME/.local/share/Trash/files/
										echo "DELETED ""$LINE">>$HOME/commands/uberfuzz/log.txt
									else
										echo "ABORT: Attempted to delete invalid file('.', '..' or '')"
									fi
							#fi
							;;
						#================== DEFINING RENAME function ctrl-r ===============================
						"${V[_RENAME_]}" )
								if [ "$LINE" != "." ] && [ "$LINE" != ".." ]
								then
									echo "Give a new name to rename ""$LINE" ":"
									read NEWNAME
									if [ "$NEWNAME" != "" ]	&& [ "$NEWNAME" != "." ] && [ "$NEWNAME" != ".." ]
									then
											echo "RENAME "$LINE" as "$NEWNAME"? (y or Enter/n)"
											read REPLY


											if [ "$REPLY" == "y" ] || [ "$REPLY" == "" ]
											then

												if [ -e "$NEWNAME" ]
												then
													echo "ABORTED: Name already exists.">>$HOME/commands/uberfuzz/log.txt
												else
													mv "$LINE" "$NEWNAME"
													echo "RENAMED "$LINE"  as " "$NEWNAME">>$HOME/commands/uberfuzz/log.txt
												fi
											else
											echo "RENAME ABORTED.Invalid name.">>$HOME/commands/uberfuzz/log.txt
											fi
									else
										echo "ABORTED, Invalid name.">>$HOME/commands/uberfuzz/log.txt
									fi
								fi
								;;
						#================= DEFINING HELP function ctrl-h ====================================
						"${V[_HELP_]}" )	clear
							H="$(cat $HOME/.config/uberfuzz/uberfuzz.conf|sed 's/_ / : /g;s/_//g'|fzf	--header="*** SHORTCUTS USED IN FZFFM ***"	--layout=reverse	--border --preview-window=30%:noborder --preview='Y="3";MAXW=$(("$FZF_PREVIEW_COLUMNS"/2)); MAXH=$(("$FZF_PREVIEW_COLUMNS"/2)) ;X=$(("$FZF_PREVIEW_COLUMNS"*10/4));draw_icon $X $Y $MAXW $MAXH keyboard-shortcuts.png')"
							;;
						#====================== DEFINING EMPTY TRASH function ctrl-z =======================
						"${V[_EMPTY-TRASH_]}" )
						echo "*** TRASH contains :"
							echo "$(ls -A $HOME/.local/share/Trash/files/)"
							echo "*** EMPTY TRASH? Are you SURE? (y/n)"
							read REPLY
							if [ "$REPLY" == "y" ]
							then
							 TOTALTRASHLINES="$(ls -a $HOME/.local/share/Trash/files/|tail +3|wc -l)"
							 TRASHLINENUMBER=1
								while [ $TRASHLINENUMBER -le $TOTALTRASHLINES ]
								do
								 TRASHLINE="$(ls -a $HOME/.local/share/Trash/files/|tail +3|head -1)"
									if [ "$TRASHLINE" != "." ] && [ "$TRASHLINE" != ".." ] && [ "$TRASHLINE" != "" ]
									then
										rm -rv $HOME/.local/share/Trash/files/"$TRASHLINE"
									fi

									((TRASHLINENUMBER++))
								done
								echo "TRASH EMPTIED.">>$HOME/commands/uberfuzz/log.txt
							fi
							;;

						#================= DEFINING COPY NAME function ctrl-y ====================================
						"${V[_COPY-NAME_]}" )
							if [ "$LINE" != "." ] && [ "$LINE" != ".." ] && [ "$LINE" != "" ]
							then
								echo "$LINE">$HOME/commands/uberfuzz/COPYNAME.txt
								echo "COPIED name of ""$LINE">>$HOME/commands/uberfuzz/log.txt
							else
								echo "ABORTED: Invalid Name.">>$HOME/commands/uberfuzz/log.txt
							fi
							;;
						#================= DEFINING PASTE NAME function ctrl-u ====================================
						"${V[_PASTE-NAME_]}" )NEWNAME="$(cat $HOME/commands/uberfuzz/COPYNAME.txt|head -1)"
							if [ "$NEWNAME" != "." ] && [ "$NEWNAME" != ".." ] && [ "$NEWNAME" != "" ] && [ "$LINE" != "." ] && [ "$LINE" != ".." ] && [ "$LINE" != "" ]
							then
								if [ -e "$NEWNAME" ]
								then
									f=1
									#if file already exists, rename it as "copy of"
									while [ -f "$NEWNAME" ] || [ -d "$NEWNAME" ]
									do
											NEWNAME="$f"-"$(cat $HOME/commands/uberfuzz/COPYNAME.txt|head -1)"
											((f++))
									done
								fi
								mv "$LINE" "$NEWNAME"
								echo "RENAMED "$LINE" as ""$NEWNAME"	>>$HOME/commands/uberfuzz/log.txt
							else
								echo "ABORTED: Improper Name or file/directory.">>$HOME/commands/uberfuzz/log.txt
							fi
							;;
						#================= DEFINING MAKE NEW FILE ctrl-n =================================
						"${V[_CREATE-N-FILE_]}" )	read -p "Enter name of new file :" NAME
							if [ -z "$NAME" ]
							then
								echo "Action ABORTED.">>$HOME/commands/uberfuzz/log.txt
							elif [ -f "$PWD""/""$NAME" ]
							then
								echo "ABORTED: Name already in use." >>$HOME/commands/uberfuzz/log.txt
							else
								touch "$NAME"
								echo "CREATED ""$NAME"" file inside ""$PWD">>$HOME/commands/uberfuzz/log.txt
							fi

						;;
						#================= DEFINING SELECT APP function ctrl-alt-o ========================
						"${V[_SELECT-APP_]}" )	APP="$(ls /usr/share/|fzf	--layout=reverse	 --height=100% 	--preview-window=40%:noborder --preview='Y="3";MAXW=$(("$FZF_PREVIEW_COLUMNS"/2)); MAXH=$(("$FZF_PREVIEW_COLUMNS"/2)) ;X=$(("$FZF_PREVIEW_COLUMNS"*10/6)); draw_icon $X $Y $MAXW $MAXH gnome-system.png'	--border -i --prompt="Open with: ")"
							echo "Opened "$LINE" with "$APP""	>>$HOME/commands/uberfuzz/log.txt
							eval "$APP" "$LINE"
						;;
						#================= DEFINING MAKE NEW DIRECTORY ctrl-alt-n =========================
						 "${V[_CREATE-N-DIR_]}" )	read -p "Enter name of new directory :" NAME
							if [ -z "$NAME" ]
							then
								echo "Action ABORTED, enter valid name">>$HOME/commands/uberfuzz/log.txt
							elif [ -d "$PWD""/""$NAME" ]
							then
								echo "ABORTED: Name already in use.">>$HOME/commands/uberfuzz/log.txt
							else
								mkdir "$NAME"
								echo "CREATED ""$NAME"" directory inside ""$PWD">>$HOME/commands/uberfuzz/log.txt
							fi
							;;


						#================= DEFINING MOVE TO HOME Bookmark alt-1 =======================

							"${V[_home_]}")cd;echo "MOVED to ""$PWD">>$HOME/commands/uberfuzz/log.txt
							;;
							#================= DEFINING MOVE TO Desktop Bookmark alt-2 ====================
							"${V[_Desktop_]}")	cd $HOME/Desktop;	echo "MOVED to ""$PWD">>$HOME/commands/uberfuzz/log.txt
							;;
							#================= DEFINING MOVE TO Documents Bookmark alt-3 ==================
							"${V[_Documents_]}") cd $HOME/Documents;echo "MOVED to ""$PWD">>$HOME/commands/uberfuzz/log.txt
							;;
							#================= DEFINING MOVE TO Downloads Bookmark alt-4 ==================
							"${V[_Downloads_]}")	cd $HOME/Downloads;	echo "MOVED to ""$PWD">>$HOME/commands/uberfuzz/log.txt
							;;
							#================= DEFINING MOVE TO Music Bookmark alt-5 ======================
							"${V[_Music_]}")	cd $HOME/Music;	echo "MOVED to ""$PWD">>$HOME/commands/uberfuzz/log.txt
							;;
							#================= DEFINING MOVE TO Pictures Bookmark alt-6 ====================
							"${V[_Pictures_]}")	cd $HOME/Pictures;	echo "MOVED to ""$PWD">>$HOME/commands/uberfuzz/log.txt;
							;;
							#================= DEFINING MOVE TO Videos Bookmark alt-7 =======================
							"${V[_Videos_]}") cd $HOME/Videos;	echo "MOVED to ""$PWD">>$HOME/commands/uberfuzz/log.txt
							;;
							#================= DEFINING MOVE TO COMMANDS Bookmark alt-8 =====================
							"${V[_commands_]}" )	cd $HOME/commands;	echo "MOVED to ""$PWD">>$HOME/commands/uberfuzz/log.txt
							;;
							#================= DEFINING MOVE TO vicky Bookmark alt-v =========================
							"alt-v" )	cd /run/user/1000/gvfs/sftp:host=192.168.1.17,user=vicky/home/vicky;	echo "MOVED to ""$PWD">>$HOME/commands/uberfuzz/log.txt
							;;
							#================= DEFINING MOVE TO athenoula Bookmark alt-a =====================
							"alt-a") run /user/1000/gvfs/sftp/host:192=168.1.5.user,athenoula=home/athenoula/cd;	echo "MOVED to ""$PWD"	>>$HOME/commands/uberfuzz/log.txt
							;;
							#================= DEFINING MOVE TO christakis Bookmark alt-c =====================
							"alt-c")cd /run/user/1000/gvfs/sftp:host=192.168.1.15,user=christakis/home/christakis;	echo "MOVED to ""$PWD">>$HOME/commands/uberfuzz/log.txt
							;;
							#================= DEFINING MOVE BACK Bookmark alt-b =====================
							"${V[_back_]}" )cd -;	echo "MOVED to ""$PWD">>$HOME/commands/uberfuzz/log.txt
							;;
							#================= DEFINING BROWSE TRASH FILE Bookmark alt-z ======================
							"${V[_TRASH_]}" )	cd $HOME/.local/share/Trash/files/;	echo "MOVED to ""$PWD">>$HOME/commands/uberfuzz/log.txt
							;;
							#=================	DEFINING THEME function ctrl-t ===================================
						"${V[_THEME_]}")	T="";
						while [ "$T" != "Exit" ]
						do
							T="$(cat $HOME/.config/uberfuzz/themes.txt | awk '{print $1}'|fzf	--layout=reverse	 --height=100% 	--preview-window=40%:noborder --preview='Y="3";MAXW=$(("$FZF_PREVIEW_COLUMNS"/2)); MAXH=$(("$FZF_PREVIEW_COLUMNS"/2)) ;X=$(("$FZF_PREVIEW_COLUMNS"*10/6));  draw_icon $X $Y $MAXW $MAXH gnome-graphics.png'	--border -i --prompt="Select Theme: ")"
							TC="$(grep "$T" $HOME/.config/uberfuzz/themes.txt|sed 's/^.*  //')"
							if [ "$T" != "Exit" ]
							then
								export FZF_DEFAULT_OPTS="$TC"
								echo "Selected Theme: "$T"">>$HOME/commands/uberfuzz/log.txt
								echo "$FZF_DEFAULT_OPTS">$HOME/commands/uberfuzz/current_theme.txt
								#define background color for gnome-terminal
								BACKGROUNDCOLOR="$(cat $HOME/commands/uberfuzz/current_theme.txt|sed 's/^.*,bg://;s/,.*$//')"
								#FOREGROUNDCOLOR="$(cat $HOME/commands/uberfuzz/current_theme.txt|sed 's/^.*,fg://;s/,.*$//')"
								#kitty @ set-colors background="$BACKGROUNDCOLOR"	#foreground="$FOREGROUNDCOLOR"

							fi
						done
						;;
				#================= DEFINING Going Back one step Keybinding left ===================
				"left" )	cd ..;	echo "MOVED to ""$PWD">>$HOME/commands/uberfuzz/log.txt
				;;
				#================= DEFINING SHELL  space ==========================================
				"${V[_OPENTERMINAL_]}" )	finalise&&gnome-terminal  --wait --working-directory="$PWD"


 			;;
				esac
				((i++))
	done
done
