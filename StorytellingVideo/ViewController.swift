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
import AssetsLibrary

class ViewController: UIViewController, VideoSectionDelegate, SelectImportVCDelegate {
    
    var videoSectionArray: NSMutableArray = []
    var currentVideoSection: VideoSectionView?
    
    var exportBtn: UIButton?
    
    var firstAsset: AVAsset?
    var secondAsset: AVAsset?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Storyboard"
        
        for index in 0...3 {
            //print("\(index) times 5 is \(index * 5)")
            
            var videoSectionFrame = CGRect()
            let row : Int = index / 2
            
            print("\(row)")
            
            if index % 2 != 1 {
                videoSectionFrame = CGRect(x: Int((self.view.frame.width/2 - 100)/2), y: row * (100 + 10) + 100, width: 100, height: 100)
            }else{
                videoSectionFrame = CGRect(x: Int((self.view.frame.width/2 - 100)/2 + self.view.frame.width/2), y: row * (100 + 10) + 100, width: 100, height: 100)
            }
            
            let videoSection = VideoSectionView(frame: videoSectionFrame)
            videoSection.delegate = self
            self.view.addSubview(videoSection)
            videoSectionArray.add(videoSection)
            
            exportBtn = UIButton.init(frame: CGRect(x: (375-200)/2, y: 500, width: 200, height: 30))
            exportBtn?.setTitle("Export", for: UIControlState.normal)
            exportBtn?.addTarget(self, action: #selector(mergeVideos), for: UIControlEvents.touchUpInside)
            exportBtn?.backgroundColor = UIColor.gray
            self.view.addSubview(exportBtn!)
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
            importController.delegate = self
            self.navigationController?.pushViewController(importController, animated: true)
        }
    }
    
    func setThumbnailForVideoSection(image: UIImage, videoURL: URL) {
        self.currentVideoSection?.videoIcon?.image = image
        self.currentVideoSection?.containVideo = true
        self.currentVideoSection?.videoURL = videoURL
        
    }
    
    func exportDidFinish(session: AVAssetExportSession) {
        if session.status == AVAssetExportSessionStatus.completed{
            let outputURL = session.outputURL
            print("outputURL: \(session.outputURL)")
            let library = ALAssetsLibrary()
            if library.videoAtPathIs(compatibleWithSavedPhotosAlbum: outputURL){
                library.writeVideoAtPath(toSavedPhotosAlbum: outputURL, completionBlock: { url, error in
                    var title = ""
                    var message = ""
                    if error != nil {
                        title = "Error"
                        message = "Failed to save video"
                    }else{
                        title = "Success"
                        message = "Video exported and saved"
                    }
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
        firstAsset = nil
        secondAsset = nil
    }
    
    func mergeVideos() {
        
        firstAsset = AVAsset(url: (videoSectionArray.object(at: 0) as! VideoSectionView).videoURL!)
        secondAsset = AVAsset(url: (videoSectionArray.object(at: 1) as! VideoSectionView).videoURL!)
        print("\(firstAsset) $$$ \(secondAsset)")
        
        let mixComposition = AVMutableComposition()
        
        let firstTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try firstTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, (self.firstAsset?.duration)!), of: (firstAsset?.tracks(withMediaType: AVMediaTypeVideo)[0])!, at: kCMTimeZero)
        } catch _ {
            print("Failed to load first track")
        }
        
        let secondTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try secondTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, (self.secondAsset?.duration)!), of: (secondAsset?.tracks(withMediaType: AVMediaTypeVideo)[0])!, at: (firstAsset?.duration)!)
        } catch _ {
            print("Failed to load second track")
        }
        
        // 2.1
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd((firstAsset?.duration)!, (secondAsset?.duration)!))
        
        // 2.2
        let firstInstruction = videoCompositionInstructionForTrack(firstTrack, asset: firstAsset!)
        firstInstruction.setOpacity(0.0, at: (firstAsset?.duration)!)
        let secondInstruction = videoCompositionInstructionForTrack(secondTrack, asset: secondAsset!)
        
        // 2.3
        mainInstruction.layerInstructions = [firstInstruction, secondInstruction]
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 30)
        mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let savePath = (documentDirectory as NSString).appendingPathComponent("mergeVideo-\(date).mov")
        let url = URL(fileURLWithPath: savePath)
        
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
            else { return }
        exporter.outputURL = url
        exporter.outputFileType = AVFileTypeQuickTimeMovie
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = mainComposition
        
        exporter.exportAsynchronously(){
            DispatchQueue.main.async { _ in
                self.exportDidFinish(session: exporter)
            }
        }
    }
    
    func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
    func videoCompositionInstructionForTrack(_ track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        
        var scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
        if assetInfo.isPortrait {
            scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor),
                                     at: kCMTimeZero)
        } else {
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.width / 2))
            if assetInfo.orientation == .down {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                let windowBounds = UIScreen.main.bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
                concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
            }
            instruction.setTransform(concat, at: kCMTimeZero)
        }
        
        return instruction
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension ViewController: UINavigationControllerDelegate{
    
}

