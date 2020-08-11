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
public struct TryRequest<Object, Failure>: TryRequestService where Failure: Error {
    public typealias SuccessBatch = (Object) -> Void
    public typealias ErrorBatch = (Failure) -> Void

    fileprivate let batch: (@escaping SuccessBatch, @escaping ErrorBatch) -> Void

    public init(_ batch: @escaping (@escaping SuccessBatch, @escaping ErrorBatch) -> Void) {
        self.batch = batch
    }

    public func request(onSuccess: @escaping (Object) -> Void, onError: @escaping (Failure) -> Void) {
        self.batch(onSuccess, onError)
    }
}

#if canImport(Combine)
import Combine

@available(iOS 13, tvOS 13, macOS 10.15, watchOS 6, *)
public extension TryRequest {
    var publisher: AnyPublisher<Object, Failure> {
        let currentValue = CurrentValueSubject<Object?, Failure>(nil)

        self.request(onSuccess: {
            currentValue.value = $0
        }, onError: {
            currentValue.send(completion: .failure($0))
        })

        return currentValue.flatMap { value -> AnyPublisher<Object, Failure> in
            if let value = value {
                return Just(value)
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()
            }

            return Empty()
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
#endif
