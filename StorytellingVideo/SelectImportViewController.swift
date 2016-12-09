//
//  SelectImportViewController.swift
//  StorytellingVideo
//
//  Created by Wanqiao Wu on 2016-12-09.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

import UIKit

class SelectImportViewController: UIViewController {
    
    public var albumBtn: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white

        // Do any additional setup after loading the view.
        albumBtn = UIButton(frame: CGRect(x: (self.view.frame.size.width - 100)/2, y: (self.view.frame.size.height - 30)/2, width: 100, height: 30))
        albumBtn?.setTitle("Album", for: UIControlState.normal)
        albumBtn?.addTarget(self, action: #selector(clickAlbumBtn), for: UIControlEvents.touchUpInside)
        albumBtn?.backgroundColor = UIColor.gray
        self.view.addSubview(albumBtn!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clickAlbumBtn() -> Void {
        print("Click Album")
    }

}
