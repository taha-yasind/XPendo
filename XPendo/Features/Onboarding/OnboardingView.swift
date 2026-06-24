/*
 DOSYA: OnboardingView tarafından kullanılır.swift
 AMAÇ: İlk açılış onboarding carousel ve completion aksiyonunu sunar. Kullanıcının main app’e ne zaman geçeceğini kontrol eder.
 KULLANAN: AppRootView ve OnboardingPageView tarafından kullanılır.
*/
import SwiftUI

// OnboardingMode, ilk açılış ile Settings içinden tekrar izleme akışını ayırır.
enum OnboardingMode {
    case firstLaunch
    case replay
}

// OnboardingView, uygulamanın temel özelliklerini sayfalı bir SwiftUI akışıyla tanıtır.
// İlk launch sonunda AppRootView'daki hasSeenOnboarding flag'i tamamlanır.
struct OnboardingView: View {
    let mode: OnboardingMode
    let onFinish: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex = 0

    private let pages = OnboardingPage.pages

    // Bu view için görünen SwiftUI layout’unu kurar.
    var body: some View {
        VStack(spacing: 0) {
            header

            TabView(selection: $selectedIndex) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            footer
        }
        .background(XPendoTheme.background.ignoresSafeArea())
    }

    // Replay modunda kapatma butonu görünür; firstLaunch modunda kullanıcı son sayfaya kadar ilerler.
    private var header: some View {
        HStack {
            Text("Xpendo")
                .font(.headline.weight(.bold))
                .foregroundStyle(XPendoTheme.primaryText)

            Spacer()

            if mode == .replay {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(XPendoTheme.primaryText)
                        .frame(width: 42, height: 42)
                        .background(XPendoTheme.surfaceBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(XPendoTheme.cardBorder, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(AppLocalization.string("common.close"))
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 18)
    }

    // Primary button son sayfada finish callback'ini, diğer sayfalarda navigation ilerlemesini çalıştırır.
    private var footer: some View {
        VStack(spacing: 20) {
            pageIndicator

            Button(action: primaryButtonTapped) {
                Text(primaryButtonTitle)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(XPendoTheme.accentTeal, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: XPendoTheme.accentTeal.opacity(0.22), radius: 16, x: 0, y: 8)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == selectedIndex ? XPendoTheme.accentTeal : XPendoTheme.secondaryText.opacity(0.22))
                    .frame(width: index == selectedIndex ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.28, dampingFraction: 0.86), value: selectedIndex)
            }
        }
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var isLastPage: Bool {
        selectedIndex == pages.count - 1
    }

    // Bu type için odaklı bir davranış parçasını yönetir.
    private var primaryButtonTitle: String {
        if isLastPage {
            return mode == .firstLaunch
                ? AppLocalization.string("onboarding_get_started")
                : AppLocalization.string("onboarding_done")
        }

        return AppLocalization.string("onboarding_next")
    }

    // Onboarding akışındaki tek karar noktası: son sayfadaysa tamamla, değilse sonraki sayfaya geç.
    private func primaryButtonTapped() {
        if isLastPage {
            onFinish()
        } else {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                selectedIndex += 1
            }
        }
    }
}
