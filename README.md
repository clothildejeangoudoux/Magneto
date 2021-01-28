## Running Magneto (Linux) ##

### Dependencies ###
- RealPaver 0.4 for Magneto
- Julia 1.4.1 or above

### Installation Instructions ###
RealPaver 0.4 for Magneto, in the ```realpaver-0.4_Magneto``` directory
- ``` ./configure ```
- ``` make ```
- ``` make check ```
- ``` make install ``` as root

Julia 1.4.1 or above
- ``` wget https://julialang-s3.julialang.org/bin/linux/x64/1.4/julia-1.4.2-linux-x86_64.tar.gz ```
- ``` tar zxvf julia-1.4.2-linux-x86_64.tar.gz ```
- ``` export JULIA_LOAD_PATH="~/Magneto/src:$JULIA_LOAD_PATH" ```

### Magneto Test Suite ###
Execute the benchmark in the ```benchmark/fpbench``` directory with the command\\
``` ./run_test.sh a b c ```
- with ```a = 1``` for Magneto execution
- with ```b = 1``` for Rand 5s execution
- with ```c = 1``` for Rand 50s execution
- with ```d  = 0``` to run all the benchmark suite or the number of the benchmark to run a single test (e.g. ```d = 001``` for 001_carthesianToPolar_radius)

After running the test script, the results are available in ```benchmark/fpbench/```