//
//  Button.swift
//  DrawItNow
//
//  Created by Steven J. Selcuk on 4.08.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import SwiftUI

struct GoodButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(Color.gray.opacity(0))
            .frame(minWidth: 100, minHeight: 40, alignment: .center)
            .padding(5)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}
