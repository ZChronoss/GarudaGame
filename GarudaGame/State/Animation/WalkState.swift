//
//  MoveLeftState.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 23/06/24.
//

import Foundation
import GameplayKit

class WalkState: AnimationState {
    override func didEnter(from previousState: GKState?) {
        let frames = createAnimationFrame(self.name, state: .walk)
        let animation = SKAction.animate(with: frames,
                                         timePerFrame: TimeInterval(0.1))
        node.run(SKAction.repeatForever(animation))
    }
}
