
#Region "Program Notes"
#REM

            File: "Buzz_Wire_Game.bas"
         License: MIT (See end of file) 
  Change History: 2024/10/27 by Alan Hunt - 1st issue.


Microcontroller Pin Usage
==========================

Pin Usage                                           PICAXE 20X2 Pinout & Functions                   Pin Usage
                                -------------------------------------------------------------------
+5V Supply                      |1  Vdd                                                     Gnd 20|  0V Supply
Programming Input               |2  Serial In                                        Serial out 19|  Debugging Output
BATTERY (ADC3 VoltageBatt)      |3  C.7(ADC3/Out/In)                     B.0(In/Out/ADC1/hint1) 18|  AUDIO_TX (to DF Player @T9600)
HelpButton                      |4  C.6(In)                          B.1(In/Out/ADC2/hint1/SRQ) 17|  CELL (ADC2 for Cell 1 voltage)
LeaderboardButton               |5  C.5(hpwmA/pvmC.5/Out/In)            B.2(In/Out/ADC4/Comp2+) 16|  AUDIO_STATUS (DF Player active low)
RaceButton                      |6  C.4(hwpmB/SRNQ/Out/In)              B.3(In/Out/ADC5/Comp2-) 15|  LED_RED1 (1st "Get Ready")
InputPosL (Left Start Point)    |7  C.3(hwpmC/ADC7/Out/In)        B.4(In/Out/ADC6/hpwmD/Comp1-) 14|  PWM_BUZZ (Tone for Buzz Wire)
InputPosR (Right Start Point)   |8  C.2(kbclk/ADC8/Out/In)    B.5(In/Out/ADC10/hi2csda/hspisdi) 13|  LED_RED2 (2nd "Get Ready")
InputBuzz (Buzz Wire)           |9  C.1(hspisdo/kbdata/ADC9/Out/In)    B.6(In/Out/ADC11/hserin) 12|  LED_RED3 (3rd "Get Ready")
RESET_BUTTON                    |10 C.0(hserout/Out/In)             B.7(In/Out/hi2cscl/hspisck) 11|  LED_Green(Race "Go" light)
                                -------------------------------------------------------------------
 

PICAXE 20X2 Notes
=================
    * Chip hardware is the Microchip PIC18F14K22 MCU:
        - Power supply 1.8V to 5.5V. Default clock 8MHz.
        - Pullup and pulldown input currents measured respectively as 1.5nA and 300pA on B.1 when set as a digital input.
        - When an ADC channel is enabled it draws approximately 280 uA and the recommended source impedance is 10 kOhm.
        - Input over/under voltage protection has a maximum clamp current of 20mA.

Program Notes
=============
    * The game has 7 digital inputs monitored on Port C.  Five of the inputs are monitored by software interrupts with "setint" (Only c.1 to c.5 permitted for 20M2 and 20X2).  The symbol "getInputs" (pinsC) is used to read PortC simultaneously and place it in the symbol "GameInputs" (variable b3).  Then bits of b3 are used to check specific inputs, like InputBuzz(bit25).
    * Clock rate was set to 16MHz but it's not necessary.  It probably helps to speed up inputs, particularly as I left debugging on for show.
    * Timer3 word value is set to increment every 131 mS (Prescale8:1 * 65536 * 4 / Clock), so very roughly divide 8 to get seconds.


#EndREM
#EndRegion

#Region "Main Compiler Directives"
'Compiler Directives
#picaxe 20X2 
#no_data
#no_table
#no_debug
#define Debugger_On                         'Comment out this line to disable Debugging.

#Endregion

#Region "Resources"
'Pins
    symbol AUDIO_TX = B.0                   '@DF_Player_Mini.basinc: Serial Tx to audio module via 1K resistor.
    symbol CELL1 = pinB.1                   '@Voltage.basinc: Cell 1 voltage monitoring is ADC2(B.1).
    symbol AUDIO_STATUS = pinB.2            '@DF_Player_Mini.basinc: Busy is active low after time lag (AUDIO_IDLE and AUDIO_BUSY).
    symbol LED_RED1 = B.3                   '1st track light.
    symbol PWM_BUZZ = B.4                   'Tone for Buzz Wire.
    symbol LED_RED2 = B.5                   '2nd track light.
    symbol LED_RED3 = B.6                   '3rd track light.
    symbol LED_GREEN = B.7                  '4th "go" and running track light.
    symbol RESET_BUTTON = pinC.0            'Circuit board button to clear game stats if pressed during initialisation.
    symbol HELP_BUTTON = pinC.6             'Button to explain game.
    symbol BATTERY = pinC.7                 '@Voltage.basinc: Battery voltage monitoring is ADC3(C.7).

