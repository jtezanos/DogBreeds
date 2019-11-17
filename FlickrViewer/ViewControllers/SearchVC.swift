import UIKit
import RxSwift
import AlamofireImage
import RxCocoa
import Agrume
import RxDataSources

class SearchVC: UIViewController {
    
    static let startLoadingOffset: CGFloat = 20.0
    
    static func isNearTheBottomEdge(contentOffset: CGPoint, _ collectionView: UICollectionView) -> Bool {
        return contentOffset.y + collectionView.frame.size.height + startLoadingOffset > collectionView.contentSize.height
    }
    
    var viewModel = SearchViewModel()
    let disposBag = DisposeBag()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        /// 1) We setup our dataSource & collectionView cell
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionOfBreed>(
            configureCell: { (_, cv, indexPath, url) in
                guard let cell = cv.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.imageCell, for: indexPath) as? ImageCell else {
                    return UICollectionViewCell()
                }
                cell.setup(with: url)
                return cell
            }
        )

        /// 2) Sections are bound to our collectionView
        viewModel.breedsData
          .bind(to: collectionView.rx.items(dataSource: dataSource))
          .disposed(by: disposeBag)
        
        setupTableView()
        collectionViewRx()
    }
    
    func collectionViewRx() {
        let _ = collectionView.rx.contentOffset
            .flatMap { offset in
                SearchVC.isNearTheBottomEdge(contentOffset: offset, self.collectionView)
                    ? Observable.just([])
                    : Observable.empty()
        }
        
        collectionView.rx.didScroll
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.searchBar.resignFirstResponder()
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(String.self)
            .subscribe(onNext: { [weak self] url in
                guard let self = self else { return }
                guard let url = URL(string: url) else { return }
                let agrume = Agrume(url: url, background: .blurred(.extraLight), dismissal: .withPhysicsAndButton(nil))
                agrume.show(from: self)
            })
            .disposed(by: disposeBag)
    }
    
    func setupTableView() {
        /// Declare it anyway we want since we will be modifiying constraints
        tableView = UITableView(frame: CGRect(x: 300, y: 300, width: 30, height: 300))
        view.addSubview(tableView)
        
        /// Setup all constraints, notice how we are not using safe area guides, we will need to update this at some point
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 8.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        
        /// We must register prior to setting up Rx
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: R.reuseIdentifier.tableViewCell)
        
        tableView.rx.modelSelected(String.self)
            .subscribe(onNext: { [weak self] breed in
                guard let self = self else { return }
                self.viewModel.updateBreedImages(breed: breed)
                self.tableView.isHidden = true
            })
            .disposed(by: disposeBag)
        
        /// Once a user completes a search, we will hit the API and filter results accordingly. In the future, we can involve some caching strategy so that we are not always hitting the API
        let searchResultsForBreed = searchBar.rx.text.orEmpty
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .doOnNext({ [weak self] _ in
                self?.tableView.isHidden = false
            })
            .flatMapLatest(viewModel.breeds)
            .observeOn(MainScheduler.instance)
        
        searchResultsForBreed
            .bind(to: tableView.rx.items(cellIdentifier: R.reuseIdentifier.tableViewCell, cellType: UITableViewCell.self)) { (_, breed: String, cell: UITableViewCell) in
                cell.textLabel?.text = breed
            }
            .disposed(by: disposeBag)
    }
    
}
