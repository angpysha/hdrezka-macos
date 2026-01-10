import Combine
import Defaults
import FactoryKit
import SwiftUI

@Observable
final class TVWatchOverlayViewModel {
    @ObservationIgnored @LazyInjected(\.getMovieVideoUseCase) private var getMovieVideoUseCase
    @ObservationIgnored @LazyInjected(\.getSeriesSeasonsUseCase) private var getSeriesSeasonsUseCase

    @ObservationIgnored private var cancellables: Set<AnyCancellable> = []

    private(set) var voiceActings: [MovieVoiceActing] = []
    private(set) var selectedActing: MovieVoiceActing?

    private(set) var seasons: [MovieSeason]?
    private(set) var selectedSeason: MovieSeason?

    private(set) var selectedEpisode: MovieEpisode?

    private(set) var movie: MovieVideo?
    private(set) var selectedQuality: String?

    private(set) var availableQualities: [String] = []
    private(set) var lockedQualities: [String] = []

    private(set) var isLoadingSeasons = false
    private(set) var isLoadingVideo = false
    private(set) var error: String?

    let details: MovieDetailed

    private let isUserPremium: Int?
    private let defaultQuality: DefaultQuality

    init(details: MovieDetailed) {
        self.details = details
        self.isUserPremium = Defaults[.isUserPremium]
        self.defaultQuality = Defaults[.defaultQuality]
        self.voiceActings = details.voiceActing ?? []
    }

    func prepare() {
        selectInitialActing()
    }

    func presentError(_ message: String) {
        error = message
    }

    func clearError() {
        error = nil
    }

    func selectActing(_ acting: MovieVoiceActing) {
        guard acting != selectedActing else { return }

        if acting.isPremium, isUserPremium == nil {
            presentError(String(localized: "key.premium_content"))
            selectedActing = nil
            seasons = nil
            movie = nil
            return
        }

        clearError()
        selectedActing = acting
        seasons = nil
        selectedSeason = nil
        selectedEpisode = nil
        selectedQuality = nil
        movie = nil
        availableQualities = []
        lockedQualities = []

        if details.series != nil {
            loadSeasons(for: acting)
        } else {
            loadVideo(acting: acting, season: nil, episode: nil)
        }
    }

    func selectSeason(_ season: MovieSeason) {
        guard season != selectedSeason else { return }

        clearError()
        selectedSeason = season
        selectedEpisode = nil
        selectedQuality = nil
        movie = nil
        availableQualities = []
        lockedQualities = []

        if let firstEpisode = season.episodes.first {
            selectEpisode(firstEpisode)
        }
    }

    func selectEpisode(_ episode: MovieEpisode) {
        guard episode != selectedEpisode else { return }

        clearError()
        selectedEpisode = episode
        selectedQuality = nil
        movie = nil
        availableQualities = []
        lockedQualities = []

        if let acting = selectedActing, let season = selectedSeason {
            loadVideo(acting: acting, season: season, episode: episode)
        }
    }

    func selectQuality(_ quality: String) {
        guard quality != selectedQuality else { return }
        clearError()
        selectedQuality = quality
    }

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

    var canPlay: Bool {
        guard movie != nil else { return false }
        if let selectedQuality {
            return availableQualities.contains(selectedQuality)
        }
        return !availableQualities.isEmpty
    }

    private func selectInitialActing() {
        var preferred: MovieVoiceActing?

        let nonPremium = voiceActings.filter { !$0.isPremium }
        let available = if isUserPremium != nil { voiceActings } else { nonPremium }

        preferred = available.first { $0.isSelected }

        if preferred == nil {
            preferred = available.first
        }

        if preferred == nil {
            preferred = voiceActings.first
        }

        if let preferred {
            selectActing(preferred)
        } else {
            presentError(String(localized: "key.no_voice_acting"))
        }
    }

