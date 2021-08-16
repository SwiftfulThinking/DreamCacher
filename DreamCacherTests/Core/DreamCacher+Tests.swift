//
//  DreamCacher+Tests.swift
//  DreamCacherTests
//
//  Created by Nick Sarno on 8/14/21.
//

import XCTest
@testable import DreamCacher

// Naming structure:    test_UnitOfWork_StateUnderTest_ExpectedBehavior
// Test structure:      Given, When, Then

class DreamCacher_Tests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {        
        // Reset aggregate cache
        DreamCache.updateConfiguration(maximumAllowedSizeInMB: 0)
        DreamCache.deleteAllDreamCachers()
    }
    
    // MARK: AGGREGATE SIZE LIMIT
    
    func test_DreamCacher_aggregateCacheSizeLimit_shouldBe0() {
        // Then
        XCTAssertEqual(DreamCache.aggregateCacheSizeLimit, 0)
    }
    
    func test_DreamCacher_aggregateCacheSizeLimit_shouldUpdate() {
        // Given
        let limit: Double = .random()

        // When
        DreamCache.updateConfiguration(maximumAllowedSizeInMB: limit)
        
        // Then
        XCTAssertEqual(DreamCache.aggregateCacheSizeLimit, limit.convertingMBToBytes)
    }
    
    func test_DreamCacher_aggregateCacheSizeLimit_shouldBeGreaterThanOrEqualToZero() {
        // Given
        let limit: Double = -.random()

        // When
        DreamCache.updateConfiguration(maximumAllowedSizeInMB: limit)
        
        // Then
        let wanted = max(0, limit.convertingMBToBytes)
        XCTAssertEqual(DreamCache.aggregateCacheSizeLimit, wanted)
    }
    
    // MARK: SINGLETON SIZE LIMIT
    
    func test_DreamCacher_singletonInstanceSizeLimit_shouldBe0() {
        // Then
        XCTAssertEqual(DreamCache.shared.cacheSizeLimit, 0)
    }
    
    func test_DreamCacher_singletonInstanceSizeLimit_shouldUpdate() {
        // Given
        let limit: Double = .random()

        // When
        DreamCache.updateConfiguration(maximumAllowedSizeInMB: limit)
        
        // Then
        XCTAssertEqual(DreamCache.shared.cacheSizeLimit, limit.convertingMBToBytes)
    }
    
    // MARK: INSTANCE SIZE LIMIT
    
    func test_DreamCacher_newInstanceLimit_shouldBeEqualToAggregateLimit() {
        // Given
        let cache = DreamCache(name: UUID().uuidString)
        
        // When
        
        
        // Then
        XCTAssertEqual(cache.cacheSizeLimit, DreamCache.aggregateCacheSizeLimit)
    }
        
    func test_DreamCacher_newInstanceLimit_shouldUpdate() {
        // Given
        let limit: Double = .random() //Double.random(in: 0..<999999)
        let cache = DreamCache(name: UUID().uuidString, maximumAllowedSizeInMB: limit)
        
        // When
        
        
        // Then
        XCTAssertEqual(cache.cacheSizeLimit, limit.convertingMBToBytes)
    }
    
    func test_DreamCacher_newInstanceLimit_shouldBeGreaterThanOrEqualToZero() {
        // Given
        let limit: Double = -.random()

        // When
        DreamCache.updateConfiguration(maximumAllowedSizeInMB: limit)
        
        // Then
        let wanted = max(0, limit.convertingMBToBytes)
        XCTAssertEqual(DreamCache.aggregateCacheSizeLimit, wanted)
    }
    
    // MARK: AGGREGATE SIZE

    func test_DreamCacher_aggregateCache_shouldBeEmpty() {
        // Given
        let size = DreamCache.aggregateCacheSize ?? 0
        // When
        
        // Then
        XCTAssertEqual(size, 0, accuracy: 10000) // base folder should be less than 0.1 kb
    }
    
    func test_DreamCacher_aggregateCache_savesWithoutLimit() {
        // Given
        guard let image = UIImage.random(size: CGSize(width: 800, height: 800)) else { return }
        let data = image.jpegData(compressionQuality: 1)?.bytes ?? 0
        
        // When
        for _ in 0..<100 {
            let cache = DreamCache(name: UUID().uuidString)
            cache.save(imageJPG: image, forKey: UUID().uuidString)
        }
        
        // Then
        let size = DreamCache.aggregateCacheSize ?? 0
        
        let expectedSize = 100 * data
        let accuracy = 100 * 3 * 1000
        XCTAssertEqual(size, expectedSize, accuracy: accuracy)
    }
    
    func test_DreamCacher_aggregateCache_savesWithLimit() {
        // Given
        guard let image = UIImage.random(size: CGSize(width: 800, height: 800)) else { return }
        
        // When
        let limit = Double.random(in: 0..<7.0)
        DreamCache.updateConfiguration(maximumAllowedSizeInMB: limit)
        
        for _ in 0..<100 {
            let cache = DreamCache(name: UUID().uuidString)
            cache.save(imageJPG: image, forKey: UUID().uuidString)
        }
        
        // Then
        let size = DreamCache.aggregateCacheSize ?? 0
        
        let expectedSize = Int(limit * 1000000)  // 5,000,000 bytes = 5 mb
        XCTAssertLessThan(size, expectedSize)
    }
    
    // MARK: INSTANCE SIZE
    
    func test_DreamCacher_newInstanceCache_shouldBeEmpty() {
        // Given
        let cache = DreamCache(name: UUID().uuidString)
        let size = cache.cacheSize ?? 0
        // When
        
        // Then
        XCTAssertEqual(size, 0, accuracy: 10000) // base folder should be less than 0.1 kb
    }
    
    func test_DreamCacher_newInstanceCache_savesWithoutLimit() {
        // Given
        let cache = DreamCache(name: UUID().uuidString)
        guard let image = UIImage.random(size: CGSize(width: 800, height: 800)) else { return }
        let data = image.jpegData(compressionQuality: 1)?.bytes ?? 0

        // When
        for _ in 0..<100 {
            cache.save(imageJPG: image, forKey: UUID().uuidString)
        }
        
        // Then
        let size = cache.cacheSize ?? 0

        let expectedSize = 100 * data
        let accuracy = 100 * 3 * 1000
        XCTAssertEqual(size, expectedSize, accuracy: accuracy)
    }
    
    func test_DreamCacher_newInstanceCache_savesWithLimit() {
        // Given
        let limit = Double.random(in: 0..<7.0)
        let cache = DreamCache(name: UUID().uuidString, maximumAllowedSizeInMB: limit)
        guard let image = UIImage.random(size: CGSize(width: 800, height: 800)) else { return }
        
        // When
        for _ in 0..<100 {
            cache.save(imageJPG: image, forKey: UUID().uuidString)
        }
        
        // Then
        let size = cache.cacheSize ?? 0

        let expectedSize = Int(limit * 1000000)  // 5,000,000 bytes = 5 mb
        XCTAssertLessThan(size, expectedSize)
    }
    
    
    // MARK: INSTANCE NAME
    
    func test_DreamCacher_newInstanceName_shouldUpdate() {
        // Given
        let name = UUID().uuidString
        let cache = DreamCache(name: name)
        
        // When
        
        
        // Then
        XCTAssertEqual(cache.cacheName, name)
    }
    
    // MARK: AGGREGATE DELETE
    
    func test_DreamCacher_aggregateCache_shouldDelete() {
        // Given
        let name = UUID().uuidString
        let cache = DreamCache(name: name)
        
        // When
        let fileName = UUID().uuidString
        cache.save(bool: true, forKey: fileName)
        let deleted = DreamCache.deleteAllDreamCachers()

        // Then
        let cached = cache.bool(forKey: fileName)
        XCTAssertSuccess(deleted)
        XCTAssertNil(cached)
    }
    
    func test_DreamCacher_aggregateCache_shouldFunctionAfterBeingDeleted() {
        // Given
        let name = UUID().uuidString
        let cache = DreamCache(name: name)
        
        // When
        let fileName = UUID().uuidString
        let saved1 = cache.save(bool: true, forKey: fileName)
        let cached1 = cache.bool(forKey: fileName)
        
        let deleted = DreamCache.deleteAllDreamCachers()
        let cached2 = cache.bool(forKey: fileName)

        let saved2 = cache.save(bool: false, forKey: fileName)
        let cached3 = cache.bool(forKey: fileName)

        // Then
        XCTAssertSuccess(saved1)
        XCTAssertNotNil(cached1)

        XCTAssertSuccess(deleted)
        XCTAssertNil(cached2)

        XCTAssertSuccess(saved2)
        XCTAssertNotNil(cached3)
    }
    
    // MARK: INSTANCE DELETE
    
    func test_DreamCacher_newInstance_shouldDelete() {
        // Given
        let name = UUID().uuidString
        let cache = DreamCache(name: name)
        
        // When
        let fileName = UUID().uuidString
        cache.save(bool: true, forKey: fileName)
        cache.deleteCache()
        
        // Then
        let cached = cache.bool(forKey: fileName)
        XCTAssertNil(cached)
    }
    
    
            
    func test_DreamCacher_newInstance_shouldFunctionAfterBeingDeleted() {
        // Given
        let name = UUID().uuidString
        let cache = DreamCache(name: name)
        
        // When
        let fileName = UUID().uuidString
        let saved1 = cache.save(bool: true, forKey: fileName)
        let cached1 = cache.bool(forKey: fileName)
        
        let deleted = cache.deleteCache()
        let cached2 = cache.bool(forKey: fileName)
        
        let saved2 = cache.save(bool: false, forKey: fileName)
        let cached3 = cache.bool(forKey: fileName)

        // Then
        XCTAssertSuccess(saved1)
        XCTAssertNotNil(cached1)

        XCTAssertSuccess(deleted)
        XCTAssertNil(cached2)
        
        XCTAssertSuccess(saved2)
        XCTAssertNotNil(cached3)
    }

}


