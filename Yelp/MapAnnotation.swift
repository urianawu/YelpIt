//
//  MapAnnotation.swift
//  Yelp
//
//  Created by you wu on 2/11/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    let title: String?
    var imageName: NSURL!
    let coordinate: CLLocationCoordinate2D
    let ratingImageURL: NSURL
    let review: String!
    let categories: String!
    
    init(business: Business) {
        self.title = business.name!
        self.ratingImageURL = business.ratingImageURL!
        self.review = "\(business.reviewCount!) reviews"
        self.categories = business.categories!
        self.coordinate = business.coordinate!
        if let image = business.imageURL{
            self.imageName = image
        }else {
            self.imageName = nil
        }
        super.init()
    }

}
