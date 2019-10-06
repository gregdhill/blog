#!/bin/bash

dirty=$(git status --porcelain | wc -l)
if [[ $dirty -ne 0 ]]
then
    echo "Checkout dirty"
    exit 1
fi

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

hugo
cd public
git add --all
git commit -m "`date`"