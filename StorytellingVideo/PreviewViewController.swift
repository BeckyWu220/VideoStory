//
//  PreviewViewController.swift
//  StorytellingVideo
//
//  Created by Wanqiao Wu on 2016-12-12.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices

import FBSDKLoginKit
import FBSDKShareKit

class PreviewViewController: UIViewController {
    
    var thumbnailImageView: UIImageView?
    var thumbnailImage: UIImage?
    var videoURL: URL?
    var mergedVideo: Bool
    var delegate: SelectImportVCDelegate!
    
    var fbShareBtn: UIButton?
    var fbLoginBtn: FBSDKLoginButton?
    var backBtn: UIButton?
    
    init(videoURL: URL, mergedVideo: Bool) {
        
        let asset = AVURLAsset(url: videoURL)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        thumbnailImage = try! UIImage(cgImage: imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil))
        self.videoURL = videoURL
        self.mergedVideo = mergedVideo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Preview"
        
        backBtn = UIButton(frame: CGRect(x: 10, y: 40, width: 40, height: 40))
        backBtn?.setImage(UIImage.init(named: "backBtn"), for: UIControlState.normal)
        backBtn?.addTarget(self, action: #selector(clickBackBtn), for: .touchUpInside)
        self.view.addSubview(backBtn!)
        
        thumbnailImageView = UIImageView.init(frame: CGRect(x: (self.view.frame.size.width - 300)/2, y: 100, width: 300, height: 300))
        thumbnailImageView?.image = thumbnailImage
        thumbnailImageView?.isUserInteractionEnabled = true
        thumbnailImageView?.contentMode = .scaleAspectFill
        thumbnailImageView?.clipsToBounds = true
        
        thumbnailImageView?.layer.borderWidth = 3
        thumbnailImageView?.layer.borderColor = UIColor.gray.cgColor
        
        self.view.addSubview(thumbnailImageView!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PreviewViewController.playVideo))
        self.thumbnailImageView?.addGestureRecognizer(tapGesture)
        
