# Інструкція по налаштуванню tvOS Target

Цей документ описує кроки для додавання tvOS target до існуючого Xcode проекту HDrezka.

## Крок 1: Створення tvOS Target

1. Відкрийте проект `HDrezka.xcodeproj` в Xcode
2. В Project Navigator виберіть проект (синя іконка зверху)
3. Натисніть "+" внизу списку targets
4. Виберіть "App" під tvOS секцією
5. Заповніть поля:
   - Product Name: `HDrezkaTV`
   - Team: Ваша команда
   - Organization Identifier: `com.hdrezka` (або ваш)
   - Bundle Identifier: `com.hdrezka.tv`
   - Interface: SwiftUI
   - Language: Swift
6. Натисніть "Finish"

## Крок 2: Налаштування Build Settings

### Основні налаштування

1. Виберіть HDrezkaTV target
2. Перейдіть на вкладку "Build Settings"
3. Налаштуйте наступні параметри:

```
Deployment Info:
- Minimum Deployments: tvOS 17.0

Signing & Capabilities:
- Automatically manage signing: Так
- Team: Ваша команда

Build Settings:
- Product Bundle Identifier: com.hdrezka.tv
- Product Name: HDrezkaTV
- Display Name: HDrezka
```

## Крок 3: Додавання файлів до Target

### Файли HDrezkaTV (tvOS-специфічні)

Додайте всі файли з папки `HDrezkaTV/` до tvOS target:

1. Правою кнопкою на HDrezkaTV target → New Group
2. Назвіть його "HDrezkaTV"
3. Додайте файли:

```
HDrezkaTV/
├── HDrezkaTVApp.swift
├── Core/
│   ├── TVAppState.swift
│   └── TVDownloaderStub.swift
├── Presentation/
│   ├── TVContentView.swift
│   ├── Home/TVHomeView.swift
│   ├── Search/TVSearchView.swift
│   ├── Details/TVDetailsView.swift
│   ├── Categories/TVCategoriesView.swift
│   ├── Collections/TVCollectionsView.swift
│   ├── Bookmarks/TVBookmarksView.swift
│   ├── WatchingLater/TVWatchingLaterView.swift
│   ├── Settings/TVSettingsView.swift
│   ├── Player/TVPlayerView.swift
│   ├── Auth/
│   │   ├── TVSignInSheetView.swift
│   │   ├── TVSignUpSheetView.swift
│   │   └── TVRestoreSheetView.swift
│   └── Components/TVCardView.swift
└── Resources/
    ├── Info.plist
    └── HDrezkaTV.entitlements
```

### Shared файли (з macOS проекту)

Додайте до tvOS target наступні існуючі файли:

**Domain Layer** (всі файли):
- `HDrezka/Domain/Entities/` - всі файли ✅
- `HDrezka/Domain/Repositories/` - всі файли ✅
- `HDrezka/Domain/UseCases/` - всі файли ✅

**Data Layer** (всі файли):
- `HDrezka/Data/Network/` - всі файли ✅
- `HDrezka/Data/Parsing/` - всі файли ✅
- `HDrezka/Data/Repositories/` - всі файли ✅
- `HDrezka/Data/Utils/` - всі файли (крім тих що використовують NSWorkspace) ✅

**Core** (вибіркові файли):
- `HDrezka/Core/Const.swift` ✅
- `HDrezka/Core/Container.swift` ✅
- `HDrezka/Core/Defaults.swift` ✅
- `HDrezka/Core/Errors.swift` ✅
- ❌ НЕ додавайте `Downloader.swift` (використовуємо TVDownloaderStub)

**Presentation ViewModels**:
- `HDrezka/Presentation/Home/HomeViewModel.swift` ✅
- `HDrezka/Presentation/Search/SearchViewModel.swift` ✅
- `HDrezka/Presentation/Details/DetailsViewModel.swift` ✅
- `HDrezka/Presentation/Categories/CategoriesViewModel.swift` ✅
- `HDrezka/Presentation/Collections/CollectionsViewModel.swift` ✅
- `HDrezka/Presentation/Bookmarks/BookmarksViewModel.swift` ✅
- `HDrezka/Presentation/WatchingLater/WatchingLaterViewModel.swift` ✅

**Presentation Utils** (вибіркові):
- Додайте Swift extensions які не використовують macOS APIs

## Крок 4: Додавання SPM залежностей

1. File → Add Package Dependencies
2. Додайте наступні пакети для tvOS target:

