#  python3 <tests/test1.py             >tmp/test1_out.txt
#  diff     tests/test1_out.txt_result  tmp/test1_out.txt

dbName = "SensorReadings_2026-01-19.db"
print("database: ", dbName)

import sqlite3
from datetime import datetime, timedelta # library and a module are both called datetime

fmt = '%Y-%m-%d %H:%M:%S'

sliceStart ='2026-01-03 00:12:00'
sliceMinutes = 120
sliceSeconds = 0

SliceStart  = datetime.strptime(sliceStart, fmt)
SliceEnd = SliceStart + timedelta(days=0, hours=0, minutes=sliceMinutes, seconds=sliceSeconds)

print("SliceStart: ", SliceStart)
print("SliceEnd:   ", SliceEnd)

con = sqlite3.connect(dbName)

st = "(timeStamp > '" +SliceStart.strftime(fmt) + "')"
en = "(timeStamp < '" +   SliceEnd.strftime(fmt) + "')"

q = "SELECT sensorData.id, timeStamp, temperature, x, y, z FROM sensorData INNER JOIN \
    sensorLocation ON sensorData.id = sensorLocation.id  WHERE " + st + " AND " +  en 
    
zz = con.execute(q).fetchall()
print("records returned ", len(zz))

timeStamp   = [ v[1]  for v in zz ]
temperature = [ v[2]  for v in zz ]
x = [ v[3]  for v in zz ]
y = [ v[4]  for v in zz ]
z = [ v[5]  for v in zz ]

IDtemperature = [ [v[0],v[2]]  for v in zz ]

minTemp = min(temperature)
maxTemp = max(temperature)
print("temperature range", minTemp, " to ", maxTemp)

print("min x ", min(x), "max x ", max(x))
print("min y ", min(y), "max y ", max(y))
print("min z ", min(z), "max z ", max(z))

con.close() 
