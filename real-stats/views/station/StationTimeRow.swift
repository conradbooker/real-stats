//
//  StationRow.swift
//  real-stats
//
//  Created by Conrad on 4/1/23.
//

import SwiftUI

enum disruption {
    case delayed
    case none
    case skippedStations
    case slowSpeeds
    case reroutes
}

var stationKeys = [
    "R01": "Astoria-Ditmars Blvd", "R03": "Astoria Blvd", "R04": "30 Av", "R05": "Broadway", "R06": "36 Av", "R08": "39 Av-Dutch Kills", "R11": "Lexington Av/59 St", "R13": "5 Av/59 St", "R14": "57 St-7 Av", "R15": "49 St", "R16": "Times Sq-42 St", "R17": "34 St-Herald Sq", "R18": "28 St", "R19": "23 St", "R20": "14 St-Union Sq", "R21": "8 St-NYU", "R22": "Prince St", "R23": "Canal St", "Q01": "Canal St", "R24": "City Hall", "R25": "Cortlandt St", "R26": "Rector St", "R27": "Whitehall St-South Ferry", "R28": "Court St", "R29": "Jay St-MetroTech", "R30": "DeKalb Av", "R31": "Atlantic Av-Barclays Ctr", "R32": "Union St", "R33": "4 Av-9 St", "R34": "Prospect Av", "R35": "25 St", "R36": "36 St", "R39": "45 St", "R40": "53 St", "R41": "59 St", "R42": "Bay Ridge Av", "R43": "77 St", "R44": "86 St", "R45": "Bay Ridge-95 St", "D24": "Atlantic Av-Barclays Ctr", "D25": "7 Av", "D26": "Prospect Park", "D27": "Parkside Av", "D28": "Church Av", "D29": "Beverley Rd", "D30": "Cortelyou Rd", "D31": "Newkirk Plaza", "D32": "Avenue H", "D33": "Avenue J", "D34": "Avenue M", "D35": "Kings Hwy", "D37": "Avenue U", "D38": "Neck Rd", "D39": "Sheepshead Bay", "D40": "Brighton Beach", "D41": "Ocean Pkwy", "D42": "W 8 St-NY Aquarium", "D43": "Coney Island-Stillwell Av", "B12": "9 Av", "B13": "Fort Hamilton Pkwy", "B14": "50 St", "B15": "55 St", "B16": "62 St", "B17": "71 St", "B18": "79 St", "B19": "18 Av", "B20": "20 Av", "B21": "Bay Pkwy", "B22": "25 Av", "B23": "Bay 50 St", "N02": "8 Av", "N03": "Fort Hamilton Pkwy", "N04": "New Utrecht Av", "N05": "18 Av", "N06": "20 Av", "N07": "Bay Pkwy", "N08": "Kings Hwy", "N09": "Avenue U", "N10": "86 St", "J12": "121 St", "J13": "111 St", "J14": "104 St", "J15": "Woodhaven Blvd", "J16": "85 St-Forest Pkwy", "J17": "75 St-Elderts Ln", "J19": "Cypress Hills", "J20": "Crescent St", "J21": "Norwood Av", "J22": "Cleveland St", "J23": "Van Siclen Av", "J24": "Alabama Av", "J27": "Broadway Junction", "J28": "Chauncey St", "J29": "Halsey St", "J30": "Gates Av", "J31": "Kosciuszko St", "M11": "Myrtle Av", "M12": "Flushing Av", "M13": "Lorimer St", "M14": "Hewes St", "M16": "Marcy Av", "M18": "Delancey St-Essex St", "M19": "Bowery", "M20": "Canal St", "M21": "Chambers St", "M22": "Fulton St", "M23": "Broad St", "M01": "Middle Village-Metropolitan Av", "M04": "Fresh Pond Rd", "M05": "Forest Av", "M06": "Seneca Av", "M08": "Myrtle-Wyckoff Avs", "M09": "Knickerbocker Av", "M10": "Central Av", "L01": "8 Av", "L02": "6 Av", "L03": "14 St-Union Sq.", "L05": "3 Av", "L06": "1 Av", "L08": "Bedford Av", "L10": "Lorimer St", "L11": "Graham Av", "L12": "Grand St", "L13": "Montrose Av", "L14": "Morgan Av", "L15": "Jefferson St", "L16": "DeKalb Av", "L17": "Myrtle-Wyckoff Avs", "L19": "Halsey St", "L20": "Wilson Av", "L21": "Bushwick Av-Aberdeen St", "L22": "Broadway Junction", "L24": "Atlantic Av", "L25": "Sutter Av", "L26": "Livonia Av", "L27": "New Lots Av", "L28": "East 105 St", "L29": "Canarsie-Rockaway Pkwy", "S01": "Franklin Av", "S03": "Park Pl", "S04": "Botanic Garden", "A02": "Inwood-207 St", "A03": "Dyckman St", "A05": "190 St", "A06": "181 St", "A07": "175 St", "A09": "168 St", "A10": "163 St-Amsterdam Av", "A11": "155 St", "A12": "145 St", "D13": "145 St", "A14": "135 St", "A15": "125 St", "A16": "116 St", "A17": "Cathedral Pkwy (110 St)", "A18": "103 St", "A19": "96 St", "A20": "86 St", "A21": "81 St-Museum of Natural History", "A22": "72 St", "A24": "59 St-Columbus Circle", "A25": "50 St", "A27": "42 St-Port Authority Bus Terminal", "A28": "34 St-Penn Station", "A30": "23 St", "A31": "14 St", "A32": "W 4 St-Wash Sq", "D20": "W 4 St-Wash Sq", "A33": "Spring St", "A34": "Canal St", "A36": "Chambers St", "E01": "World Trade Center", "A38": "Fulton St", "A40": "High St", "A41": "Jay St-MetroTech", "A42": "Hoyt-Schermerhorn Sts", "A43": "Lafayette Av", "A44": "Clinton-Washington Avs", "A45": "Franklin Av", "A46": "Nostrand Av", "A47": "Kingston-Throop Avs", "A48": "Utica Av", "A49": "Ralph Av", "A50": "Rockaway Av", "A51": "Broadway Junction", "A52": "Liberty Av", "A53": "Van Siclen Av", "A54": "Shepherd Av", "A55": "Euclid Av", "A57": "Grant Av", "A59": "80 St", "A60": "88 St", "A61": "Rockaway Blvd", "A63": "104 St", "A64": "111 St", "A65": "Ozone Park-Lefferts Blvd", "H01": "Aqueduct Racetrack", "H02": "Aqueduct-N Conduit Av", "H03": "Howard Beach-JFK Airport", "H04": "Broad Channel", "H12": "Beach 90 St", "H13": "Beach 98 St", "H14": "Beach 105 St", "H15": "Rockaway Park-Beach 116 St", "H06": "Beach 67 St", "H07": "Beach 60 St", "H08": "Beach 44 St", "H09": "Beach 36 St", "H10": "Beach 25 St", "H11": "Far Rockaway-Mott Av", "D01": "Norwood-205 St", "D03": "Bedford Park Blvd", "D04": "Kingsbridge Rd", "D05": "Fordham Rd", "D06": "182-183 Sts", "D07": "Tremont Av", "D08": "174-175 Sts", "D09": "170 St", "D10": "167 St", "D11": "161 St-Yankee Stadium", "D12": "155 St", "B04": "21 St-Queensbridge", "B06": "Roosevelt Island", "B08": "Lexington Av/63 St", "B10": "57 St", "D15": "47-50 Sts-Rockefeller Ctr", "D16": "42 St-Bryant Pk", "D17": "34 St-Herald Sq", "D18": "23 St", "D19": "14 St", "D21": "Broadway-Lafayette St", "D22": "Grand St", "F14": "2 Av", "F15": "Delancey St-Essex St", "F16": "East Broadway", "F18": "York St", "F20": "Bergen St", "F21": "Carroll St", "F22": "Smith-9 Sts", "F23": "4 Av-9 St", "F24": "7 Av", "F25": "15 St-Prospect Park", "F26": "Fort Hamilton Pkwy", "F27": "Church Av", "F29": "Ditmas Av", "F30": "18 Av", "F31": "Avenue I", "F32": "Bay Pkwy", "F33": "Avenue N", "F34": "Avenue P", "F35": "Kings Hwy", "F36": "Avenue U", "F38": "Avenue X", "F39": "Neptune Av", "F01": "Jamaica-179 St", "F02": "169 St", "F03": "Parsons Blvd", "F04": "Sutphin Blvd", "F05": "Briarwood", "F06": "Kew Gardens-Union Tpke", "F07": "75 Av", "G08": "Forest Hills-71 Av", "G09": "67 Av", "G10": "63 Dr-Rego Park", "G11": "Woodhaven Blvd", "G12": "Grand Av-Newtown", "G13": "Elmhurst Av", "G14": "Jackson Hts-Roosevelt Av", "G15": "65 St", "G16": "Northern Blvd", "G18": "46 St", "G19": "Steinway St", "G20": "36 St", "G21": "Queens Plaza", "F09": "Court Sq-23 St", "F11": "Lexington Av/53 St", "F12": "5 Av/53 St", "D14": "7 Av", "G05": "Jamaica Center-Parsons/Archer", "G06": "Sutphin Blvd-Archer Av-JFK Airport", "G07": "Jamaica-Van Wyck", "G22": "Court Sq", "G24": "21 St", "G26": "Greenpoint Av", "G28": "Nassau Av", "G29": "Metropolitan Av", "G30": "Broadway", "G31": "Flushing Av", "G32": "Myrtle-Willoughby Avs", "G33": "Bedford-Nostrand Avs", "G34": "Classon Av", "G35": "Clinton-Washington Avs", "G36": "Fulton St", "101": "Van Cortlandt Park\n242 St", "103": "238 St", "104": "231 St", "106": "Marble Hill-225 St", "107": "215 St", "108": "207 St", "109": "Dyckman St", "110": "191 St", "111": "181 St", "112": "168 St-Washington Hts", "113": "157 St", "114": "145 St", "115": "137 St-City College", "116": "125 St", "117": "116 St-Columbia University", "118": "Cathedral Pkwy (110 St)", "119": "103 St", "120": "96 St", "121": "86 St", "122": "79 St", "123": "72 St", "124": "66 St-Lincoln Center", "125": "59 St-Columbus Circle", "126": "50 St", "127": "Times Sq-42 St", "128": "34 St-Penn Station", "129": "28 St", "130": "23 St", "131": "18 St", "132": "14 St", "133": "Christopher St-Sheridan Sq", "134": "Houston St", "135": "Canal St", "136": "Franklin St", "137": "Chambers St", "138": "WTC Cortlandt", "139": "Rector St", "142": "South Ferry", "228": "Park Place", "229": "Fulton St", "230": "Wall St", "231": "Clark St", "232": "Borough Hall", "233": "Hoyt St", "234": "Nevins St", "235": "Atlantic Av-Barclays Ctr", "236": "Bergen St", "237": "Grand Army Plaza", "238": "Eastern Pkwy-Brooklyn Museum", "239": "Franklin Avenue-Medgar Evers College", "248": "Nostrand Av", "249": "Kingston Av", "250": "Crown Hts-Utica Av", "251": "Sutter Av-Rutland Rd", "252": "Saratoga Av", "253": "Rockaway Av", "254": "Junius St", "255": "Pennsylvania Av", "256": "Van Siclen Av", "257": "New Lots Av", "241": "President Street-Medgar Evers College", "242": "Sterling St", "243": "Winthrop St", "244": "Church Av", "245": "Beverly Rd", "246": "Newkirk Av - Little Haiti", "247": "Flatbush Av-Brooklyn College", "601": "Pelham Bay Park", "602": "Buhre Av", "603": "Middletown Rd", "604": "Westchester Sq-E Tremont Av", "606": "Zerega Av", "607": "Castle Hill Av", "608": "Parkchester", "609": "St Lawrence Av", "610": "Morrison Av-Soundview", "611": "Elder Av", "612": "Whitlock Av", "613": "Hunts Point Av", "614": "Longwood Av", "615": "E 149 St", "616": "E 143 St-St Mary's St", "617": "Cypress Av", "618": "Brook Av", "619": "3 Av-138 St", "401": "Woodlawn", "402": "Mosholu Pkwy", "405": "Bedford Park Blvd-Lehman College", "406": "Kingsbridge Rd", "407": "Fordham Rd", "408": "183 St", "409": "Burnside Av", "410": "176 St", "411": "Mt Eden Av", "412": "170 St", "413": "167 St", "414": "161 St-Yankee Stadium", "415": "149 St-Grand Concourse", "416": "138 St-Grand Concourse", "621": "125 St", "622": "116 St", "623": "110 St", "624": "103 St", "625": "96 St", "626": "86 St", "627": "77 St", "628": "68 St-Hunter College", "629": "59 St", "630": "51 St", "631": "Grand Central-42 St", "632": "33 St", "633": "28 St", "634": "23 St", "635": "14 St-Union Sq", "636": "Astor Pl", "637": "Bleecker St", "638": "Spring St", "639": "Canal St", "640": "Brooklyn Bridge-City Hall", "418": "Fulton St", "419": "Wall St", "420": "Bowling Green", "423": "Borough Hall", "201": "Wakefield-241 St", "204": "Nereid Av", "205": "233 St", "206": "225 St", "207": "219 St", "208": "Gun Hill Rd", "209": "Burke Av", "210": "Allerton Av", "211": "Pelham Pkwy", "212": "Bronx Park East", "213": "E 180 St", "214": "West Farms Sq-E Tremont Av", "215": "174 St", "216": "Freeman St", "217": "Simpson St", "218": "Intervale Av", "219": "Prospect Av", "220": "Jackson Av", "221": "3 Av-149 St", "222": "149 St-Grand Concourse", "301": "Harlem-148 St", "302": "145 St", "224": "135 St", "225": "125 St", "226": "116 St", "227": "Central Park North (110 St)", "501": "Eastchester-Dyre Av", "502": "Baychester Av", "503": "Gun Hill Rd", "504": "Pelham Pkwy", "505": "Morris Park", "701": "Flushing-Main St", "702": "Mets-Willets Point", "705": "111 St", "706": "103 St-Corona Plaza", "707": "Junction Blvd", "708": "90 St-Elmhurst Av", "709": "82 St-Jackson Hts", "710": "74 St-Broadway", "711": "69 St", "712": "Woodside-61 St", "713": "52 St", "714": "46 St-Bliss St", "715": "40 St-Lowery St", "716": "33 St-Rawson St", "718": "Queensboro Plaza", "R09": "Queensboro Plaza", "719": "Court Sq", "720": "Hunters Point Av", "721": "Vernon Blvd-Jackson Av", "723": "Grand Central-42 St", "724": "5 Av", "725": "Times Sq-42 St", "902": "Times Sq-42 St", "901": "Grand Central-42 St", "726": "34 St-Hudson Yards", "Q05": "96 St", "Q04": "86 St", "Q03": "72 St", "S31": "St George", "S30": "Tompkinsville", "S29": "Stapleton", "S28": "Clifton", "S27": "Grasmere", "S26": "Old Town", "S25": "Dongan Hills", "S24": "Jefferson Av", "S23": "Grant City", "S22": "New Dorp", "S21": "Oakwood Heights", "S20": "Bay Terrace", "S19": "Great Kills", "S18": "Eltingville", "S17": "Annadale", "S16": "Huguenot", "S15": "Prince's Bay", "S14": "Pleasant Plains", "S13": "Richmond Valley", "S09": "Tottenville", "S11": "Arthur Kill"
]

