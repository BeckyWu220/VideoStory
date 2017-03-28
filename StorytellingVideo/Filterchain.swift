//
//  FilterChain.swift
//  Randomizer
//
//  Created by Leo Stefansson on 22.12.2016.
//  Copyright © 2016 Generate Software Inc. All rights reserved.
//

import GPUImage2Hybridity
import AVFoundation
import Photos // We need this to save videos


public class FilterChain {
    let fbSize = Size(width: 1080, height: 1920)
    var camera:Camera!
    var renderView:RenderView!
    
    // Still image capture
    let pictureOutput = PictureOutput()
    
    // Video capture
    var movieOutput : MovieOutput? = nil
    var isRecording = false
    var fileURL: URL? = nil
    
    // Filters
    let saturationFilter = SaturationAdjustment()
    let pixellateFilter = Pixellate()
    let dotFilter = PolkaDot()
    let invertFilter = ColorInversion()
    let halftoneFilter = Halftone()
    //    let blendFilter = AlphaBlend()
    let swirlFilter = SwirlDistortion()
    let dilationFilter = Dilation()
    
    let erosionFilter = Erosion()
    let lowPassFilter = LowPassFilter()
    let highPassFilter = HighPassFilter()
    let cgaColorspaceFilter = CGAColorspaceFilter()
    let kuwaharaFilter = KuwaharaFilter()
    let posterizeFilter = Posterize()
    let vignetteFilter = Vignette()
    let zoomBlurFilter = ZoomBlur()
    let polarPizellateFilter = PolarPixellate()
    let pinchDistortionFilter = PinchDistortion()
    let sphereRefractionFilter = SphereRefraction()
    let glassSphereRefractionFilter = GlassSphereRefraction()
    let embossFilter = EmbossFilter()
    let toonFilter = ToonFilter()
    let thresholdSketchFilter = ThresholdSketchFilter()
    let tiltShiftFilter = TiltShift()
    let iOSBlurFilter = iOSBlur()
    let solarizeFilter = Solarize()
    
    
    var filters: [BasicOperation] = [BasicOperation]() // All available filters, casting as superclass to hold all filters in an array
    var activeFilters: [BasicOperation] = [BasicOperation]() // Currently active filters
    var numFilters = 7 // Number of filters in chain
    
    public func initFilters() {
        filters = [saturationFilter, pixellateFilter, dotFilter, invertFilter, halftoneFilter, /*blendFilter,*/ swirlFilter, dilationFilter, erosionFilter, /*lowPassFilter, highPassFilter,*/ cgaColorspaceFilter, kuwaharaFilter, posterizeFilter, vignetteFilter, zoomBlurFilter, polarPizellateFilter, pinchDistortionFilter, sphereRefractionFilter, glassSphereRefractionFilter, embossFilter, toonFilter, thresholdSketchFilter, /*ShiftFilter, iOSBlurFilter,*/ solarizeFilter]
        var i = 0
        while i<numFilters {
            activeFilters.append(filters[i])
            i+=1
        }
        
    }
    
    // Start the filter chain
    public func start() {
        initFilters()
    }
    
    // Pass the view from the ViewController
    public func startCameraWithView(view: RenderView) {
        do {
            renderView = view
            camera = try Camera(sessionPreset:AVCaptureSessionPreset640x480)
            camera.runBenchmark = false
            //            camera.delegate = self
            
            rebuildChain()
            camera.startCapture()
            
        } catch {
            fatalError("Could not initialize rendering pipeline: \(error)")
        }
        
    }
    
    // Remove all targets from every filterchain element
    private func teardownChain() {
        camera.stopCapture()
        // Remove all targets from currently active filters and camera
        camera.removeAllTargets()
        
        // Remove targets from active filters
        var index = 0
        for _ in activeFilters {
            print("removing target from filter at index \(index)")
            activeFilters[index].removeAllTargets()
            index+=1
        }

    }
    
    // Put the filterchain elements back together
    private func rebuildChain() {
        camera --> activeFilters[0]
        var i = 0
        
        while i<numFilters-1 {
            activeFilters[i] --> activeFilters[i+1]
            i+=1
        }
        activeFilters[numFilters-1] --> renderView
        activeFilters[numFilters-1] --> pictureOutput
        if (movieOutput != nil) {
            activeFilters[numFilters-1] --> movieOutput!
        }
        
    }
    
    public func randomizeFilterChain() {
        print("RANDOMIZING")
        teardownChain()
        // Remove active filters from array
        //activeFilters.removeAll(keepingCapacity: true)

        // Select new active filters
        
        for index in 0..<numFilters {
            let randNum = uniqueRandomIndex()
            activeFilters[index] = filters[randNum]
        }
        print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++-")
        print("Current filter chain:")
        for filter in activeFilters {
            print(filter)
        }
        
        rebuildChain()
        camera.startCapture()
    }
    
