//
//  ToyViewController.swift
//  StorytellingVideo
//
//  Created by Wanqiao Wu on 2017-04-03.
//  Copyright © 2017 Wanqiao Wu. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices
import GPUImage
import AssetsLibrary
import AVFoundation

class ToyViewController: UIViewController, UINavigationControllerDelegate {
    
    public var albumBtn: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Toy"
        
        albumBtn = UIButton(frame: CGRect(x: 0, y: self.view.frame.size.height - 30, width: 100, height: 30))
        albumBtn?.setTitle("Album", for: UIControlState.normal)
        albumBtn?.addTarget(self, action: #selector(clickAlbumBtn), for: UIControlEvents.touchUpInside)
        albumBtn?.backgroundColor = UIColor.gray
        self.view.addSubview(albumBtn!)
        
        
    }
    
    func clickAlbumBtn() -> Void {
        print("Click Album Button.")
        switchToMediaBrowser(viewController: self, usingDelegate: self)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ToyViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        dismiss(animated: true, completion: {
            
            if mediaType == kUTTypeMovie {
            
                guard let path = (info[UIImagePickerControllerMediaURL] as! NSURL).path else {
                    return
                }
                
                var videoAsset: AVAsset?
                videoAsset = AVURLAsset(url: info[UIImagePickerControllerMediaURL] as! URL)
                let videoTrack = videoAsset?.tracks(withMediaType: AVMediaTypeVideo).first
                let videoSize = videoTrack?.naturalSize
                var renderOrientation = ImageOrientation.portrait
                self.orientationFor(track: videoTrack!, renderOrientation: &renderOrientation)
                
                var renderView = RenderView(frame: CGRect(x: 0, y: 60, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width*(videoSize?.height)!/(videoSize?.width)!))
                renderView.orientation = renderOrientation
                print("Orientation: \(renderView.orientation)")
                self.view.addSubview(renderView)
                
                do {
                    let movie = try MovieInput(asset: videoAsset!, playAtActualSpeed: true, loop: true)
                    
                    let filter = Pixellate()
                    movie --> filter --> renderView
                    movie.start()
                    print("RenderView Sources: \(renderView)")
                } catch {
                    fatalError("Could not initialize rendering pipeline: \(error)")
                }
                
            }
            
        });
    }

    
    func orientationFor(track: AVAssetTrack, renderOrientation: inout ImageOrientation) -> Void {
        var videoSize = track.naturalSize
        let videoTransform = track.preferredTransform
        
        if videoSize.width == videoTransform.tx && videoSize.height == videoTransform.ty {
            print("Landscape Right")
            renderOrientation = ImageOrientation.portraitUpsideDown
        }else if videoTransform.tx == 0 && videoTransform.ty == 0 {
            print("Landscape Left")
            renderOrientation = ImageOrientation.portrait
        }else if videoTransform.tx == 0 && videoTransform.ty == videoSize.width {
            videoSize = CGSize(width: track.naturalSize.height, height: track.naturalSize.width)
            print("Portrait Upsidedown")
            renderOrientation = ImageOrientation.landscapeRight
        }else {
            videoSize = CGSize(width: track.naturalSize.height, height: track.naturalSize.width)
            print("Portrait")
            renderOrientation = ImageOrientation.landscapeLeft
        }
    }

}
























