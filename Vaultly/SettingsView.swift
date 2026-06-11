import SwiftUI

struct SettingsView: View {
    // Persistencia automática de la preferencia de moneda
    @AppStorage("currencyCode") private var currencyCode: String = "USD"

    var body: some View {
        Form {
            Section(header: Text("Preferencias Locales")) {
                Picker("Moneda", selection: $currencyCode) {
                    ForEach(CurrencyCode.allCases) { currency in
                        Text(currency.label).tag(currency.rawValue)
                    }
                }
                .pickerStyle(.menu)
            }

            Section(header: Text("Información")) {
                HStack {
                    Text("Versión")
                    Spacer()
                    Text("1.1.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Configuración")
        .frame(minWidth: 300, minHeight: 200)
    }
}

#Preview {
    SettingsView()
}
