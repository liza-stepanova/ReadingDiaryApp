enum AppTab: CaseIterable {
    
    case catalog
    case favorite
    case myBooks
    case profile

    var title: String {
        switch self {
        case .catalog: return "Каталог"
        case .favorite: return "Любимые"
        case .myBooks: return "Мои книги"
        case .profile: return "Профиль"
        }
    }

    var systemImageName: String {
        switch self {
        case .catalog: return "books.vertical"
        case .favorite: return "heart"
        case .myBooks: return "book"
        case .profile: return "person"
        }
    }
    
    var selectedImageName: String {
        switch self {
        case .catalog: return "books.vertical.fill"
        case .favorite: return "heart.fill"
        case .myBooks: return "book.fill"
        case .profile: return "person.fill"
        }
    }
    
}
