//
//  CellDecoy.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 5/23/21.
//

import UIKit
import MapKit

class LocationPin: UICollectionViewCell {
    
//MARK: - Components
    
    private let mapView = MKMapView()
    private let mapDimension: CGFloat = 100
    var infoCollection: SavedLocations! {
        didSet {
            titleLabel.text = infoCollection?.title
            configureMapView()
        }
    }
    
    private let bigView: UIView = {
        let vw = UIView()
        vw.layer.cornerRadius = 20
        vw.layer.borderWidth = 1
        vw.layer.borderColor = UIColor.black.cgColor
        
        return vw
    }()
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Loading..."
        lb.textColor = .black
        lb.textAlignment = .center
        lb.numberOfLines = 2
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        return lb
    }()
    
//MARK: - View Scenes
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        mapView.isUserInteractionEnabled = false
        mapView.overrideUserInterfaceStyle = .light
        
        //bigView
        addSubview(bigView)
        bigView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10)
        
        //mapView
        bigView.addSubview(mapView)
        mapView.layer.cornerRadius = mapDimension / 2
        mapView.layer.borderWidth = 0.7
        mapView.layer.borderColor = UIColor.black.cgColor
        mapView.anchor(top: bigView.topAnchor, paddingTop: 12, width: mapDimension, height: mapDimension)
        mapView.centerX(inView: bigView)
        
        //label
        bigView.addSubview(titleLabel)
        titleLabel.anchor(top: mapView.bottomAnchor, left: bigView.leftAnchor, right: bigView.rightAnchor, paddingTop: 12, paddingLeft: 8, paddingRight: 8)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//MARK: - MapView
    //let's deal with the mapView for each cell
    func configureMapView() {
        let coor = CLLocationCoordinate2D(latitude: infoCollection.latitude, longitude: infoCollection.longtitude)
        
        //let's setup the region
        let region = MKCoordinateRegion(center: coor, latitudinalMeters: 1000, longitudinalMeters: 1000) //make 100m distance around the center
        mapView.setRegion(region, animated: false)
        
        //let's add annotation to configure the center
        let anno = MKPointAnnotation()
        anno.coordinate = coor
        mapView.addAnnotation(anno)
        //mapView.selectAnnotation(anno, animated: true) //make anno big
    }
    
}
