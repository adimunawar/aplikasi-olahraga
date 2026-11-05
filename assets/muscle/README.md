# Muscle Anatomy Asset System - Home Bulking Coach

Sistem aset anatomi otot tubuh manusia (*Muscle Anatomy Illustration System*) berbasis flat-vector transparan untuk aplikasi **Home Bulking Coach**.

Aset ini didesain khusus agar dapat di-layer secara dinamis menggunakan widget `Stack` di Flutter dengan presisi pixel 1:1, tanpa distorsi atau pergeseran posisi anatomi.

---

## 1. Spesifikasi Teknis Aset

| Properti | Nilai Spesifikasi |
|---|---|
| **Dimensi Canvas** | `950 × 2540 px` (High Resolution) |
| **Format File** | 32-bit Transparent PNG (`RGBA`) |
| **Sistem Koordinat** | Identik & Terpusat (Origin `0, 0` sama untuk semua layer) |
| **Gaya Ilustrasi** | Minimalist Flat-Vector Fitness Infographic |
| **Warna Tubuh Netral** | `#EEF0F3` / `#EBECEE` |
| **Warna Garis Kontur** | `#AAB2BC` / `#CBD5E1` |
| **Warna Highlight Aktif** | **Lime Green (`#A8E900` / `#B0F600`)** |
| **Warna Detail Sekunder**| Light Gray (`#DDE2E7`) |
| **Background** | 100% Transparan |

---

## 2. Struktur Direktori Aset

```
assets/muscle/
├── front/
│   ├── base_front.png       # Base anatomi depan (abu-abu netral)
│   ├── chest.png            # Dada (Pectoralis Major/Minor)
│   ├── shoulders.png        # Bahu depan & samping (Deltoids)
│   ├── biceps.png           # Lengan depan (Biceps Brachii)
│   ├── forearms.png         # Lengan bawah (Brachioradialis / Flexors)
│   ├── abs.png              # Perut tengah (Rectus Abdominis)
│   ├── obliques.png         # Otot samping perut (External Obliques)
│   ├── quads.png            # Paha depan (Quadriceps Femoris)
│   └── calves.png           # Betis & tulang kering depan (Tibialis / Gastrocnemius)
│
├── back/
│   ├── base_back.png        # Base anatomi belakang (abu-abu netral)
│   ├── traps.png            # Punggung atas & leher (Trapezius)
│   ├── back.png             # Sayap punggung (Latissimus Dorsi / Rhomboids)
│   ├── shoulders.png        # Bahu belakang (Rear Deltoids)
│   ├── triceps.png          # Lengan belakang (Triceps Brachii)
│   ├── forearms.png         # Lengan bawah posterior (Extensors)
│   ├── lower_back.png       # Pinggang bawah (Erector Spinae / Lumbar)
│   ├── glutes.png           # Pantat / panggul (Gluteus Maximus / Medius)
│   ├── hamstrings.png       # Paha belakang (Biceps Femoris / Semitendinosus)
│   └── calves.png           # Betis belakang (Gastrocnemius / Soleus)
│
└── previews/
    ├── front_preview.png              # Preview tubuh depan netral
    ├── back_preview.png               # Preview tubuh belakang netral
    ├── chest_highlight_preview.png    # Preview highlight otot dada
    ├── pushup_highlight_preview.png   # Preview gerakan push-up (Chest + Shoulders)
    └── full_body_highlight_preview.png# Preview seluruh tubuh aktif
```

---

## 3. Mapping Otot & Panduan Latihan

| Nama Otot (Target) | View Utama | File Layer Overlay | Contoh Latihan Terkait |
|---|---|---|---|
| **Chest / Dada** | Front | `front/chest.png` | Push-ups, Incline Push-ups, Chest Dips |
| **Shoulders / Bahu** | Front & Back | `front/shoulders.png`, `back/shoulders.png` | Pike Push-up, Lateral Raise, Overhead Press |
| **Biceps** | Front | `front/biceps.png` | Chin-ups, Inverted Rows (underhand), Curls |
| **Triceps** | Back | `back/triceps.png` | Diamond Push-up, Bench Dips, Overhead Extension |
| **Forearms** | Front & Back | `front/forearms.png`, `back/forearms.png` | Dead Hang, Wrist Flexion, Farmer Walk |
| **Abs / Core** | Front | `front/abs.png` | Plank, Crunches, Leg Raises, Hollow Hold |
| **Obliques** | Front | `front/obliques.png` | Side Plank, Russian Twists, Bicycle Crunches |
| **Traps** | Back | `back/traps.png` | Shrugs, Y-Raises, Face Pulls |
| **Back / Lats** | Back | `back/back.png` | Pull-ups, Doorframe Rows, Australian Pull-ups |
| **Lower Back** | Back | `back/lower_back.png` | Superman, Bird Dog, Good Mornings |
| **Glutes** | Back | `back/glutes.png` | Glute Bridges, Hip Thrusts, Bulgarian Split Squats |
| **Quads** | Front | `front/quads.png` | Bodyweight Squats, Lunges, Step-ups |
| **Hamstrings** | Back | `back/hamstrings.png` | Nordic Hamstring Curl, Single-leg RDL |
| **Calves** | Back & Front | `back/calves.png`, `front/calves.png` | Calf Raises, Jump Rope, Donkey Calf Raises |

