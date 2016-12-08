//
//  VideoSectionView.swift
//  StorytellingVideo
//
//  Created by Wanqiao Wu on 2016-12-07.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

import UIKit

protocol VideoSectionDelegate {
    func tappedVideoSection(videoSection: VideoSectionView)
}

class VideoSectionView: UIView {
    
    var delegate : VideoSectionDelegate!
    public var videoIcon : UIImageView?
    public var containVideo : Bool?
    public var videoURL : URL?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        videoIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        videoIcon?.image = UIImage(named: "videoBg")
        self.addSubview(videoIcon!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(VideoSectionView.beTapped))
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beTapped(){
        print("Be Tapped")
        delegate.tappedVideoSection(videoSection: self)
    }

}
