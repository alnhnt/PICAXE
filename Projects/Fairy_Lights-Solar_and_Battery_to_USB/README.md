# Fairy Lights - Outdoor Solar to USB

This project converted a set of outdoor solar powered fairly lights to an indoor USB powered set with increased brightness.  The circuit is also compatible with some battery powered lights that drive their LEDs with about 2.7V AC too.

The original circuitry turned on with darkness and provided fading and flashing sequences, which can be distracting indoors.  To keep things simple this design provides a steady light that's much brighter and relies on manually switching off the USB charger that provides the power supply.

## Contents

This file contains:

* [Pre-conversion\_Details](./README.md#Pre-conversion_Details)
* [Design](./README.md#Design)
* [License](./README.md#License)

Other key files include:

* [Electronics\_Schematic](./Pictures/FairlyLights_SolarToUSB_7Schematic.jpg), produced in KiCad v8.0.6.
* [Circuit\_Board\_Layout](./Pictures/FairlyLights_SolarToUSB_8Board.png), based on stripboard and produced in VeroRoute v2.39 from the KiCad netlist.
* [Program](./Software/Fairy_Lights-Solar_to_USB.bas) written in PICAXE BASIC with the PICAXE Editor v6.2.0.0.

Sub-folders contain pictures and source files.

## Pre-conversion\_Details

The original system contained a Ni-MH AA 1.2V 600mAh battery and the circuit drew 40 mA when active. The controller box included a small solar panel for self-charging, a button to set flashing modes and a power button.

The LEDs were quite dim and needed to be much brighter, especially for indoor use. All 50 LEDs were wired in parallel, with blue and green operating in 1 polarity, and yellow and red operating in the other. This configuration runs the risk of too much load on specific LEDs if forward voltages are different.

The controller fed the LED string with 2.7V AC at 9.8kHz, the forward and reverse currents were +13.6mA and -12.4mA, but with short spikes of 400 mA.

## Design

An old USB charger was upcycled as a 5V power supply and it’s certainly better on the wallet and environment than using batteries.

Using a programmable PICAXE 08M2 lowered the component count and allowed the opportunity to play with BASIC.

The 08M2 created an AC supply for the LEDs by using 2 output pins to provide alternating and opposite high and lows at 115 Hz. At this reduced frequency there is less wasted energy in the capacitive load and there is still no visible flicker. The outputs were boosted by feeding them to a L9110 H-Bridge. The drive current for the LED string was upgraded to +36 mA and -35 mA. This is limited by a 33 ohm series resistor, the LED forward voltage and the voltage drop on the L9110 outputs.

The original 13 mA for the LEDs provided a puny amount of light, so the 36mA was a substantial upgrade. It easily competed with indoor lighting and a seemed a reasonable limit to avoid damaging the LEDs. There’s some hope here that too much load does not fall on any single LED, they are wired in parallel and seem to have similar brightness.

With the PICAXE operating at 8MHz clock, toggling the output pins programmatically provided 140us deadbands for the H-Bridge that avoided shoot-through current. During on-times there were pause commands to keep each phase active for about 49% of the cycle. Doing anything more programmatically with the PICAXE could affect the toggling rate and cause flicker on the LEDs.

A potentiometer controlled the brightness of the LEDs, but the household thought brighter the better, so it was completely superfluous. The current control was via a transistor and if doing the circuit again I’d just connect the H-Bridge positive supply directly to the 5V rail, which boosts the output to 45mA unless the 33 ohm resistor is replaced with a higher value.

There are further notes in the program, and in the electronics schematic there are some circuit measurements too.

## Licence

Contents of this project are covered by different licences:

* The PICAXE BASIC software has the [MIT](https://choosealicense.com/licenses/mit/) Licence.
* All other materials have the [CERN OHL v2 Permissive](https://choosealicense.com/licenses/cern-ohl-p-2.0/) licence.
