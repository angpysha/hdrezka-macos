# HDrezka для tvOS 📺

Адаптація HDrezka для Apple TV з перевикористанням 85% коду з macOS версії.

## 🚀 Швидкий старт

### Крок 1: Додати tvOS Target

```bash
# 1. Відкрийте Xcode
open HDrezka.xcodeproj

# 2. Створіть новий tvOS App target (назва: HDrezkaTV)
# File → New → Target → tvOS → App
```

### Крок 2: Додати файли до проекту

Всі необхідні файли вже створені в папці `HDrezkaTV/`:

```
HDrezkaTV/
├── HDrezkaTVApp.swift          ✅ Entry point
├── Core/                        ✅ tvOS-specific core
├── Presentation/                ✅ All UI screens
│   ├── Auth/                   (Sign In, Sign Up, Restore)
│   ├── Home/                   (Main screen)
│   ├── Search/                 (Search functionality)
│   ├── Details/                (Movie details)
│   ├── Categories/             (Browse categories)
│   ├── Collections/            (Movie collections)
│   ├── Bookmarks/              (User bookmarks)
│   ├── WatchingLater/          (Watch later list)
│   ├── Settings/               (App settings)
│   ├── Player/                 (Video player)
│   └── Components/             (Reusable UI)
└── Resources/                   ✅ Configs
```

### Крок 3: Додати Shared код

Додайте до tvOS target (через Target Membership в Xcode):

**✅ Domain Layer** (весь):
- `HDrezka/Domain/Entities/`
- `HDrezka/Domain/Repositories/`
- `HDrezka/Domain/UseCases/`

**✅ Data Layer** (весь):
- `HDrezka/Data/Network/`
- `HDrezka/Data/Parsing/`
- `HDrezka/Data/Repositories/`
- `HDrezka/Data/Utils/`

**✅ Core** (вибірково):
- `HDrezka/Core/Const.swift` ✅
- `HDrezka/Core/Container.swift` ✅
- `HDrezka/Core/Defaults.swift` ✅
- `HDrezka/Core/Errors.swift` ✅
- `HDrezka/Core/Downloader.swift` ❌ (використовуємо TVDownloaderStub)

**✅ ViewModels**:
- Всі `*ViewModel.swift` файли з Presentation layer

### Крок 4: Додати залежності

Через SPM додайте для tvOS target:

```swift
// Package Dependencies
Alamofire
Kingfisher
FactoryKit
Defaults
SwiftSoup
```

### Крок 5: Запустити

```bash
# Виберіть HDrezkaTV scheme
# Виберіть Apple TV simulator
# Cmd + R
```

## 📁 Структура файлів

### tvOS-Specific Files

| File | Purpose |
|------|---------|
| `HDrezkaTVApp.swift` | App entry point |
| `TVContentView.swift` | Main screen with TabView |
| `TVAppState.swift` | App state management |
| `TVDownloaderStub.swift` | Download stub (not supported) |
| `TV*View.swift` | All UI screens adapted for TV |
| `TVCardView.swift` | Movie card with focus effects |
| `TVExtensions.swift` | Helper extensions |

### Shared Files (з macOS)

- ✅ **100% Domain Layer** - бізнес-логіка
- ✅ **100% Data Layer** - networking, parsing
- ✅ **100% ViewModels** - presentation logic
- ❌ **0% Views** - повністю нові для tvOS

## 🎨 UI Особливості

### Розміри для tvOS

```swift
// Шрифти
Title: 48-56pt
Body: 28-32pt
Caption: 24-28pt

// Кнопки
Min size: 80x80pt
Padding: 20-40pt

// Відступи
Horizontal: 90pt (safe area)
Vertical: 60pt

// Картки
Width: 300pt
Aspect ratio: 2:3
```

### Focus Effects

```swift
// Автоматичне масштабування при фокусі
.focusable(true)
.scaleEffect(isFocused ? 1.1 : 1.0)
.shadow(radius: isFocused ? 20 : 8)
```

## 🎮 Навігація

### Apple TV Remote

