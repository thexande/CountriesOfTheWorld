import XCTest
@testable import ApolloUnitTestingDemo
@testable import Apollo

final class ApolloUnitTestingDemoTests: XCTestCase {

    func test_CountriesQuery() {
        
        guard let results = MockGraphQLQuery.countries.responseObject else {
            XCTFail()
            return
        }
        
        let query = CountriesQuery()
        
        withCache(initialRecords: [:]) { cache in
            
            let store = ApolloStore(cache: cache)
            let client = ApolloClient(networkTransport: MockNetworkTransport(body: results),
                                      store: store)
            
            let worldStore = WorldStore(client: client)
            
            let expectation = self.expectation(description: "Fetching query")
            
            worldStore.fetchAllCountries { result in
                defer {
                    expectation.fulfill()
                }
                
                switch result {
                case .failure:
                    XCTFail()
                    return
                case let .success(data):
                    
                    guard let first = data.first else {
                        XCTFail()
                        return
                    }
                    
                    let object = World.CountryLite(code: "USA", name: "America", emoji: "🇺🇸")
                    XCTAssertEqual(object, first)
                }
            }
            
            self.waitForExpectations(timeout: 5, handler: nil)
        }
    }

    func test_CountryQuery() {
        
        guard let results = MockGraphQLQuery.country.responseObject else {
            XCTFail()
            return
        }
        
        let query = CountryQuery()
        
        withCache(initialRecords: [:]) { cache in
            
            let store = ApolloStore(cache: cache)
            let client = ApolloClient(networkTransport: MockNetworkTransport(body: results),
                                      store: store)
            
            let worldStore = WorldStore(client: client)
            
            let expectation = self.expectation(description: "Fetching query")
            
            worldStore.fetchCountry(code: "AE") { result in
                defer {
                    expectation.fulfill()
                }
                
                switch result {
                case .failure:
                    XCTFail()
                    return
                case let .success(data):
                    XCTAssert(true)
                }
            }
            
            self.waitForExpectations(timeout: 5, handler: nil)
        }
    }

}
