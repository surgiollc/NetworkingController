//
//  URLSessionDelegate.swift
//  NetworkingController
//
//  Created by Chandler De Angelis on 5/7/18.
//  Copyright © 2018 Chandler De Angelis. All rights reserved.
//

import Foundation

final class NetworkingControllerSessionDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    weak var controller: NetworkingController?
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.controller?.urlSession(session, dataTask: dataTask, didReceive: data)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.controller?.urlSession(session, task: task, didCompleteWithError: error)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        self.controller?.urlSession(session, task: task, didReceive: challenge, completionHandler: completionHandler)
    }

}
