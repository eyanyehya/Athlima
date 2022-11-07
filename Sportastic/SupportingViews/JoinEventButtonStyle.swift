//
//  PrimaryButtonStyle.swift
//  Sportastic
//
//  Created by Eyan Yehya on 9/18/22.
//

import SwiftUI
import Foundation

struct JoinEventButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
 
    func makeBody(configuration: Configuration) -> some View {
        Group {
            if isEnabled {
                configuration.label
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .background(Color.accentColor)
        .cornerRadius(10)
        .animation(.default, value: isEnabled)
    }
}

extension ButtonStyle where Self == JoinEventButtonStyle {
    static var joinButton: JoinEventButtonStyle {
        JoinEventButtonStyle()
    }
}

