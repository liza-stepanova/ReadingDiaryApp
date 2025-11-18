enum ReadingStatus: String, CaseIterable, Equatable {
    
    case none = "none"
    case reading = "reading"
    case done = "done"
    
    var menuTitle: String {
        switch self {
        case .none:
            return "Не прочитано"
        case .reading:
            return "Читаю"
        case .done:
            return "Прочитано"
        }
    }

    var iconName: String {
        switch self {
        case .none:
            return "line.3.horizontal"
        case .reading:
            return "book"
        case .done:
            return "checkmark.circle"
        }
    }
    
}
