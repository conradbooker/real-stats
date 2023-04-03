//
//  PythonSwiftFunctions.swift
//  real-stats
//
//  Created by Conrad on 4/1/23.
//

import Foundation
import PythonKit
import PythonSupport

func returnTimes(station: Station) -> PythonObject {
    PythonSupport.initialize()
    let path = String((Bundle.main.path(forResource: "main", ofType: "py")!).dropLast(8))
    print(path)
    
    ///private/var/containers/Bundle/Application/0FF83499-223B-4056-818D-0047E20CD79B/PlanIt.app/icsJSon.py

    let sys = Python.import("sys")
    sys.path.append(path)
    let file = Python.import("main")
    
    //network error handling here
//    getStationTimes(station,trunkLine,expectedLines)
    
    let response = file.getStationTimes(station.GTFSID,station.trunk,station.possibleLines)
    return response
}