'Variables
    symbol GameTime = timer                 'Alias for the system "timer", measures elapsed game/idle time time in tenths of a second.
    symbol UpTime = timer3                  'Alias for "timer3", used for random number generation and uptime in 8th's of a second.
    
    symbol _Debugger = b0                   '"Debugger.basinc" module is limited to using b0 for Byte to ASCII bitstream conversion.
    
    symbol InterruptSetting = b1            'Interrupt setting for input pins.
    symbol IntSetBuzz = bit9
    symbol IntSetPosR = bit10
    symbol IntSetPosL = bit11
    symbol IntSetRace = bit12
    symbol IntSetLeaderboard = bit13

    symbol InterruptMask = b2               'Interrupt mask for input pins.
    symbol IntMaskBuzz = bit17
    symbol IntMaskPosR = bit18
    symbol IntMaskPosL = bit19
    symbol IntMaskRace = bit20
    symbol IntMaskLeaderBoard = bit21
    
    symbol GameInputs = b3                  'Game inputs on PortC with quick byte getter "getInputs" and bit checkers in b3.
    symbol getInputs = pinsC
    symbol InputBuzz = bit25
    symbol InputPosR = bit26
    symbol InputPosL = bit27
    symbol RaceButton = bit28
    symbol LeaderboardButton = bit29
    symbol HelpButton = bit30
    
    symbol GameStatus = b4                  'Game Status has enumerated state constants
    symbol GameDirection = b5
    
    symbol SoundLoopIdle = b6               'Pointer for a list of tracks played when no game is running.
    symbol SoundLoopBackground = b7         'Pointer for a list of tracks played as background music during the game.
    symbol SoundLoopCrash = b8              'Pointer for a list of crash sounds that interupt the background music.
    symbol SoundLoopFanfare = b9            'Pointer for a list of tracks played at the end of a game.
    symbol SoundLoopAdvert = b10            'Pointer for a list of adverts played when the game is idle for too long.
    
    symbol CrashCount = b11            
    symbol LapTime = w6                     'Time in tenths of a second.
    symbol PenaltyTime = w7                 'Time added, in tenths, for a premature race start.
    
    symbol LapRecord = w8
    symbol PlayerNumber = w9
    symbol PlayerRanking = b20
    
    symbol GameTimerLog = b21
    symbol GameTimer1 = w11
    symbol GameTimer2 = w12
    symbol GameTimer3 = w13
    
    symbol VoltsCell2 = w14
    symbol VoltsCell1 = w15
    symbol BatteryCapacity = b32
    
    'Internal variables for gosubs (Try and keep these unique due to ease Interrupt handling)
    symbol _LeaderBoard_ResultPTR = b33     'For Gosub PlayerRank only.
    symbol _LeaderBoard_TimePTR = b34       'For Gosubs PlayerRank and SayLeaderboard.
    symbol _LeaderBoard_PlayerPTR = b35     'For Gosubs PlayerRank and SayLeaderboard.
    symbol _GameEndW = w18                  'For Gosub GameEnd only.
    symbol _LeaderBoardW = w19              'For Gosubs PlayerRank and SayLeaderboard.
    symbol _LeaderBoardB = b40              'For Gosubs PlayerRank and SayLeaderboard.
    
    '@DF_Player_Mini.basinc Variables
    symbol _Timing = w21					'Assign symbol to any spare Word.
    
    '@DF_Player_Mini.basinc Variables
    symbol _Audio_Digit = b41               'Assign symbol to any spare Byte.
    symbol _Audio_Integer = w22             'Assign symbol to any spare Word.
    symbol _Audio_Fraction = w23            'Assign symbol to any spare Word.
    symbol _Audio_Track = b48               'Assign symbol to any spare Byte.
    symbol _Audio_Byte = b49                'Assign symbol to any spare Byte.

    '@Voltage.basinc Variables
    symbol Voltage_Vdd = w25                'Assign symbol to any spare Word. Stores PICAXE supply voltage as mV.
    symbol _VoltageADCval = w26             'Assign symbol to any spare Word.
    symbol _VoltageModulus = w27            'Assign symbol to any spare Word.    
    
