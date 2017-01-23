//
//  PostStrategy.swift
//  Mattermost
//
//  Created by Maxim Gubin on 10/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

private protocol FeedCellBuilderInterface: class {
    func heightForPost(_ post: Post, prevPost: Post?) -> CGFloat
    func cellForPost(_ post: Post, prevPost: Post?, errorHandler: @escaping (_ post:Post) -> Void) -> UITableViewCell
}


final class FeedCellBuilder {

//MARK: Properties
    fileprivate let tableView: UITableView
    
//MARK: LifeCycle
    init(tableView: UITableView) {
        self.tableView = tableView
    }

    fileprivate init?(){
        return nil
    }
    
    static func isFollowUp(_ post: Post, previous: Post?) -> Bool {
        guard previous != nil else { return false }
        
        let postsInterval = (post.createdAt as NSDate?)?.minutesLaterThan(previous?.createdAt)
        return (post.authorId == previous?.authorId) && (postsInterval! < Constants.Post.FollowUpDelay)
        
    }
    
    static func typeForPost(_ post: Post, previous: Post?) -> CellType {
        return post.hasAttachments() ? .attachment : .common
    }
}


//MARK: FeedCellBuilderInterface
extension FeedCellBuilder: FeedCellBuilderInterface {
    func cellForPost(_ post: Post, prevPost: Post?, errorHandler: @escaping (_ post:Post) -> Void) -> UITableViewCell {
        
//        let reuseIdentifier = (post.cellType == .common) ? FeedCommonTableViewCell.reuseIdentifier : FeedAttachmentsTableViewCell.reuseIdentifier
        let reuseIdentifier = ModernConversationTableViewCell.reuseIdentifier
        
        
        
        var cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? ModernConversationTableViewCell
        if cell == nil {
            cell = ModernConversationTableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
        cell!.transform = self.tableView.transform
//        cell?.errorHandler = errorHandler
        
        if post.renderedText == nil {
            let attrStr = post.attributedMessage!
            post.renderedText = AttributedTextLayoutData(text: attrStr, maxWidth: UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize)
        }
        
        cell!.configureWithPost(post)
        
        return cell!
    }
    
    func heightForPost(_ post: Post, prevPost: Post?) -> CGFloat {
        return ModernConversationTableViewCell.heightWithPost(post)
//        switch post.cellType {
//            case .attachment:
//                return FeedAttachmentsTableViewCell.heightWithPost(post)
//       /*     case .followUp:
////                return FeedFollowUpTableViewCell.heightWithPost(post)
//                return FeedCommonTableViewCell.heightWithPost(post)*/
//            case .common:
//                return FeedCommonTableViewCell.heightWithPost(post)
//            /*case .attachmentFollowUp:
//                return FeedCommonTableViewCell.heightWithPost(post)*/
//        }
    }
}
