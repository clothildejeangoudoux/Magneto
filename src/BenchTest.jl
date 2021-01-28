# BenchTest.jl
module BenchTest

using IntervalArithmetic
using DataStructure
using MutantGeneration
using Magneto
using RandomTesting
using TestFunctions
using PrintConstraint

export test

function print_tblmut(M_tblmut,tests,f)
    if (M_tblmut != nothing)
        k, u = mutation_score(tests,M_tblmut)
        print(f,length(M_tblmut)," ",k," ")
    else
        print(f,0," ",0," ")    
    end
end

function gen_tblmut(C,f_tblmut,tests)
    M_tblmut = mutants_generation_1mutation(C,"precision")
    print_tblmut(M_tblmut,tests,f_tblmut)
    M_tblmut = mutants_generation_1mutation(C,"bounds")
    print_tblmut(M_tblmut,tests,f_tblmut)
    M_tblmut = mutants_generation_1mutation(C,"constant")
    print_tblmut(M_tblmut,tests,f_tblmut)
    M_tblmut = mutants_generation_1mutation(C,"variable")
    print_tblmut(M_tblmut,tests,f_tblmut)
    M_tblmut = mutants_generation_1mutation(C,"unary")
    print_tblmut(M_tblmut,tests,f_tblmut)
    M_tblmut = mutants_generation_1mutation(C,"binary")
    print_tblmut(M_tblmut,tests,f_tblmut)
    M_tblmut = mutants_generation_1mutation(C,"add")
    print_tblmut(M_tblmut,tests,f_tblmut)
    M_tblmut = mutants_generation_1mutation(C,"del")
    print_tblmut(M_tblmut,tests,f_tblmut)
end

function test(C::DataConstraint, variables, constants, args)

    tree = string("y ",C.dataSymbol,gen_csp_tree(C.dataRight),"(1 +",Float32(C.dataRelativeError.dataValue),")")

    # mutant generation
    M, t_mg = @timed mutants_generation(C)
    m = length(M)

    # spec complexity
    nb_op = count_op(C.dataRight)
    depth = depth_tree(C.dataRight)

    # open file
    f = open(string("../",args[4]),"a")
    f_tblmut = open(string("../tblmut_",args[4]),"a")
    f_testset = open(string("../testset_",args[4]),"a")

    print(f,C.dataName," ",m," ",t_mg," ",nb_op," ",depth," ")
    
    if args[1] == "1"
        # Compute with Magneto
        tests, t_mt = @timed magneto(C,M)
        println(f_testset,C.dataName," ",tests)
        if isfile("equivalent_mutants.txt")
            cmd = `wc -l equivalent_mutants.txt`
            res = read(cmd,String)    
            eq_mut = parse(Int,split(res)[1])
        else
            eq_mut = 0
        end
        # number of generated tests
        tst = length(tests)
        # Magneto mutation score
        mu_score = (m-eq_mut)/m
        # Comparison with random testing mutation score evaluation method
        k, u = mutation_score(tests,M)
        print(f,eq_mut," ",tst," ",mu_score," ",k/length(M)," ",u/length(M)," ",u/length(M)+k/length(M)," ",t_mt," ")
        
        # Generating results for tblmut
        print(f_tblmut,C.dataName," ")
        gen_tblmut(C,f_tblmut,tests)
        
        if args[2] == "2"
            # BB with timeout set to Magneto's time files
            f2_tblmut = open(string("../tblmut_",args[5]),"a")
            f2 = open(string("../",args[5]),"a")
            f2_testset = open(string("../testset_",args[5]),"a")
            print(f2,C.dataName," ",m," ",t_mg," ",nb_op," ",depth," ")

            # BB
            (nb_tests, test_set, k, u), t_rd = @timed random_testing(C,M,Timer(t_mt))
            print(f2,nb_tests," ",length(test_set)," ",k/length(M)," ",u/length(M)," ",u/length(M)+k/length(M)," ",t_rd)
            println(f2_testset,C.dataName," ",test_set)
            
            # Generating results for tblmut
            print(f2_tblmut,C.dataName," ")
            gen_tblmut(C,f2_tblmut,test_set)

            print(f2,"\n")
            print(f2_tblmut,"\n")
            close(f2)
            close(f2_tblmut)
            close(f2_testset)
        end
    end
    if args[2] == "1"
        # BB with timeout set to parse(Int64,args[3])
        (nb_tests, test_set, k, u), t_rd = @timed random_testing(C,M,Timer(parse(Int64,args[3])))
        print(f,nb_tests," ",length(test_set)," ",k/length(M)," ",u/length(M)," ",u/length(M)+k/length(M)," ",t_rd)
        println(f_testset,C.dataName," ",test_set)
        
        # Generating results for tblmut
        print(f_tblmut,C.dataName," ")
        gen_tblmut(C,f_tblmut,test_set)
    end
    
    print(f,"\n")
    print(f_tblmut,"\n")
    
    close(f)
    close(f_tblmut)
    close(f_testset)
end


end
