//
//  UCollectionViewCell.swift
//  FullScreen
//
//  Created by yawa on 12/1/23.
//

import UIKit
import youtube_ios_player_helper

struct Item {
    var id: String!
}

class LearningVideosShortsPlayerCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var ytview: YTPlayerView!
    var isPlayerViewReady: Bool = false
    private var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ytview.delegate = self
    }

    func loadedVideo(video: Item?, forIndexPath: IndexPath) {
        indexPath = forIndexPath
        if let video {
            ytview?.load(withVideoId: video.id!)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update constraints based on the new orientation
        self.contentView.layoutIfNeeded()
        if self.ytview != nil {
            self.ytview.layoutIfNeeded()
        }
    }
}

extension LearningVideosShortsPlayerCollectionViewCell: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        isPlayerViewReady = true
        NotificationCenter.default.post(
            name: Notification.Name("learningShortVidPlayerReady"), object: nil,
            userInfo: ["indexPath": indexPath ?? [:]]
        )
    }

    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
        return .clear
    }
}

