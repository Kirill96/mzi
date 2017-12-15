//
//  DigitalSignature.swift
//  ChatChat
//
//  Created by Kirill on 10.11.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit


class DigitalSignature {

    func createDigitalSignature(data: Data) -> String {
        var str = ""

        let temp = MD5().md5()

        str = ClassicDes().encryption(text: temp)

        return str
    }

    func getDigitalSignature(signature: String) -> Data {
        let dat = Data()

        let temp = MD5().md5()

        let str = ClassicDes().decryption(text: signature)

        return dat
    }


}
