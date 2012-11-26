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

interface MergeForkFAUIfc;
  interface Server#(HexBDG, HexBDG) ingress;
  interface Get#(HexBDG) egress;
  interface Put#(HexBDG) ack;
endinterface

(* synthesize *)
module mkMergeForkFAU(MergeForkFAUIfc);

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


interface egress = toGet(datagramEgressF);//TODO:input FIFO
interface ack = toPut(ackIngressF); // TODO: to be used for ACKS
  
interface Server ingress;
  interface request = toPut(datagramIngressF); //TODO: output FIFO
  interface response = toGet(ackEgressF); //TODO: to be used for ACKS
endinterface
endmodule
