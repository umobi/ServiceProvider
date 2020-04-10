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

#if os(iOS) || os(tvOS)

import Foundation
import RxCocoa
import RxSwift

open class ReloadService<Controller: ReloadController>: Service<Controller> {
    open func reload(_ completionHandler: (() -> Void)? = nil) {
        self.controller.reload(completionHandler)
    }
}

open class ReloadController: ServiceController {
    public final let disposeBag = DisposeBag()
    
    open func reload(_ completionHandler: (() -> Void)? = nil) {
        completionHandler?()
    }
    
    public required init() {
        NotificationCenter.default.rx
            .notification(NotificationKeys.reloadInfo.name(self))
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] _ in
                self?.reload()
            }).disposed(by: disposeBag)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0, execute: {
            self.post(for: .reloadInfo)
        })
    }
}

extension ReloadController: ServiceNotification {
    public enum NotificationKeys: String, NotificationKey {
        case reloadInfo
    }
}

#endif
