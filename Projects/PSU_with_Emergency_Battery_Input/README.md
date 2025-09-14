# Power Supply with Emergency Battery Input
*Author: Alan Hunt, Date: 2025-09-14, 
License: [CERN OHL v2 Permissive](https://choosealicense.com/licenses/cern-ohl-p-2.0/)*

The project's documentation includes notes on some tools and techniques for electronics dual power supplying, stripboarding, box labelling, simple voltage monitoring with an LED, and current control of LEDs. So, hands up and apologies, it doesn't include a PICAXE but I thought it would have some relevance here. If it sends someone to sleep on a bedtime read, I'll consider it worthwhile.

The project demonstrates how the power supply for a device was replaced, so that an emergency battery input was included.

The device being powered was a Tigo CCA, providing solar panel optimisation, and requiring 12V to 24V. The project principles can be adapted to other devices; perhaps with an always on buck-boost converter and moving the feedback protection diodes to the inputs instead of outputs, so that the lower PICAXE supply voltages are supported.

## Contents
This project includes:	
- [PDF Documentation](./Documents/Tigo_PSU.pdf) and its source file in LibreOffice Writer 25.2.
- [Electronics Schematic](./Electronics_Schematic/Screenshot.jpg) and source files in  KiCad 9.0.
- [Circuit Board Layout](./Circuit_Board/Top.jpg) based on stripboard and source file in VeroRoute v2.39.
- [Physical Design](./Documents/Physical_Design.pdf) and source file in LibreOffice Draw 25.2.
- [Pictures](./Pictures)
