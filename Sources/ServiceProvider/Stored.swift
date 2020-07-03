//
//  File.swift
//  
//
//  Created by brennobemoura on 03/07/20.
//

import Foundation
import KeychainAccess
import Combine

public struct Stored {
    let id: String

    init(_ id: String) {
        self.id = id
    }

    func decode<Object: Decodable>(_ object: Object.Type) -> StoredService<Object> {
        .init(controller: .init(self.id))
    }

    func data() -> StoredService<Data> {
        .init(controller: .init(self.id))
    }
}

public extension Stored {
    struct StoredService<Object> where Object: Decodable {
        let controller: Controller<Object>

        func keychain(_ keychain: Keychain? = nil, _ name: String? = nil) -> Self {
            .init(controller: self.controller.edit {
                $0.keychain = keychain
                $0.keychainName = name
            })
        }

        var object: Object? {
            self.controller.restore()
        }

        func publisher() -> AnyPublisher<Object?, Error> {
            NotificationCenter.default.publisher(for: .init("\(self.controller.id).value"))
                .tryMap {
                    let payload = $0.userInfo?["data"] as? NotificationPayload
                    let payloadData = payload?.data

                    if let object = payloadData as? Object {
                        return object
                    }

                    guard let data = payloadData else {
                        return nil
                    }

                    return try JSONDecoder().decode(Object.self, from: data)
                }
                .prepend(self.controller.restore())
                .eraseToAnyPublisher()
        }
    }
}

public extension Stored.StoredService where Object: Encodable {
    func set(_ value: Object) throws {
        try self.controller.set(value)
    }

    func erase() throws {
        try self.controller.set(nil)
    }
}

extension Stored {
    struct Controller<Object> where Object: Decodable {
        let id: String

        let keychain: Keychain?
        let keychainName: String?

        init(_ id: String) {
            self.id = id
            self.keychain = nil
            self.keychainName = nil
        }

        init(_ original: Controller<Object>, editable: Editable) {
            self.id = original.id
            self.keychainName = editable.keychainName
            self.keychain = editable.keychain
        }

        func edit(_ edit: @escaping (Editable) -> Void) -> Self {
            let editable = Editable(self)
            edit(editable)
            return .init(self, editable: editable)
        }

        class Editable {
            var keychain: Keychain?
            var keychainName: String?

            init(_ original: Controller<Object>) {
                self.keychain = original.keychain
                self.keychainName = original.keychainName
            }
        }

        private func decode(_ data: Data) -> Object? {
            if let object = data as? Object {
                return object
            }

            return try? JSONDecoder().decode(Object.self, from: data)
        }

        func restore() -> Object? {
            let key = self.keychainName ?? "\(self.id).value"

            if let keychain = self.keychain {
                guard let data = try? keychain.getData(key) else {
                    return nil
                }

                return self.decode(data)
            }

            guard let data = UserDefaults.standard.value(forKey: key) as? Data else {
                return nil
            }

            return self.decode(data)
        }
    }
}

enum NotificationPayload {
    case `nil`
    case data(Data)

    init(_ data: Data?) {
        guard let data = data else {
            self = .nil
            return
        }

        self = .data(data)
    }

    var data: Data? {
        switch self {
        case .nil:
            return nil
        case .data(let data):
            return data
        }
    }
}

extension Stored.Controller where Object: Encodable {
    func post(_ data: Data?) {
        NotificationCenter.default.post(
            name: .init("\(self.id).value"),
            object: nil,
            userInfo: [
                "data": NotificationPayload(data)
            ]
        )
    }

    func store(_ data: Data?) throws {
        let key = self.keychainName ?? "\(self.id).value"

        if let keychain = self.keychain {
            if let data = data {
                try keychain.set(data, key: key)
                self.post(data)
                return
            }

            try keychain.remove(key)
            self.post(nil)
            return
        }

        UserDefaults.standard.setValue(data, forKey: key)
        self.post(data)
    }

    func set(_ object: Object?) throws {
        guard let object = object else {
            try self.store(nil)
            return
        }

        if let data = object as? Data {
            try self.store(data)
            return
        }

        try self.store(JSONEncoder().encode(object))
    }
}
