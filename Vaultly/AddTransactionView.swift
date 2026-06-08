import SwiftUI
import SwiftData

struct AddTransactionView: View {
    // Permite interactuar con la base de datos de SwiftData
    @Environment(\.modelContext) private var modelContext
    // Permite cerrar esta ventana modal de forma programática
    @Environment(\.dismiss) private var dismiss
    
    // Estados locales para capturar los datos del formulario
    @State private var title: String = ""
    @State private var amount: Double = 0.0
    @State private var category: String = "General"
    @State private var isExpense: Bool = true
    @State private var date: Date = Date()
    @State private var isPaid: Bool = true
    
    
    // Lista de categorías predefinidas
    let categories = ["General", "Alimentación", "Vivienda", "Salario", "Entretenimiento", "Finanzas"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Detalles del movimiento")) {
                    // Campo para el título
                    TextField("Concepto o título", text: $title)
                    
                    // Selector tipo espejo/segmentado para Gasto o Ingreso
                    Picker("Tipo", selection: $isExpense) {
                        Text("Gasto").tag(true)
                        Text("Ingreso").tag(false)
                    }
                    .pickerStyle(.segmented)
                    
                    // Campo formateado para divisas (Moneda en USD)
                    TextField("Monto", value: $amount, format: .currency(code: "USD"))
                    
                    // Selector de fecha nativo de macOS
                    DatePicker("Fecha", selection: $date, displayedComponents: .date)
                    
                    Toggle("¿Ya está pagado?", isOn: $isPaid)
                    
                    // Selector de categoría
                    Picker("Categoría", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }
            }
            .padding()
            // Dimensiones recomendadas para que se vea cómodo y estético en macOS
            .frame(minWidth: 400, minHeight: 320)
            .navigationTitle("Nueva Transacción")
            .toolbar {
                // Botón para cancelar y cerrar sin guardar
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                // Botón para confirmar y guardar en la base de datos
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveTransaction()
                    }
                    // Validación simple: no deja guardar si no hay título o el monto es 0
                    .disabled(title.isEmpty || amount <= 0)
                }
            }
        }
    }
    
    /// Crea el modelo real con los datos capturados y lo inserta en SwiftData
    private func saveTransaction() {
        let newTransaction = Transaction(
            title: title,
            amount: amount,
            date: date,
            category: category,
            isExpense: isExpense,
            isPaid: isPaid
        )
        
        withAnimation {
            modelContext.insert(newTransaction)
            dismiss() // Cierra la hoja modal automáticamente
        }
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
