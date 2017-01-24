//
//  ConversationsViewController.swift
//  Demo
//
//  Created by little2s on 16/5/10.
//  Copyright © 2016年 little2s. All rights reserved.
//

import UIKit
import NoChat

class ChatsViewController: UITableViewController {
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let selectedCell = tableView.cellForRow(at: indexPath),
            let title = selectedCell.textLabel?.text else {
                return
        }
        
        switch title {
            
        case "Telegram":
            
            let chatItemsDecorator = TGChatItemsDecorator()
            
            let demoDataSource = TGChatDataSource()
            demoDataSource.chatItems = DemoChatItemFactory.createChatItemsTG()
            
            let chatVC = TGChatViewController()
            chatVC.chatItemsDecorator = chatItemsDecorator
            chatVC.chatDataSource = demoDataSource
            
            chatVC.title = title
            navigationController?.pushViewController(chatVC, animated: true)
            
        case "WeChat":
            
            let chatItemsDecorator = MMChatItemsDecorator()
            
            let demoDataSource = MMChatDataSource()
            demoDataSource.chatItems = DemoChatItemFactory.createChatItemsMM()
            
            let chatVC = MMChatViewController()
            chatVC.chatItemsDecorator = chatItemsDecorator
            chatVC.chatDataSource = demoDataSource
            
            chatVC.title = title
            navigationController?.pushViewController(chatVC, animated: true)
            
        case "Slack":
            
            let chatItemsDecorator = SLKChatItemsDecorator()
            
            let demoDataSource = SLKChatDataSource()
            demoDataSource.chatItems = DemoChatItemFactory.createChatItemsSLK()
            
            let chatVC = SLKChatViewController()
            chatVC.chatItemsDecorator = chatItemsDecorator
            chatVC.chatDataSource = demoDataSource
            
            chatVC.title = title
            navigationController?.pushViewController(chatVC, animated: true)
            
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
