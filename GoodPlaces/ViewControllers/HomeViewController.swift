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

    private var btnD: CGFloat = 36
    private var ivD: CGFloat = 32
    private let mapView = MKMapView()
    private var logOutObserver: NSObjectProtocol?
    private var profileURL: URL? {
        return URL(string: userInfo?.profileImageUrl ?? "no url")
    }
    
    private var locationManager: CLLocationManager!
    private var arrayLocation = [SavedLocations]()
    private var selectedAnnoInfo: SelectedAnno?
    private var route: MKRoute? //use this to generate polyline
    private var titleChanged = "no title"
    private var arrayTwoAnno = [MKPointAnnotation]()
    private var hasPolylines = false
    
//MARK: - Components
    
    private let savedPlacesButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "bookmark.circle.fill"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = .black
        btn.addTarget(self, action: #selector(showSavedPlacesPage), for: .touchUpInside)
        
        return btn
    }()

    
    private let friendsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "person.2.circle.fill"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = .black
        btn.isEnabled = false
        btn.addTarget(self, action: #selector(showlistFriendsPage), for: .touchUpInside)
        
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
    
    private var bottomView = BottomAction()

    //when "userInfo" got changed, the "didSet" got called
    var userInfo: User? {
        didSet {
            print("DEBUG: userInfo just changes")
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
        enableLocationService()
        fetchSavedLocations()
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
        
        //friendsButton
        view.addSubview(friendsButton)
        friendsButton.anchor(right: view.rightAnchor, paddingRight: 12)
        friendsButton.centerY(inView: savedPlacesButton)
        friendsButton.setDimensions(height: btnD, width: btnD)
        friendsButton.layer.cornerRadius = btnD/2
        
        
        //emailLabel and view
        view.addSubview(labelView)
        labelView.centerY(inView: savedPlacesButton)
        labelView.anchor(left: savedPlacesButton.rightAnchor, right: friendsButton.leftAnchor, paddingLeft: 28, paddingRight: 28, height: btnD)
        
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
        bottomView.anchor(left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, height: 170)
        
        //centerButton
        view.addSubview(centerButton)
        centerButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 20, paddingRight: 16, width: 50, height: 50)
        
        
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
        
    }
    
    //this func is exclusively unique for protocol
    deinit {
        if let observer1 = logOutObserver {
            NotificationCenter.default.removeObserver(observer1)
        }
        
    }
    
//MARK: - Show stuff
    
    func showStuff(controller: UIViewController) {
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @objc func showSettingPage() {
        let mail = Auth.auth().currentUser?.email
        
        if mail == nil {
            print("DEBUG-HomeVC: user not signed in, no Setting page..")
            alertSignIn(Title: "Sign in required!", comment: "Please sign in to see your profile.", buttonNote1: "Cancel", buttonNote2: "Sign in")
        } else {
            let vc = SettingViewController()
            showStuff(controller: vc)
        }
        
    }
    
    @objc func showlistFriendsPage() {
        let mail = Auth.auth().currentUser?.email
        
        if mail == nil {
            print("DEBUG-HomeVC: user not signed in, no Friends page..")
            alertSignIn(Title: "Sign in required!", comment: "Please sign in to see your list of friends.", buttonNote1: "Cancel", buttonNote2: "Sign in")
        } else {
            let vc = FriendsViewController()
            showStuff(controller: vc)
        }
        
    }
    
    @objc func showSavedPlacesPage() {
        let mail = Auth.auth().currentUser?.email
        
        if mail == nil {
            print("DEBUG-HomeVC: user not signed in, no places page..")
            alertSignIn(Title: "Sign in required!", comment: "Please sign in to see your saved places.", buttonNote1: "Cancel", buttonNote2: "Sign in")
        } else {
            let vc = savedPlacesViewController()
            showStuff(controller: vc)
        }
        
    }
    
    
//MARK: - API stuff
    
    //let's check authentification
    func authentication() {
        let mail = Auth.auth().currentUser?.email ?? "nil"
        print("DEBUG-HomeVC: user log in as \(mail)")
        
        if mail == "nil" {
            print("DEBUG: user not logged in..")
            //usernameLabel.text = "Tap to sign in"
            showLoginPage()
        } else {
            fetchUserData()
            fetchSavedLocations()
        }
        
    }
    
    func fetchUserData() {
        //let's fill in with data
        Service.fetchUserInfo { userStuff in
            self.userInfo = userStuff
        }
    }
    
    
    //let do some alerts signIn
    func alertSignIn (Title: String, comment: String, buttonNote1: String, buttonNote2: String) {
        
        let alert = UIAlertController (title: Title, message: comment, preferredStyle: .alert)
        let action1 = UIAlertAction (title: buttonNote1, style: .cancel, handler: nil)
        let action2 = UIAlertAction (title: buttonNote2, style: .default) { (action) in
            self.showLoginPage()
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        present (alert, animated: true, completion: nil)
    }
    
//MARK: - Mark location
    
    @objc func markLocationTapped() {
        let mail = Auth.auth().currentUser?.email
        
        if mail == nil {
            print("DEBUG-HomeVC: user not signed in, no location mark..")
            alertSignIn(Title: "Sign in required!", comment: "Please sign in to save places.", buttonNote1: "Cancel", buttonNote2: "Sign in")
        } else {
            centerCurrentLocation() //let re-center to current location
            //let's wait for 0.5 sec to show user his current location
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.textBox()
            }
            
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
                self.titleChanged = textField.text!
                print("DEBUG: title created: \(self.titleChanged)")
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
        
        guard let lat = locationManager.location?.coordinate.latitude else {
            print("DEBUG-HomeVC: error setting current location")
            return
        }
        guard let long = locationManager.location?.coordinate.longitude else { return }
        
        Service.uploadLocation(title: titleChanged, lat: lat, long: long) { error in
            
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
        self.addAnnoToCurrentLocation(newTitle: self.titleChanged) //add an anno to indicate current location
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
    
    func addAnnoToSavedLocations(lat: CLLocationDegrees, long: CLLocationDegrees, titleFetch: String) {
        
        //you can use this way, or the way below (which can add title)
//        let coor = CLLocationCoordinate2D(latitude: lat, longitude: long)
//        let anno = LocationAnnotation(coordinateLoca: coor)
        
        let anno = MKPointAnnotation()
        anno.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        anno.title = titleFetch
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
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000) //we got 2000 meters around the current location
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
    
    func configureBottomAction(title: String, distance: String) {
        UIView.animate(withDuration: 0.3) {
            self.markLocationButton.alpha = 0
            self.centerButton.alpha = 0
        } completion: { _ in
            self.bottomView.isHidden = false
            self.bottomView.delegate = self
            self.bottomView.titleLabel = title
            self.bottomView.distanceMile = distance
            UIView.animate(withDuration: 0.3) {
                self.bottomView.alpha = 1
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
            
            self.arrayLocation = locationArray
            
            for info in self.arrayLocation {
                self.addAnnoToSavedLocations(lat: info.latitude, long: info.longtitude, titleFetch: info.title)
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
    
    //let's evaluate the case from HomeVC, this one need inheritance from "CLLocationManagerDelegate"
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            print("DEBUG: current status is whenInUse, requesting always")
            //locationManager.requestAlwaysAuthorization() //ask user 2 things (always allow or allow when app is used)
        } else if status == .authorizedAlways {
            print("DEBUG: current status is always")
        } else if status == .denied {
            print("DEBUG: current status is denied")
            locationManager.requestWhenInUseAuthorization()
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
    
    //this dictates what happen when we tap on an annotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let toCoor = view.annotation?.coordinate else { return }
        guard let coorCurrent = locationManager.location?.coordinate else { return }
        guard let titleDestination = view.annotation?.title else { return }
        guard let distanceToD = distanceInMile(lat: toCoor.latitude, long: toCoor.longitude) else { return }
        
        let anno1 = MKPointAnnotation()
        anno1.coordinate = toCoor
        let anno2 = MKPointAnnotation()
        anno2.coordinate = coorCurrent
        let array = [anno1, anno2] //has currentLocation and destination
        
        //let's check if user pick the same OR different anno
        let pickedAnno = SelectedAnno(lat: toCoor.latitude, long: toCoor.longitude, title: titleDestination)
        
        if selectedAnnoInfo == pickedAnno {
            print("DEBUG-HomeVC: we already have a polyline for this")
        } else {
            //this case means that user has tapped a new anno
            if hasPolylines {
                //remove the previous polyline
                print("DEBUG: removing a polyline..")
                guard let polyline = self.route?.polyline else { return }
                self.mapView.removeOverlay(polyline)
                
                //present a new one, zoom to it, update info of BottomAction
                arrayTwoAnno = array
                selectedAnnoInfo = SelectedAnno(lat: toCoor.latitude, long: toCoor.longitude, title: titleDestination)
                
                generatePolyline(toCoor: toCoor)
                mapView.zoomToFit(annotations: self.arrayTwoAnno) //zoom to 2 points in the array
                configureBottomAction(title: titleDestination ?? "nope", distance: distanceToD)
                
            } else { //user has not tapped on any anno yet
                
                //let's pass info to global-class var
                arrayTwoAnno = array
                selectedAnnoInfo = SelectedAnno(lat: toCoor.latitude, long: toCoor.longitude, title: titleDestination)
                
                //let's do some cool stuff
                generatePolyline(toCoor: toCoor)
                mapView.zoomToFit(annotations: self.arrayTwoAnno) //zoom to 2 points in the array
                configureBottomAction(title: titleDestination ?? "nope", distance: distanceToD)
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
        removeAllPolyline()
        centerCurrentLocation()
        hasPolylines = false
        selectedAnnoInfo = nil
        
        UIView.animate(withDuration: 0.3) {
            self.bottomView.alpha = 0
        } completion: { _ in
            self.bottomView.isHidden = true
            UIView.animate(withDuration: 0.3) {
                self.markLocationButton.alpha = 1
                self.centerButton.alpha = 1
            }
        }
    }
    
    func openOnMap() {
        openMap(lati: selectedAnnoInfo?.lat, longi: selectedAnnoInfo?.long, nameMap: selectedAnnoInfo?.title)
    }
    
}
