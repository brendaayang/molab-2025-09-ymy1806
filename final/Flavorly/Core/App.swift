//
//  App.swift
//  Flavorly
//
//  Created by Brenda Yang on 9/24/25.
//

import SwiftUI

private let appAssembler: AppAssembler = {
    return AppAssembler()
}()

// MARK: - AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    private let appAppearanceService: AppAppearanceServiceProtocol
    
    override init() {
        self.appAppearanceService = appAssembler.resolver.resolve(AppAppearanceServiceProtocol.self)!
        super.init()
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Configure app appearance globally
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.flavorlyCream)
        
        let titleFont = UIFont(name: "SuperBakery", size: 34)
        
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.flavorlyPink),
            .font: titleFont ?? UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.flavorlyPink),
            .font: titleFont?.withSize(20) ?? UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        
        let navBar = UINavigationBar.appearance()
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        navBar.compactScrollEdgeAppearance = appearance
        navBar.tintColor = UIColor(Color.flavorlyPink)
        
        // Set global accent color for the entire app
        UIView.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor(Color.flavorlyPink)
        
        self.appAppearanceService.configureTabBarAppearance()
        
        return true
    }
}

// MARK: - Flavorly App
@main
struct FlavorlyMainApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var theme = Theme.shared
    
    init() {
        // Record app login for tracking expired items
        AppLoginService.shared.recordLogin()
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView(coordinator: appAssembler.resolver.resolve(AppRootCoordinator.self)!)
                .preferredColorScheme(.light)
                .environmentObject(self.theme)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "flavorly",
              url.host == "bpd" else { return }
        
        let path = url.pathComponents.dropFirst().joined(separator: "/")
        
        NotificationCenter.default.post(
            name: NSNotification.Name("OpenBPDMode"),
            object: nil,
            userInfo: ["destination": path]
        )
    }
}