    private func loadSeasons(for acting: MovieVoiceActing) {
        isLoadingSeasons = true
        clearError()

        getSeriesSeasonsUseCase(movieId: details.movieId, voiceActing: acting, favs: details.favs)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoadingSeasons = false

                if case let .failure(error) = completion {
                    self.presentError(error.localizedDescription)
                }
            } receiveValue: { [weak self] seasons in
                guard let self else { return }

                self.seasons = seasons

                if let currentSeason = seasons.first(where: { $0.isSelected }) ?? seasons.first {
                    self.selectSeason(currentSeason)
                }
            }
            .store(in: &cancellables)
    }

    private func loadVideo(acting: MovieVoiceActing, season: MovieSeason?, episode: MovieEpisode?) {
        isLoadingVideo = true
        clearError()

        getMovieVideoUseCase(voiceActing: acting, season: season, episode: episode, favs: details.favs)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoadingVideo = false

                if case let .failure(error) = completion {
                    self.presentError(error.localizedDescription)
                }
            } receiveValue: { [weak self] movie in
                guard let self else { return }

                if movie.needPremium {
                    self.presentError(String(localized: "key.premium_content"))
                    self.movie = nil
                    self.availableQualities = []
                    self.lockedQualities = []
                    return
                }

                self.movie = movie
                self.availableQualities = movie.getAvailableQualities()
                self.lockedQualities = movie.getLockedQualities()

                if let quality = self.defaultQualitySelection(from: movie) {
                    self.selectedQuality = quality
                } else if let first = movie.getAvailableQualities().first {
                    self.selectedQuality = first
                }
            }
            .store(in: &cancellables)
    }

    private func defaultQualitySelection(from movie: MovieVideo) -> String? {
        switch defaultQuality {
        case .ask:
            return nil
        case .q360, .q480, .q720, .q1080, .q1440, .q2160:
            if movie.getAvailableQualities().contains(defaultQuality.rawValue) {
                return defaultQuality.rawValue
            } else {
                return nil
            }
        }
    }
}

struct TVWatchOverlayView: View {
    let details: MovieDetailed
    let onPlay: (TVPlayerConfiguration) -> Void
    let onCancel: () -> Void

    @State private var viewModel: TVWatchOverlayViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedTarget: FocusTarget?

    init(details: MovieDetailed, onPlay: @escaping (TVPlayerConfiguration) -> Void, onCancel: @escaping () -> Void) {
        self.details = details
        self.onPlay = onPlay
        self.onCancel = onCancel
        _viewModel = State(initialValue: TVWatchOverlayViewModel(details: details))
    }

    var body: some View {
        VStack(spacing: 30) {
            headerView
            contentView
            footerView
        }
        .frame(width: 1100, height: 780)
        .background(.ultraThinMaterial)
        .cornerRadius(40)
        .task {
            viewModel.prepare()
            await MainActor.run {
                focusSelectedActing(force: true)
            }
        }
//        .onChange(of: viewModel.selectedActing) {
//            focusSelectedActing()
//        }
//        .onChange(of: viewModel.selectedSeason) {
//            focusSelectedSeason()
//        }
//        .onChange(of: viewModel.selectedEpisode) {
//            focusSelectedEpisode()
//        }
//        .onChange(of: viewModel.selectedQuality) {
//            focusSelectedQuality()
//        }
    }

    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: 18) {
            Text(String(localized: "key.watch"))
                .font(.system(size: 48, weight: .bold))

            if let error = viewModel.error {
                errorBanner(error)
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 35) {
                voiceActingSection
//                seasonsSection
//                episodesSection
                qualitiesSection
            }
            .padding(.horizontal, 60)
            .padding(.vertical, 20)
        }
    }

    @ViewBuilder
    private var footerView: some View {
        HStack(spacing: 30) {
            cancelButton
            playButton
        }
        .padding(.bottom, 30)
    }

    private var cancelButton: some View {
        Button {
            dismiss()
            onCancel()
        } label: {
            Text("key.cancel")
                .font(.system(size: 28))
                .frame(width: 220, height: 60)
                .background(Color.gray.opacity(focusedTarget == .cancel ? 0.45 : 0.3))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(focusedTarget == .cancel ? Color.white : .clear, lineWidth: 3)
                )
        }
        .buttonStyle(.plain)
//        .focusable(true)
//        .focused($focusedTarget, equals: .cancel)
    }

    private var playButton: some View {
        Button {
            if let config = viewModel.makeConfiguration() {
                onPlay(config)
                dismiss()
            }
        } label: {
            Text("key.watch")
                .font(.system(size: 28, weight: .semibold))
                .frame(width: 320, height: 60)
                .background(backgroundForPlayButton)
                .foregroundStyle(foregroundForPlayButton)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(focusedTarget == .play ? Color.white : .clear, lineWidth: 3)
                )
        }
        .buttonStyle(.plain)
//        .focusable(viewModel.canPlay)
        .disabled(!viewModel.canPlay)
