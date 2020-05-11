//
//  TestListener.swift
//  internet_speed_test
//
//  Created by Taha Malas on 5/1/20.
//

import Foundation

protocol TestListener {
    func onComplete(transferRate: Double)
    
    func onError(speedTestError: String, errorMessage: String)
    
    func onProgress(percent: Double, transferRate: Double)
}