'Constants
    'For interrupts
    symbol VAL_DEFAULT = %00000000          'Interrupt value default
    symbol MASK_DEFAULT = %00111110         'Interrupt mask default
    symbol NOT_MASK_DEFAULT = %11000001
    symbol CONTACT = 1                      'Logic level for contact with buzz wire or end points.
    symbol NO_CONTACT = 0
    symbol PRESSED = 1                      'Logic level for button press.
    symbol NOT_PRESSED = 0
    
    'For GameStatus variable
    symbol GAME_NOT_SET = 0                 'Not at a valid start point.
    symbol GAME_WAITING = 1                 'At a valid start point and waiting for Race or practise.
    symbol GAME_BEGINNING = 2               'Race button pressed.
    symbol GAME_NOT_STARTED = 3             'Race Go signal was given but not moved off yet.
    symbol GAME_PLAYING = 4
    symbol GAME_ENDING = 5                  'Reached end point and stating performance.
    symbol GAME_PRACTISE = 6                'Moved off without pressing Race button.
    
    'For GameDirection variable
    symbol R_TO_L = 1
    symbol L_TO_R = 2
    
    'For Penalty time (tenths of a second)
    symbol PENALTY_PREMATURE_START = 100
    symbol PENALTY_CRASH = 30
    
    'Initialise Variables
    symbol SOUND_IDLE_START = 177           'MP3 177 to 215 play backgound music when no game is running.
    symbol SOUND_IDLE_END = 215
    symbol SOUND_BACKGROUND_START = 218     'MP3 218 to 238 play background music during the game. 
    symbol SOUND_BACKGROUND_END = 238
    symbol SOUND_FANFARE_START = 250        'MP3 250 to 254 play different game endings for leaderboard entries.
    symbol SOUND_FANFARE_END = 254
    symbol SOUND_CRASH_START = 1            'ADVERT 1 to 8 play crash sounds that interupt the background music.
    symbol SOUND_CRASH_END = 8
    symbol SOUND_ADVERT_START = 15          'ADVERT 15 to 22 interuppt idle music to encourage game playing.
    symbol SOUND_ADVERT_END = 22
    
    'Timer Values (tenths of a second)
    symbol GAME_TIME1 = 100                 'Some encouragement after 10S, or quit a failed race start.
    symbol GAME_TIME2 = 300                 'Some encouragement after 30S.
    symbol GAME_TIME3 = 900                 'Suggest you let someone else play after 90S.
    symbol IDLE_TIMER = 900                 'Play an advert to encourage playing every 90S.
    
    'For EEPROM storage locations
    symbol aGAME_COUNT  = 2
    symbol LEADERBOARD_SIZE = 20            'Limited to 20 to make speaking nth's easier.
    symbol aLEADERBOARD_PLAYER = 30         'The Leaderboard player numbers occupy EEPROM addresses from here.
    symbol aLEADERBOARD_PLAYER_END = 68     'Player numbers are stored as words, the last byte used is this plus 1. 
    symbol aLEADERBOARD_TIME = 70           'Laptimes are stored as words from here.
    symbol aLEADERBOARD_TIME_END = 108      'The last byte is this +1.
    symbol LEADERBOARD_SPOKEN_SIZE = 4      'Number of entries spoken after LEADERBOARD_BUTTON pressed (limited to 4 by track 120).
    
    'For Battery Monitoring (Voltage in mV)
    symbol VOLTS_CELL_GOOD = 3400           'A li-ion Samsung INR18650-30Q with constant 200mA load was tested to be about 18% at 3400 mV.
    symbol VOLTS_CELL_EXHAUSTED = 3100      'The battery spec is 2.5V cut-off but tested down to 2.8V, this gave about 6% at 3100 mV.
                                            'Caution: Figures change drastically for 3.0V cut-off cells, or high current loads.
    
    '@Timing.basinc Constants
    'CLOCK_SET_KHZ options: 31,250,500,1000,2000,4000,8000,16000,32000,or 64000 (Dependenton chip). No equals sign and nothing after number.
    #define CLOCK_SET_KHZ 16000
    #define TIMER_IN_HUNDRETHS 10

    '@DF_Player_Mini.basinc Constants
    symbol AUDIO_VOLUME = 31                '0 to 31(Maximum).
    symbol AUDIO_BAUD = T9600_16            'Tx is idle high (T) and 9600 bps, the last characters you adjust to your clock speed.
    symbol AUDIO_ACTIVE = 0                 'The AUDIO_STATUS pin is active low, indicating audio playing.
    symbol AUDIO_IDLE = 1                   'AUDIO_STATUS high indicates the module is idle, or seeking to play a track on the disk.

   '@Voltage_X2.basinc Constant
    symbol VoltageDividend = 10595       'Adjust value for FVR inaccuracy, see "Voltage_X2.basinc" Calibration.


'Modules
    #include "Debugger.basinc"
    #include "Timing.basinc"
    #include "DF_Player_Mini.basinc"
    #include "Voltage_X2.basinc"
#Endregion

#Region "Programme Initialisation"
Init:
    if PenaltyTime = PENALTY_PREMATURE_START then goto Main    'A premature start causes a Run 0

    Pause1S                                 'Allows PICAXE Editor time to open the terminal window.
    DebugLine(ppp_filename)                 'Displays the programming filename in PICAXE Editor Terminal if "Debugger_On" is defined.
    DebugLine(ppp_datetime)                 'Displays the programming date and time.

'Setup Pins
    dirsB = %11111001                       'Set port B7 to B0 pins (1=output).
    dirsC = %00000000                       'Ensure all C pins are inputs.
    adcsetup = %0000000000000110            'Use ADC3(Pin 3, C.7) and ADC2 (Pin 17, B.1), this disables digital interface circuitry.
    hpwm PWMDIV16, 0, 0, %1000, 255, 511    'Use PWM to produce lowest tone possible for a potential buzz wire contact sound. 

'Setup Timers
    tmr3setup %10110001                     'Enables timer3 to generate randomness and for approx timing (8 per Sec, see notes).
    
'Initialise Variables
    SoundLoopIdle = SOUND_IDLE_START                'MP3 150 to 172 play background music when no game is running.
    SoundLoopBackground = SOUND_BACKGROUND_START    'MP3 200 to 212 play background music during the game. 
    SoundLoopCrash = SOUND_CRASH_START              'ADVERT 1 to 9 play crash sounds that interupt the background music.
    SoundLoopFanfare = SOUND_FANFARE_START          'MP3 250 to 254 play different game endings.
    SoundLoopAdvert = SOUND_ADVERT_START            'ADVERT 15 to 21 to encourage play when idle too long.

    GameTimer1 = GAME_TIME1                 'Some encouragement after 10S, or quit a failed race start.
    GameTimer2 = GAME_TIME2                 'Some encouragement after 30S.
    GameTimer3 = GAME_TIME3                 'Suggest you let someone else play after 90S.
    
