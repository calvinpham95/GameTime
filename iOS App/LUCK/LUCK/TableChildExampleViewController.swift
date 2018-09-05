import Foundation
import XLPagerTabStrip


var firstTeam: String = ""
var secondTeam: String = ""
var gameID: Int = Int()

protocol ChainUp {
    func chainUp1()
    func chainUp2()
}

class TableChildExampleViewController: UITableViewController, IndicatorInfoProvider {
    
    
    var delegate: ChainUp?
    
    let cellIdentifier = "postCell"
    var blackTheme = false
    var itemInfo = IndicatorInfo(title: "View")
    var gameData: [[String: Any]] = []
    
    init(style: UITableViewStyle, itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "PostCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = true
        if blackTheme {
            tableView.backgroundColor = UIColor(red: 15/255.0, green: 16/255.0, blue: 16/255.0, alpha: 1.0)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.gameData = DataProvider.sharedInstance.getData(league: self.itemInfo.title!)
        return self.gameData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PostCell,
            let data = self.gameData[indexPath.row] as? NSDictionary else { return PostCell() }
        
        cell.configureWithData(data)
        if blackTheme {
            cell.changeStylToBlack()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        
        let cell = tableView.cellForRow(at: indexPath) as! PostCell
        firstTeam = cell.team1Name
        secondTeam = cell.team2Name
        cell.checkMarkImage.image = UIImage(named: "Check mark selected")
        var temp1 = self.gameData[indexPath.row]["id"] as! String
        gameID = Int(temp1)!
        delegate?.chainUp1()
        
        
        
    }
    
    

    

    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
}

