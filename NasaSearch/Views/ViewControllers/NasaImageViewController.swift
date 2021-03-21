//
//  NasaImageViewController.swift
//  NasaSearch
//
//  Created by David on 3/17/21.
//

import UIKit

private let reuseIdentifier = "nasaImageCell"

class NasaImageViewController: UIViewController {
    
    @IBOutlet weak var nasaImageSearchBar: UISearchBar!
    @IBOutlet weak var nasaImageCollectionView: UICollectionView!
    
    let userDefaultsAppearanceKey = NasaImageController.shared.userDefaultsAppearanceKey
    
    var nasaImages = [NasaImage]()
    
    /// used for pagination
    var currentSearchTerm = ""
    var currentlyDisplayedPage = 0
    
    /// used to pad the insets of the cellectionView
    let cellInsetSize: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nasaImageSearchBar.delegate = self
        nasaImageCollectionView.delegate = self
        nasaImageCollectionView.dataSource = self
        
        nasaImageCollectionView.contentInset.left = cellInsetSize
        nasaImageCollectionView.contentInset.right = cellInsetSize
        nasaImageCollectionView.contentInset.top = cellInsetSize
        
        setupNavBar()
        
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
    
    /// makes the nav bar background clear, sets the colors to indigo, and sets the back button image
    func setupNavBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
        
        let attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.systemIndigo,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22)
        ]
        navigationController?.navigationBar.titleTextAttributes = attrs
        navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .systemIndigo
    }
    
}

extension NasaImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nasaImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? NasaImageCollectionViewCell else { return UICollectionViewCell()}
        
        let nasaImage = nasaImages[indexPath.row]
        cell.nasaImage = nasaImage
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = 5
        let width = (collectionView.frame.size.width - (CGFloat(padding) * 2 + cellInsetSize * 2)) / CGFloat(2)
        let height = width / 200 * 110
        return CGSize(width: width, height: height)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailView" {
            guard let indexPath = nasaImageCollectionView.indexPathsForSelectedItems,
                  let destination = segue.destination as? NasaImageDetailViewController else {return}
            let nasaImageToSend = nasaImages[indexPath[0].row]
            destination.nasaImage = nasaImageToSend
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
        if position > (nasaImageCollectionView.contentSize.height - 150 - nasaImageCollectionView.frame.size.height) && currentlyDisplayedPage != 0 {
            
            /// makes sure pagination is not already occuring
            guard !NasaImageController.shared.isPaginating  else { return }
            
            let nextPageToLoad = currentlyDisplayedPage + 1
            
            NasaImageController.shared.fetchNasaImages(searchTerm: currentSearchTerm, page: nextPageToLoad) { [weak self] (result) in
                switch result {
                case .success(let nasaImages):
                    DispatchQueue.main.async {
                        
                        /// some results come back with nil for the image links so this gets rid of those since we can't load an image from it
                        let filteredNasaImages = nasaImages.filter { $0.links != nil }
                        
                        self?.currentlyDisplayedPage += 1
                        self?.nasaImages.append(contentsOf: filteredNasaImages)
                        self?.nasaImageCollectionView.reloadData()
                        
                        NasaImageController.shared.isPaginating = false
                        
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

extension NasaImageViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        /// makes sure there is a search term and it is not an empty string
        guard let searchTerm = nasaImageSearchBar.text, !searchTerm.isEmpty else {return}
        
        /// clears the local array if a new search initiates
        nasaImages = []
        nasaImageCollectionView.reloadData()
        
        /// sets this locally to be used for pagination
        currentSearchTerm = searchTerm
        currentlyDisplayedPage = 0
        
        /// a new search from the search bar will only ever load the first page of results. Pagination will load any pages beyond 1.
        NasaImageController.shared.fetchNasaImages(searchTerm: currentSearchTerm, page: 1) { [weak self] (result) in
            switch result {
            case .success(let nasaImages):
                
                DispatchQueue.main.async {
                    
                    /// some results come back with nil for the image links so this gets rid of those since we can't load an image from it
                    let filteredNasaImages = nasaImages.filter { $0.links != nil }
                    
                    self?.nasaImages = filteredNasaImages
                    if filteredNasaImages.isEmpty {
                        
                        /// notifys user that there are no results for their search
                        self?.presentNoResultsAlert(searchTerm: searchTerm)
                    } else {
                        NasaImageController.shared.isPaginating = false
                        self?.currentlyDisplayedPage = 1
                        self?.nasaImageCollectionView.reloadData()
                    }
                    
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func presentNoResultsAlert(searchTerm: String) {
        
        guard currentlyDisplayedPage == 0 else { return }
        
        let title = "No Results"
        let message = "\nWe couldn't find any images based on the search term '\(searchTerm).'\n\nPlease try another search. "
        let actionTitle = "OK"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
