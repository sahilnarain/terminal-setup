#!/bin/bash

if [[ $TERM == 'linux' ]]
then
  echo "source ~/ai.muttrc"
else
  echo "source ~/.mutt/colorschemes/dracula.muttrc"
fi
