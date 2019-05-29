onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/DUT/clk
add wave -noupdate -group {Input Memory Signals} -radix hexadecimal /tb_top/DUT/inputMem/rd_en
add wave -noupdate -group {Input Memory Signals} -radix hexadecimal /tb_top/DUT/inputMem/rd_addr
add wave -noupdate -group {Input Memory Signals} -radix hexadecimal /tb_top/DUT/inputMem/rd_data
add wave -noupdate -group {Weight Memory Signals} -radix hexadecimal /tb_top/DUT/weightMem/rd_en
add wave -noupdate -group {Weight Memory Signals} -radix hexadecimal /tb_top/DUT/weightMem/rd_addr
add wave -noupdate -group {Weight Memory Signals} -radix hexadecimal /tb_top/DUT/weightMem/rd_data
add wave -noupdate -expand -group {FIFO Signals} -radix hexadecimal /tb_top/DUT/weightFIFO/en
add wave -noupdate -expand -group {FIFO Signals} -radix hexadecimal /tb_top/DUT/weightFIFO/weightIn
add wave -noupdate -expand -group {FIFO Signals} -radix hexadecimal /tb_top/DUT/weightFIFO/weightOut
add wave -noupdate -expand -group {One Column of Weights} -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[15]/genblk1/last_sysArrRow_inst/genblk1[13]/genblk1/pe_inst/weight}
add wave -noupdate -expand -group {One Column of Weights} -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[14]/genblk1/sysArrRow_inst/genblk1[13]/genblk1/pe_inst/weight}
add wave -noupdate -expand -group {One Column of Weights} -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[13]/genblk1/sysArrRow_inst/genblk1[13]/genblk1/pe_inst/weight}
add wave -noupdate -expand -group {One Column of Weights} -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[12]/genblk1/sysArrRow_inst/genblk1[13]/genblk1/pe_inst/weight}
add wave -noupdate -expand -group {One Column of Weights} -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[11]/genblk1/sysArrRow_inst/genblk1[13]/genblk1/pe_inst/weight}
add wave -noupdate -expand -group {One Column of Weights} -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[10]/genblk1/sysArrRow_inst/genblk1[13]/genblk1/pe_inst/weight}
add wave -noupdate -expand -group {One Column of Weights} -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[9]/genblk1/sysArrRow_inst/genblk1[13]/genblk1/pe_inst/weight}
add wave -noupdate -expand -group {One Column of Weights} -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[8]/genblk1/sysArrRow_inst/genblk1[13]/genblk1/pe_inst/weight}
add wave -noupdate -expand -group {One Column of Weights} -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[7]/genblk1/sysArrRow_inst/genblk1[13]/genblk1/pe_inst/weight}
add wave -noupdate -expand -group {One Column of Weights} -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[6]/genblk1/sysArrRow_inst/genblk1[13]/genblk1/pe_inst/weight}
add wave -noupdate -expand -group {One Column of Weights} -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[5]/genblk1/sysArrRow_inst/genblk1[13]/genblk1/pe_inst/weight}
add wave -noupdate -expand -group {One Column of Weights} -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[4]/genblk1/sysArrRow_inst/genblk1[13]/genblk1/pe_inst/weight}
add wave -noupdate -expand -group {One Column of Weights} -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[3]/genblk1/sysArrRow_inst/genblk1[13]/genblk1/pe_inst/weight}
add wave -noupdate -expand -group {One Column of Weights} -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[2]/genblk1/sysArrRow_inst/genblk1[13]/genblk1/pe_inst/weight}
add wave -noupdate -expand -group {One Column of Weights} -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[1]/genblk1/sysArrRow_inst/genblk1[13]/genblk1/pe_inst/weight}
add wave -noupdate -expand -group {One Column of Weights} -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[0]/genblk1/first_sysArrRow_inst/genblk1[13]/genblk1/pe_inst/weight}
add wave -noupdate -expand -group MACCs -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[15]/genblk1/last_sysArrRow_inst/maccout}
add wave -noupdate -expand -group MACCs -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[14]/genblk1/sysArrRow_inst/maccout}
add wave -noupdate -expand -group MACCs -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[13]/genblk1/sysArrRow_inst/maccout}
add wave -noupdate -expand -group MACCs -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[12]/genblk1/sysArrRow_inst/maccout}
add wave -noupdate -expand -group MACCs -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[11]/genblk1/sysArrRow_inst/maccout}
add wave -noupdate -expand -group MACCs -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[10]/genblk1/sysArrRow_inst/maccout}
add wave -noupdate -expand -group MACCs -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[9]/genblk1/sysArrRow_inst/maccout}
add wave -noupdate -expand -group MACCs -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[8]/genblk1/sysArrRow_inst/maccout}
add wave -noupdate -expand -group MACCs -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[7]/genblk1/sysArrRow_inst/maccout}
add wave -noupdate -expand -group MACCs -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[6]/genblk1/sysArrRow_inst/maccout}
add wave -noupdate -expand -group MACCs -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[5]/genblk1/sysArrRow_inst/maccout}
add wave -noupdate -expand -group MACCs -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[4]/genblk1/sysArrRow_inst/maccout}
add wave -noupdate -expand -group MACCs -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[3]/genblk1/sysArrRow_inst/maccout}
add wave -noupdate -expand -group MACCs -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[2]/genblk1/sysArrRow_inst/maccout}
add wave -noupdate -expand -group MACCs -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[1]/genblk1/sysArrRow_inst/maccout}
add wave -noupdate -expand -group MACCs -radix hexadecimal {/tb_top/DUT/sysArr/genblk1[0]/genblk1/first_sysArrRow_inst/maccout}
add wave -noupdate -group {Output Memory} -radix hexadecimal /tb_top/DUT/outputMem/wr_en
add wave -noupdate -group {Output Memory} -radix hexadecimal /tb_top/DUT/outputMem/wr_data
add wave -noupdate -group {Output Memory} -radix hexadecimal /tb_top/DUT/outputMem/wr_addr
add wave -noupdate -expand -group {Done Signals} /tb_top/DUT/mem_to_fifo_done
add wave -noupdate -expand -group {Done Signals} /tb_top/DUT/fifo_to_arr_done
add wave -noupdate -expand -group {Done Signals} /tb_top/DUT/output_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {385 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 580
configure wave -valuecolwidth 207
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {536 ps} {961 ps}
