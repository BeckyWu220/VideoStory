//
//  SelectImportViewController.swift
//  StorytellingVideo
//
//  Created by Wanqiao Wu on 2016-12-09.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

import UIKit

class SelectImportViewController: UIViewController {
    
    public var albumBtn: UIButton
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        albumBtn = UIButton(frame: CGRect(x: (self.view.frame.size.width - 100)/2, y: (self.view.frame.size.height - 30)/2, width: 100, height: 30))
        albumBtn.setTitle("Album", for: UIControlState.normal)
        albumBtn.backgroundColor = UIColor.gray
        self.view.addSubview(albumBtn)
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
