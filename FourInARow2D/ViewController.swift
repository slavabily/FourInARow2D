//
//  ViewController.swift
//  FourInARow2D
//
//  Created by slava bily on 3/10/19.
//  Copyright © 2019 slava bily. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController {
    
    var strategist: GKMinmaxStrategist!
    var placedChips = [UIView]()
    var board: Board!
    
    @IBOutlet var buttons: [UIButton]!
    
    @IBAction func makeMove(_ sender: UIButton) {
        let button = sender.tag

        if let slot = board.nextEmptySlot(in: button) {
            board.add(chip: board.currentPlayer.chip, in: slot)
            addChip(inButton: slot, color: board.currentPlayer.color)
            continueGame()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        strategist = GKMinmaxStrategist()
        strategist.randomSource = nil
        
        for _ in 0 ..< Board.width * Board.height {
            placedChips.append(UIView())
        }
        levelSet()
        resetBoard()
    }
    
    @objc func levelSet() {
        let alert = UIAlertController(title: "Level", message: "Please, select difficulty level", preferredStyle: .alert)
        
        let low = UIAlertAction(title: "Easy", style: .default) { [unowned self] _ in
            self.strategist.maxLookAheadDepth = 2
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Easy level", style: .plain, target: self, action: #selector(self.levelSet))
        }
        let medium = UIAlertAction(title: "Medium", style: .default) { [unowned self] _ in
            self.strategist.maxLookAheadDepth = 4
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Medium level", style: .plain, target: self, action: #selector(self.levelSet))
        }
        let hard = UIAlertAction(title: "Hard", style: .default) { [unowned self] _ in
            self.strategist.maxLookAheadDepth = 6
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hard level", style: .plain, target: self, action: #selector(self.levelSet))
        }
        alert.addAction(low)
        alert.addAction(medium)
        alert.addAction(hard)
        
        present(alert, animated: true)
    }
    
    // MARK: AI launch
    
    func resetBoard() {
        board = Board()
        
        strategist.gameModel = board
        
        updateUI()
        
        for chip in placedChips {
            chip.removeFromSuperview()
        }
        placedChips.removeAll(keepingCapacity: true)
    }
    
    func buttonForAIMove() -> Int? {
        if let aiMove = strategist.bestMove(for: board.currentPlayer) as? Move {
            return aiMove.button
        }
        
        return nil
    }
    
    func makeAIMove(in button: Int) {
        
        buttons.forEach { $0.isEnabled = true }
        navigationItem.leftBarButtonItem = nil
        
        if let slot = board.nextEmptySlot(in: button) {
            board.add(chip: board.currentPlayer.chip, in: slot)
            addChip(inButton: button, color: board.currentPlayer.color)
            continueGame()
        }
    }
    
    func startAIMove() {
        
        buttons.forEach { (button) in
            button.isEnabled = false
        }
        
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: spinner)
        
        DispatchQueue.global().async { [unowned self] in
            let strategistTime = CFAbsoluteTimeGetCurrent()
            guard let button = self.buttonForAIMove() else { return }
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
            
            let aiTimeCeiling = 1.0
            let delay = aiTimeCeiling - delta
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.makeAIMove(in: button)
            }
        }
    }
    
    func addChip(inButton slot: Int, color: UIColor) {
        
        let button = buttons[slot]
        
        let size = min(button.frame.width, button.frame.height)
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        
        let newChip = UIView()
        newChip.frame = rect
        newChip.isUserInteractionEnabled = false
        newChip.backgroundColor = color
        newChip.layer.cornerRadius = size / 2
        newChip.center = positionForChip(inSlot: slot) ?? button.center
        newChip.transform = CGAffineTransform(scaleX: 0, y: 0)
        view.addSubview(newChip)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            newChip.transform = CGAffineTransform.identity
        })
        
        placedChips.append(newChip)
    }
    
    func positionForChip(inSlot slot: Int) -> CGPoint? {
        let button = buttons[slot]
        
        if let stack = button.superview {
            
//            let size = min(stack.frame.width, stack.frame.height)
            
            let tag = button.tag
            
            switch tag {
            case 0...3:
                return CGPoint(x: stack.center.x, y: button.center.y)
            case 4...7:
                return CGPoint(x: stack.center.x, y: button.center.y)
            case 8...11:
                return CGPoint(x: stack.center.x, y: button.center.y)
            case 12...15:
                return CGPoint(x: stack.center.x, y: button.center.y)
            default:
                break
            }
            
//            switch tag {
//            case 0...3:
//                return CGPoint(x: button.center.x, y: button.center.y)
//            case 4...7:
//                return CGPoint(x: button.center.x + size + 2, y: button.center.y)
//            case 8...11:
//                return CGPoint(x: button.center.x + (size + 2) * 2, y: button.center.y)
//            case 12...15:
//                return CGPoint(x: button.center.x + (size + 2) * 3, y: button.center.y)
//            default:
//                break
//            }
        }
        return nil
    }
    
    func updateUI() {
        title = "\(board.currentPlayer.name)'s Turn"
        
        if board.currentPlayer.chip == .black {
            startAIMove()
        }
    }
    
    func continueGame() {
        // 1
        var gameOverTitle: String? = nil
        
        // 2
        
        if board.isWin(for: board.currentPlayer) {
            gameOverTitle = "\(board.currentPlayer.name) Wins!"
        } else if board.isAlmostFull() {
            gameOverTitle = "Draw!"
        }
        
        // 3
        if gameOverTitle != nil {
            let alert = UIAlertController(title: gameOverTitle, message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Play Again", style: .default) { [unowned self] (action) in
                self.resetBoard()
            }
            
            alert.addAction(alertAction)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.present(alert, animated: true)
            }
            
            return
        }
        
        // 4
        board.currentPlayer = board.currentPlayer.opponent
        updateUI()
    }
}

