//
//  3DESDoubleKey.swift
//  ChatChat
//
//  Created by Kirill on 07.11.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

class TripleDesDoubleKey {

    private let key1And3 = "qwertyu"
    private let key2 = "1234567"

    func encryption(text: String) -> String {
        var string = text

        string = ClassicDes().cipher(text: string, key: self.key1And3, cipher: .Encrypt)
        string = ClassicDes().cipher(text: string, key: self.key2, cipher: .Encrypt)
        string = ClassicDes().cipher(text: string, key: self.key1And3, cipher: .Encrypt)

        return string
    }

    func decryption(text: String) -> String {
        var string = text

        string = ClassicDes().cipher(text: string, key: self.key1And3, cipher: .Decrypt)
        string = ClassicDes().cipher(text: string, key: self.key2, cipher: .Decrypt)
        string = ClassicDes().cipher(text: string, key: self.key1And3, cipher: .Decrypt)

        return string
    }

}
