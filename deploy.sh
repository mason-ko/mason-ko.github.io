#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

cd origin-data

# Build the project.
hugo -t toha

# Go To Public folder
cd public
# Add changes to git.
cp -rf . ../../

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

