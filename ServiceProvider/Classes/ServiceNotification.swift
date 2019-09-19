//
//  ServiceNotification.swift
//  mercadoon
//
//  Created by brennobemoura on 21/08/19.
//  Copyright © 2019 brennobemoura. All rights reserved.
//

import Foundation

public protocol NotificationKey: RawRepresentable where RawValue == String {}

public protocol ServiceNotification {
    associatedtype NotificationKeys: NotificationKey
}

public extension NotificationKey {
    func name<Service: ServiceNotification>(_ serviceNotification: Service) -> Notification.Name {
        return Notification.Name(serviceNotification.identifier + "." + self.rawValue)
    }
}

public extension ServiceNotification {
    func post(object: Any? = nil, for key: NotificationKeys) {
        NotificationCenter.default.post(name: key.name(self), object: nil)
    }
}

internal extension ServiceNotification {
    var identifier: String {
        return String(format: "%02X", UInt(bitPattern: ObjectIdentifier(Self.self)))
    }
}
