//
//  ViewController.swift
//  Images
//
//  Created by Shehryar Bajwa on 2018-04-16.
//  Copyright © 2018 truBrain. All rights reserved.
//
//print("hello world")
import UIKit
import Foundation

class SentMemesViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate {
    
    var meme = [Meme]()

    @IBOutlet weak var Pickimage: UIBarButtonItem!
    @IBOutlet weak var CameraButton: UIBarButtonItem!
    @IBOutlet weak var images: UIImageView!   
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var sharebutton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        self.topText.delegate = self
        self.bottomText.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    let memeTextAttributes:[String: Any] = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size : 30)!,
        NSStrokeWidthAttributeName : -3.0
    ]
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        topText.resignFirstResponder()
        bottomText.resignFirstResponder()
        return true
    }
    
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if view.frame.origin.y == 0 && bottomText.isFirstResponder{
            view.frame.origin.y -= getKeyboardHeight(notification as Notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
            view.frame.origin.y = 0
        }
    
    
    func saveMeme() {
        // Create the meme in the form of a struct
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: images.image, memedImage: generateMemedImage())
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    func generateMemedImage() -> UIImage {
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    

    
    @IBAction func pickImage(_ sender: Any) {
        let pickImage = UIImagePickerController()
        pickImage.delegate = self
        pickImage.sourceType = .photoLibrary
        present(pickImage, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func pickCamera(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
        let pickCamera = UIImagePickerController()
        pickCamera.delegate = self
        pickCamera.sourceType = .camera
        present(pickCamera, animated: true, completion: nil)
        } else{
            print("Camera not enabled")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageIselected = info[UIImagePickerControllerOriginalImage] as! UIImage
        images.image = imageIselected
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender:UIButton){
        images.image = nil
        topText.text = "Top"
        bottomText.text = "Bottom"
        sharebutton.isEnabled = true
    }
    
    @IBAction func shareButton(_ sender: UIButton){
        
        if sender.isEnabled {
        let memeImage = self.generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
            activityViewController.completionWithItemsHandler = {
                activity, completed, items, error in
                if completed && (self.images != nil) {
                    self.saveMeme()
                    self.dismiss(animated: true, completion: nil)
                } else{
                    print("You haven't initialized an image")
                }
                
            }
        
    }
    
    
    }





}
