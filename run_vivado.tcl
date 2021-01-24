read_xdc Basys-3-Master.xdc
read_edif HUB75Driver.edif
link_design -part xc7a35tcpg236-1 -top HUB75Driver
opt_design
place_design
route_design
report_utilization
report_timing
write_bitstream -force HUB75Driver.bit
