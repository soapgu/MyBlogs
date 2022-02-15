//
//  ViewController.swift
//  MyBlogs
//
//  Created by guhui on 2022/2/11.
//

import UIKit
import RxSwift

class ViewController: UITableViewController,UITableViewDataSourcePrefetching {
    let pageSize:Int = 20
    var totalCount = 0
    var loading = false
    var dataSource = [Int:[Issue]]()
    let api:GithubAPI = GithubAPI()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBlogs(pageNumber: 0)
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        //print("prefetchRowsAt rows:\(productIndexStr( indexPaths))")
        if( !loading ){
            let pageNumerSet = Set(indexPaths.map{ $0.row / pageSize })
            for page in pageNumerSet{
                //print( "check page" )
                if( dataSource[page] == nil ){
                    loadBlogs(pageNumber: page)
                    break;
                }
            }
        }
    }
    
    func loadBlogs( pageNumber:Int ){
        loading = true
        print( "load page:\(pageNumber)" )
        api.loadBlogs(pageSize: self.pageSize,pageNumber: pageNumber + 1 ).observe(on: MainScheduler.instance)
            .subscribe(onSuccess:{ [weak self] result in
                self?.totalCount = result.total_count
                self?.dataSource[pageNumber] = result.items
                if pageNumber == 0 {
                    self?.tableView.reloadData()
                }
                else {
                    if let indexPathsToReload = self?.calculateIndexPathsToReload(pageNumber: pageNumber) {
                        self?.tableView.reloadRows(at: indexPathsToReload, with: .fade)
                    }
                }
            } , onFailure: { error in
                print( error.localizedDescription ) },
               onDisposed: { [weak self] in
                self?.loading = false
            })
            .disposed(by: disposeBag)
    }
    
    private func calculateIndexPathsToReload(pageNumber: Int) -> [IndexPath] {
        let startIndex = pageNumber * pageSize
        let endIndex = pageNumber * pageSize + pageSize
        let indexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
        /*
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
        */
        return indexPaths
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("fetch total")
        return totalCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("render row: \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let pageIndex = indexPath.row / pageSize
        if let pageRecords = dataSource[pageIndex]{
            let issue = pageRecords[indexPath.row % pageSize]
            content.text = "\(issue.number). \(issue.title)"
            //cell.textLabel?.showsExpansionTextWhenTruncated = true
        }
        else{
            content.text = "loading"
        }
        content.textProperties.numberOfLines = 1
        content.textProperties.font = UIFont.systemFont(ofSize: 13)
        cell.contentConfiguration = content
        return cell
    }
    
    func productIndexStr( _ indexPaths: [IndexPath] ) -> String {
        var indexStr = ""
        for index in indexPaths{
            indexStr += "\(index.row) "
        }
        return indexStr.trimmingCharacters(in: .whitespaces)
    }
}

