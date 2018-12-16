import Foundation
import WorldAPI

protocol CountriesPresenterActionDispatching: AnyObject {
    func dispatch(_ action: CountriesPresenter.Action)
}

final class CountriesPresenter: CountriesViewActionDispatching {
    
    enum Action {
        case selectedCountry(code: String, title: String)
    }
    
    private let store: WorldStoreInterface
    weak var dispatcher: CountriesPresenterActionDispatching?
    
    var render: ((LoadableViewProperties<[World.CountryLite]>) -> Void)?
    
    
    init?() {
        let serverAdress = "https://countries.trevorblades.com/"
        
        guard let url = URL(string: serverAdress) else {
            return nil
        }
        
        let factory = World.Factory()
        self.store = factory.makeStore(with: url)
    }
    
    func dispatch(_ action: CountriesViewController.Action) {
        switch action {
        case .willAppear:
            refresh()
        case let .selectedCountry(code, title):
            dispatcher?.dispatch(.selectedCountry(code: code, title: title))
        case .refresh:
            refresh()
        }
    }
    
    
    func refresh() {
        store.fetchAllCountries(cachePolicy: .returnCacheDataElseFetch) { [weak self] result in
            switch result {
            case let .success(countries):
                self?.render?(.data(countries))
            case let .failure(error):
                self?.render?(.error(error))
            }
        }
    }
}

