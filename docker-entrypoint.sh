#!/bin/bash
set -e

git clone https://github.com/QMSTR/qmstr-demo

cd qmstr-demo

# if not demo specified
if [ -z "$1" ]; then
    for demo in */; do
        echo Running demo: $demo
        cd $demo
        ./build.sh
    done
else
    echo Runnind demo: $1
    cd $1
    ./build.sh
fi