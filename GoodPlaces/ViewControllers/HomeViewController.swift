//
//  HomeViewController.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 4/29/21.
//

import UIKit
import Firebase
import MapKit //Xcode default module
import GeoFire
import SDWebImage


class HomeViewController: UIViewController {

//    private var btnD: CGFloat = 36 //this is wrong for lower iOS
    private var btnD: CGFloat = 40 //try this one for lower iOS
    private var ivD: CGFloat = 32
    
    private let mapView = MKMapView()
    private var locationManager: CLLocationManager!
    
    private var logOutObserver: NSObjectProtocol?
    private var deletionOrRenameObserver: NSObjectProtocol?
    private var userInfoObserver: NSObjectProtocol?
    
    private var profileURL: URL? {
        return URL(string: userInfo?.profileImageUrl ?? "no url")
    }
    
    private var arrayLocation = [SavedLocations]()
    private var selectedAnnoInfo: SelectedAnno?
    private var route: MKRoute? //use this to generate polyline
    private var titleNote = "no title" //for rename title
    private var arrayTwoAnno = [MKPointAnnotation]()
    private var hasPolylines = false
    
    private var latShare: CLLocationDegrees?
    private var longShare: CLLocationDegrees?
    private var titleShare: String?

    
//MARK: - Components
    
    //this is invalid for lower iOS version
//    private let savedPlacesButton: UIButton = {
//        let btn = UIButton(type: .system)
//        btn.setBackgroundImage(UIImage(systemName: "bookmark.circle.fill"), for: .normal)
//        btn.tintColor = .white
//        btn.backgroundColor = .black
//        btn.addTarget(self, action: #selector(showSavedPlacesPage), for: .touchUpInside)
//
//        return btn
//    }()
    
