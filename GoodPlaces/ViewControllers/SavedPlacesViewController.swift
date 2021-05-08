//
//  LocationsViewController.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 4/29/21.
//

import UIKit

private let savedPlacesIdentifier = "savedPlaces"


class savedPlacesViewController: UIViewController {
    
    private let tableView = UITableView()
    
    private var renameObserver: NSObjectProtocol?
    
    private var savedLocationsArray = [SavedLocations]() {
        didSet {
            print("DEBUG-SavedPlacesVC: array got filled")
            tableView.reloadData()
        }
    }
    
//MARK: - Components
    
    //make it "lazy var" since we gotta add func "segmentSwitch"
    private lazy var segment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Row view", "Board view"])
        sc.backgroundColor = .black
        
        //set the text color for the text of the sc
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = UIColor.white
        sc.layer.borderWidth = 1
        sc.layer.borderColor = UIColor(white: 1, alpha: 0.87).cgColor
        
        sc.addTarget(self, action: #selector(segmentSwitch), for: .valueChanged)
        
        return sc
    }()
    
    private let noLocationSavedLabel: UILabel = {
        let lb = UILabel()
        lb.text = "No location saved."
        lb.textColor = .black
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        
        return lb
    }()
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchSavedLocations()
        protocolVC()
    }
    
    
//MARK: - Configure UI
    
    func configureUI() {
        view.backgroundColor = .white
        
        configureNavigationBar(title: "Saved places", preferLargeTitle: false, backgroundColor: #colorLiteral(red: 0.4772150784, green: 1, blue: 0.517582286, alpha: 1), buttonColor: .black)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .done, target: self, action: #selector(dismissSavedPlacesVC))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addLocation))

        view.addSubview(segment)
        segment.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 12)
        segment.centerX(inView: view)
        
        configureTableView()
        
        view.addSubview(noLocationSavedLabel)
        noLocationSavedLabel.anchor(top: segment.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingRight: 20)
    }
    
    func configureTableView() {
        tableView.backgroundColor = .clear
        tableView.rowHeight = 50
        tableView.tableFooterView = UIView() //eliminate the unnecessary lines if there is no cell
        tableView.separatorStyle = .singleLine
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: savedPlacesIdentifier)
        
        view.addSubview(tableView)
        tableView.anchor(top: segment.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 12)
    }
    
    
//MARK: - Protocol VC
    //remember to put this func in the viewDidLoad. this func gets called from MapVC
    func protocolVC() {
        renameObserver = NotificationCenter.default.addObserver(forName: .didRenameTitle, object: nil, queue: .main) { [weak self] _ in
            
            print("DEBUG-SavedPlacesVC: title renamed notified..")
            guard let strongSelf = self else { return }
            strongSelf.fetchSavedLocations()
        }
        
    }
    
    //this func is exclusively unique for protocol
    deinit {
        if let observer1 = renameObserver {
            NotificationCenter.default.removeObserver(observer1)
        }
        
    }
        
    
//MARK: - Actions
    
    @objc func dismissSavedPlacesVC() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func segmentSwitch() {
        if segment.selectedSegmentIndex == 0 {
            tableView.isHidden = false
            view.backgroundColor = .white
        } else {
            tableView.isHidden = true
            view.backgroundColor = .yellow
        }
    }
    
    @objc func addLocation() {
        
    }
    
    func fetchSavedLocations() {
        Service.fetchLocations { locationArray in
            self.savedLocationsArray = locationArray
            
            if locationArray.count == 0 {
                self.noLocationSavedLabel.alpha = 1
            } else {
                self.noLocationSavedLabel.alpha = 0
            }
        }
    }
    
    
}


//MARK: - Extension Datasource

extension savedPlacesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedLocationsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: savedPlacesIdentifier, for: indexPath)
        cell.backgroundColor = .white
        cell.textLabel?.textColor = .black
        cell.textLabel?.text = savedLocationsArray[indexPath.row].title
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    
}

//MARK: - Extensions Delegate

extension savedPlacesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true) //unhighlight the selected row/cell
        print("DEBUG-SavedPlacesVC: select row \(indexPath.row)")
        
        let vc = MapViewController()
        vc.locationInfo = savedLocationsArray[indexPath.row] //pass data to MapVC
        navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
}
