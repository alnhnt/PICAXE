# Fairy Lights - Low Voltage with RTC and GPS

This project uses a NEO-M8N GPS module to automatically gain an accurate time for a PICAXE 20X2. The 20X2 also uses a MCP7940N RTC (Real Time Clock) to keep the time and set alarms. The RTC alarm state asserts a digital output that the 20X2 uses as a hardware interrupt to wake from Sleep and Doze modes and control fairy lights. Library modules created for the GPS and RTC parts are intended to support future use of these components.

The project builds on the [Outdoor Solar to USB](https://github.com/alnhnt/PICAXE/tree/main/Fairy_Lights-Solar_and_Battery_to_USB) project and now four strings of lights are powered by the single L9110 H-Bridge. A decorative DC powered lamppost is also switched by a MOSFET. The power supply is taken from an old 19V PC brick, with its DC jack replaced with a more standard 5.5/2.1mm sized jack. A DC buck converter serves the MCU, GPS, RTC and H-Bridge with a 5V supply; and a DC boost converter supplies the lamp circuit with 23V. The power rails to the GPS and boost converter are also switched to remove their standby load.

## Contents
This file contains:	
- [Pre-conversion_Details](./README.md#Pre-conversion_Details)
- [Design](./README.md#Design)
- [License](./README.md#License)

Other key files include:
- [Electronics_Schematic](./Pictures/FairyLights_RTCandGPS_5Schematic.png), produced in KiCad v8.0.6.
- [Circuit_Board_Layout](./Pictures/FairyLights_RTCandGPS_6Board_Topside.png), based on stripboard and produced in VeroRoute v2.39 from the KiCad netlist.
- [Program](./Software/Fairy_Lights-Battery_to_Mains_GPS_RTC.bas) written in PICAXE BASIC with the PICAXE Editor v6.2.0.0.

Sub-folders contain pictures and source files.

## Pre-conversion_Details
One set of 50 lights were solar powered and similar to the “Outdoor Solar to USB” project, but they operated at 148 Hz with +2.8 V @ 19 mA and -2.66V @ 17.8 mA.

Another set of 100 lights had been powered by 3 AA batteries and operated at 493 Hz with +2.68V @ 26.8 mA and -2.64 V @ 26.4 mA.

Another two sets of 100 lights had been powered by 3 AA batteries and operated at 14.8 kHz with +2.84V @ 37.6 mA and -2.56 V @ 36.0 mA, however, the supply was only active for 28% of the time in each direction. There must have been a high capacitive wasted load at this frequency too.

The lamppost was very bright and consisted of 120 lights with a supply of 21.64V DC @ 148 mA. It made the place look like Narnia!

## Design
The PICAXE 20X2 with its default 8MHz clock rate provided: HWPM (Hardware based Pulse Wave Modulation) to generate signals for a H-Bridge to power the lights; a UART interface for the GPS board; an I2C interface for the RTC; and a couple of digital outputs to control power to the GPS and a DC Boost converter.

The HPWM was used in half bridge mode with a small deadband of 10us to prevent shoot-through current on the L9110 H-Bridge. The 20X2 PWM clock divider is limited to PWMDIV16 and the lowest achievable frequency of 488Hz was used. Using HPWM meant the H-Bridge would drive the lights when the PICAXE was operating in a lower power Doze period between the lights going on and off. The H-Bridge supply was 5V and its output had 4 sets of lights connected in parallel, with each set of lights having a 33 ohm series resistor. Compared to the original circuits, the brightness of each set was approximately doubled with each phase being about 40mA and 50% active.

The GPS UART interface is only 9,800kbps but the PICAXE high speed serial interface was still used to allow reads to occur in the background with data written to Scratch Pad RAM.

The RTC I2C relied on PICAXE internal weak pull-ups for the clock and data lines. At 1 stage there were issues with the breadboard prototype so perhaps typical external pull-up resistors would be safest instead. The MCP7940N chip needs an external crystal with load capacitance of 6pf to 9pf, which is less common but just as cheap from an electronics retailer. The RTC was programmed with alarms that asserted a pin high, and this was used by the PICAXE as a hardware interrupt. The PICAXE makes a daily GPS time update for the RTC, driven by an alarm. If it’s a valid day for the lights to be on, the next alarm is the lights on time, and the alarm after that is the off time. In the inactive periods, the PICAXE enters the low power Sleep mode.

The GPS consumed about 50mA when active, and even with the receiver disabled the load only dropped to 15mA. The DC boost converter was also drawing 7 milliamps when the lamppost lighting was not in use. To prevent unnecessary power drain, PICAXE outputs drove MOSFETs to control the power to these components. The lamppost supply also contains a current limiter circuit using discrete components. It’s important not to set its DC Boost converter to more than 27V to prevent the current limiter MOSFET from being overloaded.

A couple of 10 pin headers surrounded the PICAXE because these connection points are useful for programming, monitoring and debugging. A VeroRoute circuit board diagram was flipped and scaled to match the underside of the circuit board and when taped in placed this helped to place the hole cutter for the stripboard. Perhaps toner transfer can be tried on the top of the board too, which would help align components to the right holes when soldering!

The project was housed in an outdoor waterproof box. An inner box housed the circuit board and flying leads came out of this box to be presented as inline JST connectors to the fairy lights and a DC jack for power. The lamppost had a 3 pin JST connector to distinguish it from the other fairy lights with only 2 pins.

There are further notes in the program and the electronics schematic.  

## License
Contents of this project are covered by different licenses:

- The PICAXE BASIC software has the [MIT](https://choosealicense.com/licenses/mit/) License.  
- All other materials have the [CERN OHL v2 Permissive](https://choosealicense.com/licenses/cern-ohl-p-2.0/) license.
