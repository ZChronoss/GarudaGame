//
//  GameOverNode.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 24/06/24.
//

import Foundation
import GameplayKit

class GameOverNode: SKNode {
    let square = SKShapeNode(rectOf: CGSize(width: 1000, height: 500))
    let gameOverLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
    let restartLevelButton = SKShapeNode(circleOfRadius: 50)
    let mainMenuButton = SKShapeNode(circleOfRadius: 50)
    
    override init() {
        super.init()
        let squareFrame = square.frame
        square.fillColor = .red
        
        gameOverLabel.position = CGPoint(x: squareFrame.midX, y: squareFrame.midY + 70)
        gameOverLabel.fontSize = 100
        gameOverLabel.text = "Game Over"
        square.addChild(gameOverLabel)
        
        restartLevelButton.position = CGPoint(x: squareFrame.midX - 100, y: squareFrame.midY - 70)
        restartLevelButton.fillColor = .blue
        square.addChild(restartLevelButton)
        
        mainMenuButton.position = CGPoint(x: squareFrame.midX + 100, y: squareFrame.midY - 70)
        mainMenuButton.fillColor = .green
        square.addChild(mainMenuButton)
        addChild(square)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let scene = self.scene as? BaseScene
            if restartLevelButton.contains(location){
                scene?.restartLevel()
            }else if mainMenuButton.contains(location){
                scene?.returnToMainMenu()
            }
        }
    }
    
    
}
