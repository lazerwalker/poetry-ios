import AVFoundation
import Foundation

class BackgroundAudioOutput {
    let engine = AVAudioEngine()

    var nodes:[String:AVAudioPlayerNode] = [:]

    func playSoundscape(name:String) {
        // TODO: Try to reuse existing node?
        if let node = self.playSound(name) {
            if (!engine.running) {
                do {
                    try engine.start()
                } catch let e as NSError {
                    print("Couldn't start engine", e)
                }
            }
            node.play()

            nodes[name] = node
        }
    }

    func stopSoundscape(name:String) {
        if let node = nodes[name] {
            node.stop()
        }
    }

    //-
    func playSound(file:String, withExtension ext:String = "mp3") -> AVAudioPlayerNode? {
        do {
            if let url = NSBundle.mainBundle().URLForResource(file, withExtension: ext, subdirectory: "Audio") {
                let file = try AVAudioFile(forReading: url)
                let buffer = AVAudioPCMBuffer(PCMFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
                try file.readIntoBuffer(buffer)

                let node = AVAudioPlayerNode()
                engine.attachNode(node)
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
