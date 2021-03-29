//
//  ImageLoader.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/14/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Foundation
import Combine
import UIKit

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private var imageCache = ImageCache.getImageCache()
    private let imageProcessingQueue = DispatchQueue(label: "image-processing")
    private var cancellable: AnyCancellable?
    
    init(urlString: String) {
        loadImage(urlString: urlString)
    }
    
    private func loadImage(urlString: String) {
        if loadImageFromCache(urlString: urlString) {
            return
        }
        
        loadImageFromUrl(urlString: urlString)
    }
    
    private func loadImageFromCache(urlString: String) -> Bool {
        guard let cacheImage = imageCache.get(forKey: urlString) else {
            return false
        }
        
        image = cacheImage
        return true
    }
    
    private func loadImageFromUrl(urlString: String) {
        let url = URL(string: urlString)!
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .subscribe(on: imageProcessingQueue)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loadedImage in
                guard let strongSelf = self, let loadedImage = loadedImage else {
                    return
                }
                
                strongSelf.imageCache.set(forKey: urlString, image: loadedImage)
                strongSelf.image = loadedImage
            }
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
