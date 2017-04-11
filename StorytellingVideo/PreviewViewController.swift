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
        
        thumbnailImageView = UIImageView.init(frame: CGRect(x: (self.view.frame.size.width - 300)/2, y: 100, width: 300, height: 300))
        thumbnailImageView?.image = thumbnailImage
        thumbnailImageView?.isUserInteractionEnabled = true
        thumbnailImageView?.contentMode = .scaleAspectFill
        thumbnailImageView?.clipsToBounds = true
        self.view.addSubview(thumbnailImageView!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PreviewViewController.playVideo))
        self.thumbnailImageView?.addGestureRecognizer(tapGesture)
        
        if (self.mergedVideo) {
            /*If this is the preview of merged video*/
            
            if (FBSDKAccessToken.current() != nil) {
                /*With facebook logged in. Show Share Button directly*/
                let fbShareBtn = UIButton.init(frame: CGRect(x: (375-200)/2, y: 500, width: 200, height: 30))
                fbShareBtn.setTitle("Share to Facebook", for: UIControlState.normal)
                fbShareBtn.addTarget(self, action: #selector(shareVideo), for: UIControlEvents.touchUpInside)
                fbShareBtn.backgroundColor = UIColor.gray
                self.view.addSubview(fbShareBtn)
            } else {
                /*Show login button first if no user has logged in Facebook.*/
                let fbLoginBtn = FBSDKLoginButton.init(frame: CGRect(x: (375-200)/2, y: 600, width: 200, height: 30))
                fbLoginBtn.delegate = self
                fbLoginBtn.publishPermissions = ["publish_actions"]
                fbLoginBtn.readPermissions = ["email"]
                self.view.addSubview(fbLoginBtn)
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
        
//        let dialog = FBSDKShareDialog()
//        dialog.shareContent = content
//        dialog.show()
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
            
        }else {
            print("LOGIN FAILS WITH ERROR: \(error)")
        }
    }
    
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
     */
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("LOGOUT")
    }


    /**
     Sent to the delegate when the sharer is cancelled.
     - Parameter sharer: The FBSDKSharing that completed.
     */
    public func sharerDidCancel(_ sharer: FBSDKSharing!) {
        print("FB CANCEL")
    }
    
    /**
     Sent to the delegate when the sharer encounters an error.
     - Parameter sharer: The FBSDKSharing that completed.
     - Parameter error: The error.
     */
    public func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        print("FB FAIL WITH ERROR: \(error)")
    }
    
    /**
     Sent to the delegate when the share completes without error or cancellation.
     - Parameter sharer: The FBSDKSharing that completed.
     - Parameter results: The results from the sharer.  This may be nil or empty.
     */
    public func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        //
        print("FB SUCCESS")
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
