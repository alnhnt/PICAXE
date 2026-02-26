# Morse Code Sender

This program for a PICAXE 08M2 makes a very simple and handy little project to practise morse code listening/watching. It supports variable dit rate, Farnsworth timing and ProSigns, which are all useful in learning Morse Code.

The program evolved from a need to test the "Morse_Encoder.basinc" module and now it show cases the use of that module too. The module itself was initially created to encode hourly messages to fairy lights at Christmas time.

When the program starts it sends "HELLO WORLD". After that you can repeatedly type up to 20 characters of text in the PICAXE Editor's Terminal and send it to the chip, which will output the morse code.

The current settings produce a 600Hz tone, a keying dit rate of 20 Words Per Minute and overall Farnsworth rate of 10 WPM. Note, the dit rate may seem high but this is recommended to learn the sounds because counting dits and dahs is impossible at normal audio reception rates. Visual morse is much slower though.

## More Details

* The [Morse_Sender.bas](./Software/Morse_Sender.bas) file contains notes about the electrical connections and usage.
* The [Morse_Encoder.basinc](./Software/Morse_Encoder.basinc) file contains more information on its usage and morse encoding and timing. The highlights are that it can send using the macros MorseTxChar(Char); MorseTxEEPROM(Location); or MorseTxRAM(Location), where Location is the address of a null terminated string. The sending method is extensible in that the module tries to run MorseOn and MorseOff that you define in your program.

## Licence

Contents of this project are covered by different licences:

* The PICAXE BASIC software has the [MIT](https://choosealicense.com/licenses/mit/) Licence.
* All other materials have the [CERN OHL v2 Permissive](https://choosealicense.com/licenses/cern-ohl-p-2.0/) licence.
