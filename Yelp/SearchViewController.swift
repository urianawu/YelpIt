//
//  SearchViewController.swift
//  Yelp
//
//  Created by you wu on 2/9/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import AlgoliaSearch

@objc protocol SearchViewControllerDelegate {
    optional func searchViewController(searchViewController: SearchViewController, didUpdateSearch term: String)
}

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var termSearchBar = UISearchBar()
    weak var delegate: SearchViewControllerDelegate?
    
    var index : Index!
    var searchSuggests = [String]()
    var defaultSuggests = [String]()
    var searchTerm = String()
    var searchLocation = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        termSearchBar.sizeToFit()
        navigationItem.titleView = termSearchBar
        termSearchBar.becomeFirstResponder()

        tableView.dataSource = self
        tableView.delegate = self
        termSearchBar.delegate = self
        
        indexSearch()

        self.searchTerm = "Restaurants"
        
        //default suggestions
        defaultSuggests.append("Restaurants")
        defaultSuggests.append("Bars")
        defaultSuggests.append("Coffee & Tea")
        defaultSuggests.append("Dinner")
        defaultSuggests.append("Nightlife")
        defaultSuggests.append("Wings")
        defaultSuggests.append("Steakhouse")
        searchSuggests = defaultSuggests
        self.tableView.reloadData()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchSuggests = defaultSuggests
            self.tableView.reloadData()

        } else {
            self.searchTerm = searchText
            //do search query
            index.search(Query(query: searchText), block: { (content, error) -> Void in
                if error == nil {
                    let hits = content!["hits"] as! [NSDictionary]
                    var hitResults = [String]()
                    for hit in hits {
                        hitResults.append(hit["title"] as! String)
                    }
                    self.searchSuggests = hitResults
                    self.tableView.reloadData()

                }
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchSuggests.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath)
        cell.textLabel!.text = searchSuggests[indexPath.row]
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath)
        cell.selectionStyle = .None
        self.searchTerm = searchSuggests[indexPath.row]
        onSearchButton(cell)
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onSearchButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        print("searching... \(self.searchTerm)")
        delegate?.searchViewController?(self, didUpdateSearch: self.searchTerm)
    }
    
    func indexSearch() {
        let client = AlgoliaSearch.Client(appID: "P4VTR8SXK9", apiKey: "6b3b16d3cacfad35924e8b15e47f0297")
        index = client.getIndex("yelp_categories")
    }
/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
