// MergeForkFAU.bsv
// Copyright (c) 2012 Atomic Rules LLC - ALL RIGHTS RESERVED
// Christina Smith
// FIXME!! Adding and removing L2 header should not be in the same module that merges and forks!!
import GetPut     ::*;
import FIFO       ::*;
import FIFOF      ::*;
import Vector     ::*;
import ClientServer ::*;

import DPPDefs    ::*;
import MLDefs     ::*;

interface MergeForkFAUIfc;
  interface Server#(HexBDG, HexBDG) ingress;
  interface Get#(HexBDG) egress;
  interface Put#(HexBDG) ack;
endinterface

(* synthesize *)
module mkMergeForkFAU(MergeForkFAUIfc);

FIFO#(HexBDG)                datagramIngressF   <- mkFIFO;
FIFO#(HexBDG)                datagramEgressF    <- mkFIFO;
FIFOF#(HexBDG)               ackIngressF        <- mkFIFOF;
FIFO#(HexBDG)                ackEgressF         <- mkFIFO;
Reg#(Vector#(6, Bit#(8)))    macSrc             <- mkReg(unpack('h000102030405));
Reg#(Vector#(6, Bit#(8)))    macDst             <- mkReg(unpack('h050403020100));
Reg#(Vector#(2, Bit#(8)))    ethType            <- mkReg(unpack('h3333));
Reg#(Bool)                   isDGheader         <- mkReg(True);
Reg#(Bool)                   isAckHeader        <- mkReg(True);
Reg#(UInt#(16))              headerNum          <- mkReg(1);
Reg#(UInt#(16))              frameNum           <- mkReg(1);

rule rmDGheader(isDGheader);
  HexBDG l2header = datagramIngressF.first;
  datagramIngressF.deq;
  isDGheader <= False;
//  $display("MergeForkFAU: removed L2 header for frame %0x", headerNum);
 // headerNum <= headerNum + 1;
endrule

rule pumpFrame(!isDGheader);                       // Will need to multiplex multiple FDUs
  let y = datagramIngressF.first;
  if(y.isEOP) begin 
    isDGheader <= True; 
    $display("MergeForkFAU: sent frame %0x", frameNum);
    frameNum <= frameNum + 1; 
  end
  datagramEgressF.enq(y);
  datagramIngressF.deq;
endrule

rule pumpHeader(isAckHeader && ackIngressF.notEmpty);
  Vector#(12, Bit#(8)) macAddrs = append(macDst, macSrc);
  HexBDG x = HexBDG{data: padHexByte(append(macAddrs, ethType)), nbVal: 16, isEOP: False};  // FIXME! This is totally wrong, there are really only 14 valid bytes in an L2 header. 
  ackEgressF.enq(x);
  isAckHeader <= False;
endrule

rule pumpAck(!isAckHeader);                        // Ack will always go to AckTracker
  let y = ackIngressF.first;
  if(y.isEOP)isAckHeader <= True;
  ackEgressF.enq(y);
  ackIngressF.deq;
endrule


interface egress = toGet(datagramEgressF);
interface ack = toPut(ackIngressF);
  
interface Server ingress;
  interface request = toPut(datagramIngressF); 
  interface response = toGet(ackEgressF); 
endinterface
endmodule
