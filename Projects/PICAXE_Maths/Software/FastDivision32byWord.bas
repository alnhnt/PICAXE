#rem
        Version: 2026-10-10, by Alan Hunt
        Purpose: For testing of FastDivision32byWord
        License: MIT
====================================================

This program tests and show cases some methods of 32 bit division, I developed them to improve on the speed of typical long division methods. Please use them as you wish.

My need for very fast division was a base ten log function that used a 12 bit divisor from a floating point significand. After achieving a six-fold speed improvement, I extended the solution to support general purpose 16 bit divisors, this dropped the speed to four-fold with a maximum of 0.2% error, or two-fold speed at the expense of huge program space. As for the program space, it could be improved, and no doubt a program slot is probably the way to go for complex maths functions. I'd argue we don't need absolute accuracy all the time, so 0.2% should be sufficient in most cases :)

In 2012, PICAXE Forum optimisations used maths on the high word and reduce the potential 32 bit shifts of long division down to 16. The nibbing methods in this file remove the 16 bit shifts on the low word too. The core nibbling solutions work with divisors up to 4,096, they assess 4 bits at a time without overflowing and the code is so small there's no need to construct a loop. The 4,096 ceiling is because the modulus operator returns a remainder of up to 4,095 and this is can be multiplied by 16 while not overflowing a word variable. In the initial high word division the remainder has a unit value of remainder*65536/divisor, which is difficult to handle, but it's value is only n*16/divisor compared to the most significant nibble in the low word. There's the 1st trick: The maximum remainder of 4095 supports the multiplication by 16 and subsequent division, so it's possible to add this value to the low word and carry any remainder to the next nibble, which again is multiplied by 16. There's two implementations, the "Nibbling Long Method" truncates and performs like binary long division taking in 4 bit chunks from a copy of the low word dividend. My preferred "Nibbling Maths Method" can only be used for rounding, it initially divides the low word and tries to eradicate the carry down from the high word remainder in nibbing steps.

The next trick is a conditional scalar that reduces divisors above 4095 by a factor of 16. The Nibbling Maths Method is then used and that's followed by conditionally post scaling to bring the quotient down to the expected value. In the "Nibbling Scalar Nearest Method" the nearest scaled divisor is chosen and the accuracy is very good, less than 0.2% error. It's accurate because n/Divisor is almost flat after 256.

The last trick is the "Nibbling Scalar Interpolation Method", this calculates two divisions representing the top and bottom ends of the scaled range. Linear interpolation then restores the lost precision, in return for some tiny inaccuracy that can only be seen in rare cases. The maximum error is only +0.000478% because the function of n/Divisor has virtually no curvature after 256. The maximum +5 error is seen when the maximum 32 bit dividend of 4.3 billion is has a divisor is 4,104, and the result was 1,046,536 instead of 1,046,531. This maximum error occurs at the middle of the 1st scaled range, they occur if the divisor is less than 4097 and they diminish quickly as the divisor grows larger, or the dividend reduces in size.

This file starts with a test framework and table memory for testing data, then each nibbling method is contained in a subroutine. The subroutines describe when to use the method, the technique involved, and its performance and accuracy.

I hope someone finds it useful!  Copies are on the forum and latest work is here: https://github.com/alnhnt/PICAXE


Performance
===========

Division Method             Processing Time     Program Bytes and Notes
-----------------------------------------------------------------------------------------
NibbleLong(Truncate)            21.4 ms         80 bytes. No error. Divisor limit 4096.
NibbleMaths(Round)              23.4 ms         88 bytes. No error. Divisor limit 4096.
NibbleScalarNearest             26.2 ms         133 bytes. No error for small divisors.
                                33.4 ms         (Divisors above 4095, max error 0.19%)
NibbleScalarInterpolate         26.3 ms         280 bytes.  No error for small divisors.
                                70.5 ms         (Divisors > 4095, max error 0.000478%)
Optimised 16 bit shifts      Approx 150 ms      80 bytes. Not measured or included here.
32 bit long division         Approx 300 ms      As above.


