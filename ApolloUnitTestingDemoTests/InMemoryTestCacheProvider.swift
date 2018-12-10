import XCTest
@testable import Apollo

protocol TestCacheProvider: AnyObject {
    static func withCache(initialRecords: RecordSet?,
                          execute test: (NormalizedCache) throws -> ()) rethrows
}

class InMemoryTestCacheProvider: TestCacheProvider {
    /// Execute a test block rather than return a cache synchronously, since cache setup may be
    /// asynchronous at some point.
    static func withCache(initialRecords: RecordSet? = nil,
                                 execute test: (NormalizedCache) throws -> ()) rethrows {
        let cache = InMemoryNormalizedCache(records: initialRecords ?? [:])
        try test(cache)
    }
}
