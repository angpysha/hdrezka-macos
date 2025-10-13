# tvOS Target: Що додавати, а що НІ

## ✅ ДОДАТИ до tvOS target

### Core (вибірково)
```
✅ HDrezka/Core/Const.swift
✅ HDrezka/Core/Container.swift
✅ HDrezka/Core/Defaults.swift
✅ HDrezka/Core/Errors.swift
❌ HDrezka/Core/Downloader.swift        (використовуємо TVDownloaderStub)
❌ HDrezka/Core/AppState.swift          (використовуємо TVAppState)
```

### Domain (всі файли)
```
✅ HDrezka/Domain/Entities/**/*.swift   (всі)
✅ HDrezka/Domain/Repositories/**/*.swift (всі)
✅ HDrezka/Domain/UseCases/**/*.swift   (всі)
```

### Data (всі файли)
```
✅ HDrezka/Data/Network/**/*.swift      (всі)
✅ HDrezka/Data/Parsing/**/*.swift      (всі)
✅ HDrezka/Data/Repositories/**/*.swift (всі)
✅ HDrezka/Data/Utils/CustomInterceptor.swift
✅ HDrezka/Data/Utils/CustomMonitor.swift
✅ HDrezka/Data/Utils/Decrypt.swift
❌ HDrezka/Data/Utils/Utils.swift       (має NSWorkspace - потребує fix)
```

### Presentation - ViewModels (всі)
```
✅ HDrezka/Presentation/Home/HomeViewModel.swift
✅ HDrezka/Presentation/Search/SearchViewModel.swift
✅ HDrezka/Presentation/Details/DetailsViewModel.swift  ✅ (вже виправлено)
✅ HDrezka/Presentation/Categories/CategoriesViewModel.swift
✅ HDrezka/Presentation/Collections/CollectionsViewModel.swift
✅ HDrezka/Presentation/Bookmarks/BookmarksViewModel.swift
✅ HDrezka/Presentation/WatchingLater/WatchingLaterViewModel.swift
✅ HDrezka/Presentation/List/ListViewModel.swift
✅ HDrezka/Presentation/Person/PersonViewModel.swift
✅ HDrezka/Presentation/Comments/CommentsViewModel.swift
```

---

## ❌ НЕ ДОДАВАТИ до tvOS target

### Entry Point
```
❌ HDrezka/HDrezkaApp.swift             (macOS entry point)
   → Використовуємо HDrezkaTV/HDrezkaTVApp.swift
```

### Presentation - Views (всі macOS UI)
```
❌ HDrezka/Presentation/ContentView.swift
❌ HDrezka/Presentation/Home/HomeView.swift
❌ HDrezka/Presentation/Search/SearchView.swift
❌ HDrezka/Presentation/Details/DetailsView.swift
❌ HDrezka/Presentation/Categories/CategoriesView.swift
❌ HDrezka/Presentation/Collections/CollectionsView.swift
❌ HDrezka/Presentation/Bookmarks/BookmarksView.swift
❌ HDrezka/Presentation/WatchingLater/WatchingLaterView.swift
❌ HDrezka/Presentation/List/ListView.swift
❌ HDrezka/Presentation/Person/PersonView.swift
❌ HDrezka/Presentation/Comments/CommentsView.swift

→ Використовуємо HDrezkaTV/Presentation/TV*.swift
```

### Presentation - Components (macOS specific)
```
❌ HDrezka/Presentation/Components/Cards/*.swift
❌ HDrezka/Presentation/Components/Sheets/*.swift
❌ HDrezka/Presentation/Components/DownloadsView.swift
❌ HDrezka/Presentation/Components/ImageView.swift
❌ HDrezka/Presentation/Components/LicensesView.swift
❌ HDrezka/Presentation/Components/SettingsView.swift
❌ HDrezka/Presentation/Components/SpoilerView.swift
❌ HDrezka/Presentation/Components/UpdateButton.swift
❌ HDrezka/Presentation/Components/EmptyStateView.swift
❌ HDrezka/Presentation/Components/ErrorStateView.swift
❌ HDrezka/Presentation/Components/LoadingStateView.swift

→ Використовуємо HDrezkaTV/Presentation/Components/TV*.swift
```

### Presentation - Utils (macOS specific)
```
❌ HDrezka/Presentation/Utils/WindowAccessor.swift  (NSWindow)
❌ HDrezka/Presentation/Utils/NSImage.swift         (NSImage)
❌ HDrezka/Presentation/Utils/Array.swift           (можливо OK)
❌ HDrezka/Presentation/Utils/Int.swift             (можливо OK)
❌ HDrezka/Presentation/Utils/Set.swift             (можливо OK)
❌ HDrezka/Presentation/Utils/Shimmer.swift         (можливо OK)
❌ HDrezka/Presentation/Utils/State.swift           (можливо OK)
❌ HDrezka/Presentation/Utils/String.swift          (можливо OK)
❌ HDrezka/Presentation/Utils/URL.swift             (можливо OK)
❌ HDrezka/Presentation/Utils/View.swift            (можливо OK - перевірити)

→ Використовуємо HDrezkaTV/Presentation/Utils/TVExtensions.swift
```

