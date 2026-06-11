import Foundation
import SwiftData

enum RecurrenceFrequency: String, CaseIterable, Identifiable {
    case none = "Ninguno"
    case daily = "Diario"
    case weekly = "Semanal"
    case monthly = "Mensual"
    case yearly = "Anual"

    var id: String { rawValue }
}

enum CurrencyCode: String, CaseIterable, Identifiable {
    case usd = "USD"
    case mxn = "MXN"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .usd:
            return "Dólar (USD)"
        case .mxn:
            return "Peso Mexicano (MXN)"
        }
    }
}

@Model
final class Transaction: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var amount: Double
    var date: Date
    var category: String
    var isExpense: Bool

    var isRecurring: Bool = false
    var recurrenceFrequency: String = RecurrenceFrequency.none.rawValue

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        date: Date = Date(),
        category: String,
        isExpense: Bool = true,
        isRecurring: Bool = false,
        recurrenceFrequency: RecurrenceFrequency = .none
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.isExpense = isExpense
        self.isRecurring = isRecurring
        self.recurrenceFrequency = recurrenceFrequency.rawValue
    }
}

// MARK: - Mock Data
extension Transaction {
    static let mocks: [Transaction] = [
        Transaction(title: "Sueldo Mensual", amount: 3500.0, date: Date(), category: "Salario", isExpense: false, isRecurring: true, recurrenceFrequency: .monthly),
        Transaction(title: "Suscripción Gym", amount: 50.0, date: Date(), category: "Salud", isExpense: true, isRecurring: true, recurrenceFrequency: .monthly),
        Transaction(title: "Supermercado", amount: 120.50, date: Date(), category: "Alimentación", isExpense: true, isRecurring: false),
        Transaction(title: "Venta eBay", amount: 200.0, date: Date(), category: "Ventas", isExpense: false, isRecurring: false)
    ]
}
