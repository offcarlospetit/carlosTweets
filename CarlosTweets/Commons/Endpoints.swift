//
//  Endpoints.swift
//  CarlosTweets
//
//  Created by Carlos Petit on 17-05-20.
//  Copyright © 2020 Carlos Petit. All rights reserved.
//

import UIKit

struct Endpoints {
    static let domain = "https://platzi-tweets-backend.herokuapp.com/api/v1"
    static let login = Endpoints.domain + "/auth"
    static let register = Endpoints.domain + "/register"
    static let getPosts = Endpoints.domain + "/posts"
    static let post = Endpoints.domain + "/posts"
    static let delete = Endpoints.domain + "/posts/"
}
