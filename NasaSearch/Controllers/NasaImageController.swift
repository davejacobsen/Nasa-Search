//
//  NasaImageController.swift
//  NasaSearch
//
//  Created by David on 3/17/21.
//

import UIKit

class NasaImageController {
    
    static let shared = NasaImageController()
    
    let cache = NSCache<NSString, UIImage>()
    var isPaginating = false
    
    let userDefaultsAppearanceKey = "appearanceSelection"
    
    private let nasaImageStringBaseURL = "https://images-api.nasa.gov"
    private let searchEndpoint = "/search?q="
    private let pageEndpoint = "&page="
    
    func fetchNasaImages(searchTerm: String, page: Int, completion: @escaping (Result<[NasaImage], NasaImageError>) -> Void) {
        
        isPaginating = true
        
        let pageString = String(page)
        let URLString = nasaImageStringBaseURL + searchEndpoint + searchTerm + pageEndpoint + pageString
        
        /// encodes spaces in search bar
        let encodedURLString = URLString.replacingOccurrences(of: " ", with: "%20")
        
        guard let finalURL = URL(string: encodedURLString) else {return (completion(.failure(.invalidURL)))}
        
        URLSession.shared.dataTask(with: finalURL) { data, _, error in
            
            if let error = error {
                print(error, error.localizedDescription)
                return completion(.failure(.thrown(error)))
            }
            
            guard let data = data else { return completion(.failure(.noData)) }
            
            do {
                let  topLevelObject = try JSONDecoder().decode(TopLevelObject.self, from: data)
                return completion(.success(topLevelObject.collection.items))
            } catch {
                print(error, error.localizedDescription)
                return completion(.failure(.thrown(error)))
            }
        }.resume()
        
    }
    
    func fetchNasaImageThumbnail(nasaImage: NasaImage, completion: @escaping (Result<UIImage, NasaImageError>) -> Void) {
        
        guard let URLString = nasaImage.links?[0].imageLink else { return completion(.failure(.invalidURL)) }
        
        /// check image cache before fetching
        let cacheKey = NSString(string: URLString)
        if let image = cache.object(forKey: cacheKey) {
            completion(.success(image))
            return
        }
        
        let formattedURLString = URLString.replacingOccurrences(of: " ", with: "%20")
        
        guard let nasaImageURL = URL(string: formattedURLString) else { return completion(.failure(.invalidURL)) }
        
        URLSession.shared.dataTask(with: nasaImageURL) { (data, _, error) in
            
            if let error = error {
                completion(.failure(.thrown(error)))
            }
            
            guard let data = data else {return completion(.failure(.noData))}
            guard let image = UIImage(data: data) else {return completion(.failure(.unableToDecode))}
            
            self.cache.setObject(image, forKey: cacheKey)
            completion(.success(image))
            
        }.resume()
    }
    
    /// formats API date strings into human readable date strings
    func convertNasaDateString(dateString: String) -> String {
        
        let recievingDateFormatter = DateFormatter()
        recievingDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        guard let date = recievingDateFormatter.date(from: dateString) else { return "Unknown date" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        return dateFormatter.string(from: date)
    }
    
}
