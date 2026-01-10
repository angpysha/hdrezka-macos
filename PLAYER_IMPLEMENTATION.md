# 🎬 Реалізація плеєра для tvOS

## ✅ Що реалізовано

### 1. TVWatchOverlayViewModel
**Файл:** `RezkaTV/Presentation/Details/TVWatchOverlayView.swift`

**Функціонал:**
- ✅ Повторює macOS-логіку вибору озвучки, сезону, епізоду та якості
- ✅ Перевіряє доступ користувача до преміум-озвучок та заблокованих якостей
- ✅ Автоматично підбирає стартові значення (озвучка, сезон, епізод, якість)
- ✅ Завантажує сезони/епізоди для серіалів через `GetSeriesSeasonsUseCase`
- ✅ Завантажує потік відео через `GetMovieVideoUseCase`

### 2. TVWatchOverlayView
**Файл:** `RezkaTV/Presentation/Details/TVWatchOverlayView.swift`

**Особливості:**
- ✅ Відображає горизонтальні каруселі для озвучок, сезонів, епізодів і якостей
- ✅ Підтримує фокус та керування Siri Remote
- ✅ Показує стани завантаження та помилки
- ✅ Формує `TVPlayerConfiguration` і передає його в плеєр

### 3. TVPlayerView
**Файл:** `RezkaTV/Presentation/Player/TVPlayerViewController.swift`

**Особливості:**
- ✅ Приймає готову конфігурацію з відео та виборами користувача
- ✅ Створює `AVPlayer` з обраною якістю
- ✅ Відтворює контент у `AVPlayerViewController`
- ✅ Підтримує Picture-in-Picture та зовнішній екран

---

## 🎮 Як це працює

```
1. Користувач натискає "Дивитись"
   ↓
2. TVDetailsView відкриває TVWatchOverlayView у sheet
   ↓
3. Користувач обирає озвучку/сезон/епізод/якість
   ↓
4. ViewModel отримує необхідні дані з use case-ів
   ↓
5. Формується TVPlayerConfiguration з MovieVideo та вибраними параметрами
   ↓
6. fullScreenCover показує TVPlayerView
   ↓
7. AVPlayer починає відтворення HLS потоку
```

---

## 📝 Використання в TVDetailsView

```swift
struct TVDetailsView: View {
    @State private var isWatchOverlayPresented = false
    @State private var activePlayerConfig: TVPlayerConfiguration?

    var body: some View {
        // ... контент ...
        Button {
            playMovie()              // ← Відкрити overlay з виборами
        } label: {
            Text("Дивитись")
        }
        .sheet(isPresented: $isWatchOverlayPresented) {
            if let details = viewModel.state.data {
                TVWatchOverlayView(details: details) { config in
                    activePlayerConfig = config
                } onCancel: {
                    activePlayerConfig = nil
                }
            }
        }
        .fullScreenCover(item: $activePlayerConfig) { config in
            TVPlayerView(configuration: config)  // ← Плеєр
        }
    }

    private func playMovie() {
        isWatchOverlayPresented = true
    }
}
```

---

## 🎯 Основні функції

### 1. Вибір озвучки (з урахуванням преміум)

```swift
if acting.isPremium, isUserPremium == nil {
    error = String(localized: "key.premium_content")
    return
}

selectedActing = acting
```

### 2. Підтримка серіалів

```swift
getSeriesSeasonsUseCase(movieId: details.movieId,
                        voiceActing: acting,
                        favs: details.favs)
    .sink { ... } receiveValue: { seasons in
        self.seasons = seasons
        self.selectSeason(seasons.first ?? ...)
    }
```

### 3. Завантаження відео та вибір якості

```swift
getMovieVideoUseCase(voiceActing: acting,
                     season: season,
                     episode: episode,
                     favs: details.favs)
    .sink { ... } receiveValue: { movie in
        self.movie = movie
        self.availableQualities = movie.getAvailableQualities()
        self.lockedQualities = movie.getLockedQualities()
        self.selectedQuality = defaultQualitySelection(from: movie)
    }
```

### 4. Формування конфігурації для плеєра

```swift
func makeConfiguration() -> TVPlayerConfiguration? {
    guard let movie, let acting = selectedActing else { return nil }
    return TVPlayerConfiguration(
        details: details,
        video: movie,
        acting: acting,
        season: details.series != nil ? selectedSeason : nil,
        episode: details.series != nil ? selectedEpisode : nil,
        quality: selectedQuality
    )
}
```

---

## 🚀 Додаткові можливості

### TODO список покращень:

#### 1. Збереження позиції відтворення ⏱️

