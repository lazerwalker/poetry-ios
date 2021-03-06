import AVFoundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var generator:PoetryGenerator?
    var locationSensor = LocationSensor()
    var timeSensor = TimeSensor()

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayback)       

        let calculator = InputCalculator(location: locationSensor, time: timeSensor)
        let generator = PoetryGenerator(calculator: calculator)

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard = UIStoryboard(name: "MainViewController", bundle: NSBundle.mainBundle())
        let vc = storyboard.instantiateInitialViewController() as? MainViewController
        vc?.generator = generator
        window?.rootViewController = vc
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

}

