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

public protocol KeychainKey: RawRepresentable {
    var rawValue: String { get }
}

public protocol ServiceKeychain {
    associatedtype KeychainKeys: KeychainKey
    
    var keychain: Keychain { get }
}

public extension ServiceKeychain {
    func set(_ value: String, for key: KeychainKeys) throws {
        try self.keychain.set(value, key: key.rawValue)
    }
    
    func set(_ value: Data, for key: KeychainKeys) throws {
        try self.keychain.set(value, key: key.rawValue)
    }
    
    func get(for key: KeychainKeys) throws -> String? {
        return try self.keychain.getString(key.rawValue)
    }
    
    func get(for key: KeychainKeys) throws -> Data? {
        return try self.keychain.getData(key.rawValue)
    }
    
    func remove(for key: KeychainKeys) throws {
        try self.keychain.remove(key.rawValue)
    }
}



public extension Keychain {
    static var main: Keychain {
        return .init(service: Bundle.main.bundleIdentifier!)
    }
}

public extension ServiceKeychain {
    var keychain: Keychain {
        return .main
    }
}
