iverilog $1*.v -g2012 -o $1.vvp
vvp $1.vvp -lxt2
#gtkwave $1.gtkw
