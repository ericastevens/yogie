//
//  VideoPreviewViewController.swift
//  Yogie
//
//  Created by Erica Y Stevens on 4/25/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos

class VideoPreviewViewController: UIViewController {
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        self.updatePlayButtonTitle()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        self.saveVideoToLibrary()
    }
    
    static let assetKeysRequiredToPlay = ["playable", "hasProtectedContent"]
    
    var fileLocation: URL? {
        didSet {
            self.asset = AVURLAsset(url: self.fileLocation!)
        }
    }
    
    let player = AVPlayer()
    var asset: AVURLAsset? {
        didSet {
            guard let newAsset = asset else { return }
            self.loadAssetURL(newAsset)
        }
    }
    var playerLayer: AVPlayerLayer? {
        return playerView.playerLayer
    }
    var playerItem: AVPlayerItem? {
        didSet{
            player.replaceCurrentItem(with: self.playerItem)
            player.actionAtItemEnd = .pause
        }
    }

    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.playerView.playerLayer.player = player
        
        addObserver(self, forKeyPath: "player.currentItem.status", options: .new, context: nil) //KVO
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerReachedEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil) //When AVPLayerItem reaches endpoint, it fires a notification
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObserver(self, forKeyPath: "player.currentItem.status")
    }
    
    // MARK: Main
    
    func loadAssetURL(_ asset: AVURLAsset) {
        asset.loadValuesAsynchronously(forKeys: VideoPreviewViewController.assetKeysRequiredToPlay) { 
            DispatchQueue.main.async {
                guard asset == self.asset else { return }
                
                for key in VideoPreviewViewController.assetKeysRequiredToPlay {
                    var error: NSError?
                    
                    if !asset.isPlayable || asset.hasProtectedContent {
                        let message = "Unable to play video"
                        
                        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                        alertController.addAction(okayAction)
                        self.present(alertController, animated: true, completion: nil)
                        
                        return
                    }
                    
                    if asset.statusOfValue(forKey: key, error: &error) == .failed {
                        let message = "Failed to load"
                        
                        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                        alertController.addAction(okayAction)
                        self.present(alertController, animated: true, completion: nil)
                        
                        return
                    }
                }
                self.playerItem = AVPlayerItem(asset: asset)
            }
        }
    }
    
    // MARK: Callbacks
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "player.currentItem.status" {
            self.playVideoButton.isHidden = false
            self.saveButton.isHidden = false
        }
    }
    
    func playerReachedEnd(_ notification: NSNotification) {
        self.asset = AVURLAsset(url: self.fileLocation!)
        self.playVideoButton.setTitle("Play Again", for: .normal)
    }
    
    // MARK: Helpers
    
    func saveVideoToLibrary() {
       PHPhotoLibrary.shared().performChanges({ 
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.fileLocation!)
        }) { (saved, error) in
            if saved {
                let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func updatePlayButtonTitle() {
        if player.rate > 0 {
            //playing
            player.pause()
            self.playVideoButton.setTitle("Play", for: .normal)
        } else {
            //paused/stopped
            player.play()
            self.playVideoButton.setTitle("Pause", for: .normal)
        }
    }
}
