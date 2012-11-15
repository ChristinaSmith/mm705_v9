
L
-Analyzing %s Unisim elements for replacement
17*netlist2
180Z29-17
O
2Unisim Transformation completed in %s CPU seconds
28*netlist2
0Z29-28
•
Loading clock regions from %s
13*device2^
\/opt/Xilinx/14.3/ISE_DS/PlanAhead/data/parts/xilinx/kintex7/kintex7/xc7k325t/ClockRegion.xmlZ21-13
–
Loading clock buffers from %s
11*device2_
]/opt/Xilinx/14.3/ISE_DS/PlanAhead/data/parts/xilinx/kintex7/kintex7/xc7k325t/ClockBuffers.xmlZ21-11
’
&Loading clock placement rules from %s
318*place2R
P/opt/Xilinx/14.3/ISE_DS/PlanAhead/data/parts/xilinx/kintex7/ClockPlacerRules.xmlZ30-318

)Loading package pin functions from %s...
17*device2N
L/opt/Xilinx/14.3/ISE_DS/PlanAhead/data/parts/xilinx/kintex7/PinFunctions.xmlZ21-17
’
Loading package from %s
16*device2a
_/opt/Xilinx/14.3/ISE_DS/PlanAhead/data/parts/xilinx/kintex7/kintex7/xc7k325t/ffg900/Package.xmlZ21-16
…
Loading io standards from %s
15*device2O
M/opt/Xilinx/14.3/ISE_DS/PlanAhead/data/./parts/xilinx/kintex7/IOStandards.xmlZ21-15
‘
+Loading device configuration modes from %s
14*device2M
K/opt/Xilinx/14.3/ISE_DS/PlanAhead/data/parts/xilinx/kintex7/ConfigModes.xmlZ21-14
Œ
/Loading list of drcs for the architecture : %s
17*drc2G
E/opt/Xilinx/14.3/ISE_DS/PlanAhead/data/./parts/xilinx/kintex7/drc.xmlZ23-17
˜
Parsing XDC File [%s]
179*designutils2b
`/home/cms/projects/mm705/mm705/mm705.runs/impl_2/.Xil/Vivado-9752-core980/dcp/fpgaTop_routed.xdcZ20-179
¡
Finished Parsing XDC File [%s]
178*designutils2b
`/home/cms/projects/mm705/mm705/mm705.runs/impl_2/.Xil/Vivado-9752-core980/dcp/fpgaTop_routed.xdcZ20-178
6
Reading XDEF placement.
206*designutilsZ20-206
4
Reading XDEF routing.
207*designutilsZ20-207
¨
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
Read XDEF File: 2
00:00:00.642
00:00:00.642	
554.6292
0.000Z17-268
3
Restoring placement.
754*designutilsZ20-754
–
ORestored %s out of %s XDEF sites from archive | CPU: %s secs | Memory: %s MB |
403*designutils2
35362
35362

2.3400002
	27.672836Z20-403
€
!Unisim Transformation Summary:
%s111*project2Ã
À  A total of 5426 instances were transformed.
  FD => FDCE: 2202 instances
  FDC => FDCE: 16 instances
  FDE => FDCE: 2301 instances
  FDR => FDRE: 856 instances
  FDS => FDSE: 4 instances
  IBUFGDS => IBUFDS: 1 instances
  RAM32M => RAM32M (RAMD32, RAMD32, RAMD32, RAMD32, RAMD32, RAMD32, RAMS32, RAMS32): 46 instances
Z1-111
1
%Phase 0 | Netlist Checksum: 36add98c
*common
¥
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
read_checkpoint: 2

00:00:142

00:00:142	
554.6292	
408.969Z17-268
w
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2
Implementation2

xc7k325tZ17-347
g
0Got license for feature '%s' and/or device '%s'
310*common2
Implementation2

xc7k325tZ17-349
]
,Running DRC as a precondition to command %s
1349*	planAhead2
write_bitstreamZ12-1349
5
Running DRC with %s threads
24*drc2
4Z23-27
4
Loading data files...
1165*	planAheadZ12-1165
3
Loading site data...
1167*	planAheadZ12-1167
4
Loading route data...
1166*	planAheadZ12-1166
4
Processing options...
1514*	planAheadZ12-1514
1
Creating bitmap...
1141*	planAheadZ12-1141
.
Creating bitstream...
7*	bitstreamZ40-7
C
Writing bitstream %s...
11*	bitstream2
./fpgaTop.bitZ40-11
=
Bitgen Completed Successfully.
1606*	planAheadZ12-1842
?
Releasing license: %s
83*common2
ImplementationZ17-83
¥
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
write_bitstream: 2

00:01:072

00:01:052	
894.1172	
339.488Z17-268


End Record