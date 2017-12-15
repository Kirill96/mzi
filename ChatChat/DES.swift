//
//  DES.swift
//  ChatChat
//
//  Created by Kirill on 07.11.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation

class ClassicDes {

    private let key = "qwertyu"

    private let func_E = [32,1,2,3,4,5,
                          4,5,6,7,8,9,
                          8,9,10,11,12,13,
                          12,13,14,15,16,17,
                          16,17,18,19,20,21,
                          20,21,22,23,24,25,
                          24,25,26,27,28,29,
                          28,29,30,31,32,1]

    private let p_transformation = [16,7,20,21,29,12,28,17,
                                    1,15,23,26,5,18,31,10,
                                    2,8,24,14,32,27,3,9,
                                    19,13,30,6,22,11,4,25]

    private let s_transformation = [
        [[14,4,13,1,2,15,11,8,3,10,6,12,5,9,0,7],
         [0,15,7,4,14,2,13,1,10,6,12,11,9,5,3,8],
         [4,1,14,8,13,6,2,11,15,12,9,7,3,10,5,0],
         [15,12,8,2,4,9,1,7,5,11,3,14,10,0,6,13]],

        [[15,1,8,14,6,11,3,4,9,7,2,13,12,0,5,10],
         [3,13,4,7,15,2,8,14,12,0,1,10,6,9,11,5],
         [0,14,7,11,10,4,13,1,5,8,12,6,9,3,2,15],
         [13,8,10,1,3,15,4,2,11,6,7,12,0,5,14,9]],

        [[10,0,9,14,6,3,15,5,1,13,12,7,11,4,2,8],
         [13,7,0,9,3,4,6,10,2,8,5,14,12,11,15,1],
         [13,6,4,9,8,15,3,0,11,1,2,12,5,10,14,7],
         [1,10,13,0,6,9,8,7,4,15,14,3,11,5,2,12]],

        [[7,13,14,3,0,6,9,10,1,2,8,5,11,12,4,15],
         [13,8,11,5,6,15,0,3,4,7,2,12,1,10,14,9],
         [10,6,9,0,12,11,7,13,15,1,3,14,5,2,8,4],
         [3,15,0,6,10,1,13,8,9,4,5,11,12,7,2,14]],

        [[2,12,4,1,7,10,11,6,8,5,3,15,13,0,14,9],
         [14,11,2,12,4,7,13,1,5,0,15,10,3,9,8,6],
         [4,2,1,11,10,13,7,8,15,9,12,5,6,3,0,14],
         [11,8,12,7,1,14,2,13,6,15,0,9,10,4,5,3]],

        [[12,1,10,15,9,2,6,8,0,13,3,4,14,7,5,11],
         [10,15,4,2,7,12,9,5,6,1,13,14,0,11,3,8],
         [9,14,15,5,2,8,12,3,7,0,4,10,1,13,11,6],
         [4,3,2,12,9,5,15,10,11,14,1,7,6,0,8,13]],

        [[4,11,2,14,15,0,8,13,3,12,9,7,5,10,6,1],
         [13,0,11,7,4,9,1,10,14,3,5,12,2,15,8,6],
         [1,4,11,13,12,3,7,14,10,15,6,8,0,5,9,2],
         [6,11,13,8,1,4,10,7,9,5,0,15,14,2,3,12]],

        [[13,2,8,4,6,15,11,1,10,9,3,14,5,0,12,7],
         [1,15,13,8,10,3,7,4,12,5,6,11,0,14,9,2],
         [7,11,4,1,9,12,14,2,0,6,10,13,15,3,5,8],
         [2,1,14,7,4,10,8,13,15,12,9,0,3,5,6,11]]]

    private let c0 = [57,49,41,33,25,17,9,1,58,50,42,34,26,18,
                      10,2,59,51,43,35,27,19,11,3,60,52,44,36]

    private let d0 = [63,55,47,39,31,23,15,7,62,54,46,38,30,22,
                      14,6,61,53,45,37,29,21,13,5,28,20,12,4]

    private let finish_permutation = [14,17,11,24,1,5,3,28,15,6,21,10,23,19,12,4,
                                      26,8,16,7,27,20,13,2,41,52,31,37,47,55,30,40,
                                      51,45,33,48,44,49,39,56,34,53,46,42,50,36,29,32]

    private let number_of_shifts = [1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1]

    private let ip_initial_permutation = [58, 50, 42, 34, 26, 18, 10, 2, 60, 52, 44, 36, 28, 20, 12, 4,
                                          62, 54, 46, 38, 30, 22, 14, 6, 64, 56, 48, 40, 32, 24, 16, 8,
                                          57, 49, 41, 33, 25, 17,  9, 1, 59, 51, 43, 35, 27, 19, 11, 3,
                                          61, 53, 45, 37, 29, 21, 13, 5, 63, 55, 47, 39, 31, 23, 15, 7]

