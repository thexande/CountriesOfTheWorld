import Apollo
import Dispatch
import XCTest

extension XCTestCase {
    func withCache(initialRecords: RecordSet? = nil,
                          execute test: (NormalizedCache) throws -> ()) rethrows {
        
        return try InMemoryTestCacheProvider.withCache(initialRecords: initialRecords, execute: test)
    }
}

final class MockNetworkTransport: NetworkTransport {
    
    enum NetworkError: Error {
        case networkFailure
    }
    
    private final class MockTask: Cancellable {
        func cancel() { }
    }
    
    let simulateNetworkFailure: Bool
    
    let body: JSONObject
    
    init(body: JSONObject, simulateNetworkFailure: Bool = false) {
        self.body = body
        self.simulateNetworkFailure = simulateNetworkFailure
    }
    
    func send<Operation>(operation: Operation,
                                completionHandler: @escaping (_ response: GraphQLResponse<Operation>?, _ error: Error?) -> Void) -> Cancellable {
        
        DispatchQueue.global(qos: .default).async {
            
            if self.simulateNetworkFailure {
                completionHandler(nil, NetworkError.networkFailure)
                return
            }
            
            completionHandler(GraphQLResponse(operation: operation, body: self.body), nil)
        }
        
        return MockTask()
    }
}
