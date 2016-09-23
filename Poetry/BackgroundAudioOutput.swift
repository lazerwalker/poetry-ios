import AVFoundation
import Foundation

class BackgroundAudioOutput {
    let engine = AVAudioEngine()

    var nodes:[String:AVAudioPlayerNode] = [:]

    func playSoundscape(name:String) {
        // TODO: Try to reuse existing node?
        if let node = self.playSound(name) {
            startEngineIfNotRunning()
            node.volume = 1.0
            node.play()

            nodes[name] = node
        }
    }

    func stopSoundscape(name:String) {
        if let node = nodes[name] {
            node.stop()
        }
    }

    func pauseSoundscape(name:String) {
        if let node = nodes[name] {
            node.pause()
        }
    }

    func fadeInSoundscape(name:String) {
        if let node = self.playSound(name) {
            startEngineIfNotRunning()
            node.play()

            NSTimer.scheduledTimerWithTimeInterval(0.1, repeats: true) { (timer) in
                node.volume = node.volume + 0.05
                if node.volume >= 1.0 {
                    timer.invalidate()
                }
            }

            nodes[name] = node
        }
    }

    func fadeOutSoundscape(name:String) {
        if let node = nodes[name] {
            NSTimer.scheduledTimerWithTimeInterval(0.1, repeats: true) { (timer) in
                node.volume = node.volume - 0.05
                if node.volume <= 0 {
                    timer.invalidate()
                    self.stopSoundscape(name)
                }
            }
        }
    }

    //-
    func startEngineIfNotRunning() {
        if (!engine.running) {
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
