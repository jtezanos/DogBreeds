//
//  FlickrViewerTests.swift
//  FlickrViewerTests
//
//  Created by Jason Tezanos on 10/27/18.
//  Copyright © 2018 Jason Tezanos. All rights reserved.
//

import XCTest
import RxSwift
@testable import FlickrViewer

class FlickrViewerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSeachViewModelBuildSections() {
        let viewModel = SearchViewModel()
        
        let imageURLs = [
        "https://images.dog.ceo/breeds/dane-small/n02109047_9503.jpg",
        "https://images.dog.ceo/breeds/dane-great/n02109047_9604.jpg",
        "https://images.dog.ceo/breeds/dane-big/photo_2018-12-24_10-55-43 (2).jpg"
        ]
        
        let section1 = SectionOfBreed(header: "dane-small", items: ["https://images.dog.ceo/breeds/dane-small/n02109047_9503.jpg"])
        let section2 = SectionOfBreed(header: "dane-great", items: ["https://images.dog.ceo/breeds/dane-great/n02109047_9604.jpg"])
        let section3 = SectionOfBreed(header: "dane-big", items: ["https://images.dog.ceo/breeds/dane-big/photo_2018-12-24_10-55-43 (2).jpg"])
                
        viewModel.buildSections(with: imageURLs)
            .subscribe(onNext: { sections in
                /// We need to see if the array contains the items since we ultimately pull from a Dictionary, order is not guaranteed
                XCTAssertTrue(sections.contains(section1))
                XCTAssertTrue(sections.contains(section2))
                XCTAssertTrue(sections.contains(section3))
            })
            .disposed(by: disposeBag)
    }
    
    func testBreedsMapping() {
        let breedDictionary = [
        "affenpinscher": [],
        "african": [],
        "airedale": [],
        "akita": [],
        "appenzeller": [],
        "basenji": [],
        "beagle": [],
        "bluetick": [],
        "borzoi": [],
        "bouvier": [],
        "boxer": [],
        "brabancon": [],
        "briard": [],
        "buhund": [
            "norwegian"
        ],
        "bulldog": [
            "boston",
            "english",
            "french"
        ]]
        let breedsResponse = BreedsResponse(breedsRAW: breedDictionary)
        
        XCTAssertEqual(breedsResponse.breeds.first, "affenpinscher")
        XCTAssertEqual(breedsResponse.breeds.last, "bulldog")
    }
    
}
