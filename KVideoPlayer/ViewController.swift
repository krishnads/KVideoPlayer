//
//  ViewController.swift
//  KVideoPlayer
//
//  Created by Apple on 15/05/19.
//  Copyright © 2019 Konstant info Solutions Pvt. Ltd. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    var filterPlayers : [AVPlayer?] = []
    var currentPage: Int = 0
    var filterScrollView : UIScrollView?
    var player: AVPlayer?
    var playerController : AVPlayerViewController?
    var avPlayerLayer : AVPlayerLayer!
    
    var arrayItems = [
        "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupFilterWith(size: self.view!.bounds.size)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }


}


extension ViewController: UIScrollViewDelegate {
    
    func setupFilterWith(size: CGSize)  {
        currentPage = 0
        filterPlayers.removeAll()
        filterScrollView = UIScrollView(frame: UIScreen.main.bounds)
        
        let count = arrayItems.count
        for i in 0...count-1 {
            //Adding image to scroll view
            let imgView : UIView = UIView.init(frame: CGRect(x: CGFloat(i) * size.width, y: 0, width: size.width, height: size.height))
            let imgViewThumbnail: UIImageView = UIImageView.init(frame: imgView.bounds)
            
            //imgView.image =
            imgView.backgroundColor = .clear
            imgViewThumbnail.contentMode = .scaleAspectFit
            imgView.addSubview(imgViewThumbnail)
            imgViewThumbnail.image = getThumbnailImage(forUrl: URL(string: arrayItems[i])!)
            filterScrollView?.addSubview(imgView)
           
            
            //For Multiple player
            
             let player = AVPlayer(url: URL(string: arrayItems[i])!)
             let avPlayerLayer = AVPlayerLayer(player: player)
             avPlayerLayer.videoGravity = .resizeAspect
             avPlayerLayer.masksToBounds = true
             avPlayerLayer.cornerRadius = 5
             avPlayerLayer.frame = imgView.layer.bounds
             imgView.layer.addSublayer(avPlayerLayer)
             filterPlayers.append(player)
            
        }
        filterScrollView?.isPagingEnabled = true
        filterScrollView?.contentSize = CGSize.init(width: CGFloat(arrayItems.count) * size.width, height: size.height)
        filterScrollView?.backgroundColor = .red
        filterScrollView?.delegate = self
        view.addSubview(filterScrollView!)
        
        
        //For Single player
//        player = AVPlayer(url: URL(string: "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4")!)
//        avPlayerLayer = AVPlayerLayer(player: player)
//        avPlayerLayer.videoGravity = .resizeAspect
//        avPlayerLayer.masksToBounds = true
//        avPlayerLayer.cornerRadius = 5
//        avPlayerLayer.frame = view.layer.bounds
//        view.layer.addSublayer(avPlayerLayer)
//        filterPlayers.append(player)
//        if (player != nil) {
//            player!.play()
//        }
        //For Multiple player
        playVideos()
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    func playVideos() {
        for i in 0...filterPlayers.count - 1 {
            playVideoWithPlayer((filterPlayers[i])!)
        }

        for i in 0...filterPlayers.count - 1 {
            if i != currentPage {
                (filterPlayers[i])!.pause()
            }
        }
    }
    
    func playVideoWithPlayer(_ player: AVPlayer) {
        player.play()
    }
    
    //For Single player
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //avPlayerLayer.isHidden = true
        //player?.pause()
    }
    
    //For Single player
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
       // avPlayerLayer.isHidden = false
        //player?.play()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth : CGFloat = (filterScrollView?.frame.size.width)!
        let fractionalPage : Float = Float((filterScrollView?.contentOffset.x)! / pageWidth)
        let targetPage : NSInteger = lroundf(fractionalPage)
        
        if targetPage != currentPage {
            currentPage = targetPage
            
            //For Single player
//            player = AVPlayer(url: URL(string: "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4")!)
//            player?.play()

            
            //For Multiple player
            for i in 0...filterPlayers.count - 1 {
                if i == currentPage {
                    (filterPlayers[i])!.play()
                } else {
                    (filterPlayers[i])!.pause()
                }
            }
        }
        
    }
    
    func playVideoWithPlayer(_ player: AVPlayer, video:AVURLAsset, filterName:String) {
        
        let  avPlayerItem = AVPlayerItem(asset: video)
        
        if (filterName != "NoFilter") {
            let avVideoComposition = AVVideoComposition(asset: video, applyingCIFiltersWithHandler: { request in
                let source = request.sourceImage.clampedToExtent()
                let filter = CIFilter(name:filterName)!
                filter.setDefaults()
                filter.setValue(source, forKey: kCIInputImageKey)
                let output = filter.outputImage!
                request.finish(with:output, context: nil)
            })
            avPlayerItem.videoComposition = avVideoComposition
        }
        
        player.replaceCurrentItem(with: avPlayerItem)
        player.play()
    }
    
    @objc func playerItemDidReachEnd(_ notification: Notification) {
        
        //For Single player
//                player!.seek(to: CMTime.zero)
//                player!.play()
        
        
        //        For Multiple player
                for i in 0...filterPlayers.count - 1 {
                    if i == currentPage {
                        (filterPlayers[i])!.seek(to: CMTime.zero)
                        (filterPlayers[i])!.play()
                    }
                }
    }
    
}
