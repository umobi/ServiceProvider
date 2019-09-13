//
//  BaseService.swift
//  TokBeauty
//
//  Created by Ramon Vicente on 14/03/17.
//  Copyright © 2017 TokBeauty. All rights reserved.
//

import Foundation
import KeychainAccess

open class ServiceStoredController<Value>: ServiceController {
    required public init() {}
    
    final private var storedValue: Value? = nil
    public private(set) final var value: Value? {
        get {
            self.storedValue = self.prepareToRestore()
            return self.storedValue
        }
        
        set {
            self.storedValue = self.prepareToSync(newValue)
        }
    }
    
    final public var isStored: Bool {
        return self.storedValue != nil
    }
    
    open func shouldRestore(_ oldValue: Value?) -> Bool { return true }
    open func restore() -> Value? { return self.storedValue }
    private final func prepareToRestore() -> Value? {
        guard self.shouldRestore(self.storedValue) else {
            return self.storedValue
        }
        
        return self.restore()
    }
    
    open func shouldSync(_ newValue: Value?) -> Bool { return true }
    open func sync(_ newValue: Value?) {}
    private final func prepareToSync(_ value: Value?) -> Value? {
        guard self.shouldSync(value) else {
            return self.storedValue
        }
        
        self.sync(value)
        return value
    }
    
    open func discart() {
        self.storedValue = nil
    }
    
    public final func setValue(_ value: Value?) {
        self.value = value
    }
}
