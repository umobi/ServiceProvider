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
import RxCocoa
import RxSwift

@frozen
public struct Restore<Object>: DecodableService where Object: Decodable {
    @usableFromInline
    internal enum DefaultRaw {
        case empty
        case object(Object)
    }

    fileprivate let key: String
    fileprivate let `default`: DefaultRaw
    fileprivate let releaseIfInvalid: Bool
    fileprivate let isValid: (Object) -> Bool
    fileprivate let userDefaults: UserDefaults

    public init(_ key: String, _ isValid: @escaping (Object) -> Bool) {
        self.key = key
        self.default = .empty
        self.isValid = isValid
        self.releaseIfInvalid = false
        self.userDefaults = .standard
    }

    public init(_ key: String, default object: Object) {
        self.key = key
        self.default = .object(object)
        self.isValid = { _ in true }
        self.releaseIfInvalid = false
        self.userDefaults = .standard
    }

    public init(_ key: String) {
        self.key = key
        self.default = .empty
        self.isValid = { _ in true }
        self.releaseIfInvalid = false
        self.userDefaults = .standard
    }

    public init(_ key: String, default object: Object, _ isValid: @escaping (Object) -> Bool) {
        self.key = key
        self.default = .object(object)
        self.isValid = isValid
        self.releaseIfInvalid = false
        self.userDefaults = .standard
    }

    fileprivate init(_ original: Restore, editable: Editable) {
        self.key = original.key
        self.default = original.default
        self.isValid = original.isValid
        self.releaseIfInvalid = editable.releaseIfInvalid
        self.userDefaults = editable.userDefaults
    }
}

private extension Restore {
    class Editable {
        var releaseIfInvalid: Bool
        var userDefaults: UserDefaults

        init(_ original: Restore) {
            self.releaseIfInvalid = original.releaseIfInvalid
            self.userDefaults = original.userDefaults
        }
    }

    func edit(_ edit: (Editable) -> Void) -> Self {
        let editable = Editable(self)
        edit(editable)
        return .init(self, editable: editable)
    }
}

public extension Restore {
    func releaseOnInvalid(_ flag: Bool = true) -> Self {
        self.edit {
            $0.releaseIfInvalid = flag
        }
    }

    func userDefaults(_ userDefaults: UserDefaults) -> Self {
        self.edit {
            $0.userDefaults = userDefaults
        }
    }
}

public extension Restore {
    var observable: Observable<Object> {
        NotificationCenter.default.rx
            .notification(.init(self.key))
            .map { _ in () }
            .startWith(())
            .flatMapLatest { _ -> Observable<Object> in
                do {
                    let object = try self.get()
                    return .just(object)
                } catch let error {
                    return .error(error)
                }
            }
    }

    var tryObservable: Observable<Object?> {
        NotificationCenter.default.rx
            .notification(.init(self.key))
            .map { _ in () }
            .startWith(())
            .map { _ in self.getOrNil() }
    }
}

public extension Restore {
    func get() throws -> Object {
        guard let data = self.userDefaults.data(forKey: self.key) else {
            switch self.default {
            case .object(let object):
                return object
            default:
                throw ServiceError("No data stored")
            }
        }

        let object = try JSONDecoder().decode(Object.self, from: data)

        guard self.isValid(object) else {
            if self.releaseIfInvalid {
                self.userDefaults.setValue(nil, forKey: self.key)
            }

            throw ServiceError("Invalid Object")
        }

        return object
    }

    func getOrNil() -> Object? {
        try? self.get()
    }
}
