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

interface AckTrackerIfc;
  interface Server#(UInt#(16), UInt#(16)) frameAck;
  interface Put#(HexBDG) ackIngress;
endinterface

(* synthesize *)
module mkAckTracker(AckTrackerIfc);

FIFO#(UInt#(16))             fidIngressF        <- mkFIFO;
FIFO#(UInt#(16))             fidEgressF         <- mkFIFO;
FIFO#(HexBDG)                ackIngressF        <- mkFIFO;
FIFO#(UInt#(16))             fidF               <- mkFIFO;

rule getFID;
  HexByte y = ackIngressF.first.data;
  ackIngressF.deq;
  fidF.enq(unpack({pack(y[6]),pack(y[7])}));      // AckStart value (fid being acked)
endrule


rule checkAckFDU0(fidIngressF.first == fidF.first);
  $display("AckTracker: ack received for frame %0x", fidF.first);
  fidIngressF.deq;                               // deq fid from FDU fifo
  fidEgressF.enq(fidF.first);                    // give FDU the fid we acked
  fidF.deq;
endrule


interface Server frameAck;
  interface request = toPut(fidIngressF);
  interface response = toGet(fidEgressF); 
endinterface
interface ackIngress = toPut(ackIngressF);
endmodule
