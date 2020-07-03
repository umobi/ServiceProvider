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
import Combine

public protocol NotificationObservableKey: NotificationKey {
    static var valueDidChange: Self? { get }
}

public protocol ServiceStoredObservableProtocol: ServiceNotification where NotificationKeys: NotificationObservableKey {
    associatedtype Value
    var value: Value { get }
}

public extension NotificationObservableKey {
    static var valueDidChange: Self? {
        guard let didChange = Self(rawValue: kValueDidChange) else {
            print("Error: ServiceProvider.NotificationKeys for \(String(describing: Self.self)) did not have kValueDidChange")
            return nil
        }
        
        return didChange
    }
}

public extension ServiceStoredObservableProtocol {
    func notification<Key>(_ key: Key) -> AnyPublisher<Value, Never> where Key == NotificationKeys {
        NotificationCenter.default
            .publisher(for: key.name(self))
            .map { _ in return self.value }
            .eraseToAnyPublisher()
    }
    
    var value: AnyPublisher<Value, Never> {
        guard let valueDidChange = NotificationKeys.valueDidChange else {
            #if DEBUG
            print("Error: Calling ServiceStoredRxProtocol<\(String(describing: Self.self))>.valueObservable will not perfom any action.\nOverride NotificationKeys.valueDidChange method or set one case with default rawValue \(kValueDidChange)")
            #endif
            return Empty<Value, Never>()
                .eraseToAnyPublisher()
        }

        return self.notification(valueDidChange)
            .prepend(self.value)
            .eraseToAnyPublisher()
    }
}

public let kValueDidChange = "valueDidChange"

public typealias ObservableServiceStoredController<Value> = ServiceStoredController<Value> & ServiceStoredObservableProtocol

public protocol ObservableServiceType: ServiceType where Controller: ServiceStoredObservableProtocol {}

open class ObservableService<Controller: ServiceController & ServiceStoredObservableProtocol>: Service<Controller>, ObservableServiceType {}

public extension ObservableServiceType {
    func notification<Key>(_ key: Key) -> AnyPublisher<Controller.Value, Never> where Key == Controller.NotificationKeys {
        NotificationCenter.default
            .publisher(for: key.name(self.controller))
            .map { _ in return self.controller.value }
            .eraseToAnyPublisher()
    }
    
    var value: AnyPublisher<Controller.Value, Never> {
        guard let valueDidChange = Controller.NotificationKeys.valueDidChange else {
            #if DEBUG
            print("Error: Calling ServiceStoredRxProtocol<\(String(describing: Self.self))>.valueObservable will not perfom any action.\nOverride NotificationKeys.valueDidChange method or set one case with default rawValue \(kValueDidChange)")
            #endif
            return Empty<Controller.Value, Never>()
                .eraseToAnyPublisher()
        }
        
        return self.notification(valueDidChange)
            .prepend(self.controller.value)
            .eraseToAnyPublisher()
    }
}
