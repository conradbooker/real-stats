from google.transit import gtfs_realtime_pb2
import requests
from key import apiKey
import datetime
from stationDataFile import stations
import json


def getTimes(stationID,line,minutes=False):
    """
    finds the times for a train per station, and only searches given line

    returns times dicitonary (look below)
    """

    time = {
        "timeToCurrentStation": 1679412265,
        "tripID": "",
        "currentStation": "",
        "destination": "",
        "delays": []
    }

    times = {
        "northbound": [time,time,time,time],
        "southbound": [time,time,time,time]
    }



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



# def getStationLines():
#     return

if __name__ == "__main__":
    stationData = stations()
    print(stationData)
    for count,station in enumerate(stationData):
        GTFSID = stationData[count]["GTFSID"]
        del stationData[count]["GTFSID"]

        stopName = stationData[count]["stopName"]
        del stationData[count]["stopName"]

        stationID = stationData[count]["stationID"]
        del stationData[count]["stationID"]

        lines = stationData[count]["lines"]
        del stationData[count]["lines"]

        trunk = stationData[count]["trunk"]
        del stationData[count]["trunk"]

        borough = stationData[count]["borough"]
        del stationData[count]["borough"]

        lat = stationData[count]["lat"]
        del stationData[count]["lat"]

        long = stationData[count]["long"]
        del stationData[count]["long"]

        northDir = stationData[count]["northDir"]
        del stationData[count]["northDir"]

        southDir = stationData[count]["southDir"]
        del stationData[count]["southDir"]

        ADA = stationData[count]["ADA"]
        del stationData[count]["ADA"]

        stationData[count]["stations"] = [{}]

        stationData[count]["stations"][0]["GTFSID"] = GTFSID
        stationData[count]["stations"][0]["stationID"] = stationID
        stationData[count]["stations"][0]["stopName"] = stopName
        stationData[count]["stations"][0]["lines"] = lines
        stationData[count]["stations"][0]["trunk"] = trunk
        stationData[count]["stations"][0]["borough"] = borough
        stationData[count]["stations"][0]["lat"] = lat
        stationData[count]["stations"][0]["long"] = long
        stationData[count]["stations"][0]["northDir"] = northDir
        stationData[count]["stations"][0]["southDir"] = southDir
        stationData[count]["stations"][0]["ADA"] = ADA

    jsonFile = open("data.json","w")
    jsonFile.write(json.dumps(stationData, indent = 3, separators = (", ", ": ")))
    print(json.dumps(stationData, indent = 3, separators = (", ", ": ")))