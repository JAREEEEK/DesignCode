//
//  Data.swift
//  DesignCode
//
//  Created by Yaroslav Nosik on 17.05.2020.
//  Copyright © 2020 Yaroslav Nosik. All rights reserved.
//

import SwiftUI

struct Post: Codable, Identifiable {
    let id = UUID()
    var title: String
    var body: String
}

class API {
    func getPosts(completion: @escaping ([Post]) -> Void) {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            
            let posts = try! JSONDecoder().decode([Post].self, from: data)
            DispatchQueue.main.async {
                completion(posts)
            }
        }
        .resume()
    }
}
