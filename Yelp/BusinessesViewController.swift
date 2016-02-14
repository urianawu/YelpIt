//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD
import CoreLocation

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, FiltersViewControllerDelegate, SearchViewControllerDelegate {
    
    var businesses: [Business]!
    var searchTerm = String("Restaurants")
    var searchSort = 0
    var searchRadius = 0
    var filteredCategories = [String]()
    var hasDeal = Bool(false)
    var offset = Int(0)
    var location = CLLocation(latitude: 30.601433, longitude: -96.314464)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var mapButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var showMap = false
    var locationManager : CLLocationManager!

    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?

    var i = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        //search button
        searchButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        
        //table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        //map view
        mapView.hidden = true
        mapView.delegate = self
        goToLocation(location)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
        
        // Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: YelpSortMode.Distance.rawValue, radius: 0, categories:[], deals: false, offset: 0) { (businesses: [Business]!, error: NSError!) -> Void in
        self.businesses = businesses
        self.tableView.reloadData()

        }
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        }else {
            return 0
        }
    }
    
    @IBAction func onMapButton(sender: AnyObject) {
        let transitionOptions: UIViewAnimationOptions = [.TransitionFlipFromRight, .ShowHideTransitionViews]
        if (self.showMap) {
            mapButton.title = "Map"
        }else {
            mapButton.title = "List"
            self.updateMap()
            

        }
        
        UIView.transitionWithView(tableView, duration: 0.5, options: transitionOptions, animations: {
            self.tableView.hidden = !self.showMap
            }, completion: nil)
        
        UIView.transitionWithView(mapView, duration: 0.5, options: transitionOptions, animations: {
            self.mapView.hidden = self.showMap
            }, completion: nil)
        self.showMap = !self.showMap
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        
        return cell
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            mapView.setRegion(region, animated: false)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? MapAnnotation {
            
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier("id")
            if view == nil {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
            }
            
            view!.canShowCallout = true
            view!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            if annotation.imageName != nil {
                imageView.setImageWithURL(annotation.imageName!)
            }
            view!.leftCalloutAccessoryView = imageView
            let mapDetailView = MapDetailView()
            mapDetailView.ratingView.setImageWithURL(annotation.ratingImageURL)
            mapDetailView.reviewLabel.text = annotation.review
            mapDetailView.categoryLabel.text = annotation.categories
            if #available(iOS 9.0, *) {
                view!.detailCalloutAccessoryView = mapDetailView
            } else {
                // Fallback on earlier versions
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print(view.annotation?.title)
        if control == view.rightCalloutAccessoryView {
            print("Disclosure Pressed!")
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                // ... Code to load more results ...
                loadMoreData()
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as?UINavigationController {
            if let filtersViewController = navigationController.topViewController as? FiltersViewController {
                filtersViewController.delegate = self
            }
            if let searchViewController = navigationController.topViewController as? SearchViewController {
                searchViewController.delegate = self
            }
        }
        
    }
    
    func searchViewController(searchViewController: SearchViewController, didUpdateSearch term: String) {
        self.searchTerm = term
        updateSearch()

    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        self.filteredCategories = filters["categories"] as! [String]
        self.hasDeal = filters["deal"] as! Bool
        self.searchSort = filters["sort"] as! Int
        self.searchRadius = filters["distance"] as! Int
        updateSearch()
    }
    
    func updateSearch() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        Business.searchWithTerm(searchTerm, sort: searchSort, radius: searchRadius, categories: filteredCategories, deals: hasDeal, offset: 0) { (businesses: [Business]!, error: NSError!) -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.businesses = businesses
            self.tableView.reloadData()
            self.updateMap()
            self.offset = 0
        }
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        for business in businesses {
            //update map view pins
            let info = MapAnnotation(business: business)
            mapView.addAnnotation(info)
            if businesses.indexOf(business) == 0 {
                //display first business
                mapView.selectAnnotation(info, animated: true)
            }
        }
    }
    func loadMoreData() {
        self.offset += 20
        Business.searchWithTerm(searchTerm, sort: searchSort, radius: searchRadius, categories: filteredCategories, deals: hasDeal, offset: offset) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses.appendContentsOf(businesses)
            // Update flag
            self.isMoreDataLoading = false
            
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            self.tableView.reloadData()
        }

    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
}
