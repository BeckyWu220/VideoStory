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
    var videoSlotArray: NSMutableArray = []
    var slotRangeArray: NSMutableArray = []
    var currentVideoSection: VideoSectionView?
    
    var exportBtn: UIButton?
    var videoURL: URL?
    var endEditingBtn: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Storyboard"
        
        self.createVideoSections(number: 3)
        
        exportBtn = UIButton.init(frame: CGRect(x: (375-200)/2, y: 500, width: 200, height: 30))
        exportBtn?.setTitle("Export", for: UIControlState.normal)
        exportBtn?.addTarget(self, action: #selector(mergeVideos), for: UIControlEvents.touchUpInside)
        exportBtn?.backgroundColor = UIColor.gray
        self.view.addSubview(exportBtn!)
        
        endEditingBtn = UIButton.init(frame: (exportBtn?.frame)!)
        endEditingBtn?.setTitle("End Editing", for: UIControlState.normal)
        endEditingBtn?.addTarget(self, action: #selector(endEditingMode), for: UIControlEvents.touchUpInside)
        endEditingBtn?.backgroundColor = UIColor.gray
        self.view.addSubview(endEditingBtn!)
        endEditingBtn?.isHidden = true
    }
    
    func tappedVideoSection(videoSection: VideoSectionView) {
        print("???")
        
        if videoSection.containVideo {
            let moviePlayer = MPMoviePlayerViewController(contentURL: self.currentVideoSection?.videoURL)
            self.presentMoviePlayerViewControllerAnimated(moviePlayer)
        }else{
            currentVideoSection = videoSection
            
            let importController : SelectImportViewController = SelectImportViewController()
            importController.delegate = self
            self.endEditingMode()
            self.navigationController?.pushViewController(importController, animated: true)
        }
    }
    
    func switchToEditingMode() {
        exportBtn?.isHidden = true
        endEditingBtn?.isHidden = false
        
        for i in 0...(self.videoSectionArray.count-1) {
            let videoSection = self.videoSectionArray.object(at: i) as! VideoSectionView
            videoSection.deleteBtn?.isHidden = false
        }
    }
    
    func endEditingMode() {
        exportBtn?.isHidden = false
        endEditingBtn?.isHidden = true
        
        for i in 0...(self.videoSectionArray.count-1) {
            let videoSection = self.videoSectionArray.object(at: i) as! VideoSectionView
            videoSection.deleteBtn?.isHidden = true
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
                        
                        let previewController = PreviewViewController.init(videoURL: self.videoURL!)
                        self.navigationController?.pushViewController(previewController, animated: true)
                        
                        for i in 0...(self.videoSectionArray.count-1) {
                            let videoSection = self.videoSectionArray.object(at: i) as! VideoSectionView
                            videoSection.removeFromSuperview()
                        }
                        self.videoSectionArray.removeAllObjects()
                        self.createVideoSections(number: 3)
                    }
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
        
        
    
    }
    
    func createVideoSections(number: Int) {
        for index in 0...(number - 1) {
            //print("\(index) times 5 is \(index * 5)")
            
            var videoSectionFrame = CGRect()
            let row : Int = index / 2
            
            print("\(row)")
            
            if index % 2 != 1 {
                videoSectionFrame = CGRect(x: Int((self.view.frame.width/2 - 100)/2), y: row * (100 + 50) + 100, width: 100, height: 100)
            }else{
                videoSectionFrame = CGRect(x: Int((self.view.frame.width/2 - 100)/2 + self.view.frame.width/2), y: row * (100 + 50) + 100, width: 100, height: 100)
            }
            
            let videoSlot = SlotView(frame: videoSectionFrame)
            self.view.addSubview(videoSlot)
            videoSlotArray.add(videoSlot)
            
            let slotRange = UIView(frame: CGRect(x: 0, y: 0, width: videoSlot.frame.size.width * 1.5, height: videoSlot.frame.size.height * 1.5))
            slotRange.center = videoSlot.center
            slotRange.backgroundColor = UIColor.red
            slotRange.alpha = 0.5
            self.view.addSubview(slotRange)
            slotRangeArray.add(slotRange)
            
            let videoSection = VideoSectionView(frame: videoSectionFrame)
            videoSection.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            videoSection.delegate = self
            videoSectionArray.add(videoSection)
        }
        
        for i in 0...(videoSectionArray.count-1) {
            let videoSection = videoSectionArray.object(at: i) as! VideoSectionView
            self.view.addSubview(videoSection)
        }
    }
    
    func draggedVideoSection(videoSection: VideoSectionView) {
        print("Drag")
        let intersectionArray : NSMutableArray = []
        print("Elements: \(intersectionArray.count)")
        for i in 0...(slotRangeArray.count-1) {
            
            let slotRange = slotRangeArray.object(at: i) as! UIView
            
            let intersection = slotRange.frame.intersection(videoSection.frame)
            let intersectArea: CGFloat

            
            if intersection.isNull {
                intersectArea = 0
            }else{
                intersectArea = intersection.width * intersection.height
            }
            
            intersectionArray.add(intersectArea)
        }
        
        var maxIntersectionSlot = 0
        print("After Adding Elements: \(intersectionArray.count)")
        
        for j in 0...(intersectionArray.count-2) {
            print("?")
            if (intersectionArray.object(at: j) as! CGFloat) < (intersectionArray.object(at: j+1) as! CGFloat) {
                maxIntersectionSlot = j+1
            }
        }
        
        for element in intersectionArray {
            print(element)
        }
        print("MaxSlot: \(maxIntersectionSlot)")
        let targetSlot = videoSlotArray.object(at: maxIntersectionSlot) as! SlotView
        
        let originSlotIndex = videoSectionArray.index(of: videoSection)
        
        let originSlot = videoSlotArray.object(at: originSlotIndex) as! SlotView
        
        let targetVideoSection = videoSectionArray.object(at: maxIntersectionSlot) as! VideoSectionView
        
        UIView.animate(withDuration: 0.3,
                                   delay: 0.0,
                                   options: .curveEaseInOut,
                                   animations:
        {
            videoSection.center = targetSlot.center
            targetVideoSection.center = originSlot.center
        }, completion: { finished in
            let tempVideoSection = self.videoSectionArray.object(at: originSlotIndex) as! VideoSectionView
            
            self.videoSectionArray.replaceObject(at: originSlotIndex, with: self.videoSectionArray.object(at: maxIntersectionSlot))
            self.videoSectionArray.replaceObject(at: maxIntersectionSlot, with: tempVideoSection)
        })
    }
    
    func mergeVideos() {
        
        let mixComposition = AVMutableComposition()
        let mainInstruction = AVMutableVideoCompositionInstruction()
        
        var videoLength = kCMTimeZero
        
        for i in 0...(videoSectionArray.count-1) {
            
            let videoSection = videoSectionArray.object(at: i) as! VideoSectionView
            
            if videoSection.containVideo {
                let videoAsset = AVAsset(url: videoSection.videoURL!)
                print("\(videoAsset)")
                
                let videoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
                do {
                    try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: videoLength)
                    videoLength = CMTimeAdd(videoLength, videoAsset.duration)
                    
                    let videoInstruction = videoCompositionInstructionForTrack(videoTrack, asset: videoAsset)
                    videoInstruction.setOpacity(0.0, at: videoLength)
                    
                    mainInstruction.layerInstructions.append(videoInstruction)
                    
                } catch {
                    print("Failed to load video track")
                }
            }
            
        }
        
        // 2.1
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoLength)
        
        // 2.3
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
        
        videoURL = exporter.outputURL
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

