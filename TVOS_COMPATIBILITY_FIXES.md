# tvOS Compatibility Fixes

Цей документ описує виправлення для сумісності коду між macOS та tvOS.

## ✅ Виправлені проблеми

### 1. YouTubePlayerKit (не підтримується на tvOS)

**Проблема:** YouTubePlayerKit доступний тільки для iOS та macOS

**Рішення:** Conditional compilation

**Файли:**
- `HDrezka/Presentation/Details/DetailsViewModel.swift`
- `HDrezka/Presentation/Details/DetailsView.swift`

```swift
// Import
#if os(macOS)
import YouTubePlayerKit
#endif

// Properties
#if os(macOS)
private(set) var trailer: YouTubePlayer?
#else
private(set) var trailerId: String?
#endif

// UI
#if os(macOS)
if let trailer {
    YouTubePlayerView(trailer) { ... }
}
#else
// На tvOS не показуємо (або показуємо посилання)
#endif
```

## ⚠️ Потенційні проблеми

### 2. NSWorkspace (macOS only)

Використовується для:
- Відкриття URL
- Відкриття файлів у Finder
- Активація вікон

**Рішення:**
```swift
#if os(macOS)
NSWorkspace.shared.open(url)
#elseif os(tvOS)
UIApplication.shared.open(url) // tvOS обмежений
#endif
```

### 3. NSWindow (macOS only)

**Рішення:**
```swift
#if os(macOS)
var window: NSWindow?
#elseif os(tvOS)
// tvOS не має множинних вікон
#endif
```

### 4. Downloader (використовує Aria2 - не працює на tvOS)

**Рішення:** Створена заглушка `TVDownloaderStub` ✅

### 5. Sparkle (автооновлення - тільки macOS)

**Рішення:** Не додавати до tvOS target (вже зроблено)

### 6. FirebaseCrashlytics

**Перевірити:** Чи підтримується на tvOS
**Рішення:** Conditional import якщо потрібно

## 🔍 Як знайти macOS-специфічний код

```bash
# Пошук NSWorkspace
grep -r "NSWorkspace" HDrezka --include="*.swift"

# Пошук NSWindow  
grep -r "NSWindow" HDrezka --include="*.swift"

# Пошук NSImage/NSColor
grep -r "NSImage\|NSColor" HDrezka --include="*.swift"

# Пошук NSApplication
grep -r "NSApplication" HDrezka --include="*.swift"
```

## 📝 Чеклист перед компіляцією tvOS

- [x] YouTubePlayerKit conditional import
- [ ] Перевірити NSWorkspace usage
- [ ] Перевірити NSWindow usage
- [ ] Перевірити file system access
- [ ] Перевірити NotificationCenter usage
- [ ] Переконатись що Downloader не додано до target
- [ ] Переконатись що Sparkle не додано до target

## 🛠 Типові патерни виправлення

### Pattern 1: Conditional Import
```swift
#if os(macOS)
import SomeMacOSFramework
#elseif os(tvOS)
import SomeTVOSAlternative
#endif
```

### Pattern 2: Conditional Property
```swift
#if os(macOS)
var macOSSpecificProperty: Type
#else
var tvOSAlternative: OtherType
#endif
```

### Pattern 3: Conditional Code Block
```swift
func someFunction() {
    #if os(macOS)
    // macOS implementation
    doMacOSStuff()
    #elseif os(tvOS)
    // tvOS implementation
    doTVOSStuff()
    #endif
}
```

### Pattern 4: Type Aliases
```swift
#if os(macOS)
typealias PlatformColor = NSColor
typealias PlatformImage = NSImage
#elseif os(tvOS) || os(iOS)
typealias PlatformColor = UIColor
typealias PlatformImage = UIImage
#endif
```

## 🚀 Automation Script

Створіть скрипт для перевірки:

```bash
#!/bin/bash
# check_tvos_compatibility.sh

echo "Checking tvOS compatibility..."

# Check for macOS-only APIs
echo "=== NSWorkspace usage ==="
grep -rn "NSWorkspace" HDrezka --include="*.swift" | grep -v "#if os(macOS)"

echo "=== NSWindow usage ==="
grep -rn "NSWindow" HDrezka --include="*.swift" | grep -v "#if os(macOS)"

echo "=== NSApplication usage ==="
grep -rn "NSApplication" HDrezka --include="*.swift" | grep -v "#if os(macOS)"

echo "Done!"
```

## 📚 Додаткові ресурси

- [Apple Platform Differences](https://developer.apple.com/documentation/xcode/differences-between-macos-ios-watchos-and-tvos)
- [Conditional Compilation](https://docs.swift.org/swift-book/ReferenceManual/Statements.html#ID538)
- [tvOS Programming Guide](https://developer.apple.com/tvos/)

---

**Примітка:** Після виправлення кожної проблеми - тестуйте компіляцію для обох платформ!

