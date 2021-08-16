//
//  DreamCacherInteractor+Delete.swift
//  DreamCacher
//
//  Created by Nick Sarno on 8/14/21.
//

import Foundation


// MARK: INTERACTOR+DELETE

extension DreamCacherInteractor {
    
    // MARK: PUBLIC
    
    static func delete(forKey key: String, cache: DreamCache) -> Result<Void, Error> {
        let supportedExtensions = SupportedExtension.allCases
        
        for ext in supportedExtensions {
            if let url = fileURL(fileName: key, fileExtension: ext, cache: cache), Filer.urlExists(url: url) {
                return Filer.delete(at: url)
            }
        }

        return .failure(InteractorError.fileNotFound)
    }
    
    @discardableResult static func deleteCache(cache: DreamCache) -> Result<Void, Error> {
        guard let url = cacheURL(cache: cache) else {
            return .failure(InteractorError.invalidURL)
        }
        return Filer.delete(at: url)
    }
    
    @discardableResult static func deleteAllCaches() -> Result<Void, Error> {
        guard let url = baseURL() else {
            return .failure(InteractorError.invalidURL)
        }
        return Filer.delete(at: url)
    }
}

