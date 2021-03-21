//
//  NasaImageCollectionViewCell.swift
//  NasaSearch
//
//  Created by David on 3/17/21.
//

import UIKit

class NasaImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nasaImageThumbnailImageView: UIImageView!
    @IBOutlet weak var holderView: UIView!
    
    var nasaImage: NasaImage? {
        didSet {
            
            guard let nasaImage = nasaImage else {return}
            
            nasaImageThumbnailImageView.layer.cornerRadius = 10
            holderView.layer.cornerRadius = 10
            self.holderView.backgroundColor = UIColor.systemIndigo
            
            /// this hides the hides the indigo background until the image has loaded
            holderView.isHidden = true
            
            NasaImageController.shared.fetchNasaImageThumbnail(nasaImage: nasaImage) { [weak self] (result) in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self?.nasaImageThumbnailImageView.image = image
                        self?.holderView.isHidden = false
                    }
                case .failure(let error):
                    print(error.errorDescription!)
                    DispatchQueue.main.async {
                        let errorImage = UIImage(named: "NoImageFound.jpg")
                        self?.nasaImageThumbnailImageView.image = errorImage
                        self?.holderView.isHidden = false
                    }
                }
            }
        }
    }
}
