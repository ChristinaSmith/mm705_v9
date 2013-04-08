// ForkSnd.bsv - used to multiplex frame to free FDU
// Copyright (c) 2013 Atomic Rules LLC - ALL RIGHTS RESERVED
// Written by: Christina Smith 4/8/13

import GetPut     ::*;
import FIFOF      ::*;
import FIFO       ::*;

import DPPDefs    ::*;
import MLDefs     ::*;


interface ForkSndIfc;
  interface Get#(HexBDG) datagramRcv;
  interface Put#(HexBDG) datagramSnd;
  interface Get#(FIFOF#(Bit#(0))) free;
endinterface

//(* synthesize *)
module mkForkSnd(ForkSndIfc);

FIFOF#(Bit#(0)) freeF               <- mkFIFOF1;
FIFO#(HexBDG)   datagramIngressF    <- mkFIFO;
FIFO#(HexBDG)   datagramEgressF     <- mkFIFO;

rule muxFrame(freeF.notEmpty);      // when we have an FDU available...
  let y = datagramIngressF.first;   // grab HexBDG of frame
  Bool isEOP = y.isEOP;             // check it for EOP
  datagramEgressF.enq(y);           // enq it out to FDU
  datagramIngressF.deq;             // deq the HexBDG
  if(isEOP) freeF.deq;              // on EOP, close connection to FDU
endrule

interface free = toGet(freeF);
interface datagramRcv = toGet(datagramIngressF);
interface datagramSnd = toPut(datagramEgressF);

endmodule
