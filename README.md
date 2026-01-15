Status:  Things described here are work in progress and subject to change.

## Project Overview

Following is a short summary of several relate repositories intended for gathering sensor data. 
My application is with temperature and humidity sensors in walls, roof, and floor of a house. 
With small modifications the hardware and software might be usable in other settings.

This and the related repositories provide code and designs for printed circuit board modules 
with temperature and humidity sensors. (Others possible in the future.) 
The sensor modules transmit measurements by LoRa to a base station computer that can record 
results and (optionally) connect to the Internet.

The repositories for the various pieces are as follows;

 * This repository (`SensorProject`) has (Python) code for a base station that receives and 
records data from sensor modules. A Raspberry Pi setup is described below. 
It also has some programs for processing data.

 * [SensorProject_t16-pcb](https://github.com/pdgilbert/SensorProject_t16-pcb) has a Kicad 
design for a module with analog digital converters and connectors for
sixteen 10K NTC 3950 temperature sensors.

 * [`SensorProject_t16`](https://github.com/pdgilbert/SensorProject_t16) has Rust code for
the `SensorProject_t16-pcb` hardware.

 * [`multiplexI2C`](https://github.com/pdgilbert/multiplexI2C) has a Kicad design for a
module with I2C connections for eight (eg. AHT10) temperature and humidity sensors.

 * [`SensorProject_th8`](https://github.com/pdgilbert/SensorProject_th8) has  Rust code
for the `multiplexI2C` hardware.


## Base Station Summary

The program `SensorRecord` is `python3` code which runs on a base station. 
It receives and records data from the sensor modules. 
The current version simply listens on a LoRa channel and records any transmissions received.
There is no attempt at acknowledgment, filtering for faulty or unexpected transmissions, or encryption.
This approach is useful for debugging transmitters but does mean the data needs to be 
post-processed to be useful for its intended purpose.

The base station could be any computer that runs python3 but it needs a LoRa module to 
receive information. It can be run headless but a monitor is very useful for initial setup.
(An older project that has similar LoRa requirements is in repository `LoRaGPS`.) 

The program  `SensorDataReformat` is an example that filters the recorded data and rearranges
it for use in another program. It can be run on any computer with python3. 

Data associated with a group of sensors, typically a building, is arranged in subdirectories. 
The directory `Garage/` is the most developed example.

These programs and example hardware are described more in sections below.

## Filtering and re-arranging recorded data

The `python3` code `SensorDataReformat` takes recorded data and rearranges it for use in other programs.
Most notably, it attaches the sensor identifier to data records.
This id gives a way to map a data record to a location.

The file `ModuleIdHash.txt` gives more meaningful names (eg. "NE floor profile") to modules.
It is not (yet) used in programs.
The file `SensorIdHash.txt` gives the map from a module identifier and connector to a sensor identifier.

## Recording software setup

`SensorRecord` is `python3` code for receiving and recording data from the sensor modules.
To run it with default argument values:

```
 ./SensorRecord  --debug=True
```

`SensorRecord`  takes command line arguments to set the
frequency, bandwidth, coding rate, and spreading factor. Use the `--help` argument for
more details. There are trade-offs among competing objectives: distance, data rate, 
data reliability, channel congestion, battery life ... . 
These are affected by the various settings.
The best is difficult to determined and will depend on the application and distances involved. 
For more information, see for example:
[exploratory engineering](https://docs.exploratory.engineering/lora/dr_sf/)
and
[Mark Zachmann blog](https://medium.com/home-wireless/testing-lora-radios-with-the-limesdr-mini-part-2-37fa481217ff)


##  Example Configation of a Base Station using Raspberry Pi

###  Hardware

The Raspberry Pi base station  described here has a RFM95 style LoRa 915 MHz module with its solder 
pads connected to Raspberry Pi header pins as below.
Be sure to connect an antenna to the radio module. (The radio can be damaged if there is no antenna.)
Beware that on some radio modules NSS (chip select) may need a 10k pull up resistor. 
This can be soldered across the RFM95 board to vcc.

GPIO is also known as "BCM" or "Broadcom". GPIO is mostly used below.
Re GPIO see Raspberry Pi reference
https://pip.raspberrypi.com/categories/685-whitepapers-app-notes-compliance-guides/documents/RP-006553-WP/A-history-of-GPIO-usage-on-Raspberry-Pi-devices-and-current-best-practices.pdf

The LoRa radio board HopeRF RFM95 has a Semteck SX1276 chip.
The manual/datasheet is at https://cdn.sparkfun.com/assets/learn_tutorials/8/0/4/RFM95_96_97_98W.pdf
Re DIO see "pinouts" and p40-41.

A shielded module like G-NiceRF LoRa1276-C1-915 is probably better but I have not tested.

Pin settings for the RFM95W to Raspberry Pi are as follows:

|  RFM95 |Pi pin|   Pi GPIO=BCM     |       
|:------:|:----:|:-----------------:|       
|  DIO0  |   7  |     GPIO  4       |       
|  DIO1  |  11  |     GPIO 17       |       
|  DIO2  |  12  |     GPIO 18       |       
|  DIO3  |  13  |     GPIO 27       |       
|  REST  |  15  |     GPIO 22       |       
|  VCC   |  17  |      3v3          |       
|  MOSI  |  19  | spi0 MOSI GPIO 10 |       
|  MISO  |  21  | spi0 MISO GPIO  9 |       
|  SCK   |  23  | spi0 SCK  GPIO 11 |       
| NSS/CS |  24  | spi0 CE0  GPIO  8 |       
|  GND   |  25  |     GND           |       
|  GND   |  20  |     GND           |        
|  GND   |  14  |     GND           |        
                      
Raspberry Pi 3B, 2B, and Zero W all have the same pinouts.  See for example
https://www.etechnophiles.com/raspberry-pi-3-gpio-pinout-pin-diagram-and-specs-in-detail-model-b/
or https://pinout.xyz/

### Install Software

#### Background

Below describes a successful test in December 2025 to run the `SensorRecord` program with 
old hardware and an old package (`pySX127x`from https://github.com/rpsreal/pySX127x) 
to interface to the RFM95W. It uses a new version
of Raspian (now called Raspebery Pi OS) and a new version of Python. I briefly explored some
newer packages. For the needs of `SensorRecord` there does not yet appear to be anything better
that works with RFM95W/SX1276 and is reasonably well documented. 
Also, all suffer from the two main problems using `pySX127x` with a new Python and OS. 

First, Python virtual environments are now highly recommended and the recipies for using them
seem not yet widely tested and explained. Some packages need linking to compiled `C` code, and 
finding everything needed can be frustating.

Second, with the release of the R Pi 5, Raspberry changed the mechanism for accesssing GPIO pins. 
They also changed Raspberry Pi OS to use the new mechanism. This means that even older Pi's
need to deal with the change to run the new OS.
Raspberry's preferred new `gpiozero` library requires lots of re-coding and is not (yet) widely used.
The `pySX127x` package and many others use the `RPi.GPIO` module, the `rpi-gpio` version of 
which no longer works with Raspebery Pi OS. 
The package `rpi-lgpio` replaces `rpi-gpio` and installs a different `RPi.GPIO` module.
Further discussion of this is at https://rpi-lgpio.readthedocs.io/en/release-0.4/install.html,  forums.raspberrypi.com/viewtopic.php?p=2160578#p2160578, and elsewhere.
See also https://github.com/ConceptualSystems/lgpio and https://github.com/joan2937/lg.

So, the simple solution used below is the `lrpi-lgpio` library (Dave Jones (waveform80) python 
bindings tojoan2937's C library). This installs an RPi.GPIO replacement.

Instruction below have been tested and work on 
  - Raspberry Pi 3 model B v1.2 
  - Raspberry Pi 2 model B v1.1 
  - Raspberry Pi Zero W v1.1 
(Yes I had to brush dust off them.)
This has been tested to work with 2025-12-04-raspios-trixie-armhf-lite.img (Raspbian 1:6.12.47-1+rpt1).


#### Install Raspberry Pi OS

Download and burn an SD with Pi Os (formerly  Raspian) follow instructions at
https://www.raspberrypi.com/software/operating-systems/.  Rough summary:

Instructions here were tested with Raspberry Pi OS Lite 32 bit Release date 4 Dec 2025
(Raspbian 1:6.12.47-1+rpt1). This is a 32 bit version of the OS.

Downloaded file `2025-12-04-raspios-trixie-armhf-lite.img.xz` 
and in file `checksums.sha256` add a line
1b3e49b67b15050a9f20a60267c145e6d468dc9559dd9cd945130a11401a49ff 2025-12-04-raspios-trixie-armhf-lite.img.xz

Check the checksum:
```
sha256sum --check checksums.sha256
```
then (this may take a minute to complete)
```
xz --decompress 2025-12-04-raspios-trixie-armhf-lite.img.xz
```

Right click on the image file and choose Open with disk images writer (in linux).
Select the SD card unit and press Start. (I tested with a 16GB SD card.)
The writer may give a message that the image does not fill the SD. That is ok.

Put the SD card in R Pi, attach to network (if you want that configured), and power up.

The first bootup 
   - resizes image to use the full sd (So may take 5 minutes to boot.
     If longer, make sure the image you have is appropriate for the Pi model you have.
   - prompts for keyboard layout (more choices with "other")
   - prompts for user/passwd,  eg pi/whatever
   - sets up ssh keys host key
   - configures the wired network if attached
   - sets clock but may make bad guess at time zone

The wired network connects automatically. For wifi
```
   sudo raspi-config  # System Options > Wireless LAN
```
(Some details for wireless are skipped here. )

Set up ssh service if you want to run headless or remotely. 
```
   systemctl status ssh
   sudo systemctl start ssh     # should be able to ssh from remote to basestation now
   sudo systemctl enable ssh    # ssh service will start at boot
```
 
Optionally, remote login can now be used to do the remainder.

Possibly change the base station name:

```
sudo hostname basestationX   # or whatever
#or
sudo hostnamectl set-hostname  basestationX   # (this does not change /etc/hosts)
#or
sudo raspi-config  # ...> change hostname >   # (this changes /etc/hosts too)
```
The old hostname should also be replace with the new in /etc/hosts file too, eg sudo nano /etc/hosts,
otherwise there are error messages about `unable to resolve host`. 

The new name does not appear as the prompt until a new terminal is started.)



Ensure that SPI is enabled for the RFM95 LoRa module
```
   ls -l /dev/spidev*
```
If it reports "No such file or directory"  then
```
   sudo raspi-config
```
and  Interface Options > SPI > enable

```
ls -l /dev/spidev*  #should show 2 devices (may require reboot)
```

#### Install Python Virtual environment and Packages

```
sudo apt install git
sudo apt install python3-setuptools swig python3-lgpio  liblgpio-dev
sudo apt install python-dev-is-python3 # has headers to build with pip install .. 

python3 -m venv  LoRaVenv
source LoRaVenv/bin/activate  #deactivate when done

pip install spidev lgpio rpi-lgpio

# install /pySX127x from git repo
git clone https://github.com/rpsreal/pySX127x
cd pySX127x
pip install .  # uses setup.py
cd

pip list   # lists package installed in the virtual environment
```
gives
```
Package   Version
--------- -------
lgpio     0.2.2.0
pip       25.1.1
pyLoRa    0.3.1
rpi-lgpio 0.6
spidev    3.8
```

#### git considerations

The venv (LoRaVenv) can be added to .gitignore. 
This implies that any git managed code should **not** be the venv subdirectory.
Consider adding to the git repo a copy of `requirements.txt` generated by
pip freeze > requirements.txt


### Running `SensorRecord` 

The defaults in the code will not be correct in geographic locations where 
something other than 915 MHz should be used for LoRa transmitions. 
Be sure to check the command line arguments for options.
(A different RFM95 LoRa module will also be needed.)

Copy the `SensorRecord` program from this repository and check that the file has execute permission.
If you already have it on a local computer it can be copied with

```
scp userID@somewhere:SensorRecord   SensorRecord
```   
Make sure the virtual environment is activated and start the program with defaults:
```
source LoRaVenv/bin/activate  #deactivate when done
./SensorRecord  --debug=True
```
Received messages are recorded in file `SensorRecordOuput.txt` by default. 
The `--debug=True` argument causes messages to also be printed on the terminal.
The `--help` argument displays argument options.

## License

Licensed under either of

 * Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or
   http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license ([LICENSE-MIT](LICENSE-MIT) or
   http://opensource.org/licenses/MIT)

at your option.

## Contributing

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall
be dual licensed as above, without any additional terms or conditions.
