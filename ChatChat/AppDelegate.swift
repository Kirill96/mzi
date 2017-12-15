/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        
//        let text1 = ClassicDes.sharedInstance.encryption(text: "Hello", key: "qwertyu")
//        print("text1: \(text1)")
//        let text2 = ClassicDes.sharedInstance.encryption(text: text1, key: "qwertyu")
//        print("text2: \(text2)")
//        let text3 = ClassicDes.sharedInstance.encryption(text: text2, key: "qwertyu")
//        print("text3: \(text3)")
//
//
//        let dec1 = ClassicDes.sharedInstance.decryption(text: text3, key: "qwertyu")
//        print("dec1: \(dec1)")
//        let dec2 = ClassicDes.sharedInstance.decryption(text: dec1, key: "qwertyu")
//        print("dec2: \(dec2)")
//        let dec3 = ClassicDes.sharedInstance.decryption(text: dec2, key: "qwertyu")
//        print("dec3: \(dec3)")

//        let text1 = ClassicDes.sharedInstance.encryption(text: "Hello", key: "qwertyu")
//        print("text1: \(text1)")
//        let text2 = ClassicDes.sharedInstance.encryption(text: text1, key: "1234567")
//        print("text2: \(text2)")
//        let text3 = ClassicDes.sharedInstance.encryption(text: text2, key: "qwertyu")
//        print("text3: \(text3)")
//
//
//        let dec1 = ClassicDes.sharedInstance.decryption(text: text3, key: "qwertyu")
//        print("dec1: \(dec1)")
//        let dec2 = ClassicDes.sharedInstance.decryption(text: dec1, key: "1234567")
//        print("dec2: \(dec2)")
//        let dec3 = ClassicDes.sharedInstance.decryption(text: dec2, key: "qwertyu")
//        print("dec3: \(dec3)")

        return true
    }
}

