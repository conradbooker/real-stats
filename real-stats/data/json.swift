//
//  JSON.swift
//  Tisander
//
//  Created by Mike Bignell on 22/06/2018.
//  Copyright © 2018 Mike Bignell. All rights reserved.
//

import Foundation

/**
 Errors when parsing JSON string
 */
public enum SerializationError: String, Error {
    /// Unterminated object. Opening curley brace without a close
    case unterminatedObject
    /// Unterminated Array. Opening square brackets without a close
    case unterminatedArray
    /// Unterminated string. Opening double quote without matching ending one
    case unterminatedString
    /// Invalid JSON
    case invalidJSON
    /// Invalid array element. One of the elements in the array was not valid
    case invalidArrayElement
    /// Number missing it's exponent part
    case invalidNumberMissingExponent
    /// Number was missing it's fractional element
    case invalidNumberMissingFractionalElement
    /// Reached the end of the file unexpectedly
    case unexpectedEndOfFile
}

/// Element of JSON structure, can be an array element or a key/value
internal protocol JSONElement: Value {}

/// Any value for JSON, can be Object, array, number, string, boolean or null
public protocol Value {
    /**
     Subscript for getting values from keys
     - parameter key: key for value
     - returns: value for key. Also returns nil if it is not a key/value structure
     */
    subscript(key: String) -> Value? { get }
    /**
     Subscript for retrieving items from an array at index
     - parameter index: index for value
     - returns: value at index
     */
    subscript(index: Int) -> Value? { get }
}

/// Protocol to provide a string representation of the JSON structure
internal protocol JSONStringRepresentable {
    /**
     String representation of the JSON
     - returns: string with the json sub-value
     */
    func stringRepresentation() -> String
}

extension Value {
    /**
     Convert a JSON object or array into a string
     - returns: String representation of the entire object
     */
    public func toJSONString() -> String {
        if type(of: self) is [JSON.ObjectElement].Type {
            return (self as? [JSON.ObjectElement])?.stringRepresentation() ?? ""
        } else if type(of: self) is [JSON.ArrayElement].Type {
            return (self as? [JSON.ArrayElement])?.stringRepresentation() ?? ""
        }
        
        return ""
    }
}

public extension Value {
    /**
     Subscript for getting values from keys
     - parameter key: key for value
     - returns: value for key. Also returns nil if it is not a key/value structure
     */
    public subscript(key: String) -> Value? {
        get {
            return (self as? [JSON.ObjectElement])?.reduce(nil, { (result, element) -> Value? in
                guard result == nil else { return result }
                
                return element.key == key ? element.value : nil
            })
        }
    }
    /**
     Subscript for getting values from indexes
     - parameter index: index to retrieve
     - returns: value if index is valid and the subject is an array of `JSON.ArrayElement`s
     */
    public subscript(index: Int) -> Value? {
        get {
            guard let elementArray = self as? [JSON.ArrayElement],
                index >= 0,
                index <  elementArray.count
                else { return nil }
            
            return ((elementArray as [Any])[index] as? JSON.ArrayElement)?.value
        }
    }
    
    /// Get all keys in the key/value set, returns nil if the array is not keys/values.
    public var keys: [String]? {
        return (self as? [JSON.ObjectElement])?.compactMap { $0.key }
    }
    
    /// Get all values in the current structure
    public var values: [Value]? {
        return (self as? [JSON.ArrayElement])?.map { $0.value } ?? (self as? [JSON.ObjectElement])?.map { $0.value }
    }
}

extension Bool: Value, JSONStringRepresentable {
    /**
     Return the string representation of this boolean
     - returns: either 'true' or 'false'
     */
    func stringRepresentation() -> String { return self ? "true" : "false" }
}
extension Int: Value, JSONStringRepresentable {
    /**
     Return the string representation of this integer
     - returns: integer as string
     */
    func stringRepresentation() -> String { return String(self) }
}
extension Double: Value, JSONStringRepresentable {
    /**
     Return the string representation of this double precision floating point number
     - returns: double as string. Uses default system number formatter
     */
    func stringRepresentation() -> String { return String(self) }
}
extension String: Value, JSONStringRepresentable {
    /**
     Return the string
     - returns: string in quotes
     */
    func stringRepresentation() -> String { return "\"\(self)\"" }
}
extension JSON.ArrayElement: JSONElement, JSONStringRepresentable {
    /**
     Return the string representation of this array element
     - returns: string representation of this array element
     */
    func stringRepresentation() -> String { return "\(self.value.stringRepresentation())" }
}
extension JSON.ObjectElement: JSONElement, JSONStringRepresentable {
    /**
     Return the string representation of this object
     - returns: string representation of this object with a "key":value
     */
    func stringRepresentation() -> String { return "\"\(self.key)\":\(self.value.stringRepresentation())" }
}
extension JSON.NULL: Value, JSONStringRepresentable {
    /**
     Return the string representation of this null
     - returns: "null"
     */
    func stringRepresentation() -> String { return "null" }
}

extension Array: Value, JSONStringRepresentable where Array.Element: JSONElement {
    /**
     Return the string representation of this JSON structure
     - returns: string representation of this JSON structure
     */
    func stringRepresentation() -> String {
        if Array.Element.self == JSON.ObjectElement.self {
            return "{\( (self as? [JSON.ObjectElement])?.map { $0.stringRepresentation() }.joined(separator: ",") ?? "" )}"
        } else if Array.Element.self == JSON.ArrayElement.self {
            return "[\( (self as? [JSON.ArrayElement])?.map { $0.stringRepresentation() }.joined(separator: ",") ?? "" )]"
        }
        
        return ""
    }
}

/**
 Create a representation of the JSON document that is parsed. Does not use Apple's `JSONSerialization` class and therefore keeps the order of the keys in the set as it's enountered.
 */
open class JSON {
    /// Representation for null value
    class NULL {}
    
    /// Array element representation
    struct ArrayElement {
        /// Array element value
        let value: Value & JSONStringRepresentable
    }
    
    /// Object element representation
    struct ObjectElement {
        /// Object element key
        let key: String
        /// Object element value
        let value: Value & JSONStringRepresentable
    }
    
    /**
     Return a JSON structure value
     
     - parameter string: String representation of JSON
     - returns: An array of `ArrayElement`s or `ObjectElemet`s
     - throws: `SerializationError`
     */
    public static func parse(string: String) throws -> Value {
        
        let json = JSON()
        
        var index = string.startIndex
        
        // Run space parser to remove beginning spaces
        _ = json.spaceParser(string, index: &index)
        
        if let arrayElements = try json.arrayParser(string, index: &index) {
            return arrayElements
        } else if let objectElements = try json.objectParser(string, index: &index) {
            return objectElements
        }
        
        throw SerializationError.invalidJSON
    }
    
    /**
     Function to parse object
     
     Starts by checking for a {
     Next checks for the key of the object
     finally the value of the key
     Uses - KeyParser,SpaceParser,valueParser and endofsetParser
     Finally checks for the end of the main Object with a }
     
     - parameter jsonString: String representation of JSON
     - parameter index: Current index in json document
     - returns: An array of `ObjectElemet`s
     - throws: `SerializationError.unterminatedObject`
     */
    private func objectParser(_ jsonString: String, index: inout String.Index) throws -> [ObjectElement]? {
        guard index != jsonString.endIndex, jsonString[index] == "{" else { return nil }
        
        var parsedDict = [ObjectElement]()
        index = jsonString.index(after: index)
        
        while true {
            if let key = try keyParser(jsonString,index: &index) {
                _ = spaceParser(jsonString, index: &index)
                
                guard let _ = colonParser(jsonString, index: &index) else { return nil }
                
                if let value = try valueParser(jsonString, index: &index) {
                    parsedDict.append(ObjectElement(key: key, value: value))
                }
                
                _ = spaceParser(jsonString, index: &index)
                
                if let _ = endOfSetParser(jsonString, index: &index) {
                    return parsedDict
                }
            } else if index == jsonString.endIndex {
                throw SerializationError.unterminatedObject
            } else if jsonString[index] == "}" || isSpace(jsonString[index]) {
                _ = spaceParser(jsonString, index: &index)
                
                guard let _ = endOfSetParser(jsonString, index: &index) else {
                    throw SerializationError.unterminatedObject
                }
                
                return parsedDict
            } else {
                break
            }
        }
        
        return nil
    }
    
    /**
     Function to check key value in an object
     
     Uses SpaceParser and StringParser
     
     - parameter jsonString: String representation of JSON
     - parameter index: Current index in json document
     - returns: Key string or nil
     - throws: `SerializationError`
     */
    private func keyParser(_ jsonString: String, index: inout String.Index) throws -> String? {
        _ = spaceParser(jsonString, index: &index)
        
        return try stringParser(jsonString, index: &index) ?? nil
    }
    
    /**
     Function to check for a colon
     
     - parameter jsonString: String representation of JSON
     - parameter index: Current index in json document
     - returns: Colon or null
     */
    @discardableResult
    private func colonParser(_ jsonString: String, index: inout String.Index) -> String? {
        guard index != jsonString.endIndex, jsonString[index] == ":" else { return nil }
        
        index = jsonString.index(after: index)
        
        return ":"
    }
    
    /**
     Function to check value in an object
     
     SpaceParser to remove spaces
     pass it to the elemParser
     stores the returned element in a variable called value
     after which the string is then passed to the space and comma parser
     
     - parameter jsonString: String representation of JSON
     - parameter index: Current index in json document
     - returns: a JSON value
     - throws: `SerializationError`
     */
    private func valueParser(_ jsonString:String, index: inout String.Index) throws -> (Value & JSONStringRepresentable)? {
        _ = spaceParser(jsonString, index: &index)
        
        guard let value = try elemParser(jsonString, index: &index) else { return nil }
        
        _ = spaceParser(jsonString, index: &index)
        _ = commaParser(jsonString, index: &index)
        
        return value
    }
    
    /**
     Function to check end of object
     
     Checks for a }
     
     - parameter jsonString: String representation of JSON
     - parameter index: Current index in json document
     - returns: a closing curley brace
     */
    @discardableResult
    private func endOfSetParser(_ jsonString:String, index: inout String.Index) -> Bool? {
        guard jsonString[index] == "}" else { return nil }
        
        index = jsonString.index(after: index)
        
        return true
    }
    
    /**
     Function to parser an array
     
     Starts by checking for a [
     After which it is passed to an elemParser store the returned value in another array called parsed array
     Uses elemParser,SpaceParser,commaParser,endOfArrayParser
     Finally checks for a ] to mark the end of the array
     
     - parameter jsonString: String representation of JSON
     - parameter index: Current index in json document
     - returns: an array of elements
     - throws: `SerializationError`
     */
    private func arrayParser(_ jsonString: String, index: inout String.Index) throws -> [ArrayElement]? {
        guard jsonString[index] == "[" else { return nil }
        
        var parsedArray = [ArrayElement]()
        index = jsonString.index(after: index)
        
        while true {
            if let returnedElem = try elemParser(jsonString, index: &index) {
                parsedArray.append(ArrayElement(value: returnedElem))
                _ = spaceParser(jsonString, index: &index)
                
                if let _ = commaParser(jsonString, index: &index) {
                    
                } else if let _ = endOfArrayParser(jsonString, index: &index) {
                    return parsedArray
                } else {
                    return nil
                }
            } else if index == jsonString.endIndex {
                throw SerializationError.unterminatedArray
            } else if jsonString[index] == "]" || isSpace(jsonString[index]) {
                _ = spaceParser(jsonString, index: &index)
                
                guard let _ = endOfArrayParser(jsonString, index: &index) else {
                    throw SerializationError.unterminatedArray
                }
                
                return parsedArray
            } else {
                throw SerializationError.invalidArrayElement
            }
        }
    }
    
