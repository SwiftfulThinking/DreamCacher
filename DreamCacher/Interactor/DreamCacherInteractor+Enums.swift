//
//  DreamCacherInteractor+Enums.swift
//  DreamCacher
//
//  Created by Nick Sarno on 8/13/21.
//

import Foundation
import UIKit

// MARK: INTERACTOR+ENUMS

extension DreamCacherInteractor {
    
    // MARK: EXTENSIONS
    
    enum SupportedExtension: String, CaseIterable {
        case jpg = ".jpg"
        case png = ".png"
        case mp4 = ".mp4"
        case mp3 = ".mp3"
        case txt = ".txt"
    }

    // MARK: FILE TYPES
        
    enum FileType {
        
        case jpg(image: UIImage, compression: CGFloat? = nil)
        case png(image: UIImage)
        case mp4(url: URL)
        case mp3(url: URL)
        case anyArray(array: [Any])
        case any(any: Any)
        case model(data: Data)
        
        var fileExtension: SupportedExtension {
            switch self {
            case .jpg: return .jpg
            case .png: return .png
            case .mp4: return .mp4
            case .mp3: return .mp3
            case .anyArray, .any, .model: return .txt
            }
        }
        
        func toData() -> Data? {
            switch self {
            case .jpg(image: let image, compression: let compression): return image.jpegData(compressionQuality: compression ?? 1.0)
            case .png(image: let image): return image.pngData()
            case .mp4(url: let url), .mp3(url: let url): return try? Data(contentsOf: url)
            case .anyArray(array: let array): return try? JSONSerialization.data(withJSONObject: array, options: [])
            case .any(let any): return try? JSONSerialization.data(withJSONObject: [any], options: [])
            case .model(data: let data): return data
            }
        }
        
        init?(any: Any) {
            
            if let image = any as? UIImage {
                self = .jpg(image: image, compression: nil)
                return
            }

            if let url = any as? URL {
                self = .any(any: url.path)
                return
            }
                        
            if let array = any as? [Any], JSONSerialization.isValidJSONObject(any) {
                self = .anyArray(array: array)
                return
            }
            
            if let data = any as? Data {
                self = .model(data: data)
                return
            }
            
            if JSONSerialization.isValidJSONObject([any]) {
                self = .any(any: any)
                return
            }
            
            return nil
        }
                
        init?(data: Data, ext: SupportedExtension) {
            switch ext {
            case .jpg:
                guard let image = UIImage(data: data) else { return nil }
                self = .jpg(image: image, compression: nil)
            case .png:
                guard let image = UIImage(data: data) else { return nil }
                self = .png(image: image)
            case .mp4:
                guard let url = URL(dataRepresentation: data, relativeTo: nil) else { return nil }
                self = .mp4(url: url)
            case .mp3:
                guard let url = URL(dataRepresentation: data, relativeTo: nil) else { return nil }
                self = .mp3(url: url)
            case .txt:
                guard let object = (try? JSONSerialization.jsonObject(with: data, options: []) as? [Any])?.first else { return nil }
                self = .any(any: object)
            }
        }
        
    }
    
    // MARK: ERROR
    
    enum InteractorError: LocalizedError {
        
        // Fail to retrieve file from URL
        case fileNotFound
        // Fail to retrieve directory from URL
        case directoryNotFound
        // Fail to create URL for path
        case invalidURL
        // Fail to convert file to Data
        case noData
        // Attempt to save a value type that is not supported
        case notSupported
        // Fail to create cache space for object
        case failedToCleanCache(directory: URL, maximumLimit: Int, availableSize: Int, sizeRequested: Int, urlsDeleted: [URL], urlsUnableToDelete: [URL])
        // File larger than cache's max limit
        case fileTooLarge(maximumLimit: Int, sizeRequested: Int)
        
        var errorDescription: String {
            switch self {
            case .fileNotFound: return "Fail to retrieve file from URL."
            case .directoryNotFound: return "Fail to retrieve directory from URL."
            case .invalidURL: return "Fail to create URL for path."
            case .noData: return "Fail to convert file to Data."
            case .notSupported: return "Attempt to save a value type that is not supported"
            case .failedToCleanCache(directory: let directory, maximumLimit: let max, availableSize: let available, sizeRequested: let requested, urlsDeleted: let deleted, urlsUnableToDelete: let unableToDelete): return
                """
                ** WARNING **
                
                    There was a severe problem managing the size of the DreamCacher.
                    - Directory: \(directory.path)
                    - Maximum Limit: \(max)
                    - Available Limit: \(available)
                    - Requested Limit: \(requested)
                    - URLs successfully deleted at:
                        \(deleted)
                    - URLs failed to delete at:
                        \(unableToDelete)
                                    
                ** WARNING **
                """
            case .fileTooLarge(maximumLimit: let max, sizeRequested: let requested):
                return "File size (\(max)) is larger than the cache's maximum limit (\(requested))"
            }
        }
    }

}
