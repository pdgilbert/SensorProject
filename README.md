Status:  Things described here are work in progress and subject to change.
         The main parts are working but need improvement in several aspects.
         Some reorganization is necessary and documentation needs work.
         All sensors have not yet been connected properly. 
         Data is available for testing code but needs filtering to be
         used for the actual intended purposes.

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
records data from sensor modules. A Raspberry Pi base station setup is described below. 
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


## Data Flow Overview

The main data flow is sensor data passes from sensors to a transmitting module, then to
a recording basestation. From there it is passed to a computer that puts the data into
a `SQL` database. It is then extracted from the database to display in the building model
(`Grasshopper`/`Rhino`). It can also be processed directly on the database with `SQL` 
for some purposes such as cleaning and filtering. 

Transmition and basestation recording happens frequently, currently set at 10 minutes.
Other transfers happen on an "as needed" basis. Currently data is transferred from the
basestation roughly monthly. Both timings reflect the development status and could change
substantialy..

There are two secondary data flows to establish the sensor configuration. 
These may only need to be done once, when the sensors are all installed.
They will need to be done again if sensors are added or changed. 
The first is the sensor IDs corresponding to modules/sockets must be added to the database.
The second is that sensor locations from the construction drawings are added to the database.

[The sensor locations are mainly of interest for display in the construction drawings,
so it might be possible to omit them from the database and do the necessary translations
in Grasshopper. However, it seems simpler to add them to the database and do more
display processing in python/SQL rather than Grasshopper. Also, it is useful to have
locations in SQL do do some sensor checks and data cleaning.]

Unless otherwise indicated, files mentioned here are in a directory corresponding to
a building with the sensors installed (eg `Garage`). Some file names are passed as
program arguments and can be easily changed.

Temperature and humidity measurements are given by sensors embedded in the building 
floor, walls, and roof. A group of sensors connects into sockets in a module which fits
in a light switch sized hole in the wall. The module broadcasts the measured
values for each socket along with the socket number and module ID. 
The group of sensors attached to a module are sometimes referred to as a *profile*.
In the current hardware the temperature and humidity modules have sockets for up to 
8 sensors, and the temperature only modules have sockets for up to 16 sensors.
(Temperature only sensors are waterproof and thus can be embedded in concrete, 
while humidity sensors cannot be waterproof.)

In the `Garage` example there are 9 floor, 1 wall, and 1 roof profiles.

The sensors are each given a two letter ID (eg. `AB`) and their locations are recorded in
the (Rhino) construction drawings. The `Grasshopper` script `extractSensorIDLocations.ghx`
is used to extract senser locations from the Rhino 3dm file.
The script puts the location data in a file `sensorLocations.txt`.
Note that the sensor locations are relative to an origin set in the 3dm file,
An attempt to display data in another drawing would require accommodating this.

Which sensors are in which module sockets must be recorded when the modules are installed.
This is kept in the file `SensorIdHash.txt`

The broadcasts from the modules are received and recorded into a file on the basestation(s)
with a time stamp indicating when they were received. Two basestations provides redunancy.
The time interval between broadcasts is still under consideration. For development purposes
it has been set at 10 minutes. This is considerably shorter than is needed generally for 
tracing heat flow in a building, although there can be occassional events where that
frequency may be interesting. The file on the basestation has default 
name `SensorRecordOuput.txt`. It may occasionally be necessary to restart the recording 
program and my current convention is to rename `SensorRecordOuput.txt`, adding a number
so the previous data is not erased by the new recording. (A better solution will happen 
eventually.) These recording files need to occassionally be moved from the basestation(s) to
another computer for processing and display. This has been done by USB transfer or by `scp`..

The sensor measurement data `SensorRecordOuput.txt` is converted by the script 
`RecordData/SensorDataReformat` to have sensor IDs rather than module IDs 
and socket numbers. This is put in a csv file.
THIS SHOULD PROBABLY BE ALL DONE IN SQL.
See [README_record](./RecordData/README_record.md) for more detail.


The sensor measurement data and the sensor locations are combined into a (SQLite) database.
This is done with python scripts ...

Measurement data is displayed in Rhino using the building 3dm and the `Grasshopper` script
`DisplayData/utils/garage_slab_sensor_Vis.ghx`
IF THIS IS GENERIC THEN RENAME IT, IF NOT, MOVE IT.
The `Grasshopper` script calls a python script `extractSensorReadingsSliceSQLite.py`
which makes SQL calls to the SQLite database.

See [README_display](./DisplayData/README_display.md) for more detail

## Base Station Summary
See [README_record](./RecordData/README_record.md)



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
