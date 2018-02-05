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
        /usr/bin/xbps-install -Munv 2>&1 | grep MISSING > /tmp/void-errs
        # if non-null then errors
	en=`cat /tmp/void-errs | /usr/bin/wc -l`
	if [ $en -eq 0 ] # no error
	then 
	   sudo xbps-install -Su # just run regular update
        else # error
	    rm /tmp/dontinstall
	    while read line; do  # check each problematic pkg
		echo $line > /tmp/tmpline  # strip out each line about problem pkgs to tmp file /tmp/tmpline
		problem=$(cut -d' ' -f2- /tmp/tmpline | sed 's/[<>=].*//') # narrow to pkg-name in /tmp/tmpline, store in $problem
		echo "$(/usr/bin/xbps-query -X $problem | sed 's/-[0-9].*$//g')" >> /tmp/dontinstall # store list of all unupgradeable pkgs
	    done < /tmp/void-errs
   
	    # Cut out relevant info from all lines with "Found"
            /usr/bin/xbps-install -Munv 2>&1 |grep Found | cut -d' ' -f2 | sed 's/-[0-9].*$//g' > /tmp/void-pkgs 
	    
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
		if [ $bad -eq 0 ]
		then
		    installme="$installme $targetpkg"
#		    echo $installme
		fi
	    done < /tmp/void-pkgs
	    sudo xbps-install -Su $installme
	fi
	
