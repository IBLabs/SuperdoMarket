//
//  GroceryItem.swift
//  SuperdoMarket
//
//  Created by Itamar Biton on 20/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import Foundation

class GroceryItem {
    var name: String = ""       // name of the item
    var weight: String = ""     // weight of the item
    var bagColor: String = ""   // the item's bag color (in hex, prefixed with a #)

    /**
     Initializes a new grocery item.
     
     - Parameter name: The item's name
     - Parameter weight: The item's weight (in kilograms)
     - Parameter bagColor: The item's bag color (in hex, prefixed with a #)
    */
    init(name: String, weight: String, bagColor: String) {
        self.name = name
        self.weight = weight
        self.bagColor = bagColor
    }
    
    /**
     Initializes a new grocery item using a JSON string
     
     - Parameter json: A JSON foramtted string
     */
    convenience init(jsonString: String) throws {
        // try and convert the recieved JSON string to data
        guard let data = jsonString.data(using: .utf8) else {
            throw GroceryItemError.parsingError(string: "Failed parsing the received JSON data")
        }
        
        // try to parse the JSON data to a json object
        do {
            if let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? Dictionary<String, Any> {
                // get the information from the dictionary
                let name = jsonDictionary["name"] as! String
                let weight = jsonDictionary["weight"] as! String
                let bagColor = jsonDictionary["bagColor"] as! String
                
                // initialize
                self.init(name: name, weight: weight, bagColor: bagColor)
            } else {
                throw GroceryItemError.parsingError(string: "Failed parsing the received JSON data")
            }
        } catch {
            throw GroceryItemError.parsingError(string: "Failed parsing the received JSON data")
        }
    }
    
    enum GroceryItemError: Error {
        case parsingError(string: String)
    }
}
