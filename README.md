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
There are also programs for processing data and example programs for displaying it,
described in sections below.

 * [SensorProject_t16-pcb](https://github.com/pdgilbert/SensorProject_t16-pcb) has a Kicad 
design for a module with analog digital converters and connectors for
sixteen 10K NTC 3950 temperature sensors.

 * [`SensorProject_t16`](https://github.com/pdgilbert/SensorProject_t16) has Rust code for
the `SensorProject_t16-pcb` hardware.

 * [`multiplexI2C`](https://github.com/pdgilbert/multiplexI2C) has a Kicad design for a
module with I2C connections for eight (eg. AHT10) temperature and humidity sensors.

 * [`SensorProject_th8`](https://github.com/pdgilbert/SensorProject_th8) has  Rust code
for the `multiplexI2C` hardware.


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
These may only need to be done once, when the sensors are installed.
However, they will need to be done again if sensors are added or changed. 
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

In the `Garage` example there are 9 floor, 1 wall, and 1 roof profiles. CHECK

The sensors are each given a two letter ID (eg. `AB`) and their locations are recorded in
the (Rhino) construction drawings. The `Grasshopper` script `extractSensorIDLocations.ghx`
is used to extract senser locations from the Rhino 3dm file.
The script puts the location data in a file `sensorLocations.txt`.

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

See [README_BaseStation](./RecordData/README_BaseStation.md) for more details.


### Database

Data associated with sensors for a building is arranged in a subdirectory. 
The directory `Garage/` is the most developed example.

Files used to build the database are as follows:
- `SensorIdHash.txt` is manually edited for any new sensors installed.
- `ModuleIdHash.txt` is manually edited to add a description for any new module.
- `sensorLocations.txt` is extracted from the construction `.3dm` drawing 
     with Grasshopper script `extractSensorIDLocations.ghx`.
- `SensorRecordOuput*.txt` files are moved from basestation(s) to directory `raw_data/`. 

The process is as follows.
- The intermediate file of readings `tmp/All_data.txt` needs to be prepared by:
```
           cat raw_data/SensorRecordOuput*.txt >tmp/All_data.txt
```
      Or optionally run through `SensorDataFreqFilter` to reduce frequency, for example
```
           cat raw_data/SensorRecordOuput*.txt | \
               ../utils/SensorDataFreqFilter  120   >tmp/All_data.txt
```
      This reduces the number of readings so there is at least 120 minutes (2 hours)
      between readings for a module.
      (Beware that runTests will indicate differences because the test sample is changed.)

- The shell (bash) script `buildDB` uses these files and python programs in `utils/` to
build the database. In the directory corresponding to a building (eg `Garage`) run

```
   ../buildDB   tmp/All_data.txt  target/SensorReadings.db
```
This generates a (SQLite) database file `target/SensorReadings.db`
and runs some tests to check things have loaded properly.

The `buildDB` script does the following:

1/ The combined file is filter to remove some (obvious) faulty transmition recordings
     and module Id and J# are converted to a sensor ID.

2/ The resulting converted file is loaded into the target database (table `SensorData`).

3/ The sensor details (id, location, module id, module socket number) are loaded into 
     the target database (table `Sensors`) and the module descriptions are loaded into 
     the target database (table `Modules`).

4/ The script ./runTests is run to check the database.

See the `buildDB` script for syntax details. For working notes see [README_garage](./Garage/README_garage.md).


### Data Display

Currently, displaying the data requires Rhino 8, the building model file `Garage/slab_sensors.3dm`,
the Grasshopper script `Garage/slab_sensor_Vis.ghx` and python code 
`extractReadingsSlice.py` which must be loaded into the Grasshopper script.
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
