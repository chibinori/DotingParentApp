//
//  NewNoteViewController.swift
//  DotingParent
//
//  Created by 酒井紀明 on 2016/01/13.
//  Copyright © 2016年 noriaki.sakai. All rights reserved.
//

import UIKit

class NewNoteViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var noteTitleField: UITextField!
    @IBOutlet weak var noteCommentField: UITextField!
    
    @IBOutlet weak var imageViewOutlet: UIImageView!
    
    @IBOutlet weak var saveBtnOutlet: UIBarButtonItem!
    private var isCanceled :Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        isCanceled = false
        saveBtnOutlet.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // viewDidLoadでは写真選択を呼ぶことができない
        
        // 既に選択済みの場合は何もしない
        if imageViewOutlet.image != nil || isCanceled {
            if !isCanceled {
                saveBtnOutlet.enabled = true
            }
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
        let serverAddress = ServerUtility.getAddress()
        
        let url = NSURL(string: serverAddress + "app_notes")
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "POST"
        
        let title: String = (noteTitleField.text != nil && noteTitleField.text != "")
                            ? noteTitleField.text! : "No Title"
        let comment: String = (noteCommentField.text != nil) ? noteCommentField.text! : ""
        
        let param = [
            "user_id" : "papa",
            "note_title" :  title ,
            "note_comment" : comment
        ]
        let boundary = ServerUtility.generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let imageData = UIImageJPEGRepresentation(self.imageViewOutlet.image!, 1)
        
        request.HTTPBody = ServerUtility.createBodyWithParameters(param, filePathKey: "image", imageDataKey: imageData!, mimeType: "image/jpeg", boundary: boundary)
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
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
        })
        task.resume()
    }
    
    private func raiseImagePicker() {
        let imagePickerController = UIImagePickerController()
        
        // フォトライブラリから選択
        imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        // 編集OFFに設定
        // これをtrueにすると写真選択時、写真編集画面に移る
        imagePickerController.allowsEditing = false
        
        // デリゲート設定
        imagePickerController.delegate = self
        
        // 選択画面起動
        self.presentViewController(imagePickerController,animated:true ,completion:nil)
    }
    
    // 写真選択時に呼ばれる
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        // アルバム画面を閉じます
        picker.dismissViewControllerAnimated(true, completion: nil);
        
        // 画像をリサイズしてUIImageViewにセット
        let resizeImage = resize(image, max: 1200)
        self.imageViewOutlet.image = resizeImage
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {

        // アルバム画面を閉じます
        picker.dismissViewControllerAnimated(true, completion: nil);

        
        if imageViewOutlet.image != nil {
            return
        }
        
        // 写真が選択されてなければそのまま前の画面に戻る
        // viewAppearでpickerが開かないようにする
        isCanceled = true
        saveBtnOutlet.enabled = false
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        
    }
    
    @IBAction func textFieldReturn(sender: UITextField) {
        self.view.endEditing(true)
    }
}

