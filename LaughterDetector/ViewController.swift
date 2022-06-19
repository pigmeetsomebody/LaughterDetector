//
//  ViewController.swift
//  LaughterDetector
//
//  Created by 朱彦谕 on 2021/10/10.
//

import UIKit
import Combine
import SoundAnalysis


class ViewController: UIViewController {
    
    /// The runtime state that contains information about the strength of the detected sounds.
    var appState = AppState()

    /// The configuration that dictates aspects of sound classification, as well as aspects of the visualization.
    var appConfig = AppConfiguration()
    
    @IBOutlet weak var progressIndicator: AquaProgressIndicator!
    
    @IBOutlet weak var levelSlider: UISlider!
    
    @IBOutlet weak var recordBtn: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var soundIdentifier = SoundIdentifier(labelName: "laughter")
        soundIdentifier.displayName = "笑声"
        appConfig.monitoredSounds = [soundIdentifier]
        progressIndicator.addAquaScene()
        progressIndicator.changeWaterLevel(to: 0.0)
        appState.confidenceDidChangedBlock = { [weak self] (results) in
            
            var confidenceValue: Double = 0.0
            results.forEach { (soundIdentifier, detectionState) in
                if soundIdentifier.labelName == "laughter" {
                    confidenceValue = max(confidenceValue, detectionState.currentConfidence)
                    if (self?.threshhold ?? 0.3) <= confidenceValue {
                        self?.view.backgroundColor = UIColor.red
                        self?.recordBtn.setImage(UIImage(systemName: "Play"), for: .normal)
                        self?.titleLabel.text = "检测到笑声😂！！！"
                    } else {
                        self?.view.backgroundColor = UIColor.systemOrange
                        self?.titleLabel.text = "正在检测😂......"
                    }
                }
            }
            self?.progressIndicator.changeWaterLevel(to: CGFloat(confidenceValue))
        
        }
        
        titleLabel.font = UIFont.systemFont(ofSize: 32)
        titleLabel.textAlignment = .center
        titleLabel.text = "笑声😂检测仪"
        self.recordBtn.setTitle("开始检测", for: .normal)
        levelSlider.value = 0.3
    }
    var threshhold: Double = 0.3
    @IBAction func valueDidChange(_ sender: UISlider) {
        //progressIndicator.changeWaterLevel(to: CGFloat(sender.value))
        let value = sender.value * 100
        threshhold = Double(value / 100.0)
        print("valueDidChange: \(threshhold)")
    }
    
    
    var isRunning = false
    @IBAction func didToggleRecordBtn(_ sender: Any) {
        if isRunning {
            self.recordBtn.setImage(UIImage(systemName: "Play"), for: .normal)
            self.recordBtn.setTitle("开始检测", for: .normal)
            titleLabel.text = "笑声😂检测仪"
           
            appState.stopDetection(config: appConfig)
        } else {
            self.recordBtn.setImage(UIImage(systemName: "Pause"), for: .normal)
            self.recordBtn.setTitle("停止🤚", for: .normal)
            appState.restartDetection(config: appConfig)
            self.titleLabel.text = "正在检测😂......"
        }
        isRunning = !isRunning
    }
    
}

