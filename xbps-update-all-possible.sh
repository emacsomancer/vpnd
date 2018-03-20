#!/bin/bash


  # xbps-install-all-possible

    # Copyright (C) 2018 Benjamin Slade

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


        # Check if error (2>&1 redirects stderr>stdout)
	/usr/bin/xbps-install -Munv 2>&1 | grep MISSING > /tmp/void-errs   # check for missing packages
	/usr/bin/xbps-install -Munv 1>/dev/null 2>/tmp/stderr   # need to do in 2 steps for some reason
	grep broken /tmp/stderr > /tmp/void-breaks   # check for broken packages and breaking packages
	# if non-null then errors
	en=`cat /tmp/void-errs | /usr/bin/wc -l`
	eb=`cat /tmp/void-breaks | /usr/bin/wc -l`
	if [[ $en -eq 0 && $eb -eq 0 ]]  # no error
	then 
	   sudo xbps-install -Su # just run regular update
        else # error
	    if [ -f /tmp/dontinstall ]
	    then
		rm /tmp/dontinstall
	    fi
	    while read line; do  # check each problematic pkg in void-errs
		echo $line > /tmp/tmpline  # strip out each line about problem pkgs to tmp file /tmp/tmpline
		problem=$(cut -d' ' -f2- /tmp/tmpline | sed 's/[<>=].*//') # narrow to pkg-name in /tmp/tmpline, store in $problem
		echo "$(/usr/bin/xbps-query -X $problem | sed 's/-[0-9].*$//g')" >> /tmp/dontinstall # store list of all unupgradeable pkgs
	    done < /tmp/void-errs

    	    while read line; do  # check each problematic pkg in void-breaks
		echo $line > /tmp/tmpline  # strip out each line about problem pkgs to tmp file /tmp/tmpline
		problem=$(cut -d " " -f 1 /tmp/tmpline | sed 's/-[0-9].*:$//g') # narrow to pkg-name by throwing away final -DDD:
#		echo $problem # DELETEME
		echo $problem >> /tmp/dontinstall
	    done < /tmp/void-breaks
   
	    # Cut out relevant info from all lines with "Found"
            /usr/bin/xbps-install -Munv 2>&1 |grep Found | cut -d' ' -f2 | cut -d' ' -f1 | sed 's/-[0-9].*$//g' > /tmp/void-pkgs 
	    
	    # Create list of all installable pkgs
	    while read targetpkg; do
		bad=0
		while read noinstall; do
#		    echo "targetpkg is $targetpkg"
#		    echo "forbidded to install is $noinstall"
		    if [ "$targetpkg" == "$noinstall" ]
		    then
			bad=$((bad+1))
		    fi
		done < /tmp/dontinstall
#		echo $bad
#		echo $targetpkg
		if [ $bad -eq 0 ]   # if targetpkg doesn't match a pkg already in our don't install list then check
		then
		    sudo xbps-install -Sun $targetpkg 2>&1 | grep breaks > /tmp/morebreaks # check if pkg breaks anything
    		    sudo xbps-install -Sun $targetpkg 2>&1 | grep broken >> /tmp/morebreaks # check if pkg breaks anything
	    	    emb=`cat /tmp/morebreaks | /usr/bin/wc -l`
	    	    if [ $emb -eq 0 ]   # if targetpkg doesn't break anything, then add to our install string
		    then
			
			installme="$installme $targetpkg"
		    fi
#		    echo "installme="$installme
		fi
	    done < /tmp/void-pkgs
	    sudo xbps-install -S $installme     # finally install everything that can be installed
		
	fi
	
