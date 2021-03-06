//
//  FeedAttachmentsTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 27.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import WebImage
import RealmSwift

final class FeedAttachmentsTableViewCell: FeedCommonTableViewCell {
    
//MARK: Properties
    fileprivate let tableView = UITableView()
    fileprivate var attachments : List<File>!
    
//MARK: LifeCycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !self.post.isInvalidated else { return }
        let x = Constants.UI.MessagePaddingSize
        var y: CGFloat = self.post.isFollowUp ? 0 : 36
        y += self.post.hasParentPost() ? (64 + Constants.UI.ShortPaddingSize) : 0
        if (self.post.message?.characters.count)! > 0 { y += CGFloat(post.attributedMessageHeight) + 15.0 }
        let widht = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize
        let height = self.tableView.contentSize.height
        
        self.tableView.frame = CGRect(x: x, y: y, width: widht, height: height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        var indexPath = IndexPath()
        for row in 0...attachments.count-1 {
            indexPath = IndexPath(row: row, section: 0)
            if var cell = tableView.cellForRow(at: indexPath) {
                if /*attachments[row].isImage*/FileUtils.fileIsImage(attachments[row]) {
                    (cell as! AttachmentImageCell).configureForNoSelectedState()
                } else {
                    (cell as! AttachmentFileCell).configureForNoSelectedState()
                }
            }
        }
        
        tableView.delegate = nil
        tableView.dataSource = nil
    }
}


//MARK: Configuration
extension FeedAttachmentsTableViewCell {
    override func configureWithPost(_ post: Post) {
        super.configureWithPost(post)
        self.attachments = self.post.files
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    override class func heightWithPost(_ post: Post) -> CGFloat {
        var heigth: CGFloat = !post.isFollowUp ? 36 : 0
        heigth += CGFloat(post.attributedMessageHeight)
        if (post.message?.characters.count)! > 0 { heigth += 15 }
        post.files.forEach({
            heigth += /*$0.isImage*/FileUtils.fileIsImage($0) ? AttachmentImageCell.heightWithFile($0) : 56
        })
        
        return heigth
    }
}


fileprivate protocol Setup: class {
    func initialSetup()
    func setupTableView()
}


//MARK: Setup
extension FeedAttachmentsTableViewCell: Setup {
    func initialSetup() {
        setupTableView()
    }
    
    func setupTableView() {
        self.tableView.scrollsToTop = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.bounces = false
        self.tableView.isScrollEnabled = false
        
        self.tableView.register(AttachmentImageCell.self, forCellReuseIdentifier: AttachmentImageCell.reuseIdentifier, cacheSize: 15)
        self.tableView.register(AttachmentFileCell.self, forCellReuseIdentifier: AttachmentFileCell.reuseIdentifier, cacheSize: 15)
        self.addSubview(self.tableView)
    }
}


//MARK: UITableViewDataSource
extension FeedAttachmentsTableViewCell : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.attachments != nil ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.attachments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let file = self.attachments[indexPath.row]
        //For gif files can be used solution from search for monkeys 
        if FileUtils.fileIsImage(file) {
            return self.tableView.dequeueReusableCell(withIdentifier: AttachmentImageCell.reuseIdentifier) as! AttachmentImageCell
        } else {
            return self.tableView.dequeueReusableCell(withIdentifier: AttachmentFileCell.reuseIdentifier) as! AttachmentFileCell
        }
    }
}


//MARK: UITableViewDelegate
extension FeedAttachmentsTableViewCell : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let file = self.attachments[indexPath.row]
        return FileUtils.fileIsImage(file) ? AttachmentImageCell.heightWithFile(file) : 56
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let file = self.attachments[indexPath.row]
        (cell as! Attachable).configureWithFile(file)
    }
}

//MARK: LongTapConfigure
extension FeedAttachmentsTableViewCell {
    override func configureForSelectedState(action: String) {
        let selectingColor: UIColor!
        switch action {
        case Constants.PostActionType.SendReply:
            selectingColor = UIColor.kg_lightLightGrayColor()
        case Constants.PostActionType.SendUpdate:
            selectingColor = UIColor.yellow
        default:
            selectingColor = UIColor.kg_lightLightGrayColor()
        }
        
        super.configureForSelectedState(action: action)
        var indexPath = IndexPath()
        for row in 0...attachments.count-1 {
            indexPath = IndexPath(row: row, section: 0)
            if var cell = tableView.cellForRow(at: indexPath) {
                if /*attachments[row].isImage*/FileUtils.fileIsImage(attachments[row]) {
                    (cell as! AttachmentImageCell).configureForSelectedState(action: action)
                } else {
                    (cell as! AttachmentFileCell).configureForSelectedState(action: action)
                }
            }
        }
    }
    
    override func configureForNoSelectedState() {
        super.configureForNoSelectedState()
        var indexPath = IndexPath()
        for row in 0...attachments.count-1 {
            indexPath = IndexPath(row: row, section: 0)
            if var cell = tableView.cellForRow(at: indexPath) {
                if /*attachments[row].isImage*/FileUtils.fileIsImage(attachments[row]) {
                    (cell as! AttachmentImageCell).configureForNoSelectedState()
                } else {
                    (cell as! AttachmentFileCell).configureForNoSelectedState()
                }
            }
        }
    }
}
