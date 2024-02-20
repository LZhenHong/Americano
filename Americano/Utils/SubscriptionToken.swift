//
//  SubscriptionToken.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Combine

class SubscriptionToken {
    var cancellable: AnyCancellable?

    var isValid: Bool {
        cancellable != nil
    }

    func unseal() {
        cancellable = nil
    }
}

extension AnyCancellable {
    func seal(in token: SubscriptionToken) {
        token.cancellable = self
    }
}
