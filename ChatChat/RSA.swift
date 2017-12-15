//
//  RSA.swift
//  ChatChat
//
//  Created by Kirill on 10.11.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import SwiftyRSA

class RSAEncoding {

    let publicKey = "qwerty"
    let privateKey = "123456"

    func rsaEncoding(text: String) -> String {

        let publicKey = try! PublicKey(pemNamed: self.publicKey)
        let clear = try! ClearMessage(string: text, using: .utf8)
        let encrypted = try! clear.encrypted(with: publicKey, padding: .PKCS1)

        _ = encrypted.data
        let base64String = encrypted.base64String

        return base64String
    }

    func rsaDecoding(text: String) -> String {

        let privateKey = try! PrivateKey(pemNamed: self.privateKey)
        let encrypted = try! EncryptedMessage(base64Encoded: text)
        let clear = try! encrypted.decrypted(with: privateKey, padding: .PKCS1)

        // Then you can use:
        _ = clear.data
        _ = clear.base64String
        let string = try! clear.string(encoding: .utf8)

        return string
    }

}