Acknowledgements:
Back in 2012, the PICAXE Forum provided a great way to save time when dividing 32 bit numbers, 16 bit shifts were avoided by performing a maths division on the high word. @Womai for the idea in https://picaxeforum.co.uk/threads/dividing-a-32-bit-number-by-a-16-bit-one.21357/post-206999 and @Allycat for the optimising to about 150ms with 4MHz clock in https://www.picaxeforum.co.uk/threads/a-double-word-by-single-word-division-subroutine-32-bits-16-bits.21502/



#endrem
'Normal setup
    #picaxe 14M2 
    #no_data
    #no_debug
    #terminal 4800
    
'Test Setup    
    symbol FirstTest = 0
    'Place a comment marker before sertxd to stop terminal output:
    #define display sertxd
    
    'Select 1 test type below and comment out the rest:
    '#define Test_NibbleLong
    '#define Test_NibbleMaths
    #define Test_NibbleScalarNearest
    '#define Test_NibbleScalarInterpolate
    
    
#ifdef Test_NibbleLong
    #define TestName "### Nibble Long Truncation Method ###"
    #define TestSubroutine gosub NibbleLong
    '#define ExpectRounding
    symbol LastTest = 140
#endif
#ifdef Test_NibbleMaths
    #define TestName "### Nibble Maths Rounding Method ###"
    #define TestSubroutine gosub NibbleMaths
    #define ExpectRounding
    symbol LastTest = 140
#endif
#ifdef Test_NibbleScalarNearest
    #define TestName "### Nibble Scalar Nearest Method ###"
    #define TestSubroutine gosub NibbleScalarNearest
    #define ExpectRounding
    symbol LastTest = 310 
#endif
#ifdef Test_NibbleScalarInterpolate
    #define TestName "### Nibble Scalar Interpolation Method ###"
    #define TestSubroutine gosub NibbleScalarInterpolate
    #define ExpectRounding
    symbol LastTest = 310 
#endif


'Pins
    symbol leg3 = C.4           'Pin state is used to determine timings.
    
'General Purpose Variables.
    'Test Framework
    symbol testLocation = w1
    symbol expectedH = w2
    symbol    expectedH.LSB = b4
    symbol    expectedH.MSB = b5
    symbol expectedL = w3
    symbol    expectedL.LSB = b6
    symbol    expectedL.MSB = b7
    symbol errorCount = b8
    symbol tempB = b9
    
    'Test Container (All tests)
    symbol highWord = w5
    symbol    highWord.LSB = b10
    symbol    highWord.MSB = b11
    symbol lowWord = w6
    symbol    lowWord.LSB = b12
    symbol    lowWord.MSB = b13
    symbol divisor = w7
    symbol    divisor.LSB = b14
    symbol    divisor.MSB = b15
    symbol nibble = w8
    symbol lowWord2 = w11
    symbol    lowWord2.LSB = b22
    symbol    lowWord2.MSB = b23
    
    'Test Container (Specific requirements)
    symbol flags = b0
    symbol    flagScaled = bit0     'For Nibble Scalar Methods.
    symbol    flagEdgeCase = bit1   'For Nibble Scalar Interpolation.
    symbol distance = b1            'For Nibble Scalar Interpolation.
    symbol rounding = w9            'For NibbleMaths and NibbleScalarInterpolate.
    symbol highWord2 = w10          'For Nibble Scalar Interpolation.
    symbol overflowCheck = w12      'For NibbleMaths and NibbleScalar Methods.
    

