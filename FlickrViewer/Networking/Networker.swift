import Foundation
import ObjectMapper
import Moya
import Moya_ObjectMapper
import RxSwift
import SwiftyUserDefaults
import Result
import UIKit

class Networker {
        
    let provider: MoyaProvider<API>
    let minion: Minion
    
    init(minion: Minion = Minion.shared) {
        self.minion = minion
        self.provider = MoyaProvider<API>(plugins: [NetworkerLoggerPlugin()])
    }
    
    fileprivate func displayError(result: NetworkerResult<Any>) {
        guard let error = result.error else {
            return
        }
        
        if case .api(let meta, let message) = error {
            print("💥 \(meta): \(String(describing: message))")
        }
        
        return
    }
    
    func request(api type: API) -> Observable<NetworkerResult<Any>> {
        return provider.rx.request(type)
            .observeOn(minion.backgroundWorkScheduler)
            .asObservable()
            .map { response in
                guard let json = JSON(data: response.data) else {
                    return .failure(.invalidData)
                }
                
                guard let jsonDict = json.dictionary else {
                    return NetworkerResult.failure(.parsingError)
                }
                
                if let result = jsonDict["data"]?.object {
                    return NetworkerResult.success(result)
                }
                
                if let errors = jsonDict["errors"]?.array, let meta = jsonDict["meta"]?.string {
                    return NetworkerResult.failure(.api(meta: meta, message: errors.first?.string))
                }
                
                return NetworkerResult.failure(.parsingError)
            }
            .doOnNext(displayError)
    }
}

extension Networker {
    
    func breedImages(with breed: String) -> Observable<BreedImagesResponse> {
        return provider.rx.request(.breedImages(breed: breed))
            .asObservable()
            .mapObject(BreedImagesResponse.self)
    }
    
    func breeds() -> Observable<BreedsResponse> {
        return provider.rx.request(.breeds)
            .asObservable()
            .mapObject(BreedsResponse.self)
    }
}

/// Logs network activity (outgoing requests and incoming responses).
public final class NetworkerLoggerPlugin: PluginType {
    public init() { }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if case .success(let response) = result {
            print("🔗 URL: \(response.response?.url?.absoluteString ?? "")")
            print("🚀 Response: \(response)")
            do {
                let dataAsJSON = try JSONSerialization.jsonObject(with: response.data)
                print("🌟 Response Data: \(dataAsJSON) \n\n")
            } catch {
                print("Unable to parse response data")
            }
            
        } else {
            print("💣 Did not receive a response")
        }
    }
}
