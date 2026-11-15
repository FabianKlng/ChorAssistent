import SwiftUI

// MARK: Karte

struct CardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Theme.staffLine.opacity(0.7), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
}

extension View {
    func card(padding: CGFloat = 16) -> some View {
        modifier(CardModifier(padding: padding))
    }

    /// Papierhintergrund für Listen und Formulare.
    func paperBackground() -> some View {
        scrollContentBackground(.hidden).background(Theme.paper)
    }
}

// MARK: Notenlinien

/// Fünf waagrechte Linien wie ein Notensystem – als Zierelement.
struct StaffLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let gap = rect.height / 4
        for index in 0..<5 {
            let y = rect.minY + CGFloat(index) * gap
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        return path
    }
}

// MARK: Abschnittstitel

struct SectionHeader: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(title.uppercased())
                .font(.system(.caption, design: .serif, weight: .semibold))
                .tracking(1.6)
                .foregroundStyle(Theme.gold)
            Rectangle()
                .fill(Theme.staffLine)
                .frame(height: 1)
        }
        .accessibilityAddTraits(.isHeader)
    }
}

// MARK: Ton-Chips

struct ToneChips: View {
    enum Style {
        case compact
        case large
        case stage
    }

    let pitches: [Int]
    var style: Style = .compact

    var body: some View {
        FlowLayout(spacing: style == .compact ? 4 : 8) {
            ForEach(Array(pitches.enumerated()), id: \.offset) { _, midi in
                Text(NoteName.name(midi: midi))
                    .font(font)
                    .monospacedDigit()
                    .padding(.horizontal, style == .compact ? 8 : 14)
                    .padding(.vertical, style == .compact ? 3 : 7)
                    .foregroundStyle(foreground)
                    .background(background, in: Capsule())
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Töne: \(NoteName.names(pitches))")
    }

    private var font: Font {
        switch style {
        case .compact: return .system(.caption, design: .rounded, weight: .semibold)
        case .large: return .system(.title3, design: .rounded, weight: .semibold)
        case .stage: return .system(.title, design: .rounded, weight: .bold)
        }
    }

    private var foreground: Color {
        style == .stage ? Theme.stageGold : Theme.bordeaux
    }

    private var background: Color {
        style == .stage ? Theme.stageGold.opacity(0.16) : Theme.bordeaux.opacity(0.1)
    }
}

// MARK: Umbrechendes Layout

/// Ordnet Elemente nebeneinander an und bricht bei Platzmangel um.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(maxWidth: proposal.width ?? .infinity, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let arrangement = arrange(maxWidth: bounds.width, subviews: subviews)
        for (index, position) in arrangement.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(maxWidth: CGFloat, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var widest: CGFloat = 0
        var positions: [CGPoint] = []
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            widest = max(widest, x - spacing)
        }
        return (CGSize(width: widest, height: y + rowHeight), positions)
    }
}

// MARK: Gedrückt-Effekt

struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: Hinweis-Karte

struct HintCard: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(Theme.gold)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.serif(.headline, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Theme.inkSecondary)
            }
            Spacer(minLength: 0)
        }
        .card()
    }
}
