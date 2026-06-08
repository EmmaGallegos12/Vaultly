import Foundation
import SwiftData

@Model
final class Transaction: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var amount: Double
    var date: Date
    var category: String
    var isExpense: Bool
    // NUEVA PROPIEDAD: Indica si el movimiento ya se completó (true) o está programado (false)
    var isPaid: Bool = true

    init(id: UUID = UUID(), title: String, amount: Double, date: Date = Date(), category: String, isExpense: Bool = true, isPaid: Bool = true) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.isExpense = isExpense
        self.isPaid = isPaid
    }
}

// MARK: - Mock Data
extension Transaction {
    static let mocks: [Transaction] = [
        // Transacciones ya pagadas (Historial)
        Transaction(title: "Sueldo", amount: 3500.0, date: Date().addingTimeInterval(-86400 * 2), category: "Salario", isExpense: false, isPaid: true),
        Transaction(title: "Supermercado", amount: 150.50, date: Date().addingTimeInterval(-86400), category: "Alimentación", isExpense: true, isPaid: true),
        
        // Transacciones programadas (Futuro)
        Transaction(title: "Alquiler", amount: 1200.0, date: Date().addingTimeInterval(86400 * 3), category: "Vivienda", isExpense: true, isPaid: false),
        Transaction(title: "Pago de Tarjeta", amount: 450.0, date: Date().addingTimeInterval(86400 * 5), category: "Finanzas", isExpense: true, isPaid: false)
    ]
}
