//
//  FileManager+Extensions.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/11/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Foundation
import UIKit

// FileManager is thread-safe, and Note calls these from nonisolated Core Data callbacks.
nonisolated extension FileManager {
    
    private var applicationDocumentsDirectory: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }
    
    func saveImage(_ image: UIImage) -> String? {
        
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            let fileName = "\(UUID().uuidString).jpg"
            let imageURL = applicationDocumentsDirectory.appendingPathComponent(fileName)
            do {
                try imageData.write(to: imageURL, options: [.atomic])
            } catch {
                return nil
            }
            return fileName
        }
        return nil
    }
    
    func deleteImage(_ imageURL: URL) -> Bool {
        
        if imageURL.absoluteString.contains(applicationDocumentsDirectory.absoluteString) {
            do {
                try FileManager.default.removeItem(at: imageURL)
            }
            catch { return false}
            return true
        }
        return false
    }
    
    func getFilePath(_ fileName: String) -> String {
        
        if fileName.contains("://") || !fileName.contains(".jpg") {
            return fileName
        }
        
        return applicationDocumentsDirectory.appendingPathComponent(fileName).absoluteString
    }
}
