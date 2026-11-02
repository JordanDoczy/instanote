//
//  ImageLoader.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/14/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Foundation
import UIKit

enum ImageLoader {

    /// Returns the image right away if it's cached or stored on this device, otherwise nil.
    static func localImage(urlString: String) -> UIImage? {
        if let cachedImage = ImageCache.getImageCache().get(forKey: urlString) {
            return cachedImage
        }
        guard let url = URL(string: urlString), url.isFileURL,
              let image = UIImage(contentsOfFile: url.path)
        else { return nil }

        ImageCache.getImageCache().set(forKey: urlString, image: image)
        return image
    }

    /// Loads and caches the image at `urlString`, which may be a file or a web URL.
    static func fetchImage(urlString: String) async -> UIImage? {
        if let image = localImage(urlString: urlString) {
            return image
        }
        // The network wait happens off the main actor; the rest runs back on it.
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data)
        else { return nil }

        ImageCache.getImageCache().set(forKey: urlString, image: image)
        return image
    }
}

class ImageCache {
    private var cache = NSCache<NSString, UIImage>()
    
    func get(forKey: String) -> UIImage? {
        return cache.object(forKey: NSString(string: forKey))
    }
    
    func set(forKey: String, image: UIImage) {
        cache.setObject(image, forKey: NSString(string: forKey))
    }
}

extension ImageCache {
    private static var imageCache = ImageCache()
    static func getImageCache() -> ImageCache {
        return imageCache
    }
}
