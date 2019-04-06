#!/bin/bash

dirty=$(git status --porcelain | wc -l)
if [[ $dirty -ne 0 ]]
then
    echo "Checkout dirty"
    exit 1
fi

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

public=$(mktemp -d)
function finish {
  rm -rf "$public"
}
trap finish EXIT

hugo
mv public/* $public
git checkout master
git pull origin master
rm -rf ./*
mv $public/* .
git add --all .

msg="rebuilding site `date`"
git commit -m "$msg"
git push origin master
git checkout develop