//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by david lobo on 04/03/2016.
//  Copyright © 2016 David Lobo. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject{
    var filePathUrl: NSURL!
    var title: String!
    
    init (filePathUrl: NSURL, title: String) {
        self.filePathUrl = filePathUrl
        self.title = title
    }
}