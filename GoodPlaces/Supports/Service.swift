//
//  UserInfo.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 4/30/21.
//

import UIKit
import Firebase
import CoreLocation

struct Service {
    
    static func fetchUserInfo(completion: @escaping(User) -> Void) {
        
        print("DEBUG-Service: fetching user info..")
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("DEBUG-Service: cannot fetch email..")
            return
        }
        
        Firestore.firestore().collection("users").document(userEmail).getDocument { (snapshot, error) in
            
            if let e = error?.localizedDescription {
                print("DEBUG-Service: cant fetch userInfo..\(e)")
                return
            }
            
            guard let dictionaryUser = snapshot?.data() else {
                print("DEBUG-Service: error setting user data..")
                return
            }
            
            let userInfoFetched = User(dictionary: dictionaryUser)
            completion(userInfoFetched)
        }
    }
    
    static func fetchUserStats(completion: @escaping(Int) -> Void) {
        
        print("DEBUG-Service: fetching user stats..")
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("DEBUG-Service: cannot fetch email..")
            return
        }
        
        Firestore.firestore().collection("users").document(userEmail).collection("saved-locations").getDocuments { (snapshot, error) in
            
            if let e = error?.localizedDescription {
                print("DEBUG-Service: cant fetch user stats..\(e)")
                return
            }
            
            let numberOfSavedLocations = snapshot?.count ?? 0
            print("DEBUG-Service: we have \(numberOfSavedLocations) saved")
            completion(numberOfSavedLocations)
        }
        
    }
    
    
    static func uploadLocation(title: String, lat: CLLocationDegrees, long: CLLocationDegrees, completionBlock: @escaping(Error?) -> Void) {
        
        guard let email = Auth.auth().currentUser?.email else { return }
        
        //construct a timestamp, convert to String and upload to database
        let time = Timestamp(date: Date()) //current date
        let dateValue = time.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //just search GG to find an appropriate date format
        let timeMark = dateFormatter.string(from: dateValue)
        let timeKey = "\(timeMark)"
        
        //create the data set
        let data = [
            "latitude": lat,
            "longitude": long,
            "title": title,
            "timestamp": timeKey
        ] as [String : Any]
        
        //upload to database
        Firestore.firestore().collection("users").document(email).collection("saved-locations").document(timeKey).setData(data, completion: completionBlock)
    }
    
    
    static func fetchLocations(completionBlock: @escaping([SavedLocations]) -> Void) {
        
        guard let email = Auth.auth().currentUser?.email else { return }
        let query = Firestore.firestore().collection("users").document(email).collection("saved-locations").order(by: "timestamp", descending: true) //fetch data base on chronological order, either true or false
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            print("DEBUG-Service: we have \(documents.count) saved locations")
            
            //this "map" function get run as many times as "documents.count" to fill in the array "locations". use this or for-loop func
            let locationArray = documents.map({
                SavedLocations(dictionary: $0.data()) //get all data in a document
            })
            print("DEBUG-Service: big array notifi is: \(locationArray)")
            completionBlock(locationArray)
        }
    }
    
    
    static func deleteItem(nameItem: String, completionBlock: @escaping(Error?) -> Void) {
        
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("DEBUG-Service: cannot fetch email..")
            return
        }
        
        Firestore.firestore().collection("users").document(userEmail).collection("saved-locations").document(nameItem).delete(completion: completionBlock)
        
    }
    
    
    static func sharingLocationURL(lat: Double, long: Double, titleL: String) -> String {
        
        let titleNoSpace = titleL.replacingOccurrences(of: " ", with: "") //to construct the url
        let urlString = "https://maps.apple.com?ll=\(lat),\(long)&q=\(titleNoSpace)&_ext=EiQpzUnuGHYRQUAx0xl+LFqWXcA5zUnuGHYRQUBB0xl+LFqWXcA%3D&t=m" //this url is contructed from messing up with telegram
        
        return urlString
    }
    
    
}
