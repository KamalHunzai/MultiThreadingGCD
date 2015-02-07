//
//  APIController.swift
//  MultiThreadingGCD
//
//  Created by Kamal on 26/01/2015.
//  Copyright (c) 2015 Kamal. All rights reserved.
//

import Foundation

protocol APIControllerProtocol{

    func didReceiveAPIResults(results:NSDictionary)

}

class APIController{
    
    var delegate:APIControllerProtocol?
    init(){
    }
    
    func searchItunesFor (searchTerm:String) {
        // The itunes Api multiple terms separated by + symbols, so replace spaces with + signs
        
        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+" , options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        // Now escape anything else that isn't URL-Friendly
        
        if let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
let urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&media=software"
            
            let url = NSURL(string: urlPath)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: {data,response,error -> Void in
                println("Task Completed")
                if (error != nil) {
                    // If there is an error in the web request, print it to console
                    println(error.localizedDescription)
                }
                var err:NSError?
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
                println(jsonResult)
                if (err != nil) {
                    // If there is an error paring JSON, Print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                let results:NSArray = jsonResult["results"] as NSArray
                self.delegate?.didReceiveAPIResults(jsonResult)
            })
            task.resume()
        }
    }



}