struct StationTimeRow: View {
    var line: String
    var destination: String
    var times: [Indv]
    var disruptions: disruption
        
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(Color("cLessDarkGray"))
                            .shadow(radius: 2)
                        HStack(spacing: 0) {
                            Spacer()
                            if times.count > 2 {
                                individualTime(time: times[2].countdown)
                                    .padding(.trailing,10)
                            } else {
                                Text("--")
                                    .padding(.trailing,10)
                            }
                        }
                    }
                    .frame(width: geometry.size.width*2.7/12, height: 55)
                }
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: geometry.size.width*6.3/12)
                    Button {
                        
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(Color("cLessDarkGray"))
                                .shadow(radius: 2)
                            HStack(spacing: 0) {
                                Spacer()
                                if times.count > 1 {
                                    individualTime(time: times[1].countdown)
                                        .padding(.trailing,10)
                                } else {
                                    Text("--")
                                        .padding(.trailing, 10)
                                }
                            }
                        }
                        .frame(width: geometry.size.width*2.7/12, height: 55)
                    }
                    .buttonStyle(CButton())
                }
                HStack(spacing: 0) {
                    Button {
                        
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(Color("cLessDarkGray"))
                                .shadow(radius: 2)
                            HStack(spacing: 0) {
                                Image(line)
                                    .resizable()
                                    .frame(width: 40,height: 40)
                                    .padding(7.5)
                                VStack {
                                    Text(destination)
                                        .fontWeight(.bold)
                                    Frequency(times: times)
                                }
                                Spacer()
                                individualTime(time: times[0].countdown)
                                    .padding(.trailing,15)
                            }
                        }
                        .frame(width: geometry.size.width*9/12, height: 55)
                    }
                    .buttonStyle(CButton())
                    Spacer()
                }
            }
        }
    }
}

