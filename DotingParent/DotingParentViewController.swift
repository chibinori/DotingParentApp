//
//  ViewController.swift
//  DotingParent
//
//  Created by 酒井紀明 on 2016/01/13.
//  Copyright © 2016年 noriaki.sakai. All rights reserved.
//

import UIKit

class DotingParentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // 空行のセパレータを消す
        let v:UIView = UIView(frame: CGRectZero)
        v.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = v
        tableView.tableHeaderView = v
        
        tableView.separatorInset = UIEdgeInsetsZero
        
        let serverAddress = ServerUtility.getAddress()
        NSLog("ServerAddress: " + serverAddress)
    }
    
    var notes: Array<Dictionary<String, AnyObject>> = []
    
    override func viewWillAppear(animated: Bool) {

        let serverAddress = ServerUtility.getAddress()
        
        let url = NSURL(string: serverAddress + "app_notes.json")
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "GET"
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.None)
        SVProgressHUD.showWithStatus("Downloading...")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            let httpURLResponse = response as? NSHTTPURLResponse
            if (error == nil && httpURLResponse != nil && httpURLResponse?.statusCode == 200) {
                let dataStr = String(data: data!, encoding: NSUTF8StringEncoding)
                NSLog(dataStr!)
                
                self.notes = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! Array<Dictionary<String, AnyObject>>
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                    self.tableView.reloadData()
                })
            } else {
                // when error
                self.notes = []
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                })
            }
        })
        task.resume()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let note = notes[indexPath.row]
        
        cell.textLabel!.text = note["title"] as? String
        cell.textLabel!.font = UIFont(name: "HiraKakuProN-W3", size: 16)
        
        let url = NSURL(string: (note["thumbnail"] as? String)!)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, responce, error) -> Void in
            
            if (error == nil) {
                let image = UIImage(data:data!)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.imageView?.image = image
                    cell.layoutSubviews()
                })
            } else {
                // when error
            }
        })
        task.resume()
        
        return cell
    }

    var noteInfoUrl: String?
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {

        let note = notes[indexPath.row]
        
        self.noteInfoUrl = note["url"] as? String
            // SubViewController へ遷移するために Segue を呼び出す
        performSegueWithIdentifier("toDetailNoteViewController",sender: nil)
        
    }
    
    // Segue 準備
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toDetailNoteViewController") {
            let detailNoteVC: DetailNoteViewController = (segue.destinationViewController as? DetailNoteViewController)!
            // ノート情報取得のためのURLを設定する
            detailNoteVC.noteInfoUrl = noteInfoUrl!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

