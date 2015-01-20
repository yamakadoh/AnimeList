//
//  DetailViewController.swift
//  AnimeList
//
//  Created by yamakadoh on 1/12/15.
//  Copyright (c) 2015 yamakadoh. All rights reserved.
//

import UIKit

class VideoInfo {
    var title: String
    var countPlay: Int
    var url: String
    var thumbnail: String
    
    init(title: String, countPlay: Int, url: String, thumbnail: String) {
        self.title = title
        self.countPlay = countPlay
        self.url = url
        self.thumbnail = thumbnail
    }
}

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var objects = NSMutableArray()
    var videoInfoObjects = NSMutableArray()
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    var resultArray: NSArray = []
    var searchBar = UISearchBar(frame: CGRectMake(0, 0, 320, 44))
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
        }

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
        
        
        
        // 検索バー
        //var searchBar = UISearchBar(frame: CGRectMake(0, 0, 320, 44))
        searchBar.tintColor = UIColor.darkGrayColor()
        searchBar.placeholder = "Youtube検索"
        searchBar.text = self.detailItem as String
        searchBar.keyboardType = UIKeyboardType.Default
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar   // UINavigationBar上に、UISearchBarを追加
        //searchBar.becomeFirstResponder()  // 検索バーにフォーカスを設定
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
                let count = 1000    // あとで設定する（検索結果に含まれないから別のAPIを叩く必要がある？）
                let videoId = (item["id"] as NSDictionary)["videoId"] as String
                let thumbnail = ((snippet["thumbnails"] as NSDictionary)["default"] as NSDictionary)["url"] as String
                let info = VideoInfo(title: snippet["title"] as String, countPlay: count, url: "http://www.youtube.com/watch?v=" + videoId, thumbnail: thumbnail)
                self.videoInfoObjects.addObject(info)
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
        return videoInfoObjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as UITableViewCell
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyCell")
        
        let object = videoInfoObjects[indexPath.row] as VideoInfo
        cell.textLabel!.text = object.title
        cell.detailTextLabel!.text = "再生数:" + object.countPlay.description
        cell.imageView?.image = UIImage(named: "icon_test.png")
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: object.thumbnail)!), queue:NSOperationQueue.mainQueue()){(res, data, err) in
            let image = UIImage(data: data)
            cell.imageView?.image = image
        }
        
        return cell
    }
    
    // Cellが選択された際に呼び出される.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.resultArray[indexPath.row] as NSDictionary
        let videoId = (item["id"] as NSDictionary)["videoId"] as String
        let url = NSURL(string: "http://www.youtube.com/watch?v=" + videoId)
        UIApplication.sharedApplication().openURL(url!)
    }


    // MARK: - UISearchBar
    // テキストが変更される毎に呼ばれる
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.text = searchText
    }
    
    // Cancelボタンが押された時に呼ばれる
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = self.detailItem as String
        searchBar.resignFirstResponder()    // キーボードを閉じる
    }

    // Searchボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()    // キーボードを閉じる
    }
}
