//
//  DashboardView.swift
//  Vaultly
//
//  Created by Emmanuel Gallegos on 07/06/26.
//
import SwiftUI
import SwiftData
import Charts

struct ExpenseCategorySummary: Identifiable {
    let category: String
    let amount: Double

    var id: String { category }
}

struct DashboardView: View {
    var transactions: [Transaction]
    @AppStorage("currencyCode") private var currencyCode: String = "USD"

    // Calcula el dinero disponible basado en transacciones pasadas o presentes (<= hoy)
    var totalBalance: Double {
        let startOfTomorrow = Calendar.current.startOfTomorrow
        let relevantTransactions = transactions.filter { $0.date < startOfTomorrow }
        let income = relevantTransactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
        let expenses = relevantTransactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
        return income - expenses
    }

    // Filtra las transacciones futuras (> hoy) y las ordena
    var upcomingTransactions: [Transaction] {
        let startOfTomorrow = Calendar.current.startOfTomorrow
        return transactions
            .filter { $0.date >= startOfTomorrow }
            .sorted { $0.date < $1.date }
    }

    // Agrupa los gastos pasados o presentes por categoría para alimentar la gráfica.
    var expenseCategorySummaries: [ExpenseCategorySummary] {
        let startOfTomorrow = Calendar.current.startOfTomorrow
        let expenses = transactions.filter { transaction in
            transaction.isExpense && transaction.date < startOfTomorrow
        }

        let groupedAmounts = Dictionary(grouping: expenses, by: \.category)
            .mapValues { categoryTransactions in
                categoryTransactions.reduce(0) { $0 + $1.amount }
            }

        return groupedAmounts
            .map { ExpenseCategorySummary(category: $0.key, amount: $0.value) }
            .sorted { lhs, rhs in
                if lhs.amount == rhs.amount {
                    return lhs.category < rhs.category
                }

                return lhs.amount > rhs.amount
            }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // SECCIÓN 1: Balance Total
                VStack(spacing: 8) {
                    Text("Dinero Disponible")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text(totalBalance, format: .currency(code: currencyCode))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(totalBalance >= 0 ? .primary : .red)
                }
                .padding(.vertical, 30)
                .frame(maxWidth: .infinity)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(16)

                // SECCIÓN 2: Distribución de gastos por categoría
                VStack(alignment: .leading, spacing: 16) {
                    Text("Gastos por categoría")
                        .font(.title2)
                        .fontWeight(.bold)

                    if expenseCategorySummaries.isEmpty {
                        VStack {
                            Image(systemName: "chart.pie")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                                .padding(.bottom, 8)
                            Text("Aún no hay gastos para graficar.")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 220)
                        .background(Color.secondary.opacity(0.05))
                        .cornerRadius(12)
                    } else {
                        Chart(expenseCategorySummaries) { summary in
                            SectorMark(
                                angle: .value("Monto", summary.amount),
                                innerRadius: .ratio(0.58),
                                angularInset: 2
                            )
                            .foregroundStyle(by: .value("Categoría", summary.category))
                        }
                        .chartLegend(position: .bottom, alignment: .center)
                        .frame(height: 260)
                        .padding()
                        .background(Color.secondary.opacity(0.05))
                        .cornerRadius(12)
                    }
                }

                // SECCIÓN 3: Agenda Financiera (Pagos Programados)
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
                                UpcomingTransactionRow(transaction: transaction)
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
}

/// Sub-vista para las filas de pagos programados
struct UpcomingTransactionRow: View {
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

                // Mostrar cuántos días faltan
                HStack(spacing: 4) {
                    Text(transaction.date, style: .relative)
                        .foregroundColor(.blue)

                    Text("restantes")
                        .foregroundColor(.secondary)
                }
                .font(.caption)
            }

            Spacer()

            Text(transaction.amount, format: .currency(code: currencyCode))
                .fontWeight(.bold)
                .foregroundColor(transaction.isExpense ? .red : .green)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(10)
    }
}

private extension Calendar {
    var startOfTomorrow: Date {
        date(byAdding: .day, value: 1, to: startOfDay(for: Date())) ?? Date()
    }
}
