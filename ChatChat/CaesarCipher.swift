//
//  CaesarCipher.swift
//  ChatChat
//
//  Created by Kirill on 05.11.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation

class MD5 {
    func md5() -> String {
        return ""
    }
}

class CaesarCipher {

    let key = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let n = 5

    func ecnrypt(text: String) -> String {
        var result = ""

        for letter in text {

            if let indexLast = self.key.index(of: letter) {
                let distanse = self.key.distance(from: self.key.startIndex, to: indexLast)
                let newLetterIndex = (distanse + n) % 52

                let index = self.key.index(self.key.startIndex, offsetBy: newLetterIndex)

                result.append(self.key[index])

            } else {
                result.append(letter)
            }

        }

        return result
    }

    func decrypt(text: String) -> String {
        var result = ""

        for letter in text {
            if let indexLast = self.key.index(of: letter) {
                let distanse = self.key.distance(from: self.key.startIndex, to: indexLast)
                let newLetterIndex = (distanse - n) % 52

                if newLetterIndex < 0 {
                    let index = self.key.index(self.key.endIndex, offsetBy: newLetterIndex)
                    result.append(self.key[index])
                } else {
                    let index = self.key.index(self.key.startIndex, offsetBy: newLetterIndex)
                    result.append(self.key[index])
                }

            } else {
                result.append(letter)
            }

        }

        return result
    }
}