```swift
// При закритті плеєра
.onDisappear {
    player.pause()
    
    // Зберегти позицію
    let currentTime = player.currentTime().seconds
    savePosition(movieId: details.movieId, position: currentTime)
}

// При відкритті плеєра
Task {
    if let savedPosition = loadPosition(for: details.movieId) {
        let time = CMTime(seconds: savedPosition, preferredTimescale: 1)
        await player.seek(to: time)
    }
}
```

#### 2. Вибір озвучки 🎭

Додати menu для вибору озвучки перед відтворенням:

```swift
Menu("Вибрати озвучку") {
    ForEach(details.voiceActing ?? []) { acting in
        Button(acting.name) {
            selectedActing = acting
            loadVideo()
        }
    }
}
```

#### 3. Вибір якості 📺

Додати menu для вибору якості:

```swift
Menu("Якість") {
    ForEach(movieVideo.getAvailableQualities(), id: \.self) { quality in
        Button(quality) {
            selectedQuality = quality
            updateVideoQuality()
        }
    }
}
```

#### 4. Субтитри 📝

```swift
// AVPlayer автоматично підхопить субтитри з HLS
// Або додати вручну:
if !movieVideo.subtitles.isEmpty {
    for subtitle in movieVideo.subtitles {
        // Додати subtitle track
        let asset = AVURLAsset(url: subtitle.url)
        // ... налаштування
    }
}
```

#### 5. Picture-in-Picture 🖼️

```swift
// Вже підтримується!
controller.allowsPictureInPicturePlayback = true
```

#### 6. Прогрес перегляду 📊

```swift
// Відстежування прогресу
player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { time in
    let progress = time.seconds / player.currentItem?.duration.seconds ?? 1
    // Оновити прогрес
}
```

---

## 🎮 tvOS Контроли

### Native контроли AVPlayerViewController:

- **Click center** - Play/Pause
- **Swipe left/right** - Перемотка (10 сек)
- **Swipe up** - Інформація про відео
- **Swipe down** - Показати прогрес
- **Menu button** - Закрити плеєр

### Додаткові жести:

- **Довге натискання** - Швидка перемотка
- **Подвійне натискання** - Пропустити вперед/назад

---

## 🔧 Налаштування

### Defaults (користувацькі налаштування):

```swift
@Default(.defaultQuality) private var defaultQuality  // Якість
@Default(.rate) private var rate                      // Швидкість
@Default(.volume) private var volume                  // Гучність
@Default(.isMuted) private var isMuted               // Без звуку
@Default(.spatialAudio) private var spatialAudio     // Просторовий звук
```

---

## 📱 Інтеграція

### В TVDetailsView:

```swift
// 1. State для modal
@State private var isPlayerPresented = false

// 2. Кнопка відтворення
Button {
    playMovie()
} label: {
    HStack {
        Image(systemName: "play.fill")
        Text("Дивитись")
    }
}

// 3. fullScreenCover
.fullScreenCover(isPresented: $isPlayerPresented) {
    if let details = viewModel.state.data {
        TVPlayerView(configuration: config)
    }
}

// 4. Функція відкриття
private func playMovie() {
    isPlayerPresented = true
}
```

---

## 🎯 Приклад використання

```swift
// Просто відкрити плеєр з MovieDetailed
let details: MovieDetailed = ...
let playerView = TVPlayerView(configuration: config)

// Плеєр автоматично:
// 1. Завантажить відео потік
// 2. Вибере озвучку
// 3. Для серіалів завантажить сезони
// 4. Створить AVPlayer
// 5. Почне відтворення
```

---

## ⚠️ Обмеження та примітки

### tvOS обмеження:

1. **Файли не зберігаються** - тільки streaming
2. **Обмежена файлова система** - кеш HLS автоматичний
3. **Немає background playback** - тільки активний режим

### Переваги native AVPlayerViewController:

- ✅ Автоматичні контроли (Play/Pause/Scrubbing)
- ✅ Siri Remote integration
- ✅ Picture-in-Picture
- ✅ Субтитри з HLS
- ✅ AirPlay підтримка
- ✅ Адаптивний streaming (HLS)

---

## 🚀 Тестування

1. Запустити RezkaTV на simulator
2. Відкрити деталі фільму
3. Натиснути "Дивитись"
4. Плеєр має завантажитись та почати відтворення

### Контроли в simulator:

```
Space - Play/Pause
Arrow Left/Right - Перемотка
Escape - Закрити
```

---

## 📚 Документація Apple

- [AVPlayerViewController](https://developer.apple.com/documentation/avkit/avplayerviewcontroller)
- [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer)
- [HLS Best Practices](https://developer.apple.com/documentation/http_live_streaming)
- [tvOS Player Guidelines](https://developer.apple.com/design/human-interface-guidelines/playing-video)

---

**Плеєр готовий до використання! 🎬**

