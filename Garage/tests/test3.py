#  python3 <tests/test3.py             >tmp/test3_out.txt
#  diff     tests/test3_out.txt_result  tmp/test3_out.txt

dbName = "SensorReadings_2026-01-19.db"
print("database: ", dbName)

import sqlite3
from datetime import datetime, timedelta # library and a module are both called datetime

fmt = '%Y-%m-%d %H:%M:%S'

# slice gives 953 values with SensorReadings_2026-01-19.db 
# sliceStart ='2026-01-03 00:12:00'
# SliceStart  = datetime.strptime(sliceStart, fmt)
sliceStartYear  = 2026
sliceStartMonth = 1
sliceStartDay   = 3
sliceStartHour   =  0
sliceStartMinute = 12
sliceStartSecond =  0

SliceStart  = datetime(year=sliceStartYear, month=sliceStartMonth, day=sliceStartDay,
                hour=sliceStartHour, minute=sliceStartMinute, second=sliceStartSecond )

sliceMinutes = 57
sliceSeconds = 19

SliceEnd = SliceStart + timedelta(days=0, hours=0, minutes=sliceMinutes, seconds=sliceSeconds)

print("SliceStart: ", SliceStart)
print("SliceEnd:   ", SliceEnd)

con = sqlite3.connect(dbName)

st = "(timeStamp > '" +SliceStart.strftime(fmt) + "')"
en = "(timeStamp < '" +   SliceEnd.strftime(fmt) + "')"

q = "SELECT sensorData.id, timeStamp, temperature, x, y, z FROM sensorData INNER JOIN \
    Sensors ON sensorData.id = Sensors.id  WHERE " + st + " AND " +  en 
    
zz = con.execute(q).fetchall()
print("records returned ", len(zz))

timeStamp   = [ v[1]  for v in zz ]
temperature = [ v[2]  for v in zz ]
x = [ v[3]  for v in zz ]
y = [ v[4]  for v in zz ]
z = [ v[5]  for v in zz ]
ID  = [ v[0]  for v in zz ]

IDtemperature = [ [v[0],v[2]]  for v in zz ]

minTemp = min(temperature)
indexMin = [i for i, j in enumerate(temperature) if j == minTemp]
minID = [ID[i] for i in indexMin]

maxTemp = max(temperature)
indexMax = [i for i, j in enumerate(temperature) if j == maxTemp]
maxID = [ID[i] for i in indexMax]

print("temperature range", minTemp, " at ", minID, " to ", maxTemp, " at ", maxID)
print("")

print("ID, temperature, timeStamp,      location (x,y,z)  for min")
for i in indexMin:
  print( ID[i], temperature[i], timeStamp[i], x[i],y[i],z[i])

print("ID, temperature, timeStamp,      location (x,y,z)  for max")
for i in indexMax:
  print( ID[i], temperature[i], timeStamp[i], x[i],y[i],z[i])


print("min x ", min(x), "max x ", max(x))
print("min y ", min(y), "max y ", max(y))
print("min z ", min(z), "max z ", max(z))

con.close() 
