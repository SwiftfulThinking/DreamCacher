//
//  DreamCacherInteractor.swift
//  DreamCacher
//
//  Created by Nick Sarno on 8/13/21.
//

import Foundation

// MARK: INTERACTOR
// The interactor is in charge of communication between DreamCacher instances and the repository (FileManager)

class DreamCacherInteractor {
    
    // MARK: PUBLIC (EXTERNAL)
    
    static func getAggregateCacheSize() -> Int? {
        guard let url = baseURL() else { return nil }
        return getDirectorySize(url: url)
    }
    
    static func cleanCaches() {
        guard let url = baseURL() else { return }
        let directories = metadataForURLs(inDirectoryURL: url)?.filter({ $0.isDirectory }) ?? []
        
        for directory in directories {
            if Filer.directoryIsEmpty(url: directory.url) ?? false {
                Filer.delete(at: directory.url)
            }
        }
    }
    
    // MARK: PUBLIC (INTERNAL)
    
    static internal func baseURL() -> URL? {
        guard var url = Filer.url(forDirectory: .cachesDirectory) else { return nil }
        Filer.url(appendingFolder: "DreamCacher", toURL: &url)
        return url
    }
    
    static internal func cacheURL(cache: DreamCache) -> URL? {
        guard var url = baseURL() else { return nil }
        Filer.url(appendingFolder: cache.cacheName, toURL: &url)
        return url
    }
        
    static internal func fileURL(fileName name: String, fileExtension ext: SupportedExtension, cache: DreamCache) -> URL? {
        guard var url = cacheURL(cache: cache) else { return nil }
        Filer.url(appendingFileName: name, withExtension: ext.rawValue, toURL: &url)
        return url
    }
    
    static internal func manageCacheSizes(cache: DreamCache, file: FileType) -> Result<Void, Error> {
        guard let sizeRequested = file.toData()?.bytes else {
            return .failure(InteractorError.noData)
        }
        
        // manage cache size for local cache instance
        let prepareCache = manageCacheSize(cache: cache, sizeLimit: cache.cacheSizeLimit, sizeRequested: sizeRequested)
        switch prepareCache {
        case .success():
            break
        case .failure:
            return prepareCache
        }
        
        // manage cache for aggregate Disk Cacher
        return manageAggregateCacheSize(sizeRequested: sizeRequested)
    }
    
    static internal func getCacheSize(cache: DreamCache) -> Int? {
        guard let url = cacheURL(cache: cache) else { return nil }
        return getDirectorySize(url: url)
    }
        
    // MARK: PRIVATE

    static private func manageCacheSize(cache: DreamCache, sizeLimit: Int, sizeRequested: Int) -> Result<Void, Error> {
        guard sizeLimit > 0 else {
            return .success(())
        }
        
        guard let url = cacheURL(cache: cache) else {
            return .failure(InteractorError.invalidURL)
        }
        return manageDirectorySize(url: url, sizeLimit: sizeLimit, sizeRequested: sizeRequested)
    }
    
    static private func manageAggregateCacheSize(sizeRequested: Int) -> Result<Void, Error> {
        let sizeLimit = DreamCache.aggregateCacheSizeLimit
        
        guard sizeLimit > 0 else {
            return .success(())
        }

        guard let url = baseURL() else {
            return .failure(InteractorError.invalidURL)
        }
        
        return manageDirectorySize(url: url, sizeLimit: sizeLimit, sizeRequested: sizeRequested)
    }
    
    static private func manageDirectorySize(url: URL, sizeLimit: Int, sizeRequested: Int) -> Result<Void, Error> {
        
        guard sizeLimit > sizeRequested else {
            return .failure(InteractorError.fileTooLarge(maximumLimit: sizeLimit, sizeRequested: sizeRequested))
        }
        
        // get metadata for all files in directory (includes file sizes)
        guard var metadata = metadataForURLs(inDirectoryURL: url) else {
            return .failure(InteractorError.directoryNotFound)
        }
                
        // available space outstanding
        var availableSize = sizeLimit - totalSize(ofMetadata: metadata)
                
        // Check if there's enough space available
        guard availableSize < sizeRequested else {
            return .success(())
        }
        Logger.log(type: .info, object: "There is not enough free space available in a cache. Attempting to delete items.")
        
        // remove directories from data
        // we want to delete files, not folders
        metadata.removeAll(where: { $0.isDirectory })
        
        // sort data by most recently used elements first
        metadata.sort { a, b in
            let d1 = a.lastAccessDate ?? a.creationDate ?? Date(timeIntervalSince1970: 0)
            let d2 = b.lastAccessDate ?? b.creationDate ?? Date(timeIntervalSince1970: 0)
            return d1 > d2
        }
        
        var deletedURLs: [URL] = []
        var problemURLs: [URL] = []

        // delete least recently used items until there's enough available space
        while availableSize < sizeRequested, let meta = metadata.popLast() {
            switch Filer.delete(at: meta.url) {
            case .success():
                availableSize += meta.fileSize
                deletedURLs.append(meta.url)
            case .failure:
                problemURLs.append(meta.url)
            }
        }
        
        return availableSize >= sizeRequested ? .success(()) :
            .failure(InteractorError.failedToCleanCache(
                        directory: url,
                        maximumLimit: sizeLimit,
                        availableSize: availableSize,
                        sizeRequested: sizeRequested,
                        urlsDeleted: deletedURLs,
                        urlsUnableToDelete: problemURLs))
    }
    
    static private let urlResourceKeys: Set<URLResourceKey> = [.fileSizeKey, .contentAccessDateKey, .isDirectoryKey]

    static private func metadataForURLs(inDirectoryURL url: URL) -> [FileMeta]? {
        Filer.allURLs(inDirectoryURL: url, urlResourceKeys: urlResourceKeys)?
            .compactMap({ FileMeta(fileURL: $0, resourceKeys: urlResourceKeys) })
    }
    
    static private func totalSize(ofMetadata metadata: [FileMeta]) -> Int {
        return metadata.reduce(into: 0, { size, meta in
            return size += meta.fileSize
        })
    }
    
    static private func getDirectorySize(url: URL) -> Int? {
        guard let metadata = metadataForURLs(inDirectoryURL: url) else {
            return nil
        }
        return totalSize(ofMetadata: metadata)
    }

}
