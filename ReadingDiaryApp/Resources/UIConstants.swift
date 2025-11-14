import Foundation
import UIKit

enum UIConstants {
    
    enum Font {
        static let h0: UIFont = .systemFont(ofSize: 20, weight: .semibold)
        static let h1: UIFont = .systemFont(ofSize: 18, weight: .bold)
        static let h2: UIFont = .systemFont(ofSize: 16, weight: .medium)
        static let h3: UIFont = .systemFont(ofSize: 10, weight: .regular)
        
        static let text1: UIFont = .systemFont(ofSize: 12, weight: .regular)
        static let text2: UIFont = .systemFont(ofSize: 10, weight: .light)
    }
    
    enum Shadow {
        static let radius: CGFloat = 9
        static let opacity: Float = 0.12
        static let offset: CGSize = CGSize(width: 0, height: -4)
    }
    
}
