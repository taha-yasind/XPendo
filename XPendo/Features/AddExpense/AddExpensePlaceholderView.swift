import SwiftUI

struct AddExpensePlaceholderView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add Expense")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(XPendoTheme.primaryText)

                        Text("Phase 1 connects the sheet and establishes the visual direction. The real form comes in Phase 3.")
                            .font(.subheadline)
                            .foregroundStyle(XPendoTheme.secondaryText)
                    }

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)
                            .frame(width: 44, height: 44)
                            .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(XPendoTheme.cardBorder, lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Planned Fields")
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)

                        PlaceholderFieldRow(label: "Title", systemImage: "textformat")
                        PlaceholderFieldRow(label: "Amount", systemImage: "creditcard")
                        PlaceholderFieldRow(label: "Date", systemImage: "calendar")
                        PlaceholderFieldRow(label: "Category", systemImage: "tag")
                        PlaceholderFieldRow(label: "Note", systemImage: "note.text")
                    }
                }

                PlaceholderCard(
                    title: "Validation and Save Are Deferred",
                    systemImage: "checkmark.circle",
                    description: "The real input rules, save action, and persistence are intentionally not implemented in Phase 1.",
                    accentColor: XPendoTheme.freshGreen
                )

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Primary Action Placeholder")
                            .font(.headline)
                            .foregroundStyle(XPendoTheme.primaryText)

                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(XPendoTheme.accentTeal)
                            .frame(height: 58)
                            .overlay {
                                HStack {
                                    Text("Save Expense")
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    Spacer()

                                    Text("Phase 3")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(.white.opacity(0.18), in: Capsule())
                                }
                                .padding(.horizontal, 18)
                            }

                        Text("This visual placeholder keeps the sheet aligned with the design guide without pretending that saving already works.")
                            .font(.subheadline)
                            .foregroundStyle(XPendoTheme.secondaryText)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .background(XPendoTheme.background.ignoresSafeArea())
    }
}

private struct PlaceholderFieldRow: View {
    let label: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(XPendoTheme.accentTeal.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: systemImage)
                        .foregroundStyle(XPendoTheme.accentTeal)
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(XPendoTheme.primaryText)

                SkeletonLine(width: 150, height: 10)
            }

            Spacer()
        }
        .padding(16)
        .background(XPendoTheme.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview {
    AddExpensePlaceholderView()
}
