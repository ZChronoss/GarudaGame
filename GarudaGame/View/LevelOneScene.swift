//
//  LevelOneScene.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 13/06/24.
//

import Foundation
import GameplayKit
import SpriteKit

class LevelOneScene: BaseScene{
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        summonGaruda(at: CGPoint(x: frame.midX - 250, y: frame.midY))
        
        summonKecrek(at: CGPoint(x: frame.midX + 30, y: frame.midY), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX + 300, y: frame.midY+100), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX + 500, y: frame.midY+100), type: 2)
        summonKecrek(at: CGPoint(x: frame.midX + 1000, y: frame.midY+100), type: 2)
        summonKecrek(at: CGPoint(x: frame.midX + 1200, y: frame.midY+100), type: 2)
        
        let platformNames = (1...7).map { "\($0)" }
        for name in platformNames {
            setupPlatform(name: name)
        }
    }
}
