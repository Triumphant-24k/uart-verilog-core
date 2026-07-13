# QuestaSim run script for UART loopback simulation

quit -sim
vlib work

vlog src/uart_tx.v
vlog src/uart_rx.v
vlog src/uart_loopback_top.v
vlog tb/uart_loopback_tb.v

vsim -voptargs=+acc work.uart_loopback_tb

add wave -r sim:/uart_loopback_tb/*
run -all
