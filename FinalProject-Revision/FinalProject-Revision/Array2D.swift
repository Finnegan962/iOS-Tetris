//
//  Array2D.swift
//  FinalProject
//
//  Created by Thomas Finnegan on 2018-06-18.
//  Copyright © 2018 Thomas Finnegan. All rights reserved.
//
//  create rows and columns for game to process Tetris blocks falling and full rows.
//
//

//define class
class Array2D<T> {
    
    let columns: Int
    let rows: Int
    
//declare array, maintains references and is underlying structure
    var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows

//instantiate array with size rows x columns
//guarantees array2d will store all objects game board uses
        array = Array<T?>(repeating: nil, count: rows * columns)
    //  array = Array<T?>(count: rows * columns, repeatedValue: nil)
    }
    
//subscript for array 2d to support array[column, row]
//get value at location by multiplying row by class variable columns,
//then add column number to reach final dest
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[(row * columns) + column]
        }
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
    }
}
