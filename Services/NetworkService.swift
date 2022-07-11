//
//  Service.swift
//  SmartBrick
//
//  Created by Alexander Andrusenko on 29.06.2022.
//

import SwiftUI
import Combine
import Alamofire

enum IsFetched {
    case fetched
    case notFetched
    case error
    case fetching
}

enum ApiConstants: String {
    case apiURL = ""
    case tenantInfo = "/tenant-info"
    case projects = "/project"
    case knowledge = "/faq"
}

protocol ServiceProtocol {
    func fetchData<T: Decodable>(_ t: T.Type, path: String) -> AnyPublisher<DataResponse<T, NetworkError>, Never>
    func fetchImage(url: URL) -> AnyPublisher<DataResponse<Data, NetworkError>, Never>
    func getCachedImage(url: URL) -> Image?
    func saveImageToCache(data: Data, response: URLResponse)
}

class NetworkService {
    static let shared: ServiceProtocol = NetworkService()
    private init() { }
}

extension NetworkService: ServiceProtocol {
    func fetchData<T: Decodable>(_ t: T.Type, path: String) -> AnyPublisher<DataResponse<T, NetworkError>, Never> {
        let url = URL(string: "\(ApiConstants.apiURL.rawValue)\(path)")!
        
        let authToken = ""
        
        let headers: HTTPHeaders = [.authorization(bearerToken: authToken)]
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return AF.request(url, method: .get, headers: headers)
            .validate()
            .publishDecodable(type: T.self, decoder: decoder)
            .map { response in
                response.mapError { error in
                    let backendError = response.data.flatMap { try? JSONDecoder().decode(BackendError.self, from: $0)}
                    return NetworkError(initialError: error, backendError: backendError)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
    func fetchImage(url: URL) -> AnyPublisher<DataResponse<Data, NetworkError>, Never> {
        
        return AF.request(url, method: .get)
            .validate()
            .publishData()
            .map { response in
                response.mapError { error in
                    let backendError = response.data.flatMap { try? JSONDecoder().decode(BackendError.self, from: $0)}
                    return NetworkError(initialError: error, backendError: backendError)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getCachedImage(url: URL) -> Image? {
        
        URLCache.shared = {
            URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024, diskPath: "myDataPath")
        }()
        
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 60.0)
        
        if let cacheResponse = URLCache.shared.cachedResponse(for: request) {
            return Image(uiImage: UIImage(data: cacheResponse.data) ?? UIImage(named: "project_placeholder")!)
        }
        return nil
    }
    
    func saveImageToCache(data: Data, response: URLResponse) {
        
        URLCache.shared = {
            URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024, diskPath: "myDataPath")
        }()
        
        guard let responseURL = response.url else { return }
        
        let cashedResponse = CachedURLResponse(response: response, data: data)
        URLCache.shared.storeCachedResponse(cashedResponse, for: URLRequest(url: responseURL))
    }
}
