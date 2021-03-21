//
//  NasaImage.swift
//  NasaSearch
//
//  Created by David on 3/17/21.
//

import Foundation

struct TopLevelObject: Codable {
    let collection: NasaImageCollection
}

struct NasaImageCollection: Codable {
    let items: [NasaImage]
}

struct NasaImage: Codable {
    let data: [NasaImageData]
    
    /// must be optional for cases where there are no links so app doesn't crash
    let links: [Link]?
}

struct NasaImageData: Codable {
    let title: String
    let photographer: String?
    let location: String?
    let description: String
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case photographer
        case location
        case description
        case date = "date_created"
    }
}

struct Link: Codable {
    let imageLink: String
    
    enum CodingKeys: String, CodingKey {
        case imageLink = "href"
    }
}
