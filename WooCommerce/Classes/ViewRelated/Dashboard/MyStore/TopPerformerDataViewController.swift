import UIKit
import Yosemite
import Charts
import XLPagerTabStrip
import CocoaLumberjack


class TopPerformerDataViewController: UIViewController, IndicatorInfoProvider {

    // MARK: - Properties

    public let granularity: StatGranularity

    @IBOutlet private weak var tableView: UITableView!

    /// ResultsController: Surrounds us. Binds the galaxy together. And also, keeps the UITableView <> (Stored) TopEarnerStats in sync.
    ///
    private lazy var resultsController: ResultsController<StorageTopEarnerStats> = {
        let storageManager = AppDelegate.shared.storageManager
        let formattedDateString = StatsStore.buildDateString(from: Date(), with: granularity)
        let predicate = NSPredicate(format: "granularity = %@ AND date = %@", granularity.rawValue, formattedDateString)
        let descriptor = NSSortDescriptor(key: "date", ascending: true)

        return ResultsController<StorageTopEarnerStats>(storageManager: storageManager, matching: predicate, sortedBy: [descriptor])
    }()

    // MARK: - Computed Properties

    private var tabDescription: String {
        switch granularity {
        case .day:
            return NSLocalizedString("Today", comment: "Top Performers section title - today")
        case .week:
            return NSLocalizedString("This Week", comment: "Top Performers section title - this week")
        case .month:
            return NSLocalizedString("This Month", comment: "Top Performers section title - this month")
        case .year:
            return NSLocalizedString("This Year", comment: "Top Performers section title - this year")
        }
    }

    // MARK: - Initialization

    /// Designated Initializer
    ///
    init(granularity: StatGranularity) {
        self.granularity = granularity
        super.init(nibName: type(of: self).nibName, bundle: nil)
    }

    /// NSCoder Conformance
    ///
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureTableView()
        registerTableViewCells()
        registerTableViewHeaderFooters()
        configureResultsController()
    }
}


// MARK: - Public Interface
//
extension TopPerformerDataViewController {

    func syncTopPerformers(onCompletion: ((Error?) -> ())? = nil) {
        guard let siteID = StoresManager.shared.sessionManager.defaultStoreID else {
            onCompletion?(nil)
            return
        }

        let action = StatsAction.retrieveTopEarnerStats(siteID: siteID, granularity: granularity, latestDateToInclude: Date()) { (error) in
            if let error = error {
                DDLogError("⛔️ Dashboard (Top Performers) — Error synchronizing top earner stats: \(error)")
            }
        }
        StoresManager.shared.dispatch(action)
    }
}


// MARK: - User Interface Configuration
//
private extension TopPerformerDataViewController {

    func configureView() {
        view.backgroundColor = StyleManager.tableViewBackgroundColor
    }

    func configureTableView() {
        tableView.backgroundColor = StyleManager.tableViewBackgroundColor
        tableView.separatorColor = StyleManager.wooGreyBorder
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = Settings.estimatedRowHeight
        tableView.estimatedSectionHeaderHeight = Settings.estimatedSectionHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
    }

    func configureResultsController() {
        resultsController.startForwardingEvents(to: tableView)
        try? resultsController.performFetch()
    }

    func registerTableViewCells() {
        let cells = [ProductTableViewCell.self]

        for cell in cells {
            tableView.register(cell.loadNib(), forCellReuseIdentifier: cell.reuseIdentifier)
        }
    }

    func registerTableViewHeaderFooters() {
        let headersAndFooters = [TopPerformersHeaderView.self]

        for kind in headersAndFooters {
            tableView.register(kind.loadNib(), forHeaderFooterViewReuseIdentifier: kind.reuseIdentifier)
        }
    }
}


// MARK: - IndicatorInfoProvider Conformance (Tab Bar)
//
extension TopPerformerDataViewController {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabDescription)
    }
}


// MARK: - UITableViewDataSource Conformance
//
extension TopPerformerDataViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return resultsController.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TopPerformersHeaderView.reuseIdentifier) as? TopPerformersHeaderView else {
            fatalError()
        }

        cell.configure(descriptionText: Text.sectionDescription,
                       leftText: Text.sectionLeftColumn.uppercased(),
                       rightText: Text.sectionRightColumn.uppercased())
        return cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? ProductTableViewCell else {
            fatalError()
        }

        cell.configure(statsItem(at: indexPath))
        return cell
    }
}


// MARK: - UITableViewDelegate Conformance
//
extension TopPerformerDataViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}


// MARK: - Convenience Methods
//
private extension TopPerformerDataViewController {

    func statsItem(at indexPath: IndexPath) -> TopEarnerStatsItem? {
        guard let topEarnerStats = resultsController.fetchedObjects.first,
            let topEarnerStatsItem = topEarnerStats.items?[safe: indexPath.row] else {
            return nil
        }

        return topEarnerStatsItem
    }

    func numberOfRows() -> Int {
        guard !resultsController.isEmpty else {
            return 0
        }

        let topEarnerStats = resultsController.fetchedObjects.first
        return topEarnerStats?.items?.count ?? 0
    }
}


// MARK: - Constants!
//
private extension TopPerformerDataViewController {
    enum Text {
        static let noActivity = NSLocalizedString("No activity this period", comment: "Default text for Top Performers section when no data exists for a given period.")
        static let sectionDescription = NSLocalizedString("Gain insights into how products are performing on your store", comment: "Description for Top Performers section of My Store tab.")
        static let sectionLeftColumn = NSLocalizedString("Product", comment: "Description for Top Performers left column header")
        static let sectionRightColumn = NSLocalizedString("Total Spend", comment: "Description for Top Performers right column header")
    }

    enum Settings {
        static let estimatedRowHeight = CGFloat(80)
        static let estimatedSectionHeight = CGFloat(125)
    }
}

