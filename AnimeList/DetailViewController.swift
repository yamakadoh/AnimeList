//
//  DetailViewController.swift
//  AnimeList
//
//  Created by yamakadoh on 1/12/15.
//  Copyright (c) 2015 yamakadoh. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()

        self.navigationItem.title = "Youtube検索結果"

        searchYoutube()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func searchYoutube() {
        let API_KEY = "管理画面から発行したAPIキー"
        let title = self.detailItem as String
        let searchWord:String! = title.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let url = NSURL(string: "https://www.googleapis.com/youtube/v3/search?key=\(API_KEY)&q=\(searchWord)&part=snippet&maxResults=10&order=viewCount")
        let urlRequest = NSURLRequest(URL: url!)

        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {(response, jsonData, error) -> Void in
            let dict:NSDictionary = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
            println(dict)

            let resultArray: NSArray = dict["items"] as NSArray
        })
    }
}