struct Frequency: View {
    var times: [Indv]
    
    func getFrequency() -> Int {
        var frequencies: [Int] = []
        for index in 0..<times.count {
            if index < times.count-1 {
                frequencies.append(abs(times[index].countdown-times[index+1].countdown))
            }
        }
        let sum = frequencies.reduce(0, +)
        return Int(sum / times.count)
    }
    
    var body: some View {
        VStack {
            Text("Every \(getFrequency()/60) mins")
                .font(.caption)
        }
    }
}

struct individualTime: View {
    var time: Int
    var body: some View {
        VStack {
            if time >= 70 {
                Text("\(Int(time-10)/60)")
                    .font(.title3)
                    .fontWeight(.bold)
                if Int(time-10)/60 == 1 {
                    Text("min")
                        .font(.footnote)
                } else {
                    Text("mins")
                        .font(.footnote)
                }
            } else if time > 69 {
                Text("<1")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("min")
                    .font(.footnote)
            } else if time > 20 {
                Text("arriving")
            } else if time > 10 {
                Text("at station")
            } else if time > 0 {
                Text("leaving")
            }
        }
    }
}

struct StationTimeRow_Previews: PreviewProvider {
    static var previews: some View {
        
        let time = (String(returnTimes(station: complexData[340].stations[0])) ?? "").decodeJson(Time.self)
        StationTimeRow(line: "6", destination: "Coney Island", times: time.north[0].times, disruptions: .delayed)
            .previewLayout(.fixed(width: 375, height: 65))
    }
}
