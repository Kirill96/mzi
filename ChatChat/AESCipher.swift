//
//  AESCipher.swift
//  ChatChat
//
//  Created by Kirill on 07.11.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//
import CryptoSwift
import UIKit

class AESCipher {

    let key_encrypt = "bbC2H19lkVbQDfakxcrtNMQdd0FloLyw"
    let iv = "gqLOHUioQ0QjhuvI"

    func encrypt(text: String) -> String? {

        let arraySlice = Array(text.utf8)
        let enc = try! AES(key: key_encrypt, iv: iv, padding: .pkcs7).encrypt(arraySlice)
        let encData = Data(bytes: enc, count: Int(enc.count))
        let base64String: String = encData.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
        let result = String(base64String)

        return result
    }

    func decrypt(text: String) -> String? {
        let data = Data(base64Encoded: text)!

        let dec = try! AES(key: key_encrypt, iv: iv, padding: .pkcs7).decrypt([UInt8](data))
        let decData = Data(bytes: dec, count: Int(dec.count))
        let result = NSString(data: decData, encoding: String.Encoding.utf8.rawValue)

        return String(result!)
    }

}