    private let ip_1 = [40,8,48,16,56,24,64,32,39,7,47,15,55,23,63,31,
                        38,6,46,14,54,22,62,30,37,5,45,13,53,21,61,29,
                        36,4,44,12,52,20,60,28,35,3,43,11,51,19,59,27,
                        34,2,42,10,50,18,58,26,33,1,41,9,49,17,57,25]


    enum CipherMethod {
        case Encrypt, Decrypt
    }


    private func transformation<T>(start: Int, end: Int, array: inout [T], binText: [T]) {
        for item in start..<end {
            array.append(binText[item])
        }
    }


    private func getResult<T>(array: [T], resultArray: inout [T]) {
        for elem in array {
            resultArray.append(elem)
        }
    }


    private func remove<T>(from start: Int, to end: Int, in array: inout [T]) {
        for _ in start..<end {
            array.remove(at: 0)
        }
    }


    private func textIntoABinaryView(text: String) -> [Int] {
        var binText = [Int]()
        for char in text.characters {
            let unicodeChar = String(char).unicodeScalars
            let decimal = Int(unicodeChar[unicodeChar.startIndex].value)
            var binary = String(decimal, radix: 2)
            var lenBinary = binary.lengthOfBytes(using: String.Encoding.utf8)
            while lenBinary != 8 {
                binary = "0" + binary
                lenBinary += 1
            }
            for ch in binary.characters {
                binText.append(Int(String(ch))!)
            }
        }
        return binText
    }


    private func binaryViewIntoAText(binText: [Int]) -> String {
        var charArray = [String]()
        var currentBinText = binText
        while currentBinText.count > 0 {
            var binNumber = ""
            for item in 0..<8 {
                binNumber += String(currentBinText[item])
            }
            let intBinNumber = Int(binNumber, radix: 2)!
            charArray.append(String(UnicodeScalar(UInt32(intBinNumber))!))
            remove(from: 0, to: 8, in: &currentBinText)
        }
        return charArray.joined()
    }


    private func permutation(binText: [Int], table: [Int]) -> [Int] {
        var permutationText = [Int]()
        for elem in table {
            permutationText.append(binText[elem - 1])
        }
        return permutationText
    }


    private func modulo(a: [Int], b: [Int]) -> [Int] {
        var result = [Int]()
        for item in 0..<a.count{
            result.append(a[item] ^ b[item])
        }
        return result
    }


    private func genBBlocks(binText: [Int]) -> [[Int]] {
        var B = [[Int]]()
        var currentBinText = binText
        while currentBinText.count > 0 {
            var block = [Int]()
            transformation(start: 0, end: 6, array: &block, binText: currentBinText)
            B.append(block)
            remove(from: 0, to: 6, in: &currentBinText)
        }
        return B
    }


    private func transform(B: [[Int]], S: [[[Int]]]) -> [Int] {
        var result = [Int]()
        for (x, y) in zip(B, 0..<8) {
            let a = Int(String(x[0]) + String(x[5]), radix: 2)!
            let b = Int(String(x[1]) + String(x[2]) + String(x[3]) + String(x[4]), radix: 2)!
            let temp = S[y][a][b]

            var binary = String(temp, radix: 2)
            var lenBinary = binary.lengthOfBytes(using: String.Encoding.utf8)
            while lenBinary != 4 {
                binary = "0" + binary
                lenBinary += 1
            }
            for ch in binary.characters {
                result.append(Int(String(ch))!)
            }
        }
        return result
    }


    private func addedBit(binKey: [Int]) -> Int {
        var count = 0
        for x in binKey {
            if x == 1 {
                count += 1
            }
        }
        if count % 2 == 0 {
            return 1
        }
        return 0
    }

    private func currentPermutation(new: inout [Int], shift: Int, cD: inout [Int], newBinKey: [Int]) {
        transformation(start: shift, end: c0.count, array: &new, binText: c0)
        transformation(start: 0, end: shift, array: &new, binText: c0)
        for x in new {
            cD.append(newBinKey[x-1])
        }
    }

    private func getNewPermutation(cD: inout [Int], newBinKey: [Int], shift: Int) {
        var new = [Int]()
        currentPermutation(new: &new, shift: shift, cD: &cD, newBinKey: newBinKey)
    }

    private func createNewKey(newKey: inout [[Int]], shift: inout Int, newBinKey: [Int], index: Int) {
        var cD = [Int]()
        shift += number_of_shifts[index]

        getNewPermutation(cD: &cD, newBinKey: newBinKey, shift: shift)
        getNewPermutation(cD: &cD, newBinKey: newBinKey, shift: shift)

        newKey.append(permutation(binText: cD, table: finish_permutation))
    }

