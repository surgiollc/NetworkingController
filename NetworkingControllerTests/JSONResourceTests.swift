//
//  JSONResourceTests.swift
//  NetworkingControllerTests
//
//  Created by Chandler De Angelis on 5/17/18.
//  Copyright © 2018 Chandler De Angelis. All rights reserved.
//

import XCTest
@testable import NetworkingController

final class JSONResourceTests: XCTestCase {
    
    private var jsonData: Data {
        let bundle: Bundle = Bundle(for: type(of: self))
        let url: URL = bundle.url(forResource: "jsonapi_response", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    private var document: JSONDocument!
    
    private var resource: JSONResource? {
        return self.document.resourceObject
    }
    
    override func setUp() {
        super.setUp()
        self.document = JSONDocument(data: self.jsonData)!
    }
    
    func testThatRelationshipsAreCorrect() {
        XCTAssertNotNil(self.resource)
        
        let author: JSONResource.Relationship? = self.resource?[relationship: "author"]
        XCTAssertNotNil(author)
        XCTAssertEqual(author?.key, "author")
        let authorObject: JSONResource.RelatedObject? = author?.first
        XCTAssertNotNil(authorObject)
        XCTAssertEqual(authorObject?.type, "people")
        XCTAssertEqual(authorObject?.ID, 9)
        
        let array: JSONResource.Relationship? = self.resource?[relationship: "array"]
        XCTAssertNotNil(array)
        XCTAssertEqual(array?.key, "array")
        let firstObject: JSONResource.RelatedObject? = array?.first
        XCTAssertNotNil(firstObject)
        XCTAssertEqual(firstObject?.ID, 1)
        XCTAssertEqual(firstObject?.type, "stuff")
        let lastObejct: JSONResource.RelatedObject? = array?[1]
        XCTAssertNotNil(lastObejct)
        XCTAssertEqual(lastObejct?.ID, 2)
        XCTAssertEqual(lastObejct?.type, "stuff")
    }
    
    func testThatResourceReturnsIncludedResources() {
        XCTAssertNotNil(self.resource)
        let includedResources: [JSONResource]? = self.resource?.relatedResources(in: self.document)
        XCTAssertEqual(includedResources?.count, 1)
        let includedResource: JSONResource? = includedResources?.first
        XCTAssertEqual(includedResource?.type, "people")
        XCTAssertEqual(includedResource?.ID, 9)
        
    }
}
