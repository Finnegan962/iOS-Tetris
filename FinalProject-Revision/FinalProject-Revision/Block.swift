//
//  Block.swift
//  FinalProject
//
//  Created by Thomas Finnegan on 2018-06-18.
//  Copyright © 2018 Thomas Finnegan. All rights reserved.
//
//  creates the falling blocks used for the game
//

import SpriteKit

//enumeration and support 6 colors
let NumberOfColors: UInt32 = 6

//decalre enum and type, implements csc
enum BlockColor: Int, CustomStringConvertible {
    
//full list of colors, 0-5 for 6 colors
    case Blue = 0, Orange, Purple, Red, Teal, Yellow
    
//property spriteName, acts like a variable but generates value each time
    var spriteName: String {
        switch self {
        case .Blue:
            return "blue"
        case .Orange:
            return "orange"
        case .Purple:
            return "purple"
        case .Red:
            return "red"
        case .Teal:
            return "teal"
        case .Yellow:
            return "yellow"
        }
    }
    
//declare another property, w/o the code wont compile
//returns spriteName of color to object
    var description: String {
        return self.spriteName
    }
    
//declare function random, returns random choice of colors
    static func random() -> BlockColor {
        return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
    }
}

func random() -> BlockColor {
    return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
}

//declare block class, implements hashable and csc
//hashable allows storign of block in array2d
class Block: Hashable, CustomStringConvertible {
    
//define color as let, so it can no longer be assigned
//without, it will change colors mid game
    let color: BlockColor
    
//declare column & row, represent location of block
//skspritenode represents visual element of block gamescene uses to animate block
    var column: Int
    var row: Int
    var sprite: SKSpriteNode?
    
//shortcut for sprite file name
    var spriteName: String {
        return color.spriteName
    }
    
//implemented hashValue property, which hashable requires to provide
//return exclusive of row and column to generate integers for each block
    var hashValue: Int {
        return self.column ^ self.row
    }
    
//implement description
    var description: String {
        return "\(color): [\(column), \(row)]"
    }
    
    init(column:Int, row:Int, color:BlockColor) {
        self.column = column
        self.row = row
        self.color = color
    }
}

//custom operate comparing one block to another
//returns true if both are in same location and of same color
func ==(lhs: Block, rhs: Block) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}
