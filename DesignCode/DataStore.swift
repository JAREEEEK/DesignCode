//
//  DataStore.swift
//  DesignCode
//
//  Created by Yaroslav Nosik on 17.05.2020.
//  Copyright © 2020 Yaroslav Nosik. All rights reserved.
//

import SwiftUI
import Combine

class DataStore: ObservableObject {
    @Published var posts: [Post] = []
    
    init() {
        getPosts()
    }
    
    func getPosts() {
        API().getPosts { (posts) in
            self.posts = posts
        }
    }
}
