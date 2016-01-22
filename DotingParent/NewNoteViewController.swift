//
//  NewNoteViewController.swift
//  DotingParent
//
//  Created by 酒井紀明 on 2016/01/13.
//  Copyright © 2016年 noriaki.sakai. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import AVKit
import AVFoundation

class NewNoteViewController: UIViewController, UINavigationControllerDelegate, GMImagePickerControllerDelegate {
    
    @IBOutlet weak var noteTitleField: UITextField!
    @IBOutlet weak var noteCommentField: UITextField!
    
    @IBOutlet weak var imageViewOutlet: UIImageView!
    
    @IBOutlet weak var saveBtnOutlet: UIBarButtonItem!
    @IBOutlet weak var movieStartBtnOutlet: UIButton!
    private var isCanceled :Bool = false
    private var imagePHAsset :PHAsset? = nil
    private var imageAVAsset :AVAsset? = nil
    private let MOVIE_IMAGE_NUM = 3
    private let MOVIE_IMAGE_FILENAME_PREFIX = "movie_image_"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        isCanceled = false
        saveBtnOutlet.enabled = false
        movieStartBtnOutlet.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // viewDidLoadでは写真選択を呼ぶことができない
        
        // 既に選択済みの場合は何もしない
        if self.imagePHAsset != nil || isCanceled {

            return
        }
        
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let alertController = UIAlertController(title: "警告", message: "Photoライブラリにアクセス出来ません", preferredStyle: .Alert)
            
            let closeAction = UIAlertAction(title: "閉じる", style: .Default) {
                action in NSLog("閉じるボタンが押されました")
            }
            