```
Alamofire: https://github.com/Alamofire/Alamofire.git
Kingfisher: https://github.com/onevcat/Kingfisher.git
FactoryKit: https://github.com/hmlongco/Factory.git
Defaults: https://github.com/sindresorhus/Defaults.git
SwiftSoup: https://github.com/scinfu/SwiftSoup.git
```

3. У діалозі вибору target'ів виберіть HDrezkaTV для кожного пакету

## Крок 5: Налаштування Info.plist

1. Виберіть HDrezkaTV target
2. Info tab
3. Переконайтеся що наявні ключі:
   - Bundle name: HDrezka
   - Bundle display name: HDrezka
   - App Transport Security Settings:
     - Allow Arbitrary Loads: YES

Або використовуйте готовий `Info.plist` з `HDrezkaTV/Resources/`

## Крок 6: Налаштування Capabilities

1. Виберіть HDrezkaTV target
2. Signing & Capabilities tab
3. Натисніть "+ Capability"
4. Додайте:
   - App Groups (якщо потрібна синхронізація між пристроями)
   - Keychain Sharing

## Крок 7: Assets Catalog

1. Створіть новий Assets catalog для tvOS або використовуйте існуючий
2. Додайте App Icon для tvOS:
   - Розміри: 400x240, 1280x768, 2320x1410 (різні варіанти)
3. Додайте Launch Image (опційно)
4. Додайте Top Shelf Image (рекомендовано)

## Крок 8: Localization

Якщо ви використовуєте `Localizable.xcstrings`:

1. Виберіть файл у Project Navigator
2. File Inspector → Target Membership
3. Позначте галочку біля HDrezkaTV

## Крок 9: Компіляція умовного коду

Якщо є код, який працює тільки на macOS, огорніть його:

```swift
#if os(macOS)
// macOS specific code
#elseif os(tvOS)
// tvOS specific code
#endif
```

Приклад:
```swift
#if os(macOS)
import AppKit
typealias PlatformImage = NSImage
#elseif os(tvOS)
import UIKit
typealias PlatformImage = UIImage
#endif
```

## Крок 10: Тестування

1. Виберіть HDrezkaTV scheme
2. Виберіть Apple TV simulator (або пристрій)
3. Натисніть Cmd+R для запуску
4. Тестуйте навігацію з пультом (симулятор: Option+Shift+рух мишкою)

## Поширені проблеми та рішення

### Помилка: "Module compiled with Swift X.X cannot be imported"

**Рішення**: Переконайтеся що всі targets використовують однакову версію Swift:
- Build Settings → Swift Language Version

### Помилка: "Use of undeclared type NSImage/NSColor"

**Рішення**: Замініть macOS типи на tvOS:
```swift
#if os(macOS)
import AppKit
#elseif os(tvOS) || os(iOS)
import UIKit
#endif
```

### Помилка компонування (linker errors)

**Рішення**: Перевірте що всі необхідні файли додані до Compile Sources:
- Target → Build Phases → Compile Sources

### Layout не оптимальний для TV

**Рішення**: Переконайтеся що використовуєте відступи для tvOS:
```swift
.padding(.horizontal, 90)  // Safe area for TV
```

## Додаткові рекомендації

### Focus Engine

Використовуйте фокус для навігації:
```swift
@FocusState private var focusedItem: Item?

SomeView()
    .focusable()
    .focused($focusedItem, equals: item)
```

### Testing на реальному пристрої

1. Підключіть Apple TV до Mac через USB-C
2. Xcode → Window → Devices and Simulators
3. Виберіть ваш Apple TV
4. Запустіть проект

### Performance

- Використовуйте `LazyVStack`/`LazyHStack` для списків
- Оптимізуйте зображення (Kingfisher автоматично кешує)
- Уникайте складних анімацій

## Фінальна перевірка

- [ ] Проект компілюється без помилок
- [ ] Всі екрани відкриваються
- [ ] Навігація працює з пультом
- [ ] Фокус переміщується коректно
- [ ] Авторизація працює
- [ ] Відео відтворюється
- [ ] App icon відображається
- [ ] Локалізація працює

## Наступні кроки

Після успішного налаштування:
1. Налаштуйте CI/CD для tvOS
2. Додайте Unit Tests
3. Налаштуйте TestFlight для бета-тестування
4. Підготуйте до публікації в App Store

---

**Потрібна допомога?** Перегляньте документацію Apple:
- [tvOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/tvos)
- [Focus Management in tvOS](https://developer.apple.com/documentation/uikit/focus-based_navigation)