    //try this code for the lower iOS version
    private let savedPlacesButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "bookmark.circle"), for: .normal)
        btn.tintColor = .black
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(showSavedPlacesPage), for: .touchUpInside)
        
        return btn
    }()

    //gotta have 2 layers to test out different iOS versions
    private let shareButtonLayer1: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "paperplane.circle.fill"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = .black
        btn.alpha = 0 //for animation stuff
        btn.addTarget(self, action: #selector(shareSavedLocation), for: .touchUpInside)
        
        return btn
    }()
    private let shareButtonLayer2: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "paperplane.circle"), for: .normal)
        btn.tintColor = .blue
        btn.backgroundColor = .clear
        btn.alpha = 0 //for animation stuff
        btn.addTarget(self, action: #selector(shareSavedLocation), for: .touchUpInside)
        
        return btn
    }()
    
    
    //gotta make this "lazy var" to load the tap gesture
    private lazy var labelView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .white
        vw.layer.cornerRadius = 16
        vw.layer.shadowOffset = CGSize(width: 4, height: 4)
        vw.layer.shadowOpacity = 0.7
        vw.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showSettingPage))
        vw.addGestureRecognizer(tap)
        
        return vw
    }()
    
    //gotta make this "lazy var" to load the tap gesture
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.circle")
        iv.tintColor = .lightGray
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showSettingPage))
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    //gotta make this "lazy var" to load the tap gesture
    lazy var usernameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Loading..."
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lb.textColor = .black
        lb.textAlignment = .left
        lb.isUserInteractionEnabled = true
        //lb.adjustsFontSizeToFitWidth = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showSettingPage))
        lb.addGestureRecognizer(tap)
        
        return lb
    }()
    
    private var labelAlt: UILabel = {
        let lb = UILabel()
        lb.text = "..."
        lb.textColor = .black
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        return lb
    }()
    
    private let markLocationButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Mark location", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        btn.backgroundColor = .blue
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(markLocationTapped), for: .touchUpInside)
        
        return btn
    }()
    
    private let centerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "location.circle"), for: .normal)
        btn.backgroundColor = .clear
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(centerCurrentLocation), for: .touchUpInside)
        
        return btn
    }()
    
    private let zoomInButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "arrow.down.forward.and.arrow.up.backward.circle"), for: .normal)
        btn.backgroundColor = .clear
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(zoomCurrentLocation), for: .touchUpInside)
        
        return btn
    }()
    
    private var bottomView = BottomAction()

    //when "userInfo" got changed, the "didSet" got called
    var userInfo: User? {
        didSet {
            print("DEBUG-HomeVC: userInfo just changes")
            usernameLabel.text = userInfo?.username ?? "Tap to sign in"
            profileImageView.sd_setImage(with: profileURL)
        }
    }
    
    
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        locationManager.allowsBackgroundLocationUpdates = true
        configureMapView()
        configureUI()
        
        authentication()
        protocolVC()
        
    }
    
    //let's set default color for status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .darkContent
    }
    
    func configureUI() {
        view.backgroundColor = #colorLiteral(red: 0.2864701468, green: 0.6212142493, blue: 0.5792253521, alpha: 1)
        
        //savePlacesButton
        view.addSubview(savedPlacesButton)
        savedPlacesButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 16)
        savedPlacesButton.setDimensions(height: btnD-2, width: btnD-2)
        savedPlacesButton.layer.cornerRadius = (btnD-2) / 2
        
        //labelAlt
        view.addSubview(labelAlt)
        labelAlt.anchor(top: savedPlacesButton.bottomAnchor, left: savedPlacesButton.leftAnchor, paddingTop: 12)
        labelAlt.isHidden = true
        
        //shareButtonLayer1
        view.addSubview(shareButtonLayer1)
        shareButtonLayer1.anchor(right: view.rightAnchor, paddingRight: 12)
        shareButtonLayer1.centerY(inView: savedPlacesButton)
        shareButtonLayer1.setDimensions(height: btnD, width: btnD)
        shareButtonLayer1.layer.cornerRadius = btnD/2
        shareButtonLayer1.isHidden = true
        
        //shareButtonLayer2
        view.addSubview(shareButtonLayer2)
        shareButtonLayer2.anchor(right: view.rightAnchor, paddingRight: 12)
        shareButtonLayer2.centerY(inView: savedPlacesButton)
        shareButtonLayer2.setDimensions(height: btnD, width: btnD)
        shareButtonLayer2.layer.cornerRadius = btnD/2
        shareButtonLayer2.isHidden = true
        
        //emailLabel and view
        view.addSubview(labelView)
        labelView.centerY(inView: savedPlacesButton)
        labelView.anchor(left: savedPlacesButton.rightAnchor, right: shareButtonLayer1.leftAnchor, paddingLeft: 28, paddingRight: 28, height: btnD)
        
        labelView.addSubview(profileImageView)
        profileImageView.anchor(left: labelView.leftAnchor, paddingLeft: 6)
        profileImageView.centerY(inView: labelView)
        profileImageView.setDimensions(height: ivD, width: ivD)
        profileImageView.layer.cornerRadius = ivD / 2
        
        labelView.addSubview(usernameLabel)
        usernameLabel.centerY(inView: labelView)
        usernameLabel.anchor(left: profileImageView.rightAnchor, right: labelView.rightAnchor, paddingLeft: 6, paddingRight: 14)
        
        //bottomView (appear when we tap on an anno)
        view.addSubview(self.bottomView)
        bottomView.anchor(left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, height: 155)
        
        //centerButton
        view.addSubview(centerButton)
        centerButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 20, paddingRight: 16, width: 50, height: 50)
        
        //zoomInButton
        view.addSubview(zoomInButton)
        zoomInButton.anchor(bottom: centerButton.topAnchor, right: centerButton.rightAnchor, paddingBottom: 12, width: 50, height: 50)
        
        //markLocationButton
        view.addSubview(markLocationButton)
        markLocationButton.anchor(left: view.leftAnchor, right: centerButton.leftAnchor, paddingLeft: 16, paddingRight: 12, height: 50)
        markLocationButton.centerY(inView: centerButton)
        markLocationButton.layer.cornerRadius = 12
        
    }
    
//MARK: - mapView
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame //cover the entire screen
        mapView.overrideUserInterfaceStyle = .light
        
        mapView.showsUserLocation = true //show a blue dot indicating current location
        mapView.userTrackingMode = .follow //detect when user is moving. in the simulator, go on the status bar on top, tap "Feature" -> "Location" -> "custom location", and change the lat/longtitude
        mapView.delegate = self
    }
    
