#! /bin/bash


touch    COPYNAME.txt COPY.txt CUT.txt log.txt  P.txt PP.txt
audio_shortcuts="┌─────────────────────────────────────────────┐
│           MPLAYER AUDIO SHORTCUTS           │
├───────────┬─────────────────────────────────┤
│   ←  →    │ Seek backward/forward 5 seconds │
├───────────┼─────────────────────────────────┤
│   ↑  ↓    │ Seek backward/forward 1 minute  │
├───────────┼─────────────────────────────────┤
│ BACKSPACE │ Reset playback speed to normal  │
├───────────┼─────────────────────────────────┤
│ p / SPACE │ Pause (pressing again unpauses) │
├───────────┼─────────────────────────────────┤
│  q / Q    │ Quit/Store position & quit      │
├───────────┼─────────────────────────────────┤
│  9 / 0    │ Decrease/increase volume        │
├───────────┼─────────────────────────────────┤
│    m      │ Mute sound                      │
└───────────┴─────────────────────────────────┘"
video_shortcuts="┌───────────────────────────────────────────┐
│          XPLAYER VIDEO SHORTCUTS          │
├───────────┬───────────────────────────────┤
│ p / SPACE │ Pause / Play                  │
├───────────┼───────────────────────────────┤
│   ↑  ↓    │ Increase / Decrease volume    │
├───────────┼───────────────────────────────┤
│   ←  →    │ Skip back/forward             │
├───────────┼───────────────────────────────┤
│     q     │ Quit                          │
├───────────┼───────────────────────────────┤
│     f     │ Toggle full screen            │
├───────────┼───────────────────────────────┤
│     s     │ Cycle between sub tracks      │
├───────────┼───────────────────────────────┤
│     m     │ Mute sound                    │
└───────────┴───────────────────────────────┘"



