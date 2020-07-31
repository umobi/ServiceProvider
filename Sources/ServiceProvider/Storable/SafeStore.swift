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

@frozen
public struct SafeStore<Object>: EncodableService where Object: Codable {
    fileprivate let key: String
    fileprivate let isValid: (Object) -> Bool
    fileprivate let isSharedResource: Bool
    fileprivate let keychain: Keychain

    public init(_ key: String, _ isValid: @escaping (Object) -> Bool) {
        self.key = key
        self.isValid = isValid
        self.isSharedResource = false
        self.keychain = .shared
    }

    public init(_ key: String) {
        self.key = key
        self.isValid = { _ in true }
        self.isSharedResource = false
        self.keychain = .shared
    }

    private init(_ original: SafeStore, editable: Editable) {
        self.key = original.key
        self.isValid = original.isValid
        self.isSharedResource = editable.isSharedResource
        self.keychain = editable.keychain
    }
}

private extension SafeStore {
    class Editable {
        var isSharedResource: Bool
        var keychain: Keychain

        init(_ original: SafeStore) {
            self.isSharedResource = original.isSharedResource
            self.keychain = original.keychain
        }
    }

    func edit(_ edit: (Editable) -> Void) -> Self {
        let editable = Editable(self)
        edit(editable)
        return .init(self, editable: editable)
    }
}

private extension SafeStore {
    var privateKey: String {
        "\(Self.self).\(self.key)"
    }
}

private extension SafeStore {
    func postIfAvailable() {
        guard self.isSharedResource else {
            return
        }

        NotificationCenter.default.post(
            .init(
                name: Notification.Name(rawValue: self.privateKey),
                object: nil,
                userInfo: [:]
            )
        )
    }
}

public extension SafeStore {
    func shareResource(_ flag: Bool = true) -> Self {
        self.edit {
            $0.isSharedResource = flag
        }
    }

    func keychain(_ keychain: Keychain) -> Self {
        self.edit {
            $0.keychain = keychain
        }
    }
}

public extension SafeStore {
    func set(_ object: Object) throws {
        guard self.isValid(object) else {
            throw ServiceError("Invalid Object")
        }

        try self.keychain.set(
            try JSONEncoder().encode(object),
            key: self.privateKey
        )


        self.postIfAvailable()
    }
    
    func trySet(_ object: Object) {
        try? self.set(object)
    }

    func release() {
        try? self.keychain.remove(self.privateKey)
        self.postIfAvailable()
    }
}