//MARK: - Protocol VC
    
    func protocolVC() {
        logOutObserver = NotificationCenter.default.addObserver(forName: .didLogOut, object: nil, queue: .main) { [weak self] _ in
            
            print("DEBUG-HomeVC: logged out update notified..")
            guard let strongSelf = self else { return }
            
            //strongSelf.usernameLabel.text = "Tap to sign in"
            //strongSelf.profileImageView.image = UIImage(systemName: "person.circle")
            strongSelf.removeAllAnno()
            strongSelf.showLoginPage()
        }
        
        deletionOrRenameObserver = NotificationCenter.default.addObserver(forName: .didDeleteOrRenameItem, object: nil, queue: .main) { [weak self] _ in
            
            print("DEBUG-HomeVC: item deleted notified..")
            guard let strongSelf = self else { return }
            strongSelf.removeAllAnno()
            strongSelf.fetchSavedLocations()
        }
        
        userInfoObserver = NotificationCenter.default.addObserver(forName: .didChangeUserInfo, object: nil, queue: .main) { [weak self] _ in
            print("DEBUG-HomeVC: new username notified..")
            guard let strongSelf = self else { return }
            strongSelf.fetchUserData() //fetch again to fill new data in userInfo and trigger the "didSet"
        }
        
    }
    
    //this func is exclusively unique for protocol
    deinit {
        if let observer1 = logOutObserver {
            NotificationCenter.default.removeObserver(observer1)
        }
        if let observer2 = deletionOrRenameObserver {
            NotificationCenter.default.removeObserver(observer2)
        }
        if let observer3 = userInfoObserver {
            NotificationCenter.default.removeObserver(observer3)
        }
        
    }
    
//MARK: - Show stuff
    
    func showNav(controller: UIViewController) {
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @objc func showSettingPage() {
        let vc = SettingViewController()
        showNav(controller: vc)
    }
    
    @objc func showSavedPlacesPage() {
        let vc = savedPlacesViewController()
        showNav(controller: vc)
    }
    
//MARK: - share stuff
    
    //share the location (or image if you want)
    @objc func shareSavedLocation() {
        guard let titleForShare = titleShare else { return }
        
        var url = Service.sharingLocationURL(lat: latShare!, long: longShare!, titleL: titleForShare)
        
        //let's verify the url before sharing
        if let urlTest = URL(string: url) {
            print("DEBUG-HomeVC: url is good \(urlTest)")
        } else {
            print("DEBUG-HomeVC: url is bad, gotta construct it")
            url = Service.sharingLocationURL(lat: latShare!, long: longShare!, titleL: "SavedPlace")
        }
        
        guard let LocationUrl = URL(string: url) else { return }
        print("DEBUG-HomeVC: locationURL is \(LocationUrl)")
        
        let shareText = "Share \"\(titleForShare)\""
        
        let vc = UIActivityViewController(activityItems: [shareText, LocationUrl], applicationActivities: nil)
        present(vc, animated: true, completion: nil)
    }
    
//MARK: - API stuff
    
    //let's check authentification
    func authentication() {
        let mail = Auth.auth().currentUser?.email ?? "nil"
        print("DEBUG-HomeVC: user log in as \(mail)")
        
        if mail == "nil" {
            print("DEBUG-HomeVC: user not logged in..")
            //usernameLabel.text = "Tap to sign in"
            showLoginPage()
        } else {
            fetchingStuff()
        }
        
    }
    
    func fetchUserData() {
        //let's fill in with data
        print("DEBUG-HomeVC: fetching user data")
        Service.fetchUserInfo { userStuff in
            self.userInfo = userStuff
        }
    }
    
    func fetchingStuff() {
        fetchUserData()
        fetchSavedLocations()
        enableLocationService()
    }
    
    //let do some alerts location
    func alertLocation (Title: String, comment: String, buttonNote1: String, buttonNote2: String) {
        
        let alert = UIAlertController (title: Title, message: comment, preferredStyle: .alert)
        let action1 = UIAlertAction (title: buttonNote1, style: .cancel, handler: nil)
        let action2 = UIAlertAction (title: buttonNote2, style: .default) { (action) in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!) //open the app setting
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        present (alert, animated: true, completion: nil)
    }
    
//MARK: - Mark location
    
    @objc func markLocationTapped() {
        centerCurrentLocation() //let's re-center to current location
        //let's wait for 0.3 sec to show user his current location
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.textBox()
        }
    }
    
    
    func textBox() {
        var textField = UITextField()
        
        let alertBox = UIAlertController(title: "Title", message: "Please name your current location.", preferredStyle: .alert)
        let cancel = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "Save", style: .default) { (action) in
            //let's verify the textField
            if textField.text?.isEmpty == false && textField.text?.starts(with: " ") == false {
                
                self.showPresentLoadingView(true, message: "Saving")
                self.titleNote = textField.text!
                print("DEBUG: title created: \(self.titleNote)")
                self.markLocation()
                
            } else {
                print("DEBUG: textField is empty..")
                self.alert(error: "Please enter a title", buttonNote: "Try again")
            }
        }
        
        alertBox.addTextField { (alertTextField) in
            alertTextField.placeholder = "Where are you now?"
            alertTextField.autocapitalizationType = .words
            textField = alertTextField //set customized textField = alert default textField
        }
        alertBox.addAction(cancel)
        alertBox.addAction(action)
        present(alertBox, animated: true, completion: nil)
    }
    
    //gotta use func "enableLocationService" to access current lat and long
    func markLocation() {
        print("DEBUG-HomeVC: marking current location..")
        
        guard let latitude = locationManager.location?.coordinate.latitude else { return }
        guard let longitude = locationManager.location?.coordinate.longitude else { return }
        guard let altitude = locationManager.location?.altitude else { return } // altitude in meters
        
        Service.uploadLocation(title: titleNote, lat: latitude, long: longitude, alt: altitude) { error in
            
            //let's delay for 0.3 sec to show user the loadingIndicator
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("DEBUG-HomeVC: successfully upload result")
                self.showPresentLoadingView(false, message: "Saving")
                
                if let e = error?.localizedDescription {
                    self.alert(error: e, buttonNote: "OK")
                    return
                }
                self.succesfullyMarkLocation()
            }
        }
    }
    
    func succesfullyMarkLocation() {
        self.showSuccess(show: true, note: "Saved", view: self.view)
        print("DEBUG: successfully save and upload location")
        self.addAnnoToCurrentLocation(newTitle: self.titleNote) //add an anno to indicate current location
        self.showSuccess(show: false, note: "Saved", view: self.view) //got delay a bit to show success mark
    }
    
