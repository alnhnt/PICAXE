
#Region "Program Notes"
#REM
            File: "Fairy_Lights-Battery_to_Mains_GPS_RTC.bas"
         License: MIT (See end of file) 
  Change History: 2026/1/13 Changed on time to 15:30 and enabled RTC debug output.
                  2025/1/13 by Alan Hunt - 1st issue.


Microcontroller Pin Usage
=========================
                                                        (Microchip PIC18F14K22) 
Pin Usage                                           PICAXE 20X2 Pinout & Functions                   Pin Usage
                                -------------------------------------------------------------------
+5V Supply                      |1  Vdd                                                     Gnd 20|  0V Supply
Programming Input               |2  Serial In                                        Serial out 19|  Debugging Output
                                |3  C.7(ADC3/Out/In)                     B.0(In/Out/ADC1/hint1) 18|  HInt (RTC MFP)
Timed                           |4  C.6(In)                          B.1(In/Out/ADC2/hint2/SRQ) 17|
BridgeA                         |5  C.5(hpwmA/pwmC.5/Out/In)            B.2(In/Out/ADC4/Comp2+) 16|  GPS_Power
BridgeB                         |6  C.4(hpwmB/SRNQ/Out/In)              B.3(In/Out/ADC5/Comp2-) 15|
                                |7  C.3(hpwmC/ADC7/Out/In)        B.4(In/Out/ADC6/hpwmD/Comp1-) 14|
Lamp_Power                      |8  C.2(kbclk/ADC8/Out/In)    B.5(In/Out/ADC10/hi2csda/hspisdi) 13|  I2C_Data (RTC)
                                |9  C.1(hspisdo/kbdata/ADC9/Out/In)    B.6(In/Out/ADC11/hserin) 12|  HSerIn (GPS)
HSerOut (GPS)                   |10 C.0(hserout/Out/In)             B.7(In/Out/hi2cscl/hspisck) 11|  I2C_Clock (RTC)
                                -------------------------------------------------------------------
Program Notes
=============
    *   The PICAXE 20X2 gets the time from a GPS board, the NEO-M8N.
    *   A MCP7940N RTC is programmed with the time.
    *   The RTC is programmed with an alarm that wakes the PICAXE from Sleep or Doze using a hardware interrupt.
    *   Depending on the time, the alarm is set to make a daily time update, or switch the lights on or off.
    *   The PICAXE operates in Doze mode to provide HPWM for a H-Bridge that creates AC for fairy lights.
    *   HPWM operates in half-bridge mode, providing complimentary outputs and a deadband preventing shoot-through current.
    *   Internal pull-ups were used for I2C lines, these are about 30k compared to 10k spec for I2C.
    *   The "Timed" input is connected to a jumper, so that simple power on-off operation is possible without any timing.
    

PWM Notes
=========
	* The PWM_PERIOD has a value of 0 to 255, which sets the cycle time. The time (500 ns to 2 ms) = (PWM_PERIOD + 1) * 4 / InternalResonator / PWMDIV.
	* The PWMDIV parameter provides an optional frequency divisor of 4, 16 or 64, but 64 is not available on the 20X2 chip.
	* The PWM cycle range is 500 ns to 2 ms (from 2 MHz with no PWMDIV and down to 488 Hz with "PWMDIV16").
	* To set the PWM frequency (1 / Cycle Time) use PWM_PERIOD = (2,000,000 / (F * PWMDIV)) - 1.
	* The PWM_DEADBAND parameter has a range of 0 to 127 to set the time when the outputs are in an overlapping inactive state to prevent potential short circuits in driver circuitry. PWMDIV does not affect the Deadband. 
	* A PWM_DEADBAND of 1 equates to 500 ns (time = 4 * PWM_DEADBAND / InternalResonator).
	* The PWM_Duty cycle is a 10 bit on time and has a max value of 4 * PWM_PERIOD, which is 100% active and should not be exceeded. For an equal positive/negative duty cycle use 2 * PWM_PERIOD - PWM_DEADBAND.
	

#EndREM
#EndRegion

#Region "Compiler Directives"
'Compiler Directives
    
    'Setup
    #picaxe 20X2 
    #no_data
    #no_table
    #no_debug
    
    'Program Macros and Definitions
    #define LightsOn gosub LightOn
    #define LightsOff gosub LightOff
    #define GPS_On low GPS_Power : pause 500
    #define GPS_Off high GPS_Power
    
    '@Debugger.basinc 
    'The Debugger config must not use an equals sign, or add comments or spaces to the end of these lines:
    #define Debugger_SplashExtra "https://github.com/alnhnt/PICAXE"
    
    '@RTC_MCP7940N.basinc 
    #define RTC_Debugging
    '#define RTC_Debugging_Registers
    '#define RTC_Battery_Backup

#Endregion

