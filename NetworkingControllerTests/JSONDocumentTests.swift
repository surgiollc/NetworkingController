//
//  JSONDocumentTests.swift
//  NetworkingControllerTests
//
//  Created by Chandler De Angelis on 4/6/18.
//  Copyright © 2018 Chandler De Angelis. All rights reserved.
//

import XCTest
@testable import NetworkingController

final class JSONDocumentTests: XCTestCase {
    
    private var jsonData: Data {
        let bundle: Bundle = Bundle(for: type(of: self))
        let url: URL = bundle.url(forResource: "jsonapi_response", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    private var document: JSONDocument!
    
    override func setUp() {
        super.setUp()
        self.document = JSONDocument(data: self.jsonData)!
    }
    
    func testThatDataObjectIsCorrect() {
        let dataObject: JSONObject? = self.document.rootDataObject
        XCTAssertNotNil(dataObject)
        XCTAssertEqual(dataObject?["type"] as? String, "articles")
        XCTAssertEqual(dataObject?["id"] as? String, "1")
        let relationships: JSONObject? = dataObject?["relationships"] as? JSONObject
        let author: JSONObject? = relationships?["author"] as? JSONObject
        XCTAssertNotNil(author)
        let links: JSONObject? = author?["links"] as? JSONObject
        XCTAssertNotNil(links)
        XCTAssertEqual(links?["self"] as? String, "/articles/1/relationships/author")
        let authorData: JSONObject? = author?["data"] as? JSONObject
        XCTAssertEqual(authorData?["type"] as? String, "people")
        XCTAssertEqual(authorData?["id"] as? String, "9")
    }
    
    func testThatResourcesAreCorrect() {
        let resource: JSONResource? = self.document.resourceObject
        XCTAssertNotNil(resource)
        XCTAssertEqual(resource?.type, "articles")
        XCTAssertEqual(resource?.ID, "1")
        let title: String? = resource?[attribute: "title"]
        XCTAssertEqual(title, "title")
        let authorRel: JSONResource.Relationship! = resource?[relationship: "author"]
        XCTAssertNotNil(authorRel)
        let authorObject: JSONResource.RelatedObject! = authorRel.first
        XCTAssertNotNil(authorObject)
        XCTAssertEqual(authorRel.key, "author")
        XCTAssertEqual(authorObject.type, "people")
        XCTAssertEqual(authorObject.ID, "9")
    }
    
    func testThatErrorsAreCorrect() {
        let errors: [JSONObject] = self.document.errors
        XCTAssertEqual(errors.count, 1)
        let er: JSONObject? = errors.first
        XCTAssertNotNil(er)
        XCTAssertEqual(er?["title"] as? String, "some error")
        XCTAssertEqual(er?["id"] as? String, "1")
    }
    
    func testThatMetaIsCorrect() {
        let meta: JSONObject? = self.document.meta
        XCTAssertNotNil(meta)
        XCTAssertEqual(meta?["copyright"] as? String, "Copyright 2015 Example Corp.")
    }
    
    func testIncluded() {
        let includes: [JSONResource] = self.document.includes
        XCTAssertEqual(includes.count, 1)
        let resource: JSONResource = includes.first!
        XCTAssertEqual(resource.type, "people")
        XCTAssertEqual(resource.ID, "9")
        let name: String? = resource[attribute: "first-name"]
        XCTAssertEqual(name, "Dan")
        XCTAssertEqual(resource.links?["self"] as? String, "http://example.com/people/9")
    }
    
}
