//
//  Shape.swift
//  FinalProject
//
//  Created by Thomas Finnegan on 2018-06-19.
//  Copyright © 2018 Thomas Finnegan. All rights reserved.
//
//  creates shape styles and rotations for shapes
//

import SpriteKit

let NumOrientations: UInt32 = 4

//shape rotation
enum Orientation: Int, CustomStringConvertible {
    case Zero = 0, Ninety, OneEighty, TwoSeventy
    
    var description: String {
        switch self {
        case .Zero:
            return "0"
        case .Ninety:
            return "90"
        case .OneEighty:
            return "180"
        case .TwoSeventy:
            return "270"
        }
    }
    
    static func random() -> Orientation {
        return Orientation(rawValue:Int(arc4random_uniform(NumOrientations)))!
    }
    
    //method for returning orientation whether clockwise or counter
    static func rotate(orientation:Orientation, clockwise: Bool) -> Orientation {
        var rotated = orientation.rawValue + (clockwise ? 1 : -1)
        if rotated > Orientation.TwoSeventy.rawValue {
            rotated = Orientation.Zero.rawValue
        } else if rotated < 0 {
            rotated = Orientation.TwoSeventy.rawValue
        }
        return Orientation(rawValue:rotated)!
    }
}

//creates shapes

//shape variety
let NumShapeTypes: UInt32 = 7

//shape indexes
let FirstBlockIdx: Int = 0
let SecondBlockIdx: Int = 1
let ThirdBlockIdx: Int = 2
let FourthBlockIdx: Int = 3

class Shape: Hashable, CustomStringConvertible {
    
    //color of shape
    //calls on BlockColor to randomize the color between the 6
    let color:BlockColor
    
    //blocks comprising shape
    var blocks = Array<Block>()
    
    //current orientation of shape
    var orientation: Orientation
    
    //column and row for anchor point of shape
    var column, row:Int
    
    //overrides
    
    //defines dictionarym maps one object to another
        //subclasses override this
    var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [:]
    }
    //returns empty value
        //subclasses override this
    var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [:]
    }
    
    //returns bottom blocks of shape at current orientation
    var bottomBlocks:Array<Block> {
        guard let bottomBlocks = bottomBlocksForOrientations[orientation] else {
            return []
        }
        return bottomBlocks
    }
    
    //hashable
    var hashValue:Int {
       
        //iterate through blocks array
        return blocks.reduce(0) { $0.hashValue ^ $1.hashValue }
    }
    
    //customstringconvertible
    var description:String {
        return "\(color) block facing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"
    }
    
    init(column:Int, row:Int, color: BlockColor, orientation:Orientation) {
        self.color = color
        self.column = column
        self.row = row
        self.orientation = orientation
        //initializeBlocks()
    }
    
    
    //special init, simplifies init process for shape class,
    //assigns given row & column values
    //while generating orientation
    convenience init(column:Int, row:Int) {
        self.init(column:column, row:row, color:BlockColor.random(), orientation:Orientation.random())
    }
    
    //define final function, cannot be overridden by sublasses
    //sape and subsclasses must use implementation of initBlocks
    final func initializeBlocks() {
        guard let blockRowColumnTranslations = blockRowColumnPositions[orientation] else {
            return
        }
    //use map function to create blocks array. performs specific task
    //executes  provided code block for each object in array
        blocks = blockRowColumnTranslations.map { (diff) -> Block in
            return Block(column: column + diff.columnDiff, row: row + diff.rowDiff, color: color)
        }
    }
    
    final func rotateBlocks(orientation: Orientation) {
        guard let blockRowColumnTranslation:Array<(columnDiff: Int, rowDiff: Int)> = blockRowColumnPositions[orientation] else {
            return
        }
        
    //introduces enum func, allows to iterate through array by definding index var
        for (idx, diff) in blockRowColumnTranslation.enumerated() {
            blocks[idx].column = column + diff.columnDiff
            blocks[idx].row = row + diff.rowDiff
        }
    }
    
    //methods for rotating shape clockwise or counter
    final func rotateClockwise() {
        let newOrientation = Orientation.rotate(orientation: orientation, clockwise: true)
        rotateBlocks(orientation: newOrientation)
        orientation = newOrientation
    }
    
    final func rotateCounterClockwise() {
        let newOrientation = Orientation.rotate(orientation: orientation, clockwise: false)
        rotateBlocks(orientation: newOrientation)
        orientation = newOrientation
    }
    
    final func lowerShapeByOneRow() {
        shiftBy(columns: 0, rows: 1)
    }
    
    final func raiseShapeByOneRow() {
        shiftBy(columns: 0, rows: -1)
    }
    
    final func shiftRightByOneColumn() {
        shiftBy(columns: 1, rows: 0)
    }
    
    final func shiftLeftByOneColumn() {
        shiftBy(columns: -1, rows: 0)
    }
    
    //simple method which adjusts each column and row
    final func shiftBy(columns: Int, rows: Int) {
        self.column += columns
        self.row += rows
        for block in blocks {
            block.column += columns
            block.row += rows
        }
    }
    
    //provides aproach to posision by setting properties before rotating blocks
    //causes accurate realignment of blocks to new properties
    final func moveTo(column: Int, row: Int) {
        self.column = column
        self.row = row
        rotateBlocks(orientation: orientation)
    }
    
    final class func random(startingColumn: Int, startingRow: Int) -> Shape {
        switch Int(arc4random_uniform(NumShapeTypes)) {
            
    // created method to generate random shapes
        case 0:
            return ShapeSquare      (column: startingColumn, row: startingRow)
        case 1:
            return ShapeLine        (column: startingColumn, row: startingRow)
        case 2:
            return ShapeL           (column: startingColumn, row: startingRow)
        case 3:
            return ShapeJ           (column: startingColumn, row: startingRow)
        case 4:
            return ShapeT           (column: startingColumn, row: startingRow)
        default:
            return ShapeZ           (column: startingColumn, row: startingRow)
        }
    }
    
}

func == (lhs: Shape, rhs: Shape) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}

