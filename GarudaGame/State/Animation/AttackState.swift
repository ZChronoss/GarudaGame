//
//  AttackState.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 26/06/24.
//

import Foundation
import GameplayKit

class AttackState: AnimationState {
    override func didEnter(from previousState: GKState?) {
        let frames = createAnimationFrame(self.name, state: .attack)
        let animation = SKAction.animate(with: frames,
                                         timePerFrame: TimeInterval(0.1))
        node.run(animation)
    }
}
