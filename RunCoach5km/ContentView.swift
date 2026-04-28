import SwiftUI

struct ContentView: View {
    @State private var name: String = ""
    @State private var minutes: Int = 20
    @State private var seconds: Int = 45
    @State private var showPlan = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 4) {
                        Image(systemName: "figure.run.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                        Text("RunCoach 5km")
                            .font(.title.bold())
                        Text("Plano personalizado de 12 semanas")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .listRowBackground(Color.clear)
                }

                Section("Dados do Atleta") {
                    TextField("Nome do atleta", text: $name)
                        .textInputAutocapitalization(.words)

                    HStack {
                        Text("Tempo actual 5km")
                        Spacer()
                        Picker("min", selection: $minutes) {
                            ForEach(14...45, id: \.self) { m in
                                Text("\(m)").tag(m)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 70, height: 80)
                        .clipped()

                        Text("min")
                            .foregroundStyle(.secondary)

                        Picker("seg", selection: $seconds) {
                            ForEach(0...59, id: \.self) { s in
                                Text(String(format: "%02d", s)).tag(s)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 70, height: 80)
                        .clipped()

                        Text("seg")
                            .foregroundStyle(.secondary)
                    }
                }

                if !name.isEmpty {
                    let paces = Paces(baseTotalSeconds: Double(minutes * 60 + seconds))
                    Section("Resumo") {
                        LabeledContent("Ritmo actual", value: paces.base.formattedPace)
                        LabeledContent("Ritmo conversa", value: paces.leve.formattedPace)
                        LabeledContent("Ritmo de prova objetivo",
                            value: "\(paces.gMin.formattedPace) – \(paces.gMax.formattedPace)")
                        LabeledContent("Objetivo 5km",
                            value: "\(formatTime(paces.objMinSecs)) – \(formatTime(paces.objMaxSecs)) min")
                    }

                    Section {
                        Button(action: { showPlan = true }) {
                            Label("Gerar Plano de 12 Semanas", systemImage: "waveform.path.ecg")
                                .frame(maxWidth: .infinity)
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .navigationTitle("RunCoach 5km")
            .navigationDestination(isPresented: $showPlan) {
                PlanView(athlete: Athlete(
                    name: name,
                    baseMinutes: minutes,
                    baseSeconds: seconds
                ))
            }
        }
    }
}

#Preview {
    ContentView()
}
