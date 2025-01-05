# Fairy Lights - Simple Experiment

This experiment records some findings about PICAXE output resistance and voltage drop with load.  It exists because of the fun in creating AC for LED strings without using the usual series resistor.  This goes against best practise of using a resistor or current limiter with LEDs and, as a word of caution, you have to prove sufficient LED forward voltage first!

In the experiment the PICAXE 08M2 managed to raise the current from 13mA to 20mA for a set of fairly dim ex-solar power lights.  The eventual project used the 08M2 to drive a L9110 H-Bridge with higher load though.  At 8MHz the 08M2 toggled 2 outputs at 114Hz and provided 140us deadbands to prevent shoot-through current on the H-Bridge.

For future reference, the Electronics Schematic provides a record of the circuit, the PICAXE output voltages and internal resistances at different load currents, plus some thoughts on the effects of LED failures.

Full details are contained in the:
- [Electronics_Schematic](./Electronics_Schematic) produced in KiCad v8.0.6.
- [Program](./Software/Fairy_Lights-Simple_Experiment.bas) written in PICAXE BASIC with the PICAXE Editor v6.2.0.0.

## License
Contents of this project are covered by the [MIT](https://choosealicense.com/licenses/mit/) License.  

![Electronics Schematic](./Pictures/Fairy_lights-Simple_Experiment.png)
