#!/bin/bash


  # vpnd - Void Package Notifier Daemon
    
    #         "He who fights against (certain kinds of) daemons should beware lest 
    #          he himself becomes a daemon. And when you gaze long into the Void,
    #  	       sometimes the Void gazes also into you....
    #	             ....and sometimes you just need to update your system."
    
    # 	             (with apologies to F. Nietzsche)

    # Copyright (C) 2017 Benjamin Slade

    # LICENCE:
    # This program is free software: you can redistribute it and/or modify it under the
    # terms of the GNU General Public License as published by the Free Software
    # Foundation, either version 3 of the License, or (at your option) any later
    # version.

    # This program is distributed in the hope that it will be useful, but WITHOUT ANY
    # WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
    # PARTICULAR PURPOSE. See the GNU General Public License for more details.

    # You should have received a copy of the GNU General Public License along with this
    # program. If not, see http://www.gnu.org/licenses/.


# TODO:
# * 1st 
#   - add input for update cycle (default=60mins)
#   - add input for notify-send on update check (binary/default=off) 
# * 2nd
#   - add click menu with different options
#      - refresh (current left-click action)
#      - update? (spawn terminal with pre-made xbps-command?)
# * 3rd
#   - remove bashisms? (even possible with yad?) - not possible because of function export? :(

# icon files - [ variables not working in echo "icon:..." commands ?! ]
ungeheuern="/usr/local/share/icons/vpnd/ungeheuern.png"
abgrund="/usr/local/share/icons/vpnd/abgrund.png"

# create a FIFO file, used to manage the I/O redirection from shell
PIPE=$(mktemp -u --tmpdir ${0##*/}.XXXXXXXX)
mkfifo $PIPE

# attach a file descriptor to the file
exec 3<> $PIPE

# define function for yad to call on left-click, forcing check updates
function updater {
	# enumerate packages needing updating, export to tmp file 
        /usr/bin/xbps-install -Mun | sed -r 's/(\w+) (\w+)/\1 [\2]/' | awk '{print $1,$2}' | column -t  > /tmp/void-pkgs
        # count packages needing updating
        n=`cat /tmp/void-pkgs | /usr/bin/wc -l`
	# set last checked timestamp
        d="$(stat /tmp/void-pkgs|grep Access|grep 20|sed 's/\..*$//'|sed 's/Access: /Last checked: /')"
        while read line; do
                pkgs="$pkgs\n $line"
        done < /tmp/void-pkgs
	if [ $n -eq 0 ] # no new pkgs
	then
		pkginfo="all packages up-to-date \n------------------------------------------------------- \n [$d]"
		exec 3<> $PIPE >&3
		echo "icon:/usr/local/share/icons/vpnd/abgrund.png"
	elif [ $n -eq 1 ] # 1 new pkg
	then
	    	pkginfo="$n package needs updating: \n================================== $pkgs \n------------------------------------------------------------------ \n [$d]"
		exec 3<> $PIPE >&3
		echo "icon:/usr/local/share/icons/vpnd/ungeheuern.png"
        else # >1 new pkgs
	    	pkginfo="$n packages need updating:  \n================================== $pkgs \n----------------------------------------------------------------- \n [$d]"
	    	exec 3<> $PIPE >&3
		echo "icon:/usr/local/share/icons/vpnd/ungeheuern.png"
	fi
	echo "tooltip:$pkginfo" # set mouse-over to relevant pkginfo
}

# add handler function to manage process shutdown
function on_exit() {
    echo "quit" >&3
    rm -f $PIPE
}
trap on_exit EXIT

# export needed things
export -f updater
export PIPE

# summon yad systray icon
yad --notification --command="bash -c updater" --image="/usr/local/share/icons/vpnd/ungeheuern.png" --text="$d2" --listen <&3 & 

# call updater function for first time, getting initial values 
bash -c updater

# loop to update every N seconds
while true
   do
	sleep 1800  	# wait 30 minutes (N=1800 secs)
	bash -c updater
done

# ,,Wer mit Ungeheuern kaempft, mag zusehn, dass er nicht dabei zum Ungeheuer wird. Und
#   wenn du lange in einem Abgrund blickst, blickt der Abgrund auch in dich hinein.''
#				   --Friedrich Nietzsche, _Jenseits von Gut und Boese_ no. 146
