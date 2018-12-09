import Apollo
import enum Result.Result

enum World {
    enum StoreError: Error {
        case parsing
        case network
    }
    
    struct Country {
        
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
    
    func fetchAllCountries(completion: @escaping ((Result<[World.Country], World.StoreError>) -> Void))
}

extension WorldStoreInterface {
    func fetchAllCountries(completion: @escaping ((Result<[World.Country], World.StoreError>) -> Void)) {
        let query = WorldQuery()
        
        
    }
}

final class WorldStore: WorldStoreInterface {
    let client: ApolloClientInterface
    
    init(client: ApolloClientInterface) {
        self.client = client
    }
}
