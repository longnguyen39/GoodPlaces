//
//  BottomAction.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 5/8/21.
//

import UIKit

protocol BottomActionDelegate: class {
    func zoom()
    func dismissBottomAction()
    func openOnMap()
}

class BottomAction: UIView {
    
    //when var got modified, the didSet gets called. we can bring all func in didSet to viewDidLoad
    var titleLabel = "title..." {
        didSet { locationLabel.text = titleLabel }
    }
    
    var distanceMile = "0.0" {
        didSet { distanceLabel.text = "\(distanceMile) mi" }
    }
    
    //this get filled in HomeVC
    var placeInfo: SavedLocations? {
        didSet {
            locationLabel.text = placeInfo?.title
        }
    }
    
    weak var delegate: BottomActionDelegate?
    
//MARK: - Components
    
    private let locationLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Loading..."
        lb.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        lb.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.8)
        lb.numberOfLines = 1
//        lb.adjustsFontSizeToFitWidth = true
        
        return lb
    }()
    
    private let distanceLabel: UILabel = {
        let lb = UILabel()
        lb.text = "..."
        lb.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lb.textColor = .lightGray
        lb.textAlignment = .right
        lb.backgroundColor = .clear
        lb.numberOfLines = 1
        lb.adjustsFontSizeToFitWidth = true
        
        return lb
    }()
    
    private let dismissButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "xmark.circle"), for: .normal)
        btn.tintColor = .red
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        return btn
    }()
    
    private let openMapButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Open Map", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        btn.tintColor = .white
        btn.backgroundColor = .blue
        btn.addTarget(self, action: #selector(openUpMap), for: .touchUpInside)
        
        return btn
    }()
    
    private let zoomButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "location.circle"), for: .normal)
        btn.tintColor = .black
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(zoomToTwoAnno), for: .touchUpInside)
        
        return btn
    }()
    
    
    
//MARK: - View Scenes
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowOffset = CGSize(width: 3, height: -3)
        layer.shadowOpacity = 0.5
        alpha = 0
        isHidden = true
        
        //dismissButton
        addSubview(dismissButton)
        dismissButton.anchor(top: topAnchor, right: rightAnchor, paddingTop: 8, paddingRight: 8, width: 30, height: 30)
        
        //distanceLabel
        addSubview(distanceLabel)
        distanceLabel.anchor(right: dismissButton.leftAnchor, paddingRight: 8, width: 65)
        distanceLabel.centerY(inView: dismissButton)
        
        //locationLabel
        addSubview(locationLabel)
        locationLabel.anchor(top: topAnchor, left: leftAnchor, right: distanceLabel.leftAnchor, paddingTop: 12, paddingLeft: 16, paddingRight: 8)
        
        //zoomButton
        addSubview(zoomButton)
        zoomButton.anchor(bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingBottom: 20, paddingRight: 12, width: 50, height: 50)
        zoomButton.layer.cornerRadius = 50 / 2
        
        //openMapButton
        addSubview(openMapButton)
        openMapButton.anchor(top: zoomButton.topAnchor, left: leftAnchor, right: zoomButton.leftAnchor, paddingLeft: 12, paddingRight: 12, height: 50)
        openMapButton.layer.cornerRadius = 12
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//MARK: - Actions
    
    @objc func dismissView() {
        delegate?.dismissBottomAction()
    }
    
    @objc func zoomToTwoAnno() {
        delegate?.zoom()
    }
    
    @objc func openUpMap() {
        delegate?.openOnMap()
    }
    
    
    
}
