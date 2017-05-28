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

# install yad - http://sourceforge.net/projects/yad-dialog/
sudo xbps-install -Su yad 

# copy icons
sudo mkdir -p /usr/local/share/icons/vpnd/
sudo cp abgrund.png /usr/local/share/icons/vpnd/abgrund.png
sudo cp ungeheuern.png /usr/local/share/icons/vpnd/ungeheuern.png

# copy bash shell script & make +x
sudo cp vpnd.sh /usr/local/bin/vpnd
sudo chmod +x /usr/local/bin/vpnd