'Test Cases
'==========
'The Test Data is held in table memory and for readability it's in Big Endian format, so high byte first and 2 bytes per word. Each test has ten bytes, which are the HighWord, LowWord, Divisor, Expected High Word Result, and Expected Low Word Result. The first set of data is common to all tests. There's a gap every 5 lines, this indicates where an extra pause exists to help timing measurements. Comments provide a test description, test purpose, and the processing time in milliseconds for a PICAXE 14M2 running at 4MHz. Where the term "Max" is used this means $FFFF FFFF, or in decimal 4,294,967,295.
'
' Test Data: Dividend(4),Divisor(2),Quotient(4)     Overview                Notes/Purpose   Time in ms --> Maths    Long   ScalarN ScalarI
'-----------------------------------------------------------------------------------------------------------------------------------------
'                                                                                              Averages =  [23.4]  [21.4]  [26.2]  [26.4]
    table   0,(0,0,0,0,0,1,0,0,0,0)                 '0/1=0                  Dividing zero                   23.3    21.4    26.2    26.3
    table  10,(0,0,0,1,0,1,0,0,0,1)                 '1/1=1                  Dividend LSW is 1               
    table  20,(0,0,0,1,0,3,0,0,0,0)                 '1/3=0                  0.33 is below resolution        23.3    21.4    26.2    26.3
    table  30,(0,0,0,8,0,2,0,0,0,4)                 '8/2=4                  Small integers                  
    table  40,(0,1,0,0,0,1,0,1,0,0)                 '65536/1=65536          Dividend MSW is 1               23.3    21.4    26.2    26.3
  
    table  50,(0,1,0,0,0,2,0,0,128,0)               '65536/2=32768          Carry down to LSW               
    table  60,(0,10,0,12,0,4,0,2,128,3)             '655372/4=163843        MSW retains some value          23.3    21.4    26.2    26.2
    table  70,(0,9,255,96,15,255,0,0,0,160)         '655200/4095=160        Bigger number
    table  80,(0,9,255,240,15,255,0,0,0,160)        '655344/4095=160.035    NibbleMaths Truncation OK       23.3    21.4    26.2    26.4
    table  90,(0,15,66,64,0,3,0,5,22,21)            '1,000,000/3=333,333.3  Round down or truncate the .3
    
#ifdef ExpectRounding
    table 100,(255,255,255,255,15,255,0,16,1,0)     'Max/4095=1,048,832     Biggest dividend                23.4            26.2    26.4
    table 110,(255,255,255,255,15,253,0,16,3,1)     'Max/4093=1,049,344.56  Round up big
    table 120,(0,10,0,12,0,8,0,1,64,2)              '655372/8=81921.5       Round up to 81922               23.5            26.2    26.4
    table 130,(0,10,0,12,15,160,0,0,0,164)          '655372/4000=163.843    Round up to 164                 
    table 140,(0,10,7,91,15,255,0,0,0,160)          '657243/4095=160.498    Round down or truncate          23.4            26.2    26.4
#else    
    table 100,(255,255,255,255,15,255,0,16,1,0)     'Max/4095=1,048,832     Biggest dividend                        21.4
    table 110,(255,255,255,255,15,253,0,16,3,0)     'Max/4093=1,049,344.56  Truncate big
    table 120,(0,10,0,12,0,8,0,1,64,1)              '655372/8=81921.5       Truncate to 81921                       21.4
    table 130,(0,10,0,12,15,160,0,0,0,163)          '655372/4000=163.843    Truncate to 163
    table 140,(0,10,7,91,15,255,0,0,0,160)          '657243/4095=160.498    Truncate to 163                         21.4
#endif

' Test Data: Dividend(4),Divisor(2),Quotient(4)     Overview (Ideal)        Notes/Purpose/Actual           ScalarN
'-----------------------------------------------------------------------------------------------------------------
'                                                                                               Average =  (33.4)
#ifdef Test_NibbleScalarNearest
    table 150,(255,255,255,255,255,255,0,1,0,0)     'Max/$FFFF=$1,0001      -1 error. Top scalar end        33.7
    table 160,(255,255,255,255,255,254,0,1,0,0)     'Max/$FFFE=$1,0002.0    -2 error                                               
    table 170,(255,255,255,255,255,249,0,1,0,0)     'Max/$FFF9=$1,0007.0    -7 error                        33.7
    table 180,(255,255,255,255,255,248,0,1,0,0)    'Max/$FFF8=$1,0008.0    +8 error (0.012%)                                              
    table 190,(255,255,255,255,255,247,0,1,0,16)    'Max/$FFF7=$1,0009.0    +7 error                        33.2
    
    table 200,(255,255,255,255,255,246,0,1,0,16)    'Max/$FFF6=$1,000A.0    +6 error                                               
    table 210,(255,255,255,255,255,241,0,1,0,16)    'Max/$FFF1=$1,000F.0    +1 error                        33.2
    table 220,(255,255,255,255,255,240,0,1,0,16)    'Max/$FFF0=$1,0010.0    Exact. Top scalar start                      
    table 230,(255,255,255,255,255,239,0,1,0,16)    'Max/$FFEF=$1,0011.0    -1 error. Top of next group     33.4
    table 240,(255,255,255,255,16,15,0,15,240,15)   'Max/4111=1,044,750     -255. Bottom scalar end           
    
    table 250,(255,255,255,255,16,14,0,15,240,15)   'Max/4110=1,045,004     -509 (-0.049%)                  33.3
    table 260,(255,255,255,255,16,9,0,15,240,15)    'Max/4105=1,046,277     -1,732 (-0.17%)                                   
    table 270,(255,255,255,255,16,8,0,15,240,15)    'Max/4104=1,046,531.9   -2,036 (-0.19%) As expected.    33.3
    table 280,(255,255,255,255,16,7,0,16,0,0)       'Max/4103=1,046,787     +1,789 (+0.17%) As expected.                                            
    table 290,(255,255,255,255,16,6,0,16,0,0)       'Max/4102=1,047,042     +1,534 (+0.15%)                 33.5
    
    table 300,(255,255,255,255,16,1,0,16,0,0)       'Max/4097=1,048,320     +256 (+0.02%)                   33.5                           
    table 310,(255,255,255,255,16,0,0,16,0,0)       'Max/4096=1,048,575.9   Exact with rounding
