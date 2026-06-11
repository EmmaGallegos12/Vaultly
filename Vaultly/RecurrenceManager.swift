import Foundation
import SwiftData

struct RecurrenceManager {
    static func processRecurringTransactions(context: ModelContext, transactions: [Transaction]) {
        let now = Date()
        let calendar = Calendar.current

        let dueTransactions = transactions.filter { transaction in
            transaction.isRecurring && transaction.date < now
        }

        for transaction in dueTransactions {
            guard
                let frequency = RecurrenceFrequency(rawValue: transaction.recurrenceFrequency),
                let nextDate = nextDate(
                    after: transaction.date,
                    frequency: frequency,
                    calendar: calendar
                )
            else {
                transaction.isRecurring = false
                continue
            }

            transaction.isRecurring = false

            let newTransaction = Transaction(
                title: transaction.title,
                amount: transaction.amount,
                date: nextDate,
                category: transaction.category,
                isExpense: transaction.isExpense,
                isRecurring: true,
                recurrenceFrequency: frequency
            )

            context.insert(newTransaction)
        }
    }

    private static func nextDate(
        after date: Date,
        frequency: RecurrenceFrequency,
        calendar: Calendar
    ) -> Date? {
        switch frequency {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date)
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date)
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date)
        case .none:
            return nil
        }
    }
}
