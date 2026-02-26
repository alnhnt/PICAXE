
#Region "Program Notes"
#REM

            File: "Morse_Sender.bas"
         License: MIT (See end of file)
  Change History: 2026/02/26 by Alan Hunt - 1st issued version.


Summary
=======
This PICAXE 08M2 program makes a very simple and handy little project to practise morse code listening/watching. It supports variable dit rate, Farnsworth timing and ProSigns, which are all useful in learning Morse Code.

The program evolved from a need to test the "Morse_Encoder.basinc" module and now it show cases the use of that module too. The module itself was initially created to encode hourly messages to fairy lights during Yuletide.

When the program starts it sends "HELLO WORLD". After that you can repeatedly type up to 20 characters of text in the PICAXE Editor's Terminal and send it to the chip, which will output the morse code.

The current settings produce a 600Hz tone, a keying dit rate of 20 Words Per Minute and overall Farnsworth rate of 10 WPM. Note, the dit rate may seem high but this is recommended to learn the sounds because counting dits and dahs is impossible at normal audio reception rates. Visual morse is much slower though.

Prosigns
========
A ProSign is a code with a specific meaning that is made by joining letters together without their usual spacing. For example, morse usually starts with the "CT" prosign to signify "Commencing Transmission" and this helps to realise the keying speed. To achieve the sending of prosigns, the encoder module simply omits the gap between characters if the next character is lowercase. So to send the CT prosign, the text "Ct" is used.

Timing
======
See Morse_Encoder.basinc for detailed information about morse and Farnsworth timing. In essence, you should gain familiarity with sounds of morse characters at near full speed because the audio is too quick to count dits and dahs as you go faster. Farnsworth timing helps learners by making large gaps between characters and words, while the brain improves its recognition of the sounds.

Electrical Connections
======================
The program has one digital output for audio and another digital output to drive an LED. Each output can easily connect via a 1K resistors, to a piezo speaker/transducer and the LED, which in turn are also connected to ground.

To keep things simple, after downloading this program, you move your PC's serial connection from Serial_In (Pin 2) to C.4 (Pin 3) of the PICAXE 08M2. 

You'll also need 100k pull-down resistors on Pins 2 and 3, to stop the serial inputs floating and giving erratic behaviour. The audio is then on C.2 (Pin 5) and the light is on C.1 (Pin 6).


#EndREM
#EndRegion

'Compiler Directives
    #picaxe 08M2
    #terminal 4800

'Pins
    symbol MorseLED = C.1
    symbol MorseSound = C.2
    symbol SerialRx = C.4

'Variables
    '@Morse_Encoder.basinc Variables
    symbol _MorseCharLocation = b16         'Any byte variable.
    symbol _MorseChar = b17                 'Any byte variable.
    symbol _MorseEncoding = w9              'Any word variable.
    symbol _MorseEncoding.lsb = b18         'The least significant byte of _MorseEncoding.

'Constants
    symbol MORSE_PERIOD = 103               'Sets the morse tone to 600Hz @ 4MHz with pwmdiv16. 
    symbol MORSE_DUTY = 207                 '50% duty cyle for above.
    'Messages
    eeprom 0,("Ct",0)
    eeprom 3,("GPS DN Ar",0)
    eeprom 13,("GPS UP",0)
    eeprom 20,("PM.",0)
    eeprom 24,("Sk Cl",0)
    eeprom 30,("HAPPY BIRTHDAY SUE 88",0)
    eeprom 52,("HAPPY SATURNALIA 73",0)
    eeprom 72,("HAPPY YULE TIDE 73",0)
    eeprom 91,("MERRY YULE FEAST 73",0)
    eeprom 111,("HAPPY NEW YEAR 73",0)
    eeprom 129,("Ct HELLO WORLD Ar",0)
    eeprom 147,("Ct THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG Ar",0)
    
'Modules
    '@Morse_Encoder.basinc
    symbol MorseDitTime = 60                        '60ms = 20 WPM.
    symbol FarnsworthDitTime = 313                  'Character space = 939ms, Word space = 2.191s, Makes 10 WPM.
    'Note: The #defines below can affect morse timing. Keep MorseOn and MorseOff as quick as possible.
    #define MorseOn high MorseLED : pwmduty MorseSound, MORSE_DUTY
    #define MorseOff low MorseLED : pwmduty MorseSound, 0
    #include "Morse_Encoder.basinc"
    
'Initialisation
    pwmout pwmdiv16, MorseSound, MORSE_PERIOD, 0    'Initialise PWM for morse sound. Initally 0 duty, so off.
    pause 2000                                      'Wait for PE Terminal to be ready.
    sertxd(cr,lf,ppp_filename)                      'Display the programming filename and time.
    sertxd(cr,lf,ppp_datetime) 
    sertxd(cr,lf,"Ct Hello World Ar")
    MorseTxEEPROM(129)                              'Send the string stored in EEPROM starting at address 129.
    
Main:                                
    'Read up to 20 characters.
    sertxd(cr,lf,"Ready for text, up to 20 characters.",cr,lf)
    do
        bptr = 100
        serin [1000],SerialRx,N4800_4,@bptrinc,@bptrinc,@bptrinc,@bptrinc,@bptrinc,@bptrinc,@bptrinc,@bptrinc,@bptrinc,@bptrinc,@bptrinc,@bptrinc,@bptrinc,@bptrinc,@bptrinc,@bptrinc,@bptrinc,@bptrinc,@bptrinc,@bptrinc
    loop until bptr > 100                           'If no bytes received, go back an listen again.
    @bptr = 0                                       'Set the final byte of the string as the null character.
    
    'Display and send the string.
    bptr = 100
    do
        sertxd(@bptrinc)
    loop until @bptr = 0
    MorseTxRAM(100)                                 'Send the string stored in RAM starting at address 100.

    goto Main

#Region "License" 
#Rem

MIT License

Copyright (c) 2026 Alan Hunt

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
