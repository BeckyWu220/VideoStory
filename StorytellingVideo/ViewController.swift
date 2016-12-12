//
//  ViewController.swift
//  StorytellingVideo
//
//  Created by Wanqiao Wu on 2016-12-07.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices

class ViewController: UIViewController, VideoSectionDelegate {
    
    var videoSectionArray: NSMutableArray = []
    var currentVideoSection: VideoSectionView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Storyboard"
        
        for index in 0...3 {
            //print("\(index) times 5 is \(index * 5)")
            
            var videoSectionFrame = CGRect()
            var row : Int = index / 2
            
            print("\(row)")
            
            if index % 2 == 1 {
                videoSectionFrame = CGRect(x: Int((self.view.frame.width/2 - 100)/2), y: row * (100 + 10) + 100, width: 100, height: 100)
            }else{
                videoSectionFrame = CGRect(x: Int((self.view.frame.width/2 - 100)/2 + self.view.frame.width/2), y: row * (100 + 10) + 100, width: 100, height: 100)
            }
            
            let videoSection = VideoSectionView(frame: videoSectionFrame)
            videoSection.delegate = self
            self.view.addSubview(videoSection)
            videoSectionArray.add(videoSection)
        }
        
    }
    
    func tappedVideoSection(videoSection: VideoSectionView) {
        print("???")
        
        if videoSection.containVideo != nil {
            let moviePlayer = MPMoviePlayerViewController(contentURL: self.currentVideoSection?.videoURL)
            self.presentMoviePlayerViewControllerAnimated(moviePlayer)
        }else{
            currentVideoSection = videoSection
            
            let importController : SelectImportViewController = SelectImportViewController()
            self.navigationController?.pushViewController(importController, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension ViewController: UINavigationControllerDelegate{
    
}