            // addActionした順に左から右にボタンが配置されます
            alertController.addAction(closeAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            self.raiseImagePicker()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func save(sender: AnyObject) {
        
        let title: String = (noteTitleField.text != nil && noteTitleField.text != "")
                            ? noteTitleField.text! : "No Title"
        let comment: String = (noteCommentField.text != nil) ? noteCommentField.text! : ""
        

        if self.imagePHAsset?.mediaType == PHAssetMediaType.Image {
            let userId = ServerUtility.getUserId()

            let param = [
                "user_id" : userId,
                "note_title" :  title ,
                "note_comment" : comment
            ]
            
            let imageData = UIImageJPEGRepresentation(self.imageViewOutlet.image!, 1)

            let serverAddress = ServerUtility.getAddress()
            let url = NSURL(string: serverAddress + "app_notes")
            let request = NSMutableURLRequest(URL: url!)
            
            request.HTTPMethod = "POST"

            let boundary = ServerUtility.generateBoundaryString()
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            request.HTTPBody = ServerUtility.createBodyWithParameters(param, filePathKey: "image", imageDataKey: imageData!, fileName: "post_image.JPG", mimeType: "image/jpeg", boundary: boundary)
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.None)
            SVProgressHUD.showWithStatus("Uploading...")
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                
                let httpURLResponse = response as? NSHTTPURLResponse
                if (error == nil && httpURLResponse != nil && httpURLResponse?.statusCode == 201) {
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
                        
                        let alertController = UIAlertController(title: "警告", message: "写真のアップロードに失敗しました", preferredStyle: .Alert)
                        
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
        } else if self.imagePHAsset?.mediaType == PHAssetMediaType.Video {
            
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.None)
            SVProgressHUD.showWithStatus("Movie Compressing...")

            let durationSeconds = CMTimeGetSeconds(self.imageAVAsset!.duration)
            let interval = durationSeconds / Float64(self.MOVIE_IMAGE_NUM - 1)
            var step: Float64 = 0.0
            var imageRef: CGImageRef
            var uiImage: UIImage
            var imageJpeg: NSData;
            var imageDataArray : Array<NSData> = []
            
            // assetから画像をキャプチャーする為のジュネレーターを生成.
            let generator = AVAssetImageGenerator(asset: self.imageAVAsset!)
            generator.maximumSize = CGSize(width: 800, height: 800)
            generator.appliesPreferredTrackTransform = true

            // 動画の最初のキャプチャを撮る.
            imageRef = try! generator.copyCGImageAtTime(kCMTimeZero, actualTime: nil)
            
            uiImage = UIImage(CGImage: imageRef)
            imageJpeg = UIImageJPEGRepresentation(uiImage, 0.5)!
            imageDataArray.append(imageJpeg)
            
            // 動画途中のキャプチャを撮る.
            step = step + interval
            for var i = 0 ; i < self.MOVIE_IMAGE_NUM - 2 ; i++  {
                let midpoint = CMTimeMakeWithSeconds(step, 30);
                
                imageRef = try! generator.copyCGImageAtTime(midpoint, actualTime: nil)
                uiImage = UIImage(CGImage: imageRef)
                imageJpeg = UIImageJPEGRepresentation(uiImage, 0.5)!
                imageDataArray.append(imageJpeg)
                
                step += interval
            }
            
            // 動画の最後のキャプチャを撮る.
            imageRef = try! generator.copyCGImageAtTime(self.imageAVAsset!.duration, actualTime: nil)
            uiImage = UIImage(CGImage: imageRef)
            imageJpeg = UIImageJPEGRepresentation(uiImage, 0.5)!
            imageDataArray.append(imageJpeg)
            NSLog("imageAryCount:\(imageDataArray.count)")

            
            //
            // ここから動画の圧縮MP4変換
            //
            let exportSession = AVAssetExportSession(asset: self.imageAVAsset!, presetName: AVAssetExportPresetMediumQuality)
            exportSession!.outputFileType = AVFileTypeMPEG4
            let tmpPath = NSTemporaryDirectory() + "compressed.mp4"
            NSLog("/tmp\n\(tmpPath)")
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(tmpPath) {
                try! fileManager.removeItemAtPath(tmpPath)
            }
            exportSession!.outputURL = NSURL.fileURLWithPath(tmpPath)
            
            exportSession!.exportAsynchronouslyWithCompletionHandler { () -> Void in
                switch exportSession!.status {
                case AVAssetExportSessionStatus.Completed:
                    NSLog("Export completed");
                    let compressedMovieData = NSData(contentsOfURL: exportSession!.outputURL!)
                    self.uploadMovie(title, comment: comment, movieDataKey: compressedMovieData!, imageDataKeys: imageDataArray)
                    
                    
                    // テスト用に再生してみる
//                    let avAsset = AVURLAsset(URL: exportSession!.outputURL!, options: nil)
//                    // AVPlayerに再生させるアイテムを生成.
//                    let playerItem = AVPlayerItem(asset: avAsset)
//                    
//                    // AVPlayerを生成.
//                    let videoPlayer = AVPlayer(playerItem: playerItem)
//                    
//                    let playerViewController = AVPlayerViewController()
//                    playerViewController.player = videoPlayer
//                    
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        self.presentViewController(playerViewController, animated: true) {
//                            playerViewController.player!.play()
//                        }
//                    })

                    break
                case AVAssetExportSessionStatus.Failed:
                    NSLog("Export failed")
                    break
                case AVAssetExportSessionStatus.Cancelled:
                    NSLog("Export caceceled")
                    break
                default:
                    break
                }
                SVProgressHUD.dismiss()
            }


        } else {
            // ありえない
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func uploadMovie(title: String, comment: String, movieDataKey: NSData, imageDataKeys: [NSData]) {

        
        //
        // 動画のアップロード
        //
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.None)
        SVProgressHUD.showWithStatus("Movie Uploading...")

        let userId = ServerUtility.getUserId()
        let param = [
            "user_id" : userId,
            "note_title" :  title ,
            "note_comment" : comment
        ]
        
        let serverAddress = ServerUtility.getAddress()
        let url = NSURL(string: serverAddress + "app_notes")
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        
        let boundary = ServerUtility.generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.HTTPBody = ServerUtility.createBodyWithParameters(param, filePathKey: "movie", imageDataKey: movieDataKey, fileName: "post_movie.MP4", mimeType: "video/mp4", boundary: boundary)

        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            let httpURLResponse = response as? NSHTTPURLResponse
            let responseHeaders = httpURLResponse?.allHeaderFields
            let locationUrlStr: String? = responseHeaders!["location"] as? String

            if (error == nil && httpURLResponse != nil && httpURLResponse?.statusCode == 201
                && locationUrlStr != nil) {
                let dataStr = String(data: data!, encoding: NSUTF8StringEncoding)
                NSLog(dataStr!)
                
                self.uploadMovieImage(locationUrlStr!, imageDataKeys: imageDataKeys)
                
            } else {
                // when error
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                    
                    let alertController = UIAlertController(title: "警告", message: "動画のアップロードに失敗しました", preferredStyle: .Alert)
                    
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
    
    var uploadedMovieImageCnt = 0
    private func uploadMovieImage(movieImagePostUrl: String, imageDataKeys: [NSData]) {
        
        let userId = ServerUtility.getUserId()
        let param = [
            "user_id" : userId
        ]
        
        uploadedMovieImageCnt = 0
        let url = NSURL(string: movieImagePostUrl + "/movie_image")
        let totalImageCnt = imageDataKeys.count
        
        for imageDataKey in imageDataKeys {
            let request = NSMutableURLRequest(URL: url!)
            
            request.HTTPMethod = "POST"
            
            let boundary = ServerUtility.generateBoundaryString()
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            request.HTTPBody = ServerUtility.createBodyWithParameters(param, filePathKey: "movie_image", imageDataKey: imageDataKey, fileName: "post_movie_image.JPG", mimeType: "image/jpeg", boundary: boundary)
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                
                let httpURLResponse = response as? NSHTTPURLResponse
                if (error == nil && httpURLResponse != nil && httpURLResponse?.statusCode == 201) {
                    let dataStr = String(data: data!, encoding: NSUTF8StringEncoding)
                    NSLog(dataStr!)
                    
                    self.finishUploadMovieImage(url!, totalImageCnt: totalImageCnt)
                    
                } else {
                    // when error
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        SVProgressHUD.dismiss()
                        
                        let alertController = UIAlertController(title: "警告", message: "動画のアップロードに失敗しました2", preferredStyle: .Alert)
                        
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
    }
    
    private func finishUploadMovieImage(uploadUrl :NSURL, totalImageCnt: Int) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.uploadedMovieImageCnt++
            if self.uploadedMovieImageCnt < totalImageCnt {
                return
            }
            
            // 全てアップロードした
            let userId = ServerUtility.getUserId()
            let param = [
                "user_id" : userId,
                "finishes" : "true"
            ]

            let request = NSMutableURLRequest(URL: uploadUrl)
            
            request.HTTPMethod = "POST"
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(param, options: NSJSONWritingOptions.init(rawValue: 0))
            //request.HTTPBody = ServerUtility.createBodyWithParameters(param, filePathKey: nil, imageDataKey: nil, fileName: nil, mimeType: nil, boundary: boundary)
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                
                let httpURLResponse = response as? NSHTTPURLResponse
                if (error == nil && httpURLResponse != nil && httpURLResponse?.statusCode == 201) {
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
                        
                        let alertController = UIAlertController(title: "警告", message: "動画のアップロードに失敗しました3", preferredStyle: .Alert)
                        
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
        })
    }
    
    private func raiseImagePicker() {
        let picker = GMImagePickerController()
        picker.delegate = self;
        picker.allowsMultipleSelection = false
        picker.title = "Photos"
        self.presentViewController(picker, animated: true, completion: nil)

    }
    
    // 画像をリサイズ
    func resize(image: UIImage, max: Int) -> UIImage {
        
        // 縦横比を固定してリサイズ
        
        let imageW = image.size.width
        let imageH = image.size.height
        if Int(imageW) < max && Int(imageH) < max {
            return image
        }
        
        let scale = (imageW > imageH ? CGFloat(max) / imageW : CGFloat(max) / imageH);
        
        let resizedSize: CGSize = CGSizeMake(imageW * scale, imageH * scale)
        UIGraphicsBeginImageContext(resizedSize)
        image.drawInRect(CGRectMake(0, 0, resizedSize.width, resizedSize.height))
        
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizeImage
    }
    
    @IBOutlet weak var imageSelectBtn: UIButton!
    
    @IBAction func selectImage(sender: UIButton) {
        self.raiseImagePicker()
    }
    
    
    func assetsPickerController(picker: GMImagePickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        picker.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
        NSLog("GMImagePicker: User ended picking assets. Number of selected items is: %lu", assets.count);
        
        self.imagePHAsset = assets[0] as? PHAsset

        let manager: PHImageManager = PHImageManager()

        if self.imagePHAsset?.mediaType == PHAssetMediaType.Video {
            manager.requestAVAssetForVideo(self.imagePHAsset!, options: nil) {
                (avAsset:AVAsset?, avAudioMix :AVAudioMix?, assetInfos:[NSObject : AnyObject]?) -> Void in
                self.imageAVAsset = avAsset
            }
            self.movieStartBtnOutlet.hidden = false
        } else if self.imagePHAsset?.mediaType == PHAssetMediaType.Image {
            self.movieStartBtnOutlet.hidden = true
        } else {
            self.movieStartBtnOutlet.hidden = true
            return
        }
    
        manager.requestImageForAsset(self.imagePHAsset!,
            targetSize: CGSizeMake(1200, 1200),
            contentMode: .AspectFit,
            options: nil) { (image, info) -> Void in
                // 取得したimageをUIImageViewなどで表示する
                self.imageViewOutlet.image = image
                self.saveBtnOutlet.enabled = true
        }
    }
    
    
    func assetsPickerControllerDidCancel(picker: GMImagePickerController!) {

        if imageViewOutlet.image != nil {
            return
        }
        
        // 写真が選択されてなければそのまま前の画面に戻る
        // viewAppearでpickerが開かないようにする
        isCanceled = true
        saveBtnOutlet.enabled = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func movieStart(sender: UIButton) {
        if self.imagePHAsset?.mediaType != PHAssetMediaType.Video {
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
        
        // assetからURLを取得.
//        let manager: PHImageManager = PHImageManager()
//        
//        manager.requestAVAssetForVideo(self.imagePHAsset!, options: nil) {
//            (avAsset:AVAsset?, avAudioMix :AVAudioMix?, assetInfos:[NSObject : AnyObject]?) -> Void in
//
//            
//            // AVPlayerに再生させるアイテムを生成.
//            let playerItem = AVPlayerItem(asset: avAsset!)
//            
//            // AVPlayerを生成.
//            let videoPlayer = AVPlayer(playerItem: playerItem)
//            
//            let playerViewController = AVPlayerViewController()
//            playerViewController.player = videoPlayer
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.presentViewController(playerViewController, animated: true) {
//                    playerViewController.player!.play()
//                }
//            })
//        }
    }
    
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        
    }
    
    @IBAction func textFieldReturn(sender: UITextField) {
        self.view.endEditing(true)
    }
}

