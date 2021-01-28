# (FPCore
#  (x r lat lon)
#  :name
#  "sphere"
#  :cite
#  (solovyev-et-al-2015)
#  :precision
#  binary64
#  :pre
#  (and (<= -10 x 10)
#       (<= 0 r 10)
#       (<= -392699/250000 lat 392699/250000)
#       (<= -62831853/20000000 lon 62831853/20000000))
#  (let ((sinLat (sin lat)) (cosLon (cos lon))) (+ x (* (* r sinLat) cosLon))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
x = DataVariable("x","real",@interval(-10,10))
r = DataVariable("r","real",@interval(0,10))
lat = DataVariable("lat","real",@interval(-392699/250000,392699/250000))
lon = DataVariable("lon","real",@interval(-62831853/20000000,62831853/20000000))
eps = DataConstant("eps","real",10^-10) 

variables = [y, x, r, lat, lon]
constants = []

C = DataConstraint("C_sphere",
                   constants,
                   variables,
                   "=",
                   y,
                   DataBinaryOperation("+",
                                       x,
                                       DataBinaryOperation("*",
                                                           DataBinaryOperation("*",
                                                                               r,
                                                                               DataUnaryOperation("sin",
                                                                                                  lat)),
                                                           DataUnaryOperation("cos",
                                                                              lon))),
                   eps)

test(C, variables, constants, ARGS)
