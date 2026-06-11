import SwiftUI
import SwiftData

private enum SidebarDestination: Hashable {
    case dashboard
    case transactions
    case settings
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    @State private var selection: SidebarDestination? = .dashboard
    @State private var showingAddSheet = false

    var body: some View {
        NavigationSplitView {
            // Barra lateral (Sidebar)
            List(selection: $selection) {
                NavigationLink(value: SidebarDestination.dashboard) {
                    Label("Mi Resumen", systemImage: "chart.pie.fill")
                }
                NavigationLink(value: SidebarDestination.transactions) {
                    Label("Todas las transacciones", systemImage: "tray.full")
                }

                Divider()

                NavigationLink(value: SidebarDestination.settings) {
                    Label("Configuración", systemImage: "gear")
                }
            }
            .navigationTitle("Vaultly")
        } detail: {
            // Vista de detalle: Lista principal de transacciones
            Group {
                if selection == .dashboard {
                    DashboardView(transactions: transactions)
                } else if selection == .transactions {
                    List {
                        ForEach(transactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                        .onDelete(perform: deleteTransactions)
                    }
                    .navigationTitle("Transacciones")
                } else if selection == .settings {
                    SettingsView()
                } else {
                    Text("Selecciona una categoría")
                        .foregroundColor(.secondary)
                }
            }
            .toolbar {
                // El botón "Añadir" no tiene sentido en "Configuración"
                if selection != .settings {
                    ToolbarItem {
                        Button(action: { showingAddSheet = true }) {
                            Label("Añadir", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTransactionView()
        }
        .onAppear {
            RecurrenceManager.processRecurringTransactions(
                context: modelContext,
                transactions: transactions
            )

            // Insertar mocks si está vacío para propósitos de demostración
            #if DEBUG
            if transactions.isEmpty {
                for mock in Transaction.mocks {
                    modelContext.insert(mock)
                }
            }
            #endif
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
    @AppStorage("currencyCode") private var currencyCode: String = "USD"

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(transaction.title)
                        .font(.headline)
                    if transaction.isRecurring {
                        Image(systemName: "arrow.2.squarepath")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
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
        formatter.currencyCode = currencyCode

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
