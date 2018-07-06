//
//  ShapeJ.swift
//  FinalProject
//
//  Created by Thomas Finnegan on 2018-06-26.
//  Copyright © 2018 Thomas Finnegan. All rights reserved.
//

class ShapeJ:Shape {
    
    /*
     
     Orientation 0
     
    *| 0 |
     | 1 |
     | 3 | 2 |
     
     Orientation 90
     
     | 3*|
     | 2 | 1 | 0 |
     
     Orientation 180
     
     | 2*| 3 |
     | 1 |
     | 0 |
     
     Orientation 270
     
     | 0*| 1 | 2 |
     | 3 |
     
     * marks the row/column indicator for the shape
     
     Pivots about `1`
     
     */
    
    override var blockRowColumnPositions: [Orientation : Array<(columnDiff: Int, rowDiff: Int)>]
        {
        return [
            Orientation.Zero:
                [(0,0), (0,1), (1,1), (1,2)],
            Orientation.Ninety:
                [(2,0), (1,0), (1,1), (0,1)],
            Orientation.OneEighty:
                [(0,0), (0,1), (1,1), (1,2)],
            Orientation.TwoSeventy:
                [(2,0), (1,0), (1,1), (0,1)]
        ]
    }
    
    override var bottomBlocksForOrientations: [Orientation : Array<Block>]
        {
        return [
            Orientation.Zero:
                [blocks[SecondBlockIdx], blocks[FourthBlockIdx]],
            Orientation.Ninety:
                [blocks[FirstBlockIdx], blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.OneEighty:
                [blocks[SecondBlockIdx], blocks[FourthBlockIdx]],
            Orientation.TwoSeventy:
                [blocks[FirstBlockIdx], blocks[ThirdBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
}
