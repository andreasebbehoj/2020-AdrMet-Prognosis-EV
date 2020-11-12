***** 1_Setup.do *****
version 16
clear all
file close _all

set more off

*** Generate necessary folders
capture: mkdir data
capture: mkdir results


*** Install necessary packages
/*
net install github, from("https://haghish.github.io/github/")
github install andreasebbehoj/dstpop
ssc install grstyle, replace
ssc install palettes, replace
ssc install colrspace, replace
ssc install asdoc, replace
*/

