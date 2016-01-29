//
//  PhotosViewController.swift
//  Instegram
//
//  Created by user116136 on 1/28/16.
//  Copyright © 2016 Hannah Werbel. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    var photos: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Instegram Most Popular"
        tableView.rowHeight = 320
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.registerClass(PhotoCell.self, forCellReuseIdentifier: "PhotoCell")
        
        
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
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                        self.photos = responseDictionary["data"] as! [NSDictionary]
                       
                        self.tableView.reloadData()
                    }
                }
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @available(iOS 2.0, *)
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let photos = photos {
            return photos.count
        } else {
            return 0
        }
    }
    
    @available(iOS 2.0, *)
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell

        let photo = photos![indexPath.row]
        let imagePath = photo.valueForKeyPath("images.low_resolution.url") as! String
            print("photo\(imagePath)")
            let imageUrl = NSURL(string: imagePath)
            print("url\(imageUrl)")
            cell.photoView.setImageWithURL(imageUrl!)
        
        
        
        
        
        return cell
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
