//
//  LaunchAnimationView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 25.07.2025.
//


import SwiftUI
import Lottie

public struct LaunchAnimationView: View {
    @EnvironmentObject private var state: LaunchState
    
    public init() {
        
    }

    public var body: some View {
        ZStack {
            LottieView(animation: .named("animation"))
                .playing(loopMode: .playOnce)
                .animationDidFinish { _ in
                    withAnimation(.easeOut(duration: 0.2)) {
                        state.isFinished = true
                    }
                }
        }
    }
}

public final class LaunchState: ObservableObject {
    @Published public var isFinished: Bool
    
    public init(isFinished: Bool = false) {
        self.isFinished = isFinished
    }
}
