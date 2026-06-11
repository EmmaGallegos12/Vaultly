import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Preferencia de moneda compartida
    @AppStorage("currencyCode") private var currencyCode: String = "USD"

    // Estados del formulario
    @State private var title: String = ""
    @State private var amount: Double = 0.0
    @State private var category: String = "Otros"
    @State private var isExpense: Bool = true
    @State private var date: Date = Date()

    // Estados de recurrencia
    @State private var isRecurring: Bool = false
    @State private var recurrenceFrequency: RecurrenceFrequency = .monthly

    // Listas dinámicas de categorías
    private let expenseCategories = ["Vivienda", "Alimentación", "Transporte", "Entretenimiento", "Salud", "Otros"]
    private let incomeCategories = ["Salario", "Ventas", "Inversiones", "Regalo", "Otros"]

    var body: some View {
        NavigationStack {
            Form {
                // 1. Selector de tipo de movimiento (Top)
                Picker("Tipo de movimiento", selection: $isExpense) {
                    Text("Gasto").tag(true)
                    Text("Ingreso").tag(false)
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .onChange(of: isExpense) {
                    // Reiniciar categoría al cambiar de tipo para evitar inconsistencias
                    category = "Otros"
                }

                Section(header: Text("Detalles del movimiento")) {
                    TextField("Concepto", text: $title)

                    // Formato de moneda dinámico basado en Settings
                    TextField("Monto", value: $amount, format: .currency(code: currencyCode))

                    DatePicker("Fecha", selection: $date, displayedComponents: .date)

                    Picker("Categoría", selection: $category) {
                        ForEach(isExpense ? expenseCategories : incomeCategories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }

                Section(header: Text("Recurrencia")) {
                    Toggle("Movimiento recurrente", isOn: $isRecurring)

                    if isRecurring {
                        Picker("Frecuencia", selection: $recurrenceFrequency) {
                            ForEach(RecurrenceFrequency.allCases.filter { $0 != .none }) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
            .animation(.spring(), value: isRecurring)
            .padding()
            .frame(minWidth: 400, minHeight: 450)
            .navigationTitle("Nueva Transacción")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { saveTransaction() }
                        .disabled(title.isEmpty || amount <= 0)
                }
            }
        }
    }

    private func saveTransaction() {
        let newTransaction = Transaction(
            title: title,
            amount: amount,
            date: date,
            category: category,
            isExpense: isExpense,
            isRecurring: isRecurring,
            recurrenceFrequency: isRecurring ? recurrenceFrequency : .none
        )

        withAnimation {
            modelContext.insert(newTransaction)
            dismiss()
        }
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
