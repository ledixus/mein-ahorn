#!/bin/bash

#MIT License

#Copyright (c) 2016 Stefan Dietrich

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

#crontab entry: 0 22 * * * /home/pi/kamera/scripts/report.sh

LOGFILE="/home/pi/kamera/log/kamera.log"
FAILFILE="/home/pi/kamera/log/kamera.fail"
IRC="/PATH/TO/LOGFILE/OF/THE/IRC_BASH_BOT"

#Calculation for scheduled amount of pictures. Endtime is 22:00 because the script takes pictures until 21:50

STARTIME=5
ENDTIME=22
INTERVAL=10

SCHEUDLED=$((($ENDTIME - $STARTTIME) * 60 / $INTERVAL))

y=0

if [[ ! -f "${LOGFILE}"  ]]
        then
                echo "PRIVMSG #YOUR_IRC_CHANNEL :Keine Logdateien gefunden" >> "${IRC}"
		exit
fi

CALC="$(cut -d" " -f1 "${LOGFILE}")"
AMOUNT="$(wc -l "${LOGFILE}" | cut -d" " -f1)"

for x in ${CALC}
        do Y=$((y+$x))
done

if [[ "${Y}" == "0" ]]
	then
		echo "PRIVMSG #YOUR_IRC_CHANNEL :Ich habe "${AMOUNT}" von "${SCHEDULED}" geplanten Bildern ohne Fehlercodes gemacht" >> "${IRC}" && rm "${LOGFILE}"
	else
		echo "PRIVMSG #YOUR_IRC_CHANNEL :Ich habe "${Y}" Fehler bei "${AMOUNT}" von "${SCHEDULED}" geplanten Bildern gemacht!!!" >> "${IRC}" && mv "${LOGFILE}" "${FAILFILE}"

fi

