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


#$(date +"%Y") for the Year
#$(date +"%m") for the Month
#$(date +"KW%V-%d-%m-%Y-%H%M") for KW00-Day00-Month00-Year0000-Time0000

#crontab entry for this file: */10 05-21 * * * /home/pi/kamera/scripts/aufnahme.sh


mkdir -p $(date +"/home/pi/kamera/pics/%Y/KW%V")


WEATHER=$(sudo python "/home/pi/kamera/scripts/dht22.py" 2032 4)
TMP_FILE="/home/pi/kamera/pics/tmp.jpg"


raspistill -o "{TMP_FILE}" && sleep 10 && convert "{TMP_FILE}" -pointsize 50 -font "Verdana-Fett" \ 
-fill "black" -stroke "black" -strokewidth 5 -gravity NorthEast -annotate +100+100 "$(date "+%V. KW %a. %d. %b %Y %H:%M")\n ${WEATHER}" \
-fill "white" -stroke "white" -strokewidth 1 -gravity NorthEast -annotate +100+100 "$(date "+%V. KW %a. %d. %b %Y %H:%M")\n ${WEATHER}" \
$(date "+/home/pi/kamera/pics/%Y/KW%V/%m-%d-%Y-%H_%M.jpg") && rm "{TMP_FILE}"

echo -e $? $(date +"KW%V-%d-%m-%Y-%H%M") >> /home/pi/kamera/log/kamera.log
