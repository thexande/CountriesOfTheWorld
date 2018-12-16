import WorldAPI

protocol CountryPresenterActionDispatching: AnyObject {
    func dispatch(_ action: CountryPresenter.Action)
}

final class CountryPresenter: CountryDetailActionDispatching {
    enum Action {
        case willAppear
        case selectedCountry(code: String)
    }
    
    private let code: String
    private let store: WorldStoreInterface
    var render: ((LoadableViewProperties<CountryDetailViewController.Properties>) -> Void)?
    
    
    init?(code: String) {
        self.code = code
        
        let serverAdress = "https://countries.trevorblades.com/"
        
        guard let url = URL(string: serverAdress) else {
            return nil
        }
        
        let factory = World.Factory()
        self.store = factory.makeStore(with: url)
    }
    
    func dispatch(_ action: CountryDetailViewController.Action) {
        switch action {
        case .willAppear:
            refresh()
        }
    }
    
    
    func refresh() {
        
        store.fetchCountry(code: code, cachePolicy: .returnCacheDataElseFetch) { [weak self] result in
            switch result {
            case let .success(country):
                
                let sections = [
                    CountryDetailViewController.Properties.Section(title: "name", items: [country.name]),
                    CountryDetailViewController.Properties.Section(title: "flag", items: [country.emoji]),
                    CountryDetailViewController.Properties.Section(title: "continent", items: [country.continent.name]),
                    CountryDetailViewController.Properties.Section(title: "currency", items: [country.currency]),
                    CountryDetailViewController.Properties.Section(title: "languages", items: country.languages.map { $0.name }),
                    ]
                
                let title = "\(country.emoji) \(country.name)"
                let properties = CountryDetailViewController.Properties(title: title, sections: sections)
                
                self?.render?(.data(properties))
                
            case let .failure(error):
                return
            }
        }
    }
}
