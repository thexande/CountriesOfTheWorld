import UIKit
import WorldAPI
import Anchorage

enum LoadableViewProperties<T> {
    case loading
    case error(Error)
    case data(T)
}


protocol CountryDetailActionDispatching: AnyObject {
    func dispatch(_ action: CountryDetailViewController.Action)
}

final class CountryDetailViewController: UIViewController {
    
    weak var dispatcher: CountryDetailActionDispatching?
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let loadingView = TableLoadingView()
    
    enum Action {
        case willAppear
    }
    
    struct Properties {
        struct Section {
            let title: String
            let items: [String]
        }
        
        let title: String
        let sections: [Section]
    }
    
    var sections: [Properties.Section] = [] {
        didSet {
            view.bringSubviewToFront(tableView)
            self.tableView.reloadData()
        }
    }
    
    func render(_ properties: LoadableViewProperties<Properties>) {
        switch properties {
        case let .data(properties):
            DispatchQueue.main.async {
                self.sections = properties.sections
                self.title = properties.title
            }
        case .error:
            return
        case .loading:
            view.bringSubviewToFront(loadingView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard isViewLoaded else {
            return
        }
        
        dispatcher?.dispatch(.willAppear)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: String(describing: UITableViewCell.self))
        
        view.addSubview(tableView)
        view.addSubview(loadingView)
        loadingView.edgeAnchors == view.edgeAnchors
        tableView.edgeAnchors == view.edgeAnchors
    }
}

extension CountryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self)) else {
            return UITableViewCell()
        }
        
        let item = sections[indexPath.section].items[indexPath.item]
        cell.textLabel?.text = item
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}
