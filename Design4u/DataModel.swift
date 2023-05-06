

import SwiftUI

@MainActor
class DataModel: ObservableObject {
    @Published var people = [Person]()
    
    // Навыки которые выбраны пользователем
    @Published var tokens = [Skill]()
    
    // Все навыки из которых можно выбирать
    private var allSkills = [Skill]()
    
    @Published var searchText = ""
    
    @Published private(set) var selected = [Person]()
    
    
    
    var searchResults: [Person] {
        let setTokens = Set(tokens)
        
        return people.filter { person in
            
            // Вначале проверяем, соответствует ли человек установленным токенам, а дальше фильтруем
            guard person.skills.isSuperset(of: setTokens) else { return false }
            
            guard selected.contains(person) == false else { return false }
            
            // Основной фильтр
            guard searchText.isEmpty == false else { return true }
            
            for string in [person.firstName, person.lastName, person.bio, person.details] {
                if string.localizedCaseInsensitiveContains(searchText) {
                    return true
                }
            }
            return false
        }
    }
    
    var suggestedTolens: Binding<[Skill]> {
        if searchText.starts(with: "#") {
            return .constant(allSkills)
        } else {
            return .constant([])
        }
    }
    
    func fetch() async throws {
        let url = URL(string: "https://hws.dev/designers.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        people = try JSONDecoder().decode([Person].self, from: data)
        
        // преобразование всего массива в массив навыков
        allSkills = Set(people.map(\.skills).joined()).sorted()
    }
    
    
    // добавление и удаление людей из списка избранных
    
    func select(_ person: Person) {
        selected.append(person)
    }
    
    func remove(_ person: Person) {
        if let index = selected.firstIndex(of: person) {
            selected.remove(at: index)
        }
    }
    
}
