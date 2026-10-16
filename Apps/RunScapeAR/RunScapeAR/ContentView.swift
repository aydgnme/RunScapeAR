//
//  ContentView.swift
//  RunScapeAR
//
//  Created by Mert Ioan Aydogan on 02/10/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            RoutePreviewView()
                .navigationTitle("3D Route")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
