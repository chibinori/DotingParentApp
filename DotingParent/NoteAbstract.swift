//
//  NoteAbstract.swift
//  DotingParent
//
//  Created by 酒井紀明 on 2016/01/23.
//  Copyright © 2016年 noriaki.sakai. All rights reserved.
//

import Foundation

class NoteAbstract : NSObject {
    var title: String
    var imageUrl: NSURL
    var isMovie: Bool
    
    init(name: String, imageUrl: NSURL, isMovie: Bool){
        self.title = name
        self.imageUrl = imageUrl
        self.isMovie = isMovie
    }
}
