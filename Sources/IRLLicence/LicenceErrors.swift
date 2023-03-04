//
//  LicenceErrors.swift
//
//  [IRLLicence](https://github.com/irlmob/IRLLicence)
//  Created by Denis Martin-Bruillot on 03/03/2023.
//
//  Copyright (c) 2023 Denis Martin-Bruillot.
//  All rights reserved. This code is licensed under the MIT License, which can be found in the LICENSE file.
//

import Foundation

private let errorComment = "Usage error"

/// `LicenceErrors`
///
/// Those are the different errors you may face while validating your licence.
///
/// - warning: ⚠️ You are responsible for maintaing this licence, not your users.
///
@available(macOS 10.13, iOS 11, tvOS 11, watchOS 4, *)
@available(swift 5.0)
public enum LicenceErrors: Error {
    /// Invalid Licence email address provided
    case invalidEmail
    /// The provided Licence Key is invalid
    case invalidLicenceKey(key: String)
    /// Something is wrong with the Validator. Public Key is invalid!
    case invalidPublicKey
    /// Invalid Licence `Bundle ID`
    case invalidLicenceAssociatedID(current: String, expected: String)
    /// Invalid Executable, the `Bundle ID` cannot be retrieve.
    case invalidExecutable
}

// MARK: Human Readbale Errors
@available(macOS 10.13, iOS 11, tvOS 11, watchOS 4, *)
@available(swift 5.0)
extension LicenceErrors: LocalizedError {
    /// Localized Error description. `Bundle.main`. You can translate the errors in your app .
    public var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return NSLocalizedString("Invalid Licence email address provided.",
                                     bundle: Bundle.main, comment: errorComment)
        case .invalidLicenceKey(let key):
            let format = NSLocalizedString("""
                                           ⚠️ The provided Licence Key is invalid
                                           %@
                                           """,
                                           bundle: Bundle.main, comment: errorComment
            )
            return String(format: format, key)
            
        case .invalidPublicKey:
            return NSLocalizedString("⛔️ Something is wrong with the Validator. Public Key is invalid!",
                                     comment: errorComment)
                                     
                   
        case .invalidLicenceAssociatedID(let current, let expected):
            let format = NSLocalizedString("""
                                           ⛔️ The provided Licence Key is associated with the App Bundle ID: %@, but the running App use this bundle ID: %@
                                           """,
                                           bundle: Bundle.main, comment: errorComment
            )
            return String(format: format, expected, current)
            
        case .invalidExecutable:
            return NSLocalizedString("⛔️ Invalid Executable, the `Bundle ID` cannot be retrieve.",
                                     bundle: Bundle.main, comment: errorComment)
        }
        
            
    }
}