//MARK: - Actions
    
    func addAnnoToCurrentLocation(newTitle: String) {
        guard let currentCoor = locationManager.location?.coordinate else { return }
        let anno = MKPointAnnotation()
        anno.coordinate = currentCoor
        anno.title = newTitle
        
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true) //make anno big and standout
    }
    
    func addAnnoToSavedLocations(lat: CLLocationDegrees, long: CLLocationDegrees, titleFetch: String, alt: Double) {
        
        //you can use this way, or the way below it (which can add title)
//        let coor = CLLocationCoordinate2D(latitude: lat, longitude: long)
//        let anno = LocationAnnotation(coordinateLoca: coor)
        
        let anno = MKPointAnnotation()
        let stringAlt = String(format: "%.2f", alt)
        anno.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        anno.title = titleFetch
        anno.subtitle = "\(stringAlt) m"
        mapView.addAnnotation(anno)
    }
    
    func removeAllAnno() {
        //loop through all added anno and remove them
        mapView.annotations.forEach { annotation in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        print("DEBUG-HomeVC: done removing all anno..")
    }
    
    @objc func centerCurrentLocation() {
        guard let coordinate = locationManager?.location?.coordinate else { return }
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000) //we got 1000 meters around the current location
        mapView.setRegion(region, animated: true)
    }
    
    @objc func zoomCurrentLocation() {
        guard let coordinate = locationManager?.location?.coordinate else { return }
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10, longitudinalMeters: 10)
        mapView.setRegion(region, animated: true)
    }
    
    //remember to add the extension "MKMapViewDelegate" below
    func generatePolyline(toCoor: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: toCoor)
        let mapSavedPlace = MKMapItem(placemark: placemark)
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = mapSavedPlace
        request.transportType = .automobile
        
        let directionResquest = MKDirections(request: request)
        directionResquest.calculate { (res, error) in
            guard let response = res else { return }
            self.route = response.routes[0] //there are many routes lead to a destination, we just take the first route
            print("DEBUG-HomeVC: we have \(response.routes.count) routes")
            guard let polyline = self.route?.polyline else {
                print("DEBUG-HomeVC: no polyline")
                return
            }
            self.mapView.addOverlay(polyline) //let's add the polyline
        }
    }
    
    //MARK: - BottomAction
    
    func configureBottomAction(title: String, distance: String, altitude: String) {
        UIView.animate(withDuration: 0.3) {
            self.markLocationButton.alpha = 0
            self.centerButton.alpha = 0
            self.zoomInButton.alpha = 0
        } completion: { _ in
            self.bottomView.isHidden = false
            self.shareButtonLayer1.isHidden = true //test out different iOS
            self.shareButtonLayer2.isHidden = false
            self.labelAlt.isHidden = false
            
            //pass the data
            self.bottomView.delegate = self
            self.bottomView.titleLabel = title
            self.bottomView.distanceMile = distance
            self.labelAlt.text = altitude
            
            UIView.animate(withDuration: 0.3) {
                self.bottomView.alpha = 1
                self.shareButtonLayer1.alpha = 1
                self.shareButtonLayer2.alpha = 1
                self.labelAlt.alpha = 1
            }
        }
        
    }
    
    func removeAllPolyline() {
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
        //if u want to remove 1 polyline, use the code elow
//        guard let polyline = self.route?.polyline else { return }
//        self.mapView.removeOverlay(polyline)
    }
    
    func distanceInMile(lat: CLLocationDegrees, long: CLLocationDegrees) -> String? {
        
        guard let currentLoca = locationManager.location else { return "" }
        let savedLocation = CLLocation(latitude: lat, longitude: long)
        
        let distanceInMeters = currentLoca.distance(from: savedLocation)
        print("DEBUG-HomeVC: distance is \(distanceInMeters) meters")
        
        let distanceMile = distanceInMeters / 1609
        let d = String(format: "%.1f", distanceMile) //round to 1 decimals
        return d
    }
    
