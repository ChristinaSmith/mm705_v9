// FTop_mm705_toBit.bsv - the top level module
// Copyright (c) 2012 Atomic Rules LLC - ALL RIGHTS RESERVED
// Christina Smith

import MLDefs          ::*; 
import MLProducer      ::*;
import MLConsumer      ::*;
import SenderDM1       ::*;
import SenderDM2       ::*;
import Receiver        ::*;
import FDU             ::*;
import FAU             ::*;
import MergeForkFDU    ::*;
import MergeForkFAU    ::*;
import AckTracker      ::*;
import AckAggregatorDM1   ::*;
import AckAggregatorDM2   ::*;
import HBDG2QABS       ::*;
import ForkSnd         ::*;
import MergeRcv        ::*;
import MergeToWireDM1  ::*;
import MergeToWireDM2  ::*;
//import MDIO            ::*;
//import GbeQABS         ::*;
//import GMAC            ::*;
//import E8023           ::*;
//import HBDG2QABS       ::*;

import Clocks          ::*;
import Connectable     ::*;
import FIFO            ::*;
import ClientServer    ::*;
import GetPut          ::*;
import Clocks          ::*;
import XilinxExtra     ::*;
import XilinxCells     ::*;
import Vector          ::*;

interface FTop_mm705Ifc;
//  interface Reset                   gmii_rstn;           // GMII Reset driven out to Phy
//  interface GMII_RS                 gmii;                // The GMII link RX/TX
//  interface Clock                   rxclkBnd;            // GMII Rx Clock (Provided here for BSV interface rules)
//  interface MDIO_Pads               mdio;                // MDIO pads
  (* always_ready *) method Bit#(8) ledOut;  
endinterface

(* synthesize, default_clock_osc = "sys0_clk", default_reset = "sys0_rstn" *)
//module mkFTop_mm705#(Clock sys1_clkp, Clock sys1_clkn,  // 125 MHz Ethernet XO Reference
 //                    Clock gmii_rx_clk)(FTop_mm705Ifc); // 125 MHz GMII RX Clock from Marvell Phy
module mkFTop_mm705(FTop_mm705Ifc);

Clock               cc             <- exposeCurrentClock;
Reset               rstndb         <- mkAsyncResetFromCR(16, cc);

//Clock               sys1_clki      <- mkClockIBUFDS_GTE2(True, sys1_clkp, sys1_clkn);
//Clock               sys1_clk       <- mkClockBUFG(clocked_by sys1_clki);
//Reset               sys1_rst       <- mkAsyncReset(1, rstndb, sys1_clk);
IDELAYCTRL          idc            <- mkMYIDELAYCTRL(1);

UInt#(32)  mLength = 8000;
LengthMode lMode   = Constant;
DataMode   dMode   = ZeroOrigin;

// producer1 is the source that we generating in the Generator
// producer2 is the source that we are comparing against in the Checker

