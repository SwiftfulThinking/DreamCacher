//
//  DreamCache+Read.swift
//  DreamCacher
//
//  Created by Nick Sarno on 8/14/21.
//

import Foundation

import Foundation
import UIKit

// MARK: DREAMCACHER+READ
// These are convenience public functions for external use.

extension DreamCache {

    // MARK: IMAGE
    
    /// Cached UIImage
    public func image(forKey key: String) -> UIImage? {
        imagePNG(forKey: key) ?? imageJPG(forKey: key)
    }
    
    /// Cached JPG
    private func imageJPG(forKey key: String) -> UIImage? {
        guard case .jpg(image: let image, compression: _) = DreamCacherInteractor.read(key: key, fileExtension: .jpg, cache: self) else { return nil }
        return image
    }
    
    /// Cached PNG
    private func imagePNG(forKey key: String) -> UIImage? {
        guard case .png(image: let image) = DreamCacherInteractor.read(key: key, fileExtension: .png, cache: self) else { return nil }
        return image
    }

    // MARK: URL
    
    /// Cached video URL
    public func video(forKey key: String) -> URL? {
        videoMP4(forKey: key)
    }
    
    /// Cached MP4
    private func videoMP4(forKey key: String) -> URL? {
        DreamCacherInteractor.readURL(key: key, fileExtension: .mp4, cache: self)
    }
    
    /// Cached audio URL
    public func audio(forKey key: String) -> URL? {
        audioMP3(forKey: key)
    }
    
    /// Cached MP3
    private func audioMP3(forKey key: String) -> URL? {
        DreamCacherInteractor.readURL(key: key, fileExtension: .mp3, cache: self)
    }
    
    // MARK: CODABLE
    
    /// Cached Codable object
    public func object<T:Codable>(forKey key: String) -> T? {
        DreamCacherInteractor.readObject(key: key, cache: self)
    }
    
    /// Cached array of Codable objects
    public func objects<T:Codable>(forKey key: String) -> [T]? {
        DreamCacherInteractor.readObjects(key: key, cache: self)
    }
    
    // MARK: ANY
    
    /// Cached value found at key.
    ///
    /// - Warning: This method 'attempts' to find the file type for value. If file type is known, use explicit method for that type instead.
    public func any(forKey key: String) -> Any? {
        guard let result = DreamCacherInteractor.read(forKey: key, cache: self) else { return nil }
        switch result {
        case .any(any: let any): return any
        case .anyArray(array: let array): return array
        case .jpg(image: let image, compression: _): return image
        case .png(image: let image): return image
        case .mp3(url: let url): return url
        case .mp4(url: let url): return url
        case .model(data: let data): return data
        }
    }
    
    /// Cached array of values found at key.
    ///
    /// - Warning: This method 'attempts' to find the file type for value. If file type is known, use explicit method for that type instead.
    public func array(forKey key: String) -> [Any]? {
        let result = any(forKey: key)
        guard let result = result else { return nil }
        return result as? [Any] ?? [result]
    }
    
    /// Cached Boolean
    public func bool(forKey key: String) -> Bool? {
        any(forKey: key) as? Bool
    }
    
    /// Cached String
    public func string(forKey key: String) -> String? {
        any(forKey: key) as? String
    }
    
}
