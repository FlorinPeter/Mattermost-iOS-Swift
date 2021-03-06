//
//  SearchChatTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 13.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

struct Geometry {
    static let AvatarDimension: CGFloat = 40.0
    static let StandartPadding: CGFloat = 8.0
    static let SmallPadding: CGFloat    = 5.0
    static let ErrorViewSize: CGFloat   = 34.0
}


private protocol SearchChatTableViewCellConfiguration {
    func configureLabel(_ label: UILabel, font: UIFont, color: UIColor)
    func configureCellState()
    func configureBasicLabels()
    func configureAvatarImage()
}

class SearchChatTableViewCell: UITableViewCell {

//MARK: Properties
    fileprivate let channelLabel = UILabel()
    fileprivate let avatarImageView = UIImageView()
    fileprivate let nameLabel = UILabel()
    fileprivate let timeLabel = UILabel()
    fileprivate let messageLabel = MessageLabel()
    fileprivate let detailIconImageView = UIImageView()
    
    fileprivate let timeString: String = ""
    // FIXME: CodeReview: Зачем держать сразу и post, и его identifier? Даже посты без identifier (т.е неотправленные) присутствуют в бд и отображаются.
    final var post : Post! {
        didSet { self.postIdentifier = self.post.identifier }
    }
    final var postIdentifier: String?
    
    
//MARK: LifeCycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureWithPost(_ post: Post) {
        self.post = post
        configureBasicLabels()
        configureAvatarImage()
        configureMessageLabel()
    }
    
    func heighWithPost(_ post: Post) -> CGFloat {
        return 0.0
    }
    
    func errorAction() {
        
    }
}


private protocol Setup {
    func initialSetup()
    func setupBackground()
    func setupChannelLabel()
    func setupAvatarImageView()
    func setupNameLabel()
    func setupDateLabel()
    func setupMessageLabel()
    func setupDetailIconImageView()
}

private protocol Action {
    func showProfileAction()
}


//MARK: Setup
extension SearchChatTableViewCell: Setup {
    func initialSetup() {
        setupBackground()
        setupChannelLabel()
        setupAvatarImageView()
        setupNameLabel()
        setupDateLabel()
        setupMessageLabel()
        setupDetailIconImageView()
    }
    
    func setupBackground() {
        self.selectionStyle = .none
        self.backgroundColor = UIColor.white
    }
    
    func setupChannelLabel() {
        configureLabel(self.channelLabel, font: UIFont.kg_semibold13Font(), color: UIColor.kg_lightBlackColor())
        self.addSubview(self.channelLabel)
    }
    
    func setupAvatarImageView() {
        self.avatarImageView.frame = CGRect(x: 8, y: 8, width: 40, height: 40)
        self.avatarImageView.backgroundColor = UIColor.white
        self.avatarImageView.contentMode = .scaleAspectFill
        self.avatarImageView.isUserInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfileAction)))
        self.addSubview(self.avatarImageView)
    }
    
    func setupNameLabel() {
        configureLabel(self.nameLabel, font: UIFont.kg_semibold15Font(), color: UIColor.kg_lightBlackColor())
        self.nameLabel.isUserInteractionEnabled = true
        self.nameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfileAction)))
        self.addSubview(self.nameLabel)
    }
    
    func setupDateLabel() {
        configureLabel(self.timeLabel, font: UIFont.kg_regular13Font(), color: UIColor.kg_lightGrayTextColor())
        self.addSubview(self.timeLabel)
    }
    
    func setupMessageLabel() {
        self.messageLabel.backgroundColor = UIColor.white
        self.messageLabel.layer.drawsAsynchronously = true
        self.addSubview(self.messageLabel)
    }
    
    func setupDetailIconImageView() {
        self.detailIconImageView.image = UIImage(named: "comments_send_icon")
        self.detailIconImageView.backgroundColor = UIColor.white
        self.detailIconImageView.contentMode = .scaleAspectFill
        self.addSubview(self.detailIconImageView)
    }
}


//MARK: Configuration
extension SearchChatTableViewCell: SearchChatTableViewCellConfiguration {
    func configureLabel(_ label: UILabel, font: UIFont, color: UIColor) {
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.numberOfLines = 1
        label.backgroundColor = UIColor.white
        label.font = font
        label.textColor = color
    }
    
    func configureCellState() {
        
    }
    
    func configureBasicLabels() {
        self.channelLabel.text = self.post.channel.name
        self.nameLabel.text = self.post.author.nickname
        self.timeLabel.text = self.post.createdAtString
        configureMessageLabel()
    }
    
    func configureAvatarImage() {
        let postIdentifier = self.post.identifier
        self.postIdentifier = postIdentifier
                
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        // FIXME: CodeReview: зачем проверять наличие у поста identifier?
        ImageDownloader.downloadFeedAvatarForUser(self.post.author) { [weak self] (image, error) in
            guard self?.postIdentifier == postIdentifier else { return }
            self?.avatarImageView.image = image
        }
    }
    
    func configureMessageLabel() {
        self.messageLabel.textStorage = self.post.attributedMessage!
        guard self.post.messageType == .system else { return }
        //self.messageLabel.alpha = 0.5
    }
}


//MARK: Action
extension SearchChatTableViewCell: Action {
    func showProfileAction() {
    }
}
