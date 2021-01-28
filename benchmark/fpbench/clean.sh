#!/bin/bash

OLDPWD=`pwd`

for i in `ls -d [0-9]*`
do
    cd $i
    :
    rm -f C* equivalent* res* *~ Magneto_evaluation* mutation_score*
    cd - > /dev/null
done
