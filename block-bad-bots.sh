#!/bin/bash

# block-bad-bots.sh generate rewrite rules to block Bad Bots.
# Copyright (C) 2020 Ramón Román Castro <ramonromancastro@gmail.com>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc., 59
# Temple Place, Suite 330, Boston, MA 02111-1307 USA

BADBOT_URL=https://badbot.itproxy.uk/badbot.txt
BADBOT_FILE=/tmp/badbot.txt
BADBOT_CONF_FILE=/etc/httpd/conf.d/custom.badbot.conf

wget -q -O $BADBOT_FILE --no-check-certificate $BADBOT_URL
if [ $? -eq 0 ]; then

  # Convertimos a formato UNIX
  sed -i 's/\r$//g' $BADBOT_FILE

  # Filtramos las líneas vacías
  sed -i 's/\s*$//g' $BADBOT_FILE

  # Escapamos los caracteres especiales de expresiones regulares
  sed -i 's/\([-\."]\)/\\\1/g' $BADBOT_FILE

  awk 'BEGIN{
         FS="\n";
         RS="";
         print "# Block bad bots"
         print "# By Ramón Román Castro <ramon.roman.c@juntadeandalucia.es>"
         print "# https://badbot.itproxy.uk/badbot.txt"
         print "<IfModule mod_rewrite.c>"
         print "RewriteEngine On"
       }
       {
         if (NR > 1) { l[lines++]=$1 }
       }
       END{
         for (i=0; i < lines-1; i++) { print "RewriteCond %{HTTP_USER_AGENT} \""l[i]"\" [OR]" }
         print "RewriteCond %{HTTP_USER_AGENT} \""l[lines-1]"\""
         print "RewriteRule .* - [F,L]"
         print "</IfModule>"
       }' $BADBOT_FILE > $BADBOT_CONF_FILE
fi
