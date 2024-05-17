//
//  ViewController.swift
//  VideoCachingHLS
//
//  Created by apple on 2024/5/17.
//

import Foundation
import UIKit
import AVFoundation
import GCDWebServer
import PINCache

class ViewController : UIViewController {
    
    var player : AVPlayer!
    var server: HLSCachingReverseProxyServer!
    
    @IBOutlet weak var playbtn: UIButton!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .yellow
        server = HLSCachingReverseProxyServer(webServer: GCDWebServer(), urlSession: URLSession.shared, cache: PINCache.shared)
        server.start(port: 8080)
        
        let playlistURL = URL(string: "https://dzf0mrmgw3o7o.cloudfront.net/videos/3/cmfa/2.m3u8")!
        let reverseProxyURL = server.reverseProxyURL(from: playlistURL)!
        let playerItem = AVPlayerItem(url: reverseProxyURL)
//        let playerItem = AVPlayerItem(url: playlistURL)
        player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds // 将视频画面填充到特定的UIView中
        view.layer.addSublayer(playerLayer)
        player.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        player.currentItem?.preferredForwardBufferDuration = 1
    }
    
    @IBAction func clearCache(_ sender: Any) {
        PINCache.shared.removeAllObjectsAsync({ _ in
           print("&&& - 清理缓存了")
        })
    }
    
    @IBAction func clickPLay(_ sender: Any) {
        player.play()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if player.status == .readyToPlay {
                // 播放器准备好播放
            } else if player.status == .failed {
                // 播放失败
                print("Playback failed: \(player.error)")
            }
        }
    }
}
