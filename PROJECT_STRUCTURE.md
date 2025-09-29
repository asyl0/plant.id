# Жоба құрылымы

## Файлдар мен папкалар

```
green_plant_22/
│
├── lib/
│   ├── main.dart                              # Қосымшаның басталу нүктесі
│   │
│   ├── models/                                # Деректер модельдері
│   │   ├── plant_model.dart                   # Өсімдік моделі (SQLite үшін)
│   │   └── plant_identification.dart          # API жауабын өңдеу моделі
│   │
│   ├── services/                              # API қызметтері
│   │   ├── plant_id_service.dart              # Plant.id API интеграциясы
│   │   └── openrouter_service.dart            # OpenRouter AI интеграциясы
│   │
│   ├── database/                              # Деректер базасы
│   │   └── database_helper.dart               # SQLite Helper класы
│   │
│   └── screens/                               # Экрандар
│       ├── home_screen.dart                   # Басты бет
│       ├── identification_result_screen.dart  # Анықтау нәтижесі
│       ├── catalog_screen.dart                # Каталог тізімі
│       └── plant_detail_screen.dart           # Өсімдік детальдары
│
├── android/                                   # Android конфигурациясы
│   └── app/src/main/AndroidManifest.xml      # Рұқсаттар
│
├── ios/                                       # iOS конфигурациясы
│   └── Runner/Info.plist                      # Рұқсаттар
│
├── .env                                       # API кілттері (қосу керек!)
├── .env.example                               # .env мысалы
├── .gitignore                                 # Git игнор файлы
├── pubspec.yaml                               # Flutter зависимостері
│
├── README.md                                  # Жоба сипаттамасы
├── SETUP.md                                   # Орнату нұсқаулығы
├── ENV_SETUP.md                              # .env орнату нұсқаулығы
├── USAGE.md                                   # Пайдалану нұсқаулығы
└── PROJECT_STRUCTURE.md                       # Бұл файл

```

## Негізгі компоненттер

### 1. Models (Модельдер)

#### PlantModel
- SQLite базасында сақтау үшін
- Өсімдік туралы толық ақпарат
- Қазақ тіліндегі деректер

#### PlantIdentification
- Plant.id API жауабын өңдеу
- Уақытша деректер (базаға дейін)

### 2. Services (Қызметтер)

#### PlantIdService
- Plant.id API v3 интеграциясы
- Өсімдікті анықтау
- Base64 форматта сурет жіберу

#### OpenRouterService
- OpenRouter AI интеграциясы
- Қазақ тілінде ақпарат алу
- GPT-3.5-turbo моделін пайдалану

### 3. Database (Деректер базасы)

#### DatabaseHelper
- SQLite базасын басқару
- CRUD операциялары
- Singleton pattern

### 4. Screens (Экрандар)

#### HomeScreen
- Басты бет
- 3 негізгі бөлім:
  * Камера
  * Галерея
  * Каталог

#### IdentificationResultScreen
- Анықтау нәтижесі
- Ұқсас өсімдіктер тізімі
- Каталогқа қосу функциясы

#### CatalogScreen
- Сақталған өсімдіктер
- Жою мүмкіндігі
- Детальды бетке өту

#### PlantDetailScreen
- Толық ақпарат
- Қазақ тіліндегі сипаттама
- Пайдасы және зияны

## Деректер ағыны

### 1. Өсімдікті анықтау:

```
Пайдаланушы
    ↓
HomeScreen (Камера/Галерея)
    ↓
ImagePicker (Сурет таңдау)
    ↓
IdentificationResultScreen
    ↓
PlantIdService.identifyPlant()
    ↓
Plant.id API
    ↓
Нәтижелер тізімі
```

### 2. Каталогқа қосу:

```
Нәтиже экраны
    ↓
"Каталогқа қосу" батырмасы
    ↓
OpenRouterService.getPlantInfo()
    ↓
OpenRouter API (GPT-3.5)
    ↓
Қазақ тіліндегі ақпарат
    ↓
DatabaseHelper.create()
    ↓
SQLite базасы
    ↓
PlantDetailScreen
```

### 3. Каталогты қарау:

```
HomeScreen
    ↓
"Менің каталогым" батырмасы
    ↓
CatalogScreen
    ↓
DatabaseHelper.readAllPlants()
    ↓
Өсімдіктер тізімі
    ↓
PlantDetailScreen
```

## Зависимостер

### Негізгі:
- `flutter` - Flutter SDK
- `image_picker` - Камера/Галерея
- `http` - HTTP сұраныстар
- `sqflite` - SQLite база
- `flutter_dotenv` - .env файлдары
- `cached_network_image` - Сурет кэштеу
- `path_provider` - Файл жолдары

### Дев:
- `flutter_test` - Тестілеу
- `flutter_lints` - Код сапасы
- `json_serializable` - JSON генерация
- `build_runner` - Код генерация

## API Интеграциялары

### Plant.id API v3
- **Endpoint:** `https://plant.id/api/v3/identification`
- **Метод:** POST
- **Формат:** JSON + Base64 image
- **Жауап:** Өсімдіктер тізімі + ұқсастық пайызы

### OpenRouter API
- **Endpoint:** `https://openrouter.ai/api/v1/chat/completions`
- **Метод:** POST
- **Модель:** `openai/gpt-3.5-turbo`
- **Жауап:** Қазақ тіліндегі мәтін

## База құрылымы

### plants кестесі:

| Бағана | Түрі | Сипаттама |
|--------|------|-----------|
| id | INTEGER | Primary Key |
| scientific_name | TEXT | Латын атауы |
| common_name | TEXT | Жалпы атауы |
| image_path | TEXT | Сурет жолы |
| probability | REAL | Ұқсастық пайызы |
| kazakh_name | TEXT | Қазақша атауы |
| description | TEXT | Сипаттама |
| benefits | TEXT | Пайдасы |
| harms | TEXT | Зияны |
| date_added | TEXT | Қосылған күні |

## Қауіпсіздік

1. **API Кілттері:**
   - .env файлында сақталады
   - .gitignore-ке қосылған
   - GitHub-қа жүктелмейді

2. **Деректер:**
   - Локальды сақталады
   - Шифрланбаған
   - Құрылғыда ғана

3. **Рұқсаттар:**
   - Камера
   - Галерея
   - Интернет

## Тестілеу

```bash
# Анализ
flutter analyze

# Форматтау
flutter format lib/

# Іске қосу
flutter run

# Release build
flutter build apk
flutter build ios
```

## Оптимизация

1. **Сурет өлшемі:** 1024x1024px дейін кішірейтіледі
2. **Кэштеу:** `cached_network_image` пайдаланылады
3. **База:** SQLite индекстері бар
4. **Жүктеу:** Асинхронды операциялар

---

**Жоба әзір! Пайдаланыңыз! 🌿**
