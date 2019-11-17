import UIKit
import RxSwift
import Result

struct SearchViewModel {
    let networker: Networker
    let breedsData = BehaviorSubject<[SectionOfBreed]>(value: [])
    
    init(networker: Networker = Networker()) {
        self.networker = networker
    }
    
    func breeds(with search: String) -> Observable<[String]> {
        if search.isEmpty { return Observable.just([]) }
        return networker.breeds()
            .map { $0.breeds }
            .map { breeds in
                // TODO: This filtering logic should be a seprate method that is easier to test
                var filteredBreeds: [String] = []
                for breed in breeds {
                    if breed.contains(search.lowercased()) {
                        filteredBreeds.append(breed)
                    }
                }
                return filteredBreeds
            }
    }
    
    func breedImages(with breed: String) -> Observable<[String]> {
        networker.breedImages(with: breed.lowercased())
            .map { $0.breedURLs }
    }
    
    func updateBreedImages(breed: String) {
        let _ = breedImages(with: breed)
            .flatMapLatest(buildSections)
            .subscribe(onNext: { sections in
                self.breedsData.on(.next(sections))
            })
    }
    
    func buildSections(with urls: [String]) -> Observable<[SectionOfBreed]> {
        var sectionsDictionary: [String: [String]] = [:]
        
        for url in urls {
            if let breed = urlToBreed(url: url) {
                if var images = sectionsDictionary[breed] {
                    images.append(url)
                    sectionsDictionary[breed] = images
                } else {
                    sectionsDictionary[breed] = [url]
                }
            }
        }
        
        var sections: [SectionOfBreed] = []
        for item in sectionsDictionary {
            sections.append(SectionOfBreed(header: item.key, items: item.value))
        }
        return Observable.just(sections)
    }
    
    private func urlToBreed(url: String) -> String? {
        let removedFirstPart = url.replacingOccurrences(of: "https://images.dog.ceo/breeds/", with: "")
        let arrayOfComponents = removedFirstPart.components(separatedBy: "/")
        return arrayOfComponents.first
    }
}
