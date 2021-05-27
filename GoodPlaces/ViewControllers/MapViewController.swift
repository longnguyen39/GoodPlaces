//
//  MapViewController.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 5/4/21.
//

import UIKit
import MapKit
import Firebase
import MobileCoreServices //to share location via shareSheet

class MapViewController: UIViewController {

    var titleChanged = "title changed"
    var locationInfo: SavedLocations? //got data passed from SavedPlacesVC
    private var didRename = false
    
    private let mapView = MKMapView()
    private var locationManager: CLLocationManager!
    private var route: MKRoute? //use this to generate polyline
    
//MARK: - Components
    
    private lazy var distanceView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .white
        vw.layer.cornerRadius = 16
        vw.layer.shadowOffset = CGSize(width: 4, height: 4)
        vw.layer.shadowOpacity = 0.7
        vw.isUserInteractionEnabled = true
        
        return vw
    }()
    
    private var distanceLabel: UILabel = {
        let lb = UILabel()
        lb.text = "0.0 mi"
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        lb.textColor = .black
        lb.isUserInteractionEnabled = true
        lb.adjustsFontSizeToFitWidth = true
        
        return lb
    }()
    
    private let zoomInButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "arrow.down.forward.and.arrow.up.backward.circle"), for: .normal)
        btn.backgroundColor = .clear
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(zoomInAnnotation), for: .touchUpInside)
        
        return btn
    }()
    
    private let openMapButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Open Map", for: .normal)
        btn.backgroundColor = .blue
        btn.tintColor = .white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        btn.addTarget(self, action: #selector(openMapButtonTapped), for: .touchUpInside)
        
        return btn
    }()
    
    private let zoomOutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "arrow.up.backward.and.arrow.down.forward.circle"), for: .normal)
        btn.backgroundColor = .clear
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(zoomOutAnnotation), for: .touchUpInside)
        
        return btn
    }()
    
    
//MARK: - View scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureMapView()
        configureUI()
        enableLocationService()
        constructSavedLocation()
    }
    
    func configureUI() {
        view.backgroundColor = .white
        guard let titlePrivate = locationInfo?.title else { return }
        configureNavigationBar(title: titlePrivate, preferLargeTitle: false, backgroundColor: #colorLiteral(red: 0.2898526224, green: 0.9193441901, blue: 0.5178573741, alpha: 1), buttonColor: .blue)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .done, target: self, action: #selector(backToList))
        
        //set multiple barButtonItems on the right
        let btn1 = UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .done, target: self, action: #selector(shareLocation))
        let btn2 = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .done, target: self, action: #selector(editTitleTapped))
        navigationItem.setRightBarButtonItems([btn1, btn2], animated: true)
        
        //distance stuff
        view.addSubview(distanceView)
        distanceView.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 12, paddingRight: 12, width: 100, height: 30)
        
        distanceView.addSubview(distanceLabel)
        distanceLabel.anchor(left: distanceView.leftAnchor, right: distanceView.rightAnchor, paddingLeft: 10, paddingRight: 10)
        distanceLabel.centerY(inView: distanceView)
        
        //zoomInButton
        view.addSubview(zoomInButton)
        zoomInButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 20, paddingRight: 16, width: 50, height: 50)
        
        //zoomOutButton
        view.addSubview(zoomOutButton)
        zoomOutButton.anchor(left: view.leftAnchor, paddingLeft: 16, width: 50, height: 50)
        zoomOutButton.centerY(inView: zoomInButton)
        
        //openMapButton
        view.addSubview(openMapButton)
        openMapButton.anchor(left: zoomOutButton.rightAnchor, right: zoomInButton.leftAnchor, paddingLeft: 12, paddingRight: 12, height: 50)
        openMapButton.centerY(inView: zoomInButton)
        openMapButton.layer.cornerRadius = 12
    }
    
    
//MARK: - mapView
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame //cover the entire screen
        mapView.overrideUserInterfaceStyle = .light
        
        mapView.showsUserLocation = true //show a blue dot indicating current location
        mapView.userTrackingMode = .follow //dot will move if current location moves
        mapView.delegate = self //to enable all func in the extension "MKMapViewDelegate"
        
    }

//MARK: - Actions
    
    @objc func backToList() {
        navigationController?.popViewController(animated: true)
        if didRename {
            print("DEBUG-MapVC: did rename")
            //send the notification to SavedPlacesVC to reload and fetch data
            NotificationCenter.default.post(name: .didRenameTitle, object: nil)
        } else {
            print("DEBUG-MapVC: no rename")
        }
    }
    
    @objc func editTitleTapped() {
        print("DEBUG-MapVC: title edit request..")
        textBox()
    }
    
    @objc func zoomInAnnotation() {
        guard let lat = locationInfo?.latitude else { return }
        guard let long = locationInfo?.longtitude else { return }
        
        let locationAnno = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let savedPlace = locationAnno
        let region = MKCoordinateRegion(center: savedPlace, latitudinalMeters: 2000, longitudinalMeters: 2000) //we got 2000 meters around the current location
        mapView.setRegion(region, animated: true)
    }
    
    @objc func zoomOutAnnotation() {
        //let's show all annotations on map, including the current location
        let twoAnnotation = mapView.annotations
        mapView.showAnnotations(twoAnnotation, animated: true)
        mapView.zoomToFit(annotations: twoAnnotation)
    }
    
    @objc func openMapButtonTapped() {
        print("DEBUG-MapVC: openMapButton tapped..")
        openMap(lati: locationInfo?.latitude, longi: locationInfo?.longtitude, nameMap: locationInfo?.title)
    }
    
