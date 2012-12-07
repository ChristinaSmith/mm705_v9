// FTop_mm705_toBit.bsv - the top level module
// Copyright (c) 2012 Atomic Rules LLC - ALL RIGHTS RESERVED
// Christina Smith

import MLDefs          ::*; 
import DPPDefs         ::*;
import E8023           ::*;

import Clocks          ::*;
import Connectable     ::*;
import FIFO            ::*;
import ClientServer    ::*;
import GetPut          ::*;
import Clocks          ::*;
import XilinxExtra     ::*;
import XilinxCells     ::*;
import Vector          ::*;

interface HBDG2QABSIfc;
  interface Put#(HexBDG) hbdg;
  interface Get#(QABS)   qabs;
endinterface

(* synthesize *)
module mkHBDG2QABS(HBDG2QABSIfc); 

FIFO#(QABS)    qabsF   <- mkFIFO;
FIFO#(HexBDG)  hexbdgF <- mkFIFO;
Reg#(UInt#(5))  index   <- mkReg(0);
Reg#(UInt#(5)) nbVal   <- mkReg(0);
//(* descending_urgency= "funnel, drain" *)
rule funnel;
  HexBDG hbdgIn = hexbdgF.first;
//  nbVal <= hbdgIn.nbVal;
  Bool eop = hbdgIn.isEOP;
  if((hbdgIn.nbVal - index) < 4 || index == 12) hexbdgF.deq;
  QABS out = ?;
  if((hbdgIn.nbVal - index) > 4) begin
    out[0] = tagged ValidNotEOP hbdgIn.data[index]; 
    out[1] = tagged ValidNotEOP hbdgIn.data[index + 1]; 
    out[2] = tagged ValidNotEOP hbdgIn.data[index + 2]; 
    out[3] = (eop) ? tagged ValidEOP hbdgIn.data[index + 3] : tagged ValidNotEOP hbdgIn.data[index + 3]; 
  end
  else begin
    out[0] = (eop) ? tagged ValidEOP hbdgIn.data[index]     : tagged ValidNotEOP hbdgIn.data[index];     // these indecies are wrong 
    out[1] = (eop) ? tagged ValidEOP hbdgIn.data[index + 1] : tagged ValidNotEOP hbdgIn.data[index + 1]; 
    out[2] = (eop) ? tagged ValidEOP hbdgIn.data[index + 2] : tagged ValidNotEOP hbdgIn.data[index + 2]; 
    out[3] = (eop) ? tagged ValidEOP hbdgIn.data[index + 3] : tagged ValidNotEOP hbdgIn.data[index + 3]; 
  end
  index <= (index == 12 || (hbdgIn.nbVal - index) < 4) ? 0 : (eop) ? 0 : index + 4;
  qabsF.enq(out);
endrule

//rule drain;
//  qabsF.deq;
//endrule

interface hbdg  = toPut(hexbdgF);
interface qabs = toGet(qabsF);

endmodule