---

## 4. Cara Penggunaan di Flutter

Cukup tumpuk base anatomi dengan layer otot yang aktif menggunakan `Stack`. Karena resolusi dan titik origin semua gambar 100% presisi, semua layer otomatis sejajar sempurna (*pixel-perfect alignment*).

```dart
import 'package:flutter/material.dart';

class MuscleAnatomyWidget extends StatelessWidget {
  final List<String> targetMuscles;
  final bool isBackView;
  final double? height;

  const MuscleAnatomyWidget({
    super.key,
    required this.targetMuscles,
    this.isBackView = false,
    this.height = 320,
  });

  @override
  Widget build(BuildContext context) {
    final lowerMuscles = targetMuscles.map((m) => m.toLowerCase()).toSet();

    if (isBackView) {
      return SizedBox(
        height: height,
        child: AspectRatio(
          aspectRatio: 950 / 2540,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/muscle/back/base_back.png', fit: BoxFit.contain),
              if (lowerMuscles.contains('traps') || lowerMuscles.contains('trapezius'))
                Image.asset('assets/muscle/back/traps.png', fit: BoxFit.contain),
              if (lowerMuscles.contains('back') || lowerMuscles.contains('lats'))
                Image.asset('assets/muscle/back/back.png', fit: BoxFit.contain),
              if (lowerMuscles.contains('shoulders') || lowerMuscles.contains('shoulder'))
                Image.asset('assets/muscle/back/shoulders.png', fit: BoxFit.contain),
              if (lowerMuscles.contains('triceps') || lowerMuscles.contains('arms'))
                Image.asset('assets/muscle/back/triceps.png', fit: BoxFit.contain),
              if (lowerMuscles.contains('forearms'))
                Image.asset('assets/muscle/back/forearms.png', fit: BoxFit.contain),
              if (lowerMuscles.contains('lower_back') || lowerMuscles.contains('erectors'))
                Image.asset('assets/muscle/back/lower_back.png', fit: BoxFit.contain),
              if (lowerMuscles.contains('glutes'))
                Image.asset('assets/muscle/back/glutes.png', fit: BoxFit.contain),
              if (lowerMuscles.contains('hamstrings') || lowerMuscles.contains('legs'))
                Image.asset('assets/muscle/back/hamstrings.png', fit: BoxFit.contain),
              if (lowerMuscles.contains('calves'))
                Image.asset('assets/muscle/back/calves.png', fit: BoxFit.contain),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: AspectRatio(
        aspectRatio: 950 / 2540,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/muscle/front/base_front.png', fit: BoxFit.contain),
            if (lowerMuscles.contains('chest') || lowerMuscles.contains('dada'))
              Image.asset('assets/muscle/front/chest.png', fit: BoxFit.contain),
            if (lowerMuscles.contains('shoulders') || lowerMuscles.contains('shoulder') || lowerMuscles.contains('bahu'))
              Image.asset('assets/muscle/front/shoulders.png', fit: BoxFit.contain),
            if (lowerMuscles.contains('biceps') || lowerMuscles.contains('arms') || lowerMuscles.contains('lengan'))
              Image.asset('assets/muscle/front/biceps.png', fit: BoxFit.contain),
            if (lowerMuscles.contains('forearms'))
              Image.asset('assets/muscle/front/forearms.png', fit: BoxFit.contain),
            if (lowerMuscles.contains('abs') || lowerMuscles.contains('core') || lowerMuscles.contains('perut'))
              Image.asset('assets/muscle/front/abs.png', fit: BoxFit.contain),
            if (lowerMuscles.contains('obliques'))
              Image.asset('assets/muscle/front/obliques.png', fit: BoxFit.contain),
            if (lowerMuscles.contains('quads') || lowerMuscles.contains('legs') || lowerMuscles.contains('kaki'))
              Image.asset('assets/muscle/front/quads.png', fit: BoxFit.contain),
            if (lowerMuscles.contains('calves') || lowerMuscles.contains('betis'))
              Image.asset('assets/muscle/front/calves.png', fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }
}
```

