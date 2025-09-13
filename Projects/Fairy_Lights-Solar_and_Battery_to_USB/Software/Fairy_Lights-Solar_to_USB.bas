
#Region "Program Notes"
#REM

            File: "Fairy_Lights-Solar_to_USB.bas"
         License: MIT (See end of file) 
  Change History: 2025/1/2 by Alan Hunt - 1st issue.

Microcontroller Pin Usage
==========================

Pin Usage                                      PICAXE 08M2 Pinout & Functions                    Pin Usage
                        ---------------------------------------------------------------------
+5V Supply              |1  Vdd                                                         Gnd 8|  0V Supply
Programming Input       |2  C.5 Serial In (In)             C.0 Serial Out (Out/hserout/DAC) 7|  Debug Output
                        |3  C.4(Touch/ADC/Out/In)  C.1(In/Out/ADC/Touch/hserin/SRI/hi2cscl) 6|  OutA (to H-Bridge)
                        |4  C.3(In)              C.2(In/Out/ADC/Touch/pwm/tune/SRQ/hi2csda) 5|  OutB (to H-Bridge)
                        ---------------------------------------------------------------------
Notes
=============
    * This program alternates opposite high and low outputs between C.1 and C.2 pins at 115Hz, avoiding visible flicker.
    * The outputs feed an H-Bridge, where their alternating potential is used to drive LED fairy lights.
    * Program execution speed provides a short pause in switching outputs, preventing shoot-through current on the H-Bridge.
    * An 8MHz clock rate reduces the deadband between phases and the timing parameters achieve a near 50/50 duty cycle.
    * Actual timings are High OutA 4.27ms, both low 156us, High OutB 4.18ms, both low 142us.

#EndREM
#EndRegion

#Region "Setup"
'Compiler Directives
    #picaxe 08M2 
    #no_data
    #no_debug
    
    '@Timing.basinc Constant (do not use an equals sign, or add comments or spaces to the end of the line below):
    #define CLOCK_SET_KHZ 8000
    '@Debugger.basinc extra info (do not use an equals sign, or add comments or spaces to the end of the line below):
    #define Debugger_SplashExtra "https://github.com/alnhnt/PICAXE"

'Pins
    symbol OutA = C.1           'H-Bridge Input A
    symbol OutB = C.2           'H-Bridge Input B
    low OutA : high OutB        'Show 1 phase of lights while Debugger.basinc allows the PE Terminal to catch up.
    
'Constants
    symbol TimeA = 8            'Value used in pause command but 8Mhz Clockrate halves the usual millisecond timings.
    symbol TimeB = 7            'TimeB is shorter because the "goto Main" command adds a program delay.
    
'Modules
    #include "Timing.basinc"
    #include "Debugger.basinc"
  
#Endregion

#Region "Main Program"
Main:                                
    'Loop around Main quickly to create an AC signal between OutA and OutB. 
    low OutB
    high OutA
    pause TimeA
    low OutA
    high OutB
    pause TimeB
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