    private func createNewBinKey(currentBinKey: inout [Int], newBinKey: inout [Int]) {
        var currentKey = [Int]()
        for item in 0..<7 {
            currentKey.append(currentBinKey[item])
            newBinKey.append(currentBinKey[item])
        }
        newBinKey.append(addedBit(binKey: currentKey))
        remove(from: 0, to: 7, in: &currentBinKey)
    }

    private func keyGen(binKey: [Int]) -> [[Int]] {
        var newBinKey = [Int]()
        var currentBinKey = binKey
        while currentBinKey.count > 0 {
            createNewBinKey(currentBinKey: &currentBinKey, newBinKey: &newBinKey)
        }
        var newKey = [[Int]]()
        var shift = 0
        for x in 0..<16 {
            createNewKey(newKey: &newKey, shift: &shift, newBinKey: newBinKey, index: x)
        }
        return newKey
    }


    private func functionFeystel(R: [Int], binKey: [Int]) -> [Int] {
        let permutation = self.permutation(binText: R, table: func_E)
        let modulo = self.modulo(a: permutation, b: binKey)
        let genBlocks = genBBlocks(binText: modulo)
        return transform(B: genBlocks, S: s_transformation)
    }


    private func runFunctionFeystel(L: inout [Int], R: inout [Int], binKey: [Int], cipher: CipherMethod) {
        for x in 0..<16 {
            switch cipher {
            case .Encrypt:
                (L, R) = (R, modulo(a: L, b: functionFeystel(R: R, binKey: keyGen(binKey: binKey)[x])))
            case .Decrypt:
                (R, L) = (L, modulo(a: R, b: functionFeystel(R: L, binKey: keyGen(binKey: binKey)[15-x])))
            }
        }
    }


    private func cipherCycle(binText: [Int], binKey: [Int], cipher: CipherMethod) -> [Int] {
        var L = [Int]()
        var R = [Int]()

        transformation(start: 0, end: 32, array: &L, binText: binText)
        transformation(start: 32, end: 64, array: &R, binText: binText)

        runFunctionFeystel(L: &L, R: &R, binKey: binKey, cipher: cipher)

        var result = [Int]()
        getResult(array: L, resultArray: &result)
        getResult(array: R, resultArray: &result)

        return result
    }


    private func encryptionCycle(binText: [Int], binKey: [Int]) -> [Int] {
        return cipherCycle(binText: binText, binKey: binKey, cipher: .Encrypt)
    }


    private func decryptionCycle(binText: [Int], binKey: [Int]) -> [Int] {
        return cipherCycle(binText: binText, binKey: binKey, cipher: .Decrypt)
    }

    private func getCurrentPermutationAndBinKey(block: [String], key: String) -> ([Int], [Int]) {
        let binText = textIntoABinaryView(text: block.joined())
        let binKey = textIntoABinaryView(text: key)
        return (permutation(binText: binText, table: ip_initial_permutation), binKey)
    }

    private func getCipherText(blocks: [[String]], cipherText: inout [Int], key: String, cipher: CipherMethod) {
        for block in blocks {
            let (currentPermutation, binKey) = getCurrentPermutationAndBinKey(block: block, key: key)
            var crypt = [Int]()

            switch cipher {
            case .Encrypt:
                crypt = encryptionCycle(binText: currentPermutation, binKey: binKey)
            case .Decrypt:
                crypt = decryptionCycle(binText: currentPermutation, binKey: binKey)
            }

            getResult(array: permutation(binText: crypt, table: ip_1), resultArray: &cipherText)
        }
    }

    private func createBlocks(charArray: inout [String], blocks: inout [[String]]) {
        while charArray.count > 0 {
            var currentBlock = [String]()
            transformation(start: 0, end: 8, array: &currentBlock, binText: charArray)
            remove(from: 0, to: 8, in: &charArray)
            blocks.append(currentBlock)
        }
    }

    private func createCharArray(newText: String) -> [String] {
        var charArray = [String]()
        for char in newText.characters {
            charArray.append(String(char))
        }

        return charArray
    }


    func cipher(text: String, key: String, cipher: CipherMethod) -> String {
        var newText = text
        if newText.characters.count % 8 != 0 {
            for _ in 0..<(8 - (newText.characters.count % 8)) {
                newText += " "
            }
        }
        var charArray = createCharArray(newText: newText)
        var blocks = [[String]]()
        createBlocks(charArray: &charArray, blocks: &blocks)

        var cipherText = [Int]()
        getCipherText(blocks: blocks, cipherText: &cipherText, key: key, cipher: cipher)

        return binaryViewIntoAText(binText: cipherText)
    }


    func encryption(text: String) -> String {
        return cipher(text: text, key: self.key, cipher: .Encrypt)
    }


    func decryption(text: String) -> String {
        return cipher(text: text, key: self.key, cipher: .Decrypt)
    }
}