#endif

' Test Data: Dividend(4),Divisor(2),Quotient(4)     Overview (Ideal)        Notes/Purpose/Actual           ScalarI
'-----------------------------------------------------------------------------------------------------------------
'                                                                                               Average =  (70.5)
#ifdef Test_NibbleScalarInterpolate
    table 150,(255,255,255,255,255,255,0,1,0,1)     'Max/$FFFF=$1,0001      No error. Top entry end         70.4
    table 160,(255,255,255,255,255,254,0,1,0,2)     'Max/$FFFE=$1,0002.0    Exact                           
    table 170,(255,255,255,255,255,249,0,1,0,7)     'Max/$FFF9=$1,0007.0    Exact                           70.4
    table 180,(255,255,255,255,255,248,0,1,0,8)     'Max/$FFF8=$1,0008.0    Exact                                               
    table 190,(255,255,255,255,255,247,0,1,0,9)     'Max/$FFF7=$1,0009.0    Exact                           70.4
    
    table 200,(255,255,255,255,255,246,0,1,0,10)    'Max/$FFF6=$1,000A.0    Exact                                            
    table 210,(255,255,255,255,255,241,0,1,0,15)    'Max/$FFF1=$1,000F.0    Exact                           70.4
    table 220,(255,255,255,255,255,240,0,1,0,16)    'Max/$FFF0=$1,0010.0    Bottom entry in top scalar                      
    table 230,(255,255,255,255,255,239,0,1,0,17)    'Max/$FFEF=$1,0011.0    Top of next group               70.2
    table 240,(255,255,255,255,16,15,0,15,241,15)   'Max/4111=1,044,750     +1 error. Bottom scalar end     
    
    table 250,(255,255,255,255,16,14,0,15,242,14)   'Max/4110=1,045,004     +2                              70.6
    table 260,(255,255,255,255,16,9,0,15,247,9)     'Max/4105=1,046,277     +4                              
    table 270,(255,255,255,255,16,8,0,15,248,8)     'Max/4104=1,046,531.9   +5                              70.6
    table 280,(255,255,255,255,16,7,0,15,249,7)     'Max/4103=1,046,787     +4                                                  
    table 290,(255,255,255,255,16,6,0,15,250,6)     'Max/4102=1,047,042     +4                              70.6
    
    table 300,(255,255,255,255,16,1,0,15,255,1)     'Max/4097=1,048,320     +1                                            
    table 310,(255,255,255,255,16,0,0,16,0,0)       'Max/4096=1,048,575.9   Exact with rounding             70.5
#endif

    display(cr,lf,cr,lf,TestName,cr,lf,"@Test Start!")
    
