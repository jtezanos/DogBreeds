import Foundation
import RxSwift
import Result
import ObjectMapper

// MARK: - subscribe
extension ObservableType {
    func subscribeNext(_ closure: @escaping (E) -> Void) -> Disposable {
        return self.subscribe(onNext: { closure($0) }, onCompleted: nil, onDisposed: nil)
    }
}

// MARK: - doOn
extension ObservableType {
    func doOnNext(_ closure: @escaping (E) -> Void) -> Observable<E> {
        return self.do(onNext: { closure($0) }, onError: nil, onCompleted: nil, onSubscribe: nil, onDispose: nil)
    }
    
    func doOnError(_ closure: @escaping (Swift.Error) -> Void) -> Observable<E> {
        return self.do(onNext: nil, onError: { closure($0) }, onCompleted: nil, onSubscribe: nil, onDispose: nil)
    }
}

// MARK: - Result + doOn
public extension ObservableType where E: ResultProtocol {
    func `do`(onSuccess: (@escaping (Self.E.Value) throws -> Void)) -> Observable<E> {
        return `do`(onNext: { (value) in
            guard let successValue = value.value else {
                return
            }
            
            try onSuccess(successValue)
        })
    }
    
    func `do`(onFailure: (@escaping (Self.E.Error) throws -> Void)) -> Observable<E> {
        return `do`(onNext: { (value) in
            guard let failureValue = value.error else {
                return
            }
            
            try onFailure(failureValue)
        })
    }
    
    func subscribeResult(onSuccess: ((Self.E.Value) -> Void)? = nil,
                         onFailure: ((Self.E.Error) -> Void)? = nil) -> Disposable {
        return subscribeNext { value in
            if let successValue = value.value {
                onSuccess?(successValue)
            } else if let errorValue = value.error {
                onFailure?(errorValue)
            }
        }
    }
    
    func mapResult<T: Mappable>(to type: T.Type) -> Observable<NetworkerResult<T>> {
        return map { result in
            guard let object = Mapper<T>(context: nil).map(JSONObject: result.value) else {
                let error = result.error as? NetworkerError ?? NetworkerError.parsingError
                return NetworkerResult.failure(error)
            }
            
            return NetworkerResult.success(object)
            }.observeOn(Minion.shared.mainScheduler)
    }
    
    func mapResult<T: Mappable>(toArray type: T.Type) -> Observable<NetworkerResult<[T]>> {
        return map { result in
            guard let objects = Mapper<T>(context: nil).mapArray(JSONObject: result.value) else {
                let error = result.error as? NetworkerError ?? NetworkerError.parsingError
                return NetworkerResult.failure(error)
            }
            
            return NetworkerResult.success(objects)
        }
    }
    
    func mapMessage() -> Observable<NetworkerResult<String>> {
        return map { result in
            guard let result = result as? NetworkerResult<Any> else {
                return NetworkerResult.failure(NetworkerError.parsingError)
            }
            
            return result.map { obj in
                if let message = obj as? String {
                    return message
                } else {
                    return ""
                }
            }
        }
    }
}
