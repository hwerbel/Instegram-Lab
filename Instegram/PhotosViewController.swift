//
//  PhotosViewController.swift
//  Instegram
//
//  Created by user116136 on 1/28/16.
//  Copyright © 2016 Hannah Werbel. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var photos: [NSDictionary]?
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Instegram Most Popular"
        tableView.rowHeight = 320
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "didRefresh", forControlEvents: .ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        loadMoreData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let photos = photos {
            return photos.count
        } else {
            return 0
        }
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell

        let photo = photos![indexPath.row]
        let imagePath = photo.valueForKeyPath("images.low_resolution.url") as! String
            print("photo\(imagePath)")
            let imageUrl = NSURL(string: imagePath)
            print("url\(imageUrl)")
            cell.photoView.setImageWithURL(imageUrl!)
        
        
        
        
        
        return cell
    }
    
    func loadMoreData () {
        let clientId = "e05c462ebd86446ea48a5af73769b602"
        let url = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(clientId)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                self.isMoreDataLoading = false
                self.loadingMoreView!.stopAnimating()
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.photos = responseDictionary["data"] as! [NSDictionary]
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                    }
                }
        });
        task.resume()

    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollViewOffsetThreshhold = scrollViewContentHeight - tableView.bounds.size.height
            
            if (scrollView.contentOffset.y > scrollViewOffsetThreshhold && tableView.dragging) {
                isMoreDataLoading = true
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                loadMoreData()
            }
        }
    }
    
    func didRefresh() {
        loadMoreData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var cell = sender as! UITableViewCell
        var vc = segue.destinationViewController as! PhotoDetailsViewController
        var indexPath = tableView.indexPathForCell(cell)
        let photo = photos![indexPath!.row]
        
        vc.photo = photo
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
