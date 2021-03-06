//
//  SelectImportViewController.swift
//  StorytellingVideo
//
//  Created by Wanqiao Wu on 2016-12-09.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices

protocol SelectImportVCDelegate{
    func setThumbnailForVideoSection(image: UIImage, videoURL: URL)
}

class SelectImportViewController: UIViewController {
    
    var delegate: SelectImportVCDelegate!
    public var albumBtn: UIButton?
    public var cameraBtn: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white

        // Do any additional setup after loading the view.
        albumBtn = UIButton(frame: CGRect(x: (self.view.frame.size.width - 100)/2, y: (self.view.frame.size.height - 30)/2, width: 100, height: 30))
        albumBtn?.setTitle("Album", for: UIControlState.normal)
        albumBtn?.addTarget(self, action: #selector(clickAlbumBtn), for: UIControlEvents.touchUpInside)
        albumBtn?.backgroundColor = UIColor.gray
        self.view.addSubview(albumBtn!)
        
        cameraBtn = UIButton(frame: CGRect(x: (self.view.frame.size.width - 100)/2, y: (self.view.frame.size.height - 30)/2 + 60, width: 100, height: 30))
        cameraBtn?.setTitle("Camera", for: UIControlState.normal)
        cameraBtn?.addTarget(self, action: #selector(clickCameraBtn), for: UIControlEvents.touchUpInside)
        cameraBtn?.backgroundColor = UIColor.gray
        self.view.addSubview(cameraBtn!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clickAlbumBtn() -> Void {
        print("Click Album")
        switchToMediaBrowser(viewController: self, usingDelegate: self)
    }
    
    func clickCameraBtn() -> Void {
        print("Click Camera")
        switchCameraFromViewController(viewController: self, usingDelegate: self)
    }
    
    func switchToMediaBrowser(viewController: UIViewController, usingDelegate delegate: UINavigationControllerDelegate & UIImagePickerControllerDelegate) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false{
            return false
        }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .savedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
        
        //self.navigationController?.pushViewController(mediaUI, animated: true)
        present(mediaUI, animated: true, completion: nil)
        return true
    }
    
    func switchCameraFromViewController(viewController: UIViewController, usingDelegate delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            return false
        }
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .camera
        cameraController.mediaTypes = [kUTTypeMovie as NSString as String]
        cameraController.allowsEditing = false
        cameraController.delegate = delegate
        
        //self.navigationController?.pushViewController(cameraController, animated: true)
        present(cameraController, animated: true, completion: nil)
        return true
    }
    
    func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: Any) {
        var title  = "Success"
        var message = "Video was saved"
        if let _ = error{
            title = "Error"
            message = "Video failed to save"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {action in self.dismissCurrentViewController()}))
        present(alert, animated: true, completion: nil)
    }
    
    func dismissCurrentViewController() {
        self.navigationController?.popViewController(animated: true)
        print("!!!")
    }

}

extension SelectImportViewController: UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        dismiss(animated: true, completion: {
            if mediaType == kUTTypeMovie{
                
                guard let path = (info[UIImagePickerControllerMediaURL] as! NSURL).path else {
                    return
                }
                
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path){
                    UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(SelectImportViewController.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
                }
                
                let asset = AVURLAsset(url: (info[UIImagePickerControllerMediaURL] as! NSURL) as URL!)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                let image : UIImage = try! UIImage(cgImage: imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil))
                
                self.delegate.setThumbnailForVideoSection(image: image, videoURL: (info[UIImagePickerControllerMediaURL] as! NSURL) as URL!)
                
                //self.currentVideoSection?.initWithColor(color: UIColor.gray)
//                self.currentVideoSection?.videoIcon?.image = image
//                self.currentVideoSection?.containVideo = true
//                self.currentVideoSection?.videoURL = (info[UIImagePickerControllerMediaURL] as! NSURL) as URL!
                
                /*let moviePlayer = MPMoviePlayerViewController(contentURL: (info[UIImagePickerControllerMediaURL] as! NSURL) as URL!)
                 self.presentMoviePlayerViewControllerAnimated(moviePlayer)*/
                
                
            }
        })
    }
}

extension SelectImportViewController: UINavigationControllerDelegate{
    
}
