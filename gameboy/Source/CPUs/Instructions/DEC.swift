//
//  DEC.swift
//  ostrich
//
//  Created by Ryan Conway on 3/27/16.
//  Copyright © 2016 conwarez. All rights reserved.
//

import Foundation


// DEC is split into 8-bit and 16-bit groups here because it only affects flags when working with
// 8-bit operands


func dec<T: Integer>(_ num: T) -> T {
    return num &- 1
}

/// Decrement an operand and overwrite it with the new value
/// Returns (oldValue, newValue)
func decAndStore<T: Readable & Writeable>(_ op: T) -> (T.ReadType, T.WriteType) where T.ReadType == T.WriteType, T.ReadType: Integer
{
    let oldValue = op.read()
    let newValue = dec(oldValue)
    op.write(newValue)
    
    return (oldValue, newValue)
}


/// Decrement an 8-bit operand
struct DEC8<T: Readable & Writeable & OperandType>: Z80Instruction, LR35902Instruction where T.ReadType == T.WriteType, T.WriteType == UInt8, T.ReadType == UInt8 {
    let operand: T
    
    let cycleCount = 0
    
    
    func runOn(_ cpu: Z80) {
        let (oldValue, newValue) = decAndStore(operand)
        modifyFlags(cpu, oldValue: oldValue, newValue: newValue)
    }
    
    func runOn(_ cpu: LR35902) {
        let (oldValue, newValue) = decAndStore(operand)
        modifyFlags(cpu, oldValue: oldValue, newValue: newValue)
    }
    
    
    fileprivate func modifyCommonFlags(_ cpu: Intel8080Like, oldValue: T.ReadType, newValue: T.ReadType) {
        //@warn GB manual says H is set if no borrow from bit 4
        //Z80 manual says H is set if borrow from bit 4
        //GB manual is probably a typo, so we assume Z80 manual behavior here
        
        // Z is set if result is 0; otherwise, it is reset.
        // H is set if borrow from bit 4, otherwise, it is reset.
        // N is set.
        // C is not affected.
        
        cpu.ZF.write(newValue == 0x00)
        cpu.HF.write(newValue & 0x0F == 0x0F)
        cpu.NF.write(true)
    }
    
    fileprivate func modifyFlags(_ cpu: Z80, oldValue: T.ReadType, newValue: T.ReadType) {
        modifyCommonFlags(cpu, oldValue: oldValue, newValue: newValue)
        
        // S is set if result is negative; otherwise, it is reset.
        // P/V is set if m was 80h before operation; otherwise, it is reset.
        
        cpu.SF.write(numberIsNegative(newValue))
        cpu.PVF.write(oldValue == 0x80)
    }
    
    fileprivate func modifyFlags(_ cpu: LR35902, oldValue: T.ReadType, newValue: T.ReadType) {
        modifyCommonFlags(cpu, oldValue: oldValue, newValue: newValue)
    }
}

/// Decrement a 16-bit operand
struct DEC16<T: Writeable & Readable & OperandType>: Z80Instruction, LR35902Instruction where T.ReadType == T.WriteType, T.ReadType == UInt16 {
    let operand: T
    
    let cycleCount = 0
    
    
    func runOn(_ cpu: Z80) {
        decAndStore(operand)
    }
    
    func runOn(_ cpu: LR35902) {
        decAndStore(operand)
    }
}
