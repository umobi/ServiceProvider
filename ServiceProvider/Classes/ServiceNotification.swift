//
//  ServiceNotification.swift
//  mercadoon
//
//  Created by brennobemoura on 21/08/19.
//  Copyright © 2019 brennobemoura. All rights reserved.
//

import Foundation

public protocol NotificationKey: RawRepresentable where RawValue == String {
    var name: Notification.Name { get }
}

public protocol ServiceNotification {
    associatedtype NotificationKeys: NotificationKey
}

public extension NotificationKey {
    var name: Notification.Name {
        return Notification.Name("NotificationKey." + "\(self)")
    }
}

public extension ServiceNotification {
    func post(object: Any? = nil, for key: NotificationKeys) {
        NotificationCenter.default.post(name: key.name, object: nil)
    }
}
