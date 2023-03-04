//
//  String+base64.swift
//
//  [IRLLicence](https://github.com/irlmob/IRLLicence)
//  Created by Denis Martin-Bruillot on 03/03/2023.
//
//  Copyright (c) 2023 Denis Martin-Bruillot.
//  All rights reserved. This code is licensed under the MIT License, which can be found in the LICENSE file.
//

import Foundation

// Extension to the String type
internal extension String {
    // Function that returns a base64-encoded string representation of the string
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    // Function that returns a decoded string representation of the base64-encoded string
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
