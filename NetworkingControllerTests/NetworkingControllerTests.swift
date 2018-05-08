//
//  NetworkingControllerTests.swift
//  NetworkingControllerTests
//
//  Created by Chandler De Angelis on 9/16/17.
//  Copyright © 2017 Chandler De Angelis. All rights reserved.
//

import XCTest
@testable import NetworkingController

class NetworkingControllerTests: BaseTests {
        
    override func setUp() {
        super.setUp()
        NetworkingController.configureForTesting(with: TestingProtocol.self)
        self.controller = NetworkingController()
        self.controller.successDelegate = self
        self.controller.errorDelegate = self
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testThatControllerCanFetchData() {
        let bundle: Bundle = Bundle(for: type(of: self))
        guard let url: URL = bundle.url(forResource: "default_response", withExtension: "json") else {
            XCTFail("file url must not be nil")
            return
        }
        let request: URLRequest = URLRequest(url: url)
        self.completionClosure = { (data: Data?, error: Error?, status: URLResponseStatus?) -> Void in
            XCTAssertNil(error)
            XCTAssertNil(status)
            XCTAssertNotNil(data)
            XCTAssertGreaterThan(data!.count, 0)
            self.currrentExpectation.fulfill()
        }
        self.send(request)
    }
    
    func testThatFetchedDataIsCorrectSize() {
        let bundle: Bundle = Bundle(for: type(of: self))
        guard let url:          URL     = bundle.url(forResource: "default_response", withExtension: "json"),
            let expectedData:   Data    = try? Data(contentsOf: url) else {
            XCTFail("file url must not be nil")
            return
        }
        let request: URLRequest = URLRequest(url: url)
        self.completionClosure = { (data: Data?, error: Error?, status: URLResponseStatus?) -> Void in
            XCTAssertNil(error)
            XCTAssertNil(status)
            XCTAssertNotNil(data)
            XCTAssertEqual(data!.count, expectedData.count)
            self.currrentExpectation.fulfill()
        }
        self.send(request)
    }
    
    func testThatNetworkingControllerDoesNotLeak() {
        let request: URLRequest = URLRequest(url: URL(string: "http://www.google.com")!)
        self.completionClosure = { _, _, _ in
            self.controller = nil
            XCTAssertNil(self.controller)
            self.currrentExpectation.fulfill()
        }
        self.send(request)
    }
    
}

extension NetworkingControllerTests: NetworkingControllerSuccessDelegate {
    func taskDidComplete(_ task: URLSessionTask, data: Data) {
        self.completionClosure(data, .none, .none)
    }
    
    func taskDidComplete(_ task: URLSessionTask, document: JSONDocument) {
        
    }
}

extension NetworkingControllerTests: NetworkingControllerErrorDelegate {
    
    func taskDidFail(_ task: URLSessionTask, error: NSError, status: URLResponseStatus?) {
        self.completionClosure(.none, error, status)
    }
    
    func requestDidReceiveAuthenticationChallenge(_ request: URLRequest) -> (username: String, password: String) {
        return ("","")
    }
    
    func sessionDidFail(_ error: NSError?) {
        
    }
}


