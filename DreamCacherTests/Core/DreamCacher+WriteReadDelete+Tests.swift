//
//  DreamCacher+WriteReadDelete+Tests.swift
//  DreamCacherTests
//
//  Created by Nick Sarno on 8/15/21.
//

import XCTest
@testable import DreamCacher

class DreamCacher_WriteReadDelete_Tests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        DreamCache.updateConfiguration(maximumAllowedSizeInMB: 0)
        DreamCache.deleteAllDreamCachers()
    }
    
    // MARK: JPG
    
    func test_DreamCacher_WriteReadDelete_jpg() {
        // Given
        let cacheName: String = UUID().uuidString
        let cache = DreamCache(name: cacheName)
        let fileName: String = UUID().uuidString
        guard let image: UIImage = .random() else { return }
        
        // When
        let saved = cache.save(imageJPG: image, forKey: fileName)
        let cached = cache.image(forKey: fileName)
        let deleted = cache.delete(forKey: fileName)
        let cachedNil = cache.image(forKey: fileName)
        
        // Then
        XCTAssertSuccess(saved)
        XCTAssertNotNil(cached)
        XCTAssertSuccess(deleted)
        XCTAssertNil(cachedNil)
    }
    
    // MARK: PNG
    
    func test_DreamCacher_WriteReadDelete_png() {
        // Given
        let cacheName: String = UUID().uuidString
        let cache = DreamCache(name: cacheName)
        let fileName: String = UUID().uuidString
        guard let image: UIImage = .random() else { return }
        
        // When
        let saved = cache.save(imagePNG: image, forKey: fileName)
        let cached = cache.image(forKey: fileName)
        let deleted = cache.delete(forKey: fileName)
        let cachedNil = cache.image(forKey: fileName)
        
        // Then
        XCTAssertSuccess(saved)
        XCTAssertNotNil(cached)
        XCTAssertSuccess(deleted)
        XCTAssertNil(cachedNil)
    }
    
    // MARK: MP4
    
    func test_DreamCacher_WriteReadDelete_mp4() {
        // Given
        let cacheName: String = UUID().uuidString
        let cache = DreamCache(name: cacheName)
        let fileName: String = UUID().uuidString
        guard let url: URL = .randomMP4() else { return }
        
        // When
        let saved = cache.save(videoMP4AtUrl: url, forKey: fileName)
        let cached = cache.video(forKey: fileName)
        let deleted = cache.delete(forKey: fileName)
        let cachedNil = cache.video(forKey: fileName)
        
        // Then
        XCTAssertSuccess(saved)
        XCTAssertNotNil(cached)
        XCTAssertSuccess(deleted)
        XCTAssertNil(cachedNil)
    }
    
    // MARK: MP3
    
    func test_DreamCacher_WriteReadDelete_mp3() {
        // Given
        let cacheName: String = UUID().uuidString
        let cache = DreamCache(name: cacheName)
        let fileName: String = UUID().uuidString
        guard let url: URL = .randomMP3() else { return }

        // When
        let saved = cache.save(audioMP3AtUrl: url, forKey: fileName)
        let cached = cache.audio(forKey: fileName)
        let deleted = cache.delete(forKey: fileName)
        let cachedNil = cache.audio(forKey: fileName)
        
        // Then
        XCTAssertSuccess(saved)
        XCTAssertNotNil(cached)
        XCTAssertSuccess(deleted)
        XCTAssertNil(cachedNil)
    }
    
    // MARK: CODABLE
    
    struct TestModel: Codable {
        let id: String
        let bool: Bool
        let int: CGFloat
        let array: [String]
        
        init() {
            id = UUID().uuidString
            bool = Bool.random()
            int = .random()
            array = [UUID().uuidString, UUID().uuidString, UUID().uuidString]
        }
    }
    
    func test_DreamCacher_WriteReadDelete_codable() {
        // Given
        let cacheName: String = UUID().uuidString
        let cache = DreamCache(name: cacheName)
        let fileName: String = UUID().uuidString
        let object: TestModel = TestModel()

        // When
        let saved = cache.save(object: object, forKey: fileName)
        let cached: TestModel? = cache.object(forKey: fileName)
        let deleted = cache.delete(forKey: fileName)
        let cachedNil: TestModel? = cache.object(forKey: fileName)
        
        // Then
        XCTAssertSuccess(saved)
        XCTAssertNotNil(cached)
        XCTAssertSuccess(deleted)
        XCTAssertNil(cachedNil)
    }
    
    // MARK: CODABLE ARRAY
    
    func test_DreamCacher_WriteReadDelete_codableArray() {
        // Given
        let cacheName: String = UUID().uuidString
        let cache = DreamCache(name: cacheName)
        let fileName: String = UUID().uuidString
        var objects: [TestModel] = []

        for _ in 0..<Int.random(in: 0..<999) {
            objects.append(TestModel())
        }

        // When
        let saved = cache.save(objects: objects, forKey: fileName)
        let cached: [TestModel]? = cache.objects(forKey: fileName)
        let deleted = cache.delete(forKey: fileName)
        let cachedNil: [TestModel]? = cache.objects(forKey: fileName)

        // Then
        XCTAssertSuccess(saved)
        XCTAssertNotNil(cached)
        XCTAssertSuccess(deleted)
        XCTAssertNil(cachedNil)
    }

    // MARK: ANY
    
    func test_DreamCacher_WriteReadDelete_any() {
        // Given
        let cacheName: String = UUID().uuidString
        let cache = DreamCache(name: cacheName)
        
        // valid
        let string = UUID().uuidString
        let bool = Bool.random()
        let int = Int.random(in: -999999...999999)
        let cgfloat = CGFloat.random()
        let double = Double.random()
        
        // invalid
        let object = TestModel()
        let objects = [TestModel(), TestModel(), TestModel()]
        guard
            let image = UIImage.random(),
            let url1: URL = .randomMP4(),
            let url2: URL = .randomMP3() else {
            return
        }

        let validOptions: [Any] = [string, bool, int, cgfloat, double, image, url1, url2]
        
        for option in validOptions {
            
            // When
            let fileName: String = UUID().uuidString
            let saved = cache.save(value: option, forKey: fileName)
            let cached: Any? = cache.any(forKey: fileName)
            let deleted = cache.delete(forKey: fileName)
            let cachedNil: Any? = cache.any(forKey: fileName)

            // Then
            XCTAssertSuccess(saved)
            XCTAssertNotNil(cached)
            XCTAssertSuccess(deleted)
            XCTAssertNil(cachedNil)
        }
        
        let invalidOptions: [Any] = [object, objects]

        for option in invalidOptions {
            // When
            let fileName: String = UUID().uuidString
            let saved = cache.save(value: option, forKey: fileName)
            let cached: Any? = cache.any(forKey: fileName)

            // Then
            XCTAssertFailure(saved)
            XCTAssertNil(cached)
        }
    }
    
    // MARK: ANY STRING
    
    func test_DreamCacher_WriteReadDelete_anyString() {
        // Given
        let cacheName: String = UUID().uuidString
        let cache = DreamCache(name: cacheName)
        let fileName: String = UUID().uuidString

        // valid
        let string = UUID().uuidString

        // When
        let saved = cache.save(string: string, forKey: fileName)
        let cached: Any? = cache.string(forKey: fileName)
        let deleted = cache.delete(forKey: fileName)
        let cachedNil: Any? = cache.any(forKey: fileName)

        // Then
        XCTAssertSuccess(saved)
        XCTAssertNotNil(cached)
        XCTAssertSuccess(deleted)
        XCTAssertNil(cachedNil)
    }
    
    // MARK: ANY BOOL
    
    func test_DreamCacher_WriteReadDelete_anyBool() {
        // Given
        let cacheName: String = UUID().uuidString
        let cache = DreamCache(name: cacheName)
        let fileName: String = UUID().uuidString

        // valid
        let bool = Bool.random()

        // When
        let saved = cache.save(bool: bool, forKey: fileName)
        let cached: Any? = cache.bool(forKey: fileName)
        let deleted = cache.delete(forKey: fileName)
        let cachedNil: Any? = cache.any(forKey: fileName)

        // Then
        XCTAssertSuccess(saved)
        XCTAssertNotNil(cached)
        XCTAssertSuccess(deleted)
        XCTAssertNil(cachedNil)
    }
    
    // MARK: ANY ARRAY
    
    func test_DreamCacher_WriteReadDelete_anyArray() {
        // Given
        let cacheName: String = UUID().uuidString
        let cache = DreamCache(name: cacheName)
        let fileName: String = UUID().uuidString

        // valid
        let string = UUID().uuidString
        let bool = Bool.random()
        let int = Int.random(in: -999999...999999)
        let cgfloat = CGFloat.random()
        let double = Double.random()

        // invalid
        let object = TestModel()

        var array: [Any] = [string, bool, int, cgfloat, double]

        // When
        let saved = cache.save(array: array, forKey: fileName)
        let cached: Any? = cache.array(forKey: fileName)
        let deleted = cache.delete(forKey: fileName)
        let cachedNil: Any? = cache.array(forKey: fileName)

        // Then
        XCTAssertSuccess(saved)
        XCTAssertNotNil(cached)
        XCTAssertSuccess(deleted)
        XCTAssertNil(cachedNil)

        array.append(object)

        // When
        let notSaved = cache.save(array: array, forKey: fileName)
        let notCached: Any? = cache.any(forKey: fileName)

        // Then
        XCTAssertFailure(notSaved)
        XCTAssertNil(notCached)
    }

}
