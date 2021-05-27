//
//  LocationsViewController.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 4/29/21.
//

import UIKit

private let savedPlacesIdentifier = "savedPlaces"
private let cellIdentifier = "cellIdentifier"


class savedPlacesViewController: UIViewController {
    
    private let tableView = UITableView()
    private var rowNumber = IndexPath(item: 0, section: 0)
    private var renameObserver: NSObjectProtocol?
    
    //got filled by func "fetchSavedLocations"
    var savedLocationsArray = [SavedLocations]()
    private var didDeleteRow = false
    
//MARK: - Components
    
    //"lazy var" since we gotta register the cell after loading
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        //use decoy cell for "UICollectionViewCell.self"
        cv.register(LocationPin.self, forCellWithReuseIdentifier: cellIdentifier)
        
        return cv
    }()
    
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
        noSaveLabel()
        
        fetchSavedLocations()
        protocolVC()
        longPressStuff()
        swipeGesture()
    }
    
    
//MARK: - Configure UI
    
    func configureUI() {
        view.backgroundColor = .white
        configureTableView()
        
        //nav bar
        configureNavigationBar(title: "Saved places", preferLargeTitle: false, backgroundColor: #colorLiteral(red: 0.4772150784, green: 1, blue: 0.517582286, alpha: 1), buttonColor: .black)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .done, target: self, action: #selector(dismissSavedPlacesVC))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addLocation))

        //Segment
        view.addSubview(segment)
        segment.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 12)
        segment.centerX(inView: view)
        
        //tableView
        view.addSubview(tableView)
        tableView.anchor(top: segment.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 12)
        
        //collectionView
        view.addSubview(collectionView)
        collectionView.anchor(top: segment.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 12)
        collectionView.isHidden = true
        
        //saveLabel
        view.addSubview(noLocationSavedLabel)
        noLocationSavedLabel.anchor(top: segment.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingRight: 20)
    }
    
