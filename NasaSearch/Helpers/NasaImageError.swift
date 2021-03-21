//
//  NasaImageError.swift
//  NasaSearch
//
//  Created by David on 3/17/21.
//

import Foundation

enum NasaImageError: LocalizedError {
    case invalidURL
    case thrown(Error)
    case noData
    case unableToDecode
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Internal error. Please update the app or contact support."
        case .thrown(let error):
            return error.localizedDescription
        case .noData:
            return "The server responded with no data."
        case .unableToDecode:
            return "The server responded with bad data."
        }
    }
}
