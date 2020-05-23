//
//  CustomHostDownloadService.swift
//  SpeedTestLib
//
//  Created by dhaurylenka on 2/5/18.
//  Copyright © 2018 Exadel. All rights reserved.
//

import Foundation

class CustomHostDownloadService: NSObject, SpeedService {
    private var responseDate: Date?
    private var latestDate: Date?
    private var current: ((Speed, Speed) -> ())!
    private var final: ((Result<Speed, NetworkError>) -> ())!
    
    func test(_ url: URL, fileSize: Int, timeout: TimeInterval, current: @escaping (Speed, Speed) -> (), final: @escaping (Result<Speed, NetworkError>) -> ()) {
        self.current = current
        self.final = final
        let resultURL = HostURLFormatter(speedTestURL: url).downloadURL(size: fileSize)
        URLSession(configuration: sessionConfiguration(timeout: timeout), delegate: self, delegateQueue: OperationQueue.main)
            .downloadTask(with: resultURL)
            .resume()
    }
}

extension CustomHostDownloadService: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let result = calculate(bytes: downloadTask.countOfBytesReceived, seconds: Date().timeIntervalSince(self.responseDate!))
        self.final(.value(result))
        responseDate = nil
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if error != nil {
            print("url session1")
            self.final(.error(NetworkError.requestFailed))
            responseDate = nil
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print(error.debugDescription)
            print("task is \(task.error.debugDescription)")
            
            print("error is \(error.debugDescription)")
            print("url session2")
            self.final(.error(NetworkError.requestFailed))
            responseDate = nil
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let startDate = responseDate, let latesDate = latestDate else {
            responseDate = Date();
            latestDate = responseDate
            return
        }
        let currentTime = Date()
        
        let current = calculate(bytes: bytesWritten, seconds: currentTime.timeIntervalSince(latesDate))
        let average = calculate(bytes: totalBytesWritten, seconds: -startDate.timeIntervalSinceNow)
        
        latestDate = currentTime
        
       self.current(current, average)
    }
}
