//
//  PlatePresentationManager.swift
//  ShuDuDemo
//
//  Created by zry on 2018/6/5.
//  Copyright © 2018年 zry. All rights reserved.
//

import UIKit

//typealias Level = (, Int)

//enum LevelEmpty {
//    case level1(level: Int, empty: Int)
//    case level2(level: Int, empty: Int)
//    case level3(level: Int, empty: Int)
//    case level4(level: Int, empty: Int)
//    case level5(level: Int, empty: Int)
//}

struct LevelType {
    enum Level: Int{
        case level1 = 1
        case level2 = 2
        case level3 = 3
        case level4 = 4
        case level5 = 5
    }
    enum Empty: Int {
        case level1Empty = 40
        case level2Empty = 45
        case level3Empty = 50
        case level4Empty = 55
        case level5Empty = 60
        
    }
    enum Time: Int {
        case time1 = 900
        case time2 = 1200
        case time3 = 1500
        case time4 = 1800
        case time5 = 2100
    }
    let level: Level
    let empty: Empty
    let time: Time
}



//摆盘
class PlatePresentationManager: NSObject {
    public let SIZE = 9
    public let CELL_SIZE = 9
    public let LEVEL_MAX = 5
    public let BASIC_MASK = 40
    public var levelType: LevelType = LevelType(level: .level1, empty: .level1Empty, time: .time1)
    
    public var shuduArr = Array<Array<Int>>(repeating: Array<Int>(repeating: 0, count: 9), count: 9)
    
    func generate(forLevel level: LevelType) -> [[Int]] {
        var n = Int(arc4random()) % SIZE + 1
        for i in 0 ..< SIZE {
            for j in 0 ..< SIZE {
                for _ in 0 ..< SIZE {
                    if checkRow(n: n, row: i) && checkColumn(n: n, column: j) && checkZoneCells(n: n, x: i, y: j) {
                        shuduArr[i][j] = n
                        break
                    }else{
                        n = n % SIZE + 1
                    }
                }
            }
            
            n = n % SIZE + 1
        }
        upset()
        print(shuduArr)
        
        maskCells(forLevel: level)
        return shuduArr

    }
    
    func maskCells(forLevel level: LevelType) -> Void {
        
        //设置level有5个等级（1——5），等级越高，挖坑越多，每高一级，多挖5个坑.最低级有40个坑

//        let count = BASIC_MASK + (level - 1) * 5
        let count = level.empty.rawValue
        
        for _ in 0 ..< count {
            let m = Int(arc4random()) % SIZE
            let n = Int(arc4random()) % SIZE
            if shuduArr[n][m] > 0 {
                shuduArr[n][m] = 0
            }
        }
        
    }
    
    //随机打乱顺序
    func upset() -> Void {
        //按行交换三次，先找到一个要交换的九宫格(一共有9个,0~8)，然后选取九宫格的任意两行进行交换
        for _ in 0 ..< 3 {//交换三次
            let i = Int(arc4random()) % SIZE//获取要交换的九宫格的index
            
            let zoneX = i % 3
            let sx = zoneX * 3
            let row1 = Int(arc4random()) % 3 + sx
            let row2 = Int(arc4random()) % 3 + sx
            for column in 0 ..< SIZE {//交换row1，row2的每列数据
                if row1 != row2 {
                    let tmp = shuduArr[row1][column]
                    shuduArr[row1][column] = shuduArr[row2][column]
                    shuduArr[row2][column] = tmp
                }
            }
        }
        
        //按行交换三次，先找到一个要交换的九宫格(一共有9个,0~8)，然后选取九宫格的任意两行进行交换
        for _ in 0 ..< 3 {//交换三次
            let i = Int(arc4random()) % SIZE//获取要交换的九宫格的index
            let zoneY = i / 3
            let sy = zoneY * 3
            let column1 = Int(arc4random()) % 3 + sy
            let column2 = Int(arc4random()) % 3 + sy
            for row in 0 ..< SIZE {//交换column1，column2的每行数据
                if column1 != column2 {
                    let tmp = shuduArr[row][column1]
                    shuduArr[row][column1] = shuduArr[row][column2]
                    shuduArr[row][column2] = tmp
                }
            }
        }
    }
    
    //检查某行
    func checkRow(n: Int, row: Int) -> Bool {
        var result = true
        for i in 0 ..< SIZE {
            if shuduArr[row][i] == n {
                result = false
                break
            }
        }
        
        return result
    }
    
    //检查某列
    func checkColumn(n: Int, column: Int) -> Bool {
        var result = true
        for i in 0 ..< SIZE {
            if shuduArr[i][column] == n {
                result = false
                break
            }
        }
        
        return result
    }
    
    //检查九宫格,n表示填入的数字，x，y表示九宫格坐标
    func checkZoneCells(n: Int, x: Int, y: Int) -> Bool {
        var result = true

        let zoneX = x / 3
        let zoneY = y / 3
        let sx = zoneX * 3
        let sy = zoneY * 3

        for i in sx ..< sx + 3 {
            for j in sy ..< sy + 3 {
                if shuduArr[i][j] == n {
                    result = false
                    break
                }
            }
            if !result {
                break
            }
        }
       return result

    }
    
    
    
}

