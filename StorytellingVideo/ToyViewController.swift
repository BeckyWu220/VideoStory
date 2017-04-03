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
//import GPUImage
import AssetsLibrary
import AVFoundation
import GPUImage2Hybridity

class ToyViewController: UIViewController, UINavigationControllerDelegate {
    
    var filterChain = FilterChain()
    let filterView = RenderView(frame: UIScreen.main.bounds)
    
    var delegate: SelectImportVCDelegate!
    
    public var albumBtn: UIButton?
    var captureBtn : UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Toy"
        
        self.view.addSubview(filterView)
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.touchEventRecognizer (_:)))
        self.filterView.addGestureRecognizer(gesture)
        
        captureBtn = createVideoCaptureButton()
        captureBtn?.addTarget(self, action: #selector(videoCaptureButtonAction(sender:)), for: .touchUpInside)
        self.view.addSubview(captureBtn!)
        
        filterChain.start()
        filterChain.startCameraWithView(view: filterView)
        
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
    
    func createVideoCaptureButton() -> UIButton{
        let bSize = 72; // This should be an even number
        let loc = CGRect(x: Int(UIScreen.main.bounds.width/2)-(bSize/2)+bSize*2, y: Int(UIScreen.main.bounds.height)-Int(UIScreen.main.bounds.height/7), width: bSize, height: bSize)
        let captureButton = UIButton(frame: loc)
        
        captureButton.setTitle("V", for: .normal)
        captureButton.backgroundColor = .red
        // Make the button round
        captureButton.layer.cornerRadius = 0.5 * captureButton.bounds.size.width
        captureButton.clipsToBounds = true
        return captureButton
    }
    
    func videoCaptureButtonAction(sender: UIButton!) {
        print("Video Capture Button tapped")
        // Start capturing video
        filterChain.captureVideo()
        
        // Update UI elements to indicate that we are recording
        if (filterChain.isRecording) {
            self.captureBtn?.backgroundColor = .green
        }
        else {
            // Not recording, but not done saving either...i
            print("Setting video capture button color to yellow")
            self.captureBtn?.backgroundColor = .yellow
        }
        
        // Check if video is done saving
        filterChain.videoDidSave = { result, fileURL in
            print("ViewController -> videoCaptureButtonAction -> filterChain.videoDidSave result:  \(result)")
            if result {
                print("Video Saved Successfully at \(fileURL)")
            }
            else {
                print("There was a problem saving the video.")
            }
            
            // Update UI elements
            print("Setting video capture button color to red")
            // Put UI updating on the main queue to prevent a delay
            DispatchQueue.main.async {
                self.captureBtn?.backgroundColor = .red
                
                let asset = AVURLAsset(url: fileURL)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let image : UIImage = try! UIImage(cgImage: imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil))
                self.delegate.setThumbnailForVideoSection(image: image, videoURL: fileURL, videoPath: fileURL.path)
                
                //Switch back to ViewController View.
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // Touch recognizer action
    func touchEventRecognizer(_ sender:UITapGestureRecognizer){
        // do other task
        print("Touch Event!!!, randomizing filter")
        filterChain.randomizeFilterChain()
        //        filterChain.removeFilterAtIndex(index: tempFilterNum)
        //        tempFilterNum-=1;
        
        //        filterChain.appendFilter(filter: tempFilterNum)
        //        tempFilterNum+=1;
        
        //print("tempFilterNum", tempFilterNum);
        
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
























