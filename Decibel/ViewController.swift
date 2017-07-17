//
//  ViewController.swift
//  Decibel
//
//  Created by Peter Reinhardt on 8/13/16.
//  Copyright © 2016 Peter Reinhardt. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var peak: UILabel!
    @IBOutlet var average: UILabel!
    
    private var timer: DispatchSourceTimer?

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let url = directoryURL() else {
            print("Unable to find a init directoryURL")
            return
        }
        
        let recordSettings = [
            AVSampleRateKey : NSNumber(value: Float(44100.0) as Float),
            AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC) as Int32),
            AVNumberOfChannelsKey : NSNumber(value: 1 as Int32),
            AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue) as Int32),
            ]
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            let audioRecorder = try AVAudioRecorder(url: url, settings: recordSettings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            try audioSession.setActive(true)
            audioRecorder.isMeteringEnabled = true
            recordForever(audioRecorder: audioRecorder)
        } catch let err {
            print("Unable start recording", err)
        }
    }

    private func directoryURL() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent("sound.m4a")
        return soundURL
    }
    
    private func recordForever(audioRecorder: AVAudioRecorder) {
        let queue = DispatchQueue(label: "io.segment.decibel", attributes: .concurrent)
        timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
        timer?.scheduleRepeating(deadline: .now(), interval: .seconds(1), leeway: .milliseconds(100))
        timer?.setEventHandler { [weak self] in
            audioRecorder.updateMeters()
            
            // NOTE: seems to be the approx correction to get real decibels
            let correction: Float = 100
            let average = audioRecorder.averagePower(forChannel: 0) + correction
            let peak = audioRecorder.peakPower(forChannel: 0) + correction
            self?.displayData(averageLevel: average, peakLevel: peak)
        }
        timer?.resume()
    }
    
    private func displayData(averageLevel: Float, peakLevel: Float) {
        DispatchQueue.main.async {
            self.peak.text = "Peak: \(Int(peakLevel))"
            self.peak.sizeToFit()
            self.average.text = "Average: \(Int(averageLevel))"
            self.average.sizeToFit()
            
        }
    }

}

