//
//  CreateChannelTableViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 16.02.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import UIKit

private protocol Interface: class {
    func configureWith(channelType: String)
}

class CreateChannelTableViewController: UITableViewController, ChannelInfoCellDelegate {

//MARK: Properties
    @IBOutlet weak var nameCell: CreateChannelNameCell!
    @IBOutlet weak var handleCell: ChannelInfoCell!
    @IBOutlet weak var headerCell: ChannelInfoCell!
    @IBOutlet weak var purposeCell: ChannelInfoCell!
    
    var createButton: UIBarButtonItem!
    
    fileprivate var channelType: String!
    
//MARK: Interface
    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
    }
}


//MARK: Interface
extension CreateChannelTableViewController: Interface {
    func configureWith(channelType: String) {
        self.channelType = channelType
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupNavigationBar()
    func setupCells()
}

fileprivate protocol Action: class {
    func createAction()
}

fileprivate protocol Navigation: class {
    func returnToNewChannelWith(channelId: String)
}

fileprivate protocol Request: class {
    func createChannel()
}


//MARK: Setup
extension CreateChannelTableViewController: Setup {
    internal func initialSetup() {
        setupNavigationBar()
        setupCells()
    }
    
    func setupNavigationBar() {
        self.title = self.channelType == "P" ? "New Group" : "New Channel"
        
        self.createButton = UIBarButtonItem.init(title: "Create", style: .done, target: self, action: #selector(createAction))
        self.navigationItem.rightBarButtonItem = self.createButton
    }
    
    func setupCells() {
        self.nameCell.configureWith(placeholderText: self.channelType == "P" ? "Group Name" : "Channel Name")
        self.handleCell.configureWith(delegate: self)
        self.headerCell.configureWith(delegate: self)
        self.purposeCell.configureWith(delegate: self)
    }
}


//MARK: Action
extension CreateChannelTableViewController: Action {
    func createAction() {
        guard self.nameCell.localizatedName.characters.count > 0 else {
            self.handleErrorWith(message: "Incorrect Channel Name")
            self.nameCell.highligthError()
            return
        }
        
        createChannel()
    }
}


//MARK: Navigation
extension CreateChannelTableViewController {
    func returnToNewChannelWith(channelId: String) {
        RealmUtils.realmForCurrentThread().refresh()
        let channel = RealmUtils.realmForCurrentThread().object(ofType: Channel.self, forPrimaryKey: channelId)
        (self.menuContainerViewController.leftMenuViewController as! LeftMenuViewController).updateSelectionFor(channel!)
        ChannelObserver.sharedObserver.selectedChannel = channel
        _ = self.navigationController?.popViewController(animated: true)
    }
}

//MARK: Request
extension CreateChannelTableViewController: Request {
    func createChannel() {
        self.createButton.isEnabled = false
        let displayName = self.nameCell.localizatedName
        let name        = self.handleCell.infoText
        let header      = self.headerCell.infoText
        let purpose     = self.purposeCell.infoText
        
        Api.sharedInstance.createChannel(self.channelType, displayName: displayName, name: name, header: header, purpose: purpose) { (channelId, error) in
            guard error == nil else {
                let message = error?.code != 500 ? (error?.message)! : "Incorrect Handle"
                self.handleErrorWith(message: message)
                self.createButton.isEnabled = true
                return
            }
            
            let typeName = self.channelType == "O" ? "Channel" : "Group"
            AlertManager.sharedManager.showSuccesWithMessage(message: typeName + " was successfully created")
            self.returnToNewChannelWith(channelId: channelId!)
        }
    }
}


//MARK: UITableViewDelegate
extension CreateChannelTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let textHeight: CGFloat?
        switch indexPath.section {
        case 1:
            textHeight = ChannelInfoCell.heightWith(text: self.handleCell.infoText)
        case 2:
            textHeight = ChannelInfoCell.heightWith(text: self.headerCell.infoText)
        case 3:
            textHeight = ChannelInfoCell.heightWith(text: self.purposeCell.infoText)
        default:
            return CreateChannelNameCell.cellHeight()
        }
        
        return max(20, textHeight!) + 10
    }
}


//MARK: ChannelInfoCellDelegate
extension CreateChannelTableViewController {
    func cellWasUpdatedWith(text: String, height: CGFloat) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
}
