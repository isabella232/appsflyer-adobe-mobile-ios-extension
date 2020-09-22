`AppDelegate.swift`

```swift
import UIKit
import ACPCore
import ACPMobileServices
import  ACPAnalytics
import ACPGriffon
import  AppsFlyerAdobeExtension
import ACPUserProfile

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ACPCore.setLogLevel(ACPMobileLogLevel.verbose)
        ACPCore.configure(withAppId: "launch-key")

        
        ACPMobileServices.registerExtension()
        ACPAnalytics.registerExtension()
        ACPGriffon.registerExtension()
        AppsFlyerAdobeExtension.register()
        ACPIdentity.registerExtension()
        ACPLifecycle.registerExtension()
        ACPSignal.registerExtension()
        ACPUserProfile.registerExtension()

        ACPCore.start {
            ACPCore.lifecycleStart(nil)
        }
        
        AppsFlyerAdobeExtension.registerCallbacks({(data: [AnyHashable : Any]) -> () in
             if let callback_type = data["callback_type"] as? String{
                
                 if (callback_type == "onConversionDataReceived"){
                    self.handleDeferredDeeplink(data: data)
                 } else if (callback_type == "onAppOpenAttribution"){
                     self.handleDirectDeeplink(attributionData: data)
                 }
             }
         })
        
        return true
    }
    
    
    func handleDeferredDeeplink(data :[AnyHashable : Any]){
        if let status = data["af_status"] as? String{
              if(status == "Non-organic"){
                  if let sourceID = data["media_source"] , let campaign = data["campaign"]{
                      print("This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                  }
              } else {
                  print("This is an organic install.")
              }
              if let is_first_launch = data["is_first_launch"] , let launch_code = is_first_launch as? Int {
                  if(launch_code == 1){
                      print("First Launch")
                  } else {
                      print("Not First Launch")
                  }
              }
          }
    }
    
    func handleDirectDeeplink(attributionData :[AnyHashable : Any]){
        for (key, value) in attributionData {
            print(key, ":",value)
        }
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }
}

```

`SceneDelegate.swift`


```swift
import UIKit
import AppsFlyerLib
import AppsFlyerAdobeExtension

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            AppsFlyerLib.shared().handleOpen(url, options: nil)
        }
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        // Processing Universal Link from the killed state 
        if let userActivity = connectionOptions.userActivities.first {
          self.scene(scene, continue: userActivity)
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

```

