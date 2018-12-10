import Apollo
import enum Result.Result

enum World {
    enum StoreError: Error {
        case parsing
        case network
    }
    
    struct Country {
        struct Language {
            let name: String
        }
        
        struct Continent {
            let name: String
        }
        
        let name: String
        let currency: String
        let phone: String
        let emoji: String
        let languages: [Language]
        let continent: Continent
    }
}

protocol ApolloClientInterface {
    @discardableResult func fetch<Query: GraphQLQuery>(query: Query,
                                                       cachePolicy: CachePolicy,
                                                       queue: DispatchQueue,
                                                       resultHandler: OperationResultHandler<Query>?) -> Cancellable
}

extension ApolloClient: ApolloClientInterface { }

protocol WorldStoreInterface {
    var client: ApolloClientInterface { get }
    
    func fetchAllCountries(cachePolicy: CachePolicy,
                           completion: @escaping ((Result<[World.Country], World.StoreError>) -> Void))
}

extension WorldStoreInterface {
    func fetchAllCountries(cachePolicy: CachePolicy = .fetchIgnoringCacheData,
                           completion: @escaping ((Result<[World.Country], World.StoreError>) -> Void)) {
       
        let query = WorldQuery()
        let queue = DispatchQueue.global(qos: .default)
        
        let resultHandler: OperationResultHandler<WorldQuery> = { (result, error) in

            guard error == nil else {
                completion(.failure(.network))
                return
            }
            
            guard let countries = result?.data?.countries?.compactMap(Self.makeCountry(from:)) else {
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
    
    private static func makeCountry(from country: WorldQuery.Data.Country?) -> World.Country? {
        guard
            let name = country?.name,
            let currency = country?.currency,
            let phone = country?.phone,
            let emoji = country?.emoji,
            let continent = Self.makeContinent(from: country?.continent),
            let languages = country?.languages?.compactMap(Self.makeLanguages(from:))
                else {
                    return nil
        }
        
        return World.Country(name: name,
                             currency: currency,
                             phone: phone,
                             emoji: emoji,
                             languages: languages,
                             continent: continent)
    }
    
    private static func makeContinent(from continent: WorldQuery.Data.Country.Continent?) -> World.Country.Continent? {
        guard let name = continent?.name else {
            return nil
        }
        
        return World.Country.Continent(name: name)
    }
    
    private static func makeLanguages(from language: WorldQuery.Data.Country.Language?) -> World.Country.Language? {
        guard let name = language?.name else {
            return nil
        }
        
        return World.Country.Language(name: name)
    }
}

final class WorldStore: WorldStoreInterface {
    let client: ApolloClientInterface
    
    init(client: ApolloClientInterface) {
        self.client = client
    }
}
