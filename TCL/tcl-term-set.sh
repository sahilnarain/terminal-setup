if [[ `pidof fbterm` ]]
then
  tty | grep "/dev/pts/" &> /dev/null
  if [[ $? -eq 0 ]]
  then
    if [[ $TERM == 'linux' ]]
    then
      export TERM=fbterm
    fi
  fi
else
  export TERM=linux
fi