//MARK: - Configure tableView
    func configureTableView() {
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView() //eliminate the unnecessary lines if there is no cell
        tableView.rowHeight = 100 //specified the rowHeight ONLY HERE
        tableView.separatorStyle = .singleLine
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //if it's for decoy cells, then "UITableViewCell.self"
        tableView.register(LocationCell.self, forCellReuseIdentifier: savedPlacesIdentifier)
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
    
    func swipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissSavedPlacesVC))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    @objc func dismissSavedPlacesVC() {
        
        if didDeleteRow {
            print("DEBUG-SavedPlaces: row deleted")
            //send the notification to HomeVC to reload and fetch data
            NotificationCenter.default.post(name: .didDeleteItem, object: nil)
        } else {
            print("DEBUG-SavedPlaces: no row deleted")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func segmentSwitch() {
        if segment.selectedSegmentIndex == 0 {
            tableView.isHidden = false
            collectionView.isHidden = true
        } else {
            tableView.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    @objc func addLocation() {
        print("DEBUG-SavedPlacesVC: addLocation button tapped..")
        dismissSavedPlacesVC()
        
        //send the notification to HomeVC to add new location
        NotificationCenter.default.post(name: .addNewLocation, object: nil)
    }
    
    //this is only used when we rename the title of a savedLocation from MapVC
    func fetchSavedLocations() {
        showPresentLoadingView(true, message: "Loading..")
        Service.fetchLocations { locationArray in
            self.savedLocationsArray = locationArray
            print("DEBUG-SavedPlaces: we have \(self.savedLocationsArray.count) savedPlaces")
            self.noSaveLabel()
            self.tableView.reloadData()
            self.collectionView.reloadData()
            self.showPresentLoadingView(false, message: "Loading..")
        }
    }
    
    func noSaveLabel() {
        if self.savedLocationsArray.count == 0 {
            self.noLocationSavedLabel.isHidden = false
        } else {
            self.noLocationSavedLabel.isHidden = true
        }
    }
    
//MARK: - Deletion
    
    func confirmDeleteAndShareAlert(rowIndex: Int, titleDeleted: String) {
        let alert = UIAlertController (title: "Deleted this item?", message: "\"\(titleDeleted)\" will be permanently deleted from the server", preferredStyle: .alert)
        let cancel  = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction (title: "Delete", style: .destructive) { delete in
            self.nowDelete(rowNumber: rowIndex)
        }
        let share = UIAlertAction(title: "Share", style: .default) { share in
            self.nowShare(rowNumber: rowIndex)
        }
        
        alert.addAction(cancel)
        alert.addAction(share)
        alert.addAction(delete)
        present(alert, animated: true, completion: nil)
    }
    
    func nowDelete(rowNumber: Int) {
        print("DEBUG-savedPlacesVC: deletion confirmed..")
        self.showPresentLoadingView(true, message: "Deleting..")
        
        Service.deleteItem(nameItem: self.savedLocationsArray[rowNumber].time) { (error) in

            self.showPresentLoadingView(false, message: "Deleting..")
            if let e = error?.localizedDescription {
                print("DEBUG-SavedPlacesVC: error is \(e)")
                self.alert(error: e, buttonNote: "Try again")
                return
            }
            
            self.showSuccess(show: true, view: self.view)
            print("DEBUG-SavedPlacesVC: sucessfully deleting item")
            self.showSuccess(show: false, view: self.view) //got few secs delayed
            self.fetchSavedLocations()
            self.didDeleteRow = true
        }
    }
    
    //share the location (or image if you want)
    func nowShare(rowNumber: Int) {
        let titleLocation = savedLocationsArray[rowNumber].title
        let lati = savedLocationsArray[rowNumber].latitude
        let longi = savedLocationsArray[rowNumber].longtitude
        
        let url = Service.sharingLocationURL(lat: lati, long: longi, titleL: titleLocation)
        
        guard let LocationUrl = URL(string: url) else {
            print("DEBUG-MapVC: error setting urlString for sharing")
            self.alert(error: "Please make sure that the name of the location has no apostrophe ", buttonNote: "OK")
            return
        }
        
        let shareText = "Share \"\(titleLocation)\""
        
        let vc = UIActivityViewController(activityItems: [shareText, LocationUrl], applicationActivities: nil)
        present(vc, animated: true, completion: nil)
    }
    
    
//MARK: - Long Press
    
    func longPressStuff() {
        let longPressTab = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressTab(sender:)))
        let longPressColl = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressColl(sender:)))
        tableView.addGestureRecognizer(longPressTab)
        collectionView.addGestureRecognizer(longPressColl)
    }
    
    @objc func handleLongPressTab(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let index = tableView.indexPathForRow(at: touchPoint) {
                
                print("DEBUG-SavedPlaces: tab row \(index.row) deleted")
                let itemTitle = savedLocationsArray[index.row].title
                confirmDeleteAndShareAlert(rowIndex: index.row, titleDeleted: itemTitle)
            }
        }
    }
    
    @objc func handleLongPressColl(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let index = collectionView.indexPathForItem(at: touchPoint) {
                print("DEBUG-SavedPlaces: coll row \(index.row) deleted")
                let itemTitle = savedLocationsArray[index.row].title
                confirmDeleteAndShareAlert(rowIndex: index.row, titleDeleted: itemTitle)
            }
        }
    }
    
    
}


//MARK: - tableView Datasource

extension savedPlacesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedLocationsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: savedPlacesIdentifier, for: indexPath) as! LocationCell
        cell.info = savedLocationsArray[indexPath.row]
        
        return cell
    }
    
    //this func creates a swipe gesture to delete a row
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let itemTitle = savedLocationsArray[indexPath.row].title
        confirmDeleteAndShareAlert(rowIndex: indexPath.row, titleDeleted: itemTitle)
    }
    
    
}

//MARK: - tableView Delegate

extension savedPlacesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true) //unhighlight the selected row/cell
        print("DEBUG-SavedPlacesVC: select row \(indexPath.row)")
        
        let vc = MapViewController()
        vc.locationInfo = savedLocationsArray[indexPath.row] //pass data to MapVC
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

//MARK: - collectionView datasource

extension savedPlacesViewController: UICollectionViewDataSource {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedLocationsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! LocationPin
        cell.backgroundColor = .clear
        cell.infoCollection = savedLocationsArray[indexPath.row]
        
        return cell
    }
    
}

//MARK: - collectionView delegate

extension savedPlacesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("DEBUG-savedPlacesVC: ")
        
        let vc = MapViewController()
        vc.locationInfo = savedLocationsArray[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: - DelegateFlowlayout

extension savedPlacesViewController: UICollectionViewDelegateFlowLayout {
    
    //spacing for row (horizontally) between items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //spacing for collumn (vertically) between items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //set size for each item
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width) / 2
        return CGSize(width: width, height: width) //it's a square
    }
    
    
}
