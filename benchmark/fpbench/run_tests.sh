#!/bin/bash

if [[ $# -ne 2 ]]; 
then echo "illegal number of parameters"
else
    
    OLDPWD=`pwd`
    
    # echo "--------- CLEAN ---------"
    ./clean.sh

    if [[ $2 -eq 0 ]];
    then
    
	if [[ $1 -eq 1 ]];
	then echo "--------- MAGNETO ---------"
	     rm -f res_magneto.dat tblmut_res_magneto.dat testset_res_magneto.dat
	     for i in `ls -d [0-9]*`
	     do
    		 cd $i
    		 :
    		 echo "TEST " $i
    		 ./../../../julia-1.4.1/bin/julia c.jl 1 0 0 res_magneto.dat
		 rm -rf ../log_files/$i/*
		 cp -rf . ../log_files/$i
    		 cd - > /dev/null
	     done
	     cp res_magneto.dat tblmut_res_magneto.dat testset_res_magneto.dat log_files/		 
	fi
	
	if [[ $1 -eq 2 ]];
	then echo "--------- RANDOM 5s ---------"
	     rm -f res_rand_5.dat tblmut_res_rand_5.dat testset_res_rand_5.dat
             for i in `ls -d [0-9]*`
	     do
    		 cd $i
    		 :
    		 echo "TEST " $i
    		 ./../../../julia-1.4.1/bin/julia c.jl 0 1 5 res_rand_5.dat
    		 cd - > /dev/null
	     done
	     cp res_rand_5.dat tblmut_res_rand_5.dat testset_res_rand_5.dat log_files/
	fi
	
	if [[ $1 -eq 3 ]];
	then echo "--------- MAGNETO + BB ---------"
    	     rm -f res_BB.dat res_magneto.dat tblmut_res_BB.dat tblmut_res_magneto.dat testset_res_BB.dat testset_res_magneto.dat
	     for i in `ls -d [0-9]*`
    	     do
    		 cd $i
    		 :
    		 echo "TEST " $i
    		 ./../../../julia-1.4.1/bin/julia c.jl 1 2 0 res_magneto.dat res_BB.dat
		 rm -rf ../log_files/$i/*
		 cp -rf . ../log_files/$i
    		 cd - > /dev/null
    	     done
	     cp res_BB.dat res_magneto.dat tblmut_res_BB.dat tblmut_res_magneto.dat testset_res_BB.dat testset_res_magneto.dat log_files/
	fi
	
    else

	echo ----- $2* -----
	
	if [[ $1 -eq 1 ]];
	then echo "--------- MAGNETO ---------"
	     rm -f res_$2_magneto.dat tblmut_res_$2_magneto.dat testset_res_$2_magneto.dat
	     cd $2*
	     :
    	     ./../../../julia-1.4.1/bin/julia c.jl 1 0 0 res_$2_magneto.dat
	     rm -rf ../log_files/$2*/*
	     cp -rf . ../log_files/$2*
	     cp ../res_$2_magneto.dat ../tblmut_res_$2_magneto.dat ../testset_res_$2_magneto.dat ../log_files/
	     cd - > /dev/null
	fi
	
	if [[ $1 -eq 2 ]];
	then echo "--------- RANDOM 5s ---------"
	     rm -f res_$2_rand_5.dat tblmut_res_$2_rand_5.dat testset_res_$2_rand_5.dat
	     cd $2*
	     :
    	     ./../../../julia-1.4.1/bin/julia c.jl 0 1 5 res_$2_rand_5.dat
	     cp ../res_$2_rand_5.dat ../tblmut_res_$2_rand_5.dat ../testset_res_$2_rand_5.dat ../log_files/
	     cd - > /dev/null
	fi
	
	if [[ $1 -eq 3 ]];
	then echo "--------- BB ---------"
	     rm -f res_$2_BB.dat res_$2_magneto.dat tblmut_res_$2_BB.dat tblmut_res_$2_magneto.dat testset_res_$2_BB.dat testset_res_$2_magneto.dat
	     cd $2*
	     :
    	     ./../../../julia-1.4.1/bin/julia c.jl 1 2 0 res_$2_magneto.dat res_$2_BB.dat
	     rm -rf ../log_files/$2*/*
	     cp -rf . ../log_files/$2*
	     cp ../res_$2_BB.dat ../res_$2_magneto.dat ../tblmut_res_$2_BB.dat ../tblmut_res_$2_magneto.dat ../testset_res_$2_BB.dat ../testset_res_$2_magneto.dat ../log_files/
	     cd - > /dev/null
	fi
	
    fi
fi 
