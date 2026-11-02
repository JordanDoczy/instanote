//
//  ImageView.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/14/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import SwiftUI

struct ImageView: View {
    let url: String

    @State private var image: UIImage?

    init(with url: String) {
        self.url = url
        // Photos on this device load immediately, so rows don't flash empty while scrolling.
        _image = State(initialValue: ImageLoader.localImage(urlString: url))
    }

    var body: some View {
        Image(uiImage: image ?? UIImage())
            .resizable()
            .aspectRatio(contentMode: .fill)
            .task(id: url) {
                image = await ImageLoader.fetchImage(urlString: url)
            }
    }
}