mkdir -p $HOME/.cache/uberfuzz/icons $HOME/.cache/uberfuzz/prefer $HOME/.cache/uberfuzz/thumbnails $HOME/.config/uberfuzz/
touch $HOME/.config/uberfuzz/themes.txt $HOME/.config/uberfuzz/uberfuzz.conf $HOME/.config/uberfuzz/audio_shortcuts.txt $HOME/.config/uberfuzz/video_shortcuts.txt $HOME/.config/uberfuzz/current_theme.txt
themes="Exit
No_Theme
Nordisk  --color=fg:#D8DEE9,bg:#2E3440,hl:#6c6c6c,fg+:#D8DEE9,bg+:#434C5E,hl+:#A3BE8C,pointer:#BF616A,info:#4C566A,spinner:#4C566A,header:#DCD81F,prompt:#81A1C1,marker:#EBCB8B
Molokai  --color=fg:#d0d0d0,bg:#121212,hl:#5f87af,fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff,info:#afaf87,prompt:#d7005f,spinner:#af5fff,pointer:#af5fff,marker:118
Oblivious  --color=fg:#d0d0d0,bg:#2E3436,hl:#5f87af,fg+:#d0d0d0,bg+:#2E3436,hl+:#5fd7ff,info:#afaf87,prompt:#BF616A,spinner:#af5fff,pointer:#BF616A,header:#DCD81F,marker:#EBCB8B
Seoul_256_Night  --color=fg:#6c6c6c,bg:#121212,hl:65,fg+:15,bg+:234,hl+:108,info:108,prompt:109,spinner:108,pointer:168,marker:168
Red_Dark  --color=fg:#af0000,bg:#000000,hl:202,fg+:214,bg+:52,hl+:231,info:52,prompt:196,spinner:208,pointer:196,marker:208
Solarized_Colors  --color=bg+:#073642,bg:#002b36,spinner:#719e07,hl:#586e75,fg:#839496,header:#586e75,info:#cb4b16,pointer:#719e07,marker:#719e07,fg+:#839496,prompt:#719e07,hl+:#719e07
Jellybeans  --color=fg:#d7d7d7,bg:#121212,hl:103,fg+:222,bg+:234,hl+:104,info:183,prompt:110,spinner:107,pointer:167,marker:215
Seoul_Dusk  --color=fg:#6c6c6c,bg:#303030,hl:65,fg+:15,bg+:239,hl+:108,info:108,prompt:109,spinner:108,pointer:168,marker:168
One_Dark  --color=fg:#cbccc6,bg:#1f2430,hl:#bd93f9,fg+:#f8f8f2,bg+:#191e2a,hl+:#ffcc66,info:#73d0ff,prompt:#50fa7b,pointer:#73d0ff,marker:#73d0ff,spinner:#73d0ff,header:#73d0ff
Gruvbox_Dark  --color=fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f,info:#83a598,prompt:#bdae93,spinner:#fabd2f,pointer:#83a598,marker:#fe8019,header:#665c54
Spacecamp  --color=fg:#dedede,bg:#121212,hl:#666666,fg+:#eeeeee,bg+:#282828,hl+:#cf73e6,info:#cf73e6,prompt:#FF0000,pointer:#cf73e6,marker:#f0d50c,spinner:#cf73e6,header:#91aadf
Term_School  --color=fg:#f0f0f0,bg:#252c31,bg+:#005f5f,hl:#87d75f,gutter:#252c31,prompt:#f0f0f0,pointer:#dfaf00,marker:#00d7d7
Dracula  --color=fg:#f8f8f2,bg:#222d31,hl:#bd93f9,fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9,info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6,marker:#ff79c6,spinner:#ffb86c,header:#6272a4
Ubunto  --color=fg:#F1F707,bg:#360B28,hl:#666666,fg+:#eeeeee,bg+:#621342,hl+:#cf73e6,info:#cf73e6,prompt:#FF0000,pointer:#cf73e6,marker:#f0d50c,spinner:#cf73e6,header:#91aadf
Esmeralda  --color=fg:#50fa7b,bg:#152C23,hl:#23FA0B,fg+:#23FA0B,bg+:#3E4541,hl+:#23FA0B,pointer:#BF616A,info:#BE998F,spinner:#BE998F,header:#DCD81F,prompt:#B4AE10,marker:#BF616A
Dracullyrian  --color=fg:#D8E6D0,bg:#222d31,hl:#bd93f9,fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9,info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6,marker:#ff79c6,spinner:#ffb86c,header:#6272a4"
config="_COPY_ ctrl-c              :Copy selected item
_PASTE_ ctrl-v             :Paste copied items to selected directory
_CUT_ ctrl-x               :Cut selected item
_DELETE_ ctrl-d            :Move selected item to Trash
_HELP_ ctrl-h              :Show Help page (the one you are viewing now)
_SELECT-ALL_ ctrl-a        :Select all items
_DESELECT-ALL_ ctrl-alt-a  :Deselect all items
_RENAME_ ctrl-r            :Rename selected item
_COPY-NAME_ ctrl-y         :Copy name of selected item
_PASTE-NAME_ ctrl-u        :Rename selected item with copied name
_OPEN-WITH_ ctrl-o         :Select application to open item
_SELECT-APP_ ctrl-alt-o    :Select application to open item
_CREATE-N-FILE_ ctrl-n     :Create new file
_CREATE-N-DIR_ ctrl-alt-n  :Create new directory
_EMPTY-TRASH_ ctrl-z       :Empty Trash
_OPENTERMINAL_ space       :Open default terminal in this directory
_THEME_ ctrl-t             :Select Theme
_home_ alt-1               :Move to home directory
_Desktop_ alt-2            :Move to Desktop directory
_Documents_ alt-3          :Move to Documents directory
_Downloads_ alt-4          :Move to Downloads directory
_Music_ alt-5              :Move to Music directory
_Pictures_ alt-6           :Move to Pictures directory
_Videos_ alt-7             :Move to Videos directory
_commands_ alt-8           :Move to commands directory
_extrahd_ alt-9   :Move to extra hard drive directory
_back_ alt-b               :Move back one directory
_TRASH_ alt-z              :Move to Trash directory
_DEFAULTTEXT_APP_ xed      :Default text editor
_TEXT_APP1_ xed            :Text editor 1
_TEXT_APP2_ nano           :Text editor 2
_TEXT_APP3_ mousepad       :Text editor 3
_TEXT_APP4_ bash           :Open selected script with bash
_TEXT_APP5_ retext         :Open md file with ReText
_DEFAUDIO_APP_ mplayer     :Default audio player
_DEFVIDEO_APP_ mpv         :Default audio player
_MEDIA_APP1_ mplayer       :Media player 1
_MEDIA_APP2_ xplayer       :Media player 2
_MEDIA_APP3_ vlc           :Media player 3
_MEDIA_APP4_ celluloid     :Media player 4
_MEDIA_APP5_ play          :Media player 5
_MEDIA_APP6_ mpv           :Media player 6
_MEDIA_APP7_ smplayer      :Media player 7
_MEDIA_APP8_ audacity      :Audio editor
_DEFIMAGE_APP_ viewnior    :Default image viewer
_IMAGE_APP1_ viewnior      :Image viewer 1
_IMAGE_APP2_ gimp          :Image manipulation program 1
_IMAGE_APP3_ inkscape      :Image manipulation program 2
_SUB_EDITOR_ gaupol        :Subtitle editor
_DEF_OFFICE_ libreoffice   :Office suite
_DEF_PDF_ xreader          :Pdf Reader
_DBROWSER_ brave-browser   :Default web browser
_BROWSER1_ brave-browser   :Web Browser 1
_BROWSER2_ firefox         :Web Browser 2
_BROWSER3_ xed             :Text Editor
_PREFTERM_ gnome-terminal       :Terminal"
echo "$audio_shortcuts">$HOME/.config/uberfuzz/audio_shortcuts.txt
echo "$video_shortcuts">$HOME/.config/uberfuzz/video_shortcuts.txt
echo "$themes">$HOME/.config/uberfuzz/themes.txt
echo "$config">$HOME/.config/uberfuzz/uberfuzz.conf
