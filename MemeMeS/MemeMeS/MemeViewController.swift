

import UIKit

class MemeViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate, UIPopoverPresentationControllerDelegate  {
    
   
    @IBOutlet weak var pickerImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    var currentTextField : String!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    var memedImage : UIImage!
    var memes = [Meme]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextField(topText, text: "TOP")
        setUpTextField(bottomText, text: "BOTTOM")
        pickerImageView.backgroundColor = UIColor.black
        shareButton.isEnabled = false
        cancelButton.isEnabled = false
    }
    
    // Texts
    func setUpTextField(_ textField: UITextField, text: String){
        let memeTextAttributes:[NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -3]
        
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.text = text
        textField.delegate = self
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        // after the reviwe
        #if targetEnvironment(simulator)
        cameraButton.isEnabled = false
        #else
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        #endif
    }
    
    
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            unsubscribeFromKeyboardNotifications()
        }
        
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
     
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if (currentTextField == "topTextField"){
            view.frame.origin.y = 0
        }else{
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1{
            currentTextField = "topTextField"
        }else if textField.tag == 2{
            currentTextField = "bottomTextField"
        }
        if textField.text == "TOP" {
            topText.text = ""
        }
        else if textField.text == "BOTTOM"{
            bottomText.text = ""
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        cancelButton.isEnabled = true
    }
    
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // actions
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        pickImage(sourceType)
    }
    
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        
        let sourceType = UIImagePickerController.SourceType.camera
        pickImage(sourceType)
    }
    
    
    func pickImage(_ sourceType : UIImagePickerController.SourceType){
        let controller = UIImagePickerController()
        controller.sourceType = sourceType
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue) ] as? UIImage{
            pickerImageView.image = image
            shareButton.isEnabled = true
            cancelButton.isEnabled = true
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func shareMeme(_ sender: Any) {
        memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            if completed {
                self.save()
            }
        }
        if UIDevice.current.userInterfaceIdiom == .pad{
            activityController.popoverPresentationController?.sourceView = self.view
        }
        present(activityController, animated: true, completion: nil )
    }
    
    @IBAction func cancelMeme(_ sender: Any) {
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        pickerImageView.image = nil
        shareButton.isEnabled = false
        cancelButton.isEnabled = false
    }
    
    func generateMemedImage() -> UIImage {
        
        topToolBar.isHidden = true
        bottomToolBar.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        topToolBar.isHidden = false
        bottomToolBar.isHidden = false
        return memedImage
    }
    
    func save() {
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: pickerImageView.image!, memedImage: memedImage)
        memes.append(meme)
    }
    
    
}

