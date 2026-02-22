//
//  ButtonStyles.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 20/02/26.
//

import SwiftUI

struct GlassyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}
