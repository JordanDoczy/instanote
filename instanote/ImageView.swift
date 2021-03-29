//
//  ImageView.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/14/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import SwiftUI

struct ImageView: View {
    @ObservedObject var imageLoader: ImageLoader

    init(with url: String) {
        imageLoader = ImageLoader(urlString: url)
    }

    var body: some View {
        Image(uiImage: imageLoader.image ?? UIImage())
            .resizable()
            .aspectRatio(contentMode: .fill)

    }
}
