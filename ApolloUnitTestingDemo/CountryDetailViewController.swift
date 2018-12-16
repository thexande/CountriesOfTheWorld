import UIKit
import WorldAPI

enum LoadableViewProperties<T> {
    case loading
    case error(Error)
    case data(T)
}


protocol CountryDetailActionDispatching: AnyObject {
    func dispatch(_ action: CountryDetailViewController.Action)
}

final class CountryDetailViewController: UITableViewController {
    
    weak var dispatcher: CountryDetailActionDispatching?
    
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
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func render(_ properties: LoadableViewProperties<Properties>) {
        switch properties {
        case let .data(properties):
            DispatchQueue.main.async {
                self.sections = properties.sections
            }
        case .error:
            return
        case .loading:
            return
        }
    }
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self)) else {
            return UITableViewCell()
        }
        
        let item = sections[indexPath.section].items[indexPath.item]
        cell.textLabel?.text = item
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        return (sections[section].items.count < 0 ? nil : sections[section].title)
    }
    
}
