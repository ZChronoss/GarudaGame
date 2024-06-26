//
//  GameOverNode.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 24/06/24.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    let gameOverLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
    var restartLevelButton: SKSpriteNode?
    var mainMenuButton: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 70)
        gameOverLabel.fontSize = 100
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontColor = .red
        addChild(gameOverLabel)
        
//        var restartSymbol = UIImage(systemName: "arrow.circlepath")
        let restartTexture = SKTexture(systemName: "arrow.circlepath", pointSize: 32)
        restartLevelButton = SKSpriteNode(texture: restartTexture)
        restartLevelButton?.color = .white
        restartLevelButton?.colorBlendFactor = 1
        restartLevelButton?.xScale = -1
        restartLevelButton?.yScale = -1
        restartLevelButton?.size = CGSize(width: 100, height: 100)
        restartLevelButton?.position = CGPoint(x: frame.midX - 100, y: frame.midY - 70)
        addChild(restartLevelButton!)
        
//        var homeSymbol = UIImage(systemName: "house")
        let homeTexture = SKTexture(systemName: "house", pointSize: 32)
        mainMenuButton = SKSpriteNode(texture: homeTexture)
        mainMenuButton?.color = .white
        mainMenuButton?.colorBlendFactor = 1
        mainMenuButton?.xScale = -1
        mainMenuButton?.yScale = -1
        mainMenuButton?.size = CGSize(width: 100, height: 100)
        mainMenuButton?.position = CGPoint(x: frame.midX + 100, y: frame.midY - 70)
        addChild(mainMenuButton!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if restartLevelButton!.contains(location){
                let nextScene = SKScene(fileNamed: "LevelOneScene")
                nextScene?.scaleMode = .aspectFill
                self.view?.presentScene(nextScene)
            }else if mainMenuButton!.contains(location){
                let newScene = StartMenuScene(size: (view?.bounds.size)!)
                newScene.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 1.0)
                scene?.view?.presentScene(newScene, transition: transition)
            }
        }
    }
}
