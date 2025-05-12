transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/Downloads/test\ FPGA {D:/Downloads/test FPGA/uart_tx.v}
vlog -vlog01compat -work work +incdir+D:/Downloads/test\ FPGA {D:/Downloads/test FPGA/uart_rx.v}
vlog -vlog01compat -work work +incdir+D:/Downloads/test\ FPGA {D:/Downloads/test FPGA/invert_uart_transceiver_test.v}
vlog -vlog01compat -work work +incdir+D:/Downloads/test\ FPGA {D:/Downloads/test FPGA/tb_invert_uart_transceiver_test.v}
vlog -vlog01compat -work work +incdir+D:/Downloads/test\ FPGA {D:/Downloads/test FPGA/binary_to_7seg.v}

