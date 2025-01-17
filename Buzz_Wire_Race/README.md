
# BUZZ WIRE RACE
Buzz Wire Race is an electronic game representing a car on a racetrack.  The player gets a lap time that includes time penalties for bumps along the track.  The game uses a PICAXE 20X2 microcontroller to provide timing and a leaderboard; and to control LED start lights and a DF Player Mini daughter board for sound effects, music and speech.

## Contents
This file contains:	
- [Game_Description](#Game_Description)
- [Maker_Information](#Maker_Information)
	- [Metalwork, Woodword and Plastic](#Maker_Information)
	- [Electrical](#Electrical)
	- [Electronics](#Electronics)
	- [Programming](#Programming)
	- [Audio](#Audio)
	- [Graphics](#Graphics)
- [Suggested_Improvements](#Suggested_Improvements)
- [License](#License)

Other files in this folder include:
- Contents of a [Presentation_Folder](./Documents/Presentation_Folder-Main.pdf) intended for public viewing, which includes a 1 page summary, photos, diagrams and functional specification.
- [Electronics_Schematic](./Pictures/KiCAD_Schematic.jpg), produced in KiCad v8.0.3.
- [Circuit_Board_Layout](./Pictures/VeroRoute_Circuit_Board.jpg), based on stripboard and produced in VeroRoute v2.39 from the KiCad netlist.
- [Bill_of_Materials](./Electronics_Schematic/Buzz_Wire_Game_BOM.csv) from the KiCad schematic.
- [Program](./Software/Buzz_Wire_Game.bas) written in PICAXE BASIC with the PICAXE Editor v6.2.0.0.
- [Software_Modules](./Software) for PICAXE programs that ease Timing, Debugging, Voltage Monitoring and Audio Output.  
- Some of the [Audio_Tracks](./Audio) that are for non-commercial use.

## Game_Description
The game emulates a timed lap of a racetrack.  The game provides a fair bit of humour and activity with lots of effects, music and speech.  The game is always playing sound, with sets of audio tracks for idle, racing, adverts, crashes and fanfares.

To set the scene the base of the game had a laminated sheet with a venue guide to the racetrack.  A metal rod depicts the shape of the racetrack and in the original game the Snetterton Racetrack in Norfolk, England was chosen.  A toy racing car was fixed to the player's handle, which moves a metal ring along the racetrack, hopefully without bumping. 

The player's goal is to move the ring from one endpoint to the other to complete a lap as fast as possible.  However, if they start too soon or touch the rod, it incurs time penalties, beeps and crash sound effects.  The game is bidirectional with the start/finish points ending in a Startbox.  This has chequered flags and start sequence lights that culminate with 3 reds followed by a green that is kept on while the race is running.

The game has competing demands of speed and fine control to obtain a good lap time.  It tempts you to try again and beat your previous time, or take another try if someone else dethrones your fastest lap.

The game can be played quite fast because no matter how slow it's played there always seems to be crashes, each with a 3 second penalty that's potentially repeated every 0.5 seconds.  The race start sequence takes 7 seconds and a premature start is awarded a 10 second penalty too.  To stop a careless high speed lap from winning there's also a 1 minute penalty for "stock car racing", which is when the crash penalty time is greater than the playing time.

During a race messages are played based on the game time and number of crashes.  At the end of the race the game provides feedback and effects based on performance and it gives the adjusted lap time and, if fast enough, their leaderboard position.

There are help, race and leaderboard buttons and two volume controls, one for the buzz level and the other for the effects.

## Maker_Information
### Metalwork,_Woodwork_and_Plastic
The hollow base was made from 18 mm plywood, the 800 mm width made it marginally wider than the track and 450 mm depth made it stable.  The height was 90 mm to keep it fairly low but sufficient for the internals.  To ensure stability on uneven surfaces there were only 3 rubber feet, at the front corners and at the centre on the back.

The racetrack is a 3 metre long, 5 mm diameter, A2 stainless steel rod (5 mm was a nice diameter but 4 mm diameter would make cold bending easier and is probably sufficient).  The ends of the rod pass through a Startbox at 60 mm height, turn 90 downwards and pass through a cutout in the base. Underneath the base the rod is clamped in place against the side of an internal beam.  

At the top and bottom of the beam, A2 stainless steel plates measuring 3 x 20 x 80 mm have a central V bend to securely clamp the rod.  Each of these use two M6 x 80 mm fixing bolts through the beam.  The beam was 70 mm high, 45 mm deep and the length was a tight internal fit.  The edge of the beam with the clamping side was positioned at half the depth of the base.  The base was fixed with 2 screws from the outside of each of the base sides, the screws were covered with stickers after the base was varnished.

The handle was a 185 mm long, 6 mm diameter steel tube with a 3 mm diameter rod passed through.  One end of this rod was bent to make the ring around the racetrack.  A handle of a kitchen utensil was used to bend the ring with an internal diameter of 19.5 mm.  This seemed perfect for adults but a little too difficult for 12 year olds.  It's easiest to make a loop with spare rod past the ring and then cut the surplus off.  A short section of the tube was hammered flat near the ring in preparation to mount a plastic toy car with tie wraps. The 1st version of the handle worked quite well with the rod poking through the tube and being folded around a small bolt with a crimped lug for the electrical connection. The v2 handle removed the bulk where the bolt was but wasn't really much better.  This handle had 3 thick stranded wires from some mains cable that were twisted together and then brazed to the rod.  It provided strength and flexibility and an easy solder connection for the signal wire but properly cleaning the brazing flux requires some very nasty caustic soda.

The Startbox was a Hammond 1591XXGSBK (112 x 96 x 38 mm), which is a good size for the four 10mm LED mounts and two IP65 volume controls (Bourns 53CAD-E16-D15L and Kilo OEDA-50-4-6) above the racetrack rod.  The wires for the LEDs and volume controls exit through cutouts in the base of the Startbox, along with a cutout for both ends of the racetrack rod.

Self adhesive tie wraps kept the cables tidy inside the base and anything potentially removable used the plastic ladder style. The electronics area is meant to be rainproof so a compartment was made with a small strip of wood to act as a drip barrier.  Sealant along the drip barrier and beam prevents water running to the electronics.  Some old plastic gutter was cut to act as cable clamps and a cable protector. 

### Electrical
The racetrack rod has an electrical connection via a crimped lug on one of its fixing bolts.  The racetrack endpoints are formed by wrapping copper tape over heat shrink where the rod enters the Startbox.  If you haven't come across copper tape before it's used by gardeners to keep slugs off their plant pots.  Some stranded wire was soldered to the copper tape and the other end went to a connector for easy disassembly.  These 3 of racetrack connections are digital inputs on the MCU with 10k ohm pulldown resistors to 0V via an external resistor array.  They are potential human touch points, so they also have unidirectional TVS diodes to 0 V to protect against extreme static voltages.

The wire from the game handle crimped to a through-hole lug, with a bolt going through the lug, a wide washer and then the base.  Underneath there was another washer and lug, with its electrical connection taken to 5 V via a circuit board connector.

The power switch is mounted inside the base in the drip protection area at the rear corner, this prevents children playing with the switch and makes it easy to find by touch when raising the rear side.  The power switch is dual pole for the battery supply and for cell1 to monitor its voltaget.  Without switching cell1 the circuit would attempt to power up via the input protection diodes on the MCU's ADC port.

The game ran on two Li-ion cells, the Samsung INR18650-30Q with 3000 mAhr capacity and 2.5 V min cut-off.  Note that Li-ion cells often have a 3.0 V cut-off instead.  The cells were in series and powered the game via a 5 V very low drop-out regulator with protection.  Using 5 V helped to provide sufficient audio power and to drive the large LEDs reliably due to there high forward voltage.  The game lasts for over a day at low to medium volume, or about 10 hours at max volume. If either cell voltage is below 3,400 mV, about 18%, the game will speak warnings between idle tracks.  If a cell is nearly exhausted, reading below 3100 mV,  about 6%, the microcontroller issues a notice and goes to sleep.  These tests were performed at 22°C with "TestController" software taking logs from an East Tester ET5410A+ set at 200mA constant current, which is representative of the game being near maximum volume.

### Electronics
The circuit board used 2.7" by 5.4" of stripboard and all connectors were based on JST-XH clones with 2.54 mm spacing.  The PICAXE 20X2 was mounted in a socket whereas the audio player and audio amplifier daughter boards were soldered in placed for security.

In addition to TVS diodes protecting MCU inputs for the buzz wire and end points, there's a resistor to the MCU input and a capacitor to 0 V.  This helps to debounce inputs so the interrupt routine can read the changed input correctly and they provide some added voltage protection too.

The buzz wire rod is driven to 5 V if the handle touches and this signal drives a transistor switch to enable the buzz output.  The buzz sound is permanently generated from a MCU PWM output, which is mixed to the buzz output with another transistor.

A DF Player Mini module generates all the other sounds, including background music, effects and speech.  It's controlled by commands from the MCU sent over a serial link.  The MCU also watches a Busy Signal from the DF Player to determine when to play the next track.  Timers and interrupts will also send "Adverts" that temporarily pause playback with crash sound effects, or words of criticism and encouragement.  Some phrases in the game are pre-recorded while others are created by the MCU stringing together words, such as the player number and lap time, or battery voltage.

The DF Player includes a powerful speaker output but this project needed to mix the audio with buzz sounds, so a DAC output was taken instead.  This output and the switched buzz output were fed to volume controls and then mixed using the + and - inputs of an Adafruit PAM8302 2.5 W Class D mono amplifier module.  This board has a trimmer that can limit the maximum volume if required.

The MCU has 10 bit ADC rail to rail inputs that are used to monitor the battery and cell voltage.  The battery has a 50% resistor divider so the ADC voltage is always below the MCU supply voltage.

To provide good sunlight visibility the 10 mm red LEDs had to be driven hard at 16mA (I~Max~= 18 mA), whereas the green seemed to just exceed this brightness at 7 mA.  It was noticeable how the MCU output, rated for 25 mA sink or source (I~Max~= 50 mA), sagged with load.  With a 4.99V supply the logic output high, V~OH~ was 4.98V with no load; with the green LED load V~OH~=4.54V (V~f~=2.15V, I~f~=7mA, R~L~=330Ω); and for the red LEDs load V~OH~=3.61 (V~f~=2.03, I~f~=16mA ,R~L~=100Ω).  The three red LEDs are briefly on together and each causes an internal chip load of 22mW, which this is well below the chip specification of 250mA supply current and 800mW dissipation.


### Programming
The program is written in PICAXE BASIC that is organized into the following regions:
1. Program Notes
2. Compiler Directives
3. Resources
    1. Pins
    2.	Variables
    3.	Constants
    4.	Modules
4.	Initialisation
5.	Main:
6. Interrupt:
7. Subroutines

Four re-usable software modules were written for the game, with each containing detailed program notes for guidance:
1.	"Debugger.basinc" helps to display MCU status information.
1.	"Timing.basinc" sets the processor clock rate and provides timing functions regardless of the clock rate.
1.	"DF_Player_Mini.basinc" provides functions to easily control sound output from a DF Player Mini audio module.
1.	"Voltage.basinc" calculates the MCU supply voltage and ADC inputs in milivolts and can provide a rough assessment of Li-ion battery capacity.

The variable `GameStatus` tracks the operating mode and is set to 1 of 7 constants. `GAME_NOT_SET` means the handle is not at a valid start point, when the handle is correctly positioned the status becomes `GAME_WAITING`.

When the Race Button is pressed the status becomes `GAME_BEGINNING`, while the start sequence is played.  After the sequence, the status becomes `GAME_NOT_STARTED`.  When the handle is moved off the starting point the status becomes `GAME_PLAYING` and when it reaches the endpoint the status becomes `GAME_ENDING` during a sequence that gives player feedback, lap time and potential leaderboard position, if you're in the top 20.  After this the status returns to `GAME_WAITING`.

If the handle is moved off its start point without pressing the race button first, the GameStatus is made `GAME_PRACTISE`.   There's verbal confirmation of a practice that says there's no lap time given.

The MCU has a maximum of 5 software interrupts, which are used for the buzz wire, left and right endpoints, race button and the leaderboard button.  The help button input is picked up by the program loop, which is quite quick.

The interrupt setting is based on a variable that is adjusted according to the handle position, that could be an endpoint before the race starts, or floating when racing or practising.  The interrupt is then only triggered at a start or finish point, or a bump against the track.  When this happens the game status is read to determine the correct action.

The key activity in the program loop is to detect if music has ended, and if so, start the next track.  The tracks follow either a game playing background loop, or an idle loop when no race is underway.  

Another activity in the program loop is to issue adverts.  In idle mode these adverts play in a loop and occasionally interrupt music with encouraging informative or amusing messages. During game play the adverts critique player performance based on checking the game time against the expiration of 2 timer values and considering the number of crashes when they do.

In `GAME_WAITING` status a battery check is also performed before starting the next track.  If the battery is below about 20% a warning is spoken.  If the battery reaches 6% a final notice is spoken and the system goes into sleep mode, to help ensure the rechargeable battery doesn't go below its point of non-recovery.

Perhaps a reusable part of the program is the leaderboard, this subroutine implements a table with lap times and player numbers.  It determines the leaderboard position, or returns zero.  If the player achieved a ranking then that entry is inserted in the EEPROM with the lower rankings shifted down and out.

Interrupt handling is fairly "basic" with the PICAXE and it was implemented in a crude manner too.  Such as the race end triggering a gosub for the ending sequence. This wasn't possible for the start sequence because it needed to be interruptible if the handle was moved off its start point too soon.  The solution was for the race start to set `GameStatus` as `GAME_BEGINNING` and catch this in the main program loop to run `gosub GameBegin`, which is then interruptable.  If this subroutine completes the game status is changed to `GAME_NOT_STARTED`, but if the player starts too soon an interrupt occurs and a time penalty is spoken and logged.  Normally program execution returns to where it was after an interrupt, but in this case it would be part way through the start sequence.  To overcome this the interrupt for starting too soon sets all the normal race start conditions, adds a time penalty and finishes with a `run 0`.  The main program loop then operates as if a normal start had occured and continues playing race background music. 

Throughout the programming it was a joy, and often necessity, to see the game's activity in execution, which relied on typical debug usage of the `sertx`.  The use of `Debugger.basinc` made it more controllable and a little easier, but a very significant advantage of this approach was code readability, so I hope you find the same too.  The downside was program memory usage, so pruning was required as the program features grew.  The debug causes very small delays during its serial transmissions but these were not important for the game and it's nice to show others what the game is up to.

### Audio
All the audio editing was performed in NCH WavePad, which trimmed start and end silences, normalized volume levels, and where necessary changed pitch, speed or added cartoon effects.  WavePad also converted a  couple of tracks to mono because the left and right channels were far too different.

The speech was provided by https://ttsmp3.com/ and is free to use without restriction.  Mostly the AI voice "Alloy" was used and the mp3 filenames were given the numbering of 000 to 255 that the DF Player expects and a short description, which is either word, or paraphrased longer speech.  For some phrases, natural UK or USA voices from https://ttsmp3.com/ were used, most of these were slightly increased in speed to keep interest in the game and some had cartoon effects or changes in tone for comedy value.

The sound effects are from https://www.101soundboards.com, they are made available on a fair use policy where samples of less than 1% are provided from original copyrighted material, also personal uploads seem to waive rights too.  I waive personal liability by requesting you read and understand https://www.101soundboards.com/pages/about#about.  My use was personal and non-commercial.

It's fun to add some music tracks too, but you do that on your own discretion because they are not provided in this site.

### Graphics
The racetrack venue guide was recreated using Inkscape, which is popular free open source software for editing vector graphics.

The base of the game had various stickers with the Cars movie theme. These were children's wall stickers, which can be variable quality and too large, so pick carefully if you're using them.

## Suggested_Improvements
1. *Fuses* - There should really be fuses on the battery and the cell voltage tap!
2. *Compensate Performance* - The "stock car racing" penalty is there to prevent cheats racing the track without caring about crashes.  It works great for adults and teenagers, however, young children performed far worse than expected and this was disheartening for them.  The algorithm should avoid this penalty if the time is already slow, or the game adjust itself to the age group in some way.
3. *Racetrack Connector* - The racetrack endpoints should have an individual connector on the circuit board.  There was a 2 pin inline connector to make removal easier, for storage or swapping to alternate racetracks.  However, connectors take time to make and this inline connector adds a potential point of failure.
4. *Button Connectors* - Each button had an individual inline connector for ease of assembly and maintenance, these  were not worthwhile. Alternatively, a board connector for all buttons could be used.
5. *Battery Disconnection* - When a battery cell is exhausted the cells should be disconnected to prevent further discharge.  Currently, the MCU shuts down and the DF Player will go to sleep but the audio amp remains active.
6. *USB C Charging* - A great upgrade would be some battery charging circuitry and a waterproof USB C charging port.
7. *Single Cell Battery* - The two cell battery is quite efficient and will last longer than a single cell. Though the real reason for not choosing a boost SMPS was to save that step for a future project.  The battery will last long enough with a single cell, it would be cheaper and it would make charging easier too.
8. *More Audio Power* - For noisy external environments, the audio amp and speaker could be increased to 10W.  The charity event was on a very windy day and 3W was only just sufficient to entice people over, on there other hand the game is very loud indoors.
9. *More Powerful MCU* - I plan to use PICAXE chip for my next 2 projects because they are very easy and fun to use, including soldering through hole components.  The main issue with the PICAXE was lack of program memory because the program and modules were approaching 1,000 lines of code and debug consumed 459 bytes too.  The MCU couldn't support interrupt handling of the Help Button, 6th input, unless I were to add external electronics. Hardware interrupts would have been better and software handling of any interrupt type is limited.  The program's handling of the interrupts could be improved too by focusing on status changes and returning to the main program loop for processing, which could make the leaderboard button interruptible.  A long-term dream is to use printed circuit boards and move to Zig programming, via C, with more powerful MCUs (PICAXE BASIC is a joy to use though and it's tempting to stick with it and even use BASIC with GCBasic or B4R if ever needed). 
10. *Wood Glue Cleaning* - Take more care cleaning off any wood glue residue before varnishing.
11. *Visuals and Personalisation* - It would be nice to add a leaderboard screen and name inputs but this seems too over-the-top.

## License
Contents of this project are covered by different licenses. 

Each folder may contain licensing, shown in a LICENSE.md file, that is different from its parent. If a folder does not contain a LICENSE.md file, it inherits the license from its nearest ancestor folder where LICENSE.md is defined.

To summarise, this folder and the PICAXE BASIC software have the [MIT](https://choosealicense.com/licenses/mit/) License. Restrictions on the audio files is covered in the Audio section above. Most other materials have the [CERN OHL v2 Permissive](https://choosealicense.com/licenses/cern-ohl-p-2.0/) license.
