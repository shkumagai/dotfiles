#!/bin/bash

## *rc (resource) files
for rcfile in ?*rc
do
    ln -Fis "$PWD/$rcfile" "$HOME/.${rcfile}"

    archtype=$(uname -s | tr '[:upper:]' '[:lower:]')
    subrcfile="$rcfile.$archtype"
    if [[ -f $subrcfile ]]
    then
        ln -Fis "$PWD/$subrcfile" "$HOME/.$rcfile.local"
    fi
done

## *config files
for conffile in ?*config
do
    ln -Fis "$PWD/$conffile" "$HOME/.$conffile"
done

## *ignore files
for ignorefile in ?*ignore
do
    ln -Fis "$PWD/$ignorefile" "$HOME/.$ignorefile"
done
