from stationDataDict import getStationData
import json

stations = getStationData()
thing = {
      "id": 1, 
      "complexName": "Astoria-Ditmars Blvd", 
      "stations": [
         {
            "GTFSID": "R01", 
            "id": 1,
            "stopName": "Astoria-Ditmars Blvd", 
            "lines": [], 
            "trunk": "Astoria", 
            "borough": "Q", 
            "lat": 40.775036, 
            "long": -73.912034, 
            "northDir": "", 
            "southDir": "Manhattan", 
            "ADA": 0, 
            "short1": "Ditmars Blvd", 
            "short2": "Astoria", 
            "expectedLines": [
               "N", 
               "Q", 
               "W"
            ]
         }
      ]
   }

for complex in stations:
    for station in complex["stations"]:
        print(station)
        station["GTFSID"] = str(station["GTFSID"])
        station["expectedLines"] = [str(line) for line in station["expectedLines"]]

jsonFile = open("data.json","w")
jsonFile.write(json.dumps(stations, indent = 3, separators = (", ", ": ")))

