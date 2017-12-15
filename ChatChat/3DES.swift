//
//  3DES.swift
//  ChatChat
//
//  Created by Kirill on 07.11.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

class TripleDes {

    func encryption(text: String) -> String {
        var string = text

        for _ in 0..<3 {
            string = ClassicDes().encryption(text: string)
        }

        return string
    }

    func decryption(text: String) -> String {
        var string = text

        for _ in 0..<3 {
            string = ClassicDes().decryption(text: string)
        }

        return string
    }

}
