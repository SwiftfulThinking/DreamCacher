//
//  XCTest.swift
//  DreamCacherTests
//
//  Created by Nick Sarno on 8/15/21.
//

import XCTest

extension XCTest {
    
    func XCTAssertSuccess(_ result: Result<Any, Error>) {
        switch result {
        case .success: XCTAssertTrue(true)
        case .failure(let error): XCTFail(error.localizedDescription)
        }
    }
    
    func XCTAssertSuccess(_ result: Result<URL, Error>) {
        switch result {
        case .success: XCTAssertTrue(true)
        case .failure(let error): XCTFail(error.localizedDescription)
        }
    }
    
    func XCTAssertSuccess(_ result: Result<Void, Error>) {
        switch result {
        case .success: XCTAssertTrue(true)
        case .failure(let error): XCTFail(error.localizedDescription)
        }
    }
    
    func XCTAssertFailure(_ result: Result<Any, Error>) {
        switch result {
        case .success: XCTFail()
        case .failure: XCTAssertTrue(true)
        }
    }
    
    func XCTAssertFailure(_ result: Result<URL, Error>) {
        switch result {
        case .success: XCTFail()
        case .failure: XCTAssertTrue(true)
        }
    }
    
    func XCTAssertFailure(_ result: Result<Void, Error>) {
        switch result {
        case .success: XCTFail()
        case .failure: XCTAssertTrue(true)
        }
    }
        
}