//MARK: - Fetch saved Locations
    
    func fetchSavedLocations() {
        //after we have the big array of all savedLocation, loop through that array and for each loop, we add an anno to it
        Service.fetchLocations { locationArray in
            print("DEBUG-HomeVC: fetching all locations..")
            self.arrayLocation = locationArray
            
            for info in self.arrayLocation {
                self.addAnnoToSavedLocations(lat: info.latitude, long: info.longtitude, titleFetch: info.title, alt: info.altitude)
            }
            print("DEBUG-HomeVC: done adding all anno of savedLocations")
        }
        
    }//end of func
    

}


//MARK: - Privacy Location
//remember to modify the info.plist (go to Notes to see details) before writing these codes, otherwise it crashes
extension HomeViewController: CLLocationManagerDelegate {
    
    //this func will check the location status of the app
    func enableLocationService() {
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        
        //this case is the default case
        case .notDetermined:
            print("DEBUG: location notDetermined")
            //locationManager?.requestWhenInUseAuthorization() //ask user to access location, when user allows to access, we hit case "whenInUse"
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            print("DEBUG: location restricted/denied")
            alertLocation(Title: "Locations needed", comment: "Please allow GoodPlaces to access your location in Setting", buttonNote1: "Cancel", buttonNote2: "Setting")
            break
        case .authorizedAlways: //so this app only works in case of "authorizedAlways", in real app, we can modify it
            print("DEBUG: location always")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest //get current user's location and zoom into it
        case .authorizedWhenInUse:
            print("DEBUG: location whenInUse")
            //locationManager?.requestAlwaysAuthorization() //ask user 2 things (always allow or allow when app is used)
        @unknown default:
            print("DEBUG: location default")
            break
        }
    }
    
    //let's evaluate the case from HomeVC, it activates after we done picking a case in func "enableLocationService"
    //this one need inheritance from "CLLocationManagerDelegate"
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            print("DEBUG: current status is whenInUse, requesting always")
            //locationManager.requestAlwaysAuthorization() //ask user 2 things (always allow or allow when app is used)
        } else if status == .authorizedAlways {
            print("DEBUG: current status is always")
        } else if status == .denied {
            print("DEBUG: current status is denied")
            alertLocation(Title: "Locations needed", comment: "Please allow GoodPlaces to access your location in Setting", buttonNote1: "Cancel", buttonNote2: "Setting")
        }
    }
    
    
}

//MARK: - MapViewDelegate
//remember to write "MapView.delegate = self" in viewDidLoad
extension HomeViewController: MKMapViewDelegate {
    
