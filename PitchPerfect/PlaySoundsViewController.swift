//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by david lobo on 04/03/2016.
//  Copyright © 2016 David Lobo. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    var audioPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    // MARK: View Controller
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        do {
            // init audio player with saved audio file
            try audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
            audioPlayer.enableRate = true
            
            audioEngine = AVAudioEngine()
            // init audio file with saved audio file
            try audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl)
            
        } catch {
            print("Error playing audio: \(error)")
        }
        
        //Set the shared instance audio session category to Playback:
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch { print("session.setCategory not set to Playback.") }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
        // MARK: Audio playing
    
    func playAudio(rate: Float) {
        
        // Stop audio before playing as recommended
        stopAudio()
        
        audioPlayer.rate = rate
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
    }
    
    func stopAudio() {
        
        // Stop audio player
        audioPlayer.stop()
        
        //Stop and reset the audio engine
        audioEngine.stop()
        audioEngine.reset()
    }
    
    func playAudioWithVariablePitch(pitch: Float) {
        
        // create the variable pitch effect
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        playAudioWithEffect(changePitchEffect)
    }
    
    func playAudioWithEffect(effect: AVAudioUnit) {
        
        stopAudio()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(effect)

        audioEngine.connect(audioPlayerNode, to: effect, format: nil)
        audioEngine.connect(effect, to: audioEngine.outputNode, format: nil)
        
        audioEngine.prepare()
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        do {
        
            try audioEngine.start()
        
            audioPlayerNode.play()
        } catch {
            print("Audio playback error \(error)")
        }
    }
    
    // MARK: IB Action
    
    @IBAction func playSlowAudio(sender: UIButton) {
        playAudio(0.5)
    }
    
    @IBAction func playFastAudio(sender: UIButton) {
        playAudio(1.5)
    }
    
    @IBAction func stopPlaying(sender: UIButton) {
        stopAudio()
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playDarthvaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func playReverb() {
        
        // create the reverb effect
        let changePitchEffect = AVAudioUnitReverb()
        changePitchEffect.loadFactoryPreset(.Cathedral)
        changePitchEffect.wetDryMix = 50
        
        playAudioWithEffect(changePitchEffect)
    }
    
    @IBAction func playEcho() {
        
        // create the echo effect
        let echoEffect = AVAudioUnitDistortion()
        echoEffect.loadFactoryPreset(.MultiEcho2)
        echoEffect.wetDryMix = 50
        
        playAudioWithEffect(echoEffect)
    }
}
