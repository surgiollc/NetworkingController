//
//  URLSessionDelegate.swift
//  NetworkingController
//
//  Created by Chandler De Angelis on 5/7/18.
//  Copyright © 2018 Chandler De Angelis. All rights reserved.
//

import Foundation

final class WeakBox<A: AnyObject> {
    weak var unbox: A?
    init(_ value: A) {
        self.unbox = value
    }
}

final class NetworkingControllerSessionDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    private var controllers: [WeakBox<NetworkingController>] = []
    
    func addController(_ controller: NetworkingController) {
        self.controllers.append(WeakBox(controller))
    }
    
    func removeController(_ controller: NetworkingController) {
        if let index: Int = self.controllers.index(where: { $0.unbox == controller }) {
            self.controllers.remove(at: index)
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.controllers.forEach {
            $0.unbox?.urlSession(session, dataTask: dataTask, didReceive: data)
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.controllers.forEach {
            $0.unbox?.urlSession(session, task: task, didCompleteWithError: error)
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        self.controllers.forEach {
            $0.unbox?.urlSession(session, task: task, didReceive: challenge, completionHandler: completionHandler)
        }
    }

}
