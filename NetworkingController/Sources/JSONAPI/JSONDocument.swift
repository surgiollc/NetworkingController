//
//  JSONDocument.swift
//  NetworkingController
//
//  Created by Chandler De Angelis on 4/6/18.
//  Copyright © 2018 Chandler De Angelis. All rights reserved.
//

import Foundation

public struct JSONDocument: JSONAPIResource {
        
    public var json: JSONObject
    
    public var rootDataObject: JSONObject? {
        return self.json["data"] as? JSONObject
    }
    
    public var data: Data? {
        return try? JSONSerialization.data(withJSONObject: self.json, options: [])
    }
    
    init(json: JSONObject) {
        self.json = json
    }
    
    public init(resource: JSONResource) {
        self.json = ["data": resource.json]
    }
    
    public init(resources: [JSONResource]) {
        self.json = [
            "data": resources.map({ $0.json })
        ]
    }
    
    public init?(data: Data) {
        if let object: Any = try? JSONSerialization.jsonObject(with: data, options: []),
            let json: JSONObject = object as? JSONObject,
            json["data"] != nil {
            self.json = json
        } else {
            return nil
        }
    }
    
    public var resourceObjects: [JSONResource]? {
        get {
            guard case let objects as [JSONObject] = self["data"] else {
                return .none
            }
            return objects.map(JSONResource.init)
        }
        set {
            self["data"] = newValue?.map({ $0.json })
        }
    }
    
    public var resourceObject: JSONResource? {
        get {
            guard case let object as JSONObject = self["data"] else {
                return .none
            }
            return JSONResource(json: object)
        }
        set {
            self["data"] = newValue?.json
        }
    }
    
    public mutating func remove(_ resource: JSONResource) {
        guard let index: Int = self.resourceObjects?.index(of: resource) else { return }
        self.resourceObjects?.remove(at: index)
    }
    
    public var links: JSONObject? {
        return self["links"] as? JSONObject
    }
    
    public var meta: JSONObject? {
        return self["meta"] as? JSONObject
    }
    
    public var errors: [JSONObject] {
        return self["errors"] as? [JSONObject] ?? []
    }
    
    public var includes: [JSONResource] {
        guard let included = self["included"] as? [JSONObject] else {
            return []
        }
        return included.map(JSONResource.init)
    }
    
}
