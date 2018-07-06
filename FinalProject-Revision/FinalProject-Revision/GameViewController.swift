//
//  GameViewController.swift
//  FinalProject
//
//  Created by Thomas Finnegan on 2018-06-18.
//  Copyright © 2018 Thomas Finnegan. All rights reserved.
//
// responsible for user input and communicating between gamescene and gamelogic
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, GameMasterDelegate, UIGestureRecognizerDelegate {
    
    var scene: GameScene!
    var gamemaster: GameMaster!
    
    //tracks last point on screen shape movement occured
    //or where a pan began
    var panPointReference:CGPoint?
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var levelLabel: UILabel!
    
    
    func gameDidBegin(gamemaster: GameMaster) {
        
        //level.text = "\(gamemaster.level)"
        //score.text = "\(gamemaster.score)"
        scene.tickLengthMillis = TickLengthLevelOne
        
        //following false when restarting
        if gamemaster.nextShape != nil && gamemaster.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(shape: gamemaster.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    func gameDidEnd(gamemaster: GameMaster) {
        
        scene.playSound(sound: "Sounds/gameover.mp3")
        scene.animateCollapsingLines(linesToRemove: gamemaster.removeAllBlocks(), fallenBlocks: gamemaster.removeAllBlocks()) {
            gamemaster.beginGame()
        }
        view.isUserInteractionEnabled = false
        scene.stopTicking()
    }
    
    func gameDidLevelUp(gamemaster: GameMaster) {
        
        levelLabel.text = "\(gamemaster.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        scene.playSound(sound: "Sounds/levelup.mp3")
        
    }
    
    func gameShapeDidDrop(gamemaster: GameMaster) {
        scene.stopTicking()
        scene.redrawShape(shape: gamemaster.fallingShape!) {
            gamemaster.letShapeFall()
        }
        scene.playSound(sound: "Sounds/drop.mp3")
    }
    
    func gameShapeDidLand(gamemaster: GameMaster) {
        scene.stopTicking()
        self.view.isUserInteractionEnabled = false
        // #10
        let removedLines = gamemaster.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(gamemaster.score)"
            scene.animateCollapsingLines(linesToRemove: removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                // #11
                self.gameShapeDidLand(gamemaster: gamemaster)
            }
            scene.playSound(sound: "Sounds/bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    //necassary to do after shape moved to redraw
    //sprite at new location
    func gameShapeDidMove(gamemaster: GameMaster) {
        scene.redrawShape(shape: gamemaster.fallingShape!) {
            gamemaster.letShapeFall()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //config view
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        //create and config scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        //closure for tick in gamescene
        scene.tick = didTick
        
        gamemaster = GameMaster()
        gamemaster.delegate = self
        gamemaster.beginGame()
        
        skView.presentScene(scene)
        
    }
    
    func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //lowers shape by one row
    //asks gamescene to redraw shape in new location
    func didTick() {
        gamemaster.letShapeFall()
    }
    
    func nextShape() {
        let newShapes = gamemaster.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        
        self.scene.addPreviewShapeToScene(shape: newShapes.nextShape!) {}
        self.scene.movePreviewShape(shape: fallingShape) {
            
            //introduced bool to allow shut down interact with view
            //regardless of what user does to device
            //not be able to manipulate game in any way
            self.view.isUserInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    

    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        gamemaster.rotateShape()
    }
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        let currentPoint = sender.translation(in: self.view)
        if let originalPoint = panPointReference {
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                if sender.velocity(in: self.view).x > CGFloat(0) {
                    gamemaster.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    gamemaster.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .began {
            panPointReference = currentPoint
        }
    }
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        gamemaster.dropShape()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequireToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer{
            if otherGestureRecognizer is UIPanGestureRecognizer{
                return true
            }
        } else if gestureRecognizer is UIPanGestureRecognizer {
            if otherGestureRecognizer is UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
}

    


