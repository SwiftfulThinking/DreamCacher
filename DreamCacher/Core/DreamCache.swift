//
//  DreamCache.swift
//  DreamCacher
//
//  Created by Nick Sarno on 8/13/21.
//

import Foundation

final public class DreamCache {
    
    // MARK: PUBLIC (STATIC)

    /// Default instance of DiskCacher
    static public let shared = DreamCache(name: "default")

    /// Configure additional settings for DiskCacher.
    /// - Parameters:
    ///   - maximumAllowedSize: Maximum total size of all storage in DiskCacher. This will be an aggregate limit across all DiskCacher instances.
    ///   - isLoggingEnabled: Allow logging for visibility into the framework.
    static public func updateConfiguration(maximumAllowedSizeInMB mb: Double = 0, isPrintEnabled: Bool = true) {
        let max = max(0, mb.convertingMBToBytes)
        
        // Set limit for all caches
        self.aggregateCacheSizeLimit = max
        
        // Set sub-limit for shared instance
        self.shared.cacheSizeLimit = max
        
        // Clean up old cache folders
        DreamCacherInteractor.cleanCaches()
        
        Logger.updateConfiguration(isPrintEnabled: isPrintEnabled)
    }
    
    /// Force deletes all DreamCacher folders and files. This is destructive.
    @discardableResult static public func deleteAllDreamCachers() -> Result<Void, Error> {
        DreamCacherInteractor.deleteAllCaches()
    }
        
    // MARK: PRIVATE (STATIC)
    
    /// Maximum size of all storage in DreamCacher in bytes, including shared instance and created instances. 0 means no limit.
    static public private(set) var aggregateCacheSizeLimit: Int = 0 {
        didSet {
            Logger.log(type: .info, object: "Aggregate cache size limit for all DreamCachers set to '\(aggregateCacheSizeLimit)'")
        }
    }
        
    /// Current size of all storage in DreamCacher (aggregate across all instances).
    static public var aggregateCacheSize: Int? {
        DreamCacherInteractor.getAggregateCacheSize()
    }
    
    /// Aggregate set of names for all caches created. Used to warn against creating duplicate caches.
    static private var cacheNamesInMemory: Set<String> = []
        
    // MARK: PUBLIC (INSTANCE)
    
    public init(name: String, maximumAllowedSizeInMB: Double? = nil) {
        let limit = max(0, maximumAllowedSizeInMB?.convertingMBToBytes ?? DreamCache.aggregateCacheSizeLimit)
        self.cacheSizeLimit = limit
        self.cacheName = name
        
        if case .failure(let error) = checkCacheName() {
            Logger.log(type: .severe, object: error.localizedDescription)
        }
    }
        
    /// Maximum size of storage in this instance of DreamCache in bytes. 0 means no limit.
    public private(set) var cacheSizeLimit: Int {
        didSet {
            Logger.log(type: .info, object: "Cache size limit for DreamCache named '\(cacheName)' set to '\(cacheSizeLimit)'")
        }
    }
    
    /// Name used for this instance of DreamCache.
    public let cacheName: String
    
    /// Current size of all storage in this cache instance.
    public var cacheSize: Int? {
        DreamCacherInteractor.getCacheSize(cache: self)
    }
        
    // MARK: PRIVATE (INSTANCE)
            
    /// Checks that the cache name is not blank and not already in use by another instance of DreamCache.
    private func checkCacheName() -> Result<(),Error> {
        
        enum CacheNameError: LocalizedError {
            case blankName
            case duplicate
            
            var errorDescription: String? {
                switch self {
                case .blankName: return "You should not initialize a DreamCache without a valid name (more than 0 characters)."
                case .duplicate: return "There are duplicate instances of DreamCache that have the same name. This may lead to unwanted behavior. Please change the name of your cache (do not use 'default')."
                }
            }
        }
        
        guard !cacheName.isEmpty else {
            return .failure(CacheNameError.blankName)
        }
        
        guard !DreamCache.cacheNamesInMemory.contains(cacheName) else {
            return .failure(CacheNameError.duplicate)
        }
        
        DreamCache.cacheNamesInMemory.insert(cacheName)
        return .success(())
    }
            
}
