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
        }else {
            /*If this preview is for unmerged video*/
            let editBtn = UIButton.init(frame: CGRect(x: (375-200)/2, y: 500, width: 200, height: 30))
            editBtn.setTitle("Edit Video", for: UIControlState.normal)
            editBtn.addTarget(self, action: #selector(editVideo), for: UIControlEvents.touchUpInside)
            editBtn.backgroundColor = UIColor.gray
            self.view.addSubview(editBtn)
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
