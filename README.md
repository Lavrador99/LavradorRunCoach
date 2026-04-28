# RunCoach 5km — iOS App

App iOS para gerar planos de treino de 5km personalizados e exportar cada sessão 
como ficheiro `.workout` nativo da app Workout do Apple Watch.

## Estrutura do projecto

```
RunCoach5km/
├── RunCoach5kmApp.swift       — Entry point da app
├── ContentView.swift          — Ecrã inicial (input do atleta)
├── PlanView.swift             — Lista de treinos + exportação
├── PaceModel.swift            — Modelo de dados e cálculo de ritmos
└── WorkoutPlanGenerator.swift — Gerador de todos os treinos WorkoutKit
```

## Como criar o projecto no Xcode

### 1. Criar projecto novo

1. Abre o Xcode
2. File → New → Project
3. Selecciona **iOS → App**
4. Preenche:
   - **Product Name**: `RunCoach5km`
   - **Team**: a tua conta Apple Developer
   - **Bundle Identifier**: `com.tuanome.RunCoach5km` (ou outro à tua escolha)
   - **Interface**: SwiftUI
   - **Language**: Swift
5. Escolhe pasta onde guardar → Create

### 2. Adicionar os ficheiros Swift

1. No Xcode, clica com o botão direito na pasta `RunCoach5km` (dentro do projecto)
2. Selecciona **Add Files to "RunCoach5km"**
3. Adiciona os 5 ficheiros `.swift` desta pasta:
   - `RunCoach5kmApp.swift` (substitui o ficheiro existente)
   - `ContentView.swift` (substitui o ficheiro existente)
   - `PlanView.swift`
   - `PaceModel.swift`
   - `WorkoutPlanGenerator.swift`

   > Alternativa: abre cada ficheiro e copia o conteúdo para os ficheiros correspondentes já criados pelo Xcode.

### 3. Adicionar o framework WorkoutKit

1. Selecciona o projecto (ícone azul no topo do Project Navigator)
2. Selecciona o target `RunCoach5km`
3. Vai ao separador **General**
4. Desce até **Frameworks, Libraries, and Embedded Content**
5. Clica em **+**
6. Pesquisa `WorkoutKit`
7. Selecciona **WorkoutKit.framework** → Add

### 4. Adicionar permissão HealthKit (obrigatório para WorkoutKit)

1. No mesmo separador **General** → **Frameworks**, adiciona também `HealthKit.framework`
2. Vai ao separador **Signing & Capabilities**
3. Clica em **+ Capability**
4. Adiciona **HealthKit**
5. Na lista que aparece, activa **Workouts**

### 5. Info.plist — descrição do uso de saúde

1. No Project Navigator, selecciona `Info.plist`
2. Adiciona a key:
   - **NSHealthUpdateUsageDescription**: `"A app usa HealthKit para enviar treinos para o Apple Watch"`
   - **NSHealthShareUsageDescription**: `"A app usa HealthKit para gerir os teus treinos"`

   > No Xcode 13+: vai ao separador **Info** do target e adiciona as keys directamente.

### 6. Compilar e instalar

1. Conecta o iPhone ao Mac (ou usa simulador, mas exportação de ficheiros .workout requer dispositivo real para enviar)
2. Selecciona o teu iPhone como destino no Xcode
3. Clica em **Run** (▶) ou `Cmd+R`
4. Na primeira execução autoriza o HealthKit quando a app pedir

## Como usar a app

1. Introduz o nome do atleta e o seu tempo actual nos 5km
2. Vês o resumo de ritmos calculados
3. Toca em **Gerar Plano de 12 Semanas**
4. Aparece a lista com todos os 43 treinos organizados por semana
5. Para cada treino:
   - Toca no ícone ↑ para exportar só aquele treino
   - Usa o botão **Exportar tudo** (canto superior direito) para exportar os 43 de uma vez
6. Partilha os ficheiros `.workout` por AirDrop, iMessage, WhatsApp, email, etc.

## Como o cliente importa no Apple Watch

1. Recebe o ficheiro `.workout` (ex: via AirDrop)
2. No iPhone, toca no ficheiro
3. A app Workout abre automaticamente com a pré-visualização do treino
4. Toca em **Adicionar ao Apple Watch**
5. O treino aparece na app Workout do Watch, pronto a usar

## Estrutura dos ficheiros .workout

Cada ficheiro contém:
- Nome do atleta + semana + número do treino
- Tipo de actividade: Outdoor Run
- Aquecimento com alerta de ritmo de conversa
- Blocos de intervalos com metas por distância ou tempo
- Alertas de ritmo em cada segmento (±4% de tolerância)
- Desaquecimento com alerta de ritmo de conversa

## Requisitos

- iOS 17.0+
- watchOS 10.0+
- Xcode 15+
- Conta Apple Developer (gratuita para testar em dispositivo próprio)

## Notas técnicas

Os ritmos são calculados com factores extraídos directamente do plano Runna original
(base 4:09/km = 249s/km para um atleta com 20:45 nos 5km). Cada factor é aplicado
proporcionalmente ao ritmo base do atleta introduzido.

Os alertas de ritmo usam `WorkoutAlert.speed` com range de ±4% em torno do ritmo
alvo, convertendo ritmo (s/km) para velocidade (m/s) via `1000 / pace_sec`.
