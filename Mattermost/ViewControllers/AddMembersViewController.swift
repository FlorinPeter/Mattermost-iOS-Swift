//
//  AddMembersViewController.swift
//  Mattermost
//
//  Created by Владислав on 11.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import RealmSwift

class AddMembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating  {
    
    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    var channel: Channel!
    var users: Results<User>!
    var searchUsers: Results<User>!
    var searchMembersList: Results<User>!
    
    var lastSelectedIndexPath: IndexPath? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.dataSource = self
        tableView.delegate = self
        setupNavigationBar()
        setupSearchBar()
        setupUsers()
        
        let nib = UINib(nibName: "MemberInAdditingCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "memberInAdditingCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if users != nil && !searchController.isActive{
            return users.count
        }
        if searchUsers != nil && searchController.isActive{
            return searchUsers.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: MemberInAdditingCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "memberInAdditingCell") as! MemberInAdditingCell!
        searchController.isActive ? cell.configureWithUser(user: searchUsers[indexPath.row]) : cell.configureWithUser(user: users[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func setupNavigationBar() {
        self.title = "Add Members".localized
    }
    
    func setupSearchBar(){
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.backgroundColor = .white
        searchController.searchBar.barTintColor = .white
        let view: UIView = searchController.searchBar.subviews[0] as UIView
        for subView: UIView in view.subviews {
            if let textView = subView as? UITextField {
                textView.backgroundColor = UIColor(red:     239.0/255.0,
                                                   green:   239.0/255.0,
                                                   blue:    244.0/255.0,
                                                   alpha:   1.0)
            }
        }
        let rect = searchController.searchBar.frame
        let lineView = UIView.init(frame: CGRect.init(x: 0, y: rect.size.height-2, width: rect.size.width, height: 2))
        lineView.backgroundColor = UIColor.white
        searchController.searchBar.addSubview(lineView)
        
        self.definesPresentationContext = false
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .all
        searchController.searchBar.isTranslucent = false
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.lastSelectedIndexPath == nil else { return }
        self.lastSelectedIndexPath = indexPath
        
        let member = searchController.isActive ? searchUsers[indexPath.row] : users[indexPath.row]
        
        self.showLoaderView()
        
        Api.sharedInstance.addUserToChannel(member, channel: channel, completion: { (error) in
            guard (error == nil) else {
                self.hideLoaderView()
                self.lastSelectedIndexPath = nil; return
            }
            Api.sharedInstance.loadExtraInfoForChannel(self.channel.identifier!, completion: { (error) in
                guard (error == nil) else {
                    AlertManager.sharedManager.showErrorWithMessage(message: "You left this channel".localized)
                    self.hideLoaderView()
                    self.lastSelectedIndexPath = nil
                    return
                }
                AlertManager.sharedManager.showSuccesWithMessage(message: member.displayName!+" was added in channel")
                self.hideLoaderView()
                self.channel = try! Realm().objects(Channel.self).filter("identifier = %@", self.channel.identifier!).first!
                self.setupUsers()
                self.tableView.reloadData()
                if self.searchController.isActive {
                    self.searchController.searchBar.text! += ""
                }
                self.lastSelectedIndexPath = nil
            })
        })
        
    }
    
    func setupUsers() {
        let sortName = UserAttributes.username.rawValue
        let identifiers = Array(channel.members.map{$0.identifier!})
        let townSquare = RealmUtils.realmForCurrentThread().objects(Channel.self).filter("name == %@", "town-square").first
        
        let townSquareIdentifiers = Array(townSquare!.members.map{$0.identifier!})
        
        
        let predicate =  NSPredicate(format: "identifier != %@ AND identifier != %@ AND NOT identifier IN %@ AND identifier IN %@", Constants.Realm.SystemUserIdentifier,
                                     Preferences.sharedInstance.currentUserId!, identifiers, townSquareIdentifiers)
        users = RealmUtils.realmForCurrentThread().objects(User.self).filter(predicate).sorted(byProperty: sortName, ascending: true)
    }
    
    //Search updating
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(searchText: searchText)
            tableView.reloadData()
        }
    }
    
    func filterContent(searchText: String){
        
        let sortName = UserAttributes.username.rawValue
        let identifiers = Array(channel.members.map{$0.identifier!})
        let townSquare = RealmUtils.realmForCurrentThread().objects(Channel.self).filter("name == %@", "town-square").first
        
        let townSquareIdentifiers = Array(townSquare!.members.map{$0.identifier!})
        
        
        let predicate =  NSPredicate(format: "identifier != %@ AND identifier != %@ AND NOT identifier IN %@ AND identifier IN %@ AND displayName CONTAINS[c] '\(searchText)'", Constants.Realm.SystemUserIdentifier,
                                     Preferences.sharedInstance.currentUserId!, identifiers, townSquareIdentifiers)
        searchUsers = RealmUtils.realmForCurrentThread().objects(User.self).filter(predicate).sorted(byProperty: sortName, ascending: true)
    }
    
}