////////////// Sender for DM1 ///////////////////
MLProducerIfc      producer1DM1      <- mkMLProducer(reset_by rstndb, mLength, lMode, 0, 0, dMode, 8'hAA);
SenderDM1Ifc       senderDM1         <- mkSenderDM1(reset_by rstndb);
FDUIfc             fdu1DM1           <- mkFDU(reset_by rstndb);
FDUIfc             fdu2DM1           <- mkFDU(reset_by rstndb);
MergeForkFDUIfc    mfFDUDM1          <- mkMergeForkFDU(reset_by rstndb);
AckTrackerIfc      ackTrackerDM1     <- mkAckTracker(reset_by rstndb);
ForkSndIfc         forkSndDM1        <- mkForkSnd(reset_by rstndb);

////////////// Receiver for DM1 /////////////////
MLProducerIfc      producer2DM1      <- mkMLProducer(reset_by rstndb, mLength, lMode, 0, 0, dMode, 8'hEE);
MLConsumerIfc      consumerDM1       <- mkMLConsumer(reset_by rstndb);
ReceiverIfc        receiverDM1       <- mkReceiver(reset_by rstndb);
FAUIfc             fau1DM1           <- mkFAU(reset_by rstndb);
FAUIfc             fau2DM1           <- mkFAU(reset_by rstndb);
MergeForkFAUIfc    mfFAUDM1          <- mkMergeForkFAU(reset_by rstndb);
AckAggregatorDM1Ifc   ackAggregatorDM1  <- mkAckAggregatorDM1(reset_by rstndb);
MergeRcvIfc        mergeRcvDM1       <- mkMergeRcv(reset_by rstndb);

////////////// Wire for DM1 /////////////////////
MergeToWireDM1Ifc  mergeWireDM1      <- mkMergeToWireDM1(reset_by rstndb);

////////////// Sender for DM2 ///////////////////
MLProducerIfc      producer1DM2      <- mkMLProducer(reset_by rstndb, mLength, lMode, 0, 0, dMode, 8'hAA);
SenderDM2Ifc       senderDM2         <- mkSenderDM2(reset_by rstndb);
FDUIfc             fdu1DM2           <- mkFDU(reset_by rstndb);
FDUIfc             fdu2DM2           <- mkFDU(reset_by rstndb);
MergeForkFDUIfc    mfFDUDM2          <- mkMergeForkFDU(reset_by rstndb);
AckTrackerIfc      ackTrackerDM2     <- mkAckTracker(reset_by rstndb);
ForkSndIfc         forkSndDM2        <- mkForkSnd(reset_by rstndb);

////////////// Receiver for DM2 /////////////////
MLProducerIfc      producer2DM2      <- mkMLProducer(reset_by rstndb, mLength, lMode, 0, 0, dMode, 8'hEE);
MLConsumerIfc      consumerDM2       <- mkMLConsumer(reset_by rstndb);
ReceiverIfc        receiverDM2       <- mkReceiver(reset_by rstndb);
FAUIfc             fau1DM2           <- mkFAU(reset_by rstndb);
FAUIfc             fau2DM2           <- mkFAU(reset_by rstndb);
MergeForkFAUIfc    mfFAUDM2          <- mkMergeForkFAU(reset_by rstndb);
AckAggregatorDM2Ifc   ackAggregatorDM2  <- mkAckAggregatorDM2(reset_by rstndb);
MergeRcvIfc        mergeRcvDM2       <- mkMergeRcv(reset_by rstndb);

////////////// Wire for DM2 /////////////////////
MergeToWireDM2Ifc     mergeWireDM2      <- mkMergeToWireDM2(reset_by rstndb);



//GbeQABSIfc          qabsFunnel     <- mkGbeQABS(False, gmii_rx_clk, sys1_clk, sys1_rst);
//HBDG2QABSIfc        hbdg2qabs      <- mkHBDG2QABS(reset_by rstndb);

Reg#(Bit#(32)) cycleCount <- mkReg(0, reset_by rstndb);

rule countCycles;
  cycleCount <= cycleCount + 1;
endrule

/////////////// Sender for DM1 ///////////////////

// MLProducer (payload source) to Sender
mkConnection(producer1DM1.mesg, senderDM1.mesg);

// Sender to ForkSnd
mkConnection(senderDM1.datagram, forkSndDM1.datagramSnd);

// ForkSnd to FDU#1 Datagram
mkConnection(forkSndDM1.datagramRcv1, fdu1DM1.datagramSnd);

// ForkSnd to FDU#1 free
mkConnection(forkSndDM1.free1, fdu1DM1.free);

// ForkSnd to FDU#2 Datagram
mkConnection(forkSndDM1.datagramRcv2, fdu2DM1.datagramSnd);

// ForkSnd to FDU#2 free
mkConnection(forkSndDM1.free2, fdu2DM1.free);

// FDU#1 to MergeForkFDU
mkConnection(fdu1DM1.datagramRcv, mfFDUDM1.ingress1);

// FDU#2 to MergeForkFDU
mkConnection(fdu2DM1.datagramRcv, mfFDUDM1.ingress2);

// FDU#1 to AckTracker
mkConnection(fdu1DM1.frameAck, ackTrackerDM1.frameAck1);

// FDU#2 to AckTracker
mkConnection(fdu2DM1.frameAck, ackTrackerDM1.frameAck2);

// MergeForkFDU to AckTracker
mkConnection(mfFDUDM1.ack, ackTrackerDM1.ackIngress);

////////////////// Receiver for DM1 ////////////////////

// MergeForkFAU to FAU#1 datagram
mkConnection(mfFAUDM1.egress1, fau1DM1.ingress);

// MergeForkFAU to FAU#1 free
mkConnection(mfFAUDM1.free1, fau1DM1.free);

// MergeForkFAU to FAU#2 datagram
mkConnection(mfFAUDM1.egress2, fau2DM1.ingress);

// MergeForkFAU to FAU#2 free
mkConnection(mfFAUDM1.free2, fau2DM1.free);

// AckAggregator to MergeForkFAU
mkConnection(ackAggregatorDM1.ackEgress, mfFAUDM1.ack);

// FAU#1 to AckAggregator
mkConnection(fau1DM1.frameAck, ackAggregatorDM1.frameAck1);

// FAU#2 to AckAggregator
mkConnection(fau2DM1.frameAck, ackAggregatorDM1.frameAck2);

// FAU#1 to MergeRcv 
mkConnection(fau1DM1.egress, mergeRcvDM1.datagramRcv1);

// FAU#2 to MergeRcv 
mkConnection(fau2DM1.egress, mergeRcvDM1.datagramRcv2);

// MergeRcv to Receiver
mkConnection(mergeRcvDM1.datagramSnd, receiverDM1.datagram);

// Receiver to Consumer
mkConnection(receiverDM1.mesg, consumerDM1.mesgReceived);

// Producer (control) to Consumer
mkConnection(consumerDM1.mesgExpected, producer2DM1.mesg);

/////////////////// WIRE FOR DM1 ///////////////////////

// MergeForkFDU to MergeToWire
mkConnection(mfFDUDM1.egress, mergeWireDM1.ingressSnd);

// MergeForkFAU to MergeToWire
mkConnection(mfFAUDM1.ingress, mergeWireDM1.ingressRcv);

////////////////// Sender for DM2   ///////////////////

// MLProducer (payload source) to Sender
mkConnection(producer1DM2.mesg, senderDM2.mesg);

// Sender to ForkSnd
mkConnection(senderDM2.datagram, forkSndDM2.datagramSnd);

// ForkSnd to FDU#1 Datagram
mkConnection(forkSndDM2.datagramRcv1, fdu1DM2.datagramSnd);

// ForkSnd to FDU#1 free
mkConnection(forkSndDM2.free1, fdu1DM2.free);

// ForkSnd to FDU#2 Datagram
mkConnection(forkSndDM2.datagramRcv2, fdu2DM2.datagramSnd);

// ForkSnd to FDU#2 free
mkConnection(forkSndDM2.free2, fdu2DM2.free);

// FDU#1 to MergeForkFDU
mkConnection(fdu1DM2.datagramRcv, mfFDUDM2.ingress1);

// FDU#2 to MergeForkFDU
mkConnection(fdu2DM2.datagramRcv, mfFDUDM2.ingress2);

// FDU#1 to AckTracker
mkConnection(fdu1DM2.frameAck, ackTrackerDM2.frameAck1);

// FDU#2 to AckTracker
mkConnection(fdu2DM2.frameAck, ackTrackerDM2.frameAck2);

// MergeForkFDU to AckTracker
mkConnection(mfFDUDM2.ack, ackTrackerDM2.ackIngress);

////////////////// Receiver for DM2 ///////////////////

// MergeForkFAU to FAU#1 datagram
mkConnection(mfFAUDM2.egress1, fau1DM2.ingress);

// MergeForkFAU to FAU#1 free
mkConnection(mfFAUDM2.free1, fau1DM2.free);

// MergeForkFAU to FAU#2 datagram
mkConnection(mfFAUDM2.egress2, fau2DM2.ingress);

// MergeForkFAU to FAU#2 free
mkConnection(mfFAUDM2.free2, fau2DM2.free);

// AckAggregator to MergeForkFAU
mkConnection(ackAggregatorDM2.ackEgress, mfFAUDM2.ack);

// FAU#1 to AckAggregator
mkConnection(fau1DM2.frameAck, ackAggregatorDM2.frameAck1);

// FAU#2 to AckAggregator
mkConnection(fau2DM2.frameAck, ackAggregatorDM2.frameAck2);

// FAU#1 to MergeRcv 
mkConnection(fau1DM2.egress, mergeRcvDM2.datagramRcv1);

// FAU#2 to MergeRcv 
mkConnection(fau2DM2.egress, mergeRcvDM2.datagramRcv2);

// MergeRcv to Receiver
mkConnection(mergeRcvDM2.datagramSnd, receiverDM2.datagram);

// Receiver to Consumer
mkConnection(receiverDM2.mesg, consumerDM2.mesgReceived);

// Producer (control) to Consumer
mkConnection(consumerDM2.mesgExpected, producer2DM2.mesg);

/////////////////// WIRE FOR DM2 ///////////////////////

// MergeForkFDU to MergeToWire
mkConnection(mfFDUDM2.egress, mergeWireDM2.ingressSnd);

// MergeForkFAU to MergeToWire
mkConnection(mfFAUDM2.ingress, mergeWireDM2.ingressRcv);

////////////////// Connect DM1 and DM2 //////////////////

mkConnection(mergeWireDM1.egressWire, mergeWireDM2.egressWire);

method Bit#(8) ledOut;
  Bit#(4) y = truncate(cycleCount >> 28);
  Bit#(8) z = {y, consumerDM2.incorrectCnt};
//  Bit#(8) z = {y, 15};
  return z;
endmethod

//interface Reset     gmii_rstn = sys1_rst;
//interface GMII_RS   gmii      = qabsFunnel.gmii;
//interface Clock     rxclkBnd  = qabsFunnel.rxclkBnd;
//interface MDIO_Pads mdio      = qabsFunnel.mdio;

endmodule