    // Return a random filter index
    private func randomIndex() -> Int {
        let count = filters.count
        
        let randNum = Int(arc4random_uniform(UInt32(count)))
        //        print("diceRoll: \(randNum)")
        return randNum
    }
    
    // Return a unique filter index (a filter that is not already in the chain)
    private func uniqueRandomIndex() -> Int {
        var index = 0
        var alreadySelected = true
        
        while alreadySelected {
            index = randomIndex()
            var hits = 0
            print("Trying to find unique number, current \(hits) hits")
            let newFilterName = type(of:filters[index])//object_getClassName(filters[index])
            print("----------------------------------------------------------------------------")
            print("index \(index)")
            for filter in activeFilters {
                let activeFilterName = type(of:filter)//object_getClassName(filter)
                print("comparing \(newFilterName) to \(activeFilterName)")
                if (newFilterName == activeFilterName) {
                    hits = hits+1
                    print("hits \(hits)")
                }
            }
            if (hits == 0) {
                alreadySelected = false
                // Leave the while loop
            }
            
        }
        return index
    }
    
    public func captureStill() {
        print("FC -> Capture Still")
        
        pictureOutput.encodedImageFormat = .png
        pictureOutput.imageAvailableCallback = {image in
        print("FC -> image available callback")
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    // Video Capture toggle (start/stop)
    public func startVideoCapture() {
        print("FC -> Start Capture Video")
        
        if (!isRecording) {
            do {
                self.isRecording = true
                let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
                self.fileURL = URL(string:"test.mp4", relativeTo:documentsDir)!
                do {
                    try FileManager.default.removeItem(at:self.fileURL!)
                } catch {
                }
                print("Here comes the URL...")
                print(self.fileURL?.absoluteString ?? "no file URL found!")
                movieOutput = try MovieOutput(URL:fileURL!, size:Size(width:480, height:640), liveVideo:true)
                camera.audioEncodingTarget = movieOutput
                activeFilters[numFilters-1] --> movieOutput!
                movieOutput!.startRecording()
                DispatchQueue.main.async {
                    // Label not updating on the main thread, for some reason, so dispatching slightly after this
                    //(sender as! UIButton).titleLabel!.text = "Stop"
                }
            } catch {
                fatalError("Couldn't initialize movie, error: \(error)")
            }
        } else {
            movieOutput?.finishRecording{
                print("FC -> Video recording finished")
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.fileURL!)
                }, completionHandler: { success, error in
                    print("Done saving video, with or without error.")
                    //print("Saving URL: \(self.fileURL)")
                })

                self.isRecording = false
                DispatchQueue.main.async {
                  //  (sender as! UIButton).titleLabel!.text = "Record"
                }
                self.camera.audioEncodingTarget = nil
                self.movieOutput = nil
            }
        }
    }
        
    
    // TODO Callback and error handling for captureStill()
    dynamic func didSaveStillImage() {
        print("Saved image")
    }
//    dynamic func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//        if let error = error {
//            // we got back an error!
//            print("FC -> There was a problem saving the image.")
//        } else {
//            print("FC -> Image saved successfully")
//        }
//    }
    
    
    func getFilterChainLength() -> Int{
        return numFilters
    }
    
    func setFilterChainLength(newLength: Int){
        //check ceiling and floor
        if (newLength > filters.count){
            numFilters = filters.count
        }
        else if (newLength <= 0){
            numFilters = 1
        }
        else{
            numFilters = newLength
        }
        
        //rebuild chain
        rebuildChain()
        
        
    }
    
    
    func removeFilterAtIndex(index: Int){
        //Stop Camera Capture
        camera.stopCapture()
        
        //Remove specified target at index
        activeFilters.remove(at: index)
        
        // Decrement Number Filter
        setFilterChainLength(newLength: numFilters-1)
        
        //Rebuild Chain
        rebuildChain()
        
        //Start camera capture
        camera.startCapture()
    }
    
    //    func appendFilter(filter:BasicOperation){
    func appendFilter(filter:Int){
        //Stop Camera Capture
        camera.stopCapture()
        
        //Add to end of active filters
        //        activeFilters.append(filter)
        activeFilters.append(filters[filter])
        
        //Increment Number filter
        setFilterChainLength(newLength: numFilters+1)
        
        //Rebuild Chain
        rebuildChain()
        
        //Start camera capture
        camera.startCapture()
    }
}
