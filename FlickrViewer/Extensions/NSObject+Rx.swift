import Foundation
import RxSwift
import ObjectiveC

private struct AssociatedKeys {
    static var disposeBag = "disposeBag"
}

/// each DisposeBagable offers a unique Rx DisposeBag instance
public protocol HasDisposeBag {
    
    /// a unique Rx DisposeBag instance
    var disposeBag: DisposeBag { get set }
}

extension HasDisposeBag {
    
    private func doLocked(forClosure closure: () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        closure()
    }
    
    public var disposeBag: DisposeBag {
        get {
            var rxDisposeBag: DisposeBag!
            doLocked {
                let lookup = objc_getAssociatedObject(self, &AssociatedKeys.disposeBag) as? DisposeBag
                if let lookup = lookup {
                    rxDisposeBag = lookup
                } else {
                    let newDisposeBag = DisposeBag()
                    objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, newDisposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    rxDisposeBag = newDisposeBag
                }
            }
            return rxDisposeBag
        }
        
        set {
            doLocked {
                objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

extension NSObject: HasDisposeBag {}

public extension Reactive where Base: HasDisposeBag {
    /// a unique DisposeBag that is related to the Reactive.Base instance
    var disposeBag: DisposeBag {
        get { return base.disposeBag }
        set {
            var mutableBase = base
            mutableBase.disposeBag = newValue
        }
    }
}
