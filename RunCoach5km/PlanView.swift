import SwiftUI
import WorkoutKit

struct PlanView: View {
    let athlete: Athlete
    @State private var sessions: [WorkoutSession] = []
    @State private var exportItem: ExportItem?
    @State private var exportAll = false
    @State private var isExporting = false
    @State private var errorMessage: String?

    var grouped: [(Int, [WorkoutSession])] {
        Dictionary(grouping: sessions, by: \.week)
            .sorted { $0.key < $1.key }
    }

    var body: some View {
        List {
            Section {
                athleteHeader
            }

            ForEach(grouped, id: \.0) { week, ws in
                Section("Semana \(week) — \(ws.first.map { phaseLabel(week) } ?? "")") {
                    ForEach(ws) { session in
                        SessionRow(session: session) {
                            exportSingle(session)
                        }
                    }
                }
            }
        }
        .navigationTitle(athlete.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    exportAllWorkouts()
                } label: {
                    Label("Exportar tudo", systemImage: "square.and.arrow.up")
                }
                .disabled(isExporting)
            }
        }
        .sheet(item: $exportItem) { item in
            ShareSheet(items: item.urls)
        }
        .alert("Erro", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear {
            sessions = WorkoutPlanGenerator.generateAll(for: athlete)
        }
    }

    // MARK: - Header

    private var athleteHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            let R = Paces(baseTotalSeconds: athlete.baseTotalSeconds)
            HStack {
                VStack(alignment: .leading) {
                    Text(athlete.name)
                        .font(.title2.bold())
                    Text("Tempo actual: \(athlete.displayTime)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "figure.run")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
            }
            Divider()
            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 4) {
                GridRow {
                    Text("Ritmo base").foregroundStyle(.secondary)
                    Text(R.base.formattedPace).bold()
                    Text("Ritmo conversa").foregroundStyle(.secondary)
                    Text(R.leve.formattedPace).bold()
                }
                GridRow {
                    Text("Objetivo 5km").foregroundStyle(.secondary)
                    Text("\(formatTime(R.objMinSecs))–\(formatTime(R.objMaxSecs)) min").bold()
                    Text("Ritmo prova").foregroundStyle(.secondary)
                    Text("\(R.gMin.formattedPace)–\(R.gMax.formattedPace)").bold()
                }
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Export single

    private func exportSingle(_ session: WorkoutSession) {
        isExporting = true
        Task {
            do {
                let url = try await exportWorkout(session.workout,
                    name: session.workout.displayName)
                await MainActor.run {
                    exportItem = ExportItem(urls: [url])
                    isExporting = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isExporting = false
                }
            }
        }
    }

    // MARK: - Export all

    private func exportAllWorkouts() {
        isExporting = true
        Task {
            do {
                var urls: [URL] = []
                for session in sessions {
                    let url = try await exportWorkout(session.workout,
                        name: session.workout.displayName)
                    urls.append(url)
                }
                await MainActor.run {
                    exportItem = ExportItem(urls: urls)
                    isExporting = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isExporting = false
                }
            }
        }
    }

    // MARK: - Export helper

    private func exportWorkout(_ workout: CustomWorkout, name: String) async throws -> URL {
        let composition = WorkoutComposition(workout)
        let data = try await composition.dataRepresentation()
        let safeName = name
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "")
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(safeName).workout")
        try data.write(to: url)
        return url
    }

    // MARK: - Phase label

    private func phaseLabel(_ week: Int) -> String {
        switch week {
        case 1: return "Base"
        case 2, 3, 5, 6: return "Carga"
        case 4, 7, 8, 9: return "Pico"
        case 10: return "Redução"
        case 11: return "Polimento"
        case 12: return "Prova"
        default: return ""
        }
    }
}

// MARK: - Session Row

struct SessionRow: View {
    let session: WorkoutSession
    let onExport: () -> Void

    var typeColor: Color {
        switch session.type {
        case .leve:       return .green
        case .intervalos: return .blue
        case .ritmo:      return .orange
        case .longo:      return .purple
        case .polimento:  return .pink
        case .prova:      return .red
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(typeColor.opacity(0.2))
                .frame(width: 4)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(typeColor)
                        .frame(width: 4)
                }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("T\(session.sessionNumber)")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(typeColor, in: Capsule())
                    Text(session.name)
                        .font(.subheadline.bold())
                }
                Text(session.type.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                onExport()
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(typeColor)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Export helpers

struct ExportItem: Identifiable {
    let id = UUID()
    let urls: [URL]
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        PlanView(athlete: Athlete(name: "João Silva", baseMinutes: 20, baseSeconds: 45))
    }
}
