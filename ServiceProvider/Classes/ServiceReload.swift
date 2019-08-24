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

open class ServiceReload<T: ProviderType>: Service<T> {
    public final let disposeBag = DisposeBag()
    
    open func reload(_ completionHandler: (() -> Void)? = nil) {
        completionHandler?()
    }
    
    override open func start() {
        super.start()
        
        NotificationCenter.default.rx
            .notification(NotificationKeys.reloadInfo.name)
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] _ in
                self?.reload()
            }).disposed(by: disposeBag)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0, execute: {
            self.post(for: .reloadInfo)
        })
    }
}

extension ServiceReload: ServiceNotification {
    public enum NotificationKeys: String, NotificationKey {
        case reloadInfo
    }
}
