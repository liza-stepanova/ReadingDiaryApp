import Foundation
import UIKit

enum UIConstants {
    
    enum Images {
        static let coverPlaceholder: UIImage? = UIImage(systemName: "book.closed")
    }
    
    enum Search {
        static let placeholder = "Название или автор"
    }
    
    enum BookGrid {
        static let columns: Int = 2
        
        enum Size {
            static let estimatedHeight: CGFloat = 300
        }
        
        enum Spacing {
            static let itemHorizontal: CGFloat = 8
            static let itemVertical: CGFloat = 0
            static let row: CGFloat = 16
            static let sectionInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 16, trailing: 8)
        }
    }
    
    enum BookCard {
        enum Spacing {
            static let vertical: CGFloat = 4
            static let horizontal: CGFloat = 8
        }
        
        enum Size {
            static let imageHeightMultiplier: CGFloat = 1.5
            static let iconHeight: CGFloat = 20
            static let iconWidth: CGFloat = 20
        }
        
    }
    
    enum Font {
        static let h0: UIFont = .systemFont(ofSize: 20, weight: .semibold)
        static let h1: UIFont = .systemFont(ofSize: 18, weight: .bold)
        static let h2: UIFont = .systemFont(ofSize: 16, weight: .medium)
        static let h3: UIFont = .systemFont(ofSize: 12, weight: .regular)
        
        static let text1: UIFont = .systemFont(ofSize: 14, weight: .regular)
        static let text2: UIFont = .systemFont(ofSize: 12, weight: .light)
    }
    
    enum Shadow {
        static let radius: CGFloat = 9
        static let opacity: Float = 0.12
        static let offset: CGSize = CGSize(width: 0, height: -4)
    }
    
}
