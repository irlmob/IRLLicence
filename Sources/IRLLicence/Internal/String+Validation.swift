//
//  String+Validation.swift
//
//  [IRLLicence](https://github.com/irlmob/IRLLicence)
//  Created by Denis Martin-Bruillot on 03/03/2023.
//
//  Copyright (c) 2023 Denis Martin-Bruillot.
//  All rights reserved. This code is licensed under the MIT License, which can be found in the LICENSE file.
//

import Foundation

/// A set of utilities for string validation and manipulation.
internal extension String {
    /// A representation of the string with all spaces removed.
    var removeSpace: String {
        var updated = self
        while (updated as NSString).range(of: " ").location != NSNotFound {
            updated = updated.replacingOccurrences(of: " ", with: "")
        }
        return updated
    }
    
    /// A normalized representation of the string as an email address.
    var normalizedEmail: String {
        self.removeSpace
    }
}

/// A set of validation rules for string values.
internal enum ValidationRule: String {
    /// A regular expression that defines the valid format for an email address.
    case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    /// Checks if the given string value is valid according to the receiver rule.
    ///
    /// - Parameter text: The string value to validate.
    /// - Returns: A Boolean value indicating whether the string value is valid.
    func isValid(text: String) -> Bool {
        if self == .email {
            return isValid(email: text)
        }
        guard let regex = try? NSRegularExpression(pattern: rawValue) else {
            return false
        }
        return regex.matches(text)
    }
    
    /// Checks if the given string value is a valid email address.
    ///
    /// - Parameter email: The string value to validate as an email address.
    /// - Returns: A Boolean value indicating whether the string value is a valid email address.
    private func isValid(email: String) -> Bool {
        guard let emailRegex = try? NSRegularExpression(pattern: rawValue), !email.containEmoji else {
            return false
        }
        return emailRegex.matches(email)
    }
}

/// A set of utility extensions for regular expressions.
internal extension NSRegularExpression {
    /// Initializes a regular expression with the specified pattern.
    ///
    /// This initializer ensures that the pattern is valid, and if not, raises a precondition failure.
    ///
    /// - Parameter pattern: The pattern to use for the regular expression.
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
    
    /// Matches the regular expression against the given string.
    ///
    /// - Parameter string: The string to match against the regular expression.
    /// - Returns: A Boolean value indicating whether the string matches the regular expression.
    func matches(_ string: String) -> Bool {
        let range = NSRange(string.startIndex..., in: string)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}

/// A set of utility extensions for string values that contain emoji.
internal extension String {
    /// A Boolean value indicating whether the string contains an emoji character.
    var containEmoji: Bool {
        for ucode in unicodeScalars {
            switch ucode.value {
            case 0x3030, 0x00AE, 0x00A9,
                0x1D000...0x1F77F,
                0x2100...0x27BF,
                0xFE00...0xFE0F,
                0x1F900...0x1F9FF:
                return true
            default:
                continue
            }
        }
        return false
    }
}
