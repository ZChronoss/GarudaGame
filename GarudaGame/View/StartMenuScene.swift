//
//  StartMenuScene.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 19/06/24.
//

import Foundation
import SpriteKit
import GameplayKit

class StartMenuScene: SKScene {
    let gameTitle = SKLabelNode(text: "Legend of Garuda")
    let startGame = SKLabelNode(text: "Tap the screen to start!")
    
    override func didMove(to view: SKView) {
        gameTitle.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        gameTitle.fontName = "HelveticaNeue-Bold"
        gameTitle.fontColor = .white
        gameTitle.fontSize = 50
        addChild(gameTitle)
        
        startGame.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        startGame.fontColor = .white
        startGame.fontSize = 18
        addChild(startGame)
        
        // Blinking effect
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let interval = SKAction.fadeIn(withDuration: 0.5)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let blinkSequence = SKAction.sequence([fadeOut, interval, fadeIn])
        let blinkForever = SKAction.repeatForever(blinkSequence)
        startGame.run(blinkForever)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let nextScene = SKScene(fileNamed: "LevelOneScene")
        nextScene?.scaleMode = .aspectFill
        self.view?.presentScene(nextScene)
    }
}
