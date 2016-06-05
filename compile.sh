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

#crontab entry: 01 20 * * 0 /home/pi/kamera/scripts/compile.sh

#Directories
PIC_DIR="/home/pi/kamera/pics/$(date +%Y)/$(date +%m)"
VID_DIR="/home/pi/kamera/videos/$(date +%Y)/$(date +%m)"
ARCHIVE_DIR="/home/pi/kamera/archive"

#Files
ARCHIVE_FILE="${ARCHIVE_DIR}/$(date "+KW%V-%Y").tar"
VID_720="${VID_DIR}/$(date "+KW%V").mp4"
VID_1080="${VID_DIR}/$(date "+KW%V")-1080.mp4"

#Blog server
SERVER_USER="CHANGEME"
SERVER_NAME="CHANGEME"
SERVER_PORT="CHANGEME"

#Backup server
FTP_USER="CHANGEME"
FTP_SERVER="CHANGEME"

#IRC logfile
IRC="/PATH/TO/LOGFILE/OF/THE/SIMPLE/BASHBOT"

#create dirs (pic dir should exist, cause the camera script should do this)

makedirs()
{
if [[ ! -d "${VID_DIR}" ]] || [[ ! -d "${ARCHIVE_DIR}" ]]
	then
		mkdir -p {"${VID_DIR}","${ARCHIVE_DIR}"}
		echo "PRIVMSG #CHANNEL_OF_YOUR_BOT : Verzeichnisse "${VID_DIR}" und "${ARCHIVE_DIR}" erstellt" >> "${IRC}"
	else

		echo "PRIVMSG #CHANNEL_OF_YOUR_BOT : Verzeichnisse "${VID_DIR}" und "${ARCHIVE_DIR}" existieren " >> "${IRC}"
fi
}


#create an archive first

createarchive()
{

	if [[ $? -eq 1 ]]; then
		echo "PRIVMSG #CHANNEL_OF_YOUR_BOT : Fehler beim erstellen der Verzeichnisse "${VID_DIR}" und "${ARCHIVE_DIR}"." >> "${IRC}"
		exit
	else

		echo "PRIVMSG #CHANNEL_OF_YOUR_BOT : Erstelle "${ARCHIVE_FILE}" Archiv." >> "${IRC}"

		tar -cf "${ARCHIVE_FILE}" "${PIC_DIR}/$(date "+KW%V")"

		echo "PRIVMSG #CHANNEL_OF_YOUR_BOT : Das "${ARCHIVE_FILE}" Archiv wurde erfolgreich erstellt." >> "${IRC}"
fi
}


#create the videos for the blog itself

makevideos()
{

	if [[ $? -eq 1 ]]; then
		echo "PRIVMSG #CHANNEL_OF_YOUR_BOT : Fehler beim erstellen des "${ARCHIVE_FILE}" Archivs" >> "${IRC}"
		exit
	else

		echo "PRIVMSG #CHANNEL_OF_YOUR_BOT : Rendere das "${VID_720}" Video" >> "${IRC}"

		ffmpeg -r 4 -f image2 -pattern_type glob -i "${PIC_DIR}/$(date "+KW%V")/*.jpg" -c:v libx264 -crf 20 -vf scale=-1:720 -threads 0 -an -sn -pix_fmt yuv420p -preset slow "${VID_720}" && \ 

		echo "PRIVMSG #CHANNEL_OF_YOUR_BOT : "${VID_720}" erfolgreich gerendert. Rendere "${VID_1080}" Video." >> "${IRC}"

		ffmpeg -r 4 -f image2 -pattern_type glob -i "${PIC_DIR}/$(date "+KW%V")/*.jpg" -c:v libx264 -crf 20 -vf scale=-1:1080 -threads 0 -an -sn -pix_fmt yuv420p -preset slow "${VID_1080}"

		echo "PRIVMSG #CHANNEL_OF_YOUR_BOT : "${VID_1080}" erfolgreich gerendert." >> "${IRC}"
fi
}


#upload the archive (with jpg's of the week and the created videos) to the backup space

uploadvideos()
{

	if [[ $? -eq 1 ]]; then
		echo "PRIVMSG #CHANNEL_OF_YOUR_BOT : Fehler beim erstellen der .mp4 Videos." >> "${IRC}"
		exit
	else
		echo "PRIVMSG #CHANNEL_OF_YOUR_BOT : Füge die "${VID_720}" und "${VID_1080}" zum "${ARCHIVE_FILE}" Archiv hinzu." >> "${IRC}"

		tar -rf "${ARCHIVE_FILE}" "${VID_720}" "${VID_1080}" && \

		echo "PRIVMSG #CHANNEL_OF_YOUR_BOT : Erstellung "${ARCHIVE_FILE}" Archiv abgeschlossen, beginne mit Upload auf Backupspace." >> "${IRC}"
		sftp "${FTP_USER}"@"${FTP_SERVER}" <<EOF
cd /CHANGE/TO/YOUR/DIRECTORY
put "${ARCHIVE_FILE}"
bye
EOF
		echo "PRIVMSG #CHANNEL_OF_YOUR_BOT : Upload auf Backupspace abgeschlossen." >> "${IRC}"
fi
}


#upload both videos files to the server

uploadtoblog()
{

	if [[ $? -eq 1 ]]; then
		echo "PRIVMSG #CHANNEL_OF_YOUR_BOT : Fehler beim Upload der .mp4 Dateien auf den Backupspace." >> "${IRC}"
		exit
	else
		echo "PRIVMSG #CHANNEL_OF_YOUR_BOT : Beginne mit Upload von "${VID_720}" und "${VID_1080}" auf den Webserver." >> "${IRC}"
		sftp -P "${SERVER_PORT}" "${SERVER_USER}"@"${SERVER_NAME}" <<EOF
cd /CHANGE/TO/YOUR/DIRECTORY
put "${VID_720}"
put "${VID_1080}"
bye
EOF
		echo "PRIVMSG #CHANNEL_OF_YOUR_BOT : Upload abgeschlossen, l3dixus bitte neuen Beitrag erstellen." >> "${IRC}"
fi
}

makedirs
createarchive
makevideos
uploadvideos
uploadtoblog
