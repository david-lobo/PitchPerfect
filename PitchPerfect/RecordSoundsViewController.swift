//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by david lobo on 03/03/2016.
//  Copyright © 2016 David Lobo. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    // Disabled state means no action possible
    enum RecordingState {
        case Inactive, Recording, Paused, NoPermission
    }
    
    var recordingState: RecordSoundsViewController.RecordingState!
    
    //Declared Globally
    var audioRecorder:AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    
    // Displayed in label
    let recordingInProgressText = "Recording in Progress"
    let recordingInactiveText = "Tap to Record"
    let recordingPausedText = "Recording Paused"
    let recordingPermissionsText = "Recording not permitted"
    
    // MARK: IB Outlet
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    // MARK: View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the initial recording state
        recordingState = RecordSoundsViewController.RecordingState.Inactive
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewWillAppear(animated: Bool) {
        updateUI()
        
        // Set the pause/resume button images
        pauseButton.setImage(UIImage(named: "pause_80_blue"), forState: .Normal)
        resumeButton.setImage(UIImage(named: "resume_80_blue"), forState: .Normal)
        pauseButton.setImage(UIImage(named: "pause_80_grey"), forState: .Disabled)
        resumeButton.setImage(UIImage(named: "resume_80_grey"), forState: .Disabled)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    // MARK:Audio Recorder Delegate
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
    }
    
    // MARK: Audio recording
    
    func startRecording() {
        recordingState = RecordingState.Recording
        
        // getting the file path - always use same file name and overwrite previous recording
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let recordingName = "my_audio.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        let session = AVAudioSession.sharedInstance()
        
        do {
        
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
            
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            
        } catch {
            print("Error setting up recording \(error)")
        }
        
        updateUI()
    }
    
   func stopRecording() {
        recordingState = RecordingState.Inactive
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func pauseRecording() {
        recordingState = RecordingState.Paused
        
        // Pause audio recording
        audioRecorder.pause()

        updateUI()
    }
    
    func resumeRecording() {
        recordingState = RecordingState.Recording
        
        // do tha audio recording
        audioRecorder.record()
        
        updateUI()
    }
    
    // MARK: UI Methods
    
    func updateUI() {
        
        // Update the buttons and labels based on the recording state
        if let recordingState = recordingState {
            switch recordingState {
            case RecordingState.Inactive:
                
                // Update the status label
                recordingInProgress.text = recordingInactiveText
                recordingInProgress.sizeToFit()
                
                // // make the relevant buttons active/visible
                stopButton.hidden = true
                pauseButton.hidden = true
                resumeButton.hidden = true
                recordButton.enabled = true
                break
            case RecordingState.Paused:
                
                // Update the status label
                recordingInProgress.text = recordingPausedText
                recordingInProgress.sizeToFit()
                
                // make the relevant buttons active/visible
                pauseButton.enabled = false
                resumeButton.enabled = true
                break
            case RecordingState.Recording:
                
                // Update the status label
                recordingInProgress.text = recordingInProgressText
                recordingInProgress.sizeToFit()
                recordingInProgress.hidden = false
                
                // make the relevant buttons active/visible
                pauseButton.enabled = true
                resumeButton.enabled = false
                stopButton.hidden = false
                pauseButton.hidden = false
                resumeButton.hidden = false
                
                // animate until state changes
                animateRecordButton()
                break
                
            case RecordingState.NoPermission:
                
                // Update the status label
                recordingInProgress.text = recordingPermissionsText
                recordingInProgress.sizeToFit()
                recordingInProgress.hidden = false
                
                // make the relevant buttons active/visible
                pauseButton.enabled = false
                resumeButton.enabled = false
                stopButton.hidden = true
                pauseButton.hidden = true
                resumeButton.hidden = true
                recordButton.enabled = true
                
                break
            }
        }
    }
    
    func animateRecordButton() {
        
        // Fade animation will repeat until recording state changes from 'Recording'
        recordButton.fadeInAndOut(1.0, delay: 0.0, finished: { return self.recordingState == RecordingState.Recording } , completion: { _ in })
    }
    
    //MARK: IB Action
    
    @IBAction func changeRecordingState(sender: UIButton) {
        print(recordingState)
        if recordingState == RecordingState.Inactive {
            
            // Making sure the user has granted permission before recording
            if AVAudioSession.sharedInstance().recordPermission() == AVAudioSessionRecordPermission.Granted {
                startRecording()
            } else {
            
            // Request permission or display permission message on screen
                AVAudioSession.sharedInstance().requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        if allowed {
                            self.startRecording()
                        } else {
                            self.recordingState = RecordingState.NoPermission
                            self.updateUI()
                        }
                    }
                }
            }
        } else if recordingState == RecordingState.Recording {
            pauseRecording()
        } else if recordingState == RecordingState.Paused {
            resumeRecording()
        }
    }
    
    @IBAction func stop(sender: UIButton) {
        stopRecording()
    }
    
    @IBAction func pause(sender: UIButton) {
        pauseRecording()
    }
    
    @IBAction func resume(sender: UIButton) {
        resumeRecording()
    }
}
