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
        summonGaruda(at: CGPoint(x: frame.midX - 1800, y: frame.midY - 480))
        summonKecrek(at: CGPoint(x: frame.midX - 600, y: frame.midY - 450), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX - 1800, y: frame.midY + 300), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX - 1200, y: frame.midY + 550), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX - 700, y: frame.midY + 700), type: 2)
        summonKecrek(at: CGPoint(x: frame.midX + 480, y: frame.midY + 550), type: 2)
        summonKecrek(at: CGPoint(x: frame.midX + 650, y: frame.midY - 450), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX + 1200, y: frame.midY - 450), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX + 1300, y: frame.midY - 450), type: 2)
        summonObjective(at: CGPoint(x: frame.midX - 1600, y: frame.midY - 480))
        
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
