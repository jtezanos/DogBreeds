import Moya

public enum API {
    case breeds
    case breedImages(breed: String)
}

extension API: TargetType {
    public var baseURL: URL {
        guard let url = URL(string: "https://dog.ceo/api") else {
            return URL(fileReferenceLiteralResourceName: "none")
        }
        return url
    }
    
    public var task: Task {
        return .requestParameters(parameters: parameters ?? [:], encoding: URLEncoding.default)
    }
    
    public var path: String {
        switch self {
        case .breeds:
            return "/breeds/list/all"
        case .breedImages(let breed):
            return "/breed/\(breed)/images"
        }
    }
    
    public var method: Method {
        switch self {
        default:
            return .get
        }
    }
    
    public var parameters: [String: Any]? {
        // Our API is all GETs currently, we can address this being nil once that changes
        let params: [String: Any]? = nil
        
        switch self {
        default:
            break
        }
        
        return params
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    public var parameterEncoding: ParameterEncoding {
        switch self {
        default:
            return URLEncoding.default
        }
    }
    
}
