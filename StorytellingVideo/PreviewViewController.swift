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
    var exportedVideoURL: URL?
    
    init(videoURL: URL) {
        
        let asset = AVURLAsset(url: videoURL)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        thumbnailImage = try! UIImage(cgImage: imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil))
        exportedVideoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Preview"
        
        thumbnailImageView = UIImageView.init(frame: CGRect(x: (self.view.frame.size.width - 300)/2, y: 50, width: 300, height: 300))
        thumbnailImageView?.image = thumbnailImage
        thumbnailImageView?.isUserInteractionEnabled = true
        self.view.addSubview(thumbnailImageView!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PreviewViewController.playVideo))
        self.thumbnailImageView?.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func playVideo() {
        print("Play")
        let moviePlayer = MPMoviePlayerViewController(contentURL: exportedVideoURL)
        self.presentMoviePlayerViewControllerAnimated(moviePlayer)
    }

}
