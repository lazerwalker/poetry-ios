import AVFoundation
import Foundation

class BackgroundAudioOutput {
    let engine = AVAudioEngine()

    var nodes:[String:AVAudioPlayerNode] = [:]
    var hasOutput:Bool = false

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
        // TODO: Try to reuse existing node?
        if let node = self.playSound(sound.name) {
            startEngineIfNotRunning()
            node.volume = 1.0
            node.play()

            nodes[sound.name] = node
        }
    }

    func stopSoundscape(sound:Audio) {
        if let node = nodes[sound.name] {
            node.stop()
        }
    }

    func fadeInSoundscape(sound:Audio) {
        if let node = self.playSound(sound.name) {
            startEngineIfNotRunning()
            node.play()

            NSTimer.scheduledTimerWithTimeInterval(0.1, repeats: true) { (timer) in
                node.volume = node.volume + 0.05
                if node.volume >= sound.volume {
                    timer.invalidate()
                }
            }

            nodes[sound.name] = node
        }
    }

    func fadeOutSoundscape(sound:Audio) {
        if let node = nodes[sound.name] {
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
