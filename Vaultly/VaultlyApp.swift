import SwiftUI
import SwiftData

@main
struct VaultlyApp: App {
    var body: some Scene {
        WindowGroup {
            // Esta es tu vista principal
            ContentView()
        }
        // Este modificador es CRUCIAL. Inicializa la base de datos
        // y le dice a la app que guarde los modelos de tipo 'Transaction'
        .modelContainer(for: Transaction.self)
    }
}
