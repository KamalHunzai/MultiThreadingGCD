//
//  ViewController.swift
//  MultiThreadingGCD
//
//  Created by Kamal on 26/01/2015.
//  Copyright (c) 2015 Kamal. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,APIControllerProtocol {
    
    var api = APIController()

    var tableData = []
    @IBOutlet var appsTableView: UITableView!
    
    var imageCache = [String:UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        api.searchItunesFor("Pakistan Sign Langugage")
        self.api.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        var resultsArr:NSArray = results["results"] as NSArray
        dispatch_async(dispatch_get_main_queue(), {
        self.tableData = resultsArr
        self.appsTableView!.reloadData()
        
        
        })
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("SearchResultCell") as UITableViewCell
        
        let rowData:NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        // Add a check to make sure this exists
        let cellText:String? = rowData["trackName"] as? String
        cell.textLabel?.text = cellText
        cell.imageView?.image = UIImage(named: "Blank52")
        
        // Get the formatted price string for display in the subtitle
        
        let formattedPrice:NSString = rowData["formattedPrice"] as NSString
        
        // Jump in to a backgroud thread to get the image this item
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        
        let urlString = rowData["artworkUrl60"] as String
        // check our image cache for the existring key.This is just a dictionary of UIImages
        // var image:UIImage? = self.imageCache.valueForKey(urlString) as? UIImage
        var image = self.imageCache[urlString]
        
        if(image == nil) {
        // if the image does not exist, we need to download it 
            var imgURL:NSURL = NSURL(string: urlString)!
        // Download an NSData representation of the image at the URL 
            let request:NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
                if error == nil{
                image = UIImage(data: data)
                    
                // Store the image in to our cache
                    
                    self.imageCache[urlString] = image
                    dispatch_async(dispatch_get_main_queue(),{
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath){
                        cellToUpdate.imageView?.image = image
                        }
                            })
                        }
                else
                {
                println("Error:\(error.localizedDescription)")
                }
           })
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath){
                cellToUpdate.imageView?.image = image
                
                }
            })
        }
        cell.detailTextLabel?.text = formattedPrice
        
        
//        let imgURL: NSURL? = NSURL(string: urlString)
//        
//        // Download an NSData representation of the image at the URL 
//        
//        let imgData = NSData (contentsOfURL: imgURL!)
//        cell.imageView?.image = UIImage(data: imgData!)
//        
//        // Get the formatted price string for display in the subtitle
//        // let formattedPrice:NSString = rowData["formattedPrice"] as NSString
//        cell.detailTextLabel?.text = formattedPrice
        
        return cell
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        // Get the row data for the selected row
        var rowData:NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        var name:String = rowData["trackname"] as String
        var formattedPrice:String = rowData["formattedPrice"] as String
        var alert:UIAlertView = UIAlertView()
        alert.title = name
        alert.message = formattedPrice
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
   
    
    

}

