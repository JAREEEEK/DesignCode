//
//  UpdateStore.swift
//  DesignCode
//
//  Created by Yaroslav Nosik on 16.05.2020.
//  Copyright © 2020 Yaroslav Nosik. All rights reserved.
//

import SwiftUI
import Combine

class UpdateStore: ObservableObject {
    @Published var updates: [Update] = updateData
}
