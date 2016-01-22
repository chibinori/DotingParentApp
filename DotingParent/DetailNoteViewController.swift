//
//  DetailNoteViewController.swift
//  DotingParent
//
//  Created by 酒井紀明 on 2016/01/20.
//  Copyright © 2016年 noriaki.sakai. All rights reserved.
//

import UIKit
import AVKit

class DetailNoteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var noteTitleField: UITextField!
    @IBOutlet weak var noteCommentField: UITextField!
    @IBOutlet weak var imageViewOutlet: UIImageView!
    
    @IBOutlet weak var saveBtnOutlet: UIBarButtonItem!
    @IBOutlet weak var movieStartBtnOutlet: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var detailNote: Dictionary<String, AnyObject> = [:]

    var noteInfoUrl: String = ""
    
    private var imageAVAsset :AVAsset? = nil

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
        movieStartBtnOutlet.hidden = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.imageViewOutlet?.image != nil {
            return
        }
    
        let userId = ServerUtility.getUserId()

        let url = NSURL(string: self.noteInfoUrl + "?user_id=\(userId)")
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "GET"
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.None)
        SVProgressHUD.showWithStatus("Downloading...")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            let httpURLResponse = response as? NSHTTPURLResponse
            if (error == nil && httpURLResponse?.statusCode == 200) {
                let dataStr = String(data: data!, encoding: NSUTF8StringEncoding)
                NSLog(dataStr!)
                
                self.detailNote = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<String, AnyObject>
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.initializeNoteInfo()
                    self.tableView.reloadData()
                })
            } else {
                // when error
                self.detailNote = [:]
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                })
            }
        })
        task.resume()
    }
    
    private func initializeNoteInfo() {
        self.noteTitleField.text = self.detailNote["title"] as? String

        let url = NSURL(string: (self.detailNote["image_url"] as? String)!)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            let httpURLResponse = response as? NSHTTPURLResponse
            if (error == nil && httpURLResponse != nil && httpURLResponse?.statusCode == 200) {
                let image = UIImage(data:data!)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.imageViewOutlet?.image = image
                    SVProgressHUD.dismiss()
                })
            } else {
                // when error
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                    
                    let alertController = UIAlertController(title: "警告", message: "画像を取得出来ません", preferredStyle: .Alert)
                    
                    let closeAction = UIAlertAction(title: "閉じる", style: .Default) {
                        action in NSLog("閉じるボタンが押されました")
                    }
                    
                    // addActionした順に左から右にボタンが配置されます
                    alertController.addAction(closeAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)

                })
            }
        })
        task.resume()

        let movieUrlStr = self.detailNote["movie_url"] as? String
        if movieUrlStr == nil {
            return
        }

        let movieUrl = NSURL(string: movieUrlStr!)
        let movieRequest = NSMutableURLRequest(URL: movieUrl!)
        
        movieRequest.HTTPMethod = "GET"
        
        let movieTask = NSURLSession.sharedSession().dataTaskWithRequest(movieRequest, completionHandler: { (data, response, error) -> Void in
            
            let httpURLResponse = response as? NSHTTPURLResponse
            if (error == nil && httpURLResponse != nil && httpURLResponse?.statusCode == 200) {
                
                let tmpPath = NSTemporaryDirectory() + "compressed.mp4"
                NSLog(tmpPath)
                let fileManager = NSFileManager.defaultManager()
                if fileManager.fileExistsAtPath(tmpPath) {
                    try! fileManager.removeItemAtPath(tmpPath)
                }
                
                data!.writeToFile(tmpPath, atomically: true)
                
                let fileUrl = NSURL(fileURLWithPath: tmpPath)

                self.imageAVAsset = AVURLAsset(URL: fileUrl, options: nil)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.movieStartBtnOutlet.hidden = false
                    
                    let alertController = UIAlertController(title: "警告", message: "動画を取得出来ません", preferredStyle: .Alert)
                    
                    let closeAction = UIAlertAction(title: "閉じる", style: .Default) {
                        action in NSLog("閉じるボタンが押されました")
                    }
                    
                    // addActionした順に左から右にボタンが配置されます
                    alertController.addAction(closeAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)

                })
            } else {
                // when error
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alertController = UIAlertController(title: "警告", message: "動画を取得出来ません", preferredStyle: .Alert)
                    
                    let closeAction = UIAlertAction(title: "閉じる", style: .Default) {
                        action in NSLog("閉じるボタンが押されました")
                    }
                    
                    // addActionした順に左から右にボタンが配置されます
                    alertController.addAction(closeAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)

                })
            }
        })
        movieTask.resume()

    }

    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        
        let url = NSURL(string: noteInfoUrl)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "PUT"
        
        let title: String = (noteTitleField.text != nil && noteTitleField.text != "") ? noteTitleField.text! : "No Title"
        let comment: String = (noteCommentField.text != nil) ? noteCommentField.text! : ""
        
        let userId = ServerUtility.getUserId()

        let param = [
            "user_id" : userId,
            "note_title" :  title ,
            "note_comment" : comment
        ]

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(param, options: NSJSONWritingOptions.init(rawValue: 0))

        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.None)
        SVProgressHUD.showWithStatus("Updating...")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            let httpURLResponse = response as? NSHTTPURLResponse
            if (error == nil && httpURLResponse != nil && httpURLResponse?.statusCode == 200) {
                let dataStr = String(data: data!, encoding: NSUTF8StringEncoding)
                NSLog(dataStr!)
                
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                // when error
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                    
                    let alertController = UIAlertController(title: "警告", message: "情報の更新に失敗しました", preferredStyle: .Alert)
                    
                    let closeAction = UIAlertAction(title: "閉じる", style: .Default) {
                        action in NSLog("閉じるボタンが押されました")
                    }
                    
                    // addActionした順に左から右にボタンが配置されます
                    alertController.addAction(closeAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)

                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
        })
        task.resume()
    }
    
    @IBAction func movieStart(sender: UIButton) {
        if self.imageAVAsset == nil {
            return
        }
        
        // AVPlayerに再生させるアイテムを生成.
        let playerItem = AVPlayerItem(asset: self.imageAVAsset!)
        
        // AVPlayerを生成.
        let videoPlayer = AVPlayer(playerItem: playerItem)
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = videoPlayer
        
        self.presentViewController(playerViewController, animated: true) {
            playerViewController.player!.play()
        }

    }
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func textFieldReturn(sender: UITextField) {
        self.view.endEditing(true)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if detailNote["comments"] == nil {
            return 0
        }
        
        return detailNote["comments"]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let userComment = detailNote["comments"]![indexPath.row]
        
        cell.textLabel!.text = userComment["comment"] as? String
        cell.textLabel!.font = UIFont(name: "HiraKakuProN-W3", size: 12)
        
        let url = NSURL(string: (userComment["user_image_url"] as? String)!)
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
