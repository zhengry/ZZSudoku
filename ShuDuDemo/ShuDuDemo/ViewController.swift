//
//  ViewController.swift
//  ShuDuDemo
//
//  Created by zry on 2018/6/4.
//  Copyright © 2018年 zry. All rights reserved.
//

import UIKit

extension UIView {
    public var width: CGFloat {
        get{
            return self.frame.size.width
        }
        set(newWidth){
            var frame = self.frame
            frame.size.width = newWidth
            self.frame = frame
        }
    }
    public var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set(newHeight) {
            var frame = self.frame
            frame.size.height = newHeight
            self.frame = frame
        }
    }
    
    public var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set(newLeft) {
            var frame = self.frame
            frame.origin.x = newLeft
            self.frame = frame
            
        }
    }
    
    public var top: CGFloat {
        get{
            return self.frame.origin.y
        }
        
        set(newTop){
            var frame = self.frame
            frame.origin.y = newTop
            self.frame = frame
            
        }
    }
    
    public var right: CGFloat {
        get{
            return self.frame.origin.x + self.frame.size.width
        }
        set(newRight){
            var frame = self.frame
            frame.origin.x = newRight - frame.size.width
            self.frame = frame
            
        }
    }
    
    public var bottom: CGFloat {
        get{
            return self.frame.origin.y + self.frame.size.height
        }
        set(newBottom){
            var frame = self.frame
            frame.origin.y = newBottom - frame.size.height
            self.frame = frame
            
        }
    }
    
    public var centerX: CGFloat {
        get{
            return self.center.x
        }
        set(newCenterX) {
            self.center = CGPoint(x: newCenterX, y: self.center.y)
        }
    }
    
    public var centerY: CGFloat {
        get{
            return self.center.y
        }
        set(newCenterY) {
            self.center = CGPoint(x: self.center.x, y: newCenterY)
        }
    }
    
    public var size: CGSize {
        get{
            return self.frame.size
        }
        set(newSize){
            var frame = self.frame
            frame.size = newSize
            self.frame = frame
            
        }
    }
    
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let NORMAL_BG_COLOR = 0xFFFFFF
    let SELECT_BG_COLOR = 0x6495ED
    let HIGHLIGHT_BG_COLOR = 0xB0C4DE
    let ERROR_TEXT_COLOR = 0xFF0000
    let NORMAL_TEXT_COLOR = 0x000000
    let CELL_ID = "EditCell"
    let CELL_WIDTH = (UIScreen.main.bounds.width - 20) / 9.00
    
    var collection: UICollectionView!
    var allCells = [EditCell]()//所有cell
    
    var highLightCells = [EditCell]()//高亮的cell
    var normalCells = [EditCell]()//被取消高亮的cell
    
    var selectCell : EditCell?
    var manager = PlatePresentationManager()
    var generalArray = Array<Array<Int>>(repeating: Array<Int>(repeating: 0, count: 9), count: 9)//初始化数组
