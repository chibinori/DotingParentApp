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
        serverAddress = "https://techacademy-chibinori-1.c9users.io/"
        //serverAddress = "https://chibinori-dotingparent.herokuapp.com/"
        return serverAddress
    }
    
    static func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData?, mimeType: String?, boundary: String) -> NSData {
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
            let filename = "post_image.JPG"
            //let mimetype = "image/jpg"
            body.appendData("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData("Content-Type: \(mimeType)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(imageDataKey!)
            body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        
        return body
    }

    static func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
}