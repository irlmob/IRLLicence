// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Created by Denis Martin-Bruillot on 03/03/2023.
//
//  Copyright (c) 2023 Denis Martin-Bruillot.
//  All rights reserved. This code is licensed under the MIT License, which can be found in the LICENSE file.
//

import PackageDescription

// MARK: Name
let name: String = "IRLLicence"
// MARK: Plateforms
let platforms: [SupportedPlatform] = [
    .macOS(.v10_13), .iOS(.v11), .tvOS(.v11), .watchOS(.v4)
]

// MARK: Products
var products = [Product]()
var dependencies = [Package.Dependency]()
var targets = [Target]()

// MARK: Linux Support

products.append(contentsOf: [
    .library( name: "IRLLicence", targets: ["IRLLicence"])
])


dependencies.append(contentsOf: [
    .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.0")
])

// MARK: Libraries
#if os(Linux)
products.append(contentsOf: [
    .library(name: "libvalid", targets: ["libvalid"])
])

targets.append(contentsOf: [
    .target(
        name: "libvalid",
        dependencies: [ ],
        path: "Sources/libvalid",
        publicHeadersPath: "include",
        cSettings: [
            .define("MY_LIBRARY_VERSION", to: "1.0.0"), // Add any compiler flags or preprocessor macros here
        ],
        cxxSettings: [],
        linkerSettings: [
            .unsafeFlags(["-L/usr/local/lib", "-L/etc/lib"]), // Add any additional linker flags here
            .unsafeFlags(["-lcrypto", "-lssl"  ]) // Add any additional linker flags here
        ])
])

let swiftSetting: [SwiftSetting] = [
    .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "/usr/local/lib"]) // Add the LD_LIBRARY_PATH value here
]
let linkerSettings: [LinkerSetting] = [
    .unsafeFlags(["-L/usr/local/lib"]) // Add any additional linker flags here
]
targets.append(contentsOf: [
    .target(name: "IRLLicence", dependencies: [ "libvalid", "CryptoSwift" ],
            swiftSettings: swiftSetting, linkerSettings: linkerSettings)
])

#else
targets.append(contentsOf: [
    .target(name: "IRLLicence", dependencies: [ "CryptoSwift" ])
])

#endif

targets.append(
    .testTarget( name: "IRLLicenceTests", dependencies: [ "IRLLicence" ],
                 path: "./Tests/IRLLicenceTests"
               )
)

// MARK: Package Definition
let package = Package(
    name: name, defaultLocalization: "en", platforms: platforms, products: products, dependencies: dependencies, targets: targets
)
