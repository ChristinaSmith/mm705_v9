// MergeFork.bsv
// Copyright (c) 2012 Atomic Rules LLC - ALL RIGHTS RESERVED
// Christina Smith

import GetPut     ::*;
import FIFO       ::*;
import FIFOF      ::*;
import Vector     ::*;
import BRAM       ::*;

import Accum      ::*;
import DPPDefs    ::*;
import MLDefs     ::*;

interface MergeForkFDUIfc;
  interface Client#(HexBDG, HexBDG) egress;
  interface Put#(HexBDG) ingress;
  interface Get#(HexBDG) ack;
endinterface

(* synthesize *)
module mkMergeForkFDU(MergeForkFDUIfc);

FIFO#(HexBDG)                datagramIngressF   <- mkFIFO;
FIFO#(HexBDG)                datagramEgressF    <- mkFIFO;
FIFO#(HexBDG)                ackIngressF        <- mkFIFO;
FIFO#(HexBDG)                ackEgressF         <- mkFIFO;
 
rule pumpFrame;                       // Will need to multiplex multiple FDUs
  let y = datagramIngressF.first;
  datagramEgressF.enq(y);
  datagramIngressF.deq;
endrule

rule pumpAck;                        // Ack will always go to AckTracker
  let y = ackIngressF.first;
  ackEgressF.enq(y);
  ackIngressF.deq;
endrule


interface ingress = toPut(datagramIngressF);//TODO:input FIFO
interface ack = toGet(ackEgressF); // TODO: to be used for ACKS
  
interface Client egress;
  interface request = toGet(datagramEgressF); //TODO: output FIFO
  interface response = toPut(ackIngressF); //TODO: to be used for ACKS
endinterface
endmodule
