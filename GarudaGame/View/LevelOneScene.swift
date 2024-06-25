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
        self.currentScene = "LevelOneScene"
        super.didMove(to: view)
        summonGaruda(at: CGPoint(x: frame.midX - 250, y: frame.midY))
        summonKecrek(at: CGPoint(x: frame.midX + 30, y: frame.midY), type: 1)
//        summonKecrek(at: CGPoint(x: frame.midX + 250, y: frame.midY+100), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX + 340, y: frame.midY+100), type: 2)
//        summonKecrek(at: CGPoint(x: frame.midX + 1000, y: frame.midY+150), type: 2)
//        summonKecrek(at: CGPoint(x: frame.midX + 1200, y: frame.midY+150), type: 2)
        
//        let platformNames = (1...5).map { "\($0)" }
//        for name in platformNames {
//            setupPlatform(name: name)
//        }
        
        for node in self.children {
            if (node.name == "LevelOne") {
                if let someTileMap: SKTileMapNode = node as? SKTileMapNode {
                    giveTileMapPhysicsBody(map: someTileMap)
                    
                    someTileMap.removeFromParent()
                }
            }
        }
//        setupSpike(name: "spike")
//        let softPlatformNames = (6...7).map { "\($0)" }
//        for name in softPlatformNames {
//            setupSoftPlatform(name: name)
//        }
    }
    
}
