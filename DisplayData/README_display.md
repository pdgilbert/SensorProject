## Display Software Example

Subdirectory `DisplayData` contains code for an example of one way to display 
the sensor data. The example uses a Rhino model of the building and displays 
coloured dots representing temperature at the location of the sensors. 
The data is first arranged in a SQLite database, which might be useful for 
other analyis of the data, data cleaning, and sensor debugging.
Details of the database are as in [README](../README.md).

The ultimate output is the display of a graphic on a Rhino drawing.
The graphic gives a colour representation of temperature [and humitity]
from sensors at various locations in the Rhino drawing.
Time and location slices can be controlled by a Grasshopper program.

This requires the Rhino .3dm file with a representation of the building
(eg `garage_slabCHECK.3dm`).
The locations of the sensors will have been taken from this drawing 
using `extractSensorIDLocations.ghx` when building the database. 
It also requires the (SQLite) database of the 
sensors' temperatures  [and humidity] readings and associated times.

The Rhino display on the `.3dm` drawing is controlled by `sliders` in a
Grasshopper program (eg. 'garage_slab_sensor_Vis.ghx')
which uses a python script ('DisplayData/utils/extractReadingsSlice.py') 
to access the database.
The python script needs to be copy and pasted into the `.ghx` script
until I figure out something better.

##Details

See more details in [README_garage](../Garage/README_garage.md).

