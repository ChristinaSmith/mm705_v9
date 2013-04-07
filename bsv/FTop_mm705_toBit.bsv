// FTop_mm705_toBit.bsv - the top level module
// Copyright (c) 2012 Atomic Rules LLC - ALL RIGHTS RESERVED
// Christina Smith

import MLDefs          ::*; 
import DPPDefs         ::*;
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
import MDIO            ::*;
import GbeQABS         ::*;
import GMAC            ::*;
import E8023           ::*;
import HBDG2QABS       ::*;

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

MLProducerIfc       producer1      <- mkMLProducer(reset_by rstndb, mLength, lMode, 0, 0, dMode, 8'hAA);
MLProducerIfc       producer2      <- mkMLProducer(reset_by rstndb, mLength, lMode, 0, 0, dMode, 8'hEE);
MLConsumerIfc       consumer       <- mkMLConsumer(reset_by rstndb);
SenderIfc           sender         <- mkSender(reset_by rstndb);
ReceiverIfc         receiver       <- mkReceiver(reset_by rstndb);
FDUIfc              fdu            <- mkFDU(reset_by rstndb);
FAUIfc              fau            <- mkFAU(reset_by rstndb);
MergeForkFDUIfc     mfFDU          <- mkMergeForkFDU(reset_by rstndb);
MergeForkFAUIfc     mfFAU          <- mkMergeForkFAU(reset_by rstndb);
AckTrackerIfc       ackTracker     <- mkAckTracker(reset_by rstndb);
AckAggregatorIfc    ackAggregator  <- mkAckAggregator(reset_by rstndb);
//GbeQABSIfc          qabsFunnel     <- mkGbeQABS(False, gmii_rx_clk, sys1_clk, sys1_rst);
//HBDG2QABSIfc        hbdg2qabs      <- mkHBDG2QABS(reset_by rstndb);

Reg#(Bit#(32)) cycleCount <- mkReg(0, reset_by rstndb);

rule countCycles;
  cycleCount <= cycleCount + 1;
endrule
/////////////Sender to Wire//////////////////////
// MLProducer (payload source) to Sender
//mkConnection(producer1.mesg, sender.mesg);

// Sender to FDU#1
//mkConnection(sender.datagram, fdu.datagramSnd);

// FDU#1 to MergeForkFDU
//mkConnection(fdu.datagramRcv, mfFDU.ingress);

// FDU#1 to AckTracker
//mkConnection(fdu.frameAck, ackTracker.frameAck);

// MergeForkFDU to AckTracker
//mkConnection(mfFDU.ack, ackTracker.ackIngress);

// MergeForkFDU to HBDG2QABS
//mkConnection(mfFDU.egress.request, hbdg2qabs.hbdg);

// HBDG2QABS to GbeQABS
//mkConnection(hbdg2qabs.qabs, qabsFunnel.client.response);
/////////////////Sender to Wire////////////////////

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


method Bit#(8) ledOut;
  Bit#(4) y = truncate(cycleCount >> 28);
  Bit#(8) z = {y, consumer.incorrectCnt};
//  Bit#(8) z = {y, 15};
  return z;
endmethod

//interface Reset     gmii_rstn = sys1_rst;
//interface GMII_RS   gmii      = qabsFunnel.gmii;
//interface Clock     rxclkBnd  = qabsFunnel.rxclkBnd;
//interface MDIO_Pads mdio      = qabsFunnel.mdio;

endmodule

