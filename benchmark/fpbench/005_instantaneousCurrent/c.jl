# (FPCore
#  (t resistance frequency inductance maxVoltage)
#  :name
#  "instantaneousCurrent"
#  :pre
#  (and (<= 0 t 300)
#       (<= 1 resistance 50)
#       (<= 1 frequency 100)
#       (<= 1/1000 inductance 1/250)
#       (<= 1 maxVoltage 12))
#  (let* ((pi 314159265359/100000000000)
#         (impedance_re resistance)
#         (impedance_im (* (* (* 2 pi) frequency) inductance))
#         (denom (+ (* impedance_re impedance_re) (* impedance_im impedance_im)))
#         (current_re (/ (* maxVoltage impedance_re) denom))
#         (current_im (/ (- (* maxVoltage impedance_im)) denom))
#         (maxCurrent
#          (sqrt (+ (* current_re current_re) (* current_im current_im))))
#         (theta (atan (/ current_im current_re))))
#    (* maxCurrent (cos (+ (* (* (* 2 pi) frequency) t) theta)))))

using IntervalArithmetic
using DataStructure
using BenchTest

y = DataVariable("y","real",@interval(-Inf,+Inf))
t = DataVariable("t","real",@interval(0,300))
resistance = DataVariable("resistance","real",@interval(1,50))
frequency = DataVariable("frequency","real",@interval(1,100))
inductance = DataVariable("inductance","real",@interval(1/1000,1/250))
maxVoltage = DataVariable("maxVoltage","real",@interval(1,12))
c1 = DataConstant("c1","int",2)
c2 = DataConstant("c2","real",314159265359/100000000000)
eps = DataConstant("eps","real",10^-10) 

variables = [y, t, resistance, frequency, inductance]
constants = [c1,c2]

C = DataConstraint("C_instantaneousCurrent",
                   constants,
                   variables,
                   "=",
                   y,
                   DataUnaryOperation("cos",
                                      DataBinaryOperation("+",
                                                          DataBinaryOperation("*",
                                                                              DataBinaryOperation("*",
                                                                                                  DataBinaryOperation("*",
                                                                                                                      c1,
                                                                                                                      c2),
                                                                                                  frequency),
                                                                              t),
                                                          DataUnaryOperation("atan",
                                                                             DataBinaryOperation("/",
                                                                                                 DataBinaryOperation("*",
                                                                                                                     DataBinaryOperation("*",
                                                                                                                                         DataBinaryOperation("*",
                                                                                                                                                             c1,
                                                                                                                                                             c2),
                                                                                                                                         frequency),
                                                                                                                     inductance),
                                                                                                 resistance)))),
                   eps)

test(C, variables, constants, ARGS)
