import XCTest
@testable import WorldAPI
@testable import Apollo

final class WorldAPITests: XCTestCase {
    
    func test_Factory() {
        
        guard let url = URL(string: "http://www.google.com") else {
            XCTFail()
            return
        }
        
        _ = World.Factory().makeStore(with: url)
        
        XCTAssert(true, "pass")
    }

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
            
            let worldStore = World.Store(client: client)
            
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
    
    func test_CountriesQueryNetworkFailure() {
        
        guard let results = MockGraphQLQuery.countries.responseObject else {
            XCTFail()
            return
        }
        
        let query = CountriesQuery()
        
        withCache(initialRecords: [:]) { cache in
            
            let store = ApolloStore(cache: cache)
            let client = ApolloClient(networkTransport: MockNetworkTransport(body: results,
                                                                             simulateNetworkFailure: true),
                                      store: store)
            
            let worldStore = World.Store(client: client)
            
            let expectation = self.expectation(description: "Fetching query")
            
            worldStore.fetchAllCountries { result in
                defer {
                    expectation.fulfill()
                }
                
                switch result {
                case let .failure(error):
                    XCTAssertEqual(error, World.StoreError.network)
                    return
                case .success:
                   XCTFail()
                }
            }
            
            self.waitForExpectations(timeout: 5, handler: nil)
        }
    }
    
    func test_CountryQueryNetworkFailure() {
        
        guard let results = MockGraphQLQuery.countries.responseObject else {
            XCTFail()
            return
        }
        
        let query = CountriesQuery()
        
        withCache(initialRecords: [:]) { cache in
            
            let store = ApolloStore(cache: cache)
            let client = ApolloClient(networkTransport: MockNetworkTransport(body: results,
                                                                             simulateNetworkFailure: true),
                                      store: store)
            
            let worldStore = World.Store(client: client)
            
            let expectation = self.expectation(description: "Fetching query")
            
            worldStore.fetchCountry(code: "USA") { result in
                defer {
                    expectation.fulfill()
                }
                
                switch result {
                case let .failure(error):
                    XCTAssertEqual(error, World.StoreError.network)
                    return
                case .success:
                    XCTFail()
                }
            }
            
            self.waitForExpectations(timeout: 5, handler: nil)
        }
    }
    
    func test_CountriesQueryParsingFailure() {
        
        let results: JSONObject = ["👍": 0xDEADBEEF]
        
        let query = CountriesQuery()
        
        withCache(initialRecords: [:]) { cache in
            
            let store = ApolloStore(cache: cache)
            let client = ApolloClient(networkTransport: MockNetworkTransport(body: results,
                                                                             simulateNetworkFailure: false),
                                      store: store)
            
            let worldStore = World.Store(client: client)
            
            let expectation = self.expectation(description: "Fetching query")
            
            worldStore.fetchAllCountries { result in
                defer {
                    expectation.fulfill()
                }
                
                switch result {
                case let .failure(error):
                    XCTAssertEqual(error, World.StoreError.parsing)
                    return
                case .success:
                    XCTFail()
                }
            }
            
            self.waitForExpectations(timeout: 5, handler: nil)
        }
    }
    
    
    func test_CountryQueryParsingFailure() {
        
        let results: JSONObject = ["👍": 0xDEADBEEF]
        
        let query = CountriesQuery()
        
        withCache(initialRecords: [:]) { cache in
            
            let store = ApolloStore(cache: cache)
            let client = ApolloClient(networkTransport: MockNetworkTransport(body: results,
                                                                             simulateNetworkFailure: false),
                                      store: store)
            
            let worldStore = World.Store(client: client)
            
            let expectation = self.expectation(description: "Fetching query")
            
            worldStore.fetchCountry(code: "USA") { result in
                defer {
                    expectation.fulfill()
                }
                
                switch result {
                case let .failure(error):
                    XCTAssertEqual(error, World.StoreError.parsing)
                    return
                case .success:
                    XCTFail()
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
            
            let worldStore = World.Store(client: client)
            
            let expectation = self.expectation(description: "Fetching query")
            
            worldStore.fetchCountry(code: "AE") { result in
                defer {
                    expectation.fulfill()
                }
                
                switch result {
                case .failure:
                    XCTFail()
                    return
                case let .success(worldCountry):
                    let country = World.CountryDetail(code: "AE",
                                                      name: "United Arab Emirates",
                                                      currency: "AED",
                                                      phone: "971",
                                                      emoji: "🇦🇪",
                                                      languages: [World.CountryDetail.Language(name: "Arabic")],
                                                      continent: World.CountryDetail.Continent(name: "Asia"))
                    XCTAssertEqual(country, worldCountry)
                }
            }
            
            self.waitForExpectations(timeout: 5, handler: nil)
        }
    }

}
