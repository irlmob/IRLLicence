//
//  valid.c
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

// Definition in the C source file
int verifySTR(const char* data, const char* signature, const char* public_key_str) {
    // Create a public key object from the public key string
    BIO* bio = BIO_new_mem_buf((void*)public_key_str, -1);
    if (!bio) {
        return -1;
    }
    EVP_PKEY* public_key = PEM_read_bio_PUBKEY(bio, NULL, NULL, NULL);
    if (!public_key) {
        BIO_free(bio);
        return -1;
    }
    BIO_free(bio);

    // Create a message digest context using SHA-512
    EVP_MD_CTX* md_ctx = EVP_MD_CTX_new();
    if (!md_ctx) {
        EVP_PKEY_free(public_key);
        return -1;
    }
    if (!EVP_DigestInit_ex(md_ctx, EVP_sha512(), NULL)) {
        EVP_MD_CTX_free(md_ctx);
        EVP_PKEY_free(public_key);
        return -1;
    }
    
    // Update the message digest with the data to be verified
    if (!EVP_DigestUpdate(md_ctx, data, strlen(data))) {
        EVP_MD_CTX_free(md_ctx);
        EVP_PKEY_free(public_key);
        return -1;
    }

    // Verify the signature using the public key
    int result = EVP_VerifyFinal(md_ctx, (const unsigned char*)signature, strlen(signature), public_key);
    if (result != 1) {
        EVP_MD_CTX_free(md_ctx);
        EVP_PKEY_free(public_key);
        return -1;
    }
    
    EVP_MD_CTX_free(md_ctx);
    EVP_PKEY_free(public_key);
    return 0;
}

// Base64 Decode
unsigned char* base64_decode(const char* encoded_string, size_t* output_length) {
    BIO* b64 = BIO_new(BIO_f_base64());
    BIO* bmem = BIO_new_mem_buf(encoded_string, -1);
    BIO_push(b64, bmem);

    unsigned char* output_buffer = (unsigned char*)malloc(strlen(encoded_string));
    *output_length = BIO_read(b64, output_buffer, strlen(encoded_string));

    BIO_free_all(b64);

    return output_buffer;
}

// Format the Base64 String and return a new string
char* format_base64_string(const char* str) {
    int len = strlen(str);
    int num_lines = (len + 63) / 64;
    int new_len = len + num_lines - 1;
    char* new_str = (char*) malloc(new_len + 1);
    int j = 0;
    for (int i = 0; i < len; i++) {
        if (i > 0 && i % 64 == 0) {
            new_str[j] = '\n';
            j++;
        }
        new_str[j] = str[i];
        j++;
    }
    new_str[j] = '\0';  // set the null terminator at the end of the string
    return new_str;
}

// Definition in the C source file
int verifyBase64(const char* data, const char* base64_signature, const char* public_key_str) {
    size_t decoded_len;
    char* formatted_base64_string = format_base64_string(base64_signature);
    unsigned char* decoded_data = base64_decode(formatted_base64_string, &decoded_len);

    if (!decoded_data) {
        free(formatted_base64_string);
        return -1;
    }

    int verify = verifySTR(data, (const char*) decoded_data, public_key_str);

    free(decoded_data);
    free(formatted_base64_string);
    return verify;
}

// Verify 1024 Keys base signature
int verifyBase64_1024(const char* data, const char* base64_signature, const char* public_key_str) {
    // Add 1 = to the base64_signature string
    char* modified_base64_signature = (char*)malloc(strlen(base64_signature) + 2);
    strcpy(modified_base64_signature, base64_signature);
    strcat(modified_base64_signature, "=");
    int result = verifyBase64(data, modified_base64_signature, public_key_str);
    free(modified_base64_signature);
    return result;
}

// Verify 2048 Keys base signature
int verifyBase64_2048(const char* data, const char* base64_signature, const char* public_key_str) {
    // Add 2 = to the base64_signature string
    char* modified_base64_signature = (char*)malloc(strlen(base64_signature) + 3);
    strcpy(modified_base64_signature, base64_signature);
    strcat(modified_base64_signature, "==");
    int result = verifyBase64(data, modified_base64_signature, public_key_str);
    free(modified_base64_signature);
    return result;
}

int verify(const char* data, const char* base64_signature, const char* public_key_str) {
    int keyLength = strlen(public_key_str);
     switch (keyLength) {
        case 272: // 1024
            return verifyBase64_1024(data, base64_signature, public_key_str);
            break;
        case 451: // 2048
            return verifyBase64_2048(data, base64_signature, public_key_str);
            break;
        default:
            break;
    }
    return -1;
}
