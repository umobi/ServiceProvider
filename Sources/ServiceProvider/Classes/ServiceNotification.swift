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

public protocol NotificationKey: RawRepresentable where RawValue == String {}

public protocol ServiceNotification: class {
    associatedtype NotificationKeys: NotificationKey
}

public extension NotificationKey {
    func name<Service: ServiceNotification>(_ serviceNotification: Service) -> Notification.Name {
        return Notification.Name("\(ObjectIdentifier(serviceNotification))" + "." + self.rawValue)
    }
}

public extension ServiceNotification {
    func post(object: Any? = nil, for key: NotificationKeys) {
        NotificationCenter.default.post(name: key.name(self), object: nil)
    }
}

public extension Service where Controller: ServiceNotification {
    func notification(_ key: Controller.NotificationKeys) -> Notification.Name? {
        return key.name(self.controller)
    }
}
