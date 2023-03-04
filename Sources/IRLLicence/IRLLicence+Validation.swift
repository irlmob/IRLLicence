//
//  IRLLicence+Validation.swift
//
//  [IRLLicence](https://github.com/irlmob/IRLLicence)
//  Created by Denis Martin-Bruillot on 03/03/2023.
//
//  Copyright (c) 2023 Denis Martin-Bruillot.
//  All rights reserved. This code is licensed under the MIT License, which can be found in the LICENSE file.
//

import Foundation
import CryptoSwift

#if !os(Linux)
import Security
#else
import Glibc
import libvalid
#endif

// MARK: Licence Validation/Expiration
@available(macOS 10.13, iOS 11, tvOS 11, watchOS 4, *)
@available(swift 5.0)
public extension IRLLicence {
    /// Licence Key expiration date
    var expire: Date {
        Date(timeIntervalSince1970: TimeInterval(validity))
    }
    
    /// Is this Licence Experied
    var expired: Bool {
        expire > Date()
    }

    /// Validate if the licence key is Valid and not expired
    ///
    /// Once the Licence has been initialize successfuly, this is how you will check for its validity.
    /// - Note: You can call this method multiple time
    ///
    /// - Parameters:
    ///   - completion: The completion Handler with the validity
    func validate(completion: @escaping (Bool) -> Void) {
#if !os(Linux)
        guard let publicKey = try? Self.getPublicKey(key: publicKey),
              let licenceData = digest?.data(using: .utf8),
              let signatureData = Data(base64Encoded: userSignature + "==")
        else {
            print("The signature isn't a base64 string!")
            completion(false)
            return
        }

        var error: Unmanaged<CFError>?
        if SecKeyVerifySignature(
            publicKey,
            .rsaSignatureMessagePKCS1v15SHA512,
            licenceData as CFData,
            signatureData as CFData,
            &error
        ) {
            completion(expire > Date())
        } else {
            if let error = error {
                print(error.takeRetainedValue())
            }
            completion(false)
        }
#else
        Self.validationQueue.async  {
            guard let licenceData = digest,
                  let dataPtr = "\(licenceData)".cString(using: .utf8),
                  let signaturePtr = "\(userSignature)".cString(using: .utf8),
                  let publicKeyPtr = "\(publicKey)".cString(using: .utf8)
            else {
                completion(false)
                return
            }
            let result = verify(dataPtr, signaturePtr, publicKeyPtr)
            let valid = result == 0 && expire > Date()
            completion(valid)
        }
#endif
    }
}

// MARK: Licence Validation/Expiration Async/Await
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
@available(swift 5.0)
public extension IRLLicence {
    /// `async` - Validate if the licence key is Valid and not expired
    ///
    /// Once the Licence has been initialize successfuly, this is how you will check for its validity.
    /// - Note: You can call this method multiple time
    ///
    func validate() async -> Bool {
        await withUnsafeContinuation { continuation in
            validate() { continuation.resume(returning: $0) }
        }
    }
    
}
