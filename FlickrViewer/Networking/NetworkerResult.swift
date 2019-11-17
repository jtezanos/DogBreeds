import Foundation
import Result
import RxSwift
import Moya

public typealias NetworkerResult<T> = Result<T, NetworkerError>

protocol NetworkerType {
    
    associatedtype API: TargetType
    
    var provider: MoyaProvider<API> { get }
    func request(main type: API) -> Observable<NetworkerResult<Any>>
}

public enum NetworkerError: Error {
    case invalidData
    case parsingError
    case api(meta: String, message: String?)
}

extension NetworkerError: CustomDebugStringConvertible {
    public var debugDescription: String {
        return self.localizedDescription
    }
}

