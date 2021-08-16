//
//  DreamCache+Delete.swift
//  DreamCacher
//
//  Created by Nick Sarno on 8/14/21.
//

import Foundation

// MARK: DREAMCACHER+DELETE
// These are convenience public functions for external use.

extension DreamCache {
    
    /// Delete cached item at key. This is destructive.
    @discardableResult public func delete(forKey key: String) -> Result<Void, Error> {
        DreamCacherInteractor.delete(forKey: key, cache: self)
    }
    
    /// Delete entire cache and all items within. This is destructive.
    @discardableResult public func deleteCache() -> Result<Void, Error> {
        DreamCacherInteractor.deleteCache(cache: self)
    }

}