//    var amendedArray = Array<Array<Int>>(repeating: Array<Int>(repeating: 0, count: 9), count: 9)//填充过的数组
    var errorCount = 0//记录数字为0或填错的个数，用于判断game success
    var currentLevel = LevelType(level: .level1, empty: .level1Empty, time: .time1)
    var operations = [(Int, Int, Bool)]()//记录用户操作顺序（当前cell的index, 填入的数, 是否error）
    var timer: Timer?
    var timerCount = 0
    var timerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.configureUI()
        self.loadShudu(withLevel: currentLevel)
        errorCount = currentLevel.empty.rawValue
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTimer()
    }
    
    //MARK: - Init Level
    func loadShudu(withLevel level: LevelType) -> Void {
        
        self.stopTimer()
        currentLevel = level
        timerCount = level.time.rawValue
        generalArray = manager.generate(forLevel: level)
//        amendedArray = generalArray
        errorCount = level.empty.rawValue
        operations.removeAll()
        collection.reloadData()
        self.startTimer()
    }
    
    //MARK: - configuration
    func configureUI() -> Void {
        
        let layout = UICollectionViewFlowLayout.init()
        
        layout.itemSize = CGSize(width: CELL_WIDTH, height: CELL_WIDTH)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collection = UICollectionView(frame: CGRect(x: 10, y: 100, width: view.bounds.width - 20, height: view.bounds.width - 20), collectionViewLayout: layout)
        collection.backgroundColor = self.hexColor(hex: 0xF5F5F5)
        collection.dataSource = self
        collection.delegate = self
        view.addSubview(collection!)
        collection.register(UINib.init(nibName: "EditCell", bundle: nil), forCellWithReuseIdentifier: CELL_ID)
        
        self.addLines()
        self.addFigureBtns()
        self.addNewGameBtn()
        self.addGameAgainBtn()
        self.addRevokeBtn()
        self.addDeleteBtn()
        self.addTimerLabel()
    }

    func addLines() -> Void {
        collection.clipsToBounds = false
        for i in 0 ... 3 {
            let line = UIView(frame: CGRect(x: 0, y: CELL_WIDTH * CGFloat(3 * i), width: collection.bounds.width, height: 2))
            line.backgroundColor = UIColor.black
            line.center = CGPoint(x: collection.bounds.width / 2.00, y: CELL_WIDTH * CGFloat(3 * i))
            collection.addSubview(line)
            
            let columnLine = UIView(frame: CGRect(x: CELL_WIDTH * CGFloat(3 * i), y: 0, width: 2, height: collection.bounds.height))
            columnLine.backgroundColor = UIColor.black
            columnLine.center = CGPoint(x: CELL_WIDTH * CGFloat(3 * i), y: collection.bounds.width / 2.00)
            collection.addSubview(columnLine)
            
        }
        
    }
    
    func addFigureBtns() -> Void {
        let btnWidth = view.bounds.width / 9.00
        
        for i in 1 ... 9 {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: btnWidth * CGFloat(i - 1), y: view.bounds.height - 30 - btnWidth, width: btnWidth, height: btnWidth)
            button.backgroundColor = UIColor.clear
            button.setTitle(String(format: "%d", i), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 35)
            button.setTitleColor(self.hexColor(hex: 0x4682B4), for: .normal)
            button.tag = 1000 + i
            button.addTarget(self, action: #selector(selectFigure(button:)), for: UIControlEvents.touchUpInside)
            view.addSubview(button)
        }
    }
    //新游戏（重新选级）
    func addNewGameBtn() {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 50, y: 30, width: 80, height: 40)
        button.backgroundColor = UIColor.clear
        button.setTitle("新游戏", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.setTitleColor(self.hexColor(hex: 0x495ED), for: .normal)
        button.addTarget(self, action: #selector(newGame), for: .touchUpInside)
        button.sizeToFit()
        button.left = 100
        button.top = 30
        view.addSubview(button)
        
    }
    //重来(擦除填写数据)
    func addGameAgainBtn() {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: view.width - 150, y: 30, width: 100, height: 40)
        button.backgroundColor = UIColor.clear
        button.setTitle("重来", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.setTitleColor(self.hexColor(hex: 0x495ED), for: .normal)
        button.addTarget(self, action: #selector(gameAgain), for: .touchUpInside)
        button.sizeToFit()
        button.right = view.width - 100
        button.top = 30
        view.addSubview(button)
    }
    
    //撤销
    func addRevokeBtn() {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 50, y: collection.bottom + 30, width: 100, height: 40)
        button.backgroundColor = UIColor.clear
        button.setTitle("撤销", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.setTitleColor(self.hexColor(hex: 0x495ED), for: .normal)
        button.addTarget(self, action: #selector(revokeFigure), for: .touchUpInside)
        view.addSubview(button)
        
    }
    
    //橡皮擦（擦除选中的数据）
    func addDeleteBtn() {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: view.width - 150, y: collection.bottom + 30, width: 100, height: 40)
        button.backgroundColor = UIColor.clear
        button.setTitle("橡皮擦", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.setTitleColor(self.hexColor(hex: 0x495ED), for: .normal)
        button.addTarget(self, action: #selector(deleteFigure), for: .touchUpInside)
        view.addSubview(button)
    }
    
    func addTimerLabel() {
        timerLabel = UILabel(frame: CGRect(x: 0, y: collection.bottom + 90, width: 100, height: 40))
        timerLabel.centerX = view.width / 2.0
        timerLabel.backgroundColor = UIColor.clear
        timerLabel.font = UIFont.systemFont(ofSize: 20)
        timerLabel.textColor = self.hexColor(hex: 0xF08080)
        timerLabel.textAlignment = .center
        timerLabel.text = String(format: "%.2d:%.2d", timerCount / 60, timerCount % 60)
        view.addSubview(timerLabel)
    }
    
    
    //MARK: - Button Click
    @objc func selectFigure(button: UIButton) -> Void {
        // configure or delete
        // record operation（index figure isError）
        // add or reduce zero
        
        if selectCell == nil || !(selectCell?.editable)!{
            //提示用户选中某个空格
            let alert = UIAlertController(title: "请选择一个空格填充数字", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "确定", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let original = selectCell?.isTrue
        
        let figure = button.tag - 1000
        // Change OR Config OR Delete
        selectCell?.title = (selectCell?.title != figure) ? figure : 0
        selectCell?.titleLabel.text = String(format: "%d", (selectCell?.title)!)
        selectCell?.titleLabel.textColor = self.hexColor(hex: NORMAL_TEXT_COLOR)
        
        var result = false//数字是否合法
        let rowAvailable = manager.checkRow(n: (selectCell?.title)!, row: (selectCell?.row)!)
        let colAvailable = manager.checkColumn(n: (selectCell?.title)!, column: (selectCell?.column)!)
        let zoneAvailable = manager.checkZoneCells(n: (selectCell?.title)!, x: (selectCell?.row)!, y: (selectCell?.column)!)
        result = rowAvailable && colAvailable && zoneAvailable
        
        // record operation
        let operation = ((selectCell?.index)!, (selectCell?.title)!, result)
        operations.append(operation)
        print("selectOperations:\(operations)")
        // modify array
//        amendedArray[(selectCell?.row)!][(selectCell?.column)!] = (selectCell?.title)!
        
        if result {
            manager.shuduArr[(selectCell?.row)!][(selectCell?.column)!] = (selectCell?.title)!
        }else{
            manager.shuduArr[(selectCell?.row)!][(selectCell?.column)!] = 0
        }
        
        selectCell?.isTrue = result
        self.change(cell: selectCell, result: result)

        if result != (original!) {
            if result {
                errorCount -= 1
            }else{
                errorCount += 1
            }
        }
        print("errorCount---\(errorCount)")
        
        if result && errorCount == 0 {
            self.gameSuccess()
        }
    }
    
    @objc func newGame() {
        
        if errorCount != 0 {
            let alert = ZZAlertView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
            alert.add(Title: "离开当前游戏？")
            let confirm = ZZAlertAction(title: "确定") {
                self.selectGrand()
            }
            let cancel = ZZAlertAction(title: "取消") {
                alert.dismiss()
            }
            alert.add(Action: confirm)
            alert.add(Action: cancel)
            alert.show(inView: view)

        }else{
            self.selectGrand()
        }


    }

    func selectGrand() -> Void {
        //选择等级 reload
        let alert = UIAlertController(title: "选择难度", message: nil, preferredStyle: .actionSheet)
        let action0 = UIAlertAction(title: "容易", style: .default) { (_) in
            let level = LevelType(level: .level1, empty: .level1Empty, time: .time1)
            
            self.loadShudu(withLevel: level)
        }
        let action1 = UIAlertAction(title: "一般", style: .default) { (_) in
            let level = LevelType(level: .level2, empty: .level2Empty, time: .time2)
            self.loadShudu(withLevel: level)
        }
        let action2 = UIAlertAction(title: "中等", style: .default) { (_) in
            let level = LevelType(level: .level3, empty: .level3Empty, time: .time3)
            self.loadShudu(withLevel: level)
        }
        let action3 = UIAlertAction(title: "较难", style: .default) { (_) in
            let level = LevelType(level: .level4, empty: .level4Empty, time: .time4)
            self.loadShudu(withLevel: level)
        }
        let action4 = UIAlertAction(title: "困难", style: .default) { (_) in
            let level = LevelType(level: .level5, empty: .level5Empty, time: .time5)
            self.loadShudu(withLevel: level)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(action0)
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(action4)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    //挑战成功
    func gameSuccess() -> Void {
        self.stopTimer()
        let count = currentLevel.time.rawValue - timerCount
        var msg = ""
        
        if count < 60 {
            msg = "用时\(count)秒"
        }else{
            msg = "用时\(count / 60)分\(count % 60)秒"
        }
        let defaults = UserDefaults()
        defaults.set(count, forKey: "time")
        defaults.synchronize()
        
        let alert = UIAlertController(title: "恭喜您挑战成功！", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "挑战新游戏", style: .default) { (_) in
            self.newGame()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func gameFail()  {
        
        let alert = ZZAlertView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        alert.add(Title: "挑战失败!")
        let action0 = ZZAlertAction(title: "继续挑战") {
            alert.dismiss()
            self.stopTimer()
        }
        let action1 = ZZAlertAction(title: "新游戏") {
            alert.dismiss()
            self.selectGrand()
        }
        alert.add(Action: action0)
        alert.add(Action: action1)
        alert.show(inView: view)
        
    }
    
    /// 重来
    @objc func gameAgain() {

//        amendedArray = generalArray
        errorCount = currentLevel.empty.rawValue
        operations.removeAll()
        selectCell = nil
        collection.reloadData()
    }
    
    /// 撤销
    @objc func revokeFigure() {
        if operations.count == 0 {
            return
        }
        let operation = operations.last
        print("revokeOperations:\(operations)")
        let cell0: EditCell = allCells[(operation?.0)!]
        let isTrue: Bool = (operation?.2)!

        if operations.count >= 2 {
            let cellIndex = operations[operations.count - 2].0
            let cell1 = allCells[cellIndex]
            if cell0.isEqual(cell1) {
                cell0.title = operations[operations.count - 2].1
                
                let isTrue1 = operations[operations.count - 2].2
                cell0.isTrue = isTrue1
                if isTrue != isTrue1 {
                    if isTrue1 {
                        errorCount -= 1
                    }else{
                        errorCount += 1
                    }
                }
                manager.shuduArr[self.line(forIndex: cell0.index)][self.column(forIndex: cell0.index)] = cell0.title
                
            }else{
                cell0.title = 0
                manager.shuduArr[self.line(forIndex: cell0.index)][self.column(forIndex: cell0.index)] = cell0.title
                if cell0.isTrue {
                    errorCount += 1
                }
                cell0.isTrue = false
                
            }
            
        }else{
            cell0.title = 0
            manager.shuduArr[self.line(forIndex: cell0.index)][self.column(forIndex: cell0.index)] = cell0.title
            if cell0.isTrue {
                errorCount += 1
            }
            cell0.isTrue = false
        }
        self.change(cell: cell0, result: cell0.isTrue)

        if operations.count > 0 {
            operations.removeLast()
        }
        
        print("errorCount:\(errorCount)")
//        amendedArray[self.line(forIndex: cell0.index)][self.column(forIndex: cell0.index)] = cell0.title
        
    }
    
    /// 橡皮擦
    @objc func deleteFigure() {
        if operations.count == 0 {
            return
        }
        if selectCell != nil {
            if (selectCell?.editable)! && selectCell?.title != 0 {
                selectCell?.title = 0
                selectCell?.titleLabel.isHidden = true
                let operation = ((selectCell?.index)!, 0, false)
                operations.append(operation)
                if (selectCell?.isTrue)! {
                    errorCount += 1
                }
                selectCell?.isTrue = false
                
                let row = self.line(forIndex: (selectCell?.index)!)
                let col = self.column(forIndex: (selectCell?.index)!)
//                amendedArray[row][col] = 0
                manager.shuduArr[row][col] = 0
            }
           
        }
        
    }
    
    func change(cell: EditCell!, result: Bool!) {
        cell.titleLabel.text = String(format: "%d", cell.title)
        cell.titleLabel.textColor = self.hexColor(hex: (result ? NORMAL_TEXT_COLOR : ERROR_TEXT_COLOR))
        cell.titleLabel.isHidden = (cell.title == 0)
        cell.isTrue = result
    }
    
    
    
    //MARK: - Timer
    func startTimer() {
        if timer == nil {
            timerCount = currentLevel.time.rawValue
            timerLabel.text = String(format: "%.2d:%.2d", timerCount / 60, timerCount % 60)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
            timer?.fire()
        }
    }
    
    @objc func handleTimer() {
        if timerCount == 0 {
            self.stopTimer()
            if errorCount != 0 {
                self.gameFail()

            }
            return
        }
        timerCount -= 1
        timerLabel.text = String(format: "%.2d:%.2d", timerCount / 60, timerCount % 60)
    }
    
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    
    //MARK: - CollectionView Delegate && DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 81
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditCell", for: indexPath) as! EditCell
        let line = self.line(forIndex: indexPath.item)
        let column = self.column(forIndex: indexPath.item)
        cell.row = line
        cell.column = column
        cell.index = indexPath.item
        cell.zone = self.zone(forIndex: indexPath.item)
        cell.title = generalArray[line][column]
        cell.titleLabel.text = String(format: "%d", cell.title)
        cell.titleLabel.textColor = self.hexColor(hex: NORMAL_TEXT_COLOR)
        cell.contentView.backgroundColor = self.hexColor(hex: NORMAL_BG_COLOR)
        cell.titleLabel.isHidden = (cell.title == 0)
        cell.editable = (cell.title == 0)
        if cell.title != 0 {
            cell.contentView.backgroundColor = self.hexColor(hex: 0xEEEEEE)
            cell.isTrue = true
        }else{
            cell.isTrue = false
        }
        
        
        if !allCells.contains(cell) {
            allCells.append(cell)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let line = self.line(forIndex: indexPath.item)
        let column = self.column(forIndex: indexPath.item)
        let zone = self.zone(forIndex: indexPath.item)
        
        let lineCells = self.cells(forLine: line)
        let columnCells = self.cells(forColumn: column)
        let zoneCells = self.cells(forZone: zone)
        
        highLightCells = lineCells + columnCells + zoneCells
 
        for highlightCell in highLightCells {
            highlightCell.contentView.backgroundColor = self.hexColor(hex: HIGHLIGHT_BG_COLOR)
        }
        let cell = collectionView.cellForItem(at: indexPath) as! EditCell
        cell.contentView.backgroundColor = self.hexColor(hex: SELECT_BG_COLOR)
        selectCell = cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let line = self.line(forIndex: indexPath.item)
        let column = self.column(forIndex: indexPath.item)
        let zone = self.zone(forIndex: indexPath.item)
        
        let lineCells = self.cells(forLine: line)
        let columnCells = self.cells(forColumn: column)
        let zoneCells = self.cells(forZone: zone)
        normalCells = lineCells + columnCells + zoneCells
        for cell in normalCells {
            cell.contentView.backgroundColor = self.hexColor(hex: NORMAL_BG_COLOR)
            if !cell.editable {
                cell.contentView.backgroundColor = self.hexColor(hex: 0xEEEEEE)
            }
            
        }
    }
    
    
    //MARK: - CellArray
    //某行的cell
    func cells(forLine line: Int) -> [EditCell] {
        var array = [EditCell]()
        for i in (9 * line) ..< (9 * line + 9) {

            let cell = collection.cellForItem(at: IndexPath(item: i, section: 0)) as! EditCell
            array.append(cell)
        }
        return array
    }
    
    //某列的cell
    func cells(forColumn column: Int) -> [EditCell] {
        var array = [EditCell]()
        var columns = [Int]()
        for line in 0 ..< 9 {
            columns.append(9 * line + column)
        }
        
        for i in columns {
            let cell = collection.cellForItem(at: IndexPath(item: i, section: 0)) as! EditCell
            array.append(cell)
        }

        return array
    }
    
    //某个区块的cell
    
    func cells(forZone zone: (Int, Int)) -> [EditCell] {
        var array = [EditCell]()
        for cell in allCells {
            let cellZone = self.zone(forIndex: cell.index)
            if cellZone == zone {
                array.append(cell)
            }
            if array.count == 9 {
                break
            }
            
        }
        return array
    }
    
    
    func line(forIndex index: Int) -> Int {
        return index / 9
    }
    
    func column(forIndex index: Int) -> Int {
        return index % 9
    }
    
    func zone(forIndex index: Int) -> (Int, Int) {
        let x = (index / 3) % 3
        let y = (index / 3) / 9
        return (x, y)
        
    }
    
    
    //某个区块包含的9个数
    func array(forZone zone:(Int, Int)) -> [Int] {
        let cells = self.cells(forZone: zone)
        var array = [Int]()
        for cell: EditCell in cells {
            array.append(cell.title)
        }
        return array
    }
    
    //某行包含的数
    func array(forLine line: Int) -> [Int] {
        let cells = self.cells(forLine: line)
        var array = [Int]()
        for cell: EditCell in cells {
            array.append(cell.title)
        }
        return array
    }
    
    //某列包含的数
    func array(forColumn column: Int) -> [Int] {
        let cells = self.cells(forColumn: column)
        var array = [Int]()
        for cell: EditCell in cells {
            array.append(cell.title)
        }
        return array
    }
    
    //MARK: - ColorSet
    func hexColor(hex: Int) -> UIColor {
        return UIColor(red: ((CGFloat)((hex & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((hex & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(hex & 0xFF))/255.0, alpha: 1.0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

