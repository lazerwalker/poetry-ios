import AVFoundation
import Foundation

class BackgroundAudioOutput {
    let engine = AVAudioEngine()

    var nodes:[String:AVAudioPlayerNode] = [:]
    var hasOutput:Bool = false

    var regionSpecific:Audio?

    func pauseAll() {
        engine.pause()
    }

    func playAll() {
        startEngineIfNotRunning()
    }

    func stopAll() {
        engine.stop()
    }

    //-
    func playSoundscape(sound:Audio) {
        if let node = loadOrQueueNode(sound) {
            if node.playing { return }
            print("Playing \(sound.name)")
            startEngineIfNotRunning()
            node.volume = sound.volume
            node.play()

            nodes[sound.name] = node

            if sound.regionSpecific {
                regionSpecific = sound
            }
        }
    }

    func stopSoundscape(sound:Audio) {
        if let node = nodes[sound.name] {
            node.stop()
        }
    }

    func fadeInSoundscape(sound:Audio) {
        if sound.regionSpecific {
            if let previous = regionSpecific {
                if previous.name == sound.name {
                    return
                } else {
                    fadeOutSoundscape(previous)
                }
            }
        }

        if let node = loadOrQueueNode(sound) {
            if node.playing { return }
            print("Fading in \(sound.name)")

            startEngineIfNotRunning()
            node.play()

            if sound.regionSpecific {
                regionSpecific = sound
            }

            NSTimer.scheduledTimerWithTimeInterval(0.1, repeats: true) { (timer) in
                node.volume = node.volume + 0.05
                if node.volume >= sound.volume {
                    timer.invalidate()
                }
            }
        }
    }

    func fadeOutSoundscape(sound:Audio) {
        if let node = nodes[sound.name] {
            print("Fading out \(sound.name)")

            NSTimer.scheduledTimerWithTimeInterval(0.1, repeats: true) { (timer) in
                node.volume = node.volume - 0.05
                if node.volume <= 0 {
                    timer.invalidate()
                    self.stopSoundscape(sound)
                }
            }
        }
    }

    //-
    func loadOrQueueNode(sound:Audio) -> AVAudioPlayerNode? {
        var node:AVAudioPlayerNode?
        if let theNode = nodes[sound.name] {
            node = theNode
        } else {
            if let theNode = self.playSound(sound.name) {
                node = theNode
                nodes[sound.name] = node
            }
        }
        return node
    }

    func startEngineIfNotRunning() {
        if (!engine.running && hasOutput) {
            do {
                try engine.start()
            } catch let e as NSError {
                print("Couldn't start engine", e)
            }
        }
    }

    func playSound(file:String, withExtension ext:String = "mp3") -> AVAudioPlayerNode? {
        do {
            if let url = NSBundle.mainBundle().URLForResource(file, withExtension: ext, subdirectory: "Audio") {
                let file = try AVAudioFile(forReading: url)
                let buffer = AVAudioPCMBuffer(PCMFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
                try file.readIntoBuffer(buffer)

                let node = AVAudioPlayerNode()
                engine.attachNode(node)

                node.volume = 0.0
                engine.connect(node, to: engine.mainMixerNode, format: buffer.format)

                node.scheduleBuffer(buffer, atTime: nil, options: .Loops, completionHandler: nil)

                self.hasOutput = true

                return node
            } else {
                return nil
            }
        } catch let e as NSError {
            print("Couldn't find or play audio '\(file)'", e)
        }
        return nil
    }

}
