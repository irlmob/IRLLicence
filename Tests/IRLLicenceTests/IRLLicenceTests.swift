//
//  File.swift
//  
//
//  Created by Denis Martin-Bruillot on 20/02/2023.
//

import XCTest
@testable import IRLLicence

final class IRLLicenceTests: XCTestCase {
    let email = "notanemail@notanemail.com"
    
    let hostname: String = "irlmobile.com"
    
#if !os(Linux)
    func testLicenceXCTBundle4096() throws {
        let decoder = try IRLLicence(email: email,
                                     licence: licence4096XCTBundle,
                                     publicKey: publicKey4096)
        print("📱 App Bundle Id: " + decoder.licenceassociatedID)
        print("🔄 Licence: " + decoder.licence)
        print("✅ Expire on: \(decoder.expire)")
        let expectation = XCTestExpectation(description: "validate \(decoder.licence)")
        decoder.validate { result in
            XCTAssertTrue(result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testLicenceXCTBundle2048() throws {
        let decoder = try IRLLicence(email: email,
                                     licence: licence2048XCTBundle,
                                     publicKey: publicKey2048)
        print("📱 App Bundle Id: " + decoder.licenceassociatedID)
        print("🔄 Licence: " + decoder.licence)
        print("✅ Expire on: \(decoder.expire)")
        let expectation = XCTestExpectation(description: "validate \(decoder.licence)")
        decoder.validate { result in
            XCTAssertTrue(result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
#endif
}

@available(macOS 10.15, iOS 13.0.0, tvOS 13.0.0, watchOS 6.0, *)
extension IRLLicenceTests {
#if !os(Linux)
    func testAsyncLicenceXCTBundle4096() async throws {
        let decoder = try IRLLicence(email: email,
                                     licence: licence4096XCTBundle,
                                     publicKey: publicKey4096)
        print("📱 App Bundle Id: " + decoder.licenceassociatedID)
        print("🔄 Licence: " + decoder.licence)
        print("✅ Expire on: \(decoder.expire)")
        let result = await decoder.validate()
        XCTAssertTrue(result)
    }

    func testAsyncLicenceXCTBundle2048() async throws {
        let decoder = try IRLLicence(email: email,
                                     licence: licence2048XCTBundle,
                                     publicKey: publicKey2048)
        print("📱 App Bundle Id: " + decoder.licenceassociatedID)
        print("🔄 Licence: " + decoder.licence)
        print("✅ Expire on: \(decoder.expire)")
        let result = await decoder.validate()
        XCTAssertTrue(result)
    }
#endif
    
    func testAsyncLicenceDomain1024() async throws {
        let decoder = try IRLLicence(email: email,
                                     hostname: hostname,
                                     licence: licence1024Domain,
                                     publicKey: publicKey1024)
        print("🔑 Key Lenght: \(decoder.publicKey.count)")
        print("🌍 Domain: " + decoder.licenceassociatedID)
        print("🔄 Licence: " + decoder.licence)
        print("✅ Expire on: \(decoder.expire)")

        let result = await decoder.validate()
         XCTAssertTrue(result)
    }
    
    func testAsyncLicenceDomain2048() async throws {
        let decoder = try IRLLicence(email: email,
                                     hostname: hostname,
                                     licence: licence2048Domain,
                                     publicKey: publicKey2048)
        print("🔑 Key Lenght: \(decoder.publicKey.count)")
        print("🌍 Domain: " + decoder.licenceassociatedID)
        print("🔄 Licence: " + decoder.licence)
        print("✅ Expire on: \(decoder.expire)")

        let result = await decoder.validate()
         XCTAssertTrue(result)
    }
}
