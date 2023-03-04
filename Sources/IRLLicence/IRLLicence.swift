//
//  IRLLicence.swift
//
//  [IRLLicence](https://github.com/irlmob/IRLLicence)
//  Created by Denis Martin-Bruillot on 03/03/2023.
//
//  Copyright (c) 2023 Denis Martin-Bruillot.
//  All rights reserved. This code is licensed under the MIT License, which can be found in the LICENSE file.
//

import Foundation
import CryptoSwift

/// Validate the Licence Data
///
/// This licence is associated with your `App Bundle ID` and your `email`
///
/// ## Example
///
/// ```
/// let validator = try IRLLicence(email: "notanemail@notanemail.com", licence: licenceString,
/// publicKey: publicKey2048Base64)
/// let isValid = await validator.validate()
/// print("🔄 Is Valid: " + isValid ? "✅ YES" : "⛔️ NO")
/// print("✅ Expire on: \(validator.expire)")
/// ```
///
@available(macOS 10.13, iOS 11, tvOS 11, watchOS 4, *)
@available(swift 5.0)
public struct IRLLicence {
    // MARK: Initialisation
    
#if !os(Linux)
    /// ⚠️ (Apple Platform ONLY) - Initiate the process of validation the licence based on `Bundle.main.associatedIDentifier`.
    ///
    /// - Parameters:
    ///   - email: The associated email address for the licence
    ///   - licence: The Licence key
    ///   - publicKey: The public key to validate the Licence
    public init(email: String, licence: String, publicKey: String) throws {
        let bundle = Bundle.main.bundleIdentifier ?? ""
        guard !bundle.isEmpty else {
            print("⛔️ Failed to run `init(email:licence:publicKey)`. You should only use this on Apple plateform")
            throw LicenceErrors.invalidExecutable
        }
        try self.init(email: email, hostname: bundle, licence: licence, publicKey: publicKey)
    }
#else
    @available(*, unavailable, message: "This function is not available on this platform.")
    public init(email: String, licence: String, publicKey: String) throws {
        fatalError("This function is not available on this platform.")
    }
#endif
    
    /// Initiate the process of validation a licence based on a Domain.
    ///
    /// - Warning: On Linux, only 1024 bit & 2048 bit Public Keys are supported.
    /// 
    /// - Parameters:
    ///   - email: The associated email address for the licence
    ///   - hostname: The associated hostname address for the licence
    ///   - licence: The Licence key
    ///   - publicKey: The public key to validate the Licence
    public init(email: String, hostname: String, licence: String, publicKey: String) throws {
#if !os(Linux)
        // Let's validate we can decode the key (macOS)
        _ = try Self.getPublicKey(key: publicKey)
#else
        guard publicKey.count == 272 || publicKey.count == 451 else {
            throw LicenceErrors.invalidPublicKey
        }
#endif
        let validEmail = email.normalizedEmail
        guard ValidationRule.email.isValid(text: validEmail) else {
            throw LicenceErrors.invalidEmail
        }
        guard let data = licence.base64Decoded() else {
            throw LicenceErrors.invalidLicenceKey(key: licence)
        }
        self.licence = licence
        self.publicKey = publicKey
        self.associatedID = hostname
        self.providedEmail = validEmail
        self.licenceEmailHash = validEmail.sha512()
        
        // Parse the Licence details
        let base64 = data.components(separatedBy: "<>")
        guard base64.count == 3,
              let userSignature = base64.first,
              let valid = base64.last,
              let validity = Int(valid) else {
            throw LicenceErrors.invalidLicenceKey(key: licence)
        }
        self.userSignature = userSignature
        self.licenceassociatedID = base64[1]
        self.validity = validity
        guard self.licenceassociatedID == self.associatedID else {
            throw LicenceErrors.invalidLicenceAssociatedID(current: self.associatedID, expected: self.licenceassociatedID)
        }
    }
    
    // MARK: Public Variables
    
    /// The Running `App Bundle ID`, a `Domain` or any other means to lock the licence to a specific App.
    public let associatedID: String
    
    /// The  provided email which which should be assoicated with this licence
    public var providedEmail: String
    
    /// The `associatedID` coded within this licence
    public let licenceassociatedID: String
    
    /// The Licence key
    public let licence: String

    // MARK: Private Variables

    /// Internal Queue for validation
    static internal let validationQueue = DispatchQueue(label: "com.irlmobile.validation")
    
    /// The Validity Expiration date for this licence
    internal let validity: Int
    
    /// The signature, Public key & associated SHA512 email address for the licence
    internal let userSignature, publicKey, licenceEmailHash: String
}

