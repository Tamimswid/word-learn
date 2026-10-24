lib/
│
├── main.dart
├── app/                        # Tema, Router, Sabitler
│   ├── config/                 # Router, Theme
│   └── constants/              # AppConstants
│
├── core/                       # Ortak Servisler & Araçlar
│   ├── database/               # SQLite (DbClient, Tables, Views)
│   ├── network/                # AI API Client (Dio/Http)
│   └── widgets/                # Ortak UI Elemanları (Custom Button, Loading vb.)
│
└── features/                   # UYGULAMA ÖZELLİKLERİ
    │
    ├── word_management/        # 1. Kelime Ekleme & AI Pre-generation
    │   ├── models/             # WordModel
    │   ├── repositories/       # WordRepository (DB & AI API İşlemleri)
    │   ├── controllers/        # AddWordCubit / AddWordController
    │   └── views/              # AddWordScreen
    │
    ├── deck_session/           # 2. 10'luk Deste & Swipe Ekranı
    │   ├── models/             # DeckCardModel
    │   ├── repositories/       # DeckRepository (v_card_deck VIEW'ini sorgular)
    │   ├── controllers/        # DeckCubit / DeckController
    │   └── views/              # DeckScreen, SwipeCardWidget
    │
    ├── micro_exercise/         # 3. Bildirim & Mikro Alıştırmalar
    │   ├── repositories/       # ExerciseRepository
    │   ├── controllers/        # ExerciseCubit
    │   └── views/              # ExerciseDialog / Screen
    │
    └── home_dashboard/         # 4. Ana Sayfa & 7 Günlük Chart
        ├── models/             # WeeklyChartModel
        ├── repositories/       # HomeRepository (v_weekly_chart VIEW'ini sorgular)
        ├── controllers/        # HomeCubit
        └── views/              # HomeScreen, WeeklyBarChartWidget