//        .focused($focusedTarget, equals: .play)
    }

    private var backgroundForPlayButton: Color {
        if !viewModel.canPlay {
            return Color.gray.opacity(0.3)
        }
        return focusedTarget == .play ? Color.accentColor.opacity(0.9) : Color.accentColor
    }

    private var foregroundForPlayButton: Color {
        if !viewModel.canPlay {
            return Color.black.opacity(0.4)
        }
        return focusedTarget == .play ? Color.black : Color.black
    }

    private enum FocusTarget: Hashable {
        case acting(UUID)
        case season(UUID)
        case episode(UUID)
        case quality(String)
        case lockedQuality(String)
        case cancel
        case play
    }

    private func focusSelectedActing(force: Bool = false) {
        if let acting = viewModel.selectedActing ?? viewModel.voiceActings.first {
            if !force {
                if case .acting(let id) = focusedTarget, id == acting.id { return }
                if focusedTarget != nil { return }
            }
            focusedTarget = .acting(acting.id)
        } else if force {
            focusedTarget = .cancel
        }
    }

    private func focusSelectedSeason(force: Bool = false) {
        guard let season = viewModel.selectedSeason else { return }
        if !force {
            if case .season(let id) = focusedTarget, id == season.id { return }
            if focusedTarget != nil { return }
        }
        focusedTarget = .season(season.id)
    }

    private func focusSelectedEpisode(force: Bool = false) {
        guard let episode = viewModel.selectedEpisode else { return }
        if !force {
            if case .episode(let id) = focusedTarget, id == episode.id { return }
            if focusedTarget != nil { return }
        }
        focusedTarget = .episode(episode.id)
    }

    private func focusSelectedQuality(force: Bool = false) {
        guard let quality = viewModel.selectedQuality else { return }
        if !force {
            if case .quality(let value) = focusedTarget, value == quality { return }
            if focusedTarget != nil { return }
        }
        focusedTarget = .quality(quality)
    }

    private func errorBanner(_ error: String) -> some View {
        Text(error)
            .font(.system(size: 26))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.6))
            .cornerRadius(20)
            .padding(.horizontal, 40)
    }

    private var voiceActingSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if details.voiceActing?.isEmpty == false {
                Text("key.acting")
                    .font(.system(size: 32, weight: .semibold))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 25) {
                        ForEach(viewModel.voiceActings) { acting in
                            let isFocused = focusedTarget == .acting(acting.id)
                            Button {
                                viewModel.selectActing(acting)
                            } label: {
                                VStack(spacing: 8) {
                                    Text(acting.name.isEmpty ? String(localized: "key.default") : acting.name)
                                        .font(.system(size: 26, weight: .medium))
                                        .foregroundStyle(.primary)

                                    if acting.isPremium {
                                        Text(String(localized: "key.premium"))
                                            .font(.system(size: 18))
                                            .foregroundStyle(Color.pink)
                                    }
                                }
                                .frame(width: 260, height: 120)
                                .background(backgroundForActing(isFocused: isFocused, acting: acting))
                                .cornerRadius(18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(borderColorForActing(isFocused: isFocused, acting: acting), lineWidth: 3)
                                )
                            }
                            .buttonStyle(.plain)
//                            .focusable(true)
//                            .focused($focusedTarget, equals: .acting(acting.id))
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
    }

    private var seasonsSection: some View {
        Group {
            if details.series != nil {
                VStack(alignment: .leading, spacing: 20) {
                    Text("key.season")
                        .font(.system(size: 32, weight: .semibold))

                    if viewModel.isLoadingSeasons {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding(.vertical, 40)
                    } else if let seasons = viewModel.seasons, !seasons.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 25) {
                                ForEach(seasons) { season in
                                    let isFocused = focusedTarget == .season(season.id)
                                    Button {
                                        viewModel.selectSeason(season)
                                    } label: {
                                        Text(season.name.isEmpty ? String(localized: "key.season") : season.name)
                                            .font(.system(size: 26, weight: .medium))
                                            .frame(width: 220, height: 90)
                                            .background(backgroundForSelection(isFocused: isFocused, isSelected: viewModel.selectedSeason == season))
                                            .cornerRadius(18)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 18)
                                                    .stroke(borderColorForSelection(isFocused: isFocused, isSelected: viewModel.selectedSeason == season), lineWidth: 3)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .focusable(true)
                                    .focused($focusedTarget, equals: .season(season.id))
                                }
                            }
                            .padding(.vertical, 10)
                        }
                    } else {
                        Text(String(localized: "key.no_episodes"))
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var episodesSection: some View {
        Group {
            if details.series != nil, let episodes = viewModel.selectedSeason?.episodes, !episodes.isEmpty {
                VStack(alignment: .leading, spacing: 20) {
                    Text("key.episode")
                        .font(.system(size: 32, weight: .semibold))

                    if viewModel.isLoadingVideo {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding(.vertical, 40)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 25) {
                            ForEach(episodes) { episode in
                                let isFocused = focusedTarget == .episode(episode.id)
                                Button {
                                    viewModel.selectEpisode(episode)
                                } label: {
                                    Text(episode.name.isEmpty ? String(localized: "key.episode") : episode.name)
                                        .font(.system(size: 26, weight: .medium))
                                        .frame(width: 220, height: 90)
                                        .background(backgroundForSelection(isFocused: isFocused, isSelected: viewModel.selectedEpisode == episode))
                                        .cornerRadius(18)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(borderColorForSelection(isFocused: isFocused, isSelected: viewModel.selectedEpisode == episode), lineWidth: 3)
                                        )
                                }
                                .buttonStyle(.plain)
                                .focusable(true)
                                .focused($focusedTarget, equals: .episode(episode.id))
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
        }
    }

    private var qualitiesSection: some View {
        Group {
            if viewModel.movie != nil {
                VStack(alignment: .leading, spacing: 20) {
                    Text("key.quality")
                        .font(.system(size: 32, weight: .semibold))

                    if viewModel.isLoadingVideo {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding(.vertical, 40)
                    } else {
                        qualityScrollView
                    }
                }
            }
        }
    }

    private var qualityScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 25) {
                availableQualityButtons
               // lockedQualityButtons
            }
            .padding(.vertical, 10)
        }
    }

    private var availableQualityButtons: some View {
        ForEach(viewModel.availableQualities, id: \.self) { quality in
            let isFocused = focusedTarget == .quality(quality)
            Button {
                viewModel.selectQuality(quality)
            } label: {
                qualityLabel(for: quality, isFocused: isFocused)
            }
            .buttonStyle(.plain)
//            .focusable(true)
//            .focused($focusedTarget, equals: .quality(quality))
        }
    }

    private var lockedQualityButtons: some View {
        ForEach(viewModel.lockedQualities, id: \.self) { quality in
            let isFocused = focusedTarget == .lockedQuality(quality)
            Button {
                viewModel.presentError(String(localized: "key.sign_in.access"))
            } label: {
                lockedQualityLabel(for: quality, isFocused: isFocused)
            }
            .buttonStyle(.plain)
            .focusable(true)
            .focused($focusedTarget, equals: .lockedQuality(quality))
        }
    }

    private func qualityLabel(for quality: String, isFocused: Bool) -> some View {
        Text(quality)
            .font(.system(size: 26, weight: .medium))
            .frame(width: 160, height: 80)
            .background(backgroundForSelection(isFocused: isFocused, isSelected: viewModel.selectedQuality == quality))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(borderColorForSelection(isFocused: isFocused, isSelected: viewModel.selectedQuality == quality), lineWidth: 3)
            )
    }

    private func lockedQualityLabel(for quality: String, isFocused: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "lock.fill")
            Text(quality)
        }
        .font(.system(size: 26, weight: .medium))
        .frame(width: 160, height: 80)
        .background(Color.gray.opacity(isFocused ? 0.4 : 0.2))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isFocused ? Color.white : Color.gray.opacity(0.4), lineWidth: 3)
        )
    }

    private func backgroundForActing(isFocused: Bool, acting: MovieVoiceActing) -> Color {
        if viewModel.selectedActing == acting {
            return Color.accentColor.opacity(isFocused ? 0.35 : 0.2)
        }
        return Color.gray.opacity(isFocused ? 0.35 : 0.2)
    }

    private func borderColorForActing(isFocused: Bool, acting: MovieVoiceActing) -> Color {
        if viewModel.selectedActing == acting {
            return isFocused ? Color.white : Color.accentColor
        }
        return isFocused ? Color.white : .clear
    }

    private func backgroundForSelection(isFocused: Bool, isSelected: Bool) -> Color {
        if isSelected {
            return Color.accentColor.opacity(isFocused ? 0.35 : 0.2)
        }
        return Color.gray.opacity(isFocused ? 0.35 : 0.2)
    }

    private func borderColorForSelection(isFocused: Bool, isSelected: Bool) -> Color {
        if isSelected {
            return isFocused ? Color.white : Color.accentColor
        }
        return isFocused ? Color.white : .clear
    }
}
