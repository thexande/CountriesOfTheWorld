import UIKit

final class WorldCoordinator: CountriesPresenterActionDispatching {
    
    var countriesPresenter: CountriesPresenter?
    var countryPresenter: CountryPresenter?
    let nav = UINavigationController()
    
    init() {
        countriesPresenter = CountriesPresenter()
        
        let countriesView = CountriesViewController()
        countriesView.dispatcher = countriesPresenter
        
        countriesPresenter?.render = { [weak countriesView] data in
            countriesView?.render(data)
        }
        
        countriesPresenter?.dispatcher = self
        
        nav.viewControllers = [countriesView]
    }
    
    func dispatch(_ action: CountriesPresenter.Action) {
        if case let .selectedCountry(code, title) = action {
            let view = CountryDetailViewController()
            view.title = title
            countryPresenter = CountryPresenter(code: code)
            view.dispatcher = countryPresenter
            
            countryPresenter?.render = { [weak view] properties in
                view?.render(properties)
            }
            
            DispatchQueue.main.async {
                self.nav.pushViewController(view, animated: true)
            }
        }
    }
    
}

