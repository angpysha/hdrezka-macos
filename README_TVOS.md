# HDrezka для tvOS

Це адаптація HDrezka для Apple TV (tvOS).

## Огляд

tvOS версія HDrezka використовує більшу частину коду з macOS версії:
- **Domain Layer** - повністю перевикористовується
- **Data Layer** - повністю перевикористовується  
- **Core** - перевикористовується з невеликими адаптаціями
- **Presentation** - створені tvOS-специфічні UI компоненти

## Структура проекту

```
HDrezkaTV/
├── HDrezkaTVApp.swift          # Точка входу для tvOS
├── Core/
│   ├── TVAppState.swift        # Стан застосунку для tvOS
│   └── TVDownloaderStub.swift  # Заглушка (завантаження не підтримуються)
├── Presentation/
│   ├── TVContentView.swift     # Головний екран з TabView
│   ├── Home/
│   │   └── TVHomeView.swift
│   ├── Search/
│   │   └── TVSearchView.swift
│   ├── Details/
│   │   └── TVDetailsView.swift
│   ├── Categories/
│   │   └── TVCategoriesView.swift
│   ├── Collections/
│   │   └── TVCollectionsView.swift
│   ├── Bookmarks/
│   │   └── TVBookmarksView.swift
│   ├── WatchingLater/
│   │   └── TVWatchingLaterView.swift
│   ├── Settings/
│   │   └── TVSettingsView.swift
│   ├── Player/
│   │   └── TVPlayerView.swift
│   ├── Auth/
│   │   ├── TVSignInSheetView.swift
│   │   ├── TVSignUpSheetView.swift
│   │   └── TVRestoreSheetView.swift
│   └── Components/
│       └── TVCardView.swift
└── Resources/
    ├── Info.plist
    └── HDrezkaTV.entitlements
```

## Ключові відмінності від macOS версії

### UI/UX адаптації

1. **Навігація з пультом**
   - Використання `.focusable()` для елементів
   - Великі кнопки та області кліку
   - Оптимізовані розміри шрифтів (28-56pt)

2. **Картки фільмів**
   - Ефект масштабування при фокусі (1.1x)
   - Тіні для глибини
   - Ширина 300pt (оптимально для TV)

3. **Відступи**
   - Горизонтальні відступи 90pt (safe area для TV)
   - Вертикальні відступи 60pt

4. **Компоненти**
   - Використання `VideoPlayer` замість власного плеєра
   - Спрощені форми авторизації
   - Alert замість confirmationDialog

### Функціональні обмеження

1. **Завантаження файлів**
   - На tvOS не підтримується файлова система користувача
   - `TVDownloaderStub` забезпечує сумісність коду
   - Функціонал вимкнено

2. **Вікна**
   - Тільки одне вікно (головний екран)
   - Немає WindowGroup для різних екранів
   - Спрощена навігація

3. **Меню**
   - Немає MenuBar
   - Немає Commands
   - Налаштування через окремий таб

## Перевикористаний код

Наступні компоненти використовуються без змін:
- Всі ViewModels (HomeViewModel, SearchViewModel, etc.)
- Всі UseCases
- Всі Repositories та Services
- Всі Parsers
- Domain Entities
- Network layer
- Dependency Injection (FactoryKit Container)

## Необхідні залежності

Переконайтеся, що у вашому `Package.swift` або через Xcode додані:
- Alamofire
- Kingfisher (для завантаження зображень)
- FactoryKit (DI)
- Defaults (для налаштувань)
- SwiftSoup (для парсингу HTML)

## Налаштування Xcode

1. Створіть новий target типу "tvOS App"
2. Додайте всі файли з папки `HDrezkaTV/`
3. У Build Settings переконайтеся що:
   - Deployment Target: tvOS 17.0+
   - Supported Platforms: tvOS
4. Додайте shared схему для Domain/Data layers

## Запуск

1. Відкрийте проект у Xcode
2. Виберіть tvOS simulator або реальний Apple TV
3. Запустіть схему HDrezkaTV
4. Використовуйте симулятор пульта для навігації

## Рекомендації для розробки

### Фокус-навігація
```swift
.focusable(true)
.focused($isFocused)
```

### Масштабування при фокусі
```swift
.scaleEffect(isFocused ? 1.1 : 1.0)
.animation(.easeInOut(duration: 0.2), value: isFocused)
```

### Безпечні відступи для TV
```swift
.padding(.horizontal, 90)  // Horizontal safe area
.padding(.vertical, 60)     // Vertical spacing
```

### Оптимальні розміри
- Заголовки: 48-56pt
- Основний текст: 28-32pt
- Вторинний текст: 24-28pt
- Кнопки: мінімум 80x80pt

## TODO

- [ ] Інтеграція з Top Shelf (рекомендації на головному екрані tvOS)
- [ ] Підтримка Siri Remote жестів
- [ ] Picture-in-Picture для плеєра
- [ ] Зберігання позиції перегляду
- [ ] Синхронізація між пристроями через iCloud
- [ ] Підтримка tvOS 18+ features
- [ ] Оптимізація для Apple TV 4K

## Ліцензія

Такі самі умови, як і в основному проекті HDrezka macOS.

