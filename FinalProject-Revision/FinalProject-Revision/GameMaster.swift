//
//  GameMaster.swift
//  FinalProject
//
//  Created by Thomas Finnegan on 2018-06-26.
//  Copyright © 2018 Thomas Finnegan. All rights reserved.
//

//defined total number of rows, columns
let NumColumns = 10
let NumRows = 20
//defined location where set pieces starts
let StartingColumn = 4
let StartingRow = 0
//defined location of where preview piece belongs
let PreviewColumn = 12
let PreviewRow = 1

//for scoring
let PointsPerLine = 10
let LevelThreshold = 500

protocol GameMasterDelegate { // Invoked when the current round of Swiftris ends
    func gameDidEnd(gamemaster: GameMaster)
    
    // Invoked after a new game has begun
    func gameDidBegin(gamemaster: GameMaster)
    
    // Invoked when the falling shape has become part of the game board
    func gameShapeDidLand(gamemaster: GameMaster)
    
    // Invoked when the falling shape has changed its location
    func gameShapeDidMove(gamemaster: GameMaster)
    
    // Invoked when the falling shape has changed its location after being dropped
    func gameShapeDidDrop(gamemaster: GameMaster)
    
    // Invoked when the game has reached a new level
    func gameDidLevelUp(gamemaster: GameMaster)
}

class GameMaster {
    var blockArray:Array2D<Block>
    var nextShape:Shape?
    var fallingShape:Shape?
    var delegate:GameMasterDelegate?

    var score = 0
    var level = 1
    
    init() {
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
    }
    
    func beginGame() {
        
        if (nextShape == nil) {
            nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        }
        delegate?.gameDidBegin(gamemaster: self)
    }
    
    //assigns next shape, preview as falling shape
    //falling shape is the moving block
    //creates the preview shape before the moving the next to falling
    //returns optional shape objects
    func newShape() -> (fallingShape:Shape?, nextShape:Shape?) {
        fallingShape = nextShape
        nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        fallingShape?.moveTo(column: StartingColumn, row: StartingRow)
        
        //added logic to newShape, detects ending of game
        guard detectIllegalPlacement() == false else {
            nextShape = fallingShape
            nextShape!.moveTo(column: PreviewColumn, row: PreviewRow)
            endGame()
            return (nil, nil)
        }
        return (fallingShape, nextShape)
    }
    
    //added func for checking block boundary conditions
    //detemines whether block exceeds size of game board
    //dtermines whether block location overlaps with existing
    func detectIllegalPlacement() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for block in shape.blocks {
            if block.column < 0 || block.column >= NumColumns
                || block.row < 0 || block.row >= NumRows {
                return true
            } else if blockArray[block.column, block.row] != nil {
                return true
            }
        }
        return false
    }
    
    
    //provides function of dropping shape by one row
    //if detects illegal placement, raises shape to delegate drop occuring
    func dropShape() {
        guard let shape = fallingShape else {
            return
        }
        
        while detectIllegalPlacement() == false {
            shape.lowerShapeByOneRow()
        }
        shape.raiseShapeByOneRow()
        delegate?.gameShapeDidDrop(gamemaster: self)
    }
    
    //define game function calling once every tick,
    //attempts to lower shape by one row and ends game
    //if it fails to find a spot
    func letShapeFall() {
        guard let shape = fallingShape else {
            return
        }
        
        shape.lowerShapeByOneRow()
        
        if detectIllegalPlacement() {
            
            shape.raiseShapeByOneRow()
            
            if detectIllegalPlacement() {
                
                endGame()
                
            } else {
                
                settleShape()
                
            }
        } else {
            delegate?.gameShapeDidMove(gamemaster: self)
            
            if detectTouch() {
                
                settleShape()
                
            }
        }
    }
    
    //allows player to rotate shape clockwise
    //if rotate violates boundries or overlaps with settled
    //reverts rotation and returns
    func rotateShape() {
        
        guard fallingShape != fallingShape else {
            
            return
            
        }
        
        delegate?.gameShapeDidMove(gamemaster: self)
        
    }
    
    //allows player to move shape left or right
    func moveShapeLeft() {
        guard let shape = fallingShape else {
            
            return
            
        }
        
        shape.shiftLeftByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftRightByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(gamemaster: self)
    }
    
    func moveShapeRight() {
        
        guard let shape = fallingShape else {
            
            return
            
        }
        
        shape.shiftRightByOneColumn()
        
        guard detectIllegalPlacement() == false else {
            
            shape.shiftLeftByOneColumn()
            
            return
        }
        delegate?.gameShapeDidMove(gamemaster: self)
    }
    
    //adds falling shape to blocks maintained by gamemaster
    //notifies game that piece has become part of board
    func settleShape() {
        guard let shape = fallingShape else {
            return
        }
        for block in shape.blocks {
            blockArray[block.column, block.row] = block
        }
        fallingShape = nil
        delegate?.gameShapeDidLand(gamemaster: self)
    }
    
    //detects when a shape settles into place
    //happens when shapes bottom blocks touch block
    //or when block reaches bottom of board
    func detectTouch() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for bottomBlock in shape.bottomBlocks {
            if bottomBlock.row == NumRows - 1
                || blockArray[bottomBlock.column, bottomBlock.row + 1] != nil {
                return true
            }
        }
        return false
    }
    
    func endGame() {
        score = 0
        level = 1
        delegate?.gameDidEnd(gamemaster: self)
    }
    
    //defines function returns tuple
    //two arrays, lines removed & fallenblocks
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
        var removedLines = Array<Array<Block>>()
        for row in (1..<NumRows).reversed() {
            var rowOfBlocks = Array<Block>()
            
            //for loop, adds every block in given row to loval array named rowofblocks
            //if ends up with full set, 10 blocks total, removes line
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
            }
                
                if rowOfBlocks.count == NumColumns {
                    removedLines.append(rowOfBlocks)
                    for block in rowOfBlocks {
                        blockArray[block.column, block.row] = nil
                    }
                }
            }
        
                
                //check to see if recovered any lines, if not, returns empty
                if removedLines.count == 0 {
                    return ([], [])
                }
                
                //add points to player's score based on lines created and level
                //if points exceed level times 1000, level up
                let pointsEarned = removedLines.count * PointsPerLine * level
                score += pointsEarned
                if score >= level * LevelThreshold {
                        level += 1
                    delegate?.gameDidLevelUp(gamemaster: self)
                }
                
                var fallenBlocks = Array<Array<Block>>()
                for column in 0..<NumColumns {
                        var fallenBlocksArray = Array<Block>()
                    
                    //take remaning blocks on gameboard and lower by one after removed lines
                    for row in (1..<removedLines[0][0].row).reversed() {
                    guard let block = blockArray[column, row] else {
                        continue
                    }
                    var newRow = row
                    while (newRow < NumRows - 1 && blockArray[column, newRow + 1] == nil) {
                        newRow += 1
                    }
                    
                    block.row = newRow
                    blockArray[column, row] = nil
                    blockArray[column, newRow] = block
                    fallenBlocksArray.append(block)
                }
                
                if fallenBlocksArray.count > 0 {
                    fallenBlocks.append(fallenBlocksArray)
                
                }
        }
        return (removedLines, fallenBlocks)
    }
    
    func removeAllBlocks() -> Array<Array<Block>> {
        var allBlocks = Array<Array<Block>>()
        
        for row in 0..<NumRows {
            var rowOfBlocks = Array<Block>()
            
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
                blockArray[column, row] = nil
            }
            allBlocks.append(rowOfBlocks)
        }
        return allBlocks
    }
}
