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

#if os(iOS) || os(tvOS)

import Foundation
import RxSwift
import RxCocoa

public protocol NotificationRxKey: NotificationKey {
    static var valueDidChange: Self? { get }
}

public protocol ServiceStoredRxProtocol: ServiceNotification where NotificationKeys: NotificationRxKey {
    associatedtype Value
    var value: Value { get }
}

public extension NotificationRxKey {
    static var valueDidChange: Self? {
        guard let didChange = Self(rawValue: kValueDidChange) else {
            print("Error: ServiceProvider.NotificationKeys for \(String(describing: Self.self)) did not have kValueDidChange")
            return nil
        }
        
        return didChange
    }
}

public extension Reactive where Base: ServiceStoredRxProtocol {
    func notification<Key>(_ key: Key) -> Observable<Base.Value> where Key == Base.NotificationKeys {
        return NotificationCenter.default.rx
            .notification(key.name(self.base))
            .map { _ in return self.base.value }
    }
    
    var value: Observable<Base.Value> {
        guard let valueDidChange = Base.NotificationKeys.valueDidChange else {
            #if DEBUG
            print("Error: Calling ServiceStoredRxProtocol<\(String(describing: Base.self))>.valueObservable will not perfom any action.\nOverride NotificationKeys.valueDidChange method or set one case with default rawValue \(kValueDidChange)")
            #endif
            return .never()
        }
        
        return NotificationCenter.default.rx
            .notification(valueDidChange.name(self.base))
            .map { _ in return self.base.value }
            .startWith(self.base.value)
    }
}

public let kValueDidChange = "valueDidChange"

public typealias RxServiceStoredController<Value> = ServiceStoredController<Value> & ServiceStoredRxProtocol

public protocol RxServiceType: ServiceType, ReactiveCompatible where Controller: ServiceStoredRxProtocol {}

open class RxService<Controller: ServiceController & ServiceStoredRxProtocol>: Service<Controller>, RxServiceType {}

public extension Reactive where Base: RxServiceType {
    func notification<Key>(_ key: Key) -> Observable<Base.Controller.Value> where Key == Base.Controller.NotificationKeys {
        return NotificationCenter.default.rx
            .notification(key.name(self.base.controller))
            .map { _ in return self.base.controller.value }
    }
    
    var value: Observable<Base.Controller.Value> {
        guard let valueDidChange = Base.Controller.NotificationKeys.valueDidChange else {
            #if DEBUG
            print("Error: Calling ServiceStoredRxProtocol<\(String(describing: Base.self))>.valueObservable will not perfom any action.\nOverride NotificationKeys.valueDidChange method or set one case with default rawValue \(kValueDidChange)")
            #endif
            return .never()
        }
        
        return NotificationCenter.default.rx
            .notification(valueDidChange.name(self.base.controller))
            .map { _ in return self.base.controller.value }
            .startWith(self.base.controller.value)
    }
}

#endif
