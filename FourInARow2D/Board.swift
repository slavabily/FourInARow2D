//
//  Board.swift
//  FourInARow2D
//
//  Created by slava bily on 3/10/19.
//  Copyright © 2019 slava bily. All rights reserved.
//

import UIKit
import GameplayKit

enum ChipColor: Int {
    case none = 0
    case red
    case black
}

class Board: NSObject, GKGameModel {
    
    var players: [GKGameModelPlayer]? {
        return Player.allPlayers
    }
    
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
    
    static var width = 4
    static var height = 4
    
    var slots = [ChipColor]()
    
    var currentPlayer: Player
    
    override init() {
        
        currentPlayer = Player.allPlayers[0]
        
        for _ in 0 ..< Board.width * Board.height {
            slots.append(.none)
        }
        super.init()
    }
    
    func chip(inButton button: Int) -> ChipColor {
        return slots[button]
    }
    
    func set(chip: ChipColor, in button: Int) {
        slots[button] = chip
    }
    
    func nextEmptySlot(in button: Int) -> Int? {
        
        if chip(inButton: button) == .none {
            return button
        }
        return nil
    }
    
    func canMove(in button: Int) -> Bool {
        return nextEmptySlot(in: button) != nil
    }
    
    func add(chip: ChipColor, in button: Int) {
        if let button = nextEmptySlot(in: button) {
            set(chip: chip, in: button)
        }
    }
    
    func isAlmostFull() -> Bool {
        var i = 0
        for button in 0 ..< Board.width * Board.height {
            if canMove(in: button) {
                i += 1
            }
        }
        if i >= 3 {
            return false
        }
        return true
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool {
        let chip = (player as! Player).chip
        
        for slot in 0 ..< Board.height * Board.width {
            
            if squaresMatch(initialChip: chip, slot: slot, moveX: 1, moveY: 0) {
                return true
            } else if squaresMatch(initialChip: chip, slot: slot, moveX: 0, moveY: 1) {
                return true
            } else if squaresMatch(initialChip: chip, slot: slot, moveX: 1, moveY: 1) {
                return true
            } else if squaresMatch(initialChip: chip, slot: slot, moveX: 1, moveY: -1) {
                return true
            }
        }
        return false
    }
    
    var row = 0, col = 0
    
    func chip(inColumn col: Int, row: Int) -> ChipColor {
        return slots[row + col * Board.height]
    }
    
    func squaresMatch(initialChip: ChipColor, slot: Int, moveX: Int, moveY: Int) -> Bool {
        
        switch slot {
        case 0:
            row = 0
            col = 0
        case 1:
            row = 1
            col = 0
        case 2:
            row = 2
            col = 0
        case 3:
            row = 3
            col = 0
        case 4:
            row = 0
            col = 1
        case 5:
            row = 1
            col = 1
        case 6:
            row = 2
            col = 1
        case 7:
            row = 3
            col = 1
        case 8:
            row = 0
            col = 2
        case 9:
            row = 1
            col = 2
        case 10:
            row = 2
            col = 2
        case 11:
            row = 3
            col = 2
        case 12:
            row = 0
            col = 3
        case 13:
            row = 1
            col = 3
        case 14:
            row = 2
            col = 3
        case 15:
            row = 3
            col = 3
        default:
            break
        }
        
        if row + (moveY * 3) < 0 { return false }
        if row + (moveY * 3) >= Board.height { return false }
        if col + (moveX * 3) < 0 { return false }
        if col + (moveX * 3) >= Board.width { return false }
        
        
        if chip(inColumn: col, row: row) != initialChip { return false }
        if chip(inColumn: col + moveX, row: row + moveY) != initialChip { return false }
        if chip(inColumn: col + (moveX * 2), row: row + (moveY * 2)) != initialChip { return false }
        if chip(inColumn: col + (moveX * 3), row: row + (moveY * 3)) != initialChip { return false }
        
        return true
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Board()
        copy.setGameModel(self)
        return copy
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        if let board = gameModel as? Board {
            slots = board.slots
            currentPlayer = board.currentPlayer
        }
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        // 1
        if let playerObject = player as? Player {
            // 2
            if isWin(for: playerObject) || isWin(for: playerObject.opponent) {
                return nil
            }
            // 3
            var moves = [Move]()
            // 4
            for button in 0 ..< Board.width * Board.height {
                if canMove(in: button) {
                    // 5
                    moves.append(Move(button: button))
                }
            }
            // 6
            return moves
        }
        return nil
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        if let move = gameModelUpdate as? Move {
            add(chip: currentPlayer.chip, in: move.button)
            currentPlayer = currentPlayer.opponent
        }
    }
    
    func score(for player: GKGameModelPlayer) -> Int {
        if let playerObject = player as? Player {
            if isWin(for: playerObject) {
                return 1000
            } else if isWin(for: playerObject.opponent) {
                return -1000
            }
        }
        return 0
    }
}

