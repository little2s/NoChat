//
//  SoundManager.swift
//  NoChat-Swift-Example
//
//  Copyright (c) 2016-present, little2s.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import AudioToolbox

class SoundManager {
    
    private var loadedSoundSamples: Dictionary<String, SystemSoundID> = [:]
    private var soundPlayed: Dictionary<String, CFAbsoluteTime> = [:]
    
    static let manager = SoundManager()
    
    func playSound(name: String, vibrate: Bool) {
        DispatchQueue.main.async {
            if UIApplication.shared.applicationState != .active {
                return
            }
            
            let lastTimeSoundPlayed = self.soundPlayed[name] ?? 0
            
            let currentTime = CFAbsoluteTimeGetCurrent()
            if currentTime - lastTimeSoundPlayed < 0.25 {
                return
            }
            
            self.soundPlayed[name] = currentTime
            
            var soundId: SystemSoundID = 0
            
            if let value = self.loadedSoundSamples[name] {
                soundId = value
            } else {
                guard let resourcePath = Bundle.main.resourcePath else {
                    return
                }
                let path = resourcePath + "/" + name
                let url = URL(fileURLWithPath: path, isDirectory: false)
                
                
                AudioServicesCreateSystemSoundID(url as CFURL, &soundId)
                
                self.loadedSoundSamples[name] = soundId
            }
            
            AudioServicesPlaySystemSound(soundId)
            
            if vibrate {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }
    
}
