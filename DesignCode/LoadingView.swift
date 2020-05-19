//
//  LoadingView.swift
//  DesignCode
//
//  Created by Yaroslav Nosik on 18.05.2020.
//  Copyright © 2020 Yaroslav Nosik. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            LottieView(filename: "loading")
                .frame(width: 200, height: 200)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
