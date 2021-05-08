//
//  Extensions.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 4/29/21.
//

import UIKit
import JGProgressHUD
import MapKit
import CoreLocation

//MARK: - AutoLayouts
extension UIView {
    
    //make top, left, bottom, right, width, height optional so we dont have to pass them in whenever we call this func (we can pass them in if needed)
    //The top, left, bottom, right are anchors, which indicate where to aim our constraints, the padding is to set the number (how wide or short the constraints are)
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
      
        
        //in case we pass some optionals above in, then gotta make them active
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    
    //those 2 func below allow us to set up center X and Y
    func centerX(inView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat = 0, constant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: paddingLeft)
        }
    }
    
    //those func below allow us to set up width and height
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func setHeight(height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
}

//MARK: - loader/login/success/alert
extension UIViewController {
    //let's do the spinner of progressHUD
    static let hud = JGProgressHUD(style: .dark)  //each UIViewControllers only has 1 hud to share with each other across the entire project
    
    //the default text value is "loading"
    func showLoader(show: Bool, text: String? = "Loading", view: UIView) {
        
        UIViewController.hud.textLabel.text = text
        
        if show == true {
            print("DEBUG: showing loader..")
            UIViewController.hud.show(in: view) //present the loader
        } else {
            print("DEBUG: dismissing loader..")
            //UIViewController.hud.dismiss(afterDelay: 0.2,animated: true)
            UIViewController.hud.dismiss(animated: true)
        }
    }
    
    
    func showSuccess(show: Bool, note: String? = "Success!", view: UIView) {
        
        UIViewController.hud.textLabel.text = note
        UIViewController.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        if show == true {
            UIViewController.hud.show(in: view)
        } else {
            UIViewController.hud.dismiss(afterDelay: 1.5, animated: true)
        }
    }
    
    
    //let's show login page
    func showLoginPage() {
        //gotta do the "DispatchQueue" to make the LoginVC appear
        DispatchQueue.main.async {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            nav.modalTransitionStyle = .crossDissolve
            self.present(nav, animated: true)
        }
        
    }
    
    //let do some alerts
    func alert (error: String, buttonNote: String) {
        let alert = UIAlertController (title: "Error!!", message: "\(error).", preferredStyle: .alert)
        let tryAgain = UIAlertAction (title: buttonNote, style: .cancel, handler: nil)
                
        alert.addAction(tryAgain)
        present (alert, animated: true, completion: nil)
    }
    
//MARK: - show the loadingView
    func showPresentLoadingView(_ present: Bool, message: String? = nil) {
        
        if present {
            let vw = UIView()
            vw.frame = self.view.frame
            //vw.frame = CGRect(x: (self.view.frame.width-150)/2, y: (self.view.frame.height-150)/2, width: 150, height: 150)
            //vw.layer.cornerRadius = 20
            vw.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.6)
            vw.tag = 1
            
            
            let indicator = UIActivityIndicatorView()
            indicator.style = .whiteLarge
            indicator.center = vw.center
            
            
            let lb = UILabel()
            lb.text = message
            lb.font = UIFont.systemFont(ofSize: 20)
            lb.textColor = .white
            lb.textAlignment = .center
            lb.alpha = 0.87
            
            view.addSubview(vw)
            vw.addSubview(indicator)
            vw.addSubview(lb)
            
            lb.centerX(inView: vw)
            lb.anchor(top: indicator.bottomAnchor, paddingTop: 32)
            
            indicator.startAnimating()
            
        } else {
            view.subviews.forEach { subview in
                if subview.tag == 1 {
                    UIView.animate(withDuration: 0.5) {
                        subview.alpha = 0
                    } completion: { _ in
                        subview.removeFromSuperview()
                    }
                    
                }
            }
        }
    }
    
    //MARK: - open Map
    
    func openMap(lati: CLLocationDegrees?, longi: CLLocationDegrees?, nameMap: String?) {
        print("DEBUG-Extension: openMapButton tapped..")
        guard let lat = lati else { return }
        guard let long = longi else { return }
        guard let nameMapAddress = nameMap else { return }
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(lat, long)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = nameMapAddress
        mapItem.openInMaps(launchOptions: options)
    }
    
    
//MARK: - Navigation bar
    
    //let's customize the navigation bar
    func configureNavigationBar (title: String, preferLargeTitle: Bool, backgroundColor: UIColor, buttonColor: UIColor) {
        
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() //just call it
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black] //enables us to set our big titleColor to black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.backgroundColor = backgroundColor
        
        //just call it for the sake of calling it
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance //when you scroll down, the nav bar just shrinks
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        //specify what show be showing up on the nav bar
        navigationController?.navigationBar.prefersLargeTitles = preferLargeTitle
        navigationItem.title = title
        navigationController?.navigationBar.tintColor = buttonColor //enables us to set the color for the image or any nav bar button
        navigationController?.navigationBar.isTranslucent = true
        
        //this line below specifies the status bar (battery, wifi display) to white, this line of code is only valid for large title nav bar
        navigationController?.navigationBar.overrideUserInterfaceStyle = .light
        
    }
    
    
    
}

//MARK: - extension MKMapView

extension MKMapView {
    //we zoom the map to fit 2 annotations on the screen
    func zoomToFit(annotations: [MKAnnotation]) {
        var zoomRect = MKMapRect.null
        
        annotations.forEach { anno in
            let annotationPoint = MKMapPoint(anno.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
            
        }
        let insets = UIEdgeInsets(top: 100, left: 50, bottom: 170, right: 50)
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
    
    
}