Main:
    testLocation = FirstTest

    do
        'Pause every 6 tests to make test positions clear.
        tempB = testLocation // 50
        if tempB = 0 then
            pause 300
        endif
        
        'Load variables.
        readtable testLocation,highWord.MSB,highWord.LSB,lowWord.MSB,lowWord.LSB,divisor.MSB,divisor.LSB,expectedH.MSB,expectedH.LSB,expectedL.MSB,expectedL.LSB
        display(cr,lf,"      Test = ",#testLocation)
        display(cr,lf,"     Input = H(",#highWord,")  L(",#lowWord,")  Div(",#divisor,")")

        'Run test.
        TestSubroutine
        
        'Output the result
        display(cr,lf,"    Output = H(",#highWord,")  L(",#lowWord,")")
        display(cr,lf,"  Expected = H(",#expectedH,")  L(",#expectedL,")")
        if highWord = expectedH AND lowWord = expectedL then
            display(cr,lf,"    Result = Pass")
        else
            display(cr,lf,"    Result = Fail")
            inc errorCount
        endif
        display(cr,lf,"Total Errors = ",#errorCount,cr,lf)
        
        pause 300
        testLocation = testLocation + 10
    loop until testLocation > LastTest

    pause 700
    'goto Main
    stop  

#ifdef Test_NibbleLong
NibbleLong:
'Nibbling Long Method (Truncating When Divisor < 4097)
'=====================================================
    
'When To Use:
'Divisors need to be in the range of 0 to 4096. Best for standard binary truncation, or when you want to use only 2 extra word variables. For greater accuracy use rounding with MathsNibbles instead, it's 1ms quicker and consumes 9 less program bytes. 

'Technique:
'High word uses maths division and carry over to low word. The low word is processed using long division in nibble sized chunks instead of individual binary shifts. A copy of the low word brings in nibbles while the original low word quotient is updating.
    
'Performance(14M2@4Mhz):
'80 bytes and 21.4 ms without rounding. 99 program bytes and 24.1 ms with rounding. Requires 2 additional word variable for calculation.
    
'Accuracy:
'Truncation and rounding results are 100%.
    
high leg3                                   'This line only exists to help timing tests.
'---------------------------------------------------------------
nibble = highWord // divisor * 16   'Modulus carries to lowWord.
highWord = highWord / divisor       'Divide high word in 1 step.
lowWord2 = lowWord                  'Copy of bits for nibbling.

'Process the top nibble of the lowWord.  
nibble = lowWord2.MSB / 16 + nibble     'Nibble Bit12+ now Bit0+.
lowWord.MSB = nibble / divisor * 16

'Repeat above but place the result in the next 4 bits.
nibble = nibble // divisor * 16
nibble = lowWord2.MSB AND $F + nibble   'Nibble Bit8+ now Bit0+.
lowWord.MSB = nibble / divisor + lowWord.MSB

'Repeat above but place the result in the next 4 bits.
nibble = nibble // divisor * 16
nibble = lowWord2.LSB / 16 + nibble     'Nibble Bit4+ now Bit0+.
lowWord.LSB = nibble / divisor * 16

'Get the last 4 LSb from the highWord carry down.
nibble = nibble // divisor * 16
nibble = lowWord2.LSB AND $F + nibble   'Bit0+ added to remainder.
lowWord.LSB = nibble / divisor + lowWord.LSB

'Round up if necessary (Nibbling Maths is better for rounding).
'nibble = nibble // divisor * 2
'if nibble >= divisor then 
'    inc lowWord
'    if lowWord = 0 then : inc highWord : endif
'endif
'---------------------------------------------------------------
low leg3
    
return
#endif


#ifdef Test_NibbleMaths
NibbleMaths:
'Nibbling Maths Method (Rounding When Divisor < 4097)
'====================================================
    
'When To Use:
'Divisors need to be in the range of 0 to 4096. Best for greater accuracy of rounding, with hardly any greater effort for the PICAXE. It's more efficient than using rounding with the LongNibbles method. 

'Technique:
'Both the high word and low word use maths division. The carry over from the high word is gradually eradicated by adding to the low word in nibble chunks, keeping in mind the position and value of bits. If rounding were not used the fractional value of the low word creates seemingly odd behaviour if you expect typical binary truncation. That's because a big divisor causes a low word fraction that spans a large range and if this fraction is 0.5 to 0.999 it's ignored and the result is one step too low, even if the division should ideally create a whole number.
    
'Performance(14M2@4Mhz):
'88 bytes and 23.4 ms with tiny variation. Requires 3 additional word variable for calculation: nibble, rounding and overflowCheck.
    
'Accuracy:
'Rounding results are 100%. Rounding reduces quantization errors by half.

    
high leg3                                   'This line only exists to help timing tests.
'---------------------------------------------------------------
nibble = highWord // divisor * 16   'Modulus carries to lowWord.
highWord = highWord / divisor       'Divide high word in 1 step.
rounding = lowWord // divisor       'lowWord remainder for rounding.
lowWord = lowWord / divisor         'Divide low word in 1 step.
overflowCheck = lowWord             'For overflow checking lowWord.

'Process the top nibble of the lowWord.  
lowWord.MSB = nibble / divisor * 16 + lowWord.MSB 'x16 aligns nibble.
nibble = nibble // divisor * 16         'x16 scales for next nibble.

'Repeat above but place the result in the next 4 bits.
lowWord.MSB = nibble / divisor + lowWord.MSB
nibble = nibble // divisor * 16         'x16 scales for next nibble.

'Repeat above but place the result in the next 4 bits.
lowWord = nibble / divisor * 16 + lowWord   'Word avoids overflow.
nibble = nibble // divisor * 16         'x16 scales for next nibble.

'Get the last 4 LSb from the highWord carry down.
lowWord = nibble / divisor + lowWord

'Round up if necessary.
rounding = nibble // divisor + rounding * 2
if rounding >= divisor then : inc lowWord : endif

'Check for rare lowWord overflows.
if lowWord < overflowCheck then : inc highWord : endif
'---------------------------------------------------------------
low leg3                                    'This line only exists to help timing tests.

return
#endif


#ifdef Test_NibbleScalarNearest
NibbleScalarNearest:
'32 Bit Division With Scaled 16 Bit Words
'========================================
    
'When To Use:
'Divisors can be any word value, unlike the native nibbling methods. If you want quick results, this is extremely fast. The price you pay is 0.2% accuracy and 50% more program space.

'Technique:
'This uses the NibbleMaths technique, which is nestled between a conditional pre and post scalar of 16. The scalar is rounded to the nearest available to improve accuracy.
    
'Performance(14M2@4Mhz):
'133 bytes and 26.3 ms (divisor<4096) or 34.8 ms (divisor>=4096) with little variation. Requires 3 additional word variable for calculation: nibble, rounding and overflowCheck.
    
'Accuracy:
'The maximum error of +0.195% is caused by a divisor of 4104 (halfway of the lowest scaled range). When the maximum 32 bit dividend of 4,294,967,295 was divided by 4104 it gave a result of 1,044,495 instead of 1,046,531, a -2,036 error.

    
high leg3                           'This line only exists to help timing tests.
'------------------------------------------
'Pre-scale large divisors.
flags = 0
if divisor > 4095 then 
    distance = divisor // 16
    divisor = divisor / 16
    if distance >= 8 then
        inc divisor             'Move to the nearest scalar.
    endif
    flagScaled = 1
endif
'------------------------------------------
'Standard Nibbling Maths Method
nibble = highWord // divisor * 16
highWord = highWord / divisor
rounding = lowWord // divisor
lowWord = lowWord / divisor
overflowCheck = lowWord
lowWord.MSB = nibble / divisor * 16 + lowWord.MSB
nibble = nibble // divisor * 16
lowWord.MSB = nibble / divisor + lowWord.MSB
nibble = nibble // divisor * 16
lowWord = nibble / divisor * 16 + lowWord
nibble = nibble // divisor * 16
lowWord = nibble / divisor + lowWord
rounding = nibble // divisor + rounding * 2
if rounding >= divisor then : inc lowWord : endif
if lowWord < overflowCheck then : inc highWord : endif    
'------------------------------------------
'Compensate for pre-scaling.
if flagScaled = 1 then
    lowWord = lowWord / 16
    lowWord = highWord * $1000 + lowWord
    highWord = highWord / 16   
endif
'------------------------------------------
low leg3                            'This line only exists to help timing tests.

return
#endif

#ifdef Test_NibbleScalarInterpolate
NibbleScalarInterpolate:
'32 Bit Division With Scaled And Interpolated 16 Bit Words
'=========================================================
   
'When To Use:
'Divisors can be any word value, unlike the native nibbling methods. If you want very accurate results, divisors below 4096 retain the performance of native nibbling whereas bigger divisors achive about three-fold improvement compared to division optimisations using 16 bit shifts. The bigger divisors have a max error of +0.000478% and program space is tripled, due to the focus on speed. To save space you could consider looping the division twice, containing the standard Nibbling Maths Method in a subroutine, or using a program slot for maths.

'Technique:
'This uses the NibbleMaths technique, which is nestled between a conditional pre and post scalar of 16. For large divisors the distance from its base is sotred in sixteenths, the next scalar is also divided and the result is linear interpolation of the two based on the distance. It's very accurate due to the lack of curvature in 1/X when X exceeds 255.
    
'Performance(14M2@4Mhz):
'280 bytes and 26.4 ms (divisor<4096) or 70.7 ms (divisor>=4096) with little variation. Requires 4 additional word variable for calculation: nibble, rounding, overflowCheck and highWord2.
    
'Accuracy
'The maximum error of +0.000478% is caused by a divisor of 4104 (halfway of the lowest scaled range). When the maximum 32 bit dividend of 4,294,967,295 was divided by 4104 this gave a result of 1,046,536 instead of 1,046,531, a +5 error.


high leg3                           'This line only exists to help timing tests.
'------------------------------------------
'Pre-scale large divisors.
flags = 0
if divisor > 4095 then 
    distance = divisor // 16
    divisor = divisor / 16
    flagScaled = 1
    highWord2 = highWord            'Backup dividend.
    lowWord2 = lowWord
endif
'------------------------------------------
'Standard Nibbling Maths Method
nibble = highWord // divisor * 16
highWord = highWord / divisor
rounding = lowWord // divisor
lowWord = lowWord / divisor
overflowCheck = lowWord
lowWord.MSB = nibble / divisor * 16 + lowWord.MSB
nibble = nibble // divisor * 16
lowWord.MSB = nibble / divisor + lowWord.MSB
nibble = nibble // divisor * 16
lowWord = nibble / divisor * 16 + lowWord
nibble = nibble // divisor * 16
lowWord = nibble / divisor + lowWord
rounding = nibble // divisor + rounding * 2
if rounding >= divisor then : inc lowWord : endif
if lowWord < overflowCheck then : inc highWord : endif
'------------------------------------------
'Compensate for pre-scaling.
if flagScaled = 1 then
    'If using interpolation use scaled divisor + 1.
    inc divisor
    
    'Standard Nibbling Method is re-used on the original dividend.
    nibble = highWord2 // divisor * 16
    highWord2 = highWord2 / divisor
    rounding = lowWord2 // divisor
    lowWord2 = lowWord2 / divisor
    overflowCheck = lowWord2
    lowWord2.MSB = nibble / divisor * 16 + lowWord2.MSB
    nibble = nibble // divisor * 16
    lowWord2.MSB = nibble / divisor + lowWord2.MSB
    nibble = nibble // divisor * 16
    lowWord2 = nibble / divisor * 16 + lowWord2
    nibble = nibble // divisor * 16
    lowWord2 = nibble / divisor + lowWord2
    rounding = nibble // divisor + rounding * 2
    if rounding >= divisor then : inc lowWord2 : endif
    if lowWord2 < overflowCheck then : inc highWord2 : endif

    'Calc Linear Interpolation.
    highWord2 = highWord - highWord2    'Diff between values.
    if lowWord < lowWord2 then          'Underflow pre-check
        dec highWord2
    endif
    lowWord2 = lowWord - lowWord2
    highWord2 = highWord2 * distance    'Can't overflow, divisor>256.
    highWord2 = lowWord2 ** distance + highWord2  'Low overflows up.
    lowWord2 = lowWord2 * distance      'Diff now * Distance.
    lowWord2 = lowWord2 / 16            'Get diff proportional.
    lowWord2 = highWord2 * 4096 + lowWord2 'Carry down 4 lsb.
    highWord2 = highWord2 / 16
    highWord = highWord - highWord2     'Add delta to initial result.
    if lowWord < lowWord2 then          'Underflow pre-check
        dec highWord
    endif
    lowWord = lowWord - lowWord2
    
    'Use scalar again for final result.
    lowWord = lowWord / 16
    lowWord = highWord * $1000 + lowWord
    highWord = highWord / 16   
endif
'------------------------------------------
low leg3                                    'This line only exists to help timing tests.

return
#endif

