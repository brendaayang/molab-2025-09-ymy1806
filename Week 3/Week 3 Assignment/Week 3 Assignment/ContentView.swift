import SwiftUI

struct ContentView: View {
  // grid config
  private let cols = 32
  private let rows = 32
  private let pad: CGFloat = 12

  // state
  @State private var cells: [Cell] = []

  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Spacer()
        HStack {
          Text("Random Print").font(.headline)
          Button("Shuffle") { regenerate() }
            .buttonStyle(.borderedProminent)
        }
        Spacer()
      }
      .padding(.top, 60)

      GeometryReader { _ in
        Canvas { ctx, size in
          // background
          ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.white))

          guard !cells.isEmpty else { return }

          let w = size.width  - pad * 2
          let h = size.height - pad * 2
          let cw = w / CGFloat(cols)
          let ch = h / CGFloat(rows)

          for i in 0..<cells.count {
            let r = i / cols
            let c = i % cols
            let rect = CGRect(x: pad + CGFloat(c) * cw,
                              y: pad + CGFloat(r) * ch,
                              width: cw, height: ch)

            var p = Path()
            switch cells[i].dir {
              case .forward: // "\"
                p.move(to: rect.origin)
                p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
              case .back:    // "/"
                p.move(to: CGPoint(x: rect.maxX, y: rect.minY))
                p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            }

            let style = StrokeStyle(lineWidth: cells[i].weight, lineCap: .round)
            ctx.stroke(p, with: .color(cells[i].color), style: style)
          }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .onAppear { if cells.isEmpty { regenerate() } }
      }
      .frame(minHeight: 420)

      Text("Tap Shuffle to regenerate • arrays + random numbers")
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding(.bottom, 8)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemBackground))
    .ignoresSafeArea()
  }

  // MARK: - Model + data
  struct Cell {
    enum Dir { case forward, back }
    let dir: Dir
    let color: Color
    let weight: CGFloat
  }

  /// Fill the cells array with random slashes/colors/weights
  private func regenerate() {
    let palette: [Color] = [
      .black, .gray.opacity(0.9),
      .blue.opacity(0.85), .purple.opacity(0.85),
      .orange.opacity(0.9), .pink.opacity(0.9)
    ]

    cells = (0..<(cols * rows)).map { _ in
      let dir: Cell.Dir = Bool.random() ? .forward : .back
      let color = palette.randomElement() ?? .black
      let weight = CGFloat([1.5, 2.0, 2.5, 3.0].randomElement()!) // cast to CGFloat
      return Cell(dir: dir, color: color, weight: weight)
    }
  }
}

#Preview { ContentView() }
