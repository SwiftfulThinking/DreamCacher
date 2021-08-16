//
//  DreamCacherInteractor+Read.swift
//  DreamCacher
//
//  Created by Nick Sarno on 8/14/21.
//

import Foundation

// MARK: INTERACTOR+READ

extension DreamCacherInteractor {
    
    // MARK: PUBLIC
    
    static func read(forKey key: String, cache: DreamCache) -> FileType? {
        let supportedExtensions = SupportedExtension.allCases
        
        for ext in supportedExtensions {
            if let file = read(key: key, fileExtension: ext, cache: cache) {
                return file
            }
        }

        return nil
    }
    
    static func read(key: String, fileExtension: SupportedExtension, cache: DreamCache) -> FileType? {
        guard case .success(let data) = getData(key: key, fileExtension: fileExtension, cache: cache) else { return nil }
        return FileType(data: data, ext: fileExtension)
    }
    
    static func readObject<T:Codable>(key: String, cache: DreamCache) -> T? {
        guard case .success(let data) = getData(key: key, fileExtension: .txt, cache: cache) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
    
    static func readObjects<T:Codable>(key: String, cache: DreamCache) -> [T]? {
        guard case .success(let data) = getData(key: key, fileExtension: .txt, cache: cache) else { return nil }
        return try? decoder.decode([T].self, from: data)
    }
    
    static func readURL(key: String, fileExtension: SupportedExtension, cache: DreamCache) -> URL? {
        guard let url = fileURL(fileName: key, fileExtension: fileExtension, cache: cache) else { return nil }
        guard Filer.urlExists(url: url) else { return nil }
        return url
    }

    // MARK: PRIVATE

    static private let decoder = JSONDecoder()

    static func getData(key: String, fileExtension: SupportedExtension, cache: DreamCache) -> Result<Data, Error> {
        guard let url = fileURL(fileName: key, fileExtension: fileExtension, cache: cache) else {
            return .failure(InteractorError.invalidURL)
        }
        
        guard Filer.urlExists(url: url) else {
            return .failure(InteractorError.fileNotFound)
        }
        
        return Filer.read(at: url)
    }
        
    
}
