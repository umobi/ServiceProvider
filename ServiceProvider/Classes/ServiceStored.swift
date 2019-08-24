//
//  BaseService.swift
//  TokBeauty
//
//  Created by Ramon Vicente on 14/03/17.
//  Copyright © 2017 TokBeauty. All rights reserved.
//

import Foundation
import KeychainAccess

open class ServiceStored<P: ProviderType, T>: Service<P> {
    
    final private var storedValue: T? = nil
    public private(set) final var value: T? {
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
    
    open func shouldRestore(_ oldValue: T?) -> Bool { return true }
    open func restore() -> T? { return self.storedValue }
    private final func prepareToRestore() -> T? {
        guard self.shouldRestore(self.storedValue) else {
            return self.storedValue
        }
        
        return self.restore()
    }
    
    open func shouldSync(_ newValue: T?) -> Bool { return true }
    open func sync(_ newValue: T?) {}
    private final func prepareToSync(_ value: T?) -> T? {
        guard self.shouldSync(value) else {
            return self.storedValue
        }
        
        self.sync(value)
        return value
    }
    
    open func discart() {
        self.storedValue = nil
    }
    
    public final func setValue(_ value: T?) {
        self.value = value
    }
}
