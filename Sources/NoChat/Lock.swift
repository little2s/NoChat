//
//  Lock.swift
//  
//
//  Created by yinglun on 2020/8/9.
//

import Foundation

final class UnfairLock {
    
    private var _lock = os_unfair_lock()
    
    func lock() {
        os_unfair_lock_lock(&_lock)
    }
    
    func unlock() {
        os_unfair_lock_unlock(&_lock)
    }
    
}
