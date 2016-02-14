//
//  FiltersViewController.swift
//  Yelp
//
//  Created by you wu on 2/13/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewController:FiltersViewController, didUpdateFilters filters: [String: AnyObject])
}

class FiltersViewController: UITableViewController, CategoryFiltersViewControllerDelegate {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var sortLabel: UILabel!
    @IBOutlet weak var dealSwitch: UISwitch!
    
    weak var delegate: FiltersViewControllerDelegate?
    
    let distanceOptions: [String] = ["Best Match", "0.3 miles", "1 mile", "5 miles", "20 miles"]
    let sortOptions: [String] = ["Best Match", "Distance", "Rating"]
    
    var expanded: [Bool] = [false, false, false, false]
    
    var filteredCategories = [String]()
    var hasDeal = false
    var sortOption = YelpSortMode.BestMatched.rawValue
    var distance = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let dist = defaults.objectForKey("radius") as? String{
            self.distanceLabel.text = dist
        }
        if let sort = defaults.objectForKey("sort") as? String{
            self.sortLabel.text = sort
        }
        if defaults.boolForKey("deal") {
            self.hasDeal = defaults.boolForKey("deal")
            if (hasDeal) {
                dealSwitch.on = true
            }else {
                dealSwitch.on = false
            }
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        var filters = [String : AnyObject]()
        filters["categories"] = filteredCategories
        filters["deal"] = hasDeal
        filters["sort"] = sortOption
        filters["distance"] = distance
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(hasDeal, forKey: "deal")
        defaults.setObject(sortLabel.text, forKey: "sort")
        defaults.setObject(distanceLabel.text, forKey: "radius")
        defaults.synchronize()
        
        delegate?.filtersViewController?(self, didUpdateFilters: filters)

    }
    // MARK: - Table view data source

    @IBAction func onDealSwitch(sender: AnyObject) {
        hasDeal = !hasDeal
    }
    
    func updateSortOption(selected: Int) {
        sortLabel.text = sortOptions[selected]
        sortOption = selected
    }
    
    func updateDistanceOption(selected: Int) {
        distanceLabel.text = distanceOptions[selected]
        switch(selected) {
        case 0:
            self.distance = 0
            break
        case 1:
            self.distance = 483 //0.3 miles
            break
        case 2:
            self.distance = 1610
            break
        case 3:
            self.distance = 8046
            break
        case 4:
            self.distance = 32186
            break
        default:
            break
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if expanded[section] {
            if section == 2 {
                //distance
                return 5
            }else {
                //sort by
                return 3
            }
        } else {
            ///we just want the header cell
            return 1
        }

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section > 1 {
                switch indexPath.section {
                case 2:
                    if indexPath.row == 0 {
                        //reset first row text
                        distanceLabel.text = distanceOptions[0]
                    }
                    if expanded[indexPath.section] {
                        updateDistanceOption(indexPath.row)
                    }
                    break
                case 3:
                    if indexPath.row == 0 {
                        //reset first row text
                        sortLabel.text = sortOptions[0]
                    }
                    if expanded[indexPath.section] {
                        updateSortOption(indexPath.row)
                    }
                    break
                default:
                    break
            }
            expanded[indexPath.section] = !expanded[indexPath.section]

            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as!UINavigationController
        if let categoryFiltersViewController = navigationController.topViewController as? CategoryFiltersViewController {
            categoryFiltersViewController.delegate = self
        }
        
    }
    
    func categoryFiltersViewController(categoryFiltersViewController: CategoryFiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        if let categories = filters["categories"] as? [String] {
            self.filteredCategories = categories
        }else {
            self.filteredCategories = []
        }
    }

}
