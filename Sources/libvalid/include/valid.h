//
//  valid.h
//
//  [IRLLicence](https://github.com/irlmob/IRLLicence)
//  Created by Denis Martin-Bruillot on 03/03/2023.
//
//  Copyright (c) 2023 Denis Martin-Bruillot.
//  All rights reserved. This code is licensed under the MIT License, which can be found in the LICENSE file.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <openssl/evp.h>
#include <openssl/pem.h>
#include <openssl/err.h>
#include <openssl/buffer.h>

int verify(const char* data, const char* base64_signature, const char* public_key_str);
