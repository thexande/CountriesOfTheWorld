import Apollo
import enum Result.Result

public enum World {
    public enum StoreError: Error {
        case parsing
        case network
    }
    
    public struct CountryLite: Hashable {
        public let code: String
        public let name: String
        public let emoji: String
    }
    
    public struct CountryDetail: Hashable {
        
        public struct Language: Hashable {
            public let name: String
            
            public init(name: String) {
                self.name = name
            }
        }
        
        public struct Continent: Hashable {
            public let name: String
            
            public init(name: String) {
                self.name = name
            }
        }
        
        public let code: String
        public let name: String
        public let currency: String
        public let phone: String
        public let emoji: String
        public let languages: [Language]
        public let continent: Continent
        
        public init(code: String,
                    name: String,
                    currency: String,
                    phone: String,
                    emoji: String,
                    languages: [Language],
                    continent: Continent) {
            self.code = code
            self.name = name
            self.currency = currency
            self.phone = phone
            self.emoji = emoji
            self.languages = languages
            self.continent = continent
        }
    }
}

public protocol ApolloClientInterface {
    @discardableResult func fetch<Query: GraphQLQuery>(query: Query,
                                                       cachePolicy: CachePolicy,
                                                       queue: DispatchQueue,
                                                       resultHandler: OperationResultHandler<Query>?) -> Cancellable
}

extension ApolloClient: ApolloClientInterface { }

public protocol WorldStoreInterface {
    var client: ApolloClientInterface { get }
    
    // MARK:- Service
    
    func fetchAllCountries(cachePolicy: CachePolicy,
                           completion: @escaping ((Result<[World.CountryLite], World.StoreError>) -> Void))
    
    func fetchCountry(code: String,
                      cachePolicy: CachePolicy,
                      completion: @escaping ((Result<World.CountryDetail, World.StoreError>) -> Void))
}

extension World {
    
    public final class Store: WorldStoreInterface {
        
        public let client: ApolloClientInterface
        
        public init(client: ApolloClientInterface) {
            self.client = client
        }
        
        public func fetchCountry(code: String,
                                 cachePolicy: CachePolicy = .fetchIgnoringCacheData,
                                 completion: @escaping ((Result<World.CountryDetail, World.StoreError>) -> Void)) {
            
            let query = CountryQuery(code: code)
            let queue = DispatchQueue.global(qos: .default)
            
            let resultHandler: OperationResultHandler<CountryQuery> = { (result, error) in
                
                guard error == nil else {
                    completion(.failure(.network))
                    return
                }
                
                
                guard let country = result?.data?.country.flatMap(World.CountryDetail.init) else {
                    completion(.failure(.parsing))
                    return
                }
                
                completion(.success(country))
                
            }
            
            client.fetch(query: query,
                         cachePolicy: cachePolicy,
                         queue: queue,
                         resultHandler: resultHandler)
        }
        
        public func fetchAllCountries(cachePolicy: CachePolicy = .fetchIgnoringCacheData,
                                      completion: @escaping ((Result<[CountryLite], World.StoreError>) -> Void)) {
            
            let query = CountriesQuery()
            let queue = DispatchQueue.global(qos: .default)
            
            let resultHandler: OperationResultHandler<CountriesQuery> = { (result, error) in
                
                guard error == nil else {
                    completion(.failure(.network))
                    return
                }
                
                
                guard let countries = result?.data?.countries?.compactMap(CountryLite.init) else {
                    completion(.failure(.parsing))
                    return
                }
                
                completion(.success(countries))
            }
            
            client.fetch(query: query,
                         cachePolicy: cachePolicy,
                         queue: queue,
                         resultHandler: resultHandler)
        }
    }
}

fileprivate extension World.CountryLite {
    init?(country: CountriesQuery.Data.Country?) {
        guard
            let country = country?.fragments.countryLite,
            let code = country.code,
            let name = country.name,
            let emoji = country.emoji
            else {
                return nil
        }
        
        self.init(code: code,
                  name: name,
                  emoji: emoji)
    }
}

fileprivate extension World.CountryDetail.Continent {
    init?(continent: CountryDetail.Continent?) {
        
        guard let name = continent?.name else {
            return nil
        }
        
        self.init(name: name)
    }
}

fileprivate extension World.CountryDetail.Language {
    init?(language: CountryDetail.Language?) {

        guard let name = language?.name else {
            return nil
        }
        
        self.init(name: name)
    }
}

fileprivate extension World.CountryDetail {
    init?(country: CountryQuery.Data.Country?) {
        
        guard
            let country = country?.fragments.countryDetail,
            let code = country.code,
            let name = country.name,
            let currency = country.currency,
            let phone = country.phone,
            let emoji = country.emoji,
            let continent = country.continent.flatMap(World.CountryDetail.Continent.init),
            let languages = country.languages?.compactMap(World.CountryDetail.Language.init)
            else {
                return nil
        }
        
        
        self.init(code: code,
                  name: name,
                  currency: currency,
                  phone: phone,
                  emoji: emoji,
                  languages: languages,
                  continent: continent)
        
    }
}

// MARK:- `WorldStoreInterface`


extension World {
    public final class Factory {
        
        public func makeStore(with url: URL) -> World.Store {
            return World.Store(client: ApolloClient(url: url))
        }
        
        public init() { }
    }
}

