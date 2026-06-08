//
//  DashboardView.swift
//  Vaultly
//
//  Created by Emmanuel Gallegos on 07/06/26.
//
import SwiftUI
import SwiftData

struct DashboardView: View {
    var transactions: [Transaction]
    
    // Calcula el dinero disponible SOLO tomando en cuenta lo que ya está pagado (isPaid == true)
    var totalBalance: Double {
        let paidTransactions = transactions.filter { $0.isPaid }
        let income = paidTransactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
        let expenses = paidTransactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
        return income - expenses
    }
    
    // Filtra las transacciones pendientes y las ordena de la más próxima a la más lejana
    var upcomingTransactions: [Transaction] {
        transactions
            .filter { !$0.isPaid }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // SECCIÓN 1: Balance Total
                VStack(spacing: 8) {
                    Text("Dinero Disponible")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(totalBalance, format: .currency(code: "USD"))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(totalBalance >= 0 ? .primary : .red)
                }
                .padding(.vertical, 30)
                .frame(maxWidth: .infinity)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(16)
                
                // SECCIÓN 2: Agenda Financiera (Pagos Programados)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Próximos movimientos")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if upcomingTransactions.isEmpty {
                        // Mensaje de estado vacío
                        VStack {
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                                .padding(.bottom, 8)
                            Text("No tienes pagos programados pendientes.")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 150)
                        .background(Color.secondary.opacity(0.05))
                        .cornerRadius(12)
                    } else {
                        // Lista de próximos pagos
                        VStack(spacing: 12) {
                            ForEach(upcomingTransactions) { transaction in
                                upcomingTransactionRow(transaction)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Mi Resumen")
    }
    
    // Sub-vista para las filas de pagos programados
    @ViewBuilder
        private func upcomingTransactionRow(_ transaction: Transaction) -> some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.title)
                        .font(.headline)
                    
                    // Mostrar cuántos días faltan usando HStack en lugar del operador '+'
                    HStack(spacing: 4) {
                        Text(transaction.date, style: .relative)
                            .foregroundColor(.blue)
                        
                        Text("restantes")
                            .foregroundColor(.secondary)
                    }
                    .font(.caption) // Aplicamos la fuente a todo el grupo de una vez
                }
                
                Spacer()
                
                Text(transaction.amount, format: .currency(code: "USD"))
                    .fontWeight(.bold)
                    .foregroundColor(transaction.isExpense ? .red : .green)
            }
            .padding()
            .background(Color.secondary.opacity(0.05))
            .cornerRadius(10)
        }
}
