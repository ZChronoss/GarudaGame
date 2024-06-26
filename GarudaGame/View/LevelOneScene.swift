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
        summonGaruda(at: CGPoint(x: frame.midX - 3800, y: frame.midY - 1120))
        
        summonKecrek(at: CGPoint(x: frame.midX - 2700, y: frame.midY - 1150), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX - 3900, y: frame.midY - 340), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX - 3100, y: frame.midY - 90), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX - 2900, y: frame.midY + 190), type: 2)
        summonKecrek(at: CGPoint(x: frame.midX - 2600, y: frame.midY + 40), type: 2)
        summonKecrek(at: CGPoint(x: frame.midX - 1100, y: frame.midY + 100), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX - 1200, y: frame.midY - 1120), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX - 1100, y: frame.midY - 1120), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX - 900, y: frame.midY - 1120), type: 2)
        summonKecrek(at: CGPoint(x: frame.midX + 220, y: frame.midY - 1120), type: 2)
        summonKecrek(at: CGPoint(x: frame.midX - 240, y: frame.midY + 1200), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX - 200, y: frame.midY + 1200), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX - 160, y: frame.midY + 1200), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX + 100, y: frame.midY + 270), type: 2)
        summonKecrek(at: CGPoint(x: frame.midX + 1200, y: frame.midY - 240), type: 2)
        summonKecrek(at: CGPoint(x: frame.midX + 1000, y: frame.midY - 960), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX + 1500, y: frame.midY - 900), type: 1)
        summonKecrek(at: CGPoint(x: frame.midX + 1760, y: frame.midY - 820), type: 2)
        
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
