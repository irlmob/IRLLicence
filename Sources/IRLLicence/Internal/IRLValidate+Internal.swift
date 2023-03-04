//
//  IRLValidate+Internal.swift
//
//  [IRLLicence](https://github.com/irlmob/IRLLicence)
//  Created by Denis Martin-Bruillot on 03/03/2023.
//
//  Copyright (c) 2023 Denis Martin-Bruillot.
//  All rights reserved. This code is licensed under the MIT License, which can be found in the LICENSE file.
//

import Foundation
import CryptoSwift

internal extension IRLLicence {
#if !os(Linux)
    static func getPublicKey(key: String) throws -> SecKey {
        let key = key
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----\n", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----\n", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        guard let data = Data(base64Encoded: key) else {
            throw LicenceErrors.invalidPublicKey
        }

        let attributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic
        ]

        var error: Unmanaged<CFError>?
        guard let publicKey = SecKeyCreateWithData(
            data as CFData,
            attributes as CFDictionary,
            &error
        ) else {
            throw error!.takeRetainedValue() as Error
        }

        return publicKey
    }
#endif
    var digest: String? {
        licenceValue.sha512()
    }
    
    var licenceValue: String {
        licenceEmailHash + "," + associatedID + "," + "\(validity)"
    }
}
