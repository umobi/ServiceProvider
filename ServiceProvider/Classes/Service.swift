//
//  Service.swift
//  mercadoon
//
//  Created by brennobemoura on 13/08/19.
//  Copyright © 2019 brennobemoura. All rights reserved.
//

import Foundation

public protocol ProviderType: class {
    init()
}

public protocol ServiceType {
    func start()
}

open class Service<T: ProviderType>: ServiceType {
    final public unowned let provider: T
    
    public init(provider: T) {
        self.provider = provider
    }
    
    open func start() {}
}