### Player (macOS specific)
```
❌ HDrezka/Presentation/Player/CustomAVPlayer.swift
❌ HDrezka/Presentation/Player/PlayerView.swift
❌ HDrezka/Presentation/Player/SliderWithoutText.swift
❌ HDrezka/Presentation/Player/SliderWithText.swift

→ Використовуємо HDrezkaTV/Presentation/Player/TVPlayerView.swift
```

---

## 🔧 Файли що потребують виправлення

### 1. DetailsViewModel.swift ✅
**Статус:** Виправлено!
- Додано conditional compilation для YouTubePlayerKit

### 2. DetailsView.swift ✅
**Статус:** Виправлено!
- Додано conditional compilation для YouTubePlayerKit

### 3. Utils.swift (якщо додавати)
**Проблема:** Використовує NSWorkspace
**Рішення:** 
```swift
#if os(macOS)
import AppKit
// NSWorkspace code
#elseif os(tvOS)
import UIKit
// Alternative for tvOS
#endif
```

---

## 📋 Швидкий чеклист

### Крок 1: Додати tvOS файли ✅
```bash
HDrezkaTV/**/*.swift  → Всі файли в target
```

### Крок 2: Додати Domain/Data ✅
```bash
HDrezka/Domain/**/*.swift       → Target Membership: HDrezkaTV
HDrezka/Data/**/*.swift         → Target Membership: HDrezkaTV
```

### Крок 3: Додати Core (вибірково) ✅
```bash
✅ Const.swift
✅ Container.swift
✅ Defaults.swift
✅ Errors.swift
❌ НЕ Downloader.swift
❌ НЕ AppState.swift
```

### Крок 4: Додати ViewModels ✅
```bash
HDrezka/Presentation/**/*ViewModel.swift → Target Membership: HDrezkaTV
```

### Крок 5: НЕ додавати Views ❌
```bash
HDrezka/Presentation/**/*View.swift → НЕ позначати HDrezkaTV
```

---

## 🎯 Швидкий спосіб в Xcode

1. **Відкрити папку в Xcode**
2. **Виділити всі файли** (Cmd + A в папці)
3. **File Inspector** → Target Membership
4. **Поставити галочку** біля HDrezkaTV

**Застосувати для:**
- Папка `Domain/` целиком ✅
- Папка `Data/` целиком ✅
- Тільки `*ViewModel.swift` з `Presentation/` ✅

**НЕ застосовувати для:**
- Папка `Presentation/` целиком ❌
- Файли `*View.swift` ❌

---

## 🐛 Типові помилки

### ❌ "Cannot find 'NSWorkspace' in scope"
**Причина:** Додали macOS View до tvOS target
**Рішення:** Забрати галочку Target Membership для цього файлу

### ❌ "Cannot find 'YouTubePlayerKit' in scope"
**Причина:** Була виправлена ✅
**Статус:** Більше не повинна з'являтися

### ❌ "Cannot find 'Downloader' in scope"
**Причина:** Додали macOS файл що використовує Downloader
**Рішення:** Використати TVDownloaderStub або не додавати файл

### ❌ Duplicate symbols
**Причина:** Додали і macOS і tvOS версію одного файлу
**Рішення:** Залишити тільки одну версію в target

---

## ✅ Фінальна перевірка

Після додавання файлів:

```bash
# В терміналі
cd /Users/andrii/Projects/hdrezka-macos

# Перевірити чи компілюється macOS
xcodebuild -scheme HDrezka -sdk macosx clean build

# Перевірити чи компілюється tvOS
xcodebuild -scheme HDrezkaTV -sdk appletvos clean build
```

Або в Xcode:
1. Scheme: HDrezka → Cmd + B (має компілюватись ✅)
2. Scheme: HDrezkaTV → Cmd + B (має компілюватись ✅)

---

## 📝 Примітки

- **ViewModels** - додаємо (платформо-незалежні)
- **Views** - НЕ додаємо (платформо-специфічні)
- **Domain/Data** - додаємо (повністю shared)
- **Core** - вибірково (деякі платформо-специфічні)

**Золоте правило:** Якщо файл містить `import AppKit` або `NSWindow/NSWorkspace` - НЕ додавати до tvOS!

