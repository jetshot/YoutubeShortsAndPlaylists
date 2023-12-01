//
//  ViewController.swift
//  FullScreen
//
//  Created by yawa on 12/1/23.
//

import UIKit
import MSPeekCollectionViewDelegateImplementation
import youtube_ios_player_helper
class ViewController: UIViewController {
    @IBOutlet weak var learningVidShortsCollectionView: UICollectionView!
    var behavior: MSCollectionViewPeekingBehavior!
    var index: Int = 0
    var isDataLoaded = false
    var videoItems: [Item] = []
    private var currentVisibleIndex = IndexPath(row: 0, section: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        learningVidShortsCollectionView?.register(LearningVideosShortsPlayerCollectionViewCell.self)


        //Set 1 for full screen
        behavior = MSCollectionViewPeekingBehavior(cellSpacing: 0, cellPeekWidth: 0, minimumItemsToScroll: 1, maximumItemsToScroll: 1, scrollDirection: .vertical)
        learningVidShortsCollectionView.configureForPeekingBehavior(behavior: behavior)
        learningVidShortsCollectionView.delegate = self
        learningVidShortsCollectionView.dataSource = self
        videoItems = [
            Item(id: "IAiXxoxwNqE"),
            Item(id: "m8Qc608i6wY"),
            Item(id: "l2aj_dGDVr0"),
            Item(id: "DUiWzgHA-qI"),
        ]
        learningVidShortsCollectionView.reloadData()
        learningVidShortsCollectionView.isPagingEnabled = true
        self.isDataLoaded = true
        initNotifObserver()
    }

    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }


    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            self.learningVidShortsCollectionView.reloadData()
        }, completion: { context in
            self.learningVidShortsCollectionView.scrollToItem(at: IndexPath(row: self.index, section: 0), at: .top, animated: false)
        })
    }

    func initNotifObserver(){
        NotificationCenter.default.addObserver(
            forName: Notification.Name("learningShortVidPlayerReady"),
            object: nil, queue: nil
        ) { [weak self] notification in
            if let userInfo = notification.userInfo,
               let indexPath = userInfo["indexPath"] as? IndexPath,
               let visibleIndex = self?.currentVisibleIndex,
               indexPath == visibleIndex,
               let cell = self?.learningVidShortsCollectionView.cellForItem(at: visibleIndex) as? LearningVideosShortsPlayerCollectionViewCell {
                cell.ytview.playVideo()
            }
        }
    }


}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isDataLoaded ? videoItems.count : 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LearningVideosShortsPlayerCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LearningVideosShortsPlayerCollectionViewCell", for: indexPath) as! LearningVideosShortsPlayerCollectionViewCell
            cell.loadedVideo(
                video: videoItems[indexPath.row],
                forIndexPath: indexPath
            )
            return cell
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //Auto pause video
        if let playerCell = cell as? LearningVideosShortsPlayerCollectionViewCell {
            playerCell.ytview?.pauseVideo()
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //Auto play video by getting current visible index
        currentVisibleIndex = indexPath

        if let playerCell = cell as? LearningVideosShortsPlayerCollectionViewCell, playerCell.isPlayerViewReady {
            playerCell.ytview.playVideo()
        }
    }
}


//For paging while layout orientation changes
extension ViewController: UIScrollViewDelegate {
    func getCurrentVisibleIndex() -> IndexPath? {
        let centerPoint = CGPoint(x: learningVidShortsCollectionView.bounds.midX, y: learningVidShortsCollectionView.bounds.midY)
        return learningVidShortsCollectionView.indexPathForItem(at: centerPoint)
    }

    func getCurrentPage() -> Int? {
        guard let visibleIndex = getCurrentVisibleIndex() else {
            return nil
        }

        return visibleIndex.row
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == learningVidShortsCollectionView {
            if let currentPage = getCurrentPage() {
                index = currentPage
            } else {
                print("Unable to determine the current page")
            }
        }
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_ type: T.Type) {
        let nib = UINib(nibName: String(describing: type), bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: type.identifier)
    }

    func registerWithID<T: UICollectionViewCell>(_ type: T.Type) {
        self.register(T.self, forCellWithReuseIdentifier: T.identifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T? {
        return self.dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T
    }
}

extension UIView {
    
    @objc class var identifier: String{
        return String(describing: self)
    }

}