#Region "Resources"
'Pins
    pullup %10101010                        'For 20X2 the mask is B.7,B.6,B.5,B.1, B.0,C.7,C.6,C.0
    symbol Lamp_Power = C.2                 'Pin 8 drives N Channel MOSFET for OV to Booster Input (supplying lamp post).
    symbol GPS_Power = B.2                  'Pin 16 drives P Channel MOSFET for GPS +5V supply.
    symbol Timed = pinC.6                   'Pin 4 has a jumper to 0V, when connected system is on with power connected.
    
'Variables
    '@Debugger.basinc Variable
    'symbol _Debugger = b0                   'Debugger.basinc uses b0 for ASCII representation of binary and hex. 
    
    'Program Variables
    symbol LightStatus = b1
    symbol dayPosition = w1                 'Approx day in year based on month * 31 + day.
    symbol minutePosition = w2              'Minute of the day based on hour * 60 + minute.
    symbol dayPositionRTC = w3              'The "dayPosition" of last RTC update.
    
    '@RTC_MCP7940.basinc Variables
    'These variables are for program use, the module keeps copies in BCD format with register flags as per "RTC_VARIABLES".
    symbol seconds = b8                     'Assign symbol to any byte.
    symbol minutes = b9                     'Assign symbol to any byte.
    symbol hours = b10                      'Assign symbol to any byte.
    symbol weekday = b11                    'Assign symbol to any byte.
    symbol day = b12                        'Assign symbol to any byte.
    symbol month = b13                      'Assign symbol to any byte.
    symbol year = w7                        'Assign symbol to any byte.
    symbol alarmSetting = b16               'Assign symbol to any byte.
    
    '@GPS_NEO-M8N.basinc Variables    
    symbol _GPS_ChecksumA = b17             'Assign symbol to any byte.
    symbol _GPS_ChecksumB = b18             'Assign symbol to any byte.
    symbol _GPS_Length = b19                'Assign symbol to any byte.
    symbol _GPS_Error = b20                 'Assign symbol to any byte.

'Constants
    
    'PWM Setup
    symbol PWM_MODE_HALF_BRIDGE = 1         'Outputs A and B complement each other, Outputs C and D not used.
   	symbol PWM_POLARITY = 0                 'In half bridge mode this makes A and B active high.
   	symbol PWM_DEADBAND = 10                'DeadbandTime = Val * 4 / ClockCycleTime (@8MHz 10 = 5us).
   	symbol PWM_PERIOD = 255	                '@8MHz with PWMDIV16 255 = 488.28Hz (2.048ms).
   	symbol PWM_DUTY_HALF = 512	            'A and B are both 49.76% duty with 8MHz Clock, PWMDIV16, Period=255, Duty=512.
    
    'Alarm Setup (See RTC_MCP7940.basinc for Alarm Mask interpretation).
    symbol GPS_SYNC_MASK = $A0              'Alarm mask for hour check, to create a daily alarm.
    symbol GPS_SYNC_HOUR = 14               'NB: The GPS time update must be before the lights on time.
    symbol LIGHTS_MASK = $F0                'Alarm mask for precise match of all time and date parameters.
    symbol LIGHTS_ON_MINS = 930             'Use 24hr clock and set to hour * 60 + minute. E.g. 930 is 15:30.
    symbol LIGHTS_OFF_MINS = 1350           'As above 1350 = 22:30.
    symbol START_DATE = 373                 'Use month * 31 + day. E.g. 1st Dec = 373.
    symbol END_DATE = 35                    'As above 35 = 4th Jan. 
                               'NB: The end date must be before the start date, so the earliest end date is 1st Jan.
    
    '@Timing.basinc Constants
    'Do not add any comments or spaces after these 2 lines:
    #define CLOCK_SET_KHZ 8000
    #define TIMER_IN_HUNDRETHS 10
    'NB: "TIMER_IN_HUNDRETHS" is used to set the "timer" variable to increment every 100ms for GPS packet timeouts.
    
    '@GPS_NEO-M8N.basinc Constants
    symbol GPS_Variables = 113              '"GPS_NEO-M8N.basinc" requires 8 bptr variables to check packet(sentence) data.

    '@RTC_MCP7940.basinc Constants
    symbol RTC_VARIABLES = 121              'The "RTC_MCP7940.basinc" module uses 7 bptr variables from this address.
    symbol RTC_CONTROL = %00000000          'The RTC Control Register 7 settings are:
                                                'Bit7 MFP logic level output if no alarms or pulsing configured.
                                                'Bit6 Square Wave output. 1=Enabled.
                                                'Bit5 Alarm1. 1=Enabled.
                                                'Bit4 Alarm0. 1=Enabled.
                                                'Bit3 External Oscillator. 1=Enabled.
                                                'Bit2 Manual clock compensation. 1=Enabled.
                                                'Bit1 and Bit0 Pulse frequency:
                                                    '00=32.786kHz, 01=8.192kHz; 02=2.096kHz, 11=1Hz.
