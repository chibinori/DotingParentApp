//
//  ServerUtility.swift
//  DotingParent
//
//  Created by 酒井紀明 on 2016/01/14.
//  Copyright © 2016年 noriaki.sakai. All rights reserved.
//

import Foundation

class ServerUtility {
    
    static func getAddress() -> (String) {
        let ud = NSUserDefaults.standardUserDefaults()
        var serverAddress : String! = ud.stringForKey("server_address")
//        if serverAddress == nil {
//            serverAddress = "https://techacademy-chibinori-1.c9users.io/"
//        }
//        serverAddress = "https://techacademy-chibinori-1.c9users.io/"
        serverAddress = "https://chibinori-dotingparent.herokuapp.com/"
        return serverAddress
    }
    
    static func getUserId() -> (String) {
        
        let userId = "papa"
        
        return userId
    }
    
    static func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData?, fileName: String?, mimeType: String?, boundary: String) -> NSData {
        let body = NSMutableData()
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData("\(value)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            }
        }
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        if filePathKey != nil {
            //let mimetype = "image/jpg"
            body.appendData("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(fileName!)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData("Content-Type: \(mimeType!)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(imageDataKey!)
            body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        
        return body
    }
    
//    static func createBodyWithParametersForMovie(parameters: [String: String], movieDataKey: NSData,
//        imageDataKeys: [NSData], boundary: String) -> NSData {
//            
//            let body = NSMutableData()
//            for (key, value) in parameters {
//                body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//                body.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//                body.appendData("\(value)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//            }
//            body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//            
//            let movieFilename = "post_movie.MP4"
//            let moviePathKey = "movie"
//            let movieMimeType = "video/mp4"
//            body.appendData("Content-Disposition: form-data; name=\"\(moviePathKey)\"; filename=\"\(movieFilename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//            body.appendData("Content-Type: \(movieMimeType)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//            body.appendData(movieDataKey)
//            body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//            body.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//            
//            if imageDataKeys.count == 0 {
//                return body
//            }
//
//            let imagePrefix: String = parameters["movie_image_prefix"]!
//            let imageMimeType = "image/jpg"
//            
//            var i = 0
//            for (imageDataKey) in imageDataKeys {
//                let imagePathKey = imagePrefix + i.description
//                let imageFilename = imagePrefix + i.description + "_file"
//                body.appendData("Content-Disposition: form-data; name=\"\(imagePathKey)\"; filename=\"\(imageFilename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//                body.appendData("Content-Type: \(imageMimeType)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//                body.appendData(imageDataKey)
//                body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//                body.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//                i++
//            }
//            
//            return body
//    }

    static func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    // 画像をリサイズ
//    func resize(image: UIImage, max: Int) -> UIImage {
//        
//        // 縦横比を固定してリサイズ
//        
//        let imageW = image.size.width
//        let imageH = image.size.height
//        if Int(imageW) < max && Int(imageH) < max {
//            return image
//        }
//        
//        let scale = (imageW > imageH ? CGFloat(max) / imageW : CGFloat(max) / imageH);
//        
//        let resizedSize: CGSize = CGSizeMake(imageW * scale, imageH * scale)
//        UIGraphicsBeginImageContext(resizedSize)
//        image.drawInRect(CGRectMake(0, 0, resizedSize.width, resizedSize.height))
//        
//        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return resizeImage
//    }

}