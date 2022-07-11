//
//  NetworkError.swift
//  SmartBrick
//
//  Created by Alexander Andrusenko on 29.06.2022.
//

import Foundation
import Alamofire

struct NetworkError: Error {
  let initialError: AFError
  let backendError: BackendError?
}

struct BackendError: Codable, Error {
    var status: String
    var message: String
}
