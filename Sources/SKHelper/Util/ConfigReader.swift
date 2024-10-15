//
//  ConfigReader.swift
//  SKHelper
//
//  Created by Russell Archer on 15/10/2024.
//

import Foundation

/// Reads values from a property list file using keys.
///
/// Example usage:
/// ```
/// color = ConfigReader.value(for: "color", in: "Config") ?? "Unknown"
/// ```
///
public class ConfigReader {
    /// The dictionary of values read from the propert list file.
    static private var plistFileDictionary: [String : AnyObject] = [:]
    static private var mruFile = ""
    
    /// Read a property from a dictionary of values that is read from a .plist file.
    /// - Parameters:
    ///   - key: The value's key.
    ///   - file: The property list file to read values from
    /// - Returns: Returns a property from a dictionary of values that is read from a .plist file.
    static public func value(for key: String, in file: String) -> String? {
        if plistFileDictionary.isEmpty || mruFile != file { plistFileDictionary = ConfigReader.readPlistFile(filename: file) }
        if let val = plistFileDictionary[key] as? String { return val }
        return nil
    }
    
    /// Reads a property list file and returns a dictionary of values.
    /// - Parameter filename: The property list to read values from.
    /// - Returns: Returns returns a dictionary of values read from a .plist file.
    static private func readPlistFile(filename: String) -> [String : AnyObject] {
        mruFile = filename
        if let path = Bundle.main.path(forResource: filename, ofType: "plist") {
            if let contents = NSDictionary(contentsOfFile: path) as? [String : AnyObject] { return contents }
        }
        
        return [:]
    }
}
