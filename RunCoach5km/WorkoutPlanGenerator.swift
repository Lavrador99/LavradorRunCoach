import WorkoutKit
import HealthKit

// MARK: - WorkoutPlan generator

struct WorkoutSession: Identifiable {
    let id = UUID()
    let week: Int
    let sessionNumber: Int
    let name: String
    let type: SessionType
    let workout: CustomWorkout

    enum SessionType {
        case leve, intervalos, ritmo, longo, polimento, prova
        var label: String {
            switch self {
            case .leve:       return "Corrida Leve"
            case .intervalos: return "Intervalos"
            case .ritmo:      return "Treino de Ritmo"
            case .longo:      return "Treino Longo"
            case .polimento:  return "Polimento"
            case .prova:      return "Prova"
            }
        }
        var color: String {
            switch self {
            case .leve:       return "green"
            case .intervalos: return "blue"
            case .ritmo:      return "orange"
            case .longo:      return "purple"
            case .polimento:  return "pink"
            case .prova:      return "red"
            }
        }
    }
}

// MARK: - Speed range helper
// WorkoutKit usa m/s. Para alertas de ritmo passamos range de velocidade.
// tolerance de ±4% como margem de conforto.

private func speedRange(_ paceSec: Double, tol: Double = 0.04) -> ClosedRange<Double> {
    let speed = paceSec.paceToSpeed
    return (speed * (1 - tol))...(speed * (1 + tol))
}

private func speedRangeAlert(_ paceSec: Double) -> WorkoutAlert {
    .speed(speedRange(paceSec), unit: .metersPerSecond, metric: .current)
}

// Para prova com range explícito (pace máximo e mínimo)
private func speedRangeAlertExplicit(slowPace: Double, fastPace: Double) -> WorkoutAlert {
    let low  = fastPace.paceToSpeed   // pace mais rápido = velocidade mais alta
    let high = slowPace.paceToSpeed   // pace mais lento  = velocidade mais baixa
    // WorkoutKit: low < high em m/s
    return .speed(high...low, unit: .metersPerSecond, metric: .current)
}

// MARK: - Plan generator

struct WorkoutPlanGenerator {

    static func generateAll(for athlete: Athlete) -> [WorkoutSession] {
        let R = Paces(baseTotalSeconds: athlete.baseTotalSeconds)
        let n = athlete.name
        var sessions: [WorkoutSession] = []

        sessions += week1(n, R)
        sessions += week2(n, R)
        sessions += week3(n, R)
        sessions += week4(n, R)
        sessions += week5(n, R)
        sessions += week6(n, R)
        sessions += week7(n, R)
        sessions += week8(n, R)
        sessions += week9(n, R)
        sessions += week10(n, R)
        sessions += week11(n, R)
        sessions += week12(n, R)

        return sessions
    }

    // MARK: - Semana 1

