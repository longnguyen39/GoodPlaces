//
//  LocationCell.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 5/23/21.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell {
    
//MARK: - Components
    
    private let mapView = MKMapView()
    private let mapDimension: CGFloat = 80
    var info: SavedLocations! {
        didSet {
            titleLabel.text = info?.title
            configureMapView()
        }
    }
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Loading..."
        lb.textColor = .black
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        return lb
    }()
    
   
//MARK: - View Scene
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        mapView.isUserInteractionEnabled = false
        mapView.overrideUserInterfaceStyle = .light
        
        //the ROWHEIGHT is ONLY specified in the MapVC, NO where else
        accessoryType = .disclosureIndicator
        backgroundColor = .clear
        
        //mapView
        addSubview(mapView)
        mapView.layer.cornerRadius = mapDimension / 2
        mapView.layer.borderWidth = 0.7
        mapView.layer.borderColor = UIColor.black.cgColor
        mapView.anchor(left: leftAnchor, paddingLeft: 12, width: mapDimension, height: mapDimension)
        mapView.centerY(inView: self)
        
        //titleLabel
        addSubview(titleLabel)
        titleLabel.anchor(left: mapView.rightAnchor, paddingLeft: 8)
        titleLabel.centerY(inView: mapView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//MARK: - MapView
    //let's deal with the mapView for each cell
    func configureMapView() {
        let coor = CLLocationCoordinate2D(latitude: info.latitude, longitude: info.longtitude)

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