    /**
     Parsing elements in Array or value in a key/value pair
     
     Uses StringParser,numberParser,arrayParser,objectParser and nullParser
     
     - parameter jsonString: String representation of JSON
     - parameter index: Current index in json document
     - returns: element
     - throws: `SerializationError`
     */
    private func elemParser(_ jsonString:String, index: inout String.Index) throws -> (Value & JSONStringRepresentable)? {
        guard index != jsonString.endIndex else { throw SerializationError.unexpectedEndOfFile }
        _ = spaceParser(jsonString, index: &index)
        
        if let value = try stringParser(jsonString, index: &index) {
            return value
        } else if let value = try numberParser(jsonString, index: &index) {
            return value
        } else if let value = booleanParser(jsonString, index: &index) {
            return value
        } else if let value = try arrayParser(jsonString, index: &index) {
            return value
        } else if let value = try objectParser(jsonString, index: &index) {
            return value
        } else if let value = nullParser(jsonString, index: &index) {
            return value
        }
        
        return nil
    }
    
    /**
     Function to check end of array
     
     - parameter jsonString: String representation of JSON
     - parameter index: Current index in json document
     - returns: boolean
     */
    private func endOfArrayParser(_ jsonString:String, index: inout String.Index) -> Bool? {
        guard index != jsonString.endIndex, jsonString[index] == "]" else { return nil }
        
        index = jsonString.index(after: index)
        
        return true
    }
    
    /**
     Function to check for a whitespace character
     
     - parameter character: Character to test for being a space
     - returns: boolean
     */
    private func isSpace(_ character: Character) -> Bool {
        return [" ", "\t", "\n"].contains(character)
    }
    
    /**
     Space parser
     
     Uses `isSpace` function
     
     - parameter jsonString: String representation of JSON
     - parameter index: Current index in json document
     - returns: spaces captured or nil if there was no spaces
     */
    @discardableResult
    private func spaceParser(_ jsonString: String, index: inout String.Index) -> String? {
        guard index != jsonString.endIndex, isSpace(jsonString[index]) else { return nil }
        
        let startingIndex = index
        
        while index != jsonString.endIndex {
            guard isSpace(jsonString[index]) else { break }
            
            index = jsonString.index(after: index)
        }
        
        return String(jsonString[startingIndex ..< index])
    }
    
    /**
     Function to check for a single digit
     
     - parameter character: Character to test if it is a digit
     - returns: boolean for if the character is a digit
     */
    private func isDigit(_ character: Character) -> Bool {
        return "0" ... "9" ~= character
    }
    
    /**
     Function to consume a number
     
     - parameter jsonString: String representation of JSON
     - parameter index: Current index in json document
     - returns: spaces captured or nil if there was no spaces
     */
    private func consumeNumber(_ jsonString: String, index: inout String.Index) {
        while isDigit(jsonString[index]) {
            guard jsonString.index(after: index) != jsonString.endIndex else { break }
            
            index = jsonString.index(after: index)
        }
    }
    
    /**
     Number parser
     
     This method check all json valid numbers including exponents
     
     - parameter jsonString: String representation of JSON
     - parameter index: Current index in json document
     - returns: Number value, usually either `Double` or `Int`
     - throws: `SerializationError`
     */
    private func numberParser(_ jsonString: String, index: inout String.Index) throws -> (Value & JSONStringRepresentable)? {
        let startingIndex = index
        
        // When number is negative i.e. starts with "-"
        if jsonString[startingIndex] == "-" {
            guard jsonString.index(after: index) != jsonString.endIndex else { return nil }
            
            index = jsonString.index(after: index)
        }
        
        guard isDigit(jsonString[index]) else { return nil }
        
        consumeNumber(jsonString,index: &index)
        
        // For decimal points
        if jsonString[index] == "." {
            guard jsonString.index(after: index) != jsonString.endIndex else { return nil }
            
            index = jsonString.index(after: index)
            
            guard isDigit(jsonString[index]) else {
                throw SerializationError.invalidNumberMissingFractionalElement
            }
            
            consumeNumber(jsonString,index: &index)
        }
        
        // For exponents
        if String(jsonString[index]).lowercased() == "e" {
            guard jsonString.index(after: index) != jsonString.endIndex else { return nil }
            
            index = jsonString.index(after: index)
            
            if jsonString[index] == "-" || jsonString[index] == "+" {
                index = jsonString.index(after: index)
            }
            
            guard isDigit(jsonString[index]) else {
                throw SerializationError.invalidNumberMissingExponent
            }
            
            consumeNumber(jsonString,index: &index)
        }
        
        guard let double = Double(jsonString[startingIndex ..< index]) else { return nil }
        
        return (double.truncatingRemainder(dividingBy: 1.0) == 0.0 && double <= Double(Int.max)) ? Int(double) : double
    }
    
    /**
     String parser
     
     - parameter jsonString: String representation of JSON
     - parameter index: Current index in json document
     - returns: String value that was parsed
     - throws: `SerializationError`
     */
    private func stringParser(_ jsonString: String, index: inout String.Index) throws -> String? {
        guard index != jsonString.endIndex, jsonString[index] == "\"" else { return nil }
        
        index = jsonString.index(after: index)
        let startingIndex = index
        
        while index != jsonString.endIndex {
            if jsonString[index] == "\\" {
                index = jsonString.index(after: index)
                
                if jsonString[index] == "\"" {
                    index = jsonString.index(after: index)
                } else {
                    continue
                }
            } else if jsonString[index] == "\"" {
                break
            } else {
                index = jsonString.index(after: index)
            }
        }
        
        let parsedString = String(jsonString[startingIndex ..< index])
        
        guard index != jsonString.endIndex else {
            index = startingIndex
            throw SerializationError.unterminatedString
        }
        
        index = jsonString.index(after: index)
        
        return parsedString
    }
    
    /**
     Comma parser
     
     - parameter jsonString: String representation of JSON
     - parameter index: Current index in json document
     - returns: Comma or nil if none was found
     */
    @discardableResult
    private func commaParser(_ jsonString: String, index: inout String.Index) -> String? {
        guard index != jsonString.endIndex, jsonString[index] == "," else { return nil }
        
        index = jsonString.index(after: index)
        return ","
    }
    
    /**
     Boolean parser
     
     advances the index by 4 and checks for true or by 5 and checks for false
     
     - parameter jsonString: String representation of JSON
     - parameter index: Current index in json document
     - returns: Result of boolean parser or nil if wasn't found
     */
    private func booleanParser(_ jsonString: String, index: inout String.Index) -> Bool? {
        let startingIndex = index
        
        if let advancedIndex = jsonString.index(index, offsetBy: 4, limitedBy: jsonString.endIndex) {
            index = advancedIndex
        } else {
            return nil
        }
        
        if jsonString[startingIndex ..< index] == "true" {
            return true
        }
        
        if index != jsonString.endIndex {
            index = jsonString.index(after: index)
            
            if jsonString[startingIndex ..< index]  == "false" {
                return false
            }
        }
        
        index = startingIndex
        
        return nil
    }
    
    /**
     Null parser
     
     Advances the index by 4 and checks for null
     
     - parameter jsonString: String representation of JSON
     - parameter index: Current index in json document
     - returns: Result of boolean parser or nil if wasn't found
     */
    private func nullParser(_ jsonString: String, index: inout String.Index) -> NULL? {
        let startingIndex = index
        
        if let advancedIndex = jsonString.index(index, offsetBy: 4, limitedBy: jsonString.endIndex) {
            index = advancedIndex
        } else {
            return nil
        }
        
        if jsonString[startingIndex ..< index].lowercased() == "null" {
            return NULL()
        }
        
        index = startingIndex
        
        return nil
    }
}