- **Touch Surface** - Pan для навігації
- **Click** - Select
- **Menu Button** - Back
- **Play/Pause** - Video control
- **Siri** - Voice search (TODO)

### Focus Management

```swift
@FocusState private var focusedItem: Item?

ItemView()
    .focusable()
    .focused($focusedItem, equals: item)
```

## 📺 Плеєр

Використовує нативний `VideoPlayer` з автоматичними:
- ✅ Контролами відтворення
- ✅ Субтитрами
- ✅ Picture-in-Picture
- ✅ Жестами (swipe для перемотки)
- ✅ Siri Remote інтеграцією

```swift
VideoPlayer(player: player)
    .ignoresSafeArea()
```

## 🔧 Налаштування

### Info.plist

Основні ключі:
```xml
<key>CFBundleDisplayName</key>
<string>HDrezka</string>

<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Entitlements

```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.hdrezka.tv</string>
</array>
```

## 🧪 Тестування

### Simulator

```bash
# Клавіатурні скорочення
Shift + Arrow Keys - Navigation
Enter - Select
Escape - Menu (Back)
```

### Справжній пристрій

1. Підключіть Apple TV через USB-C
2. Window → Devices and Simulators
3. Виберіть ваш Apple TV
4. Run

## ⚠️ Обмеження tvOS

| Feature | macOS | tvOS |
|---------|-------|------|
| File downloads | ✅ | ❌ |
| Multiple windows | ✅ | ❌ |
| Menu bar | ✅ | ❌ |
| Keyboard/Mouse | ✅ | ❌ |
| File system access | ✅ | ❌ Limited |
| Background tasks | ✅ | ⚠️ Limited |

## 📚 Документація

- [📖 README_TVOS.md](../README_TVOS.md) - Детальний огляд
- [🏗 TVOS_ARCHITECTURE.md](../TVOS_ARCHITECTURE.md) - Архітектура
- [⚙️ TVOS_SETUP_GUIDE.md](../TVOS_SETUP_GUIDE.md) - Налаштування

## 🎯 TODO

### Базовий функціонал ✅
- [x] Навігація по екранах
- [x] Пошук фільмів
- [x] Деталі фільму
- [x] Відтворення відео
- [x] Авторизація
- [x] Закладки
- [x] Налаштування

### Покращення 📋
- [ ] Top Shelf Extension
- [ ] Siri Integration
- [ ] SharePlay Support
- [ ] iCloud Sync
- [ ] Picture-in-Picture
- [ ] Universal Search
- [ ] Offline Support (якщо можливо)

## 🤝 Contributing

1. Нові UI компоненти йдуть в `HDrezkaTV/Presentation/Components/`
2. Спільна логіка - в shared ViewModels
3. Platform-specific код огортати `#if os(tvOS)`

```swift
#if os(macOS)
// macOS specific
#elseif os(tvOS)
// tvOS specific
#endif
```

## 📝 Приклад коду

### Простий tvOS View

```swift
import SwiftUI

struct MyTVView: View {
    @State private var viewModel = MyViewModel()
    @FocusState private var focusedItem: Item?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 300), spacing: 50)
            ], spacing: 50) {
                ForEach(items) { item in
                    CardView(item: item)
                        .focusable()
                        .focused($focusedItem, equals: item)
                }
            }
            .padding(.horizontal, 90)  // TV safe area
        }
        .task {
            viewModel.load()
        }
    }
}
```

## 🐛 Debug Tips

### Focus не працює?
```swift
// Переконайтеся що додали:
.focusable(true)
```

### Layout виглядає погано?
```swift
// Використовуйте TV safe area:
.padding(.horizontal, 90)
```

### Шрифти маленькі?
```swift
// Мінімум 28pt для body text
.font(.system(size: 28))
```

## 📞 Support

Для питань та багів:
- Читайте документацію вище
- Перевіряйте Xcode console
- Тестуйте на справжньому Apple TV

## 📄 License

Така сама ліцензія як у HDrezka macOS проекту.

---

**Готово до запуску! 🚀**

Просто відкрийте Xcode, додайте tvOS target, та насолоджуйтесь перегляді на великому екрані! 📺✨

