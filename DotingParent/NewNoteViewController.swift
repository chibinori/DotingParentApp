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
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var imageViewOutlet: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // viewDidLoadでは写真選択を呼ぶことができない
        if imageViewOutlet.image != nil {
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func save(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 写真選択時に呼ばれる
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        // アルバム画面を閉じます
        picker.dismissViewControllerAnimated(true, completion: nil);
        
        // 画像をリサイズしてUIImageViewにセット
        let resizeImage = resize(image, width: 480, height: 320)
        self.imageViewOutlet.image = resizeImage
    }
    
    // 画像をリサイズ
    func resize(image: UIImage, width: Int, height: Int) -> UIImage {
        
        // TODO 縦横比を固定してリサイズ
        
        let size: CGSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizeImage
    }
}

