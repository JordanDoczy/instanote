//
//  UIImage+Extensions.swift
//  instanote
//
//  Created by Jordan Doczy on 12/13/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

// UIImage and UIGraphicsImageRenderer are thread-safe; the camera crops photos off the main thread.
nonisolated extension UIImage {

    /// Largest side, in pixels, of a photo saved to a note.
    static let notePhotoMaxPixelSide: CGFloat = 2048

    /// Returns an upright, center-cropped square, scaled down so its side is at most `maxPixelSide` pixels.
    ///
    /// Drawing through `draw(in:)` applies `imageOrientation`, so portrait photos (whose raw
    /// pixels are stored sideways) crop correctly.
    func squareCropped(maxPixelSide: CGFloat) -> UIImage {
        let shortestSide = min(size.width, size.height)
        guard shortestSide > 0 else { return self }

        let outputSide = min(shortestSide * scale, maxPixelSide)
        let drawScale = outputSide / shortestSide
        let drawSize = CGSize(width: size.width * drawScale, height: size.height * drawScale)
        let drawRect = CGRect(x: (outputSide - drawSize.width) / 2,
                              y: (outputSide - drawSize.height) / 2,
                              width: drawSize.width,
                              height: drawSize.height)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1 // one point per pixel, so outputSide is in pixels
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: outputSide, height: outputSide), format: format)
        return renderer.image { _ in
            draw(in: drawRect)
        }
    }
}
