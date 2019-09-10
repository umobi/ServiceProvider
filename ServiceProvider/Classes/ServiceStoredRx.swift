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
    associatedtype T
    var value: T { get }
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
    func notification<Key>(_ key: Key) -> Observable<Base.T> where Key == Base.NotificationKeys {
        return NotificationCenter.default.rx
            .notification(key.name)
            .map { _ in return self.base.value }
    }
    
    var value: Observable<Base.T> {
        guard let valueDidChange = Base.NotificationKeys.valueDidChange else {
            #if DEBUG
            print("Error: Calling ServiceStoredRxProtocol<\(String(describing: Base.self))>.valueObservable will not perfom any action.\nOverride NotificationKeys.valueDidChange method or set one case with default rawValue \(kValueDidChange)")
            #endif
            return .never()
        }
        
        return NotificationCenter.default.rx
            .notification(valueDidChange.name)
            .map { _ in return self.base.value }
            .startWith(self.base.value)
    }
}

public let kValueDidChange = "valueDidChange"

public typealias ServiceStoredRx<P: ProviderType, T> = ServiceStored<P, T> & ServiceStoredRxProtocol & ReactiveCompatible

public protocol ServiceRxType: ServiceType, ReactiveCompatible {}
