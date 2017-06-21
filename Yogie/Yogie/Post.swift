//
//  Post.swift
//  Yogie
//
//  Created by Erica Y Stevens on 5/22/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation
import UIKit

class Post {
    var type: String
    var timestamp: Double
//    var image: UIImage
    var user: YogieUser
    var imageData: [(Double, UIImage)]
    var asanaTitle: String?
//    var challengeTitle: String?
//    var challengeDuration: String?
//    var challengeHost: String?
    
    init(type: String, imageData: [(Double, UIImage)], user: YogieUser, timestamp: Double, asanaTitle: String?) {
        self.type = type
        self.imageData = imageData
        self.user = user
        self.timestamp = timestamp
        self.asanaTitle = asanaTitle ?? nil
    }
}
