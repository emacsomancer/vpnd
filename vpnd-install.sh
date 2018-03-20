#!/bin/sh

  # vpnd - Void Package Notifier Daemon installer

    #         "He who fights against (certain kinds of) daemons should beware lest
    #          he himself becomes a daemon. And when you gaze long into the Void,
    #          sometimes the Void gazes also into you....
    #                ....and sometimes you just need to update your system."

    #                (with apologies to F. Nietzsche)

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

# install yad - http://sourceforge.net/projects/yad-dialog/ - if not already installed
if ! [ xbps-query -s yad >/dev/null 2>&1 ]   # check for yad
then 
    /usr/bin/sudo xbps-install -Su yad
fi
if ! [ xbps-query -s bash >/dev/null 2>&1 ]  # check for bash
then 
    /usr/bin/sudo xbps-install -Su bash
fi	

# copy icons
sudo mkdir -p /usr/local/share/icons/vpnd/
sudo cp abgrund.png /usr/local/share/icons/vpnd/abgrund.png
sudo cp ungeheuern.png /usr/local/share/icons/vpnd/ungeheuern.png
sudo cp ungeheuern-krank.png /usr/local/share/icons/vpnd/ungeheuern-krank.png

# copy bash shell script & make +x
sudo cp vpnd.sh /usr/local/bin/vpnd
sudo chmod +x /usr/local/bin/vpnd
sudo cp xbps-update-all-possible.sh /usr/local/bin/xbps-update-all-possible
sudo chmod +x /usr/local/bin/xbps-update-all-possible
