#!/bin/bash
# add the list of recently modified files from the workpace with random files present to the default commit
DEFAULT_FOLDER='.'
FOLDER=${1:-$DEFAULT_FOLDER}
git add $(git status $FOLDER | sed -n 's/modified://pg')
