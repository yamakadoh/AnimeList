//
//  DetailViewController.swift
//  AnimeList
//
//  Created by yamakadoh on 1/12/15.
//  Copyright (c) 2015 yamakadoh. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var objects = NSMutableArray()
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    var resultArray: NSArray = []
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
        }

        self.navigationItem.title = "Youtube検索結果"
        
        // Status Barの高さを取得する.
        let barHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        
        // Viewの高さと幅を取得する.
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        // TableViewの生成する(status barの高さ分ずらして表示).
        let myTableView: UITableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        
        // Cell名の登録をおこなう.
        myTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        myTableView.dataSource = self
        
        // Delegateを設定する.
        myTableView.delegate = self
        
        // Viewに追加する.
        self.view.addSubview(myTableView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()

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

            //let resultArray: NSArray = dict["items"] as NSArray
            self.resultArray = dict["items"] as NSArray
            for item in self.resultArray {
                let snippet = item["snippet"] as NSDictionary
                let title = snippet["title"] as String
                //self.objects.insertObject(title as String, atIndex: 0)
                self.objects.addObject(title as String)
            }
            
            // テーブルビューの更新をするため、メインスレッドにスイッチする
            dispatch_async(dispatch_get_main_queue(), {
                // テーブルビューの更新をする
                // addSubviewしたSubviewを取得するgetSubviewみたいなメソッドはない？
                for subview in self.view.subviews {
                    if (subview as NSObject).dynamicType.isEqual(UITableView.self) {
                        subview.reloadData()
                    }
                }
            })
        })
    }

    // MARK: - Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as UITableViewCell
        
        let object = objects[indexPath.row] as String
        cell.textLabel!.text = object
        return cell
    }
    
    // Cellが選択された際に呼び出される.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.resultArray[indexPath.row] as NSDictionary
        let videoId = (item["id"] as NSDictionary)["videoId"] as String
        let url = NSURL(string: "http://www.youtube.com/watch?v=" + videoId)
        UIApplication.sharedApplication().openURL(url!)
    }
}
