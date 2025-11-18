enum ReadingStatus: Int, CaseIterable, Equatable {
    
    case none
    case reading
    case done

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