'Modules
    #include "Timing.basinc"
    #include "Debugger.basinc"
    #include "RTC_MCP7940N.basinc"
    #include "GPS_NEO-M8N.basinc"
    
#Endregion

#Region "Programme Initialisation"
Init:
	'Acknowledge power-up with lights and if in non-timed mode just hold there.
    LightsOn
    do while Timed = 0 
        debugger("Jumper connected for non-timed mode - Just keeping the lights on.",cr,lf)
        Pause5s
    loop
    
    'Check the RTC is running.
    Clock_Check

    'Power up and initialise GPS, then find time and update RTC.
    gosub UpdateRTC
    
    'Set hardware interrupt from RTC alarm pin and set system state based on time and date.
    hintsetup $22                               'Only use Interrupt 1 with rising edge.
    gosub SetState
    
    debugger("Initialised",cr,lf)

#Endregion

#Region "Main Program"
Main:                                
    if LightStatus = 1 then
        debugger("Having a doze until the alarm ",34,"interrupts",34," me!",cr,lf)
        settimer off                            'The timer would wake a doze
        doze 0                                  'This keeps the PWM running for when the lights are on.
    else
        debugger("Going for a sleep until the alarm ",34,"interrupts",34," me!",cr,lf)
        disablebod                              'This helps to reduce current drain.
        sleep 0
    endif
    Pause1s
    goto Main

#Endregion

#Region "Interrupt"
Interrupt:
    'Hardware interrupt triggered by RTC Alarm raising its MFP high, which is connected to hint1.
    debugger("@Interrupt",cr,lf)
    
    'Get system back to normal after SLEEP or DOZE.
    settimer TickToSet                          'Re-enable the timer used in packet timeouts, as per Timing.basinc.
    enablebod                                   'Re-enable Brown-Out Detection.
    
    'Check the time, set the output state, next alarm and interrupt.
    gosub SetState
    
    return
#EndRegion

#Region "Gosubs"

LightOn:
    hpwm PWMDIV16,PWM_MODE_HALF_BRIDGE,PWM_POLARITY,PWM_DEADBAND,PWM_PERIOD,PWM_DUTY_HALF
    high Lamp_Power
    LightStatus = 1
    return

LightOff:
    hpwm off
    low Lamp_Power
    LightStatus = 0
    return

UpdateRTC:
    debugger("@UpdateRTC - Turning on and initialising the GPS.",cr,lf)
    GPS_On
    gosub GPS_Initialise
    do
        debugger("Acquiring GPS time signal (could take 5 minutes).",cr,lf)
        gosub GPS_GetTime
        if _GPS_Error = 0 then exit
    loop
    debugger("Powering down GPS and updating clock.",cr,lf)
    GPS_Off
    Clock_Set
    dayPositionRTC = month * 31 + day
    return

SetState:
    debugger("@SetState",cr,lf)
    
    'Get current date and time.
    Clock_Read                                    
    dayPosition = month * 31 + day
    minutePosition = hours * 60 + minutes
    debugger("DayPosition=",#dayPosition,"   MinutePosition=",#minutePosition,cr,lf)
    
    'Update clock from GPS signal if needed.
    if dayPosition <> dayPositionRTC then gosub UpdateRTC
    
    'Check day and time to set lights and alarm
    if dayPosition >= START_DATE OR dayPosition <= END_DATE then
        debugger("Lights today",cr,lf)
        if minutePosition < LIGHTS_ON_MINS then
            LightsOff
            hours = LIGHTS_ON_MINS / 60
            minutes = LIGHTS_ON_MINS // 60
            seconds = 0
            alarmSetting = LIGHTS_MASK
            debugger("It's too early - Setting alarm to turn lights on.",cr,lf)
        elseif minutePosition < LIGHTS_OFF_MINS then
            LightsOn
            hours = LIGHTS_OFF_MINS / 60
            minutes = LIGHTS_OFF_MINS // 60
            seconds = 0
            alarmSetting = LIGHTS_MASK
            debugger("Lights should be on - Setting alarm to turn off.",cr,lf)
        else
            LightsOff
            hours = GPS_SYNC_HOUR
            alarmSetting = GPS_SYNC_MASK
            debugger("It's too late - Setting alarm for GPS RTC update.",cr,lf)
        endif
    else
        LightsOff
        hours = GPS_SYNC_HOUR
        alarmSetting = GPS_SYNC_MASK
        debugger("No lights today - Setting alarm for GPS RTC update.",cr,lf)
    endif
    Alarm_Set
    Alarm_Enable
    
    'Set interrupt for the clock's alarm signal
    hInt1Flag = 0                               'Clear the old interrupt, if present.
    setintflags $2, $2                          'Use hardware interrupt 1 only.
    
    pause 3000
    return
    
#EndRegion
#Region "License" 
#Rem

MIT License

Copyright (c) 2025 Alan Hunt

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