'Initialise Audio Module and check battery
    gosub AudioInitialise
    PlayMP3(063,"Restarted")               'Play "The system has restarted"
    gosub CheckBattery
    
'Reset game records during startup if necessary
    if RESET_BUTTON = PRESSED then
        DebugLine("@Reset Stats")
        PlayerNumber = 0
        write aGAME_COUNT, WORD PlayerNumber
        LapRecord = 0
        for PlayerRanking = aLEADERBOARD_Player to aLEADERBOARD_TIME_END step 2
            write PlayerRanking, WORD PlayerNumber
        next PlayerRanking
        PlayMP3(0145,"game stats reset")
        gosub AudioWaitForIdle
    endif

'Speak the game stats
    gosub SayGamesPlayed
    gosub SayLapRecord                
    
'Ensure the car is at one end of the track and prepare interrupt settings
    gosub GameGetReady
    InterruptSetting = VAL_DEFAULT
    InterruptMask = MASK_DEFAULT
    
'Confirm Initialisation
    PlayMP3(0151," Hello the game is ready") 
    PlayMP3(0133," Press Help or start now")
    DebugLine("@Initialised")
    debug                                   'Display values in PICAXE Editor unless "no_debug" is defined.    

#Endregion

#Region "Main"
Main:                                
    'Contiunally loop around Main to see if music has ended or GameTimers have expired.
    setint NOT InterruptSetting, InterruptMask  'Set interupts for low state on C1 to C5 (BuzzWire, PosR, PosL, Race and Leaderboard)
    
   
    'Check if the audio has finished playing.
    if AUDIO_STATUS = AUDIO_IDLE then
        DebugLine("@Main Without Audio")
        gosub DebugGameStatus
        select case GameStatus
            case GAME_NOT_SET
                PlayNow(0134," Place car at 1 end of the track")
                Pause10S
            case GAME_WAITING
                gosub CheckBattery
                gosub AudioWaitForIdle
                DebugOut("Play Idle ",#SoundLoopIdle,cr,lf)
                PlayNow(SoundLoopIdle," IdleTrack")         'Play the next rotating idle track
                inc SoundLoopIdle
                if SoundLoopIdle > SOUND_IDLE_END then
                    SoundLoopIdle = SOUND_IDLE_START
                endif
            case GAME_NOT_STARTED, GAME_PLAYING, GAME_PRACTISE
                DebugOut("Play Background ",#SoundLoopBackground,cr,lf)
                PlayNow(SoundLoopBackground," GameTrack")   'Play the next rotating game track
                inc SoundLoopBackground
                if SoundLoopBackground > SOUND_BACKGROUND_END then
                    SoundLoopBackground = SOUND_BACKGROUND_START
                end if
            else
            'Other values GAME_BEGINNING and GAME_ENDING are temporary and should not occur.
        endselect
    endif
    
    'Check if timers have expired.
    select case GameStatus
        case GAME_WAITING
            if GameTime > IDLE_TIMER then
                PlayAdvert(SoundLoopAdvert,"Roll-up etc")
                Gametime = 0
                inc SoundLoopAdvert
                if SoundLoopAdvert > SOUND_ADVERT_END then
                    SoundLoopAdvert = SOUND_ADVERT_START
                endif
            endif
            if HELP_BUTTON = PRESSED then
                DebugLine("Help Pressed")
                GameTime = 0                    'Reset the timer for encouragement adverts
                PlayNow(0132," GameIntro")
                gosub AudioWaitForIdle
            endif    
        case GAME_BEGINNING
            gosub GameBegin
        case GAME_NOT_STARTED
            'DebugOut("GameTime: ",#GameTime,cr,lf)
            'DebugOut(", GameTimer1: ",#GameTimer1,cr,lf)
            if GameTime > GameTimer1 then
                DebugLine("Not started after 10S")
                gosub GameQuit
                PlayNow(0153, "Oh no it's nap time")
                PlayMP3(0152, "Press the race button to start again")
                gosub AudioWaitForIdle
            endif
        case GAME_PLAYING
            select case GameTime
                case > GameTimer1
                    if CrashCount = 0 then
                        PlayAdvert(11,"Too slow")
                    elseif CrashCount > 2 then
                        PlayAdvert(14, "Slow down")
                    endif
                    GameTimer1 = 65535
                case > GameTimer2
                    if CrashCount < 2 then
                        PlayAdvert(11,"Too slow")
                    elseif CrashCount > 5 then
                        PlayAdvert(14, "Slow down")
                    endif
                    GameTimer2 = 65535
                case > GameTimer3
                    PlayNow(0135, "You've been playing a while, let someone else too")
                    GameTimer3 = 65535
            endselect
    endselect
    
    Pause10mS
    goto Main
    
#Endregion

#Region "Interrupts"
Interrupt:
    GameInputs = getInputs
    DebugLine("@Interupt")
    gosub DebugGameStatus
    gosub DebugGameInputs
    
    select case GameStatus
    case GAME_NOT_SET
        if InputPosL = CONTACT OR InputPosR = CONTACT then          'Car now placed correctly at one end of the track.
            GameStatus = GAME_WAITING
            if InputPosL = CONTACT then
                GameDirection = L_TO_R
            else
                GameDirection = R_TO_L
            endif
            PlayNow(062," Thank you")
        endif
    
    case GAME_WAITING
        if InputPosL = NO_CONTACT AND InputPosR = NO_CONTACT then   'Car moving without Race button, so it's a practise.
            GameStatus = GAME_PRACTISE
            SoundLoopCrash = SOUND_CRASH_START
            CrashCount = 0
            PlayNow(0147,"having a practise hey.  There's no laptime for you")
        endif
        if LeaderboardButton = PRESSED then
            if HelpButton = PRESSED then
                gosub AudioClear
                gosub CheckBattery                                  'If both pressed then state battery cell voltages
                PlayNow(0070, "The cell voltages are")
                AudioSpeakNumber(VoltsCell1)
                PlayMP3(0130, "millivolts")
                PlayMP3(0060, "and")
                AudioSpeakNumber(VoltsCell2)
                PlayMP3(0130, "millivolts")
            else
                gosub SayLeaderboard
            endif
            GameTime = 0                                            'Reset the timer for encouragement adverts
        endif
        if RaceButton = PRESSED then
            GameStatus = GAME_BEGINNING
        endif
    
    case GAME_BEGINNING
        if InputPosL = NO_CONTACT AND InputPosR = NO_CONTACT then   'Car moved too early while game still begining (before green light).
            Pause100ms                                              'Pause a while to debounce a player wiggling the handle.
            GameInputs = getInputs
            if InputPosL = NO_CONTACT AND InputPosR = NO_CONTACT then   'Car is really moving too early, so start the game and log the penalty.
                GameStatus = GAME_PLAYING
                'DebugLine("Started too Soon")
                PlayNow(0148,"Time penalty. Started too soon.")
                low LED_RED1, LED_RED2, LED_RED3
                high LED_GREEN
                GameStatus = GAME_PLAYING
                GameTimer1 = GAME_TIME1
                GameTimer2 = GAME_TIME2
                GameTimer3 = GAME_TIME3
                SoundLoopCrash = SOUND_CRASH_START
                CrashCount = 0
                PenaltyTime = PENALTY_PREMATURE_START
                GameTime = 0
                IntSetPosL = InputPosL
                IntSetPosR = InputPosR
                IntSetBuzz = InputBuzz
                run 0
            endif
        endif
    
    case GAME_NOT_STARTED
        if InputPosL = NO_CONTACT AND InputPosR = NO_CONTACT then   'Car moving correctly after given the green light.
            DebugLine("Started OK")
            GameStatus = GAME_PLAYING
        endif
    
    case GAME_PLAYING
        if InputPosL = CONTACT then                                  'Car touching left end of the track.
            if GameDirection = R_TO_L then
                gosub GameEnd
            else
                if GameTime > 20 then                                'debounce a return to start
                    PlayNow(0144," Going back huh")
                    PlayMP3(0152," Press the race button to start again")
                    gosub AudioWaitForIdle
                    gosub GameQuit
                endif
            endif
        endif
        if InputPosR = CONTACT then                                  'Car touching right end of the track.
            if GameDirection = L_TO_R then
                gosub GameEnd
            else
                if GameTime > 20 then                                'debounce a return to start
                    PlayNow(0144," Going back huh")
                    PlayMP3(0152," Press the race button to start again")
                    gosub AudioWaitForIdle
                    gosub GameQuit
                endif
            endif
        endif
        if InputBuzz = CONTACT then                                  'Buzz wire contact
            gosub GameCrash
        endif
    
    case GAME_PRACTISE
        if InputPosL = CONTACT or InputPosR = CONTACT then           'Car finished practising on the track.
            GameStatus = GAME_WAITING
            if InputPosL = CONTACT then
                GameDirection = L_TO_R
            else
                GameDirection = R_TO_L
            endif
            PlayNow(0150," Practise over, press green button")
        endif
        if InputBuzz = CONTACT then                                  'Buzz wire contact
            gosub GameCrash
        endif            
    
    endselect
    
    IntSetPosL = InputPosL
    IntSetPosR = InputPosR
    
    gosub DebugGameStatus
    DebugLine("@Interupt End")
    setint NOT InterruptSetting, InterruptMask
    
    return
#Endregion

#Region "Subroutine GameGetReady"
GameGetReady:
    DebugLine("@GameGetReady")    
    GameInputs = getInputs
    gosub DebugGameInputs
    
    if InputPosL = NO_CONTACT and InputPosR = NO_CONTACT then
        do until InputPosL = CONTACT or InputPosR = CONTACT         'Ensure car is at 1 end of the track
            PlayMP3(0134,"Place car at 1 end of the track")
            Pause3S
            GameInputs = getInputs
        loop
        
        PlayNow(062," Thank you")
    endif
    
    if InputPosL = CONTACT then
        GameDirection = L_TO_R
    else
        GameDirection = R_TO_L
    end if
    
    IntSetPosL = InputPosL
    IntSetPosR = InputPosR
    
    GameStatus = GAME_WAITING

    return
#Endregion

#Region "Subroutine GameBegin"
GameBegin:
    DebugLine("@GameBegin")    
    GameStatus = GAME_BEGINNING    
    read aGAME_COUNT, WORD PlayerNumber
    inc PlayerNumber                                                'Don't flash the PlayerNumber increase until a successful end.
    
    PlayNow(173," Arcade token")
    PlayMP3(157," Player")
    AudioSpeakNumber(PlayerNumber)
    PlayMP3(174," Wait for the green light")
    PlayMP3(175," Mario Kart beeps")
    
    high LED_RED1
    Pause1S
    high LED_RED2
    Pause1S
    high LED_RED3
    Pause1S
    low LED_RED1, LED_RED2, LED_RED3
    high LED_GREEN
    
    GameStatus = GAME_NOT_STARTED
    GameTimer1 = GAME_TIME1
    GameTimer2 = GAME_TIME2
    GameTimer3 = GAME_TIME3
    SoundLoopCrash = SOUND_CRASH_START
    CrashCount = 0
    PenaltyTime = 0
    GameTime = 0
    
    return
#Endregion

#Region "Subroutine GameCrash"
GameCrash:
    DebugLine("@GameCrash")
    PlayAdvert(SoundLoopCrash, "Crash")                             'There is a timed delay in PlayAdvert, which helps as a crash rate limiter.
    if CrashCount < 255 then
        inc CrashCount
        inc SoundLoopCrash
        if SoundLoopCrash > SOUND_CRASH_END then 
            SoundLoopCrash = SOUND_CRASH_START
        endif
    endif
    DebugOut("CrashCount=",#CrashCount,cr,lf)
    return
#Endregion

#Region "Subroutine GameQuit"
GameQuit:
    DebugLine("@GameQuit")
    low LED_RED1, LED_RED2, LED_RED3, LED_GREEN
    gosub GameGetReady
    GameTime = 0
    return
#Endregion

#Region "Subroutine GameEnd"
GameEnd:
    DebugLine("@GameEnd")
    
    'Record Game and notify of GameEnd
    GameStatus = GAME_ENDING
    LapTime = GameTime
    low LED_GREEN
    gosub AudioClear
    write aGAME_COUNT, WORD PlayerNumber
    PlayNow(0136," You finished!") 
    
    'Add 1 minute penalty if crash time is greater than laptime.
    _GameEndW = PENALTY_CRASH * CrashCount
    if _GameEndW > Laptime then
        PenaltyTime = PenaltyTime + 600
        PlayMP3(246," Slow down stop the insanity!")
        PlayMP3(155," 1 minute penalty because crashtime > laptime")
    endif
    
    'Calculate laptime and penalty time (measured in tenths of a second)
    DebugOut("GameTime=", #Laptime)
    DebugOut(", CrashTime=", #_GameEndW)
    PenaltyTime = _GameEndW + PenaltyTime
    LapTime = LapTime + PenaltyTime
    DebugOut(", Adjusted=",#LapTime,cr,lf)
    
    'Leaderboard ranking and associated messages.
    gosub PlayerRank
    select case PlayerRanking
    case 0
        PlayMP3(0170," Ah you just missed out on the leaderboard, have another try!")
    case 1    
        LapRecord = LapTime
        PlayMP3(0149," New lap record")
        _GameEndW = UpTime % 4
        _GameEndW = _GameEndW + 240
        PlayMP3(_GameEndW," Winners track")
        gosub PlayFanfare
    else
        gosub PlayFanfare
    endselect

    'Speak about crashes
    if CrashCount = 0 then
        PlayMP3(0142," No crashes!")
        if LapTime <> LapRecord then 
            PlayMP3(0247," Wow all I can say is wow!")
        endif
        PlayMP3(0137," Your time was")
    else
        if CrashCount > 9 then
            PlayMP3(0143," The car is a right off.")
        endif
        
        PlayMP3(0140," You crashed")
        AudioSpeakNumber(CrashCount)
        PlayMP3(0141," times & each cost")'
        AudioSpeakNumber(PENALTY_CRASH/10)
        PlayMP3(0083," seconds")
        PlayMP3(154," Your adjusted time was")    
    endif
    
    'Speak the laptime seconds
    AudioSpeakTenths(LapTime)
    PlayMP3(0083," seconds")
    
    If PlayerRanking <> 1 then gosub SayLapRecord
    
    gosub GameQuit
    PlayMP3(0156," Waiting for next player!")

    return
#Endregion

#Region "Subroutine SayGamesPlayed"
SayGamesPlayed:
    read aGAME_COUNT, WORD PlayerNumber
    DebugOut("@SayGamesPlayed: ",#PlayerNumber,cr,lf)
    PlayMP3(0138," There have been")
    AudioSpeakNumber(PlayerNumber)
    PlayMP3(0139," games")
    return
#Endregion

#Region "Subroutine SayLeaderboard"
SayLeaderBoard:
    read aGAME_COUNT, WORD PlayerNumber
    DebugLine("@SayLeaderBoard")
    if PlayerNumber = 0 then
        '@No games yet
        gosub AudioClear
        gosub sayGamesPlayed
    else
        '@Speak Leaderboard
        PlayNow(0158, "The top")
        If PlayerNumber > LEADERBOARD_SPOKEN_SIZE then
            PlayMP3(LEADERBOARD_SPOKEN_SIZE, "{n}")
        else
            PlayMP3(PlayerNumber, "{n}")
        endif
        PlayMP3(0159," leaderboard positions are:")
        _LeaderBoard_PlayerPTR = aLEADERBOARD_PLAYER
        _LeaderBoard_TimePTR = aLEADERBOARD_TIME
        _LeaderBoard_ResultPTR = 0
        do
            read _LeaderBoard_PlayerPTR, WORD _LeaderBoardW
            if _LeaderBoardW = 0 then exit                      'Quit leaderboard if the entry isn't filled yet.
            
            _LeaderBoardB = 160 + _LeaderBoard_ResultPTR        'Track 0160 to 0163 is "1st place" to "4th place".
            PlayMP3(_LeaderBoardB," {nth} place is")
            PlayMP3(0157," Player")
            AudioSpeakNumber(_LeaderBoardW)
            
            read _LeaderBoard_TimePTR, WORD _LeaderBoardW
            PlayMP3(0164," with laptime")
            AudioSpeakTenths(_LeaderBoardW)
            PlayMP3(0083," seconds")
            
            inc _LeaderBoard_ResultPTR
            _LeaderBoard_PlayerPTR = _LeaderBoard_PlayerPTR + 2
            _LeaderBoard_TimePTR = _LeaderBoard_TimePTR + 2
            
        loop until _LeaderBoard_ResultPTR = LEADERBOARD_SPOKEN_SIZE         'Only speak the first n entries.
        
        if PlayerNumber > LEADERBOARD_SPOKEN_SIZE then gosub sayGamesPlayed 'Speak game count if more records.    
        PlayMP3(0165, "Press green button to beat them")
    endif
    GameTime = 0
    return
#Endregion

#Region "Subroutine SayLapRecord"
SayLapRecord:
    read aLEADERBOARD_TIME, WORD LapRecord
    DebugOut("@SayLapRecord: ",#LapRecord,cr,lf)
    if LapRecord > 0 then
        PlayMP3(0146," The lap record is")
        AudioSpeakTenths(LapRecord)
        PlayMP3(0083," seconds")
    endif
    return
#Endregion

#Region "Subroutine PlayFanfare"
PlayFanfare:
    PlayMP3(0166, "Congratulations you are")
    _GameEndW = 32 + PlayerRanking
    PlayMP3(_GameEndW, "nth")
    PlayMP3(0167, "on the leaderboard")
    _GameEndW = PlayerNumber / 2
    if PlayerRanking <= _GameEndW then  
        PlayMP3(168," Musical tribute just for you.")
        PlayMP3(SoundLoopFanfare," Fanfare")
        inc SoundLoopFanfare
        if SoundLoopFanfare > SOUND_FANFARE_END then 
            SoundLoopFanfare = SOUND_FANFARE_START
        endif
    endif
    return
#Endregion

#Region "Subroutine PlayerRank"
PlayerRank:
    'DebugLine("@PlayerRank")
    
    '@Work down the leaderboard to determine ranking from the 1st beaten or blank time entry.
    _LeaderBoard_ResultPTR = aLEADERBOARD_TIME    
    do
        read _LeaderBoard_ResultPTR, WORD _LeaderBoardW
        if _LeaderBoardW = 0 OR LapTime < _LeaderBoardW then exit
        inc _LeaderBoard_ResultPTR
        inc _LeaderBoard_ResultPTR
    loop until _LeaderBoard_ResultPTR > aLEADERBOARD_TIME_END
    
    '@Chose action based on ranking.
    select case _LeaderBoard_ResultPTR
    case = aLEADERBOARD_TIME_END
        '@Last entry on the leaderboard.
        PlayerRanking = aLEADERBOARD_TIME_END - aLEADERBOARD_TIME / 2 + 1
        write aLEADERBOARD_PLAYER_END, WORD PlayerNumber
        write aLEADERBOARD_TIME_END, WORD LapTime
        'DebugOut("RankLast=",#PlayerRanking,cr,lf)
    case > aLEADERBOARD_TIME_END
        '@Not on the leaderboard.
        PlayerRanking = 0
        'DebugLine("Rank=None")
        return
    else
        '@Other placing on the leaderboard.
        PlayerRanking = _LeaderBoard_ResultPTR - aLEADERBOARD_TIME / 2 + 1
        'DebugOut("RankElse=",#PlayerRanking,cr,lf)
        
        '@Work up the leaderboard to shuffle slower entries down.
        _LeaderBoard_PlayerPTR = aLEADERBOARD_PLAYER_END - 2
        _LeaderBoard_TimePTR = aLEADERBOARD_TIME_END - 2
        do
            'Move time entry down
            read _LeaderBoard_TimePTR, WORD _LeaderBoardW                
            _LeaderBoard_TimePTR = _LeaderBoard_TimePTR + 2
            write _LeaderBoard_TimePTR, WORD _LeaderBoardW
            _LeaderBoard_TimePTR = _LeaderBoard_TimePTR - 4
            
            'Move player entry down
            read _LeaderBoard_PlayerPTR, WORD _LeaderBoardW
            _LeaderBoard_PlayerPTR = _LeaderBoard_PlayerPTR + 2 
            write _LeaderBoard_PlayerPTR, WORD _LeaderBoardW
            _LeaderBoard_PlayerPTR = _LeaderBoard_PlayerPTR - 4
            
        loop until _LeaderBoard_TimePTR < _LeaderBoard_ResultPTR

        '@Insert new leaderboard entry
        _LeaderBoard_PlayerPTR = _LeaderBoard_PlayerPTR + 2 
        write _LeaderBoard_PlayerPTR, WORD PlayerNumber
        _LeaderBoard_TimePTR = _LeaderBoard_TimePTR + 2
        write _LeaderBoard_TimePTR, WORD LapTime
    endselect
    'DebugOut("Rank=",#PlayerRanking,cr,lf)
    #rem'For Debug output only:
    for _LeaderBoard_PlayerPTR = aLEADERBOARD_PLAYER_END to aLEADERBOARD_PLAYER STEP -2
        'DebugOut("PlayerRankPTR=",#_LeaderBoard_PlayerPTR)
        read _LeaderBoard_PlayerPTR, WORD _LeaderBoardW
        DebugOut("Player=",#_LeaderBoardW)
        _LeaderBoard_TimePTR = _LeaderBoard_PlayerPTR + aLEADERBOARD_TIME - aLEADERBOARD_PLAYER
        read _LeaderBoard_TimePTR, WORD _LeaderBoardW
        DebugOut(", Time=",#_LeaderBoardW,cr,lf)
    next _LeaderBoard_PlayerPTR
    #endrem
    return
#EndRegion

#Region "Subroutine CheckBattery"
CheckBattery:
    GetVdd
    VoltsByVdd(VoltsCell2,3)                            'Get half battery voltage on ADC3 and store in VoltsCell2 as mV.
    VoltsByVdd(VoltsCell1,2)                            'Get cell voltage on ADC2 and store in VoltsCell1 as mV.
    VoltsCell2 = VoltsCell2 * 2 - VoltsCell1            'Convert ADC3 input to Cell2 voltage.
    'DebugOut("Vdd: ",#Voltage_Vdd,"mV",cr,lf)
    'DebugOut("Cell 2: ",#VoltsCell2,"mV",cr,lf)
    'DebugOut("Cell 1: ",#VoltsCell1,"mV",cr,lf)
    
    if VoltsCell2 > VOLTS_CELL_GOOD AND VoltsCell1 > VOLTS_CELL_GOOD then
        'DebugLine("Battery cells good")
    else
        if VoltsCell2 < VOLTS_CELL_EXHAUSTED OR VoltsCell1 < VOLTS_CELL_EXHAUSTED then
            'DebugLine("Battery cells exhausted")
            PlayMP3(0069,"System shutting down due to low battery")
            sleep 0                                     'Enter low power state, essentially off.
        else
            'DebugLine("Battery cells low")
            PlayMP3(0068,"Warning, battery is below 20%")
        endif
    endif
    return
#Endregion

#Region "Subroutine DebugGameStatus"
#ifndef Debugger_On
    DebugGameStatus:
    Return
#else
    DebugGameStatus:
        DebugOut("GameStatus: ")
        select case GameStatus
        case GAME_NOT_SET
            DebugOut("NotSet")
        case GAME_WAITING
            DebugOut("Waiting")
        case GAME_BEGINNING
            DebugOut("Beginning")
        case GAME_NOT_STARTED
            DebugOut("NotStarted")
        case GAME_PLAYING
            DebugOut("Playing")
        case GAME_ENDING
            DebugOut("Ending")
        case GAME_PRACTISE
            DebugOut("Practising")
        endselect

        DebugOut(", Direction: ")
        select case GameDirection
        case L_TO_R
            DebugLine("Left to Right")
        case R_TO_L
            DebugLine("Right to Left")
        else
            DebugLine("Not Set")
        endselect
    return
#endif
#Endregion

#Region "Subroutine DebugGameInputs"
#ifndef Debugger_On
    DebugGameInputs:
    Return
#else
    DebugGameInputs:
        DebugOut("GameInputs: ", #GameInputs, " ")
        if GameInputs = 128 then
            DebugLine("Nothing")
        else
            if InputBuzz = CONTACT then
                DebugOut("BuzzWire ")
            endif
            if InputPosR = CONTACT then
                DebugOut("Right ")
            endif
            if InputPosL = CONTACT then
                DebugOut("Left ")
            endif
            if RaceButton = PRESSED then
                DebugOut("Race ")
            endif
            if HelpButton = PRESSED then
                DebugOut("Help")
            endif
            DebugOut(cr,lf)
        endif
    return
#endif
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
