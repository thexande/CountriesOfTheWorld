//import Apollo
//import enum Result.Result
//
//enum World {
//    enum StoreError: Error {
//        case parsing
//        case network
//    }
//    
//    struct CountryLite: Hashable {
//        let code: String
//        let name: String
//        let emoji: String
//    }
//    
//    struct CountryDetail: Hashable {
//        struct Language: Hashable {
//            let name: String
//        }
//        
//        struct Continent: Hashable {
//            let name: String
//        }
//        let code: String
//        let name: String
//        let currency: String
//        let phone: String
//        let emoji: String
//        let languages: [Language]
//        let continent: Continent
//    }
//}
//
//protocol ApolloClientInterface {
//    @discardableResult func fetch<Query: GraphQLQuery>(query: Query,
//                                                       cachePolicy: CachePolicy,
//                                                       queue: DispatchQueue,
//                                                       resultHandler: OperationResultHandler<Query>?) -> Cancellable
//}
//
//extension ApolloClient: ApolloClientInterface { }
//
//protocol WorldStoreInterface {
//    var client: ApolloClientInterface { get }
//    
//    // MARK:- Service
//    
//    func fetchAllCountries(cachePolicy: CachePolicy,
//                           completion: @escaping ((Result<[World.CountryLite], World.StoreError>) -> Void))
//    
//    func fetchCountry(code: String,
//                      cachePolicy: CachePolicy,
//                      completion: @escaping ((Result<World.CountryDetail, World.StoreError>) -> Void))
//    
//    // MARK:- Mapping
//    
//    static func makeCountry(from country: CountriesQuery.Data.Country?) -> World.CountryLite?
//    static func makeLanguages(from language: CountryDetail.Language?) -> World.CountryDetail.Language?
//    static func makeContinent(from continent: CountryDetail.Continent?) -> World.CountryDetail.Continent?
//    static func makeCountry(from country: CountryQuery.Data.Country?) -> World.CountryDetail?
//}
//
//extension WorldStoreInterface {
//    func fetchCountry(code: String,
//                      cachePolicy: CachePolicy = .fetchIgnoringCacheData,
//                      completion: @escaping ((Result<World.CountryDetail, World.StoreError>) -> Void)) {
//       
//        let query = CountryQuery(code: code)
//        let queue = DispatchQueue.global(qos: .default)
//        
//        let resultHandler: OperationResultHandler<CountryQuery> = { (result, error) in
//            
//            guard error == nil else {
//                completion(.failure(.network))
//                return
//            }
//            
//            
//            guard let country = Self.makeCountry(from: result?.data?.country) else {
//                completion(.failure(.parsing))
//                return
//            }
//            
//            completion(.success(country))
//            
//        }
//        
//        client.fetch(query: query,
//                     cachePolicy: cachePolicy,
//                     queue: queue,
//                     resultHandler: resultHandler)
//    }
//    
//    func fetchAllCountries(cachePolicy: CachePolicy = .fetchIgnoringCacheData,
//                           completion: @escaping ((Result<[World.CountryLite], World.StoreError>) -> Void)) {
//       
//        let query = CountriesQuery()
//        let queue = DispatchQueue.global(qos: .default)
//        
//        let resultHandler: OperationResultHandler<CountriesQuery> = { (result, error) in
//
//            guard error == nil else {
//                completion(.failure(.network))
//                return
//            }
//            
//            
//            guard let countries = result?.data?.countries?.compactMap(Self.makeCountry(from:)) else {
//                completion(.failure(.parsing))
//                return
//            }
//
//            completion(.success(countries))
//        }
//        
//        client.fetch(query: query,
//                     cachePolicy: cachePolicy,
//                     queue: queue,
//                     resultHandler: resultHandler)
//    }
//    
//    static func makeCountry(from country: CountriesQuery.Data.Country?) -> World.CountryLite? {
//        
//        guard
//            let country = country?.fragments.countryLite,
//            let code = country.code,
//            let name = country.name,
//            let emoji = country.emoji
//                else {
//                    return nil
//        }
//        
//        return World.CountryLite(code: code,
//                                   name: name,
//                                   emoji: emoji)
//    }
//        
//    static func makeCountry(from country: CountryQuery.Data.Country?) -> World.CountryDetail? {
//        
//        guard
//            let country = country?.fragments.countryDetail,
//            let code = country.code,
//            let name = country.name,
//            let currency = country.currency,
//            let phone = country.phone,
//            let emoji = country.emoji,
//            let continent = Self.makeContinent(from: country.continent),
//            let languages = country.languages?.compactMap(Self.makeLanguages(from:))
//                else {
//                    return nil
//        }
//        
//        return World.CountryDetail(code: code,
//                                   name: name,
//                                   currency: currency,
//                                   phone: phone,
//                                   emoji: emoji,
//                                   languages: languages,
//                                   continent: continent)
//    }
//    
//    static func makeContinent(from continent: CountryDetail.Continent?) -> World.CountryDetail.Continent? {
//        guard let name = continent?.name else {
//            return nil
//        }
//
//        return World.CountryDetail.Continent(name: name)
//    }
//
//    static func makeLanguages(from language: CountryDetail.Language?) -> World.CountryDetail.Language? {
//        guard let name = language?.name else {
//            return nil
//        }
//
//        return World.CountryDetail.Language(name: name)
//    }
//}
//
//final class World.Store: WorldStoreInterface {
//    let client: ApolloClientInterface
//    
//    init(client: ApolloClientInterface) {
//        self.client = client
//    }
//}
//