var jsonString = """
{
   "069673_G..S": {
      "direction": "S",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "A42": {
            "id": 0,
            "times": [
               1685202972,
               1685202972,
               1685202962,
               1685202952,
               1685202942,
               1685202932
            ],
            "scheduledTime": 1685202932,
            "scheduleAdherence": 0,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 1,
            "times": [
               1685203206,
               1685203206,
               1685203197,
               1685203182,
               1685203182,
               1685203172,
               1685203157,
               1685203147,
               1685203137,
               1685203122
            ],
            "scheduledTime": 1685203012,
            "scheduleAdherence": 81,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 2,
            "times": [
               1685203294,
               1685203294,
               1685203291,
               1685203279,
               1685203266,
               1685203254,
               1685203240,
               1685203240,
               1685203232,
               1685203217
            ],
            "scheduledTime": 1685203102,
            "scheduleAdherence": 171,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "F22": {
            "id": 3,
            "times": [
               1685203329
            ],
            "scheduledTime": 1685203192,
            "scheduleAdherence": 189,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "F23": {
            "id": 4,
            "times": [
               1685203409,
               1685203471,
               1685203459,
               1685203459,
               1685203447,
               1685203435,
               1685203423,
               1685203411,
               1685203399,
               1685203399
            ],
            "scheduledTime": 1685203282,
            "scheduleAdherence": 127,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F24": {
            "id": 5,
            "times": [
               1685203499,
               1685203561,
               1685203549,
               1685203549,
               1685203537,
               1685203525,
               1685203513,
               1685203501,
               1685203489,
               1685203489
            ],
            "scheduledTime": 1685203372,
            "scheduleAdherence": 127,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F25": {
            "id": 6,
            "times": [
               1685203589,
               1685203651,
               1685203639,
               1685203639,
               1685203627,
               1685203615,
               1685203603,
               1685203591,
               1685203579,
               1685203579
            ],
            "scheduledTime": 1685203462,
            "scheduleAdherence": 127,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F26": {
            "id": 7,
            "times": [
               1685203739,
               1685203801,
               1685203789,
               1685203789,
               1685203777,
               1685203765,
               1685203753,
               1685203741,
               1685203729,
               1685203729
            ],
            "scheduledTime": 1685203612,
            "scheduleAdherence": 127,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F27": {
            "id": 8,
            "times": [
               1685203829,
               1685203891,
               1685203879,
               1685203879,
               1685203867,
               1685203855,
               1685203843,
               1685203831,
               1685203819,
               1685203819
            ],
            "scheduledTime": 1685203702,
            "scheduleAdherence": 127,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "070650_G..S": {
      "direction": "S",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "G29": {
            "id": 0,
            "times": [
               1685202912
            ],
            "scheduledTime": 1685202912,
            "scheduleAdherence": 0,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 1,
            "times": [
               1685203003,
               1685203003,
               1685203003,
               1685202987,
               1685202977,
               1685202962,
               1685202957,
               1685202942,
               1685202932
            ],
            "scheduledTime": 1685202932,
            "scheduleAdherence": 0,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 2,
            "times": [
               1685203102,
               1685203102,
               1685203099,
               1685203082,
               1685203077,
               1685203062,
               1685203062,
               1685203052,
               1685203037,
               1685203027
            ],
            "scheduledTime": 1685203015,
            "scheduleAdherence": 54,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 3,
            "times": [
               1685203186,
               1685203177,
               1685203177,
               1685203172,
               1685203157,
               1685203147,
               1685203137,
               1685203122,
               1685203122,
               1685203107
            ],
            "scheduledTime": 1685203105,
            "scheduleAdherence": 60,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 4,
            "times": [
               1685203291,
               1685203291,
               1685203279,
               1685203266,
               1685203254,
               1685203240,
               1685203240,
               1685203232,
               1685203218,
               1685203208
            ],
            "scheduledTime": 1685203225,
            "scheduleAdherence": 36,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 5,
            "times": [
               1685203329,
               1685203316,
               1685203304,
               1685203304
            ],
            "scheduledTime": 1685203285,
            "scheduleAdherence": 72,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G35": {
            "id": 6,
            "times": [
               1685203393,
               1685203386,
               1685203386,
               1685203386,
               1685203447,
               1685203435,
               1685203423,
               1685203411,
               1685203399,
               1685203399
            ],
            "scheduledTime": 1685203375,
            "scheduleAdherence": 18,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G36": {
            "id": 7,
            "times": [
               1685203483,
               1685203476,
               1685203476,
               1685203476,
               1685203537,
               1685203525,
               1685203513,
               1685203501,
               1685203489,
               1685203489
            ],
            "scheduledTime": 1685203465,
            "scheduleAdherence": 18,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "A42": {
            "id": 8,
            "times": [
               1685203603,
               1685203596,
               1685203596,
               1685203596,
               1685203657,
               1685203645,
               1685203633,
               1685203621,
               1685203609,
               1685203609
            ],
            "scheduledTime": 1685203585,
            "scheduleAdherence": 18,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 9,
            "times": [
               1685203723,
               1685203716,
               1685203716,
               1685203716,
               1685203777,
               1685203765,
               1685203753,
               1685203741,
               1685203729,
               1685203729
            ],
            "scheduledTime": 1685203705,
            "scheduleAdherence": 18,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 10,
            "times": [
               1685203813,
               1685203806,
               1685203806,
               1685203806,
               1685203867,
               1685203855,
               1685203843,
               1685203831,
               1685203819,
               1685203819
            ],
            "scheduledTime": 1685203795,
            "scheduleAdherence": 18,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F22": {
            "id": 11,
            "times": [
               1685203903,
               1685203896,
               1685203896,
               1685203896,
               1685203957,
               1685203945,
               1685203933,
               1685203921,
               1685203909,
               1685203909
            ],
            "scheduledTime": 1685203885,
            "scheduleAdherence": 18,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F23": {
            "id": 12,
            "times": [
               1685203993,
               1685203986,
               1685203986,
               1685203986,
               1685204047,
               1685204035,
               1685204023,
               1685204011,
               1685203999,
               1685203999
            ],
            "scheduledTime": 1685203975,
            "scheduleAdherence": 18,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F24": {
            "id": 13,
            "times": [
               1685204083,
               1685204076,
               1685204076,
               1685204076,
               1685204137,
               1685204125,
               1685204113,
               1685204101,
               1685204089,
               1685204089
            ],
            "scheduledTime": 1685204065,
            "scheduleAdherence": 18,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F25": {
            "id": 14,
            "times": [
               1685204173,
               1685204166,
               1685204166,
               1685204166,
               1685204227,
               1685204215,
               1685204203,
               1685204191,
               1685204179,
               1685204179
            ],
            "scheduledTime": 1685204155,
            "scheduleAdherence": 18,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F26": {
            "id": 15,
            "times": [
               1685204323,
               1685204316,
               1685204316,
               1685204316,
               1685204377,
               1685204365,
               1685204353,
               1685204341,
               1685204329,
               1685204329
            ],
            "scheduledTime": 1685204305,
            "scheduleAdherence": 18,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F27": {
            "id": 16,
            "times": [
               1685204413,
               1685204406,
               1685204406,
               1685204406,
               1685204467,
               1685204455,
               1685204443,
               1685204431,
               1685204419,
               1685204419
            ],
            "scheduledTime": 1685204395,
            "scheduleAdherence": 18,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "069675_G..N": {
      "direction": "N",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "G35": {
            "id": 0,
            "times": [
               1685202922
            ],
            "scheduledTime": 1685202922,
            "scheduleAdherence": 0,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 1,
            "times": [
               1685203003,
               1685203003,
               1685203003,
               1685202987,
               1685202977,
               1685202962,
               1685202957,
               1685202942,
               1685202932
            ],
            "scheduledTime": 1685202932,
            "scheduleAdherence": 0,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 2,
            "times": [
               1685203067,
               1685203062,
               1685203062,
               1685203052,
               1685203037,
               1685203027,
               1685203017,
               1685203004,
               1685203004
            ],
            "scheduledTime": 1685202997,
            "scheduleAdherence": 60,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 3,
            "times": [
               1685203192,
               1685203192,
               1685203182,
               1685203182,
               1685203172,
               1685203157,
               1685203147,
               1685203137,
               1685203122,
               1685203122
            ],
            "scheduledTime": 1685203117,
            "scheduleAdherence": 36,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 4,
            "times": [
               1685203276,
               1685203276,
               1685203266,
               1685203251,
               1685203240,
               1685203240,
               1685203232,
               1685203217,
               1685203207,
               1685203197
            ],
            "scheduledTime": 1685203207,
            "scheduleAdherence": 42,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 5,
            "times": [
               1685203329,
               1685203316,
               1685203304,
               1685203304,
               1685203291,
               1685203279
            ],
            "scheduledTime": 1685203297,
            "scheduleAdherence": 36,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G29": {
            "id": 6,
            "times": [
               1685203393,
               1685203381,
               1685203369,
               1685203369,
               1685203369,
               1685203369,
               1685203423,
               1685203411,
               1685203399,
               1685203399
            ],
            "scheduledTime": 1685203387,
            "scheduleAdherence": 6,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G28": {
            "id": 7,
            "times": [
               1685203603,
               1685203591,
               1685203579,
               1685203579,
               1685203579,
               1685203579,
               1685203633,
               1685203621,
               1685203609,
               1685203609
            ],
            "scheduledTime": 1685203597,
            "scheduleAdherence": 6,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G26": {
            "id": 8,
            "times": [
               1685203693,
               1685203681,
               1685203669,
               1685203669,
               1685203669,
               1685203669,
               1685203723,
               1685203711,
               1685203699,
               1685203699
            ],
            "scheduledTime": 1685203687,
            "scheduleAdherence": 6,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G24": {
            "id": 9,
            "times": [
               1685203873,
               1685203861,
               1685203849,
               1685203849,
               1685203849,
               1685203849,
               1685203903,
               1685203891,
               1685203879,
               1685203879
            ],
            "scheduledTime": 1685203867,
            "scheduleAdherence": 6,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G22": {
            "id": 10,
            "times": [
               1685203933,
               1685203921,
               1685203909,
               1685203909,
               1685203909,
               1685203909,
               1685203963,
               1685203951,
               1685203939,
               1685203939
            ],
            "scheduledTime": 1685203927,
            "scheduleAdherence": 6,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "070710_G..N": {
      "direction": "N",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "F22": {
            "id": 0,
            "times": [
               1685202962,
               1685202962,
               1685202957,
               1685202941,
               1685202932
            ],
            "scheduledTime": 1685202932,
            "scheduleAdherence": 0,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 1,
            "times": [
               1685203092,
               1685203092,
               1685203087,
               1685203077,
               1685203057,
               1685203057,
               1685203052,
               1685203037,
               1685203027,
               1685203017
            ],
            "scheduledTime": 1685203007,
            "scheduleAdherence": 50,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 2,
            "times": [
               1685203202,
               1685203202,
               1685203197,
               1685203177,
               1685203177,
               1685203172,
               1685203157,
               1685203147,
               1685203137,
               1685203122
            ],
            "scheduledTime": 1685203097,
            "scheduleAdherence": 56,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "A42": {
            "id": 3,
            "times": [
               1685203299,
               1685203299,
               1685203291,
               1685203276,
               1685203266,
               1685203254,
               1685203240,
               1685203240,
               1685203232,
               1685203217
            ],
            "scheduledTime": 1685203217,
            "scheduleAdherence": 56,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G36": {
            "id": 4,
            "times": [
               1685203329,
               1685203313
            ],
            "scheduledTime": 1685203337,
            "scheduleAdherence": 32,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G35": {
            "id": 5,
            "times": [
               1685203403,
               1685203403,
               1685203459,
               1685203459,
               1685203447,
               1685203435,
               1685203423,
               1685203423,
               1685203423,
               1685203423
            ],
            "scheduledTime": 1685203427,
            "scheduleAdherence": -24,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 6,
            "times": [
               1685203493,
               1685203493,
               1685203549,
               1685203549,
               1685203537,
               1685203525,
               1685203513,
               1685203513,
               1685203513,
               1685203513
            ],
            "scheduledTime": 1685203517,
            "scheduleAdherence": -24,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 7,
            "times": [
               1685203553,
               1685203553,
               1685203609,
               1685203609,
               1685203597,
               1685203585,
               1685203573,
               1685203573,
               1685203573,
               1685203573
            ],
            "scheduledTime": 1685203577,
            "scheduleAdherence": -24,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 8,
            "times": [
               1685203673,
               1685203673,
               1685203729,
               1685203729,
               1685203717,
               1685203705,
               1685203693,
               1685203693,
               1685203693,
               1685203693
            ],
            "scheduledTime": 1685203697,
            "scheduleAdherence": -24,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 9,
            "times": [
               1685203763,
               1685203763,
               1685203819,
               1685203819,
               1685203807,
               1685203795,
               1685203783,
               1685203783,
               1685203783,
               1685203783
            ],
            "scheduledTime": 1685203787,
            "scheduleAdherence": -24,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 10,
            "times": [
               1685203853,
               1685203853,
               1685203909,
               1685203909,
               1685203897,
               1685203885,
               1685203873,
               1685203873,
               1685203873,
               1685203873
            ],
            "scheduledTime": 1685203877,
            "scheduleAdherence": -24,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G29": {
            "id": 11,
            "times": [
               1685203943,
               1685203943,
               1685203999,
               1685203999,
               1685203987,
               1685203975,
               1685203963,
               1685203963,
               1685203963,
               1685203963
            ],
            "scheduledTime": 1685203967,
            "scheduleAdherence": -24,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G28": {
            "id": 12,
            "times": [
               1685204153,
               1685204153,
               1685204209,
               1685204209,
               1685204197,
               1685204185,
               1685204173,
               1685204173,
               1685204173,
               1685204173
            ],
            "scheduledTime": 1685204177,
            "scheduleAdherence": -24,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G26": {
            "id": 13,
            "times": [
               1685204243,
               1685204243,
               1685204299,
               1685204299,
               1685204287,
               1685204275,
               1685204263,
               1685204263,
               1685204263,
               1685204263
            ],
            "scheduledTime": 1685204267,
            "scheduleAdherence": -24,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G24": {
            "id": 14,
            "times": [
               1685204423,
               1685204423,
               1685204479,
               1685204479,
               1685204467,
               1685204455,
               1685204443,
               1685204443,
               1685204443,
               1685204443
            ],
            "scheduledTime": 1685204447,
            "scheduleAdherence": -24,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G22": {
            "id": 15,
            "times": [
               1685204483,
               1685204483,
               1685204539,
               1685204539,
               1685204527,
               1685204515,
               1685204503,
               1685204503,
               1685204503,
               1685204503
            ],
            "scheduledTime": 1685204507,
            "scheduleAdherence": -24,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "072700_G..N": {
      "direction": "N",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "F27": {
            "id": 0,
            "times": [
               1685203620,
               1685203620,
               1685203620,
               1685203620,
               1685203620,
               1685203620,
               1685203620,
               1685203620,
               1685203620,
               1685203620
            ],
            "scheduledTime": 1685203620,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F26": {
            "id": 1,
            "times": [
               1685203710,
               1685203710,
               1685203710,
               1685203710,
               1685203710,
               1685203710,
               1685203710,
               1685203710,
               1685203710,
               1685203710
            ],
            "scheduledTime": 1685203710,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F25": {
            "id": 2,
            "times": [
               1685203860,
               1685203860,
               1685203860,
               1685203860,
               1685203860,
               1685203860,
               1685203860,
               1685203860,
               1685203860,
               1685203860
            ],
            "scheduledTime": 1685203860,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F24": {
            "id": 3,
            "times": [
               1685203950,
               1685203950,
               1685203950,
               1685203950,
               1685203950,
               1685203950,
               1685203950,
               1685203950,
               1685203950,
               1685203950
            ],
            "scheduledTime": 1685203950,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F23": {
            "id": 4,
            "times": [
               1685204070,
               1685204070,
               1685204070,
               1685204070,
               1685204070,
               1685204070,
               1685204070,
               1685204070,
               1685204070,
               1685204070
            ],
            "scheduledTime": 1685204070,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F22": {
            "id": 5,
            "times": [
               1685204160,
               1685204160,
               1685204160,
               1685204160,
               1685204160,
               1685204160,
               1685204160,
               1685204160,
               1685204160,
               1685204160
            ],
            "scheduledTime": 1685204160,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 6,
            "times": [
               1685204280,
               1685204280,
               1685204280,
               1685204280,
               1685204280,
               1685204280,
               1685204280,
               1685204280,
               1685204280,
               1685204280
            ],
            "scheduledTime": 1685204280,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 7,
            "times": [
               1685204370,
               1685204370,
               1685204370,
               1685204370,
               1685204370,
               1685204370,
               1685204370,
               1685204370,
               1685204370,
               1685204370
            ],
            "scheduledTime": 1685204370,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "A42": {
            "id": 8,
            "times": [
               1685204490,
               1685204490,
               1685204490,
               1685204490,
               1685204490,
               1685204490,
               1685204490,
               1685204490,
               1685204490,
               1685204490
            ],
            "scheduledTime": 1685204490,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G36": {
            "id": 9,
            "times": [
               1685204610,
               1685204610,
               1685204610,
               1685204610,
               1685204610,
               1685204610,
               1685204610,
               1685204610,
               1685204610,
               1685204610
            ],
            "scheduledTime": 1685204610,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G35": {
            "id": 10,
            "times": [
               1685204700,
               1685204700,
               1685204700,
               1685204700,
               1685204700,
               1685204700,
               1685204700,
               1685204700,
               1685204700,
               1685204700
            ],
            "scheduledTime": 1685204700,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 11,
            "times": [
               1685204790,
               1685204790,
               1685204790,
               1685204790,
               1685204790,
               1685204790,
               1685204790,
               1685204790,
               1685204790,
               1685204790
            ],
            "scheduledTime": 1685204790,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 12,
            "times": [
               1685204850,
               1685204850,
               1685204850,
               1685204850,
               1685204850,
               1685204850,
               1685204850,
               1685204850,
               1685204850,
               1685204850
            ],
            "scheduledTime": 1685204850,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 13,
            "times": [
               1685204970,
               1685204970,
               1685204970,
               1685204970,
               1685204970,
               1685204970,
               1685204970,
               1685204970,
               1685204970,
               1685204970
            ],
            "scheduledTime": 1685204970,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 14,
            "times": [
               1685205060,
               1685205060,
               1685205060,
               1685205060,
               1685205060,
               1685205060,
               1685205060,
               1685205060,
               1685205060,
               1685205060
            ],
            "scheduledTime": 1685205060,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 15,
            "times": [
               1685205150,
               1685205150,
               1685205150,
               1685205150,
               1685205150,
               1685205150,
               1685205150,
               1685205150,
               1685205150,
               1685205150
            ],
            "scheduledTime": 1685205150,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G29": {
            "id": 16,
            "times": [
               1685205240,
               1685205240,
               1685205240,
               1685205240,
               1685205240,
               1685205240,
               1685205240,
               1685205240,
               1685205240,
               1685205240
            ],
            "scheduledTime": 1685205240,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G28": {
            "id": 17,
            "times": [
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450
            ],
            "scheduledTime": 1685205450,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G26": {
            "id": 18,
            "times": [
               1685205540,
               1685205540,
               1685205540,
               1685205540,
               1685205540,
               1685205540,
               1685205540,
               1685205540,
               1685205540,
               1685205540
            ],
            "scheduledTime": 1685205540,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G24": {
            "id": 19,
            "times": [
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720
            ],
            "scheduledTime": 1685205720,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G22": {
            "id": 20,
            "times": [
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780
            ],
            "scheduledTime": 1685205780,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "072650_G..S": {
      "direction": "S",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "G22": {
            "id": 0,
            "times": [
               1685203590,
               1685203590,
               1685203590,
               1685203590,
               1685203590,
               1685203590,
               1685203590,
               1685203590,
               1685203590,
               1685203590
            ],
            "scheduledTime": 1685203590,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G24": {
            "id": 1,
            "times": [
               1685203650,
               1685203650,
               1685203650,
               1685203650,
               1685203650,
               1685203650,
               1685203650,
               1685203650,
               1685203650,
               1685203650
            ],
            "scheduledTime": 1685203650,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G26": {
            "id": 2,
            "times": [
               1685203830,
               1685203830,
               1685203830,
               1685203830,
               1685203830,
               1685203830,
               1685203830,
               1685203830,
               1685203830,
               1685203830
            ],
            "scheduledTime": 1685203830,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G28": {
            "id": 3,
            "times": [
               1685203920,
               1685203920,
               1685203920,
               1685203920,
               1685203920,
               1685203920,
               1685203920,
               1685203920,
               1685203920,
               1685203920
            ],
            "scheduledTime": 1685203920,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G29": {
            "id": 4,
            "times": [
               1685204130,
               1685204130,
               1685204130,
               1685204130,
               1685204130,
               1685204130,
               1685204130,
               1685204130,
               1685204130,
               1685204130
            ],
            "scheduledTime": 1685204130,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 5,
            "times": [
               1685204220,
               1685204220,
               1685204220,
               1685204220,
               1685204220,
               1685204220,
               1685204220,
               1685204220,
               1685204220,
               1685204220
            ],
            "scheduledTime": 1685204220,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 6,
            "times": [
               1685204310,
               1685204310,
               1685204310,
               1685204310,
               1685204310,
               1685204310,
               1685204310,
               1685204310,
               1685204310,
               1685204310
            ],
            "scheduledTime": 1685204310,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 7,
            "times": [
               1685204400,
               1685204400,
               1685204400,
               1685204400,
               1685204400,
               1685204400,
               1685204400,
               1685204400,
               1685204400,
               1685204400
            ],
            "scheduledTime": 1685204400,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 8,
            "times": [
               1685204520,
               1685204520,
               1685204520,
               1685204520,
               1685204520,
               1685204520,
               1685204520,
               1685204520,
               1685204520,
               1685204520
            ],
            "scheduledTime": 1685204520,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 9,
            "times": [
               1685204580,
               1685204580,
               1685204580,
               1685204580,
               1685204580,
               1685204580,
               1685204580,
               1685204580,
               1685204580,
               1685204580
            ],
            "scheduledTime": 1685204580,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G35": {
            "id": 10,
            "times": [
               1685204670,
               1685204670,
               1685204670,
               1685204670,
               1685204670,
               1685204670,
               1685204670,
               1685204670,
               1685204670,
               1685204670
            ],
            "scheduledTime": 1685204670,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G36": {
            "id": 11,
            "times": [
               1685204760,
               1685204760,
               1685204760,
               1685204760,
               1685204760,
               1685204760,
               1685204760,
               1685204760,
               1685204760,
               1685204760
            ],
            "scheduledTime": 1685204760,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "A42": {
            "id": 12,
            "times": [
               1685204880,
               1685204880,
               1685204880,
               1685204880,
               1685204880,
               1685204880,
               1685204880,
               1685204880,
               1685204880,
               1685204880
            ],
            "scheduledTime": 1685204880,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 13,
            "times": [
               1685205000,
               1685205000,
               1685205000,
               1685205000,
               1685205000,
               1685205000,
               1685205000,
               1685205000,
               1685205000,
               1685205000
            ],
            "scheduledTime": 1685205000,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 14,
            "times": [
               1685205090,
               1685205090,
               1685205090,
               1685205090,
               1685205090,
               1685205090,
               1685205090,
               1685205090,
               1685205090,
               1685205090
            ],
            "scheduledTime": 1685205090,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F22": {
            "id": 15,
            "times": [
               1685205180,
               1685205180,
               1685205180,
               1685205180,
               1685205180,
               1685205180,
               1685205180,
               1685205180,
               1685205180,
               1685205180
            ],
            "scheduledTime": 1685205180,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F23": {
            "id": 16,
            "times": [
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270
            ],
            "scheduledTime": 1685205270,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F24": {
            "id": 17,
            "times": [
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360
            ],
            "scheduledTime": 1685205360,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F25": {
            "id": 18,
            "times": [
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450
            ],
            "scheduledTime": 1685205450,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F26": {
            "id": 19,
            "times": [
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600
            ],
            "scheduledTime": 1685205600,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F27": {
            "id": 20,
            "times": [
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690
            ],
            "scheduledTime": 1685205690,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "073650_G..S": {
      "direction": "S",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "G22": {
            "id": 0,
            "times": [
               1685204190,
               1685204190,
               1685204190,
               1685204190,
               1685204190,
               1685204190,
               1685204190,
               1685204190,
               1685204190,
               1685204190
            ],
            "scheduledTime": 1685204190,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G24": {
            "id": 1,
            "times": [
               1685204250,
               1685204250,
               1685204250,
               1685204250,
               1685204250,
               1685204250,
               1685204250,
               1685204250,
               1685204250,
               1685204250
            ],
            "scheduledTime": 1685204250,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G26": {
            "id": 2,
            "times": [
               1685204430,
               1685204430,
               1685204430,
               1685204430,
               1685204430,
               1685204430,
               1685204430,
               1685204430,
               1685204430,
               1685204430
            ],
            "scheduledTime": 1685204430,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G28": {
            "id": 3,
            "times": [
               1685204520,
               1685204520,
               1685204520,
               1685204520,
               1685204520,
               1685204520,
               1685204520,
               1685204520,
               1685204520,
               1685204520
            ],
            "scheduledTime": 1685204520,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G29": {
            "id": 4,
            "times": [
               1685204730,
               1685204730,
               1685204730,
               1685204730,
               1685204730,
               1685204730,
               1685204730,
               1685204730,
               1685204730,
               1685204730
            ],
            "scheduledTime": 1685204730,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 5,
            "times": [
               1685204820,
               1685204820,
               1685204820,
               1685204820,
               1685204820,
               1685204820,
               1685204820,
               1685204820,
               1685204820,
               1685204820
            ],
            "scheduledTime": 1685204820,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 6,
            "times": [
               1685204910,
               1685204910,
               1685204910,
               1685204910,
               1685204910,
               1685204910,
               1685204910,
               1685204910,
               1685204910,
               1685204910
            ],
            "scheduledTime": 1685204910,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 7,
            "times": [
               1685205000,
               1685205000,
               1685205000,
               1685205000,
               1685205000,
               1685205000,
               1685205000,
               1685205000,
               1685205000,
               1685205000
            ],
            "scheduledTime": 1685205000,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 8,
            "times": [
               1685205120,
               1685205120,
               1685205120,
               1685205120,
               1685205120,
               1685205120,
               1685205120,
               1685205120,
               1685205120,
               1685205120
            ],
            "scheduledTime": 1685205120,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 9,
            "times": [
               1685205180,
               1685205180,
               1685205180,
               1685205180,
               1685205180,
               1685205180,
               1685205180,
               1685205180,
               1685205180,
               1685205180
            ],
            "scheduledTime": 1685205180,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G35": {
            "id": 10,
            "times": [
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270
            ],
            "scheduledTime": 1685205270,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G36": {
            "id": 11,
            "times": [
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360
            ],
            "scheduledTime": 1685205360,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "A42": {
            "id": 12,
            "times": [
               1685205480,
               1685205480,
               1685205480,
               1685205480,
               1685205480,
               1685205480,
               1685205480,
               1685205480,
               1685205480,
               1685205480
            ],
            "scheduledTime": 1685205480,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 13,
            "times": [
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600
            ],
            "scheduledTime": 1685205600,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 14,
            "times": [
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690
            ],
            "scheduledTime": 1685205690,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F22": {
            "id": 15,
            "times": [
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780
            ],
            "scheduledTime": 1685205780,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F23": {
            "id": 16,
            "times": [
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870
            ],
            "scheduledTime": 1685205870,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F24": {
            "id": 17,
            "times": [
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960
            ],
            "scheduledTime": 1685205960,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F25": {
            "id": 18,
            "times": [
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050
            ],
            "scheduledTime": 1685206050,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F26": {
            "id": 19,
            "times": [
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200
            ],
            "scheduledTime": 1685206200,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F27": {
            "id": 20,
            "times": [
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290
            ],
            "scheduledTime": 1685206290,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "073700_G..N": {
      "direction": "N",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "F27": {
            "id": 0,
            "times": [
               1685204220,
               1685204220,
               1685204220,
               1685204220,
               1685204220,
               1685204220,
               1685204220,
               1685204220,
               1685204220,
               1685204220
            ],
            "scheduledTime": 1685204220,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F26": {
            "id": 1,
            "times": [
               1685204310,
               1685204310,
               1685204310,
               1685204310,
               1685204310,
               1685204310,
               1685204310,
               1685204310,
               1685204310,
               1685204310
            ],
            "scheduledTime": 1685204310,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F25": {
            "id": 2,
            "times": [
               1685204460,
               1685204460,
               1685204460,
               1685204460,
               1685204460,
               1685204460,
               1685204460,
               1685204460,
               1685204460,
               1685204460
            ],
            "scheduledTime": 1685204460,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F24": {
            "id": 3,
            "times": [
               1685204550,
               1685204550,
               1685204550,
               1685204550,
               1685204550,
               1685204550,
               1685204550,
               1685204550,
               1685204550,
               1685204550
            ],
            "scheduledTime": 1685204550,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F23": {
            "id": 4,
            "times": [
               1685204670,
               1685204670,
               1685204670,
               1685204670,
               1685204670,
               1685204670,
               1685204670,
               1685204670,
               1685204670,
               1685204670
            ],
            "scheduledTime": 1685204670,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F22": {
            "id": 5,
            "times": [
               1685204760,
               1685204760,
               1685204760,
               1685204760,
               1685204760,
               1685204760,
               1685204760,
               1685204760,
               1685204760,
               1685204760
            ],
            "scheduledTime": 1685204760,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 6,
            "times": [
               1685204880,
               1685204880,
               1685204880,
               1685204880,
               1685204880,
               1685204880,
               1685204880,
               1685204880,
               1685204880,
               1685204880
            ],
            "scheduledTime": 1685204880,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 7,
            "times": [
               1685204970,
               1685204970,
               1685204970,
               1685204970,
               1685204970,
               1685204970,
               1685204970,
               1685204970,
               1685204970,
               1685204970
            ],
            "scheduledTime": 1685204970,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "A42": {
            "id": 8,
            "times": [
               1685205090,
               1685205090,
               1685205090,
               1685205090,
               1685205090,
               1685205090,
               1685205090,
               1685205090,
               1685205090,
               1685205090
            ],
            "scheduledTime": 1685205090,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G36": {
            "id": 9,
            "times": [
               1685205210,
               1685205210,
               1685205210,
               1685205210,
               1685205210,
               1685205210,
               1685205210,
               1685205210,
               1685205210,
               1685205210
            ],
            "scheduledTime": 1685205210,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G35": {
            "id": 10,
            "times": [
               1685205300,
               1685205300,
               1685205300,
               1685205300,
               1685205300,
               1685205300,
               1685205300,
               1685205300,
               1685205300,
               1685205300
            ],
            "scheduledTime": 1685205300,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 11,
            "times": [
               1685205390,
               1685205390,
               1685205390,
               1685205390,
               1685205390,
               1685205390,
               1685205390,
               1685205390,
               1685205390,
               1685205390
            ],
            "scheduledTime": 1685205390,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 12,
            "times": [
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450
            ],
            "scheduledTime": 1685205450,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 13,
            "times": [
               1685205570,
               1685205570,
               1685205570,
               1685205570,
               1685205570,
               1685205570,
               1685205570,
               1685205570,
               1685205570,
               1685205570
            ],
            "scheduledTime": 1685205570,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 14,
            "times": [
               1685205660,
               1685205660,
               1685205660,
               1685205660,
               1685205660,
               1685205660,
               1685205660,
               1685205660,
               1685205660,
               1685205660
            ],
            "scheduledTime": 1685205660,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 15,
            "times": [
               1685205750,
               1685205750,
               1685205750,
               1685205750,
               1685205750,
               1685205750,
               1685205750,
               1685205750,
               1685205750,
               1685205750
            ],
            "scheduledTime": 1685205750,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G29": {
            "id": 16,
            "times": [
               1685205840,
               1685205840,
               1685205840,
               1685205840,
               1685205840,
               1685205840,
               1685205840,
               1685205840,
               1685205840,
               1685205840
            ],
            "scheduledTime": 1685205840,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G28": {
            "id": 17,
            "times": [
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050
            ],
            "scheduledTime": 1685206050,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G26": {
            "id": 18,
            "times": [
               1685206140,
               1685206140,
               1685206140,
               1685206140,
               1685206140,
               1685206140,
               1685206140,
               1685206140,
               1685206140,
               1685206140
            ],
            "scheduledTime": 1685206140,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G24": {
            "id": 19,
            "times": [
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320
            ],
            "scheduledTime": 1685206320,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G22": {
            "id": 20,
            "times": [
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380
            ],
            "scheduledTime": 1685206380,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "074650_G..S": {
      "direction": "S",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "G22": {
            "id": 0,
            "times": [
               1685204790,
               1685204790,
               1685204790,
               1685204790,
               1685204790,
               1685204790,
               1685204790,
               1685204790,
               1685204790,
               1685204790
            ],
            "scheduledTime": 1685204790,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G24": {
            "id": 1,
            "times": [
               1685204850,
               1685204850,
               1685204850,
               1685204850,
               1685204850,
               1685204850,
               1685204850,
               1685204850,
               1685204850,
               1685204850
            ],
            "scheduledTime": 1685204850,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G26": {
            "id": 2,
            "times": [
               1685205030,
               1685205030,
               1685205030,
               1685205030,
               1685205030,
               1685205030,
               1685205030,
               1685205030,
               1685205030,
               1685205030
            ],
            "scheduledTime": 1685205030,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G28": {
            "id": 3,
            "times": [
               1685205120,
               1685205120,
               1685205120,
               1685205120,
               1685205120,
               1685205120,
               1685205120,
               1685205120,
               1685205120,
               1685205120
            ],
            "scheduledTime": 1685205120,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G29": {
            "id": 4,
            "times": [
               1685205330,
               1685205330,
               1685205330,
               1685205330,
               1685205330,
               1685205330,
               1685205330,
               1685205330,
               1685205330,
               1685205330
            ],
            "scheduledTime": 1685205330,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 5,
            "times": [
               1685205420,
               1685205420,
               1685205420,
               1685205420,
               1685205420,
               1685205420,
               1685205420,
               1685205420,
               1685205420,
               1685205420
            ],
            "scheduledTime": 1685205420,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 6,
            "times": [
               1685205510,
               1685205510,
               1685205510,
               1685205510,
               1685205510,
               1685205510,
               1685205510,
               1685205510,
               1685205510,
               1685205510
            ],
            "scheduledTime": 1685205510,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 7,
            "times": [
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600,
               1685205600
            ],
            "scheduledTime": 1685205600,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 8,
            "times": [
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720
            ],
            "scheduledTime": 1685205720,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 9,
            "times": [
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780,
               1685205780
            ],
            "scheduledTime": 1685205780,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G35": {
            "id": 10,
            "times": [
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870
            ],
            "scheduledTime": 1685205870,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G36": {
            "id": 11,
            "times": [
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960
            ],
            "scheduledTime": 1685205960,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "A42": {
            "id": 12,
            "times": [
               1685206080,
               1685206080,
               1685206080,
               1685206080,
               1685206080,
               1685206080,
               1685206080,
               1685206080,
               1685206080,
               1685206080
            ],
            "scheduledTime": 1685206080,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 13,
            "times": [
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200
            ],
            "scheduledTime": 1685206200,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 14,
            "times": [
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290
            ],
            "scheduledTime": 1685206290,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F22": {
            "id": 15,
            "times": [
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380
            ],
            "scheduledTime": 1685206380,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F23": {
            "id": 16,
            "times": [
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470
            ],
            "scheduledTime": 1685206470,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F24": {
            "id": 17,
            "times": [
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560
            ],
            "scheduledTime": 1685206560,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F25": {
            "id": 18,
            "times": [
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650
            ],
            "scheduledTime": 1685206650,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F26": {
            "id": 19,
            "times": [
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800
            ],
            "scheduledTime": 1685206800,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F27": {
            "id": 20,
            "times": [
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890
            ],
            "scheduledTime": 1685206890,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "074700_G..N": {
      "direction": "N",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "F27": {
            "id": 0,
            "times": [
               1685204820,
               1685204820,
               1685204820,
               1685204820,
               1685204820,
               1685204820,
               1685204820,
               1685204820,
               1685204820,
               1685204820
            ],
            "scheduledTime": 1685204820,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F26": {
            "id": 1,
            "times": [
               1685204910,
               1685204910,
               1685204910,
               1685204910,
               1685204910,
               1685204910,
               1685204910,
               1685204910,
               1685204910,
               1685204910
            ],
            "scheduledTime": 1685204910,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F25": {
            "id": 2,
            "times": [
               1685205060,
               1685205060,
               1685205060,
               1685205060,
               1685205060,
               1685205060,
               1685205060,
               1685205060,
               1685205060,
               1685205060
            ],
            "scheduledTime": 1685205060,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F24": {
            "id": 3,
            "times": [
               1685205150,
               1685205150,
               1685205150,
               1685205150,
               1685205150,
               1685205150,
               1685205150,
               1685205150,
               1685205150,
               1685205150
            ],
            "scheduledTime": 1685205150,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F23": {
            "id": 4,
            "times": [
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270,
               1685205270
            ],
            "scheduledTime": 1685205270,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F22": {
            "id": 5,
            "times": [
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360,
               1685205360
            ],
            "scheduledTime": 1685205360,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 6,
            "times": [
               1685205480,
               1685205480,
               1685205480,
               1685205480,
               1685205480,
               1685205480,
               1685205480,
               1685205480,
               1685205480,
               1685205480
            ],
            "scheduledTime": 1685205480,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 7,
            "times": [
               1685205570,
               1685205570,
               1685205570,
               1685205570,
               1685205570,
               1685205570,
               1685205570,
               1685205570,
               1685205570,
               1685205570
            ],
            "scheduledTime": 1685205570,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "A42": {
            "id": 8,
            "times": [
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690,
               1685205690
            ],
            "scheduledTime": 1685205690,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G36": {
            "id": 9,
            "times": [
               1685205810,
               1685205810,
               1685205810,
               1685205810,
               1685205810,
               1685205810,
               1685205810,
               1685205810,
               1685205810,
               1685205810
            ],
            "scheduledTime": 1685205810,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G35": {
            "id": 10,
            "times": [
               1685205900,
               1685205900,
               1685205900,
               1685205900,
               1685205900,
               1685205900,
               1685205900,
               1685205900,
               1685205900,
               1685205900
            ],
            "scheduledTime": 1685205900,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 11,
            "times": [
               1685205990,
               1685205990,
               1685205990,
               1685205990,
               1685205990,
               1685205990,
               1685205990,
               1685205990,
               1685205990,
               1685205990
            ],
            "scheduledTime": 1685205990,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 12,
            "times": [
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050
            ],
            "scheduledTime": 1685206050,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 13,
            "times": [
               1685206170,
               1685206170,
               1685206170,
               1685206170,
               1685206170,
               1685206170,
               1685206170,
               1685206170,
               1685206170,
               1685206170
            ],
            "scheduledTime": 1685206170,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 14,
            "times": [
               1685206260,
               1685206260,
               1685206260,
               1685206260,
               1685206260,
               1685206260,
               1685206260,
               1685206260,
               1685206260,
               1685206260
            ],
            "scheduledTime": 1685206260,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 15,
            "times": [
               1685206350,
               1685206350,
               1685206350,
               1685206350,
               1685206350,
               1685206350,
               1685206350,
               1685206350,
               1685206350,
               1685206350
            ],
            "scheduledTime": 1685206350,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G29": {
            "id": 16,
            "times": [
               1685206440,
               1685206440,
               1685206440,
               1685206440,
               1685206440,
               1685206440,
               1685206440,
               1685206440,
               1685206440,
               1685206440
            ],
            "scheduledTime": 1685206440,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G28": {
            "id": 17,
            "times": [
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650
            ],
            "scheduledTime": 1685206650,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G26": {
            "id": 18,
            "times": [
               1685206740,
               1685206740,
               1685206740,
               1685206740,
               1685206740,
               1685206740,
               1685206740,
               1685206740,
               1685206740,
               1685206740
            ],
            "scheduledTime": 1685206740,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G24": {
            "id": 19,
            "times": [
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920
            ],
            "scheduledTime": 1685206920,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G22": {
            "id": 20,
            "times": [
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980
            ],
            "scheduledTime": 1685206980,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "075650_G..S": {
      "direction": "S",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "G22": {
            "id": 0,
            "times": [
               1685205390,
               1685205390,
               1685205390,
               1685205390,
               1685205390,
               1685205390,
               1685205390,
               1685205390,
               1685205390,
               1685205390
            ],
            "scheduledTime": 1685205390,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G24": {
            "id": 1,
            "times": [
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450,
               1685205450
            ],
            "scheduledTime": 1685205450,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G26": {
            "id": 2,
            "times": [
               1685205630,
               1685205630,
               1685205630,
               1685205630,
               1685205630,
               1685205630,
               1685205630,
               1685205630,
               1685205630,
               1685205630
            ],
            "scheduledTime": 1685205630,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G28": {
            "id": 3,
            "times": [
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720,
               1685205720
            ],
            "scheduledTime": 1685205720,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G29": {
            "id": 4,
            "times": [
               1685205930,
               1685205930,
               1685205930,
               1685205930,
               1685205930,
               1685205930,
               1685205930,
               1685205930,
               1685205930,
               1685205930
            ],
            "scheduledTime": 1685205930,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 5,
            "times": [
               1685206020,
               1685206020,
               1685206020,
               1685206020,
               1685206020,
               1685206020,
               1685206020,
               1685206020,
               1685206020,
               1685206020
            ],
            "scheduledTime": 1685206020,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 6,
            "times": [
               1685206110,
               1685206110,
               1685206110,
               1685206110,
               1685206110,
               1685206110,
               1685206110,
               1685206110,
               1685206110,
               1685206110
            ],
            "scheduledTime": 1685206110,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 7,
            "times": [
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200,
               1685206200
            ],
            "scheduledTime": 1685206200,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 8,
            "times": [
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320
            ],
            "scheduledTime": 1685206320,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 9,
            "times": [
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380,
               1685206380
            ],
            "scheduledTime": 1685206380,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G35": {
            "id": 10,
            "times": [
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470
            ],
            "scheduledTime": 1685206470,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G36": {
            "id": 11,
            "times": [
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560
            ],
            "scheduledTime": 1685206560,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "A42": {
            "id": 12,
            "times": [
               1685206680,
               1685206680,
               1685206680,
               1685206680,
               1685206680,
               1685206680,
               1685206680,
               1685206680,
               1685206680,
               1685206680
            ],
            "scheduledTime": 1685206680,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 13,
            "times": [
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800
            ],
            "scheduledTime": 1685206800,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 14,
            "times": [
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890
            ],
            "scheduledTime": 1685206890,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F22": {
            "id": 15,
            "times": [
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980
            ],
            "scheduledTime": 1685206980,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F23": {
            "id": 16,
            "times": [
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070
            ],
            "scheduledTime": 1685207070,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F24": {
            "id": 17,
            "times": [
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160
            ],
            "scheduledTime": 1685207160,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F25": {
            "id": 18,
            "times": [
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250
            ],
            "scheduledTime": 1685207250,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F26": {
            "id": 19,
            "times": [
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400
            ],
            "scheduledTime": 1685207400,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F27": {
            "id": 20,
            "times": [
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490
            ],
            "scheduledTime": 1685207490,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "075700_G..N": {
      "direction": "N",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "F27": {
            "id": 0,
            "times": [
               1685205420,
               1685205420,
               1685205420,
               1685205420,
               1685205420,
               1685205420,
               1685205420,
               1685205420,
               1685205420,
               1685205420
            ],
            "scheduledTime": 1685205420,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F26": {
            "id": 1,
            "times": [
               1685205510,
               1685205510,
               1685205510,
               1685205510,
               1685205510,
               1685205510,
               1685205510,
               1685205510,
               1685205510,
               1685205510
            ],
            "scheduledTime": 1685205510,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F25": {
            "id": 2,
            "times": [
               1685205660,
               1685205660,
               1685205660,
               1685205660,
               1685205660,
               1685205660,
               1685205660,
               1685205660,
               1685205660,
               1685205660
            ],
            "scheduledTime": 1685205660,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F24": {
            "id": 3,
            "times": [
               1685205750,
               1685205750,
               1685205750,
               1685205750,
               1685205750,
               1685205750,
               1685205750,
               1685205750,
               1685205750,
               1685205750
            ],
            "scheduledTime": 1685205750,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F23": {
            "id": 4,
            "times": [
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870,
               1685205870
            ],
            "scheduledTime": 1685205870,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F22": {
            "id": 5,
            "times": [
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960,
               1685205960
            ],
            "scheduledTime": 1685205960,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 6,
            "times": [
               1685206080,
               1685206080,
               1685206080,
               1685206080,
               1685206080,
               1685206080,
               1685206080,
               1685206080,
               1685206080,
               1685206080
            ],
            "scheduledTime": 1685206080,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 7,
            "times": [
               1685206170,
               1685206170,
               1685206170,
               1685206170,
               1685206170,
               1685206170,
               1685206170,
               1685206170,
               1685206170,
               1685206170
            ],
            "scheduledTime": 1685206170,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "A42": {
            "id": 8,
            "times": [
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290,
               1685206290
            ],
            "scheduledTime": 1685206290,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G36": {
            "id": 9,
            "times": [
               1685206410,
               1685206410,
               1685206410,
               1685206410,
               1685206410,
               1685206410,
               1685206410,
               1685206410,
               1685206410,
               1685206410
            ],
            "scheduledTime": 1685206410,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G35": {
            "id": 10,
            "times": [
               1685206500,
               1685206500,
               1685206500,
               1685206500,
               1685206500,
               1685206500,
               1685206500,
               1685206500,
               1685206500,
               1685206500
            ],
            "scheduledTime": 1685206500,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 11,
            "times": [
               1685206590,
               1685206590,
               1685206590,
               1685206590,
               1685206590,
               1685206590,
               1685206590,
               1685206590,
               1685206590,
               1685206590
            ],
            "scheduledTime": 1685206590,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 12,
            "times": [
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650
            ],
            "scheduledTime": 1685206650,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 13,
            "times": [
               1685206770,
               1685206770,
               1685206770,
               1685206770,
               1685206770,
               1685206770,
               1685206770,
               1685206770,
               1685206770,
               1685206770
            ],
            "scheduledTime": 1685206770,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 14,
            "times": [
               1685206860,
               1685206860,
               1685206860,
               1685206860,
               1685206860,
               1685206860,
               1685206860,
               1685206860,
               1685206860,
               1685206860
            ],
            "scheduledTime": 1685206860,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 15,
            "times": [
               1685206950,
               1685206950,
               1685206950,
               1685206950,
               1685206950,
               1685206950,
               1685206950,
               1685206950,
               1685206950,
               1685206950
            ],
            "scheduledTime": 1685206950,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G29": {
            "id": 16,
            "times": [
               1685207040,
               1685207040,
               1685207040,
               1685207040,
               1685207040,
               1685207040,
               1685207040,
               1685207040,
               1685207040,
               1685207040
            ],
            "scheduledTime": 1685207040,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G28": {
            "id": 17,
            "times": [
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250
            ],
            "scheduledTime": 1685207250,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G26": {
            "id": 18,
            "times": [
               1685207340,
               1685207340,
               1685207340,
               1685207340,
               1685207340,
               1685207340,
               1685207340,
               1685207340,
               1685207340,
               1685207340
            ],
            "scheduledTime": 1685207340,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G24": {
            "id": 19,
            "times": [
               1685207520,
               1685207520,
               1685207520,
               1685207520,
               1685207520,
               1685207520,
               1685207520,
               1685207520,
               1685207520,
               1685207520
            ],
            "scheduledTime": 1685207520,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G22": {
            "id": 20,
            "times": [
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580
            ],
            "scheduledTime": 1685207580,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "076650_G..S": {
      "direction": "S",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "G22": {
            "id": 0,
            "times": [
               1685205990,
               1685205990,
               1685205990,
               1685205990,
               1685205990,
               1685205990,
               1685205990,
               1685205990,
               1685205990,
               1685205990
            ],
            "scheduledTime": 1685205990,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G24": {
            "id": 1,
            "times": [
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050,
               1685206050
            ],
            "scheduledTime": 1685206050,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G26": {
            "id": 2,
            "times": [
               1685206230,
               1685206230,
               1685206230,
               1685206230,
               1685206230,
               1685206230,
               1685206230,
               1685206230,
               1685206230,
               1685206230
            ],
            "scheduledTime": 1685206230,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G28": {
            "id": 3,
            "times": [
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320,
               1685206320
            ],
            "scheduledTime": 1685206320,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G29": {
            "id": 4,
            "times": [
               1685206530,
               1685206530,
               1685206530,
               1685206530,
               1685206530,
               1685206530,
               1685206530,
               1685206530,
               1685206530,
               1685206530
            ],
            "scheduledTime": 1685206530,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 5,
            "times": [
               1685206620,
               1685206620,
               1685206620,
               1685206620,
               1685206620,
               1685206620,
               1685206620,
               1685206620,
               1685206620,
               1685206620
            ],
            "scheduledTime": 1685206620,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 6,
            "times": [
               1685206710,
               1685206710,
               1685206710,
               1685206710,
               1685206710,
               1685206710,
               1685206710,
               1685206710,
               1685206710,
               1685206710
            ],
            "scheduledTime": 1685206710,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 7,
            "times": [
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800,
               1685206800
            ],
            "scheduledTime": 1685206800,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 8,
            "times": [
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920
            ],
            "scheduledTime": 1685206920,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 9,
            "times": [
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980,
               1685206980
            ],
            "scheduledTime": 1685206980,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G35": {
            "id": 10,
            "times": [
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070
            ],
            "scheduledTime": 1685207070,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G36": {
            "id": 11,
            "times": [
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160
            ],
            "scheduledTime": 1685207160,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "A42": {
            "id": 12,
            "times": [
               1685207280,
               1685207280,
               1685207280,
               1685207280,
               1685207280,
               1685207280,
               1685207280,
               1685207280,
               1685207280,
               1685207280
            ],
            "scheduledTime": 1685207280,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 13,
            "times": [
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400
            ],
            "scheduledTime": 1685207400,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 14,
            "times": [
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490
            ],
            "scheduledTime": 1685207490,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F22": {
            "id": 15,
            "times": [
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580
            ],
            "scheduledTime": 1685207580,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F23": {
            "id": 16,
            "times": [
               1685207670,
               1685207670,
               1685207670,
               1685207670,
               1685207670,
               1685207670,
               1685207670,
               1685207670,
               1685207670,
               1685207670
            ],
            "scheduledTime": 1685207670,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F24": {
            "id": 17,
            "times": [
               1685207760,
               1685207760,
               1685207760,
               1685207760,
               1685207760,
               1685207760,
               1685207760,
               1685207760,
               1685207760,
               1685207760
            ],
            "scheduledTime": 1685207760,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F25": {
            "id": 18,
            "times": [
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850
            ],
            "scheduledTime": 1685207850,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F26": {
            "id": 19,
            "times": [
               1685208000,
               1685208000,
               1685208000,
               1685208000,
               1685208000,
               1685208000,
               1685208000,
               1685208000,
               1685208000,
               1685208000
            ],
            "scheduledTime": 1685208000,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F27": {
            "id": 20,
            "times": [
               1685208090,
               1685208090,
               1685208090,
               1685208090,
               1685208090,
               1685208090,
               1685208090,
               1685208090,
               1685208090,
               1685208090
            ],
            "scheduledTime": 1685208090,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "076700_G..N": {
      "direction": "N",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "F27": {
            "id": 0,
            "times": [
               1685206020,
               1685206020,
               1685206020,
               1685206020,
               1685206020,
               1685206020,
               1685206020,
               1685206020,
               1685206020,
               1685206020
            ],
            "scheduledTime": 1685206020,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F26": {
            "id": 1,
            "times": [
               1685206110,
               1685206110,
               1685206110,
               1685206110,
               1685206110,
               1685206110,
               1685206110,
               1685206110,
               1685206110,
               1685206110
            ],
            "scheduledTime": 1685206110,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F25": {
            "id": 2,
            "times": [
               1685206260,
               1685206260,
               1685206260,
               1685206260,
               1685206260,
               1685206260,
               1685206260,
               1685206260,
               1685206260,
               1685206260
            ],
            "scheduledTime": 1685206260,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F24": {
            "id": 3,
            "times": [
               1685206350,
               1685206350,
               1685206350,
               1685206350,
               1685206350,
               1685206350,
               1685206350,
               1685206350,
               1685206350,
               1685206350
            ],
            "scheduledTime": 1685206350,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F23": {
            "id": 4,
            "times": [
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470,
               1685206470
            ],
            "scheduledTime": 1685206470,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F22": {
            "id": 5,
            "times": [
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560,
               1685206560
            ],
            "scheduledTime": 1685206560,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 6,
            "times": [
               1685206680,
               1685206680,
               1685206680,
               1685206680,
               1685206680,
               1685206680,
               1685206680,
               1685206680,
               1685206680,
               1685206680
            ],
            "scheduledTime": 1685206680,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 7,
            "times": [
               1685206770,
               1685206770,
               1685206770,
               1685206770,
               1685206770,
               1685206770,
               1685206770,
               1685206770,
               1685206770,
               1685206770
            ],
            "scheduledTime": 1685206770,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "A42": {
            "id": 8,
            "times": [
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890,
               1685206890
            ],
            "scheduledTime": 1685206890,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G36": {
            "id": 9,
            "times": [
               1685207010,
               1685207010,
               1685207010,
               1685207010,
               1685207010,
               1685207010,
               1685207010,
               1685207010,
               1685207010,
               1685207010
            ],
            "scheduledTime": 1685207010,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G35": {
            "id": 10,
            "times": [
               1685207100,
               1685207100,
               1685207100,
               1685207100,
               1685207100,
               1685207100,
               1685207100,
               1685207100,
               1685207100,
               1685207100
            ],
            "scheduledTime": 1685207100,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 11,
            "times": [
               1685207190,
               1685207190,
               1685207190,
               1685207190,
               1685207190,
               1685207190,
               1685207190,
               1685207190,
               1685207190,
               1685207190
            ],
            "scheduledTime": 1685207190,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 12,
            "times": [
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250,
               1685207250
            ],
            "scheduledTime": 1685207250,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 13,
            "times": [
               1685207370,
               1685207370,
               1685207370,
               1685207370,
               1685207370,
               1685207370,
               1685207370,
               1685207370,
               1685207370,
               1685207370
            ],
            "scheduledTime": 1685207370,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 14,
            "times": [
               1685207460,
               1685207460,
               1685207460,
               1685207460,
               1685207460,
               1685207460,
               1685207460,
               1685207460,
               1685207460,
               1685207460
            ],
            "scheduledTime": 1685207460,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 15,
            "times": [
               1685207550,
               1685207550,
               1685207550,
               1685207550,
               1685207550,
               1685207550,
               1685207550,
               1685207550,
               1685207550,
               1685207550
            ],
            "scheduledTime": 1685207550,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G29": {
            "id": 16,
            "times": [
               1685207640,
               1685207640,
               1685207640,
               1685207640,
               1685207640,
               1685207640,
               1685207640,
               1685207640,
               1685207640,
               1685207640
            ],
            "scheduledTime": 1685207640,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G28": {
            "id": 17,
            "times": [
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850
            ],
            "scheduledTime": 1685207850,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G26": {
            "id": 18,
            "times": [
               1685207940,
               1685207940,
               1685207940,
               1685207940,
               1685207940,
               1685207940,
               1685207940,
               1685207940,
               1685207940,
               1685207940
            ],
            "scheduledTime": 1685207940,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G24": {
            "id": 19,
            "times": [
               1685208120,
               1685208120,
               1685208120,
               1685208120,
               1685208120,
               1685208120,
               1685208120,
               1685208120,
               1685208120,
               1685208120
            ],
            "scheduledTime": 1685208120,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G22": {
            "id": 20,
            "times": [
               1685208180,
               1685208180,
               1685208180,
               1685208180,
               1685208180,
               1685208180,
               1685208180,
               1685208180,
               1685208180,
               1685208180
            ],
            "scheduledTime": 1685208180,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "071605_G..S": {
      "direction": "S",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "G22": {
            "id": 0,
            "times": [
               1685202993,
               1685202993,
               1685202993,
               1685202978,
               1685202963
            ],
            "scheduledTime": 1685202963,
            "scheduleAdherence": 0,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G24": {
            "id": 1,
            "times": [
               1685203081,
               1685203077,
               1685203057,
               1685203057,
               1685203052,
               1685203037,
               1685203027,
               1685203017,
               1685202997,
               1685202997
            ],
            "scheduledTime": 1685203033,
            "scheduleAdherence": 24,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G26": {
            "id": 2,
            "times": [
               1685203245,
               1685203236,
               1685203236,
               1685203232,
               1685203217,
               1685203207,
               1685203197,
               1685203182,
               1685203182,
               1685203167
            ],
            "scheduledTime": 1685203213,
            "scheduleAdherence": -12,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G28": {
            "id": 3,
            "times": [
               1685203329,
               1685203316,
               1685203304,
               1685203304,
               1685203291,
               1685203279,
               1685203266
            ],
            "scheduledTime": 1685203303,
            "scheduleAdherence": 18,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "G29": {
            "id": 4,
            "times": [
               1685203475,
               1685203475,
               1685203475,
               1685203475,
               1685203475,
               1685203475,
               1685203475,
               1685203531,
               1685203519,
               1685203519
            ],
            "scheduledTime": 1685203513,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 5,
            "times": [
               1685203565,
               1685203565,
               1685203565,
               1685203565,
               1685203565,
               1685203565,
               1685203565,
               1685203621,
               1685203609,
               1685203609
            ],
            "scheduledTime": 1685203603,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 6,
            "times": [
               1685203655,
               1685203655,
               1685203655,
               1685203655,
               1685203655,
               1685203655,
               1685203655,
               1685203711,
               1685203699,
               1685203699
            ],
            "scheduledTime": 1685203693,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 7,
            "times": [
               1685203745,
               1685203745,
               1685203745,
               1685203745,
               1685203745,
               1685203745,
               1685203745,
               1685203801,
               1685203789,
               1685203789
            ],
            "scheduledTime": 1685203783,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 8,
            "times": [
               1685203865,
               1685203865,
               1685203865,
               1685203865,
               1685203865,
               1685203865,
               1685203865,
               1685203921,
               1685203909,
               1685203909
            ],
            "scheduledTime": 1685203903,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 9,
            "times": [
               1685203925,
               1685203925,
               1685203925,
               1685203925,
               1685203925,
               1685203925,
               1685203925,
               1685203981,
               1685203969,
               1685203969
            ],
            "scheduledTime": 1685203963,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G35": {
            "id": 10,
            "times": [
               1685204015,
               1685204015,
               1685204015,
               1685204015,
               1685204015,
               1685204015,
               1685204015,
               1685204071,
               1685204059,
               1685204059
            ],
            "scheduledTime": 1685204053,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G36": {
            "id": 11,
            "times": [
               1685204105,
               1685204105,
               1685204105,
               1685204105,
               1685204105,
               1685204105,
               1685204105,
               1685204161,
               1685204149,
               1685204149
            ],
            "scheduledTime": 1685204143,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "A42": {
            "id": 12,
            "times": [
               1685204225,
               1685204225,
               1685204225,
               1685204225,
               1685204225,
               1685204225,
               1685204225,
               1685204281,
               1685204269,
               1685204269
            ],
            "scheduledTime": 1685204263,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 13,
            "times": [
               1685204345,
               1685204345,
               1685204345,
               1685204345,
               1685204345,
               1685204345,
               1685204345,
               1685204401,
               1685204389,
               1685204389
            ],
            "scheduledTime": 1685204383,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 14,
            "times": [
               1685204435,
               1685204435,
               1685204435,
               1685204435,
               1685204435,
               1685204435,
               1685204435,
               1685204491,
               1685204479,
               1685204479
            ],
            "scheduledTime": 1685204473,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F22": {
            "id": 15,
            "times": [
               1685204525,
               1685204525,
               1685204525,
               1685204525,
               1685204525,
               1685204525,
               1685204525,
               1685204581,
               1685204569,
               1685204569
            ],
            "scheduledTime": 1685204563,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F23": {
            "id": 16,
            "times": [
               1685204615,
               1685204615,
               1685204615,
               1685204615,
               1685204615,
               1685204615,
               1685204615,
               1685204671,
               1685204659,
               1685204659
            ],
            "scheduledTime": 1685204653,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F24": {
            "id": 17,
            "times": [
               1685204705,
               1685204705,
               1685204705,
               1685204705,
               1685204705,
               1685204705,
               1685204705,
               1685204761,
               1685204749,
               1685204749
            ],
            "scheduledTime": 1685204743,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F25": {
            "id": 18,
            "times": [
               1685204795,
               1685204795,
               1685204795,
               1685204795,
               1685204795,
               1685204795,
               1685204795,
               1685204851,
               1685204839,
               1685204839
            ],
            "scheduledTime": 1685204833,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F26": {
            "id": 19,
            "times": [
               1685204945,
               1685204945,
               1685204945,
               1685204945,
               1685204945,
               1685204945,
               1685204945,
               1685205001,
               1685204989,
               1685204989
            ],
            "scheduledTime": 1685204983,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F27": {
            "id": 20,
            "times": [
               1685205035,
               1685205035,
               1685205035,
               1685205035,
               1685205035,
               1685205035,
               1685205035,
               1685205091,
               1685205079,
               1685205079
            ],
            "scheduledTime": 1685205073,
            "scheduleAdherence": -38,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "077650_G..S": {
      "direction": "S",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "G22": {
            "id": 0,
            "times": [
               1685206590,
               1685206590,
               1685206590,
               1685206590,
               1685206590,
               1685206590,
               1685206590,
               1685206590,
               1685206590,
               1685206590
            ],
            "scheduledTime": 1685206590,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G24": {
            "id": 1,
            "times": [
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650,
               1685206650
            ],
            "scheduledTime": 1685206650,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G26": {
            "id": 2,
            "times": [
               1685206830,
               1685206830,
               1685206830,
               1685206830,
               1685206830,
               1685206830,
               1685206830,
               1685206830,
               1685206830,
               1685206830
            ],
            "scheduledTime": 1685206830,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G28": {
            "id": 3,
            "times": [
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920,
               1685206920
            ],
            "scheduledTime": 1685206920,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G29": {
            "id": 4,
            "times": [
               1685207130,
               1685207130,
               1685207130,
               1685207130,
               1685207130,
               1685207130,
               1685207130,
               1685207130,
               1685207130,
               1685207130
            ],
            "scheduledTime": 1685207130,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 5,
            "times": [
               1685207220,
               1685207220,
               1685207220,
               1685207220,
               1685207220,
               1685207220,
               1685207220,
               1685207220,
               1685207220,
               1685207220
            ],
            "scheduledTime": 1685207220,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 6,
            "times": [
               1685207310,
               1685207310,
               1685207310,
               1685207310,
               1685207310,
               1685207310,
               1685207310,
               1685207310,
               1685207310,
               1685207310
            ],
            "scheduledTime": 1685207310,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 7,
            "times": [
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400,
               1685207400
            ],
            "scheduledTime": 1685207400,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 8,
            "times": [
               1685207520,
               1685207520,
               1685207520,
               1685207520,
               1685207520,
               1685207520,
               1685207520,
               1685207520,
               1685207520,
               1685207520
            ],
            "scheduledTime": 1685207520,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 9,
            "times": [
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580,
               1685207580
            ],
            "scheduledTime": 1685207580,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G35": {
            "id": 10,
            "times": [
               1685207670,
               1685207670,
               1685207670,
               1685207670,
               1685207670,
               1685207670,
               1685207670,
               1685207670,
               1685207670,
               1685207670
            ],
            "scheduledTime": 1685207670,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G36": {
            "id": 11,
            "times": [
               1685207760,
               1685207760,
               1685207760,
               1685207760,
               1685207760,
               1685207760,
               1685207760,
               1685207760,
               1685207760,
               1685207760
            ],
            "scheduledTime": 1685207760,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "A42": {
            "id": 12,
            "times": [
               1685207880,
               1685207880,
               1685207880,
               1685207880,
               1685207880,
               1685207880,
               1685207880,
               1685207880,
               1685207880,
               1685207880
            ],
            "scheduledTime": 1685207880,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 13,
            "times": [
               1685208000,
               1685208000,
               1685208000,
               1685208000,
               1685208000,
               1685208000,
               1685208000,
               1685208000,
               1685208000,
               1685208000
            ],
            "scheduledTime": 1685208000,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 14,
            "times": [
               1685208090,
               1685208090,
               1685208090,
               1685208090,
               1685208090,
               1685208090,
               1685208090,
               1685208090,
               1685208090,
               1685208090
            ],
            "scheduledTime": 1685208090,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F22": {
            "id": 15,
            "times": [
               1685208180,
               1685208180,
               1685208180,
               1685208180,
               1685208180,
               1685208180,
               1685208180,
               1685208180,
               1685208180,
               1685208180
            ],
            "scheduledTime": 1685208180,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F23": {
            "id": 16,
            "times": [
               1685208270,
               1685208270,
               1685208270,
               1685208270,
               1685208270,
               1685208270,
               1685208270,
               1685208270,
               1685208270,
               1685208270
            ],
            "scheduledTime": 1685208270,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F24": {
            "id": 17,
            "times": [
               1685208360,
               1685208360,
               1685208360,
               1685208360,
               1685208360,
               1685208360,
               1685208360,
               1685208360,
               1685208360,
               1685208360
            ],
            "scheduledTime": 1685208360,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F25": {
            "id": 18,
            "times": [
               1685208450,
               1685208450,
               1685208450,
               1685208450,
               1685208450,
               1685208450,
               1685208450,
               1685208450,
               1685208450,
               1685208450
            ],
            "scheduledTime": 1685208450,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F26": {
            "id": 19,
            "times": [
               1685208600,
               1685208600,
               1685208600,
               1685208600,
               1685208600,
               1685208600,
               1685208600,
               1685208600,
               1685208600,
               1685208600
            ],
            "scheduledTime": 1685208600,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F27": {
            "id": 20,
            "times": [
               1685208690,
               1685208690,
               1685208690,
               1685208690,
               1685208690,
               1685208690,
               1685208690,
               1685208690,
               1685208690,
               1685208690
            ],
            "scheduledTime": 1685208690,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "071691_G..N": {
      "direction": "N",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "F27": {
            "id": 0,
            "times": [
               1685203027,
               1685203027,
               1685203018
            ],
            "scheduledTime": 1685203018,
            "scheduleAdherence": 0,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "F26": {
            "id": 1,
            "times": [
               1685203127,
               1685203117,
               1685203117,
               1685203112,
               1685203099,
               1685203087,
               1685203077,
               1685203062,
               1685203062,
               1685203053
            ],
            "scheduledTime": 1685203108,
            "scheduleAdherence": 0,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "F25": {
            "id": 2,
            "times": [
               1685203272,
               1685203272,
               1685203264,
               1685203254,
               1685203240,
               1685203240,
               1685203232,
               1685203217,
               1685203207,
               1685203197
            ],
            "scheduledTime": 1685203258,
            "scheduleAdherence": -21,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "F24": {
            "id": 3,
            "times": [
               1685203329,
               1685203316,
               1685203304,
               1685203304
            ],
            "scheduledTime": 1685203348,
            "scheduleAdherence": 9,
            "isCompleted": true,
            "inNormalStopSequence": true
         },
         "F23": {
            "id": 4,
            "times": [
               1685203416,
               1685203416,
               1685203416,
               1685203416,
               1685203477,
               1685203465,
               1685203453,
               1685203441,
               1685203429,
               1685203429
            ],
            "scheduledTime": 1685203468,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F22": {
            "id": 5,
            "times": [
               1685203506,
               1685203506,
               1685203506,
               1685203506,
               1685203567,
               1685203555,
               1685203543,
               1685203531,
               1685203519,
               1685203519
            ],
            "scheduledTime": 1685203558,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 6,
            "times": [
               1685203626,
               1685203626,
               1685203626,
               1685203626,
               1685203687,
               1685203675,
               1685203663,
               1685203651,
               1685203639,
               1685203639
            ],
            "scheduledTime": 1685203678,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 7,
            "times": [
               1685203716,
               1685203716,
               1685203716,
               1685203716,
               1685203777,
               1685203765,
               1685203753,
               1685203741,
               1685203729,
               1685203729
            ],
            "scheduledTime": 1685203768,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "A42": {
            "id": 8,
            "times": [
               1685203836,
               1685203836,
               1685203836,
               1685203836,
               1685203897,
               1685203885,
               1685203873,
               1685203861,
               1685203849,
               1685203849
            ],
            "scheduledTime": 1685203888,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G36": {
            "id": 9,
            "times": [
               1685203956,
               1685203956,
               1685203956,
               1685203956,
               1685204017,
               1685204005,
               1685203993,
               1685203981,
               1685203969,
               1685203969
            ],
            "scheduledTime": 1685204008,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G35": {
            "id": 10,
            "times": [
               1685204046,
               1685204046,
               1685204046,
               1685204046,
               1685204107,
               1685204095,
               1685204083,
               1685204071,
               1685204059,
               1685204059
            ],
            "scheduledTime": 1685204098,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 11,
            "times": [
               1685204136,
               1685204136,
               1685204136,
               1685204136,
               1685204197,
               1685204185,
               1685204173,
               1685204161,
               1685204149,
               1685204149
            ],
            "scheduledTime": 1685204188,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 12,
            "times": [
               1685204196,
               1685204196,
               1685204196,
               1685204196,
               1685204257,
               1685204245,
               1685204233,
               1685204221,
               1685204209,
               1685204209
            ],
            "scheduledTime": 1685204248,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 13,
            "times": [
               1685204316,
               1685204316,
               1685204316,
               1685204316,
               1685204377,
               1685204365,
               1685204353,
               1685204341,
               1685204329,
               1685204329
            ],
            "scheduledTime": 1685204368,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 14,
            "times": [
               1685204406,
               1685204406,
               1685204406,
               1685204406,
               1685204467,
               1685204455,
               1685204443,
               1685204431,
               1685204419,
               1685204419
            ],
            "scheduledTime": 1685204458,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 15,
            "times": [
               1685204496,
               1685204496,
               1685204496,
               1685204496,
               1685204557,
               1685204545,
               1685204533,
               1685204521,
               1685204509,
               1685204509
            ],
            "scheduledTime": 1685204548,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G29": {
            "id": 16,
            "times": [
               1685204586,
               1685204586,
               1685204586,
               1685204586,
               1685204647,
               1685204635,
               1685204623,
               1685204611,
               1685204599,
               1685204599
            ],
            "scheduledTime": 1685204638,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G28": {
            "id": 17,
            "times": [
               1685204796,
               1685204796,
               1685204796,
               1685204796,
               1685204857,
               1685204845,
               1685204833,
               1685204821,
               1685204809,
               1685204809
            ],
            "scheduledTime": 1685204848,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G26": {
            "id": 18,
            "times": [
               1685204886,
               1685204886,
               1685204886,
               1685204886,
               1685204947,
               1685204935,
               1685204923,
               1685204911,
               1685204899,
               1685204899
            ],
            "scheduledTime": 1685204938,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G24": {
            "id": 19,
            "times": [
               1685205066,
               1685205066,
               1685205066,
               1685205066,
               1685205127,
               1685205115,
               1685205103,
               1685205091,
               1685205079,
               1685205079
            ],
            "scheduledTime": 1685205118,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G22": {
            "id": 20,
            "times": [
               1685205126,
               1685205126,
               1685205126,
               1685205126,
               1685205187,
               1685205175,
               1685205163,
               1685205151,
               1685205139,
               1685205139
            ],
            "scheduledTime": 1685205178,
            "scheduleAdherence": -52,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   },
   "077700_G..N": {
      "direction": "N",
      "line": "G",
      "serviceDisruptions": {
         "delays": [],
         "reroutes": []
      },
      "stations": {
         "F27": {
            "id": 0,
            "times": [
               1685206620,
               1685206620,
               1685206620,
               1685206620,
               1685206620,
               1685206620,
               1685206620,
               1685206620,
               1685206620,
               1685206620
            ],
            "scheduledTime": 1685206620,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F26": {
            "id": 1,
            "times": [
               1685206710,
               1685206710,
               1685206710,
               1685206710,
               1685206710,
               1685206710,
               1685206710,
               1685206710,
               1685206710,
               1685206710
            ],
            "scheduledTime": 1685206710,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F25": {
            "id": 2,
            "times": [
               1685206860,
               1685206860,
               1685206860,
               1685206860,
               1685206860,
               1685206860,
               1685206860,
               1685206860,
               1685206860,
               1685206860
            ],
            "scheduledTime": 1685206860,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F24": {
            "id": 3,
            "times": [
               1685206950,
               1685206950,
               1685206950,
               1685206950,
               1685206950,
               1685206950,
               1685206950,
               1685206950,
               1685206950,
               1685206950
            ],
            "scheduledTime": 1685206950,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F23": {
            "id": 4,
            "times": [
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070,
               1685207070
            ],
            "scheduledTime": 1685207070,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F22": {
            "id": 5,
            "times": [
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160,
               1685207160
            ],
            "scheduledTime": 1685207160,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F21": {
            "id": 6,
            "times": [
               1685207280,
               1685207280,
               1685207280,
               1685207280,
               1685207280,
               1685207280,
               1685207280,
               1685207280,
               1685207280,
               1685207280
            ],
            "scheduledTime": 1685207280,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "F20": {
            "id": 7,
            "times": [
               1685207370,
               1685207370,
               1685207370,
               1685207370,
               1685207370,
               1685207370,
               1685207370,
               1685207370,
               1685207370,
               1685207370
            ],
            "scheduledTime": 1685207370,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "A42": {
            "id": 8,
            "times": [
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490,
               1685207490
            ],
            "scheduledTime": 1685207490,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G36": {
            "id": 9,
            "times": [
               1685207610,
               1685207610,
               1685207610,
               1685207610,
               1685207610,
               1685207610,
               1685207610,
               1685207610,
               1685207610,
               1685207610
            ],
            "scheduledTime": 1685207610,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G35": {
            "id": 10,
            "times": [
               1685207700,
               1685207700,
               1685207700,
               1685207700,
               1685207700,
               1685207700,
               1685207700,
               1685207700,
               1685207700,
               1685207700
            ],
            "scheduledTime": 1685207700,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G34": {
            "id": 11,
            "times": [
               1685207790,
               1685207790,
               1685207790,
               1685207790,
               1685207790,
               1685207790,
               1685207790,
               1685207790,
               1685207790,
               1685207790
            ],
            "scheduledTime": 1685207790,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G33": {
            "id": 12,
            "times": [
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850,
               1685207850
            ],
            "scheduledTime": 1685207850,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G32": {
            "id": 13,
            "times": [
               1685207970,
               1685207970,
               1685207970,
               1685207970,
               1685207970,
               1685207970,
               1685207970,
               1685207970,
               1685207970,
               1685207970
            ],
            "scheduledTime": 1685207970,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G31": {
            "id": 14,
            "times": [
               1685208060,
               1685208060,
               1685208060,
               1685208060,
               1685208060,
               1685208060,
               1685208060,
               1685208060,
               1685208060,
               1685208060
            ],
            "scheduledTime": 1685208060,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G30": {
            "id": 15,
            "times": [
               1685208150,
               1685208150,
               1685208150,
               1685208150,
               1685208150,
               1685208150,
               1685208150,
               1685208150,
               1685208150,
               1685208150
            ],
            "scheduledTime": 1685208150,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G29": {
            "id": 16,
            "times": [
               1685208240,
               1685208240,
               1685208240,
               1685208240,
               1685208240,
               1685208240,
               1685208240,
               1685208240,
               1685208240,
               1685208240
            ],
            "scheduledTime": 1685208240,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G28": {
            "id": 17,
            "times": [
               1685208450,
               1685208450,
               1685208450,
               1685208450,
               1685208450,
               1685208450,
               1685208450,
               1685208450,
               1685208450,
               1685208450
            ],
            "scheduledTime": 1685208450,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G26": {
            "id": 18,
            "times": [
               1685208540,
               1685208540,
               1685208540,
               1685208540,
               1685208540,
               1685208540,
               1685208540,
               1685208540,
               1685208540,
               1685208540
            ],
            "scheduledTime": 1685208540,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G24": {
            "id": 19,
            "times": [
               1685208720,
               1685208720,
               1685208720,
               1685208720,
               1685208720,
               1685208720,
               1685208720,
               1685208720,
               1685208720,
               1685208720
            ],
            "scheduledTime": 1685208720,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         },
         "G22": {
            "id": 20,
            "times": [
               1685208780,
               1685208780,
               1685208780,
               1685208780,
               1685208780,
               1685208780,
               1685208780,
               1685208780,
               1685208780,
               1685208780
            ],
            "scheduledTime": 1685208780,
            "scheduleAdherence": 0,
            "isCompleted": false,
            "inNormalStopSequence": true
         }
      }
   }
}
"""
