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
    let gameTitle = SKSpriteNode(imageNamed: "Title")
    let startGame = SKSpriteNode(imageNamed: "StartButton")
    let background = SKSpriteNode(imageNamed: "StartMenuBackground")
    
    override func didMove(to view: SKView) {
        background.setScale(0.35)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = 0
        addChild(background)
        
        gameTitle.position = CGPoint(x: frame.midX, y: frame.midY + 60)
        gameTitle.setScale(0.4)
        gameTitle.zPosition = 1
        addChild(gameTitle)
        
        startGame.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        startGame.setScale(0.2)
        startGame.zPosition = 1
        addChild(startGame)
        
        // Blinking effect
        let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 5), duration: 1)
        moveUp.timingMode = SKActionTimingMode.easeInEaseOut
        
        let moveDown = SKAction.move(by: CGVector(dx: 0, dy: -5), duration: 1)
        moveDown.timingMode = SKActionTimingMode.easeInEaseOut
        
        let upDownSequence = SKAction.sequence([moveUp, moveDown])
        let upDownForever = SKAction.repeatForever(upDownSequence)
        gameTitle.run(upDownForever)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let location = touch?.location(in: self)
        if startGame.contains(location!){
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
//            let interval = SKAction.fadeIn(withDuration: 0.5)
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            let blinkSequence = SKAction.sequence([fadeOut, fadeIn])
            let blinkForever = SKAction.repeatForever(blinkSequence)
            startGame.run(blinkForever)
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [self] _ in
                let nextScene = SKScene(fileNamed: "LevelOneScene")
                nextScene?.scaleMode = .aspectFill
                self.view?.presentScene(nextScene)
            }
        }
    }
}
