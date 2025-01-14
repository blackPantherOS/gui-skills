#!/bin/bash

if [ ! -n "$1" ];then
    echo "### Brancher Error: Missing main (folder) parameter!"
    sleep 2
    exit 1
fi

if [ ! -n "$2" ];then
    echo "### Brancher Error: Missing second (branch) parameter!"
    sleep 2
    exit 1
fi

cd /opt/mycroft/skills
echo "INFO - Skill folder $1"
echo "INFO - Skill branch $2"
echo "INFO - Installing GUI Skill Branch"
git fetch
git checkout $2 && git reset --hard origin/$2
echo "INFO - Mycroft GUI Branch Installed"
echo "INFO - Installing Requirements Workaround"
if [ -d /opt/mycroft/.venv/bin/ ]; then
  source /opt/mycroft/.venv/bin/activate
else

if [ "x86_64" = "$(uname -m)" ] ;then
    LIB="/usr/lib64"
else
    LIB="/usr/lib"
fi

 if [ -x $LIB/mycroft-core/start-mycroft.sh ] ;then
    cd $LIB/mycroft-core || exit
    MYCROFT_CORE=$LIB/mycroft-core
 elif [ -x /var/lib/mycroft-core/start-mycroft.sh ] ;then
    cd /usr/share/mycroft-core|| exit
    MYCROFT_CORE=/var/lib/mycroft-core
 elif [ -x /usr/share/mycroft-core/start-mycroft.sh ] ;then
    cd /usr/share/mycroft-core|| exit
    MYCROFT_CORE=/usr/share/mycroft-core
 elif [ -x $HOME/mycroft-core/start-mycroft.sh ];then
    cd "$HOME/mycroft-core" || exit
    MYCROFT_CORE=$HOME/mycroft-core
 else
    FIND=$(find $HOME -maxdepth 5 -type f -name start-mycroft.sh -print -quit)
    if [ -n "$FIND" ];then
	SOURCE="${FIND}"
	DIR="$( dirname "$SOURCE" )"
	echo "Found MyCroft Core Install Here: $DIR"
	MYCROFT_CORE=$DIR
    else
	echo " ###### Missing Mycroft installation.... exiting ######## "
	exit
    fi
 fi

 if [ -f $MYCROFT_CORE/.venv/bin/activate ];then
    source $MYCROFT_CORE/.venv/bin/activate
 else 
    echo "### Brancher Error when tried activate Core..."
 fi

fi

cd $1
if [ -f "$PWD/requirements.txt" ];then
    pip install -r requirements.txt
    echo "INFO - Installed Requirements"
    echo "INFO - Refreshing Skill"
    touch __init__.py
    echo "INFO - Skill Installation Completed"
else
    echo "Brancher Error - Missing requirenments.txst in $1 !"
    sleep 2
fi
