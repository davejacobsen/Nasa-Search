//
//  MenuTableViewController.swift
//  NasaSearch
//
//  Created by David on 3/18/21.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var appearanceSegmentedControl: UISegmentedControl!
    
    let userDefaultsAppearanceKey = NasaImageController.shared.userDefaultsAppearanceKey
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appVersion = UIApplication.appVersion {
            versionLabel.text = "NasaSearch version \(appVersion)"
        }
        
        tableView.isScrollEnabled = false
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setAppearance()
    }
    
    func setAppearance() {
        
        let defaults = UserDefaults.standard
        let appearanceSelection = defaults.integer(forKey: userDefaultsAppearanceKey)
        appearanceSegmentedControl.selectedSegmentIndex = appearanceSelection
        
        if appearanceSelection == 0 {
            overrideUserInterfaceStyle = .unspecified
        } else if appearanceSelection == 1 {
            overrideUserInterfaceStyle = .light
        } else {
            overrideUserInterfaceStyle = .dark
        }
    }
    
    @IBAction func appearanceValueChanged(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        
        if appearanceSegmentedControl.selectedSegmentIndex == 0 {
            overrideUserInterfaceStyle = .unspecified
            defaults.setValue(0, forKey: userDefaultsAppearanceKey)
        } else if appearanceSegmentedControl.selectedSegmentIndex == 1 {
            overrideUserInterfaceStyle = .light
            defaults.setValue(1, forKey: userDefaultsAppearanceKey)
        } else if appearanceSegmentedControl.selectedSegmentIndex == 2 {
            overrideUserInterfaceStyle = .dark
            defaults.setValue(2, forKey: userDefaultsAppearanceKey)
        } else {
            print("selection error")
        }
    }
    
    // MARK: - Table view data source
    
    /// leaving these static as this demo app will not change but typically would make a settings/menu page dynamic for easy edits and updates
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 35 : 10
    }
    
}

/// used to apply the version label
extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
