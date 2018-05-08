//
//  URLSessionDelegate.swift
//  NetworkingController
//
//  Created by Chandler De Angelis on 5/7/18.
//  Copyright © 2018 Chandler De Angelis. All rights reserved.
//

import Foundation

class WeakNetworkingController {
    weak var value: NetworkingController?
    
    init(value: NetworkingController) {
        self.value = value
    }
}

final class NetworkingControllerSessionDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    var controllers: [WeakNetworkingController] = []
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.controllers.forEach {
            $0.value?.urlSession(session, dataTask: dataTask, didReceive: data)
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.controllers.forEach {
            $0.value?.urlSession(session, task: task, didCompleteWithError: error)
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        self.controllers.forEach {
            $0.value?.urlSession(session, task: task, didReceive: challenge, completionHandler: completionHandler)
        }
    }

}
