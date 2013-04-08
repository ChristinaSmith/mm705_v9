// FTop_mm705.bsv - the top level module
// Copyright (c) 2012 Atomic Rules LLC - ALL RIGHTS RESERVED
// Christina Smith

import MLDefs          ::*; 
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
import HBDG2QABS       ::*;
import ForkSnd         ::*;

import Clocks          ::*;
import Connectable     ::*;
import FIFO            ::*;
import ClientServer    ::*;
import GetPut          ::*;

module mkFTop_mm705(Empty);

Reg#(Bit#(32)) cycleCount <- mkReg(0);

UInt#(32)  mLength = 0;
//LengthMode lMode   = Incremental; 
LengthMode lMode   = Constant; 
DataMode   dMode   = ZeroOrigin;

// producer1 is the source that we generating in the Generator
// producer2 is the source that we are comparing against in the Checker

MLProducerIfc      producer1      <- mkMLProducer(mLength, lMode, 0, 0, dMode, 8'hAA);
MLProducerIfc      producer2      <- mkMLProducer(mLength, lMode, 0, 0, dMode, 8'hEE);
MLConsumerIfc      consumer       <- mkMLConsumer;
SenderIfc          sender         <- mkSender;
ReceiverIfc        receiver       <- mkReceiver;
FDUIfc             fdu            <- mkFDU;
FAUIfc             fau            <- mkFAU;
MergeForkFDUIfc    mfFDU          <- mkMergeForkFDU;
MergeForkFAUIfc    mfFAU          <- mkMergeForkFAU;
AckTrackerIfc      ackTracker     <- mkAckTracker;
AckAggregatorIfc   ackAggregator  <- mkAckAggregator;
ForkSndIfc         forkSnd        <- mkForkSnd;
//HBDG2QABSIfc       hbdg2qabs      <- mkHBDG2QABS;

rule countCycles;
  cycleCount <= cycleCount + 1;
  if(cycleCount%100==0)$display("[%0d] simulation cycle:%0d ...", $time, cycleCount);
endrule

rule endSim;
  if(cycleCount == 1500)begin $display("Terminating Simulation..."); $finish; end
endrule

// MLProducer (payload source) to Sender
mkConnection(producer1.mesg, sender.mesg);

// Sender to ForkSnd
mkConnection(sender.datagram, forkSnd.datagramRcv);

// ForkSnd to FDU#1 Datagram
mkConnection(forkSnd.datagramSnd, fdu.datagramSnd);

// ForkSnd to FDU#1 free
mkConnection(forkSnd.free, fdu.free);

// FDU#1 to MergeForkFDU
mkConnection(fdu.datagramRcv, mfFDU.ingress);

// FDU#1 to AckTracker
mkConnection(fdu.frameAck, ackTracker.frameAck);

// MergeForkFDU to AckTracker
mkConnection(mfFDU.ack, ackTracker.ackIngress);

/////////////////// WIRE HERE ///////////////////////
// MergeForkFDU to HBDG2QABS
//mkConnection(mfFDU.egress.request, hbdg2qabs.hbdg); 

// MergeForkFDU to MergeForkFAU
mkConnection(mfFDU.egress, mfFAU.ingress);
////////////////// END WIRE /////////////////////////

// MergeForkFAU to FAU
mkConnection(mfFAU.egress, fau.ingress);

// AckAggregator to MergeForkFAU
mkConnection(ackAggregator.ackEgress, mfFAU.ack);

// FAU to AckAggregator
mkConnection(fau.frameAck, ackAggregator.frameAck);

// FAU to Receiver
mkConnection(fau.egress, receiver.datagram);

// Receiver to Consumer
mkConnection(receiver.mesg, consumer.mesgReceived);

// Producer (control) to Consumer
mkConnection(consumer.mesgExpected, producer2.mesg);


endmodule
