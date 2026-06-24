/*
 DOSYA: OnboardingPage.swift
 AMAÇ: Her onboarding page için content modelini tanımlar. Onboarding text ve icon bilgilerini data olarak düzenli tutar.
 KULLANAN: OnboardingView ve OnboardingPageView tarafından kullanılır.
*/
import Foundation

// OnboardingPage, onboarding ekranındaki her tanıtım sayfasının localized metin keylerini taşır.
struct OnboardingPage: Identifiable {
    let id: String
    let titleKey: String
    let descriptionKey: String
    let systemImage: String

    // Sayfalar burada merkezi tutulur; OnboardingView bu listeyi TabView içinde gösterir.
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: "welcome",
            titleKey: "onboarding_welcome_title",
            descriptionKey: "onboarding_welcome_description",
            systemImage: "wallet.pass.fill"
        ),
        OnboardingPage(
            id: "track",
            titleKey: "onboarding_track_title",
            descriptionKey: "onboarding_track_description",
            systemImage: "list.bullet.rectangle.fill"
        ),
        OnboardingPage(
            id: "receipt",
            titleKey: "onboarding_receipt_title",
            descriptionKey: "onboarding_receipt_description",
            systemImage: "doc.text.viewfinder"
        ),
        OnboardingPage(
            id: "analytics",
            titleKey: "onboarding_analytics_title",
            descriptionKey: "onboarding_analytics_description",
            systemImage: "chart.pie.fill"
        ),
        OnboardingPage(
            id: "budget",
            titleKey: "onboarding_budget_title",
            descriptionKey: "onboarding_budget_description",
            systemImage: "target"
        )
    ]
}
