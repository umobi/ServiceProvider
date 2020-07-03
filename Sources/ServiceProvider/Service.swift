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

public protocol ServiceController: class {
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
