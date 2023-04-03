from google.transit import gtfs_realtime_pb2
import requests
from key import apiKey
import datetime
# from stationDataFile import stations
import json
import time

def getStationAlerts(stationID):
    """
    finds alerts for a particular station (ie the escalator is out of service, or trains are skipping station, etc)

    returns dictionary
    """

    alerts = []

    exampleAlert = {
        "title": "No Service",
        "description": "Uptown (C) & (E) trains are running express from 42St onwards",
        "dateStart": 1678677203,
        "dateEnd": 1678678189
    }

def getLineAlerts(line):
    """
    finds alerts for a particular line

    returns array of alerts
    """

def getImmediateAlerts(line):
    """
    finds immediate alerts for a particular line

    returns array of alerts (ie slow speeds, train went out of service, delays, etc.)
    """

def returnScope(trunk):

    ACE = '-ace'
    BDFM = '-bdfm'
    NQRW = '-nqrw'
    G = '-g'
    L = '-l'
    JZ = '-jz'
    IRT = ''
    SI = '-si'

    if trunk == '2nd Av' or trunk == '4th Av':
        return [NQRW,BDFM]
    elif trunk == '6th Av' or trunk == '8th Av':
        return [ACE,BDFM]
    elif trunk == 'Fulton St':
        return [ACE,G]
    elif trunk == 'Liberty Av' or trunk == 'Rockaway':
        return [ACE]
    elif trunk == '63rd St':
        return [NQRW,BDFM,ACE]
    elif trunk == 'Archer Av':
        return [ACE,BDFM]
    elif trunk == 'Queens Blvd':
        return [ACE,NQRW,BDFM]
    elif trunk == 'Astoria':
        return [NQRW]
    elif trunk == 'Brighton':
        return [NQRW,BDFM]
    elif trunk == 'Broadway':
        return [ACE,NQRW]
    elif trunk == 'Canarsie':
        return [L]
    elif trunk == 'Concourse':
        return [ACE,BDFM]
    elif trunk == 'Crosstown' or trunk == 'Culver':
        return [BDFM,G]
    elif trunk == 'Franklin Shuttle':
        return [ACE]
    elif trunk == 'Jamaica':
        return [JZ,BDFM]
    elif trunk == 'Myrtle Av':
        return [BDFM]
    elif trunk == 'Sea Beach' or trunk == 'West End':
        return [BDFM,NQRW]
    elif trunk == 'Staten Island':
        return [SI]
    else:
        return [IRT]



def getStationTimes(station,trunkLine,expectedLines):
    """
    finds lines for a particular station
    parameters:
    - trunk: if it is 
       - a: all
       - ind: ACE, SF, SR, BDFM, NQRW, G
       - bmt: JZ, L
       - irt: 123, 4566X, 77X, S42
    - 

    returns time JSON
    """
    key = apiKey()

    scope = returnScope(trunkLine)
    print(scope)

    times = {
        "north": [],
        "south": []
    }

    for expectedLine in expectedLines:
        times['north'].append({"line": str(expectedLine),"times": []})
        times['south'].append({"line": str(expectedLine),"times": []})

    # for section in scope: find station times for a line

    for trunk in scope:
        print("1")
        # add each line to dictionary of stations
        feed = gtfs_realtime_pb2.FeedMessage()
        response = requests.get('https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs' + trunk, headers={"x-api-key": key})
        feed.ParseFromString(response.content)

        for entity in feed.entity:
            if entity.HasField("trip_update"):
                routeStr = str(entity.trip_update.trip.route_id)

                if routeStr in ["1","2","3","4","5","6","7"]:
                    routeInt = int(entity.trip_update.trip.route_id)
                else:
                    routeInt = 0

                tripID = str(entity.trip_update.trip.trip_id)

                if routeStr in expectedLines or routeInt in expectedLines:
                    for stop_time_update in entity.trip_update.stop_time_update:

                        direction = str(tripID.split(".")[-1])[0]
                        
                        GTFSID = str(stop_time_update.stop_id)[:-1]
                        print(f"route: {routeStr}, id: {tripID}, gtfsID: {GTFSID}, station: {station}")

                        if GTFSID == station:
                            print(f"station is {station}")
                            currentTime = int(time.time())
                            newTime = {}
                            if stop_time_update.HasField("arrival"):
                                newTime["currentStationTime"] = int(stop_time_update.arrival.time)
                            else:
                                newTime["currentStationTime"] = int(stop_time_update.departure.time)
                            newTime["tripID"] = tripID
                            newTime["destinationID"] = str(entity.trip_update.stop_time_update[-1].stop_id)
                            newTime["countdown"] = (newTime["currentStationTime"] - currentTime)

                            if direction == "N" and newTime["currentStationTime"] > currentTime:
                                for index, subLine in enumerate(times['north']):
                                    if subLine['line'] == routeStr or subLine['line'] == routeInt:
                                        times['north'][index]['times'].append(newTime)
                            elif direction == "S" and newTime["currentStationTime"] > currentTime:
                                for index, subLine in enumerate(times['south']):
                                    if subLine['line'] == routeInt or subLine['line'] == routeStr:
                                        times['south'][index]['times'].append(newTime)

    
    # STEP 3: Clean Up

    timesClean = {
        "north": [],
        "south": []
    }

    for direction in times:
        for index, line in enumerate(times[direction]):
            if len(line["times"]) != 0:
                timesClean[direction].append(line)

    for key in timesClean:
        for route in timesClean[key]:
            route["times"] = sorted(route["times"], key=lambda d: d['countdown'])
    
    # timesClean["north"] = sorted(timesClean["north"]["times"], key=lambda d: d['countdown'])
    # timesClean["south"] = sorted(timesClean["south"]["times"], key=lambda d: d['countdown'])

    return json.dumps(timesClean, indent = 3, separators = (",", ": "))


