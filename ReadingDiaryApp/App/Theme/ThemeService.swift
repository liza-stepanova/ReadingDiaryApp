import UIKit

protocol ThemeServiceProtocol {
    var currentTheme: AppTheme { get }
    func apply(theme: AppTheme)
}

final class ThemeService: ThemeServiceProtocol {
    
    private let storageKey = "app_theme"
    private let userDefaults: UserDefaults
    private weak var window: UIWindow?
    
    private(set) var currentTheme: AppTheme = .system
    
    init(window: UIWindow, userDefaults: UserDefaults = .standard) {
        self.window = window
        self.userDefaults = userDefaults
        
        if let stored = userDefaults.value(forKey: storageKey) as? Int,
           let theme = AppTheme(rawValue: stored) {
            currentTheme = theme
        } else {
            currentTheme = .system
        }
        
        apply(theme: currentTheme)
    }
    
    func apply(theme: AppTheme) {
        currentTheme = theme
        userDefaults.set(theme.rawValue, forKey: storageKey)
        updateInterfaceStyle()
    }
    
    private func updateInterfaceStyle() {
        let style: UIUserInterfaceStyle
        switch currentTheme {
        case .system:
            style = .unspecified
        case .light:
            style = .light
        case .dark:
            style = .dark
        }
        
        window?.overrideUserInterfaceStyle = style
    }
    
}
