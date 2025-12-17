//
//  ThemeStyles.swift
//  Demo5
//
//  Created by Andy on 2025/12/17.
//

import SwiftUI

// MARK: - 主题样式结构体
struct ThemeStyles {
    // MARK: - 按钮样式
    struct PrimaryButtonStyle: ButtonStyle {
        let isEnabled: Bool

        init(isEnabled: Bool = true) {
            self.isEnabled = isEnabled
        }

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color.textOnColor)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(isEnabled ? Color.primaryButton : Color.secondaryText)
                        .opacity(configuration.isPressed ? 0.8 : 1.0)
                )
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .shadow(color: Color.cardShadow, radius: 5, x: 0, y: 2)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }

    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color.primaryText)
                .frame(height: 44)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.secondaryButton)
                        .opacity(configuration.isPressed ? 0.8 : 1.0)
                )
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }

    struct IconButtonStyle: ButtonStyle {
        let iconSize: CGFloat
        let backgroundColor: Color

        init(iconSize: CGFloat = 44, backgroundColor: Color = Color.secondaryButton) {
            self.iconSize = iconSize
            self.backgroundColor = backgroundColor
        }

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color.primaryText)
                .frame(width: iconSize, height: iconSize)
                .background(
                    Circle()
                        .fill(backgroundColor)
                        .opacity(configuration.isPressed ? 0.8 : 1.0)
                )
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .shadow(color: Color.cardShadow, radius: 3, x: 0, y: 2)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }

    // MARK: - 卡片样式
    struct CardStyle: ViewModifier {
        let cornerRadius: CGFloat
        let shadowRadius: CGFloat

        init(cornerRadius: CGFloat = 16, shadowRadius: CGFloat = 8) {
            self.cornerRadius = cornerRadius
            self.shadowRadius = shadowRadius
        }

        func body(content: Content) -> some View {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.cardBackground)
                        .shadow(color: Color.cardShadow, radius: shadowRadius, x: 0, y: 4)
                )
        }
    }

    // MARK: - 文本样式
    struct TitleTextStyle: ViewModifier {
        let color: Color

        init(color: Color = Color.textPrimary) {
            self.color = color
        }

        func body(content: Content) -> some View {
            content
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .multilineTextAlignment(.center)
        }
    }

    struct HeadlineTextStyle: ViewModifier {
        let color: Color

        init(color: Color = Color.textPrimary) {
            self.color = color
        }

        func body(content: Content) -> some View {
            content
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(color)
        }
    }

    struct BodyTextStyle: ViewModifier {
        let color: Color

        init(color: Color = Color.textPrimary) {
            self.color = color
        }

        func body(content: Content) -> some View {
            content
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(color)
        }
    }

    struct CaptionTextStyle: ViewModifier {
        let color: Color

        init(color: Color = Color.textSecondary) {
            self.color = color
        }

        func body(content: Content) -> some View {
            content
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(color)
        }
    }

    // MARK: - 输入框样式
    struct TextFieldStyle: ViewModifier {
        let isEditing: Bool

        init(isEditing: Bool = false) {
            self.isEditing = isEditing
        }

        func body(content: Content) -> some View {
            content
                .font(.system(size: 16, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .stroke(isEditing ? Color.primaryButton : Color.secondaryText.opacity(0.3), lineWidth: isEditing ? 2 : 1)
                )
        }
    }

    // MARK: - 进度条样式
    struct ProgressRingStyle: ViewModifier {
        let lineWidth: CGFloat
        let backgroundColor: Color

        init(lineWidth: CGFloat = 8, backgroundColor: Color = Color.progressBackground) {
            self.lineWidth = lineWidth
            self.backgroundColor = backgroundColor
        }

        func body(content: Content) -> some View {
            content
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: content)
        }
    }
}

// MARK: - View 扩展
extension View {
    func primaryButtonStyle(isEnabled: Bool = true) -> some View {
        self.buttonStyle(ThemeStyles.PrimaryButtonStyle(isEnabled: isEnabled))
    }

    func secondaryButtonStyle() -> some View {
        self.buttonStyle(ThemeStyles.SecondaryButtonStyle())
    }

    func iconButtonStyle(size: CGFloat = 44, backgroundColor: Color = Color.secondaryButton) -> some View {
        self.buttonStyle(ThemeStyles.IconButtonStyle(iconSize: size, backgroundColor: backgroundColor))
    }

    func cardStyle(cornerRadius: CGFloat = 16, shadowRadius: CGFloat = 8) -> some View {
        self.modifier(ThemeStyles.CardStyle(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }

    func titleTextStyle(color: Color = Color.textPrimary) -> some View {
        self.modifier(ThemeStyles.TitleTextStyle(color: color))
    }

    func headlineTextStyle(color: Color = Color.textPrimary) -> some View {
        self.modifier(ThemeStyles.HeadlineTextStyle(color: color))
    }

    func bodyTextStyle(color: Color = Color.textPrimary) -> some View {
        self.modifier(ThemeStyles.BodyTextStyle(color: color))
    }

    func captionTextStyle(color: Color = Color.textSecondary) -> some View {
        self.modifier(ThemeStyles.CaptionTextStyle(color: color))
    }

    func themeTextFieldStyle(isEditing: Bool = false) -> some View {
        self.modifier(ThemeStyles.TextFieldStyle(isEditing: isEditing))
    }

    func progressRingStyle(lineWidth: CGFloat = 8) -> some View {
        self.modifier(ThemeStyles.ProgressRingStyle(lineWidth: lineWidth))
    }
}

// MARK: - 自定义视图修饰符
struct BounceEffect: ViewModifier {
    @State private var isBouncing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isBouncing ? 1.05 : 1.0)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isBouncing = true
                }
            }
    }
}

struct ShakeEffect: ViewModifier {
    @State private var shakeOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: shakeOffset)
            .onAppear {
                withAnimation(Animation.linear(duration: 0.1).repeatCount(5, autoreverses: true)) {
                    shakeOffset = 5
                }
            }
    }
}

extension View {
    func bounceEffect() -> some View {
        self.modifier(BounceEffect())
    }

    func shakeEffect() -> some View {
        self.modifier(ShakeEffect())
    }
}