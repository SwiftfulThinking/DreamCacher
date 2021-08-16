//
//  DreamCache+Write.swift
//  DreamCacher
//
//  Created by Nick Sarno on 8/14/21.
//

import Foundation
import UIKit

// MARK: DREAMCACHER+WRITE
// These are convenience public functions for external use.

extension DreamCache {
    
    // MARK: IMAGE
    
    /// Save JPG image to cache.
    @discardableResult public func save(imageJPG image: UIImage, compression: CGFloat? = nil, forKey key: String) -> Result<URL, Error> {
        DreamCacherInteractor.write(key: key, file: .jpg(image: image, compression: compression), cache: self)
    }
        
    /// Save PNG image to cache.
    @discardableResult public func save(imagePNG image: UIImage, forKey key: String) -> Result<URL, Error> {
        DreamCacherInteractor.write(key: key, file: .png(image: image), cache: self)
    }
    
    // MARK: URL
    
    /// Save MP4 image to cache.
    @discardableResult public func save(videoMP4AtUrl url: URL, forKey key: String) -> Result<URL, Error> {
        DreamCacherInteractor.write(key: key, file: .mp4(url: url), cache: self)
    }
    
    /// Save MP3 image to cache.
    @discardableResult public func save(audioMP3AtUrl url: URL, forKey key: String) -> Result<URL, Error> {
        DreamCacherInteractor.write(key: key, file: .mp3(url: url), cache: self)
    }
    
    // MARK: CODABLE
    
    /// Save any Codable object to cache.
    @discardableResult public func save<T:Codable>(object: T, forKey key: String) -> Result<URL, Error> {
        DreamCacherInteractor.write(object: object, forKey: key, cache: self)
    }
    
    /// Save array of Codable objects to cache.
    @discardableResult public func save<T:Codable>(objects: [T], forKey key: String) -> Result<URL, Error> {
        DreamCacherInteractor.write(objects: objects, forKey: key, cache: self)
    }

    
    // MARK: ANY
    
    /// Save any type to cache.
    ///
    /// - Warning: This method 'attempts' to find the file type for value. If file type is known, use explicit method for that type instead.
    @discardableResult public func save(value: Any, forKey key: String) -> Result<URL, Error> {
        DreamCacherInteractor.write(value: value, forKey: key, cache: self)
    }

    /// Save [Any] to cache.
    @discardableResult public func save(array: [Any], forKey key: String) -> Result<URL, Error> {
        DreamCacherInteractor.write(value: array, forKey: key, cache: self)
    }
        
    /// Save Bool to cache.
    @discardableResult public func save(bool: Bool, forKey key: String) -> Result<URL, Error> {
        DreamCacherInteractor.write(key: key, file: .any(any: bool), cache: self)
    }
    
    /// Save String to cache.
    @discardableResult public func save(string: String, forKey key: String) -> Result<URL, Error> {
        DreamCacherInteractor.write(key: key, file: .any(any: string), cache: self)
    }
    
}
