//
//  QuickBiteApp.swift
//  QuickBite
//
//  Created by Angela on 04/11/25.
//
import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseMessaging
import UserNotifications
import FirebaseAuth

@main
struct QuickBiteApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var storeVM = StoreRegistrationViewModel()
    @StateObject private var cart = CartViewModel()
    @StateObject private var calendarManager = CalendarManager()
    @StateObject private var authVM = AuthenticationViewModel()
    @StateObject var navState = AppNavigationState()
    
    
    
    var body: some Scene {
        WindowGroup {
            InitialView()
                .environmentObject(storeVM)
                .environmentObject(cart)
                .environmentObject(calendarManager)
                .environmentObject(authVM)
                .environmentObject(navState)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // A. Configure Firebase
        FirebaseApp.configure()
        
        // B. Configure Push Notifications
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        if let token = fcmToken, let uid = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            db.collection("users").document(uid).setData(["fcmToken": token], merge: true)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // 1. Check if this is a Group Invite
        if let type = userInfo["type"] as? String, type == "group_invite" {
            
            // 2. Get the Order ID
            if let orderId = userInfo["orderId"] as? String {
                print("User tapped invite for Order ID: \(orderId)")
                
                // 3. Broadcast this ID to SwiftUI so we can open the sheet
                NotificationCenter.default.post(name: NSNotification.Name("OpenGroupInvite"), object: nil, userInfo: ["orderId": orderId])
            }
        }
        
        completionHandler()
    }
}

//MARK: Global Firestore Instance

let db = Firestore.firestore()
