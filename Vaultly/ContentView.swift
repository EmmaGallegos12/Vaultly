import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    @State private var selection: String? = "Dashboard"
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationSplitView {
            // Barra lateral (Sidebar)
            List(selection: $selection) {
                NavigationLink(value: "Dashboard") {
                    Label("Mi Resumen", systemImage: "chart.pie.fill")
                }
                NavigationLink(value: "All") {
                    Label("Todas las transacciones", systemImage: "tray.full")
                }
                
            }
            .navigationTitle("Vaultly")
        } detail: {
            // Vista de detalle: Lista principal de transacciones
            if  selection == "Dashboard"{
                DashboardView(transactions: transactions)
            }else if selection == "All" {
                List {
                    ForEach(transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                    .onDelete(perform: deleteTransactions)
                }
                .navigationTitle("Transacciones")
                .toolbar {
                    ToolbarItem {
                        Button(action: { showingAddSheet = true }) {
                            Label("Añadir", systemImage: "plus")
                        }
                    }
                }
            } else {
                Text("Selecciona una categoría")
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTransactionView()
        }
        .onAppear {
            // Insertar mocks si está vacío para propósitos de demostración
            if transactions.isEmpty {
                for mock in Transaction.mocks {
                    modelContext.insert(mock)
                }
            }
        }
    }
    
    private func deleteTransactions(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(transactions[index])
            }
        }
    }
}

/// Una fila personalizada para mostrar detalles de la transacción.
struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.headline)
                Text(transaction.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatAmount(transaction.amount, isExpense: transaction.isExpense))
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(transaction.isExpense ? .red : .green)
                
                Text(transaction.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatAmount(_ amount: Double, isExpense: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return isExpense ? "- \(formatted)" : "+ \(formatted)"
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Transaction.self, configurations: config)
    
    return ContentView()
        .modelContainer(container)
}
