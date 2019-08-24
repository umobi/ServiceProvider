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

public protocol ServiceStoredRxProtocol: ServiceNotification {
    associatedtype T
    var value: T { get }
    
    var valueObservable: Observable<T> { get }
}

public extension ServiceStoredRxProtocol {
    var valueObservable: Observable<T> {
        return NotificationCenter.default.rx
            .notification(NotificationKeys.valueDidChange.name)
            .map { _ in return self.value }
            .startWith(self.value)
    }
}

public typealias ServiceStoredRx<P: ProviderType, T> = ServiceStored<P, T> & ServiceStoredRxProtocol
