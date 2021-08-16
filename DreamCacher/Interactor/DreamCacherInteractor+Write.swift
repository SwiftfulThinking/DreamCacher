//
//  DreamCacherInteractor+Write.swift
//  DreamCacher
//
//  Created by Nick Sarno on 8/14/21.
//

import Foundation

// MARK: INTERACTOR+WRITE

extension DreamCacherInteractor {
    
    // MARK: PUBLIC
    
    static func write(value: Any, forKey key: String, cache: DreamCache) -> Result<URL, Error> {
        guard let file = FileType(any: value) else {
            return .failure(InteractorError.notSupported)
        }
            
        return manageCacheAndThenWriteToDisk(fileName: key, file: file, cache: cache)
    }
    
    static func write(key: String, file: FileType, cache: DreamCache) -> Result<URL, Error> {
        manageCacheAndThenWriteToDisk(fileName: key, file: file, cache: cache)
    }
    
    static func write<T:Codable>(object: T, forKey key: String, cache: DreamCache) -> Result<URL, Error> {
        do {
            let data = try encoder.encode(object)
            return manageCacheAndThenWriteToDisk(fileName: key, file: .model(data: data), cache: cache)
        } catch let error {
            return .failure(error)
        }
    }
    
    static func write<T:Codable>(objects: [T], forKey key: String, cache: DreamCache) -> Result<URL, Error> {
        do {
            let data = try encoder.encode(objects)
            return manageCacheAndThenWriteToDisk(fileName: key, file: .model(data: data), cache: cache)
        } catch let error {
            return .failure(error)
        }
    }
    
    // MARK: PRIVATE
    
    static private let encoder = JSONEncoder()
    
    static private func manageCacheAndThenWriteToDisk(fileName: String, file: FileType, cache: DreamCache) -> Result<URL, Error> {
        let prepareCaches = manageCacheSizes(cache: cache, file: file)
        
        if case .failure(let error) = prepareCaches {
            return .failure(error)
        }
        
        return writeToDisk(fileName: fileName, file: file, cache: cache)
    }
    
    static private func writeToDisk(fileName: String, file: FileType, cache: DreamCache) -> Result<URL, Error> {
        // Convert file to data
        guard let data = file.toData() else {
            return .failure(InteractorError.noData)
        }
        
        // Create folders if they don't exist
        // Result will be successful if folders were created OR folders already existed.
        // Result is failure if unable to create or find folders.
        let resultFromCreatingDirectories = createDirectoriesIfNeeded(cache: cache)
        
        // If error creating folders, return the error
        guard case .success = resultFromCreatingDirectories else {
            return resultFromCreatingDirectories
        }
        
        // Get file URL
        guard let url = fileURL(fileName: fileName, fileExtension: file.fileExtension, cache: cache) else {
            return .failure(InteractorError.invalidURL)
        }
        
        // Write to file
        return Filer.write(data: data, toURL: url)
    }
    
    static private func createDirectoriesIfNeeded(cache: DreamCache) -> Result<URL, Error> {
        // Get url for directory
        guard let url = cacheURL(cache: cache) else {
            return .failure(InteractorError.invalidURL)
        }
        
        // Check folder doesn't already exist. If it exists, return success.
        guard !Filer.urlExists(url: url) else {
            return .success(url)
        }
        
        return Filer.createDirectory(url: url)
    }
    
}
