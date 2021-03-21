//
//  NasaImageDetailViewController.swift
//  NasaSearch
//
//  Created by David on 3/17/21.
//

import UIKit

class NasaImageDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detailStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photographerLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var nasaImage: NasaImage?
    
    let userDefaultsAppearanceKey = NasaImageController.shared.userDefaultsAppearanceKey
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews(nasaImage: nasaImage)
    }
    
    /// by hiding labels that come back with no value, the stack view will handle the layout for any situation.
    func configureViews(nasaImage: NasaImage?) {
        guard let nasaImage = nasaImage else { return }
        
        NasaImageController.shared.fetchNasaImageThumbnail(nasaImage: nasaImage) { [weak self] (result) in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            case .failure(let error):
                print(error.errorDescription!)
                DispatchQueue.main.async {
                    let errorImage = UIImage(named: "NoImageFound.jpg")
                    self?.imageView.image = errorImage
                }
            }
        }
        
        self.titleLabel?.text = nasaImage.data[0].title
        
        if let photographer = nasaImage.data[0].photographer {
            self.photographerLabel?.text = "Photographed by: \(photographer)"
        } else {
            photographerLabel.isHidden = true
        }
        
        if let location = nasaImage.data[0].location {
            self.locationLabel?.text = "Location: \(location)"
        } else {
            self.locationLabel.isHidden = true
        }
        
        let dataString = nasaImage.data[0].date
        self.dateLabel?.text = "Date captured: \(NasaImageController.shared.convertNasaDateString(dateString: dataString))"
        
        self.descriptionLabel?.text = "Description: \(nasaImage.data[0].description)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setAppearance()
    }
    
    func setAppearance() {
        
        let defaults = UserDefaults.standard
        let appearanceSelection = defaults.integer(forKey: userDefaultsAppearanceKey)
        
        if appearanceSelection == 0 {
            overrideUserInterfaceStyle = .unspecified
        } else if appearanceSelection == 1 {
            overrideUserInterfaceStyle = .light
        } else {
            overrideUserInterfaceStyle = .dark
        }
    }
    
}
