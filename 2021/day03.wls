#!/usr/bin/env wolframscript

(*--- Day 3: Binary Diagnostic ---*)

(* Functions *)
FlipBits[0] := 1
FlipBits[n_] := 2^BitLength[n] + BitNot[n] /; n > 0
MSBPosition[list_] := BitLength[Max[list]] - 1

MostCommonBit[report_, p_] := Max[Commonest[BitGet[#, p] & /@ report]]
LeastCommonBit[report_, p_] := FlipBits[MostCommonBit[report, p]]

FilterByBitCriteria[list_, c_, p_] := Select[list, BitGet[#, p] == c[list, p] &]
FindByBitCriteria[list_, c_, p_] := First[list] /; Length[list] == 1
FindByBitCriteria[list_, c_, p_] := FindByBitCriteria[FilterByBitCriteria[list, c, p], c, p - 1] /; Length[list] > 1

GammaRate[report_] := FromDigits[MostCommonBit[report, #] & /@ Reverse[Range[0, MSBPosition[report]]], 2]
OxygenGeneratorRating[report_]:= FindByBitCriteria[report, MostCommonBit, MSBPosition[report]]
CO2ScrubberRating[report_]:= FindByBitCriteria[report, LeastCommonBit, MSBPosition[report]]

(* Invoking functions *)
filename = $ScriptCommandLine[[2]]
report = FromDigits[#,2] & /@ ReadList[filename, String]

gamma = GammaRate[report]
epsilon = FlipBits[gamma]
Print[gamma*epsilon]

oxygen = OxygenGeneratorRating[report]
co2 = CO2ScrubberRating[report]
Print[oxygen*co2]

(*
  ./day03.wls "inputs/input03.txt"
  3969000
  4267809
*)
