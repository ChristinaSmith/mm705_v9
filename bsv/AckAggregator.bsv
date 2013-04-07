// AckTracker.bsv
// Copyright (c) 2012 Atomic Rules LLC - ALL RIGHTS RESERVED
// Christina Smith

import GetPut     ::*;
import FIFO       ::*;
import FIFOF      ::*;
import Vector     ::*;
import BRAM       ::*;
import List       ::*;

import Accum      ::*;
import DPPDefs    ::*;
import MLDefs     ::*;

interface AckAggregatorIfc;
  interface Put#(UInt#(16)) frameAck;
  interface Get#(HexBDG) ackEgress;
endinterface

(* synthesize *)
module mkAckAggregator(AckAggregatorIfc);

FIFO#(UInt#(16))             fidIngressF        <- mkFIFO;
FIFO#(HexBDG)                ackEgressF         <- mkFIFO;
FIFO#(UInt#(16))             numFrmsF           <- mkFIFO;
Reg#(UInt#(16))              fsCnt              <- mkReg(1000);
//Reg#(Bool)                   dropAck       <- mkReg(True);

// dropAck logic used to test retransmission, should be excluded under normal operating conditions

rule sendAck;
  Vector#(10, Bit#(8)) fhV = toByteVector(DPPFrameHeader{did:3,sid:4,fs:fsCnt,as:fidIngressF.first,ac:1,f:0}); //create ack frame
//  if(!dropAck) begin   
    ackEgressF.enq(HexBDG{data: padHexByte(fhV), nbVal: 10, isEOP: True});         // send ack back to FDU
    fsCnt <= fsCnt + 1;                                                            // increase fid local to FAU
    $display("AckAggregator: ack sent for frame %0x",fidIngressF.first);
//  end
//  dropAck <= False;                                                                
  fidIngressF.deq;
endrule  

interface frameAck = toPut(fidIngressF);
interface ackEgress = toGet(ackEgressF);
endmodule
