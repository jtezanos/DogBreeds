import ObjectMapper
import RxDataSources

struct BreedImagesResponse {
    var breedURLs: [String] = []
}

extension BreedImagesResponse: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        breedURLs <- map["message"]
    }
}

struct SectionOfBreed {
  var header: String
  var items: [String]
}
extension SectionOfBreed: SectionModelType {
  typealias Item = String

   init(original: SectionOfBreed, items: [Item]) {
    self = original
    self.items = items
  }
}

extension SectionOfBreed: Equatable {
    
}
