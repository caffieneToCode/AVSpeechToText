//
//  SpeechToTextViewModel.swift
//  SpeechToText
//
//  Created by Ashish on 28/05/20.
//  Copyright © 2020 Ashish. All rights reserved.
//

import UIKit
import Speech
import Foundation
import RealmSwift

class SpeechToTextViewModel {
    
    var viewController: SpeechToTextViewController?
    var commands: [Command]? {
        didSet {
            DispatchQueue.main.async {
                self.viewController?.commandTableView.reloadData()
            }
        }
    }
    
    private let speechREcognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    func showCommandHistory() {
        audioEngine.isRunning ? (commands = [Command]()) : (commands = DataManager.sharedInstance.getCommands())
    }
    
    func showCommandsContaining(text: String) {
        
        guard !text.isEmpty else {
            showCommandHistory()
            return
        }
        commands = DataManager.sharedInstance.filterCommandsContaining(text: text)
    }
    
    func micButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if audioEngine.isRunning && !sender.isSelected {
            stopListening()
            viewController?.searchTextField.isUserInteractionEnabled = true
            viewController?.view.endEditing(true)
        } else {
            startListening()
            viewController?.searchTextField.text = ""
            viewController?.searchTextField.isUserInteractionEnabled = false
        }
        if let isRecordingLabelHidden = viewController?.recordingLabel.isHidden {
            viewController?.recordingLabel.isHidden = !isRecordingLabelHidden
        }
    }
    
    func store(_ command: Command) {
        DataManager.sharedInstance.add(command)
    }
    
    func requestAuthorization() {
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = false
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            OperationQueue.main.addOperation() {
                self.viewController?.micButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    func startListening() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("ERROR: Couldn't set audioSession properties")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("ERROR: Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechREcognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            if result != nil {
                DispatchQueue.main.async {
                    if let textFromSpeech  = result?.bestTranscription.formattedString {
                        self.showCommandsContaining(text: textFromSpeech)
                        self.viewController?.searchTextField.text = textFromSpeech
                    }
                }
                isFinal = (result?.isFinal)!
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        showCommandHistory()
    }
}
