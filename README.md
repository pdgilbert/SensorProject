
STATUS:  Draft in Progress

## Project Overview

Following is a short summary of several relate repositories intended for gathering sensor data.
My application is with temperature and humidity sensors in walls, roof, and floor of a house.
With small modifications the hardware and software might be usable in other settings.
THINGS DESCRIBED HERE ARE IN PROGRESS AND UNSTABLE.

This and the related repositories provide code and designs for PCB modules with temperature and humidity 
sensors (and possibly others in the future). 
The sensor modules transmit measurements by LoRa to a base station computer that can record results
and (optionally) connect to the Internet.

The repositories for the various pieces are as follows;

 * This repository (`SensorProject`) has (Python) code for a base station that receives and records data 
from sensor modules. A Raspberry Pi setup is described below.

 * [SensorProject_t16-pcb](https://github.com/pdgilbert/SensorProject_t16-pcb) has
a Kicad design for a module with analog digital converters 
and connectors for sixteen 10K NTC 3950 temperature sensors.

 * [`SensorProject_t16`](https://github.com/pdgilbert/SensorProject_t16) has 
Rust code for the `SensorProject_t16-pcb` hardware.

 * [`multiplexI2C`](https://github.com/pdgilbert/multiplexI2C) has
a Kicad design for a module with connectors for eight (eg. AHT10) temperature and humidity sensors.

 * [`SensorProject_th8`](https://github.com/pdgilbert/SensorProject_th8) has 
Rust code for the `multiplexI2C` hardware.


## Summary

The program `SensorRecord` is `python3` code which runs on the base station. 
It receives and records data from the sensor modules.

The base station could be any computer that runs python3 but it needs a LoRa module to receive information.
It can be run headless but ...

(An older project that has similar LoRa requirements is in repository `LoRaGPS`.) 

The program  `SensorDataReformat` is an example that takes recorded data and rearranges it for use in another program.
It can be run on any computer with python3. 

Data associated with a group of sensors, typically a building, is arranged in subdirectories. 
The directory `Garage/` is the most developed example.

These programs and example hardware are described more in sections below.

## Filtering and re-arranging recorded data

The `python3` code `SensorDataReformat` takes recorded data and rearranges it for use in other programs.
Most notably, it attaches the sensor identifier to data records. This id gives a way to map the data record to a location.

The file `ModuleIdHash.txt` gives more meaningful names (eg. "NE floor profile") to modules. It is not (yet) used in programs.
The file `SensorIdHash.txt` gives the map from a module identifier and connector to a sensor identifier.

## Recording software setup

`SensorRecord` is `python3` code for receiving and recording data from the sensor modules.
To run it with defaults:

```
 ./SensorRecord  --debug=True
```

(Compare project LoRaGPS)

WORK IN PROGRESS

`SensorRecord`  takes command line arguments to set the
frequency, bandwidth, coding rate, and spreading factor. Use the `--help` argument for
more details. There are trade offs among competing objectives: distance, data rate, 
data reliability, channel congestion, battery life ... . 
These are affected by the various settings.
The best is difficult to determined and will depend on the application. 
For more information, see for example:
[exploratory engineering](https://docs.exploratory.engineering/lora/dr_sf/)
and
[Mark Zachmann blog](https://medium.com/home-wireless/testing-lora-radios-with-the-limesdr-mini-part-2-37fa481217ff)


###  Raspberry Pi base station hardware and configation

The Raspberry Pi base station  described here has a no name RFM95 style LoRa 915 MHz module with solder 
points connected to Raspberry Pi header pins as follows.

RFM95 manual
https://cdn.sparkfun.com/assets/learn_tutorials/8/0/4/RFM95_96_97_98W.pdf

GPIO is aka "BCM" or "Broadcom". 

Worked with 
|  LoRa  |Pi pin| Pi BCM |                      Pi pins 
|:-------|:-----|:-------|                       used
|  DIO0  |   7  | BCM  4 |                            
|  DIO1  |  11  | BCM 17 |                       7
|  DIO2  |  12  | BCM 18 |                      
|  DIO3  |  13  | BCM 27 |                      11   12
|  REST  |  15  | BCM 22 |                      13
|  VCC   |  17  |  3v3   |                      15
|  MOSI  |  19  | BCM 10 |                      17   
|  MISO  |  21  | BCM  9 |                      19   
|  SCK   |  23  | BCM 11 |                      21   
|  NSS   |  24  | BCM  8 |                      23   24
|  GND   |  25  |  GND   |                      25  
                                       
                                      

Use these with RPi.GPIO and Pi Zero.
NSS (chip select) may need a 10k pull up resistor which can be soldered across the RFM95 board to vcc.
The  LoRa module DIO4, DIO5 are not used. 


|  LoRa  |Pi pin|   Pi GPIO spi0      |            Pi pins 
|:-------|:-----|:--------------------|             used
|  DIO0  |  29  |    GPIO 5           |   
|  REST  |  22  |   GPIO 25           |            17
|  VCC   |  17  |     3v3             |            19   20
|  MOSI  |  19  | spi0 MOSI (GPIO 10) |            21   22
|  MISO  |  21  | spi0 MISO (GPIO 9 ) |            23
|  SCK   |  23  | spi0 SCK  (GPIO 11) |            25   26
|  NSS   |  26  | spi0 CE1  (GPIO 7)  |            
|  GND   |  25  |     GND             |            29
|  GND   |  20  |     GND             |            




from pyLoraRFM9x import LoRa, ModemConfig

This is our callback function that runs when a message is received
def on_recv(payload):
    print("From:", payload.header_from)
    print("Received:", payload.message)
    print("RSSI: {}; SNR: {}".format(payload.rssi, payload.snr))

- Lora object will use spi port 0 and use chip select 1. 
- GPIO pin 5 will be used for interrupts and 
- set reset pin to 25
- The address of this device will be set to 2
lora = LoRa(0, 1, 5, 2, reset_pin = 25, modem_config=ModemConfig.Bw125Cr45Sf128, tx_power=14, acks=True)


LoRa(spi_channel, interrupt_pin, my_address, spi_port = 0, reset_pin=reset_pin, freq=915, tx_power=14,
      modem_config=ModemConfig.Bw125Cr45Sf128, acks=False, crypto=None)
lora = LoRa(1, 5, 0, reset_pin = 25, modem_config=ModemConfig.Bw125Cr45Sf128, tx_power=14, acks=True)


pip install pycrypto

LoRa(1, interrupt_pin, my_address, spi_port = 0, reset_pin=reset_pin, freq=915, tx_power=14,
      modem_config=ModemConfig.Bw125Cr45Sf128, acks=False, crypto=None)

NSS (chip select) may need a 10k pull up resistor which can be soldered across the board to vcc.

Remember to connect an antenna.

The  LoRa module DIO1, DIO2,  DIO3, DIO4, DIO5 are not used. 
Two additions GND solder points should be used but ... .
A shielded module would be better.

In places where something other than 915 MHz should be used then a different
module will be needed and be sure to check the command line arguments as the
defaults in the code will not be correct. 

CLEANUP, USING ONLY LITE

Download and burn an SD with Pi Os (formerly  Raspian) follow instructions at
https://www.raspberrypi.com/software/operating-systems/.  Rough summary:

With checksums in file checksums.sha256, eg lines
a73d68b618c3ca40190c1aa04005a4dafcf32bc861c36c0d1fc6ddc48a370b6e 2025-05-13-raspios-bookworm-armhf-lite.img.xz

run

```
sha256sum --check checksums.sha256
```
full, full+recommended software, lite?
```
xz --decompress 2025-05-13-raspios-bookworm-armhf-full.img.xz
xz --decompress 2025-05-13-raspios-bookworm-armhf.img.xz
xz --decompress 2025-05-13-raspios-bookworm-armhf-lite.img
```

Right click on the image file and choose Open with disk images writer. Select the SD card unit and press Start.
This may give a message that the image does not fill the SD. That is ok.
(Another option is dd but use with care!)

The first bootup 
   - resizes image to use full sd
   - prompts for keyboard layout (choices not complete)
   - prompts for user/passwd
   - sets up ssh keys host key
   - configures the network if attached
   - set clock but bad guess at time zone


sudo hostname basestationX
or
sudo hostnamectl set-hostname  basestationX
(Both return an error message about unable to resolve old name, but work.)

Set up ssh service if you want to run headless. 
   systemctl status ssh
   systemctl start ssh     # should be able to ssh from remote to basestation now
   systemctl eneable ssh   # ssh service will start at boot
 
(I first did ssh from basestation to the remote, which added  .ssd/known_hosts but
 I don't think this is necessary.)  TEST

Ensure that SPI is enabled 
   ls -l /dev/spidev*
If it reports "No such file or directory"  then
   sudo raspi-config
and  Interface Options > SPI > enable




### Recording software setup using RFM95 radio

Python3, used for programming the base station software, is already available on the image.
The essential additional points are that it needs [ CHECK python3-dev,] and 
python modules RPi.GPIO, spidev, :

See also instructins here 
https://pypi.org/project/pyLoraRFM9x/  by epeters
https://github.com/epeters13/pyLoraRFM9x


Note (I think) pipx can be used if SensorRecord is only going to be run (not developed).
Next show virtual environment for development.

https://stackoverflow.com/questions/75608323/how-do-i-solve-error-externally-managed-environment-every-time-i-use-pip-3

   sudo apt install python3-venv   ( may be alraedy installed)
Create a virtual environment (in a project directory):
   python3 -m venv MyPython3.venv   # can be a bit slow. Be patient.

Activate the virtual environment:

   source MyPython3.venv/bin/activate
which modifies PATH to include MyPython3.venv/bin/
  [ when done   source MyPython3.venv/bin/deactivate

pip install pyLoraRFM9x
or
pip install --upgrade pyLoraRFM9x   # lgpio and spidev will be installed as requirements

[Alternately skip  activate and run pip and python directly from 
  the virtual environment:

   $ MyPython3.venv/bin/pip install pkg
   $ MyPython3.venv/bin/python
   >>> import pkg
]


##################################################################################

pre shift to "managed environment" for python

sudo apt install python3-pip  # installs needed requirements including python3-dev
pip install --upgrade pyLoraRFM9x   # lgpio and spidev will be installed as requirements


##################################################################################
FOLLOWING ARE NOTE ON ATTEMPT TO UPDATE OLD pySX127x BASED CODE, 
AND NOTES FROM WORKING OLD CODE  pySX127x form rpsreal.
https://github.com/mayeranalytics/pySX127x
https://github.com/rpsreal/pySX127x

DELETE BELOW WHEN pyLoraRFM9x WORKS

```
 [sudo apt-get update  # likely needed ]
  sudo apt install python3-dev python3-RPi.GPIO python3-spidev

 [ some variation on this should also work:
  sudo apt install python3-pip  # installs needed requirements including python3-dev
  pip3 install RPi.GPIO
  pip3 install spidev 
 ]

NOT  pip3 install Pyserial

  sudo apt install git 
  PYTHON 2.7? AND DIFFERENT DEFAULT PINS?  
  git clone   https://github.com/mayeranalytics/pySX127x # this compiles on mqtt0, but not on basestationB
    ./test_lora.py gives FAIL...   ./lora_util.py gives SLEEP ...
  git clone https://github.com/rpsreal/pySX127x          # this works on mqtt0 but has not been update recently

```

Depending on the install location put something like
```
   export PYTHONPATH=$(HOME)/pySX127x/
```
in .bashrc

possibly it will be necessary to
```
  sudo apt autoremove
  sudo apt update
  sudo apt upgrade
```
  
and probably it will be necessary to reboot occasionally above and in the next.

As of August 2025 base station testing is with a Raspberry Pi 3B v1.2 running  CHECK and UPDATE
Raspian 8 (jessie), but has also been occasionally tested on a Raspberry Pi 
Zero W running Raspian 10 (Buster Lite).

It has a no name RFM95 style LoRa 915 MHz SX1276 module with a small 915MHz spring antenna soldered in
place and solder connections with pins as above. 

In locations where something other than 915 MHz should be used be sure to
check the settings in the code before running. 

Follow the normal instructions to download and burn an SD with Raspian.
Set up sshd if you want to run headless. 

The essential additional points are that it needs Python 3, python3-dev, and python 
modules RPi.GPIO,  spidev, and pySX127x:
```
  sudo apt install python3-dev python3-pip
  pip3 install RPi.GPIO   
  pip3 install spidev 
  sudo apt install git 
  git clone https://github.com/rpsreal/pySX127x # or another source
```
(SOME OF THE ABOVE MAY NOT BE NEEDED.






Depending on the install location put something like
```
   export PYTHONPATH=/home/pi/pySX127x/:/home/pi/LoRaGPS/lib
```
in .bashrc

Install LoRaGPS_base and run it
```
  python3 LoRaGPS_base
```

On a Raspberry Pi that may require setting up
iptables to allow the python code to open the port. See the 'Install a firewall' section of
https://www.raspberrypi.org/documentation/configuration/security.md. 
The whole document is good reading if the base station is to be connected to the Internet 
or publicly accessible.
```
sudo apt install ufw
sudo ufw allow 22/tcp      # for ssh if running headless
sudo ufw allow 65433/udp   # The default port used by LoRaGPS_base
sudo ufw status
sudo ufw enable             # legacy command may not be needed?
sudo systemctl start ufw    # starts the service 
sudo systemctl enable ufw   # starts the service on boot
sudo systemctl status ufw
cat /etc/ufw/ufw.conf
sudo ufw logging medium
sudo ufw show listening
```


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
