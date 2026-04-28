import Foundation

// MARK: - Athlete

struct Athlete: Identifiable {
    let id = UUID()
    var name: String
    var baseMinutes: Int
    var baseSeconds: Int

    var baseTotalSeconds: Double {
        Double(baseMinutes * 60 + baseSeconds)
    }

    var basePacePerKm: Double {
        baseTotalSeconds / 5.0
    }

    var displayTime: String {
        "\(baseMinutes):\(String(format: "%02d", baseSeconds)) min"
    }
}

// MARK: - Pace calculation
// Factores extraídos sessão a sessão do plano Runna original (base 4:09/km = 249s/km)

struct Paces {
    let base: Double

    init(baseTotalSeconds: Double) {
        base = baseTotalSeconds / 5.0
    }

    // Conversa / leve (5:15 para base 4:09)
    var leve: Double   { base * 1.2651 }

    // S1-B Corrida Progressiva
    var s1b1: Double   { base * 1.2048 }  // 5:00
    var s1b2: Double   { base * 1.1245 }  // 4:40
    var s1b3: Double   { base * 1.0843 }  // 4:30
    var s1b4: Double   { base * 1.0442 }  // 4:20

    // S1-C 400m repetições
    var s1c: Double    { base * 0.9237 }  // 3:50

    // S2-B Drop set
    var s2b1: Double   { base * 1.0040 }  // 4:10
    var s2b2: Double   { base * 0.9839 }  // 4:05
    var s2b3: Double   { base * 0.9639 }  // 4:00
    var s2b4: Double   { base * 0.9438 }  // 3:55

    // S2-D Longo progressivo
    var s2d1: Double   { base * 1.2249 }  // 5:05
    var s2d2: Double   { base * 1.1245 }  // 4:40
    var s2d3: Double   { base * 1.0843 }  // 4:30

    // S3-B Divisão de milhas
    var s3b1: Double   { base * 1.0040 }  // 4:10
    var s3b2: Double   { base * 0.9438 }  // 3:55

    // S3-C 400m variáveis
    var s3cr: Double   { base * 1.0241 }  // 4:15 (rápido)
    var s3cl: Double   { base * 1.2048 }  // 5:00 (lento)

    // S4-B Pirâmide (topo 1.6km)
    var s4b200: Double  { base * 0.8835 } // 3:40
    var s4b400: Double  { base * 0.9036 } // 3:45
    var s4b800: Double  { base * 0.9639 } // 4:00
    var s4b1200: Double { base * 1.0040 } // 4:10
    var s4b1600: Double { base * 1.0241 } // 4:15

    // S4-D Longo progressivo repetido
    var s4d1: Double   { base * 1.1647 }  // 4:50
    var s4d2: Double   { base * 1.1245 }  // 4:40
    var s4d3: Double   { base * 1.2249 }  // 5:05

    // S5-B 800m + 400m
    var s5b800: Double { base * 0.9639 }  // 4:00
    var s5b400: Double { base * 0.9237 }  // 3:50

    // S5-C Contrarrelógio
    var s5c: Double    { base * 0.9639 }  // 4:00

    // S6-B Blocos
    var s6b1km: Double { base * 1.0241 }  // 4:15
    var s6b200: Double { base * 0.8835 }  // 3:40

    // S6-D Longo em bloco
    var s6d: Double    { base * 1.2048 }  // 5:00

    // S7-B 600m → 200m
    var s7b600: Double { base * 0.9438 }  // 3:55
    var s7b200: Double { base * 0.9036 }  // 3:45

    // S7-C 3-2-1
    var s7c3: Double   { base * 1.0843 }  // 4:30
    var s7c2: Double   { base * 1.0442 }  // 4:20
    var s7c1: Double   { base * 1.0241 }  // 4:15

    // S8-B 500m no máximo
    var s8b1: Double   { base * 0.9839 }  // 4:05
    var s8b2: Double   { base * 0.9639 }  // 4:00
    var s8b3: Double   { base * 0.9438 }  // 3:55
    var s8b4: Double   { base * 0.9237 }  // 3:50

    // S8-D Longo progressivo
    var s8d1: Double   { base * 1.1647 }  // 4:50
    var s8d2: Double   { base * 1.1245 }  // 4:40

    // S9-B Pirâmide (diferente da S4: topo=1km, 400m a 3:50, aqu/desaq=3km)
    var s9b200: Double  { base * 0.8835 } // 3:40
    var s9b400: Double  { base * 0.9237 } // 3:50 ← 3:50, não 3:45 como S4
    var s9b800: Double  { base * 0.9639 } // 4:00
    var s9b1000: Double { base * 1.0040 } // 4:10 ← topo 1km, não 1.2km

    // S9-C Forte/Leve
    var s9cl: Double   { base * 1.1647 }  // 4:50 (lento primeiro)
    var s9cf: Double   { base * 1.0241 }  // 4:15 (forte depois)

    // S10-B 600m no máximo
    var s10b1: Double  { base * 0.9839 }  // 4:05
    var s10b2: Double  { base * 0.9639 }  // 4:00
    var s10b3: Double  { base * 0.9438 }  // 3:55

    // S11 Polimento
    var s11: Double    { base * 0.9438 }  // 3:55

    // S12 Prova
    var gMax: Double   { base * 0.9839 }  // 4:05 (limite mínimo esforço)
    var gMin: Double   { base * 0.9438 }  // 3:55 (limite máximo esforço)

    // Objectivos de tempo
    var objMinSecs: Double { base * 5 * 0.9398 }
    var objMaxSecs: Double { base * 5 * 0.9759 }
}

// MARK: - Helpers

extension Double {
    /// Converte ritmo (s/km) em velocidade (m/s)
    var paceToSpeed: Double { 1000.0 / self }

    /// Formata como "M:SS/km"
    var formattedPace: String {
        let s = Int(self.rounded())
        return "\(s / 60):\(String(format: "%02d", s % 60))/km"
    }
}

func formatTime(_ secs: Double) -> String {
    let s = Int(secs.rounded())
    return "\(s / 60):\(String(format: "%02d", s % 60))"
}
