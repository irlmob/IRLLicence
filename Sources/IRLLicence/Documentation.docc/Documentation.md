# ``IRLLicence``

🔐 A helper tool to validate `Licence Code provided to clients`.

## Overview

💰 If you're looking for a reliable and secure way to license your work, look no further than IRLLicence. Try it out today and ensure that your application or framework is fully licensed and secure!

## About

Welcome to ``IRLLicence/IRLLicence`` – a powerful code validation mechanism that ensures your binary is running where and how it is supposed to. 

#### 📦 How it works

- Integrate this library into your code
- Lock the functionalities or initialization of your code
- Verify your client's license data / email
- The library will also ensure the App Bundle ID and email validated from the license are running inside the correct App Bundle ID.

Using ``IRLLicence``, you can easily prevent your code from being used by unauthorized parties. 

The tool is built using Swift and supports Swift 5.4 and newer (swift-tools-version:5.7), making it easy to incorporate into your existing projects.

#### 💁‍♂️ What happens as a client

Please note that as a client, you will need to use a license that is associated with the correct App Bundle ID. 

The license is set to expire too. You must renew the license and publish your app at this stage.

The license is completely locked to you as a client and your email address. It is only valid for use with the App Bundle ID specified at the time of registration and until it expires.

## Getting Started

Getting started with IRLLicence is easy. Simply add the code to your project, distribute your Framework or Application as a closed source, and lock your code to be usable only with a valid license and email. Once your client verifies the license, your code will be able to run with confidence, knowing that it is fully licensed and secure.

IRLLicence primarily uses [SwiftPM](https://swift.org/package-manager/) as its build tool, so we recommend using that as well. If you want to depend on IRLLicence in your own project, it's as simple as adding a `dependencies` clause to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/irlmob/IRLLicence.git", from: "0.0.4")
]
```

#### Swift 5.4 and newer (swift-tools-version:5.7)
```swift
    dependencies: [.product(name: "IRLLicence", package: "IRLLicence") ]
```

### Using Xcode Package support

If your project is set up as an Xcode project and you're using Xcode 11+, you can add IRLLicence as a dependency to your
Xcode project by clicking File -> Swift Packages -> Add Package Dependency. In the upcoming dialog, please enter
`https://github.com/irlmob/IRLLicence.git` and click Next twice. Finally, select the targets you are planning to use (here `IRLLicence`) and click finish. Now will be able to `import IRLLicence` (as well as all
the other targets you have selected) in your project.

To work on IRLLicence itself, or to investigate some of the demonstration applications, you can check the Tests.

## Usage example - Simple validation

```swift
let licence = "bVJkaVZEUXpVY<...>zQ5Mw=="
let validator = try IRLLicence(email: "notanemail@notanemail.com", licence: licence,
publicKey: publicKey2048Base64)
let isValid = await validator.validate()
print("🔄 Is Valid: " + isValid ? "✅ YES" : "⛔️ NO")
print("✅ Expire on: \(validator.expire)")
```

## MIT License
Copyright (c) 2023 iRLMobile
See LICENCE.md for details
