//
//  ServiceStoredRx.swift
//  mercadoon
//
//  Created by brennobemoura on 21/08/19.
//  Copyright © 2019 brennobemoura. All rights reserved.
//

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

public protocol RxServiceType: ServiceType, ReactiveCompatible where Controller: (ServiceController & ServiceStoredRxProtocol) {}

open class RxService<Controller: ServiceController & ServiceStoredRxProtocol>: Service<Controller>, RxServiceType {
    public required init() {
        super.init()
    }
}

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
