//
//  Service.swift
//  mercadoon
//
//  Created by brennobemoura on 13/08/19.
//  Copyright © 2019 brennobemoura. All rights reserved.
//

import Foundation

public protocol ProviderType: class {
    static var shared: Self { get }
    
    func service<T>(_ type: T.Type) -> T where T: ServiceShared
    func remove<T>(_ type: T.Type) -> T? where T: ServiceShared
    
    func orCreate<T>(_ initCallback: @escaping () -> T.Controller) -> T where T: ServiceShared
}

public final class Provider: ProviderType {
//    typealias Service = ServiceType
    public private(set) static var shared: Provider = .init()
    
    private var services: [AnyObject] = []
    
    public func service<T>(_ type: T.Type) -> T where T: ServiceShared {
        if let service = self.services.first(where: { $0 is T }) {
            return service as! T
        }

        let service = T.init(controller: .init())
        self.services.append(service)
        return service
    }
    
    public func orCreate<T>(_ initCallback: @escaping () -> T.Controller) -> T where T: ServiceShared {
        if let service = self.services.first(where: { $0 is T }) {
            return service as! T
        }
        
        let controller = initCallback()
        let service = T.init(controller: controller)
        self.services.append(service)
        return service
    }
    
    public func remove<T>(_ type: T.Type) -> T? where T: ServiceShared {
        guard let slice = self.services.enumerated().first(where: { $0.element is T }) else {
            return nil
        }
        
        self.services.remove(at: slice.offset)
        return slice.element as? T
    }
}

public protocol ServiceController {
    init()
}

public protocol ServiceType {
    associatedtype Controller: ServiceController
    var controller: Controller { get }
    init(controller: Controller)
}

open class Service<Controller: ServiceController>: ServiceType {
    public let controller: Controller
    
    public required init(controller: Controller) {
        self.controller = controller
    }
}

public protocol ServiceShared: class, ServiceType {
    static var shared: Self { get }
}

public extension ServiceShared {
    static var shared: Self {
        return Provider.shared.service(Self.self)
    }
}
