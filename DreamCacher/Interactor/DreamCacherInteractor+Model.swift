//
//  DreamCacherInteractor+Model.swift
//  DreamCacher
//
//  Created by Nick Sarno on 8/14/21.
//

import Foundation

// MARK: INTERACTOR+MODELS

extension DreamCacherInteractor {
    
    // MARK: FILEMETA
    
    struct FileMeta {
        let url: URL
        let lastAccessDate: Date?
        let creationDate: Date?
        let isDirectory: Bool
        let fileSize: Int

        init?(fileURL: URL, resourceKeys: Set<URLResourceKey>) {
            let meta = try? fileURL.resourceValues(forKeys: resourceKeys)
            guard let meta = meta else { return nil }
            
            self.init(
                fileURL: fileURL,
                lastAccessDate: meta.contentAccessDate,
                creationDate: meta.creationDate,
                isDirectory: meta.isDirectory ?? false,
                fileSize: meta.fileSize ?? 0)
        }
        
        init(fileURL: URL, lastAccessDate: Date?, creationDate: Date?, isDirectory: Bool, fileSize: Int) {
            self.url = fileURL
            self.lastAccessDate = lastAccessDate
            self.creationDate = creationDate
            self.isDirectory = isDirectory
            self.fileSize = fileSize
        }
        
    }
    
}
