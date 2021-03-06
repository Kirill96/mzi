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
import JSQMessagesViewController
import Photos

final class ChatViewController: JSQMessagesViewController {

    // MARK: Properties

    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()

    private lazy var messageRef: DatabaseReference = self.channelRef!.child("messages")
    private var newMessageRefHandle: DatabaseHandle?

    var channelRef: DatabaseReference?
    var channel: Channel? {
        didSet {
            title = channel?.name
        }
    }

    var messages = [JSQMessage]()

    private lazy var userIsTypingRef: DatabaseReference =
        self.channelRef!.child("typingIndicator").child(self.senderId)
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }

    private lazy var usersTypingQuery: DatabaseQuery =
        self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)

    lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://chat-64b67.appspot.com")

    private let imageURLNotSetKey = "NOTSET"

    private var photoMessageMap = [String: JSQPhotoMediaItem]()

     private var updatedMessageRefHandle: DatabaseHandle?

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = Auth.auth().currentUser?.uid

        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero

        observeMessages()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }

    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }

        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId()

        let encryptText = self.encryption(text: text)

        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": encryptText,
            ]
        print("send message: \(text), encrypt: \(encryptText)")
        itemRef.setValue(messageItem)

        JSQSystemSoundPlayer.jsq_playMessageSentSound()

        finishSendingMessage()
        isTyping = false
    }

    override func didPressAccessoryButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary

        present(picker, animated: true, completion:nil)
    }

    // MARK: Collection view data source (and related) methods

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]

        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }


    // MARK: Firebase related methods

    private func addMessage(withId id: String, name: String, text: String) {
        
        let decryptText = self.decryption(text: text)

        print("get message: \(text), decryptText: \(decryptText)")
        if let message = JSQMessage(senderId: id, displayName: name, text: decryptText) {
            messages.append(message)
        }
    }

    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)

            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }

            collectionView.reloadData()
        }
    }

    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {

        let storageRef = Storage.storage().reference(forURL: photoURL)

        storageRef.getData(maxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }

            storageRef.getMetadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }

                if (metadata?.contentType == "image/gif") {
                    mediaItem.image = UIImage.gifWithData(data!)
                } else {
                    mediaItem.image = UIImage.init(data: data!)
                }
                self.collectionView.reloadData()

                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }

    private func observeMessages() {
        messageRef = channelRef!.child("messages")

        let messageQuery = messageRef.queryLimited(toLast:25)


        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in

            let messageData = snapshot.value as! Dictionary<String, String>

            if let id = messageData["senderId"] as String!,
                let name = messageData["senderName"] as String!,
                let text = messageData["text"] as String!,
                text.characters.count > 0 {

                self.addMessage(withId: id, name: name, text: text)


                self.finishReceivingMessage()
            } else if let id = messageData["senderId"] as String!,
                let photoURL = messageData["photoURL"] as String! {

                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {

                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)

                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            } else {
                print("Error! Could not decode message data")
            }
        })

        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String> // 1

            if let photoURL = messageData["photoURL"] as String! { // 2
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] { // 3
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                }
            }
        })
    }

    private func observeTyping() {
        let typingIndicatorRef = channelRef!.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()

        usersTypingQuery.observe(.value) { (data: DataSnapshot) in
            if data.childrenCount == 1 && self.isTyping {
                return
            }

            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }

    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()

        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            ]

        itemRef.setValue(messageItem)

        JSQSystemSoundPlayer.jsq_playMessageSentSound()

        finishSendingMessage()
        return itemRef.key
    }

    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }


    // MARK: UI and User Interaction

    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }

    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }


    // MARK: UITextViewDelegate methods

    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
    }

}

// MARK: Image Picker Delegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {

        picker.dismiss(animated: true, completion:nil)


        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {


            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
            let asset = assets.firstObject


            if let key = sendPhotoMessage() {

                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageFileURL = contentEditingInput?.fullSizeImageURL


                    let path = Auth.auth().currentUser!.uid + "\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"


                    self.storageRef.child(path).putFile(from: imageFileURL!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }

                        self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                    }
                })
            }
        } else {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage

            if let key = sendPhotoMessage() {

                let imageData = UIImageJPEGRepresentation(image, 1.0)

                let imagePath = Auth.auth().currentUser!.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"

                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"

                storageRef.child(imagePath).putData(imageData!, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        print("Error uploading photo: \(error)")
                        return
                    }

                    self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                }
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }

    func encryption(text: String) -> String {
        let activeEncryption = UserDefaultsService().get(data: .encryption)

        switch activeEncryption {
        case Encryption.caesar.rawValue:
            return CaesarCipher().ecnrypt(text: text)
        case Encryption.AES.rawValue:
            return AESCipher().encrypt(text: text) ?? ""
        case Encryption.DES.rawValue:
            return ClassicDes().encryption(text: text)
        case Encryption.tripleDES.rawValue:
            return TripleDes().encryption(text: text)
        case Encryption.tripleDES2.rawValue:
            return TripleDesDoubleKey().encryption(text: text)
        case Encryption.RSA.rawValue:
            return ClassicDes().encryption(text: text)
        case Encryption.md5.rawValue:
            return TripleDes().encryption(text: text)
        case Encryption.digitalSignature.rawValue:
            return TripleDesDoubleKey().encryption(text: text)
        case Encryption.ellipticalCurves.rawValue:
            return AESCipher().encrypt(text: text) ?? ""
        default:
            return text
        }
    }

    func decryption(text: String) -> String {

        let activeEncryption = UserDefaultsService().get(data: .encryption)

        switch activeEncryption {
        case Encryption.caesar.rawValue:
            return CaesarCipher().decrypt(text: text)
        case Encryption.AES.rawValue:
            return AESCipher().decrypt(text: text) ?? ""
        case Encryption.DES.rawValue:
            return ClassicDes().decryption(text: text)
        case Encryption.tripleDES.rawValue:
            return TripleDes().decryption(text: text)
        case Encryption.tripleDES2.rawValue:
            return TripleDesDoubleKey().decryption(text: text)
        case Encryption.RSA.rawValue:
            return ClassicDes().decryption(text: text)
        case Encryption.md5.rawValue:
            return TripleDes().decryption(text: text)
        case Encryption.digitalSignature.rawValue:
            return TripleDesDoubleKey().decryption(text: text)
        case Encryption.ellipticalCurves.rawValue:
            return AESCipher().decrypt(text: text) ?? ""
        default:
            return text
        }
    }
}
