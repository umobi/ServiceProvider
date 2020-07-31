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

@frozen
public struct Store<Object>: EncodableService where Object: Codable {
    fileprivate let key: String
    fileprivate let isValid: (Object) -> Bool
    fileprivate let isSharedResource: Bool
    fileprivate let userDefaults: UserDefaults

    public init(_ key: String, _ isValid: @escaping (Object) -> Bool) {
        self.key = key
        self.isValid = isValid
        self.isSharedResource = false
        self.userDefaults = .standard
    }

    public init(_ key: String) {
        self.key = key
        self.isValid = { _ in true }
        self.isSharedResource = false
        self.userDefaults = .standard
    }

    private init(_ original: Store, editable: Editable) {
        self.key = original.key
        self.isValid = original.isValid
        self.isSharedResource = editable.isSharedResource
        self.userDefaults = editable.userDefaults
    }
}

private extension Store {
    class Editable {
        var isSharedResource: Bool
        var userDefaults: UserDefaults

        init(_ original: Store) {
            self.isSharedResource = original.isSharedResource
            self.userDefaults = original.userDefaults
        }
    }

    func edit(_ edit: (Editable) -> Void) -> Self {
        let editable = Editable(self)
        edit(editable)
        return .init(self, editable: editable)
    }
}

private extension Store {
    var privateKey: String {
        "\(Self.self).\(self.key)"
    }
}

private extension Store {
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

public extension Store {
    func set(_ object: Object) throws {
        guard self.isValid(object) else {
            throw ServiceError("Invalid Object")
        }

        let data = try JSONEncoder().encode(object)

        self.userDefaults.setValue(
            data,
            forKey: self.privateKey
        )

        self.postIfAvailable()
    }

    func release() {
        self.userDefaults.setValue(
            nil,
            forKey: self.privateKey
        )

        self.postIfAvailable()
    }
}

public extension Store {
    func shareResource(_ flag: Bool = true) -> Self {
        self.edit {
            $0.isSharedResource = flag
        }
    }

    func trySet(_ object: Object) {
        try? self.set(object)
    }

    func userDefaults(_ userDefaults: UserDefaults) -> Self {
        self.edit {
            $0.userDefaults = userDefaults
        }
    }
}
