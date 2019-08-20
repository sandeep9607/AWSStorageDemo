//
//  PlayAudioVC.swift
//  AudioBook
//
//  Created by rootmacmini on 20/08/19.
//  Copyright © 2019 rootmacmini. All rights reserved.
//

import UIKit
import AWSS3
import AVFoundation

class PlayAudioVC: UIViewController {
    
    @IBOutlet weak var lblfileName: UILabel!
    var strFilename = ""
    var SoundData : Data? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblfileName.text = strFilename.removeFileExtension()
        // Do any additional setup after loading the view.
        downloadData(keyname: strFilename)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPlay(_ sender: Any) {
        if SoundData != nil{
            playSound(data: SoundData!)
        }
    }
    
    func downloadData(keyname: String) {
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in DispatchQueue.main.async(execute: {
            // Do something e.g. Update a progress bar.
        })
        }
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        completionHandler = { (task, location, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    NSLog("Failed with error: \(error)")
                    //                    self.statusLabel.text = "Failed"
                }
                else{
                    self.SoundData = data
//                    self.imageView.image = UIImage(data: data!)
                }
                //                print(data!)
                //                else if(self.progressView.progress != 1.0) {
                //                    self.statusLabel.text = "Failed"
                //                }
                //                else{
                //                    self.statusLabel.text = "Success"
                //                    self.imageView.image = UIImage(data: data!)
                //                }
            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.downloadData(
            fromBucket: "audiobook198-ios",
            key: keyname,
            expression: expression,
            completionHandler: completionHandler
            ).continueWith {
                (task) -> AnyObject! in if let error = task.error {
                    print("Error: \(error.localizedDescription)")
                }
                
                if let data = task.result {
                    // Do something with downloadTask.
//                    self.SoundData = data
                }
                return nil;
        }
    }
    
    
    var player: AVAudioPlayer?
    
//    func playSound() {
////        guard let url = Bundle.main.url(forResource: "soundName", withExtension: "mp3") else { return }
//
//
//    }
    
    func playSound(data: Data){
        do {
            player = try AVAudioPlayer(data: data)
            player?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
}
