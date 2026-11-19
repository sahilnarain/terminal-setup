#!/bin/bash

if [[ $TERM == 'linux' ]]
then
  echo "source ~/.mutt/colorschemes/snare.muttrc"
else
  echo "source ~/.mutt/colorschemes/dracula.muttrc"
fi
