//
//  ContentView.swift
//  DrawItNow
//
//  Created by Steven J. Selcuk on 4.08.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import SwiftUI

let settings = UserDefaults.standard
let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
let screen = UIScreen.main.bounds

struct ContentView: View {
    var body: some View {
        Canvas()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
