import SwiftUI

struct CalculatorScreenView: View {
    // Placeholder state for UI scaffolding.
    @State private var displayText: String = "0"

    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    private let buttons: [[String]] = [
        ["C", "±", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["0", ".", "=", ""]
    ]

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Display
                VStack(alignment: .trailing, spacing: 8) {
                    Text(" ")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(displayText)
                        .font(.system(size: 56, weight: .semibold, design: .rounded))
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .accessibilityLabel("Calculator display")
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)

                // Buttons grid (placeholder interactions)
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<buttons.count, id: \.self) { row in
                        ForEach(0..<buttons[row].count, id: \.self) { col in
                            let label = buttons[row][col]
                            if label.isEmpty {
                                Color.clear
                                    .frame(height: 56)
                            } else {
                                CalculatorButton(
                                    title: label,
                                    style: style(for: label)
                                ) {
                                    // Placeholder behavior: append digits, basic clear
                                    handleTap(label)
                                }
                            }
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(16)
        }
    }

    private func style(for label: String) -> CalculatorButton.Style {
        if ["+", "−", "×", "÷", "="].contains(label) {
            return .operatorButton
        }
        if ["C", "±", "%"].contains(label) {
            return .utility
        }
        return .digit
    }

    private func handleTap(_ label: String) {
        // Minimal placeholder behavior to keep the UI interactive.
        switch label {
        case "C":
            displayText = "0"
        case "±":
            if displayText.hasPrefix("-") {
                displayText.removeFirst()
            } else if displayText != "0" {
                displayText = "-" + displayText
            }
        case "%":
            // Placeholder: no-op for now
            break
        case "+", "−", "×", "÷", "=":
            // Placeholder: no-op for now
            break
        case ".":
            if !displayText.contains(".") {
                displayText = displayText == "0" ? "0." : (displayText + ".")
            }
        default:
            // Digits
            if displayText == "0" {
                displayText = label
            } else {
                // Prevent runaway length in the placeholder
                if displayText.count < 16 {
                    displayText += label
                }
            }
        }
    }
}

private struct CalculatorButton: View {
    enum Style {
        case digit
        case utility
        case operatorButton

        var background: Color {
            switch self {
            case .digit: return Color(.secondarySystemBackground)
            case .utility: return Color(.tertiarySystemBackground)
            case .operatorButton: return Color.blue.opacity(0.9)
            }
        }

        var foreground: Color {
            switch self {
            case .operatorButton: return .white
            default: return .primary
            }
        }
    }

    let title: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 56)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(style.background)
        .foregroundStyle(style.foreground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        .accessibilityLabel("Button \(title)")
    }
}

#Preview {
    CalculatorScreenView()
}
