## Base Station Summary

Code for the base station is in the subdirectory `BaseStation`.
The program `SensorRecord` is `python3` code which runs on a base station. 
It receives and records data from the sensor modules. 
The current version simply listens on a LoRa channel and records any transmissions received.
There is no attempt at acknowledgment, filtering for faulty or unexpected transmissions, or encryption.
This approach is useful for debugging transmitters but does mean the data needs to be 
post-processed to be useful for its intended purpose.

The base station could be any computer that runs python3 but it needs a LoRa module to 
receive information. It can be run headless but a monitor is very useful for initial setup.
(An older project that has similar LoRa requirements is in repository `LoRaGPS`.) 


### Recording software setup

`SensorRecord` is `python3` code for receiving and recording data from the sensor modules.
It can be run with defaults, or argument values can be specified:

```
 ./SensorRecord
 ./SensorRecord --filename='SensorRecordOuput.txt'  --debug=True
```

`SensorRecord`  also takes command line arguments to set the
frequency channel, bandwidth, coding rate, and spreading factor. Use the `--help` argument for
more details. There are trade-offs among competing objectives: distance, data rate, 
data reliability, channel congestion, battery life ... . 
These are affected by the various settings.
The best is difficult to determined and will depend on the application and distances involved. 
For more information, see for example:
[exploratory engineering](https://docs.exploratory.engineering/lora/dr_sf/)
and
[Mark Zachmann blog](https://medium.com/home-wireless/testing-lora-radios-with-the-limesdr-mini-part-2-37fa481217ff)

There is also a bash script `startSensorRecord` which is especially useful for 
starting from a cron job.

##  Example Configuration of a Base Station using Raspberry Pi

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
LLCC68 seems to be "stripped down" sx126x.

Pin settings for the RFM95W to Raspberry Pi are as follows:
| RFM95 sx1276|   LLCC68    |   Raspberry Pi          |
| pin|  label | pin| label  | pin | label (GPIO=BCM)  |       
|:---|:------:|:---|:------:|:---:|:-----------------:|       
| 14 |  DIO0  |  x |  DIO0  |   7 |     GPIO  4       |       
| 15 |  DIO1  | 15 |  DIO1  |  11 |     GPIO 17       |       
|  x |  DIO2  |  x |  DIO2  |  12 |     GPIO 18       |       
|  x |  DIO3  | 11 |  DIO3  |  13 |     GPIO 27       |       
|  6 |  REST  |  6 |  REST  |  15 |     GPIO 22       |       
| 13 |  VCC   | 13 |  VCC   |  17 |      3v3          |       
|  3 |  MOSI  |  3 |  MOSI  |  19 | spi0 MOSI GPIO 10 |       
|  2 |  MISO  |  2 |  MISO  |  21 | spi0 MISO GPIO  9 |       
|  4 |  SCK   |  4 |  SCK   |  23 | spi0 SCK  GPIO 11 |       
|  5 | NSS/CS |  5 | NSS/CS |  24 | spi0 CE0  GPIO  8 |       
|  1 |  GND   |  1 |  GND   |  25 |     GND           |       
|  8 |  GND   |  8 |  GND   |  20 |     GND           |        
| 10 | ANT GND| 10 |  GND   |  14 |     GND           |     
|  x |   x    | 16 |  BUSY  |  16 |     GPIO 23       |       
                      
Raspberry Pi 3B, 2B, and Zero W all have the same pinouts.  See for example
https://www.etechnophiles.com/raspberry-pi-3-gpio-pinout-pin-diagram-and-specs-in-detail-model-b/
or https://pinout.xyz/

### Install Base Station Software

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

Instructions here were tested with 
- `2025-12-04-raspios-trixie-armhf-lite.img.xz` Raspberry Pi OS Lite 32 bit Release date 2025-12-04
- `2026-04-21-raspios-trixie-armhf-lite.img.xz` 
- '2026-04-21-raspios-trixie-arm64-lite.img.xz` Raspberry Pi OS Lite 64 bit

Instructions below indicate `2025-12-04-raspios-trixie-armhf-lite.img.xz`. Obvious changes need for others.

Downloaded file `2025-12-04-raspios-trixie-armhf-lite.img.xz` 
and add the checksum from download site in file `checksums.sha256` add a line
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

[Note that boot and reboot may take awhile to send output so the monitor may go
to sleep and need reset.]

Set the time zone in 
```
   sudo raspi-config  # Localization Options > Timezone
```
and the wifi country
```
   sudo raspi-config  # Localization Options > WLAN country
```

The wired network connects automatically. 
[Note, if wifi is to be used for a hotspot (further below) it is best not to configure it for LAN. ]
To connect to LAN with wifi
```
   sudo raspi-config  # System Options > Wireless LAN
```
This brings up wlan0 and connects to SSID but will fail looking for ssid if no wifi LAN is available.
(Some details for wireless are skipped here. )

Note that wifi on Pi demands additional power. Be sure to use a power suppy
with adequate power or the wifi will be unstable.

Either the wired or wifi will connect the RPi to a LAN,  permiting logon from another computer on the LAN.

The system can be run without an internet connection, but part of the below install does
require a connection to the internet.

In the event there is not LAN available, the RPi can be set up as a hotspot to provide the LAN. 
That is described further below.

Set up ssh service if you want to run headless or remotely. 
```
   systemctl status ssh
   sudo systemctl start ssh     # should be able to ssh from remote to basestation now
   sudo systemctl enable ssh    # ssh service will start at boot
```
 
Optionally, remote login can now be used to do the remainder.

Possibly change the base station name:

```
sudo raspi-config  # System Options> hostname > #Preferred, also changes /etc/hosts.
#or
sudo hostname basestationX
#or
sudo hostnamectl set-hostname  basestationX   # does not change /etc/hosts
#or
```
The hostname needs to be updated in /etc/hosts file.
If not, edit it, eg sudo nano /etc/hosts,
otherwise there are error messages about `unable to resolve host`. 

The new name does not appear as the prompt until a new terminal is started.)



Ensure that SPI is enabled for the LoRa module
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
[may need sudo apt-get update ]
sudo apt install python-dev-is-python3 # has headers to build with pip install .. 

python3 -m venv  LoRaVenv
source LoRaVenv/bin/activate  #deactivate when done

pip install spidev lgpio rpi-lgpio

# install /pySX127x from git repo. This provides package pyLoRa.
# It has support for Semtech SX1276/7/8/9 radios. 
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
This implies that any git managed code should **not** be in the venv subdirectory.
Consider adding to the git repo a copy of `requirements.txt` generated by
`pip freeze > requirements.txt`


### Running `SensorRecord` 

The defaults in the code will not be correct in geographic locations where 
something other than 915 MHz should be used for LoRa transmitions. 
Be sure to check the command line arguments for options.
(A different RFM95 LoRa module will also be needed.)

Copy `SensorRecord` and `startSensorRecord` from this repository and check that they have execute permission.
If you already have them on a local computer they can be copied. From a session on the RPi do

```
scp userID@somewhere:SensorRecord   SensorRecord
scp userID@somewhere:startSensorRecord   startSensorRecord
```
or on the local computer, assuming the RPi address is 10.42.0.1, do
```
scp SensorRecord pi@10.42.0.1:SensorRecord  
scp startSensorRecord pi@10.42.0.1:startSensorRecord  
```   
Make sure the virtual environment is activated and start the program with defaults:
```
source LoRaVenv/bin/activate  #deactivate when done
./SensorRecord  --debug=True
```
Received messages are recorded in file `SensorRecordOuput.txt` by default. 
The `--debug=True` argument causes messages to also be printed on the terminal.
The `--help` argument displays argument options.

The bash script `startSensorRecord` will (re)start `SensorRecord` with an output
file named 'SensorRecordOuput_<hostname>_<YYYY-MM>.txt'.
The file is opened in append mode so previous data is not lost.
The script stores the process `PID' in the file 'SensorRecord.PID' and
uses the `PID' to stop a running process before restarting.
(Note that the script assumes the python virtual env is activate 
by `source LoRaVenv/bin/activate`.)

This script is especially useful in a cron job. For example, edit the
crontab file ('crontab -e') and add
```
   @reboot   ~/startSensorRecord
   @monthly  ~/startSensorRecord
```
This will automatically start the process when the system is booted, and also
restart it at the beginning of each month.

#### RPi Hotspot

Default Raspberry Pi OS wireless setup is to connect the Pi to an access point and the Internet.
That is generally straightforward (if your RPi's wifi hardware is recognized).
Described here are steps to set the RPi up as an access point (hotspot) so remote login by wifi
can be used to collect the `SensorRecord` saved data even when a LAN is not available.

To set up, login to the RPi with monitor and keyboard or remotely using the wired ethernet.
The wifi is being configured, so do not login on that.

Following assumes the wifi was previously activated. If not, `sudo raspi-config  # System Options > Wireless LAN`. 
If the wifi automatically connects to a SSID on boot then it will need to be turned off.
```
     sudo ifconfig wlan0 down  # This does nothing if it is not needed 
```
These information commands are all helpful for understanding the status.
```
    ifconfig              # to check status. Should not show wlan0
    iwconfig              # Should show wlan0  IEEE 802.11  ESSID:off/any  Mode:Managed  
                          #    Access Point: Not-Associated   
                          #    Retry short limit:7   RTS thr:off   Fragment thr:off
                          #    Power Management:on
    nmcli dev wifi list   # If wifi LAN is up (which it should not be) this show any SSID in reach.
```

REVISE
   
Just
    nmcli dev wifi hotspot
will generate a password and start a hotspot with SSID Hotspot-<YOUR_HOSTNAME> on the default wifi interface.

https://raspberrytips.com/nmcli-linux-command/
nmcli connection show
nmcli dev status
nmcli dev show wlan0

nmcli connection add type <connection_type> ifname <interface> con-name <connection_name>
  where connection_type is ethernet or wifi 
        ifname is eg eth0, wlan0
        connection_name is name to give the connection
nmcli device connect <device>
nmcli device disconnect <device>
eg  nmcli device connect eth0

https://raspberrytips.com/access-point-setup-raspberry-pi/
sudo nmcli con add con-name hotspot ifname wlan0 type wifi ssid "basestation"
sudo nmcli con modify hotspot wifi-sec.key-mgmt wpa-psk
sudo nmcli con modify hotspot 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
sudo nmcli con modify hotspot wifi-sec.psk "MySecret"  #works on 64-bit OS but not 32-bit.
sudo nmcli con up hotspot

On 32-bit  sudo nmcli device wifi hotspot ssid  basestation  password MySecret 

[ Above may give "...activation failed...too long to authenticate" on 
  Pi 3B so need to disable PMF(which has security implications on 
  untrusted network):
    sudo nmcli con modify hotspot 802-11-wireless-security.pmf 1
    sudo nmcli con up hotspot
]

nmcli dev wifi show-password



To start up wifi do 
   sudo nmcli device wifi hotspot ssid  <whatever>  password <MySecret>
   nmcli dev wifi show-password

[ This may give "...activation failed...too long to authenticate" on 
  Pi 3B so need to disable PMF, which has security implications on 
  untrusted network, do
    sudo nmcli con modify Hotspot 802-11-wireless-security.pmf 1
    sudo nmcli con up Hotspot

    sudo ifconfig eth0 down
]

ifconfig
iwconfig
nmcli dev wifi list
sudo more '/etc/NetworkManager/system-connections/Auto basestationLT.nmconnection'

   sudo nmcli device wifi hotspot ssid  basestation  password xxx

Process to start an AP should be three commands

nmcli connection add type wifi ifname wlan0 con-name local-ap autoconnect yes ssid test-ap mode ap
nmcli connection add type wifi ifname wlan0 con-name Hotspot  local-ap autoconnect yes ssid basestation mode ap

nmcli connection modify con-name 802-11-wireless.mode ap 802-11-wireless-security.key-mgmt wpa-psk ipv4.method shared 802-11-wireless-security.psk 'PASSWORD'
nmcli connection up con-name

To verify:
nmcli dev wifi list

   nmcli dev wifi show-password
   
try alternate?  
sudo nmcli con add con-name hotspot ifname wlan0 type wifi ssid "basestationLT"
sudo nmcli con modify hotspot wifi-sec.key-mgmt wpa-psk
sudo nmcli con modify hotspot wifi-sec.psk "whatever"
sudo nmcli con modify hotspot 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared

On the RPi make a note of its wifi LAN address.
Now, from a remote computer, connect to the basestation hotspot and  `ssh pi@10.42.0.1` 


### Retrieving Data 

- Connect to wifi hotspot basestation. [`ifconfig` to check network is `10.42.0.x` ]

- `scp pi@10.42.0.1:SensorRecordOutput*  raw_data/`
    [respond to prompt for password.]

- Check/set date
```
   ssh  pi@10.42.0.1
   date     # to check
   sudo date  -s '2026-06-19 13:30:00'   # to set
```

- Occassionally remove old files for space on the basestation
 ```
   ssh  pi@10.42.0.1
   rm  whatever
 ```
 
#################################
