//
// Copyright (c) 2019-Present Umobi - https://github.com/umobi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
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
