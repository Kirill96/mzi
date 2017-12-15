//
//  UserDefaultsManager.swift
//  ChatChat
//
//  Created by Kirill on 08.11.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit

struct UserDefaultsService {

    enum Data: String {
        case encryption = "encryption"
    }

    func save(value: String, data: Data) {
        UserDefaults.standard.set(value, forKey: data.rawValue)
        UserDefaults.standard.synchronize()
    }

    func get(data: Data) -> String {
        return UserDefaults.standard.string(forKey: data.rawValue) ?? ""
    }
}