        if (self.mergedVideo) {
            /*If this is the preview of merged video*/
            
            if (FBSDKAccessToken.current() != nil) {
                /*With facebook logged in. Show Share Button directly*/
                fbShareBtn = UIButton.init(frame: CGRect(x: (375-200)/2, y: 500, width: 200, height: 30))
                fbShareBtn?.setTitle("Share to Facebook", for: UIControlState.normal)
                fbShareBtn?.addTarget(self, action: #selector(shareVideo), for: UIControlEvents.touchUpInside)
                fbShareBtn?.backgroundColor = UIColor.gray
                self.view.addSubview(fbShareBtn!)
            } else {
                /*Show login button first if no user has logged in Facebook.*/
                fbLoginBtn = FBSDKLoginButton.init(frame: CGRect(x: (375-200)/2, y: 500, width: 200, height: 30))
                fbLoginBtn?.delegate = self
                fbLoginBtn?.publishPermissions = ["publish_actions"]
                //fbLoginBtn?.readPermissions = ["email"]
                self.view.addSubview(fbLoginBtn!)
            }
            
        }else {
            /*If this preview is for unmerged video, show editBtn and deleteBtn*/
            let editBtn = UIButton.init(frame: CGRect(x: (375-200)/2, y: 500, width: 200, height: 30))
            editBtn.setTitle("Edit Video", for: UIControlState.normal)
            editBtn.addTarget(self, action: #selector(editVideo), for: UIControlEvents.touchUpInside)
            editBtn.backgroundColor = UIColor.gray
            self.view.addSubview(editBtn)
            
            let deleteBtn = UIButton.init(frame: CGRect(x: editBtn.frame.origin.x, y: editBtn.frame.origin.y+editBtn.frame.size.height + 10, width: editBtn.frame.size.width, height: editBtn.frame.size.height))
            deleteBtn.setTitle("Delete", for: UIControlState.normal)
            deleteBtn.addTarget(self, action: #selector(deleteVideo), for: UIControlEvents.touchUpInside)
            deleteBtn.backgroundColor = UIColor.gray
            self.view.addSubview(deleteBtn)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clickBackBtn() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    

    func playVideo() {
        print("Play Preview Video")
        let moviePlayer = MPMoviePlayerViewController(contentURL: videoURL)
        self.presentMoviePlayerViewControllerAnimated(moviePlayer)
    }
    
    func deleteVideo() {
        print("Delete Video & Return to ViewController")
        self.delegate.resetVideoSection()
        self.navigationController?.popViewController(animated: true)
    }
    
    func shareVideo() {
        print("Share Video to Facebook")
        
        let video: FBSDKShareVideo = FBSDKShareVideo()
        video.videoURL = self.videoURL
        let content: FBSDKShareVideoContent = FBSDKShareVideoContent()
        content.video = FBSDKShareVideo(videoURL: self.videoURL)
        
        FBSDKShareAPI.share(with: content, delegate: self)
        
//        let dialog: FBSDKShareDialog = FBSDKShareDialog()
//        if (dialog.canShow()) {
//            print("FB Dialog show.")
//            dialog.shareContent = content
//            dialog.delegate = self
//            dialog.show()
//        } else {
//            print("FB Dialog cannot show.")
//        }
    }
}

extension PreviewViewController: FBSDKSharingDelegate, FBSDKLoginButtonDelegate {
    
    /**
     Sent to the delegate when the button was used to login.
     - Parameter loginButton: the sender
     - Parameter result: The results of the login
     - Parameter error: The error (if any) from the login
     */
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if !(error != nil) {
            print("LOGIN SUCCESS")
            
            fbLoginBtn?.removeFromSuperview()
            fbShareBtn = UIButton.init(frame: CGRect(x: (375-200)/2, y: 500, width: 200, height: 30))
            fbShareBtn?.setTitle("Share to Facebook", for: UIControlState.normal)
            fbShareBtn?.addTarget(self, action: #selector(shareVideo), for: UIControlEvents.touchUpInside)
            fbShareBtn?.backgroundColor = UIColor.gray
            self.view.addSubview(fbShareBtn!)
        }else {
            print("LOGIN FAILS WITH ERROR: \(error)")
            self.alert(title: "Reminder", message: "Login to Facebook fails. \(error)")
        }
    }
    
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
     */
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("LOGOUT")
        self.alert(title: "Reminder", message: "You've logged out from Facebook.")
    }

    /**
     Sent to the delegate when the sharer is cancelled.
     - Parameter sharer: The FBSDKSharing that completed.
     */
    public func sharerDidCancel(_ sharer: FBSDKSharing!) {
        print("FB CANCEL")
        self.alert(title: "Reminder", message: "You video posting is canceled.")
    }
    
    /**
     Sent to the delegate when the sharer encounters an error.
     - Parameter sharer: The FBSDKSharing that completed.
     - Parameter error: The error.
     */
    public func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        print("FB FAIL WITH ERROR: \(error)")
        self.alert(title: "Reminder", message: "We have error while posting your video. \(error)")
    }
    
    /**
     Sent to the delegate when the share completes without error or cancellation.
     - Parameter sharer: The FBSDKSharing that completed.
     - Parameter results: The results from the sharer.  This may be nil or empty.
     */
    public func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        //
        print("FB SUCCESS")
        self.alert(title: "Reminder", message: "Your video has been posted successfully to Facebook.")
    }
    
    func alert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension PreviewViewController: UIVideoEditorControllerDelegate, UINavigationControllerDelegate {
    
    func editVideo() {
        print("Edit Video")
        let editVideoViewController: UIVideoEditorController!
        
        if UIVideoEditorController.canEditVideo(atPath: (videoURL?.path)!) {
            editVideoViewController = UIVideoEditorController()
            editVideoViewController.delegate = self
            editVideoViewController.videoPath = (videoURL?.path)!
            editVideoViewController.videoQuality = .typeHigh
            present(editVideoViewController, animated: true, completion: {
                
            })
        }
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        dismiss(animated: false, completion: {
            self.videoURL = URL(fileURLWithPath: editedVideoPath)
            
            let asset = AVURLAsset(url: self.videoURL!)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let image : UIImage = try! UIImage(cgImage: imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil))
            
            self.setThumbnailForVideoSection(image: image, videoURL: self.videoURL!, videoPath: (self.videoURL?.path)!)
        })
    }
    
    func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        dismiss(animated: true, completion: {})
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didFailWithError error: Error) {
        print("error=\(error.localizedDescription)")
        dismiss(animated: true, completion: {})
    }
    
    func setThumbnailForVideoSection(image: UIImage, videoURL: URL, videoPath: String) {
        self.thumbnailImage = image
        thumbnailImageView?.image = thumbnailImage
        self.videoURL = videoURL
        self.delegate.setThumbnailForVideoSection(image: image, videoURL: videoURL, videoPath: videoURL.path)
    }
}
