//
//  GameEndScene.swift
//  GarudaGame
//
//  Created by Dharmawan Ruslan on 26/06/24.
//

import Foundation
import GameplayKit

class GameEndScene: SKScene {
    let gameOverLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
    var restartLevelButton: SKSpriteNode?
    var mainMenuButton: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 70)
        gameOverLabel.fontSize = 50
        gameOverLabel.text = "To Be Continued..."
        gameOverLabel.fontColor = .white
        addChild(gameOverLabel)
        
        let homeTexture = SKTexture(systemName: "house", pointSize: 32)
        mainMenuButton = SKSpriteNode(texture: homeTexture)
        mainMenuButton?.color = .white
        mainMenuButton?.colorBlendFactor = 1
        mainMenuButton?.xScale = -1
        mainMenuButton?.yScale = -1
        mainMenuButton?.size = CGSize(width: 100, height: 100)
        mainMenuButton?.position = CGPoint(x: frame.midX, y: frame.midY - 70)
        addChild(mainMenuButton!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if mainMenuButton!.contains(location){
                let newScene = StartMenuScene(size: (view?.bounds.size)!)
                newScene.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 1.0)
                scene?.view?.presentScene(newScene, transition: transition)
            }
        }
    }
}
