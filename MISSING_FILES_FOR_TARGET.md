# ❗ Додаткові файли для tvOS Target

## Обов'язково додати до HDrezkaTV target:

### 1. State файл ✅
```
HDrezka/Presentation/Utils/State.swift
```

**Містить:**
- `DataState<T>` - стан завантаження даних  
- `DataPaginationState` - стан pagination
- `EmptyState` - порожній стан

**Як додати:**
1. Відкрити Xcode
2. Знайти файл `HDrezka/Presentation/Utils/State.swift`
3. File Inspector (праворуч) → Target Membership
4. ✅ Поставити галочку біля `HDrezkaTV`

---

### 2. Інші корисні файли з Utils (опціонально)

Можете додати якщо потрібні:

```
HDrezka/Presentation/Utils/Array.swift
HDrezka/Presentation/Utils/Int.swift
HDrezka/Presentation/Utils/Set.swift
HDrezka/Presentation/Utils/Shimmer.swift
HDrezka/Presentation/Utils/String.swift
HDrezka/Presentation/Utils/URL.swift
HDrezka/Presentation/Utils/View.swift
```

**⚠️ НЕ додавати:**
```
❌ HDrezka/Presentation/Utils/WindowAccessor.swift  (NSWindow - macOS only)
❌ HDrezka/Presentation/Utils/NSImage.swift         (NSImage - macOS only)
```

---

## Вже додані до TVExtensions.swift ✅

- ✅ Theme
- ✅ DefaultQuality
- ✅ SpatialAudio
- ✅ Genres
- ✅ BookmarkFilters
- ✅ Download (stub)
- ✅ DownloadData (stub)

---

## Після додавання State.swift:

```bash
Cmd + B  # Build
```

**Має компілюватись!** ✅