if __name__ == "__main__":
   station = "420"
   trunkLine = "Lex"
   expectedLines = [4,5]
   times = getStationTimes(station,trunkLine,expectedLines)
   print(times)
   jsonFile = open("stationTimes.json","w")
   jsonFile.write(times)

   feed = gtfs_realtime_pb2.FeedMessage()
   response = requests.get('https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs', headers={"x-api-key": apiKey()})
   feed.ParseFromString(response.content)
   
   file = open("data.txt","w")
   file.write(str(feed.entity))




# def getAllStationLines(station,trunk):
#     """
#     finds lines for a particular station
#     parameters:
#     - trunk: if it is 
#        - a: all
#        - ind: ACE, SF, SR, BDFM, NQRW, G
#        - bmt: JZ, L
#        - irt: 123, 4566X, 77X, S42
#     - 

#     returns json
#     """

#     scope = returnScope(trunk)

#     for station in stations: # this looks through all stations to see what lines there are (code aready done in test.py)

#         return

# if __name__ == "__main__":
#     stationData = stations()
#     # print(stationData)
#     for count,stat in enumerate(stationData):
#         GTFSID = stat["GTFSID"]
#         del stat["GTFSID"]

#         stopName = stat["stopName"]
#         del stat["stopName"]

#         expectedLines = stat["expectedLines"]
#         del stat["expectedLines"]

#         stationID = stat["stationID"]
#         del stat["stationID"]

#         lines = stat["lines"]
#         del stat["lines"]

#         trunk = stat["trunk"]
#         del stat["trunk"]

#         borough = stat["borough"]
#         del stat["borough"]

#         lat = stat["lat"]
#         del stat["lat"]

#         long = stat["long"]
#         del stat["long"]

#         northDir = stat["northDir"]
#         del stat["northDir"]

#         southDir = stat["southDir"]
#         del stat["southDir"]

#         ADA = stat["ADA"]
#         del stat["ADA"]

#         short1 = stat["short1"]
#         del stat["short1"]

#         short2 = stat["short2"]
#         del stat["short2"]

#         stat["stations"].append({})

#         pos = len(stat["stations"])-1

#         stat["stations"][pos]["GTFSID"] = GTFSID
#         stat["stations"][pos]["stationID"] = stationID
#         stat["stations"][pos]["stopName"] = stopName
#         stat["stations"][pos]["lines"] = lines
#         stat["stations"][pos]["trunk"] = trunk
#         stat["stations"][pos]["borough"] = borough
#         stat["stations"][pos]["lat"] = lat
#         stat["stations"][pos]["long"] = long
#         stat["stations"][pos]["northDir"] = northDir
#         stat["stations"][pos]["southDir"] = southDir
#         stat["stations"][pos]["ADA"] = ADA
#         stat["stations"][pos]["short1"] = short1
#         stat["stations"][pos]["short2"] = short2
#         stat["stations"][pos]["expectedLines"] = expectedLines


#     jsonFile = open("data.json","w")
#     jsonFile.write(json.dumps(stationData, indent = 3, separators = (", ", ": ")))
#     # print(json.dumps(stationData, indent = 3, separators = (", ", ": ")))
