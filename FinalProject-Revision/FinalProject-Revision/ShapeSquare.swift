//
//  SquareShape.swift
//  FinalProject
//
//  Created by Thomas Finnegan on 2018-06-25.
//  Copyright © 2018 Thomas Finnegan. All rights reserved.
//
// creates the square shaped block, easiest one to do as does not rotate
//

class ShapeSquare:Shape {

/*
 
//comment describing blocks
     
        | 0*| 1 |
        | 2 | 3 |
 
 *marks row/column indiciation for shape
 
*/

    //overrides brcp property to provide dictionary of arrays
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>]
        {
    return [
        Orientation.Zero:
            [(0,0), (1,0), (0,1), (1,1)],
        Orientation.OneEighty:
            [(0,0), (1,0), (0,1), (1,1)],
        Orientation.Ninety:
            [(0,0), (1,0), (0,1), (1,1)],
        Orientation.TwoSeventy:
            [(0,0), (1,0), (0,1), (1,1)]
        ]
    }
    //similar override to above, but providing to bottom blocks
    override var bottomBlocksForOrientations: [Orientation : Array<Block>]
        {
        return [
            Orientation.Zero:
                [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.OneEighty:
                [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.Ninety:
                [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.TwoSeventy:
                [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
        ]
    }
}

