//
//  ServiceKeychain.swift
//  mercadoon
//
//  Created by brennobemoura on 21/08/19.
//  Copyright © 2019 brennobemoura. All rights reserved.
//

import Foundation
import KeychainAccess

public protocol KeychainKey: RawRepresentable {
    var rawValue: String { get }
}

public protocol ServiceKeychain {
    associatedtype KeychainKeys: KeychainKey
    
    var keychain: Keychain { get }
}

public extension ServiceKeychain {
    public func set(_ value: String, for key: KeychainKeys) throws {
        try self.keychain.set(value, key: key.rawValue)
    }
    
    public func set(_ value: Data, for key: KeychainKeys) throws {
        try self.keychain.set(value, key: key.rawValue)
    }
    
    public func get(for key: KeychainKeys) throws -> String? {
        return try self.keychain.getString(key.rawValue)
    }
    
    public func get(for key: KeychainKeys) throws -> Data? {
        return try self.keychain.getData(key.rawValue)
    }
    
    public func remove(for key: KeychainKeys) throws {
        try self.keychain.remove(key.rawValue)
    }
}