    //let's construct the polyline from current location to savedPlace
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .black
            lineRenderer.lineWidth = 3
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
    
    //this dictates what happen when we tap on an annotation OR add a new one
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let toCoor = view.annotation?.coordinate else { return }
        guard let coorCurrent = locationManager.location?.coordinate else { return }
        guard let titleDestination = view.annotation?.title else { return }
        guard let altDestination = view.annotation?.subtitle else { return }
        guard let distanceToD = distanceInMile(lat: toCoor.latitude, long: toCoor.longitude) else { return }
        
        let anno1 = MKPointAnnotation()
        anno1.coordinate = toCoor
        let anno2 = MKPointAnnotation()
        anno2.coordinate = coorCurrent
        let array = [anno1, anno2] //has currentLocation and destination to zoom
        
        //let's check if user pick the same OR different anno
        let pickedAnno = SelectedAnno(lat: toCoor.latitude, long: toCoor.longitude, title: titleDestination)
        
        if selectedAnnoInfo == pickedAnno {
            print("DEBUG-HomeVC: we already have a polyline for this")
        } else {
            //this case means that user has tapped a new anno after tapping a previous one
            if hasPolylines {
                //remove the previous polyline
                print("DEBUG-HomeVC: removing a polyline..")
                guard let polyline = self.route?.polyline else { return }
                self.mapView.removeOverlay(polyline)
                
                //set some info for the new anno
                arrayTwoAnno = array
                selectedAnnoInfo = SelectedAnno(lat: toCoor.latitude, long: toCoor.longitude, title: titleDestination) //for checking if user has tapped on this anno
                
                //let's present a polyline, zoom to it, and show bottomAction
                generatePolyline(toCoor: toCoor)
                mapView.zoomToFit(annotations: self.arrayTwoAnno) //zoom to 2 points in the array
                configureBottomAction(title: titleDestination ?? "nope", distance: distanceToD, altitude: altDestination ?? "none")
                
                //assign the info so that we can indicate duplicating taps
                latShare = toCoor.latitude
                longShare = toCoor.longitude
                titleShare = titleDestination
                
            } else { //user has initially tapped on an anno
                
                //let's pass info to global-class var
                arrayTwoAnno = array
                selectedAnnoInfo = SelectedAnno(lat: toCoor.latitude, long: toCoor.longitude, title: titleDestination)
                
                //let's do some cool stuff
                generatePolyline(toCoor: toCoor)
                mapView.zoomToFit(annotations: self.arrayTwoAnno) //zoom to 2 points in the array
                configureBottomAction(title: titleDestination ?? "nope", distance: distanceToD, altitude: altDestination ?? "none")
                
                //assign the info so that we can indicate duplicating taps
                latShare = toCoor.latitude
                longShare = toCoor.longitude
                titleShare = titleDestination
                hasPolylines = true
            }
        }
        
    }//end of func
    
    
}

//MARK: - BottomActionDelegate
//remember to write ".delegate = self" in viewDidLoad
extension HomeViewController: BottomActionDelegate {
    
    func zoom() {
        mapView.zoomToFit(annotations: arrayTwoAnno) //"arrayTwoAnno" got filled up when we tappe on an anno
    }
    
    func dismissBottomAction() {
        print("DEBUG-HomeVC: protocol from BottomAction, dismiss BottomAction")
        removeAllPolyline()
        centerCurrentLocation()
        hasPolylines = false
        selectedAnnoInfo = nil
        
        UIView.animate(withDuration: 0.3) {
            self.bottomView.alpha = 0
            self.shareButtonLayer1.alpha = 0
            self.shareButtonLayer2.alpha = 0
            self.labelAlt.alpha = 0
        } completion: { _ in
            self.bottomView.isHidden = true
            self.shareButtonLayer1.isHidden = true
            self.shareButtonLayer2.isHidden = true
            self.labelAlt.isHidden = true
            UIView.animate(withDuration: 0.3) {
                self.markLocationButton.alpha = 1
                self.centerButton.alpha = 1
                self.zoomInButton.alpha = 1
            }
        }
    }
    
    func openOnMap() {
        openMap(lati: selectedAnnoInfo?.lat, longi: selectedAnnoInfo?.long, nameMap: selectedAnnoInfo?.title)
    }
    
}
