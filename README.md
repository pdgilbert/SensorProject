Status:  Things described here are work in progress and subject to change.
         The main parts are working but need improvement in several aspects.
         Documentation needs work.
         All sensors have not yet been connected properly. 
         Data is available for testing code but needs filtering to be
         used for the actual intended purposes.

## Project Overview

Following is a short summary of several relate repositories intended for gathering sensor data. 
My application is with temperature and humidity sensors in walls, roof, and floor of a house. 
With modifications the hardware and software might be usable in other settings.

This and the related repositories provide code and designs for printed circuit board modules 
with temperature and humidity sensors. (Others possible in the future.) 
The sensor modules transmit measurements by LoRa to a base station computer that can record 
results and (optionally) connect to the Internet.

The repositories for the various pieces are as follows;

 * This repository (`SensorProject`) has (Python) code for a base station that receives and 
records data from sensor modules. A Raspberry Pi base station setup is described. 
There are also programs for processing data and example programs for displaying it
described in sections below.

 * [`garageTest`](https://github.com/pdgilbert/garageTest) has a simplified subset of the 
essential files for displaying sensor data in a Rhino model and gives details to do that.
The purpose is to illustrate one approach to data display and to explore the file organization.

 * [SensorProject_t16-pcb](https://github.com/pdgilbert/SensorProject_t16-pcb) has a Kicad 
design for a pcb module with analog digital converters and connectors for
sixteen 10K NTC 3950 temperature sensors.

 * [`SensorProject_t16`](https://github.com/pdgilbert/SensorProject_t16) has Rust code for
the `SensorProject_t16-pcb` hardware.

 * [`multiplexI2C`](https://github.com/pdgilbert/multiplexI2C) has a Kicad design for a
pcb module with I2C connections for eight (eg. AHT10) temperature and humidity sensors.

 * [`SensorProject_th8`](https://github.com/pdgilbert/SensorProject_th8) has  Rust code
for the `multiplexI2C` hardware.

 * [`sensor_module_mount`](https://github.com/pdgilbert/sensor_module_mount) has FreeCAD/python code
for a simple 3D printed mount design to put the pcb modules in a light switch (NA) sized wall openning.

 * [`LoRa-Pi-hat`](https://github.com/pdgilbert/LoRa-Pi-hat) has a Kicad design for a
pcb module to fit on a Raspberry Pi and add a Lora chip with antenna, etc.


## Data Flow 

Unless otherwise indicated, files mentioned here are in a directory corresponding to
the building in which sensors are installed (eg `Garage`). Some file names are passed as
program arguments and can be easily changed.

### Overview

The main data flow is sensor data passes from sensors to a transmitting module, then to
a recording base station. From there it is passed to a computer that puts the data into
a `SQL` database. It is then extracted from the database to display in the building model
(`Grasshopper`/`Rhino`). It can also be processed directly on the database with `SQL` 
for some purposes such as cleaning and filtering. 

Transmission and base station recording happens frequently, currently set at 10 minutes.
Other transfers happen on an "as needed" basis. Currently data is transferred from the
base station roughly monthly. Both timings reflect the development status and could change
substantially.

There are two important secondary data flows to establish the sensor configuration. 
In theory these only need to be done once, when the sensors are installed.
However, they will need to be done again if sensors are added or changed,
so in practice they are included in the database build process. 
The first is that the sensor IDs corresponding to modules/sockets must be added to the database.
The second is that sensor locations from the construction drawings are added to the database.

There is another data flow that is less important and currently unused. A description
of the transmitting module profiles is kept in a file and added to the database.

[The sensor locations are of interest for display in the construction like drawings.
It might be possible to omit them from the database and do the necessary translations
in Grasshopper. However, it is simpler to add them to the database and do more
display processing in python/SQL rather than Grasshopper. Also, it is useful to have the
locations in SQL to do some sensor checks and data cleaning. Note also, this helps 
separate the convenience of recording the location in the construction drawings from the
display process which might be done with different software. However, beware that the 
sensor locations are relative to an origin set in the construction drawing 3dm file.
An attempt to display data in another drawing would require accommodating this.
]

### Sensors Modules and Basestation

Temperature and humidity measurements are given by sensors embedded in the building 
floor, walls, and roof. A group of sensors connects into sockets in a module which fits
in a light switch sized hole in the wall. The module broadcasts the measured
values for each socket along with the socket number and module ID. 
The group of sensors attached to a module are sometimes referred to as a *profile*.
In the current hardware the temperature and humidity modules 
(https://github.com/pdgilbert/multiplexI2C#summary) have sockets for up to 8 sensors, and
the temperature only modules (https://github.com/pdgilbert/SensorProject_t16-pcb#summary)
have sockets for up to 16 sensors.
(Temperature only sensors are waterproof and thus can be embedded in concrete, 
while humidity sensors cannot be waterproof.)

In the `Garage` example there are 9 floor, 2 wall, and 1 roof profiles.

The sensors are each given a two letter ID (eg. `AB`) and their locations are recorded in
the (Rhino) construction drawings. The python program `extract3dmSensorLocations`
is used to extract senser locations from the Rhino 3dm file. Previously the`Grasshopper`
script `extractSensorIDLocations.ghx`was used but that requires a working version of `Rhino`
and `Grasshopper`.
The script puts the location data in a file `intermidiate/sensorLocations.txt`
which is used to construct the database.

The correspondance between sensor ID and module ID/socket# needs to be recorded
when the modules are installed. This is kept by manually editing file `SensorIdHash.txt`.

The transmitting modules (profile) description is kept in the file `ModuleIdHash.txt`.

The broadcasts from the modules are received, a time stamp added, and they are recorded
into a file on the basestation(s). Two basestations provides redundancy.
The time interval between broadcasts is still under consideration. For development purposes
it has been set at 10 minutes. This is considerably shorter than is needed generally for 
tracing heat flow in a building, although there can be occasional events where that
frequency may be interesting. The file on the basestation has default 
name `SensorRecordOuput.txt`. It may sometimes be necessary to restart the recording 
program and my current convention is to rename `SensorRecordOuput.txt`, adding a number
so the previous data is not erased by the new recording. (A better solution will happen 
eventually.) These recording files need to be moved from the basestation(s) to another
computer for processing and display. This has been done by USB transfer or by `scp`.

See [README_BaseStation](./BaseStation/README_BaseStation.md) for more details.


### Database

Data associated with sensors for a building are arranged in a subdirectory. 
The directory `Garage/` is the most developed example.

Files used to build the database are as follows:
- If new sensor data files are being used, the `SensorRecordOuput*.txt` 
  files need to be moved from basestation(s) to directory `raw_data/`. 
- File `SensorIdHash.txt` is manually edited for any new sensors.
- File `ModuleIdHash.txt` is manually edited to add a description for any new module.
- The sensor locations were manually recorded in the (Rhino) `.3dm` file from construction notes,
  for example, `garage_sensors.3dm`. The locations can be extracted from the `.3dm` by python 
  program `extract3dmSensorLocations` and written to a `.txt` file, 
  for example, `intermediate/sensorLocations.txt`. 
  If there are any changes to modules or sensors then the file `intermediate/sensorLocations.txt`
  needs to be updated. Details are described in the program file `utils/extract3dmSensorLocations`.
 
The above files should be checked in preparation for building the database.

The process to building the database is described in detail in the script `utils//buildDB`,
summarized as follows:

0/ Change into the directory of the building, for example

1/ Whenever there is new data the `.txt` file of all sensor data readings must be prepared. 
For example
```
           cat raw_data/SensorRecordOutput*.txt >intermediate/All_data.txt
```
Other options and  details are described in comments in the script `utils//buildDB`.


2/ The file of sensor locations needs to be prepared 
as described in  `utils/buildDB`,
This file only changes if hardware in the building is changed.


3/ The shell (bash) script `utils/buildDB` uses these files and python programs
in `utils/` to build the (SQLite) database file. It does the following:

- The sensor readings from the `.txt` file are loaded into the database table `SensorData`.
- The sensor details (id, location, module id, module socket number) are loaded into 
  the database table `Sensors`.
- The module descriptions are loaded into 
  the database table `Modules`.

See the `../utils/buildDB` script for more details.

4/ Finally, run some tests to check things have loaded properly.

Note that the `../utils/buildDB` script is generic to all buildings but tests are
specific to a building.

For working notes see [README_garage](./Garage/README_garage.md).


### Data Display

Currently, displaying the data requires Rhino 8, the building model file `Garage/slab_sensors.3dm`,
the `Grasshopper` script `Garage/slab_sensor_Vis.ghx` and `python` code 
`extractReadingsSlice.py` which must be loaded into the `Grasshopper` script.
More detail is described in [README_display](./DisplayData/README_display.md).


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
