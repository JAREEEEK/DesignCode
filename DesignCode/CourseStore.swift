//
//  CourseStore.swift
//  DesignCode
//
//  Created by Yaroslav Nosik on 17.05.2020.
//  Copyright © 2020 Yaroslav Nosik. All rights reserved.
//

import SwiftUI
import Contentful
import Combine

let client = Client(spaceId: "aiobzfb4x707", accessToken: "A-IgYsYx7Q0znxoQSbiejV1YHaIEHPYRhLGsVv0aXHk")

func getArray(id: String, completion: @escaping ([Entry]) -> Void) {
    let query = Query.where(contentTypeId: id)
    
    client.fetchArray(of: Entry.self, matching: query) { result in
        switch result {
        case .success(let array):
            DispatchQueue.main.async {
                completion(array.items)
            }
        case .error(let error):
            print(error)
        }
    }
}

class CourseStore: ObservableObject {
    @Published var courses: [Course] = courseData
    
    init() {
        getArray(id: "courseModel") { items in
            items.forEach { item in
                self.courses.append(Course(with: item))
            }
        }
    }
}
