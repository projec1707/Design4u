
import SwiftUI

extension Animation {
    static var easeInOutBack: Animation {
        Animation.timingCurve(0.5, -0.5, 0.5, 1.5)
    }
    
    static func easyInOutBack(duration: TimeInterval = 0.25) -> Animation {
        Animation.timingCurve(0.5, -0.5, 0.5, 1.5, duration: duration)
    }
}

struct ContentView: View {
    @StateObject private var model = DataModel()
    @Namespace var namespace
    
    @State private var selectedDesigner: Person?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(model.searchResults) { person in
                        DesignerRow(person: person, model: model, namespace: namespace, selectedDesigner: $selectedDesigner)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Designs4u")
            .searchable(text: $model.searchText, tokens: $model.tokens, suggestedTokens: model.suggestedTolens, prompt: Text("Search, or use a # to seleck skills")) { token in
                Text(token.id)
            }
            .sheet(item: $selectedDesigner, content: DesignerDetails.init)
            .safeAreaInset(edge: .bottom) {
                if model.selected.isEmpty == false {
                    VStack {
                        // selected designers
                        HStack(spacing: -10) {
                            ForEach(model.selected) { person in
                                Button {
                                    withAnimation {
                                        model.remove(person)
                                    }
                                } label: {
                                    AsyncImage(url: person.thumbnail, scale: 3)
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.white, lineWidth: 2)
                                        }
                                }
                                .buttonStyle(.plain)
                                .matchedGeometryEffect(id: person.id, in: namespace)
                            }
                        }
                        
                        // continue button
                        NavigationLink {
                            // go to the next screen
                        } label: {
                            Text("Select ^[\(model.selected.count) Person](inflect: true)")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .contentTransition(.identity)
                    }
                    .frame(maxWidth: .infinity)
                    .padding([.horizontal, .top])
                    .background(.ultraThinMaterial)
                }
            }
        }
        .task {
            do {
                try await model.fetch()
            } catch {
                print("Error handling is great!")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