//MARK: - Share location
    
    //share the location (or image if you want)
    @objc func shareLocation() {
        guard let titleLocation = locationInfo?.title else { return }
        guard let lati = locationInfo?.latitude else { return }
        guard let longi = locationInfo?.longtitude else { return }
        
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
    
    
    
//MARK: - Map stuff
    
    func constructSavedLocation() {
        guard let lati = locationInfo?.latitude else { return }
        guard let longi = locationInfo?.longtitude else { return }
        guard let titleFetched = locationInfo?.title else { return }
        
        //let's add an annotation to savedLocation
        let locationAnno = CLLocationCoordinate2D(latitude: lati, longitude: longi)
        let anno = MKPointAnnotation()
        anno.coordinate = locationAnno
        anno.title = titleFetched
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true)
        
        //re-center savedLocation for user to see it clearly
        zoomInAnnotation()
        
        //let's generate a polyline to savedLocation
        generatePolyline(toCoor: locationAnno)
        
        //let's indicate the distance label
        distanceInMile(lat: lati, long: longi)
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
            print("DEBUG-MapVC: we have \(response.routes.count) routes")
            guard let polyline = self.route?.polyline else {
                print("DEBUG-MapVC: no polyline")
                return
            }
            self.mapView.addOverlay(polyline) //let's add the polyline
        }
    }
    
    func distanceInMile(lat: CLLocationDegrees, long: CLLocationDegrees) {
        //use this way or construct "currentLoca" by the shorter way below
//        guard let currentLat = locationManager.location?.coordinate.latitude else { return }
//        guard let currentLong = locationManager.location?.coordinate.longitude else { return }
//        let currentLoca = CLLocation(latitude: currentLat, longitude: currentLong)
        
        //we need func enableLocationService to do this. Use this to construct "currentLoca" or the way above
        guard let currentLoca = locationManager.location else { return }
        let savedLocation = CLLocation(latitude: lat, longitude: long)
        
        let distanceInMeters = currentLoca.distance(from: savedLocation)
        print("DEBUG-MapVC: distance is \(distanceInMeters) meters")
        
        let distanceMile = distanceInMeters / 1609
        let d = String(format: "%.1f", distanceMile) //round to 1 decimals

        self.distanceLabel.text = "\(d) mi"
    }
    
    
    //MARK: - textBox
    
    func textBox() {
        var textField = UITextField()
        
        let alertBox = UIAlertController(title: "Edit title", message: "Rename to...", preferredStyle: .alert)
        let cancel = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "Save", style: .default) { (action) in
            //let's verify the textField
            if textField.text?.isEmpty == false && textField.text?.starts(with: " ") == false {
                
                self.showPresentLoadingView(true, message: "Saving")
                self.titleChanged = textField.text!
                print("DEBUG-MapVC: title update: \(self.titleChanged)")
                self.updateTitle()
                
            } else {
                print("DEBUG: textField is empty..")
                self.alert(error: "Please enter a valid input", buttonNote: "Try again")
            }
        }
        alertBox.addTextField { (alertTextField) in
            guard let currentTitle = self.locationInfo?.title else { return }
            alertTextField.text = currentTitle
            alertTextField.placeholder = "New title"
            alertTextField.autocapitalizationType = .words
            
            textField = alertTextField
        }
        alertBox.addAction(cancel)
        alertBox.addAction(action)
        present(alertBox, animated: true, completion: nil)
    }
    
    //MARK: - update title
    func updateTitle() {
        print("DEBUG-MapVC: updating title..")
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        guard let time = locationInfo?.time else { return }
        
        let data = ["title": titleChanged] as [String: Any]
        
        Firestore.firestore().collection("users").document(userEmail).collection("saved-locations").document(time).updateData(data) { error in
            
            self.showPresentLoadingView(false, message: "Saving")
            if let e = error?.localizedDescription {
                print("DEBUG: error updating title - \(e)")
                self.showLoader(show: false, view: self.view)
                self.alert(error: e, buttonNote: "Try again")
                return
            }
            
            self.successfullyUpdateTitle(newTitle: self.titleChanged)
        }
        
    }
    
    func successfullyUpdateTitle(newTitle: String) {
        self.showSuccess(show: true, note: "Saved", view: self.view)
        print("DEBUG-MapVC: successfully update title")
        self.navigationItem.title = newTitle
        
        self.showSuccess(show: false, note: "Saved", view: self.view) //got delay a bit to show success mark
        self.didRename = true
    }
    
    
}

//MARK: - MapViewDelegate

extension MapViewController: MKMapViewDelegate {
    //remember to write "MapView.delegate = self" in viewDidLoad
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
    
    
}

//MARK: - Privacy Location
//remember to modify the info.plist (go to Notes to see details) before writing these codes, otherwise it crashes
extension MapViewController: CLLocationManagerDelegate {
    
    //this func will check the location status of the app and enable us to obtain the coordinates of the user.
    //remember to call it in ViewDidLoad
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
