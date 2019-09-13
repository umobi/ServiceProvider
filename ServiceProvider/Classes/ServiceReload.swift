//
//  ServiceReload.swift
//  mercadoon
//
//  Created by brennobemoura on 21/08/19.
//  Copyright © 2019 brennobemoura. All rights reserved.
//

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
