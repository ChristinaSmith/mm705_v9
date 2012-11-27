// FTop_dp705.bsv - the top level module
// Copyright (c) 2012 Atomic Rules LLC - ALL RIGHTS RESERVED
// Christina Smith

import MLDefs          ::*; //sls: Keep your local imports separate from the BSV ones, so you stay aware
import MLProducer      ::*;
import MLConsumer      ::*;
import Sender          ::*;
import Receiver        ::*;
import FDU             ::*;
import FAU             ::*;
import MergeForkFDU    ::*;
import MergeForkFAU    ::*;
import AckTracker      ::*;
import AckAggregator   ::*;

import Clocks          ::*;
import Connectable     ::*;
import FIFO            ::*;
import ClientServer    ::*;
import GetPut          ::*;

module mkFTop_mm705(Empty);

Reg#(Bit#(32)) cycleCount <- mkReg(0);
FIFO#(MLMesg) prodMergeF  <- mkFIFO;
FIFO#(MLMesg) consForkF   <- mkFIFO;
Reg#(Bool)    meta        <- mkReg(True);
Reg#(Bool)    data        <- mkReg(True);
Reg#(UInt#(32)) count     <- mkReg(0);
Reg#(UInt#(32)) length    <- mkRegU;

// sls: specify these once
UInt#(32)  mLength = 8000;
LengthMode lMode   = Constant; // Incremental;
//LengthMode lMode   = Incremental;
DataMode   dMode   = ZeroOrigin;

// sls: It appears that
// producer1 is the source that we generating in the Generator
// producer2 is the source that we are comparing against in the Checker

// sls: After you have the consumer only comparing valid bytes; switch producer2
// to insert 0xEE to test...

MLProducerIfc   producer1  <- mkMLProducer(mLength, lMode, 0, 0, dMode, 8'hAA);
MLProducerIfc   producer2  <- mkMLProducer(mLength, lMode, 0, 0, dMode, 8'hEE);
MLConsumerIfc   consumer   <- mkMLConsumer;
SenderIfc       sender     <- mkSender;
ReceiverIfc     receiver   <- mkReceiver;
FDUIfc          fdu        <- mkFDU;
FAUIfc          fau        <- mkFAU;
MergeForkFDUIfc    mfFDU         <- mkMergeForkFDU;
MergeForkFAUIfc    mfFAU         <- mkMergeForkFAU;
AckTrackerIfc   ackTracker <- mkAckTracker;
AckAggregatorIfc ackAggregator <- mkAckAggregator;

rule countCycles;
  cycleCount <= cycleCount + 1;
  if(cycleCount%100==0)$display("[%0d] simulation cycle:%0d ...", $time, cycleCount);
endrule

rule endSim;
  if(cycleCount == 15000)begin $display("Terminating Simulation..."); $finish; end
endrule

// MLProducer (payload source) to Sender
mkConnection(producer1.mesg, sender.mesg);

// Sender to FDU#1
mkConnection(sender.datagram, fdu.datagramSnd);

// FDU#1 to MergeForkFDU
mkConnection(fdu.datagramRcv, mfFDU.ingress);

// FDU#1 to AckTracker
mkConnection(fdu.frameAck, ackTracker.frameAck);

// MergeForkFDU to AckTracker
mkConnection(mfFDU.ack, ackTracker.ackIngress);

// MergeForkFDU to MergeForkFAU
mkConnection(mfFDU.egress, mfFAU.ingress);

// MergeForkFAU to FAU#1
mkConnection(mfFAU.egress, fau.ingress);

// AckAggregator to MergeForkFAU
mkConnection(ackAggregator.ackEgress, mfFAU.ack);

// FAU#1 to AckAggregator
mkConnection(fau.frameAck, ackAggregator.frameAck);

// FAU#1 to Receiver
mkConnection(fau.egress, receiver.datagram);

// Receiver to Consumer
mkConnection(receiver.mesg, consumer.mesgReceived);

// MLProducer (checker) to Consumer
mkConnection(producer2.mesg, consumer.mesgExpected);



endmodule
