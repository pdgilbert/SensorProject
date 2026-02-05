## Display Software Example

Subdirectory `DisplayData` contains code for an example of one way to display the sensor data.
The example uses a Rhino model of the building and displays coloured dots representing
temperature at the location of the sensors. 
The data is first arranged in a SQLite database, which might be useful for other analyis of the data. More details coming ... .
##Summary

###Output
The ultimate output is the display of a graphic on a Rhino drawing.
The graphic gives a colour representation of temperature [and humitity]
from sensors at various locations as indicated in the Rhino drawing.
This requires the Rhino .3dm file with a representation of the building
and locations of the sensors. It also requires a database of the sensors'
temperatures  [and humidity] readings and associated times.

The important intermediate file is the (SQLite) database file. 
This is used by a Grasshopper program ('extractSensorIDLocations.ghx')
which uses a python script ('extractSensorReadingsSliceSQLite.py')
to access the database.

###Inputs
- Temperature bubbles are viewed in Rhino drawing using Grasshopper program
      'extractSensorIDLocations.ghx' which uses python 
      script 'extractSensorReadingsSliceSQLite.py' to get data 
      from `SensorReadings.db`.

##Details

See more details in [Garage notes.](./Garage/Notes.txt)

