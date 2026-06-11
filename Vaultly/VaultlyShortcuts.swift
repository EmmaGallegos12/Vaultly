import AppIntents
import Foundation
import OSLog
import SwiftData
import SwiftUI

/// Snippet compacto que Siri/Atajos muestra al confirmar el guardado.
struct QuickTransactionSnippetView: View {
    let amount: Double
    let category: String
    let isSuccess: Bool
    let message: String?

    init(
        amount: Double,
        category: String,
        isSuccess: Bool = true,
        message: String? = nil
    ) {
        self.amount = amount
        self.category = category
        self.isSuccess = isSuccess
        self.message = message
    }

    private var formattedAmount: String {
        amount.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(isSuccess ? Color.green : Color.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text(formattedAmount)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(message ?? "Añadido a \(category)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

/// App Intent para registrar un gasto sin abrir Vaultly.
struct QuickAddTransactionIntent: AppIntent {
    static var title: LocalizedStringResource = "Añadir Gasto Rápido"
    static var description = IntentDescription("Añade una transacción a Vaultly rápidamente")
    static var openAppWhenRun = false
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Vaultly",
        category: "QuickAddTransactionIntent"
    )

    @Parameter(title: "Monto")
    var amount: Double

    @Parameter(title: "Categoría", default: "Otros")
    var category: String

    static var parameterSummary: some ParameterSummary {
        Summary("Añadir \(\.$amount) en \(\.$category)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let normalizedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        let transactionCategory = normalizedCategory.isEmpty ? "Otros" : normalizedCategory

        guard amount > 0 else {
            return .result(
                dialog: "El monto debe ser mayor que cero",
                view: QuickTransactionSnippetView(
                    amount: amount,
                    category: transactionCategory,
                    isSuccess: false,
                    message: "No se guardó el gasto"
                )
            )
        }

        do {
            // El intent crea su propio contenedor y contexto. No reutiliza el ModelContext
            // inyectado en las vistas, porque ese contexto pertenece al ciclo de vida de la UI.
            let schema = Schema([Transaction.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let context = container.mainContext

            let transaction = Transaction(
                title: "Gasto rápido",
                amount: amount,
                date: Date(),
                category: transactionCategory,
                isExpense: true,
                isRecurring: false
            )

            context.insert(transaction)
            try context.save()

            return .result(
                dialog: "Gasto guardado",
                view: QuickTransactionSnippetView(amount: amount, category: transactionCategory)
            )
        } catch {
            Self.logger.error("Quick expense save failed: \(error.localizedDescription, privacy: .public)")

            return .result(
                dialog: "No se pudo guardar el gasto",
                view: QuickTransactionSnippetView(
                    amount: amount,
                    category: transactionCategory,
                    isSuccess: false,
                    message: "Intenta de nuevo desde Vaultly"
                )
            )
        }
    }
}

/// Publica el atajo en la app Atajos con frases sugeridas para Siri.
struct VaultlyShortcutsProvider: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .teal

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: QuickAddTransactionIntent(),
            phrases: [
                "Añadir \(\.$amount) en \(.applicationName)",
                "Registrar \(\.$amount) en \(\.$category) con \(.applicationName)",
                "Guardar \(\.$amount) como gasto en \(.applicationName)"
            ],
            shortTitle: "Añadir gasto",
            systemImageName: "plus.circle.fill"
        )
    }
}
