//
//  FilterViewController.swift
//  StorytellingVideo
//
//  Created by Wanqiao Wu on 2017-03-11.
//  Copyright © 2017 Wanqiao Wu. All rights reserved.
//

import UIKit
import GPUImage
import AssetsLibrary
import AVFoundation

class FilterViewController: UIViewController {
    
    var renderView: RenderView!
    var videoAsset: AVAsset?
    
    init(videoURL: URL) {
        
        videoAsset = AVURLAsset(url: videoURL)
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        let videoSize = videoAsset?.tracks(withMediaType: AVMediaTypeVideo).first?.naturalSize
        
        renderView = RenderView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width*(videoSize?.height)!/(videoSize?.width)!))
        self.view.addSubview(renderView)
        
        do {
            let movie = try MovieInput(asset: videoAsset!, playAtActualSpeed: true, loop: false)
            let filter = Pixellate()
            movie --> filter --> renderView
            movie.start()
            print("RenderView Sources: \(renderView)")
        } catch {
            fatalError("Could not initialize rendering pipeline: \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
