import something

def getTimes(stationID,line,direction,minutes=True):
    """
    finds the times for a train per station

    returns an array of numbers (times)
    """

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

