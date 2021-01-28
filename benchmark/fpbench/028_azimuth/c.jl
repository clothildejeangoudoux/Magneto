# (FPCore
#  (lat1 lat2 lon1 lon2)
#  :name
#  "azimuth"
#  :cite
#  (solovyev-et-al-2015)
#  :precision
#  binary64
#  :pre
#  (and (<= 0 lat1 2/5)
#       (<= 1/2 lat2 1)
#       (<= 0 lon1 62831853/20000000)
#       (<= -62831853/20000000 lon2 -1/2))
#  (let ((dLon (- lon2 lon1)))
#    (let ((s_lat1 (sin lat1))
#          (c_lat1 (cos lat1))
#          (s_lat2 (sin lat2))
#          (c_lat2 (cos lat2))
#          (s_dLon (sin dLon))
#          (c_dLon (cos dLon)))
#      (atan
#       (/
#        (* c_lat2 s_dLon)
#        (- (* c_lat1 s_lat2) (* (* s_lat1 c_lat2) c_dLon)))))))


using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
lat1 = DataVariable("lat1","real",@interval(0,2/5))
lat2 = DataVariable("lat2","real",@interval(1/2,1))
lon1 = DataVariable("lon1","real",@interval(0,62831853/20000000))
lon2 = DataVariable("lon2","real",@interval(-62831853/20000000,-1/2))
eps = DataConstant("eps","real",10^-10) 

variables = [y, lat1,lat2,lon1,lon2]
constants = []

C = DataConstraint("C_azimuth",
                   constants,
                   variables,
                   "=",
                   y,
                   DataUnaryOperation("atan",
                                      DataBinaryOperation("/",
                                                          DataBinaryOperation("*", DataUnaryOperation("cos",lat2), DataUnaryOperation("sin",DataBinaryOperation("-",lon2,lon1))),
                                                          DataBinaryOperation("-", DataBinaryOperation("*", DataUnaryOperation("cos",lat1), DataUnaryOperation("sin",lat2)),DataBinaryOperation("*", DataBinaryOperation("*", DataUnaryOperation("sin",lat1),DataUnaryOperation("cos",lat2)),DataBinaryOperation("-",lon2,lon1))))),
                   eps)

test(C, variables, constants, ARGS)
