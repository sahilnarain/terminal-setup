#!/bin/ash

####################

TMP_DIR=/tmp/kmscon

XKB_REMOTE=[REDACTED]
XKB_PATH=$TMP_DIR/xkb.zip
XKB_MD5=fb3cc9c969f91946a0c2c9e3aaf60ded

UNIFONT_REMOTE=[REDACTED]
UNIFONT_PATH=$TMP_DIR/unifont.tcz
UNIFONT_MD5=94ac8451362cb28d1431ec6e9b00ce8d

KMSCON_REMOTE=[REDACTED]
KMSCON_PATH=$TMP_DIR/kmscon.tcz
KMSCON_MD5=cb51f70730e41d47e5e6f7fd44280376

####################

function check_file_exists() {
  if [ -f $1 ]
  then
    return 1
   else
    return 0
   fi
}

function check_file() {
  check_file_exists $1
  if [ $? -eq 0 ]
  then
    return 0
  fi

  result=`md5sum $1 | grep -q $2`
  if [ $? -eq 0 ]
  then
    return 1
  else
    rm -rf $1
    return 0
  fi
}

####################

if [ ! -d $TMP_DIR ]
then
  mkdir $TMP_DIR
fi

cd $TMP_DIR

##########

check_file $XKB_PATH $XKB_MD5
XKB_INTEGRITY=$?

if [[ $XKB_INTEGRITY -eq 0 ]]
then
  wget $XKB_REMOTE
fi

##########

check_file $UNIFONT_PATH $UNIFONT_MD5
UNIFONT_INTEGRITY=$?

if [[ $UNIFONT_INTEGRITY -eq 0 ]]
then
  wget $UNIFONT_REMOTE
fi

##########

check_file $KMSCON_PATH $KMSCON_MD5
KMSCON_INTEGRITY=$?

if [[ $KMSCON_INTEGRITY -eq 0 ]]
then
  wget $KMSCON_REMOTE
fi

##########

if [ ! -d /usr/share/X11 ]
then
  sudo mkdir -p /usr/share/X11
fi

if [ ! -d /usr/share/X11/xkb ]
then
  cd /usr/share/X11/
  sudo unzip /tmp/kmscon/xkb.zip > /dev/null
fi

tce-load -i /tmp/kmscon/unifont.tcz
tce-load -i /tmp/kmscon/kmscon.tcz

cd /usr/lib/
find aarch64-linux-gnu/ | xargs -I "{}" sudo ln -s "{}" . 2&> /dev/null

cd /lib/
find aarch64-linux-gnu/ | xargs -I "{}" sudo ln -s "{}" . 2&> /dev/null

KMSCON_RUNNING=`ps aux | grep /usr/libexec/kmscon/kmscon | grep -v grep`
if [ $? -eq 0 ]
then
  KMSCON_RUNNING=1
else
  KMSCON_RUNNING=0
fi

PTS=`tty | grep -q pts`
if [ $? -eq 0 ]
then
  PTS=1
else
  PTS=0
fi

if [[ $KMSCON_RUNNING -eq 1 && $PTS -eq 1 ]]
then
  echo "Nesting KMSCon can be dangerous. Exiting..."
else
  echo "Running KMS..."
  # sudo kmscon --font-engine unifont --drm --hwaccel
fi
