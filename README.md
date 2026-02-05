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
There are also for programs processing data and example programs for displaying it,
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
They will need to be done again if sensors are added or changed. 
The first is that the sensor IDs corresponding to modules/sockets must be added to the database.
The second is that sensor locations from the construction drawings are added to the database.

There is a third data flow that is less important and currently unused. A description
of the location of the transmitting modules kept in a file and added to the database.

[The sensor locations are of interest for display in the construction like drawings.
It might be possible to omit them from the database and do the necessary translations
in Grasshopper. However, it is simpler to add them to the database and do more
display processing in python/SQL rather than Grasshopper. Also, it is useful to have
locations in SQL to do some sensor checks and data cleaning. Note also, this helps 
separate the convenience of recording the location in the construction drawings from the
display process which might be done with different software. However, beware that the 
sensor locations are relative to an origin set in the 3dm file.
An attempt to display data in another drawing would require accommodating this.
]

### Sensors Modules and Basestation

Temperature and humidity measurements are given by sensors embedded in the building 
floor, walls, and roof. A group of sensors connects into sockets in a module which fits
in a light switch sized hole in the wall. The module broadcasts the measured
values for each socket along with the socket number and module ID. 
The group of sensors attached to a module are sometimes referred to as a *profile*.
In the current hardware the temperature and humidity modules have sockets for up to 
8 sensors, and the temperature only modules have sockets for up to 16 sensors.
(Temperature only sensors are waterproof and thus can be embedded in concrete, 
while humidity sensors cannot be waterproof.)

In the `Garage` example there are 9 floor, 1 wall, and 1 roof profiles. CHECK

The sensors are each given a two letter ID (eg. `AB`) and their locations are recorded in
the (Rhino) construction drawings. The `Grasshopper` script `extractSensorIDLocations.ghx`
is used to extract senser locations from the Rhino 3dm file.
The script puts the location data in a file `sensorLocations.txt`.

The correspondance between sensor ID and module ID/socket# needs to be recorded
when the modules are installed. This is kept in the file `SensorIdHash.txt`.

The transmitting modules (profile) description is kept in the file `ModuleIdHash.txt`.

The broadcasts from the modules are received and recorded into a file on the basestation(s)
with a time stamp indicating when they were received. Two basestations provides redundancy.
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

Data associated with a group of sensors, typically a building, is arranged a subdirectory. 
The directory `Garage/` is the most developed example.

The program  `SensorDataReformat` in directory `utils/` filters the recorded data and
rearranges it to add to the database. It can be run on any computer with python3. 

The sensor measurement data `SensorRecordOuput.txt` is converted by `SensorDataReformat`
to have sensor IDs rather than module IDs and socket numbers. 
The result is put in  file `SensorRecordOuput.csv` to be loaded into the database.
(The sensor IDs, module IDs and socket numbers are all added to the database,
so the conversion could alternately be done in SQL.)

The sensor measurement data and the sensor locations are combined into a (SQLite) database.
This is done with python scripts ...

The file `SensorIdHash.txt` gives the map from a module identifier and connector to a sensor identifier.

The file `ModuleIdHash.txt` gives more meaningful names (eg. "NE floor profile") to modules.
It is not (yet) used in programs.


###Process Summary

- `SensorIdHash.txt` is manually edited based on which sensor is plugged 
      into which module and socket.
- `SensorRecordOuput*.txt` files are generated by python program `SensorRecord`
      running on base station(s). These need to be transferred from the base station
      for processing. The are put in the directory raw_data.
- `All_data.txt` is made from multiple recorded file. (See example.)
- `All_data.csv` is made from `All_data.txt` and `SensorIdHash.txt` by python 
      program `SensorDataReformat` in the `utils` directory.
- 'sensorLocations.txt' is generated from Rhino drawing with Grasshopper
     program detailed in 'extractSensorIDLocations.ghx'
- `SensorReadings.db` is generated from files `All_data.csv`, 'sensorLocations.txt'
     and `SensorIdHash.txt` using python programs `loadReadings` and `loadSensors`.

For an example see [README_garage](./Garage/README_garage.md).


### Data Display

Measurement data is displayed in Rhino using the building 3dm and the `Grasshopper` script
`DisplayData/utils/garage_slab_sensor_Vis.ghx`
IF THIS IS GENERIC THEN RENAME IT, IF NOT, MOVE IT.
The `Grasshopper` script calls a python script `extractSensorReadingsSliceSQLite.py`
which makes SQL calls to the SQLite database.

See [README_display](./DisplayData/README_display.md) for more detail



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
