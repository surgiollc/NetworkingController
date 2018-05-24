//
//  JSONResource.swift
//  NetworkingController
//
//  Created by Chandler De Angelis on 4/7/18.
//  Copyright © 2018 Chandler De Angelis. All rights reserved.
//

import Foundation

public enum JSONResourceError: Error {
    case notASJSONAPIResource
    case wrongType(String)
    case missingAttribute(String)
    
    public var localizedDescription: String {
        switch self {
        case .notASJSONAPIResource:
            return "Not a JSONAPI Resource"
        case .wrongType(let type):
            return "Unexpected resource type: \(type)"
        case .missingAttribute(let attribute):
            return "Missing attribute \(attribute)"
        }
    }
}

public struct JSONResource: JSONAPIResource {
    
    public typealias RelatedObject = (ID: Int, type: String)
    
    public struct Relationship: Collection {
        
        public let key: String
        
        private var dataArray: [JSONObject] {
            var result: [JSONObject] = []
            if let data: JSON = self.json["data"] {
                if let object: JSONObject = data as? JSONObject {
                    result.append(object)
                } else if let objectArray: [JSONObject] = data as? [JSONObject] {
                    result.append(contentsOf: objectArray)
                }
            }
            return result
        }
    
        public var objects: [RelatedObject] {
            var result: [RelatedObject] = []
            for data in self.dataArray {
                if let id: Int = data["id"].flatMap(toJSONInt),
                    let type: String = data["type"].flatMap(toJSONString) {
                    result.append((id, type))
                } else {
                    continue
                }
            }
            return result
        }
        
        private let json: JSONObject
        
        init(key: String, json: JSONObject) {
            self.key = key
            self.json = json
        }
        
        public var startIndex: Int {
            return self.objects.startIndex
        }
        
        public var endIndex: Int {
            return self.objects.endIndex
        }
        
        public func index(after i: Int) -> Int {
            return self.objects.index(after: i)
        }
        
        public subscript(_ index: Int) -> RelatedObject {
            return self.objects[index]
        }
    }
    
    public subscript(relationship rel: String) -> Relationship? {
        return self.relationships.first(where: { $0.key == rel })
    }
    
    public subscript<T>(attribute attr: String) -> T? {
        return self.attributes?[attr] as? T
    }
    
    public let json: JSONObject
    private let numberFormatter: NumberFormatter = NumberFormatter()
    
    public init(ID: Int? = nil, type: String, attributes: JSONObject? = nil, relationships: [String: JSONObject]? = nil) {
        var newJson: JSONObject = ["type": type]
        if let ID: Int = ID {
            newJson["id"] = ID
        }
        if let attrs: JSONObject = attributes {
            newJson["attributes"] = attrs
        }
        if let relationships: [String: JSONObject] = relationships {
            newJson["relationships"] = relationships
        }
        self.json = newJson
    }
    
    public init(json: JSONObject) {
        self.json = json
    }
    
    public var ID: Int? {
        return self["id"].flatMap(toJSONInt)
    }
    
    public var type: String? {
        return self["type"].flatMap(toJSONString)
    }
    
    public var links: JSONObject? {
        return self["links"].flatMap(toJSONObject)
    }
    
    public var attributes: JSONObject? {
        return self["attributes"].flatMap(toJSONObject)
    }
    
    public var relationships: [Relationship] {
        guard let relationships: JSONObject = self["relationships"] as? JSONObject else {
            return []
        }
        var result: [Relationship] = []
        for (key, value) in relationships where value is JSONObject {
            let rel: Relationship = Relationship(key: key, json: value as! JSONObject)
            result.append(rel)
        }
        return result
    }
    
    public func relatedResources(in document: JSONDocument) -> [JSONResource] {
        var result: [JSONResource] = []
        for relationship in self.relationships {
            for object in relationship.objects {
                let filter: (JSONResource) -> Bool = { includedResource in
                    return includedResource.ID == object.ID && includedResource.type == object.type
                }
                guard let includedIndex: Int = document.includes.index(where: filter) else {
                    continue
                }
                let includedResourceForRelationship: JSONResource = document.includes[includedIndex]
                result.append(includedResourceForRelationship)
            }
        }
        return result
    }
    
    public var meta: JSONObject? {
        return self["meta"] as? JSONObject
    }
    
    public func relationship(ofType type: AnyObject.Type) -> Relationship? {
        var result: Relationship? = .none
        let typeString: String = String(describing: type).lowercased()
        for relationship in self.relationships {
            let whereClosure: ((Int, String)) -> Bool = { object in
                return object.1 == typeString
            }
            if relationship.objects.contains(where: whereClosure) {
                result = relationship
                break
            } else {
                continue
            }
        }
        return result
    }
}

