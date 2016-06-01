//
//  IssueListViewController.swift
//  Networking
//
//  Created by Ethan Thomas on 6/1/16.
//  Copyright © 2016 Ethan Thomas. All rights reserved.
//

import Moya
import Moya_ModelMapper
import UIKit
import RxCocoa
import RxSwift

class IssueListViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!

    let disposeBag = DisposeBag()
    var provider: RxMoyaProvider<Github>!
    var latestRepositoryName: Observable<String> {
        return searchBar
            .rx_text
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
    }
    var issueTrackerModel: IssueTrackerModel!


    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }

    func setupRx() {

        //create our provider
        provider = RxMoyaProvider<Github>()

        issueTrackerModel = IssueTrackerModel(provider: provider, repositoryName: latestRepositoryName)

        issueTrackerModel
            .trackIssues()
            .bindTo(tableView.rx_itemsWithCellFactory) { (tableView, row, item) in
                let cell = tableView.dequeueReusableCellWithIdentifier("issueCell", forIndexPath: NSIndexPath(forRow: row, inSection: 0))
                cell.textLabel?.text = item.title

                return cell
        }
        .addDisposableTo(disposeBag)

        // Here we tell table view that if user clicks on a cell,
        // and the keyboard is still visible, hide it
        tableView
            .rx_itemSelected
            .subscribeNext { (indexPath) in
                if self.searchBar.isFirstResponder() == true {
                    self.view.endEditing(true)
                }
        }
        .addDisposableTo(disposeBag)
    }
}
