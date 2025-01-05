
#Region "Program Notes"
#REM

            File: "Fairy_Lights-Simple_Experiment.bas"
         License: MIT (See end of file) 
  Change History: 2025/1/2 by Alan Hunt - 1st issue.

Microcontroller Pin Usage
==========================

Pin Usage                      PICAXE 08M2 Pinout & Functions       Pin Usage
                        -------------------------------------------
+5V Supply              |1 Vdd                              Gnd 8 | 0V Supply
Programming Input       |2 Serial In                 Serial Out 7 | Debug Output
                        |3                              C.1_Out 6 | To LEDs
                        |4                              C.2_Out 5 | To LEDs
                        -------------------------------------------
Notes
=============
    * This is part of an experiment to show a PICAXE providing an AC output to drive low voltage LED fairy lights.
    * The circuit relied on internal resistance of the PICAXE 08M2 and did not use a series resistor for current limiting :O
    * The LEDs need to have a forward voltage of at least 2.5V and the 08M2 internal resistance provides the voltage drop.
    * It goes against best practise but works within spec and was a little fun after noticing output voltage sag under load.
    * The final project used this circuit to drive a conventional H-Bridge for higher current output.
    * The program creates alternating and opposite high-low outputs between C.1 and C.2 pins at 114Hz.
    * Program execution speed provides a 140us "deadband" in switching outputs, this prevents H-Bridge shoot-through current.
    * Using an 8MHz clock rate, reduces the deadband between output phases and allowed finer trimming of on-times.
    * With the timing parameters used, a near 50/50 duty cycle is achieved at a high enough rate to avoid any flicker.
    * Actual timings are High C.1 4.28ms, both low 140us, High C.2 4.18ms, both low 142us.

#EndREM
#EndRegion

#Region "Program"
Program:            'Only 15 bytes!
    #picaxe 08M2 
    #no_data
    setfreq M8
Main:                                
    'Loop around Main quickly to create an AC signal between C.1 and C.2. 
    'With 8Mhz clock and pauses of 8 and 7 the frequency is 114 Hz.  Adding extra code will change timings.
    low C.2
    high C.1
    pause 8
    low C.1
    high C.2
    pause 7         'This time is shorter because the "goto Main" command adds a program delay.
    goto Main

#Endregion

#Region "License" 
#Rem

MIT License

Copyright (c) 2024 Alan Hunt

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

#EndRem
#EndRegion
