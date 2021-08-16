//
//  Filer.swift
//  DreamCacher
//
//  Created by Nick Sarno on 8/13/21.
//

import Foundation

// MARK: FILER
/// Filer should be used for interacting with the FileManager.
///
/// - This is a utility class that is globally generic.
/// - All functions/variables should be static and there should be no 'instance' created.
final class Filer {
    
    // Singleton for FileManager class
    static private let fm = FileManager.default
    
    static func createDirectory(url: URL) -> Result<URL, Error> {
        Logger.log(type: .info, object: "Attempting to create directory at url: \(url.path)")
        do {
            try fm.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            Logger.log(type: .info, object: "Success creating directory at url: \(url.path)")
            return .success(url)
        } catch let error {
            Logger.log(type: .warning, object: "Failed to create directory at url: \(url.path)")
            return .failure(error)
        }
    }

    static func write(data: Data, toURL url: URL) -> Result<URL, Error> {
        Logger.log(type: .info, object: "Attempting to write data to url: \(url.path)")
        do {
            try data.write(to: url)
            Logger.log(type: .info, object: "Success writing data to url: \(url.path)")
            return .success(url)
        } catch let error {
            Logger.log(type: .warning, object: "Failed to write data to url: \(url.path)")
            return .failure(error)
        }
    }
    
    static func read(at url: URL) -> Result<Data, Error> {
        Logger.log(type: .info, object: "Attempting to read data at url: \(url.path)")
        do {
            let data = try Data(contentsOf: url)
            Logger.log(type: .info, object: "Success reading data at url: \(url.path)")
            return .success(data)
        } catch let error {
            Logger.log(type: .warning, object: "Failed to read data at url: \(url.path)")
            return .failure(error)
        }
    }
    
    @discardableResult static func delete(at url: URL) -> Result<Void, Error> {
        Logger.log(type: .info, object: "Attempting to delete data at url: \(url.path)")
        do {
            try fm.removeItem(at: url)
            Logger.log(type: .info, object: "Success deleting data at url: \(url.path)")
            return .success(())
        } catch let error {
            Logger.log(type: .warning, object: "Failed to delete data at url: \(url.path)")
            return .failure(error)
        }
    }

    static func urlExists(url: URL) -> Bool {
        fm.fileExists(atPath: url.path)
    }

    static func url(forDirectory: FileManager.SearchPathDirectory) -> URL? {
        fm.urls(for: .cachesDirectory, in: .userDomainMask).first
    }
    
    static func url(appendingFolder folder: String, toURL url: inout URL) {
        url.appendPathComponent(folder)
    }
    
    static func url(appendingFileName file: String, withExtension ext: String, toURL url: inout URL) {
        url.appendPathComponent(file + ext)
    }
    
    static func allURLs(inDirectoryURL url: URL, urlResourceKeys: Set<URLResourceKey>) -> [URL]? {
        fm.enumerator(at: url, includingPropertiesForKeys: Array(urlResourceKeys))?.allObjects as? [URL]
    }
    
    static func directoryIsEmpty(url: URL) -> Bool? {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: url.path)

            // If 2+ items, directory is not empty
            guard contents.count < 2 else {
                return false
            }
            
            // If only 1 item is in directory
            let item = contents.first ?? ""
            guard item == ".DS_Store" else {
                // If item is not DS_Store
                return false
            }
            
            // If item is DS_Store, directory is empty
            return true
        } catch _ {
            return nil
        }
    }
        
}
