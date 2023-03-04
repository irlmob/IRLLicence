//
//  IRLLicenceValidation.swift
//
//  [IRLLicence](https://github.com/irlmob/IRLLicence)
//  Created by Denis Martin-Bruillot on 03/03/2023.
//
//  Copyright (c) 2023 Denis Martin-Bruillot.
//  All rights reserved. This code is licensed under the MIT License, which can be found in the LICENSE file.
//

import Foundation

/// Provides functionality for validating and managing a software licence.
///
/// We will generally use this class with a Domain validation in a Vapor app for example.
///
/// - Warning: ⚠️ You must call ``licence(publicKey:email:associatedID:licence:)`` as early as possible in your code.
///
/// Here is an example of ow you would prepare this Singleton
/// ```
/// let publicKey = "-----BEGIN PUBLIC KEY-----\nMII...."
/// try await IRLLicenceValidation.licence(publicKey: publicKey, email: "hello@example.com", associatedID: "company.com", licence: "ABCD-EFGH-IJKL-MNOP")
/// ```
///
/// In your code you will then simply call:
/// ``IRLLicenceValidation/validation``
///  Inspected the tuple containing a `Bool`  indicating whether the software licence is authorized, and a `String` that describes why is not authorized or an empty string if authorzed
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
@available(swift 5.0)
public final class IRLLicenceValidation {
    /// Sets the licence information for the current instance of the App.
    ///
    /// - Parameters:
    ///   - publicKey: The public key for the licence.
    ///   - email: The email address associated with the licence.
    ///   - associatedID: The ID associated with the licence.
    ///   - licence: The licence code.
    public static func licence(publicKey: String,
                               email: String,
                               associatedID: String,
                               licence: String) async throws {
        guard !didSetValue else { return }
        Self.publicKey = publicKey
        shared.email = email
        shared.licence = licence
        shared.associatedID = associatedID
        didSetValue = true
#if os(Linux)
        let decoder = try IRLLicence(email: email, hostname: associatedID, licence: licence, publicKey: Self.publicKey)
        Self.licenceIsValid = await decoder.validate()
        Self.licenceAssociatedID = decoder.licenceassociatedID
        Self.licencExpire = decoder.expire
        Self.licenceEmail = decoder.providedEmail
#else
        let decoder = try IRLLicence(email: email, hostname: "127.0.0.1:8080", licence: licence, publicKey: Self.publicKey)
        Self.licenceIsValid = await decoder.validate()
        Self.licenceAssociatedID = "127.0.0.1:8080"
        Self.licencExpire = decoder.expire
        Self.licenceEmail = decoder.providedEmail
#endif
        
        print("✅ Your licence is associated with: \(Self.licenceAssociatedID)")
        print("📨 It has been registred by: \(email)")
        print("📅 This licence will expire: \(Self.licencExpire.formattedDate())")
        print("")
    }
    
    /// The licence associated with the instance of the object.
    public private(set) var licence: String = ""
    
    /// The email address associated with the licence.
    public private(set) var email: String = ""
    
    /// The ID associated with the licence.
    public private(set) var associatedID: String = ""
    
    /// The email address associated with the licence.
    public private(set) static var licenceEmail = ""
    
    /// The ID associated with the licence.
    public private(set) static var licenceAssociatedID = ""
    
    /// Indicates whether the software licence is currently valid.
    public private(set) static var licenceIsValid = false
    
    /// The expiration date for the software licence.
    public private(set) static var licencExpire = Date()
    
    /// A computed property that returns a tuple containing:
    ///  - a boolean value indicating whether the software licence is authorized
    ///  - a string that describing the reason why it is not authorized or an empty string if authorzed.
    public static var validation: (authorized: Bool, reason: String) {
        guard !IRLLicenceValidation.licenceEmail.isEmpty else {
            return (false, "Error. AppLicence has not been setup")
        }
        guard IRLLicenceValidation.licenceIsValid else {
            return (false, "Unauthorized. This Software licence is invalid")
        }
        guard Date() < IRLLicenceValidation.licencExpire else {
            return (false, "Unauthorized. This Software licence has expired on: \(IRLLicenceValidation.licencExpire.formattedDate())")
        }
        return (true, "")
    }

    /**
     A singleton class that represents an IRLLicenceValidation object for license validation.
     */
    private static let shared = IRLLicenceValidation()
    
    /// A flag to indicate whether the `didSetValue` property has been set or not.
    private static var didSetValue = false
    
    /// The public key to use for license validation.
    private static var publicKey: String = ""
}

/**
 An extension of the `Date` class with a function to format dates.
 */
internal extension Date {
    /// A date formatter for formatting dates.
    static var dateformatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    /**
     Formats a date using the date formatter.
     
     - Returns: A formatted string representation of the date.
     */
    func formattedDate() -> String {
        Self.dateformatter.string(from: self)
    }
}
