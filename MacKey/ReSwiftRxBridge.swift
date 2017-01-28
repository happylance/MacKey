//
//  ReSwiftRxBridge.swift
//  ReSwiftRx-RxSwiftExample
//
//  Created by Charlotte Tortorella on 1/12/16.
//  Copyright © 2016 ReSwift. All rights reserved.
//

import ReactiveReSwift
import RxSwift

extension Variable: ObservablePropertyType {
    public typealias ValueType = Element
    public typealias DisposeType = DisposableWrapper
    
    public func subscribe(_ function: @escaping (Element) -> Void) -> DisposableWrapper? {
        return DisposableWrapper(disposable: asObservable().subscribe(onNext: function))
    }
}

extension Observable: StreamType {
    public typealias ValueType = Element
    public typealias DisposeType = DisposableWrapper
    
    public func subscribe(_ function: @escaping (Element) -> Void) -> DisposableWrapper? {
        return DisposableWrapper(disposable: subscribe(onNext: function))
    }
}

public struct DisposableWrapper: SubscriptionReferenceType {
    let disposable: Disposable
    
    public func dispose() {
        disposable.dispose()
    }
}