    private static func week1(_ n: String, _ R: Paces) -> [WorkoutSession] {
        var result: [WorkoutSession] = []

        // T1 — 8km Leve
        let t1 = CustomWorkout(
            activity: .running,
            location: .outdoor,
            displayName: "\(n) — S01 — T1 — 8km Leve",
            warmup: WorkoutStep(goal: .open),
            blocks: [
                IntervalBlock(steps: [
                    IntervalStep(.work,
                        goal: .distance(8000, .meters),
                        alert: speedRangeAlert(R.leve))
                ], iterations: 1)
            ],
            cooldown: WorkoutStep(goal: .open)
        )
        result.append(WorkoutSession(week: 1, sessionNumber: 1, name: "8km Leve", type: .leve, workout: t1))

        // T2 — Corrida Progressiva
        let t2 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S01 — T2 — Progressiva",
            warmup: WorkoutStep(goal: .distance(1000, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(1000, .meters), alert: speedRangeAlert(R.s1b1))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(2000, .meters), alert: speedRangeAlert(R.s1b2))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(2000, .meters), alert: speedRangeAlert(R.s1b3))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(1000, .meters), alert: speedRangeAlert(R.s1b4))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.recovery, goal: .time(90, .seconds))], iterations: 1)
            ],
            cooldown: WorkoutStep(goal: .distance(1000, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 1, sessionNumber: 2, name: "Corrida Progressiva", type: .ritmo, workout: t2))

        // T3 — 400m Repetições (5+5)
        let t3 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S01 — T3 — 400m Rep",
            warmup: WorkoutStep(goal: .distance(2500, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [
                    IntervalStep(.work,     goal: .distance(400, .meters), alert: speedRangeAlert(R.s1c)),
                    IntervalStep(.recovery, goal: .time(60, .seconds))
                ], iterations: 5),
                IntervalBlock(steps: [IntervalStep(.recovery, goal: .time(60, .seconds))], iterations: 1),
                IntervalBlock(steps: [
                    IntervalStep(.work,     goal: .distance(400, .meters), alert: speedRangeAlert(R.s1c)),
                    IntervalStep(.recovery, goal: .time(60, .seconds))
                ], iterations: 5)
            ],
            cooldown: WorkoutStep(goal: .distance(1500, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 1, sessionNumber: 3, name: "400m Repetições (5+5)", type: .intervalos, workout: t3))

        // T4 — 10km Longo
        let t4 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S01 — T4 — 10km Longo",
            warmup: WorkoutStep(goal: .open),
            blocks: [
                IntervalBlock(steps: [
                    IntervalStep(.work, goal: .distance(10000, .meters), alert: speedRangeAlert(R.leve))
                ], iterations: 1)
            ],
            cooldown: WorkoutStep(goal: .open)
        )
        result.append(WorkoutSession(week: 1, sessionNumber: 4, name: "10km Longo", type: .longo, workout: t4))

        return result
    }

    // MARK: - Semana 2

    private static func week2(_ n: String, _ R: Paces) -> [WorkoutSession] {
        var result: [WorkoutSession] = []

        // T1 — 8km Leve
        result.append(makeSimpleRun(n, week: 2, session: 1, name: "8km Leve", distance: 8000, pace: R.leve, type: .leve))

        // T2 — Drop Set
        let t2 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S02 — T2 — Drop Set",
            warmup: WorkoutStep(goal: .distance(1600, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [
                    IntervalStep(.work,     goal: .distance(1000, .meters), alert: speedRangeAlert(R.s2b1)),
                    IntervalStep(.recovery, goal: .time(90, .seconds))
                ], iterations: 2),
                IntervalBlock(steps: [
                    IntervalStep(.work,     goal: .distance(800, .meters), alert: speedRangeAlert(R.s2b2)),
                    IntervalStep(.recovery, goal: .time(90, .seconds))
                ], iterations: 2),
                IntervalBlock(steps: [
                    IntervalStep(.work,     goal: .distance(600, .meters), alert: speedRangeAlert(R.s2b3)),
                    IntervalStep(.recovery, goal: .time(90, .seconds))
                ], iterations: 2),
                IntervalBlock(steps: [
                    IntervalStep(.work,     goal: .distance(400, .meters), alert: speedRangeAlert(R.s2b4)),
                    IntervalStep(.recovery, goal: .time(90, .seconds))
                ], iterations: 2)
            ],
            cooldown: WorkoutStep(goal: .distance(1800, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 2, sessionNumber: 2, name: "Drop Set", type: .intervalos, workout: t2))

        // T3 — 9km Leve
        result.append(makeSimpleRun(n, week: 2, session: 3, name: "9km Leve", distance: 9000, pace: R.leve, type: .leve))

        // T4 — 10km Longo Progressivo
        let t4 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S02 — T4 — Longo Prog.",
            warmup: WorkoutStep(goal: .distance(2000, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(3000, .meters), alert: speedRangeAlert(R.s2d1))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(3000, .meters), alert: speedRangeAlert(R.s2d2))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(2000, .meters), alert: speedRangeAlert(R.s2d3))], iterations: 1)
            ],
            cooldown: WorkoutStep(goal: .open)
        )
        result.append(WorkoutSession(week: 2, sessionNumber: 4, name: "10km Longo Progressivo", type: .longo, workout: t4))

        return result
    }

    // MARK: - Semana 3

    private static func week3(_ n: String, _ R: Paces) -> [WorkoutSession] {
        var result: [WorkoutSession] = []

        result.append(makeSimpleRun(n, week: 3, session: 1, name: "9km Leve", distance: 9000, pace: R.leve, type: .leve))

        // T2 — Divisão de Milhas (bloco × 3)
        let t2 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S03 — T2 — Div. Milhas",
            warmup: WorkoutStep(goal: .distance(2800, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [
                    IntervalStep(.work,     goal: .distance(1200, .meters), alert: speedRangeAlert(R.s3b1)),
                    IntervalStep(.recovery, goal: .time(120, .seconds)),
                    IntervalStep(.work,     goal: .distance(400, .meters),  alert: speedRangeAlert(R.s3b2)),
                    IntervalStep(.recovery, goal: .time(60, .seconds))
                ], iterations: 3)
            ],
            cooldown: WorkoutStep(goal: .distance(2400, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 3, sessionNumber: 2, name: "Divisão de Milhas", type: .intervalos, workout: t2))

        // T3 — 400m Variáveis (6 blocos, sem descanso entre tiros)
        let t3 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S03 — T3 — 400m Variáveis",
            warmup: WorkoutStep(goal: .distance(2400, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [
                    IntervalStep(.work,     goal: .distance(400, .meters), alert: speedRangeAlert(R.s3cr)),
                    IntervalStep(.recovery, goal: .distance(400, .meters), alert: speedRangeAlert(R.s3cl))
                ], iterations: 6),
                IntervalBlock(steps: [IntervalStep(.recovery, goal: .time(90, .seconds))], iterations: 1)
            ],
            cooldown: WorkoutStep(goal: .distance(1800, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 3, sessionNumber: 3, name: "400m Variáveis", type: .ritmo, workout: t3))

        result.append(makeSimpleRun(n, week: 3, session: 4, name: "11km Longo", distance: 11000, pace: R.leve, type: .longo))

        return result
    }

    // MARK: - Semana 4

    private static func week4(_ n: String, _ R: Paces) -> [WorkoutSession] {
        var result: [WorkoutSession] = []

        result.append(makeSimpleRun(n, week: 4, session: 1, name: "8km Leve", distance: 8000, pace: R.leve, type: .leve))

        // T2 — Pirâmide completa (S4: topo 1.6km, 400m a 3:45)
        let t2 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S04 — T2 — Pirâmide",
            warmup: WorkoutStep(goal: .distance(2000, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(200,  .meters), alert: speedRangeAlert(R.s4b200)),  IntervalStep(.recovery, goal: .time(60, .seconds))],  iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(400,  .meters), alert: speedRangeAlert(R.s4b400)),  IntervalStep(.recovery, goal: .time(90, .seconds))],  iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(800,  .meters), alert: speedRangeAlert(R.s4b800)),  IntervalStep(.recovery, goal: .time(90, .seconds))],  iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(1200, .meters), alert: speedRangeAlert(R.s4b1200)), IntervalStep(.recovery, goal: .time(120, .seconds))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(1600, .meters), alert: speedRangeAlert(R.s4b1600)), IntervalStep(.recovery, goal: .time(120, .seconds))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(1200, .meters), alert: speedRangeAlert(R.s4b1200)), IntervalStep(.recovery, goal: .time(120, .seconds))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(800,  .meters), alert: speedRangeAlert(R.s4b800)),  IntervalStep(.recovery, goal: .time(90, .seconds))],  iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(400,  .meters), alert: speedRangeAlert(R.s4b400)),  IntervalStep(.recovery, goal: .time(90, .seconds))],  iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(200,  .meters), alert: speedRangeAlert(R.s4b200)),  IntervalStep(.recovery, goal: .time(60, .seconds))],  iterations: 1)
            ],
            cooldown: WorkoutStep(goal: .distance(2000, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 4, sessionNumber: 2, name: "Intervalos em Pirâmide", type: .intervalos, workout: t2))

        result.append(makeSimpleRun(n, week: 4, session: 3, name: "9km Leve", distance: 9000, pace: R.leve, type: .leve))

        // T4 — 12km Longo Progressivo Repetido
        let t4 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S04 — T4 — Longo Prog. Rep.",
            warmup: WorkoutStep(goal: .distance(2000, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(2000, .meters), alert: speedRangeAlert(R.s4d2))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(2000, .meters), alert: speedRangeAlert(R.s4d1))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(2000, .meters), alert: speedRangeAlert(R.s4d3))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(2000, .meters), alert: speedRangeAlert(R.s4d2))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(2000, .meters), alert: speedRangeAlert(R.s4d1))], iterations: 1)
            ],
            cooldown: WorkoutStep(goal: .open)
        )
        result.append(WorkoutSession(week: 4, sessionNumber: 4, name: "12km Longo Prog. Repetido", type: .longo, workout: t4))

        return result
    }

    // MARK: - Semana 5

    private static func week5(_ n: String, _ R: Paces) -> [WorkoutSession] {
        var result: [WorkoutSession] = []

        result.append(makeSimpleRun(n, week: 5, session: 1, name: "7km Leve", distance: 7000, pace: R.leve, type: .leve))

        // T2 — 800m + 400m
        let t2 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S05 — T2 — 800m+400m",
            warmup: WorkoutStep(goal: .distance(1500, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [
                    IntervalStep(.work,     goal: .distance(800, .meters), alert: speedRangeAlert(R.s5b800)),
                    IntervalStep(.recovery, goal: .time(90, .seconds))
                ], iterations: 3),
                IntervalBlock(steps: [
                    IntervalStep(.work,     goal: .distance(400, .meters), alert: speedRangeAlert(R.s5b400)),
                    IntervalStep(.recovery, goal: .time(90, .seconds))
                ], iterations: 4)
            ],
            cooldown: WorkoutStep(goal: .distance(1500, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 5, sessionNumber: 2, name: "800m e 400m Intervalos", type: .intervalos, workout: t2))

        // T3 — 2 Milhas Contrarrelógio
        let t3 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S05 — T3 — 2mi Contrarrelógio",
            warmup: WorkoutStep(goal: .distance(2500, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [IntervalStep(.recovery, goal: .time(180, .seconds))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(3220, .meters), alert: speedRangeAlert(R.s5c))], iterations: 1)
            ],
            cooldown: WorkoutStep(goal: .distance(800, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 5, sessionNumber: 3, name: "2 Milhas Contrarrelógio", type: .ritmo, workout: t3))

        result.append(makeSimpleRun(n, week: 5, session: 4, name: "7.5km Longo", distance: 7500, pace: R.leve, type: .longo))

        return result
    }

    // MARK: - Semana 6

    private static func week6(_ n: String, _ R: Paces) -> [WorkoutSession] {
        var result: [WorkoutSession] = []

        result.append(makeSimpleRun(n, week: 6, session: 1, name: "8km Leve", distance: 8000, pace: R.leve, type: .leve))

        // T2 — 1km Dividido em Blocos (3×)
        let t2 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S06 — T2 — 1km Blocos",
            warmup: WorkoutStep(goal: .distance(2000, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [
                    IntervalStep(.work,     goal: .distance(1000, .meters), alert: speedRangeAlert(R.s6b1km)),
                    IntervalStep(.recovery, goal: .time(60, .seconds)),
                    IntervalStep(.work,     goal: .distance(200, .meters),  alert: speedRangeAlert(R.s6b200)),
                    IntervalStep(.recovery, goal: .time(45, .seconds)),
                    IntervalStep(.work,     goal: .distance(200, .meters),  alert: speedRangeAlert(R.s6b200)),
                    IntervalStep(.recovery, goal: .time(45, .seconds)),
                    IntervalStep(.work,     goal: .distance(200, .meters),  alert: speedRangeAlert(R.s6b200)),
                    IntervalStep(.recovery, goal: .time(45, .seconds)),
                    IntervalStep(.work,     goal: .distance(200, .meters),  alert: speedRangeAlert(R.s6b200)),
                    IntervalStep(.recovery, goal: .time(45, .seconds)),
                    IntervalStep(.work,     goal: .distance(200, .meters),  alert: speedRangeAlert(R.s6b200)),
                    IntervalStep(.recovery, goal: .time(120, .seconds))
                ], iterations: 3)
            ],
            cooldown: WorkoutStep(goal: .distance(2000, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 6, sessionNumber: 2, name: "1km Dividido em Blocos", type: .intervalos, workout: t2))

        result.append(makeSimpleRun(n, week: 6, session: 3, name: "9km Leve", distance: 9000, pace: R.leve, type: .leve))

        // T4 — 13km Longo em Bloco
        let t4 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S06 — T4 — 13km Bloco",
            warmup: WorkoutStep(goal: .open),
            blocks: [
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(6500, .meters), alert: speedRangeAlert(R.leve))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(6500, .meters), alert: speedRangeAlert(R.s6d))],  iterations: 1)
            ],
            cooldown: WorkoutStep(goal: .open)
        )
        result.append(WorkoutSession(week: 6, sessionNumber: 4, name: "13km Longo em Bloco", type: .longo, workout: t4))

        return result
    }

    // MARK: - Semana 7

    private static func week7(_ n: String, _ R: Paces) -> [WorkoutSession] {
        var result: [WorkoutSession] = []

        result.append(makeSimpleRun(n, week: 7, session: 1, name: "9km Leve", distance: 9000, pace: R.leve, type: .leve))

        // T2 — 600m → 200m
        let t2 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S07 — T2 — 600m→200m",
            warmup: WorkoutStep(goal: .distance(2500, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [
                    IntervalStep(.work,     goal: .distance(600, .meters), alert: speedRangeAlert(R.s7b600)),
                    IntervalStep(.recovery, goal: .time(90, .seconds))
                ], iterations: 6),
                IntervalBlock(steps: [
                    IntervalStep(.work,     goal: .distance(200, .meters), alert: speedRangeAlert(R.s7b200)),
                    IntervalStep(.recovery, goal: .time(90, .seconds))
                ], iterations: 7)
            ],
            cooldown: WorkoutStep(goal: .distance(2500, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 7, sessionNumber: 2, name: "600m → 200m", type: .intervalos, workout: t2))

        // T3 — 3-2-1 Treino de Ritmo
        let t3 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S07 — T3 — 3-2-1 Ritmo",
            warmup: WorkoutStep(goal: .distance(1500, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(3000, .meters), alert: speedRangeAlert(R.s7c3)), IntervalStep(.recovery, goal: .time(180, .seconds))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(2000, .meters), alert: speedRangeAlert(R.s7c2)), IntervalStep(.recovery, goal: .time(120, .seconds))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(1000, .meters), alert: speedRangeAlert(R.s7c1)), IntervalStep(.recovery, goal: .time(90,  .seconds))], iterations: 1)
            ],
            cooldown: WorkoutStep(goal: .distance(1500, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 7, sessionNumber: 3, name: "3-2-1 Treino de Ritmo", type: .ritmo, workout: t3))

        result.append(makeSimpleRun(n, week: 7, session: 4, name: "14km Longo", distance: 14000, pace: R.leve, type: .longo))

        return result
    }

    // MARK: - Semana 8

    private static func week8(_ n: String, _ R: Paces) -> [WorkoutSession] {
        var result: [WorkoutSession] = []

        result.append(makeSimpleRun(n, week: 8, session: 1, name: "8km Leve", distance: 8000, pace: R.leve, type: .leve))

        // T2 — 500m no Máximo (4 fases)
        let t2 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S08 — T2 — 500m Máximo",
            warmup: WorkoutStep(goal: .distance(3000, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(500, .meters), alert: speedRangeAlert(R.s8b1)), IntervalStep(.recovery, goal: .time(60, .seconds))], iterations: 4),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(500, .meters), alert: speedRangeAlert(R.s8b2)), IntervalStep(.recovery, goal: .time(60, .seconds))], iterations: 3),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(500, .meters), alert: speedRangeAlert(R.s8b3)), IntervalStep(.recovery, goal: .time(60, .seconds))], iterations: 2),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(500, .meters), alert: speedRangeAlert(R.s8b4)), IntervalStep(.recovery, goal: .time(60, .seconds))], iterations: 1)
            ],
            cooldown: WorkoutStep(goal: .distance(2000, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 8, sessionNumber: 2, name: "500m no Máximo", type: .intervalos, workout: t2))

        result.append(makeSimpleRun(n, week: 8, session: 3, name: "9km Leve", distance: 9000, pace: R.leve, type: .leve))

        // T4 — 15km Longo Progressivo
        let t4 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S08 — T4 — 15km Prog.",
            warmup: WorkoutStep(goal: .distance(5000, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(5000, .meters), alert: speedRangeAlert(R.s8d1))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(4000, .meters), alert: speedRangeAlert(R.s8d2))], iterations: 1)
            ],
            cooldown: WorkoutStep(goal: .distance(1000, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 8, sessionNumber: 4, name: "15km Longo Progressivo", type: .longo, workout: t4))

        return result
    }

    // MARK: - Semana 9

    private static func week9(_ n: String, _ R: Paces) -> [WorkoutSession] {
        var result: [WorkoutSession] = []

        result.append(makeSimpleRun(n, week: 9, session: 1, name: "9km Leve", distance: 9000, pace: R.leve, type: .leve))

        // T2 — Pirâmide S9 (diferente da S4: topo 1km, 400m a 3:50, aqu/desaq 3km)
        let t2 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S09 — T2 — Pirâmide",
            warmup: WorkoutStep(goal: .distance(3000, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(200,  .meters), alert: speedRangeAlert(R.s9b200)),  IntervalStep(.recovery, goal: .time(60,  .seconds))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(400,  .meters), alert: speedRangeAlert(R.s9b400)),  IntervalStep(.recovery, goal: .time(90,  .seconds))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(800,  .meters), alert: speedRangeAlert(R.s9b800)),  IntervalStep(.recovery, goal: .time(90,  .seconds))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(1000, .meters), alert: speedRangeAlert(R.s9b1000)), IntervalStep(.recovery, goal: .time(120, .seconds))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(800,  .meters), alert: speedRangeAlert(R.s9b800)),  IntervalStep(.recovery, goal: .time(90,  .seconds))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(400,  .meters), alert: speedRangeAlert(R.s9b400)),  IntervalStep(.recovery, goal: .time(90,  .seconds))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(200,  .meters), alert: speedRangeAlert(R.s9b200)),  IntervalStep(.recovery, goal: .time(60,  .seconds))], iterations: 1)
            ],
            cooldown: WorkoutStep(goal: .distance(3000, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 9, sessionNumber: 2, name: "Treino em Pirâmide", type: .intervalos, workout: t2))

        // T3 — 1km Forte/Leve (lento primeiro, forte depois)
        let t3 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S09 — T3 — Forte/Leve",
            warmup: WorkoutStep(goal: .distance(1500, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [
                    IntervalStep(.recovery, goal: .distance(1000, .meters), alert: speedRangeAlert(R.s9cl)),
                    IntervalStep(.work,     goal: .distance(1000, .meters), alert: speedRangeAlert(R.s9cf))
                ], iterations: 2)
            ],
            cooldown: WorkoutStep(goal: .distance(1500, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 9, sessionNumber: 3, name: "1km Forte/Leve", type: .ritmo, workout: t3))

        result.append(makeSimpleRun(n, week: 9, session: 4, name: "16km Longo", distance: 16000, pace: R.leve, type: .longo))

        return result
    }

    // MARK: - Semana 10

    private static func week10(_ n: String, _ R: Paces) -> [WorkoutSession] {
        var result: [WorkoutSession] = []

        result.append(makeSimpleRun(n, week: 10, session: 1, name: "7km Leve", distance: 7000, pace: R.leve, type: .leve))

        // T2 — 600m no Máximo (3 fases progressivas)
        let t2 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S10 — T2 — 600m Máximo",
            warmup: WorkoutStep(goal: .distance(2000, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(600, .meters), alert: speedRangeAlert(R.s10b1)), IntervalStep(.recovery, goal: .time(90, .seconds))], iterations: 3),
                IntervalBlock(steps: [IntervalStep(.recovery, goal: .time(60, .seconds))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(600, .meters), alert: speedRangeAlert(R.s10b2)), IntervalStep(.recovery, goal: .time(90, .seconds))], iterations: 2),
                IntervalBlock(steps: [IntervalStep(.recovery, goal: .time(60, .seconds))], iterations: 1),
                IntervalBlock(steps: [IntervalStep(.work, goal: .distance(600, .meters), alert: speedRangeAlert(R.s10b3)), IntervalStep(.recovery, goal: .time(90, .seconds))], iterations: 1)
            ],
            cooldown: WorkoutStep(goal: .distance(2000, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 10, sessionNumber: 2, name: "600m no Máximo", type: .intervalos, workout: t2))

        result.append(makeSimpleRun(n, week: 10, session: 3, name: "9km Leve", distance: 9000, pace: R.leve, type: .leve))
        result.append(makeSimpleRun(n, week: 10, session: 4, name: "11km Longo", distance: 11000, pace: R.leve, type: .longo))

        return result
    }

    // MARK: - Semana 11

    private static func week11(_ n: String, _ R: Paces) -> [WorkoutSession] {
        var result: [WorkoutSession] = []

        // T1 — 400m Polimento
        let t1 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S11 — T1 — Polimento",
            warmup: WorkoutStep(goal: .distance(3000, .meters), alert: speedRangeAlert(R.leve)),
            blocks: [
                IntervalBlock(steps: [IntervalStep(.recovery, goal: .time(60, .seconds))], iterations: 1),
                IntervalBlock(steps: [
                    IntervalStep(.work,     goal: .distance(400, .meters), alert: speedRangeAlert(R.s11)),
                    IntervalStep(.recovery, goal: .time(75, .seconds))
                ], iterations: 7)
            ],
            cooldown: WorkoutStep(goal: .distance(1600, .meters), alert: speedRangeAlert(R.leve))
        )
        result.append(WorkoutSession(week: 11, sessionNumber: 1, name: "400m Polimento", type: .polimento, workout: t1))

        result.append(makeSimpleRun(n, week: 11, session: 2, name: "5.5km Leve", distance: 5500, pace: R.leve, type: .leve))

        return result
    }

    // MARK: - Semana 12

    private static func week12(_ n: String, _ R: Paces) -> [WorkoutSession] {
        // T1 — Prova 5km com range de ritmo explícito
        let t1 = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S12 — T1 — Prova 5km",
            warmup: WorkoutStep(goal: .open),
            blocks: [
                IntervalBlock(steps: [
                    IntervalStep(.work,
                        goal: .distance(5000, .meters),
                        alert: .speed(
                            R.gMax.paceToSpeed...R.gMin.paceToSpeed,
                            unit: .metersPerSecond,
                            metric: .current
                        ))
                ], iterations: 1)
            ],
            cooldown: WorkoutStep(goal: .open)
        )
        return [WorkoutSession(week: 12, sessionNumber: 1, name: "Prova 5km", type: .prova, workout: t1)]
    }

    // MARK: - Helper: corrida simples

    private static func makeSimpleRun(
        _ n: String, week: Int, session: Int,
        name: String, distance: Double, pace: Double,
        type: WorkoutSession.SessionType
    ) -> WorkoutSession {
        let wk = String(format: "%02d", week)
        let workout = CustomWorkout(
            activity: .running, location: .outdoor,
            displayName: "\(n) — S\(wk) — T\(session) — \(name)",
            warmup: WorkoutStep(goal: .open),
            blocks: [
                IntervalBlock(steps: [
                    IntervalStep(.work, goal: .distance(distance, .meters), alert: speedRangeAlert(pace))
                ], iterations: 1)
            ],
            cooldown: WorkoutStep(goal: .open)
        )
        return WorkoutSession(week: week, sessionNumber: session, name: name, type: type, workout: workout)
    }
}
