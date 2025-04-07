//
//  DefaultTimer.swift
//  ExchangeRates
//
//  Created by Oleg Pankiv on 07.04.2025.
//

import Foundation

protocol TimerInterface {
    func schedule(timeInterval: TimeInterval, repeats: Bool, closure: @escaping () -> Void)
    func invalidate()
}

final class DefaultTimer: TimerInterface {
    private var timer: Timer?

    func schedule(timeInterval: TimeInterval, repeats: Bool, closure: @escaping () -> Void) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats) { _ in
            closure()
        }
    }

    func invalidate() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        invalidate()
    }
}
