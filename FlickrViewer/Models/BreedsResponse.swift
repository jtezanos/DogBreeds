import ObjectMapper

struct BreedsResponse {
    private var breedsRAW: [String: [String]] = [:]
    
    init(breedsRAW: [String: [String]]) {
        self.breedsRAW = breedsRAW
    }
    
    var breeds: [String] {
        var values: [String] = []
        for item in breedsRAW {
            values.append(item.key)
        }
        return values.sorted { $0 < $1 }
    }
}

extension BreedsResponse: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        breedsRAW <- map["message"]
    }
}
