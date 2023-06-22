//
//  SwipeToDelete.swift
//  Todoey APP
//
//  Created by Adil Anjum Khan on 21/06/2023.
//

import UIKit
import SwipeCellKit

class SwipeToDelete:UITableViewController, SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructiveAfterFill
        options.transitionStyle = .border
        return options
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.performDeleteAction(indexPath: indexPath)
        }
        
        let editAction = SwipeAction(style: .destructive, title: "Edit") { action, indexPath in
            self.performEditAction(indexPath: indexPath)
        }
        
        // Customize delete action appearance if desired
        deleteAction.image = UIImage(systemName: "trash.fill")
        // Customize the background color of the delete action
        deleteAction.backgroundColor = .red
        // Customize the tint color of the delete action (for icon and text)
        deleteAction.textColor = .white
        
        // Customize delete action appearance if desired
        editAction.image = UIImage(systemName: "pencil")
        // Customize the background color of the delete action
        editAction.backgroundColor = .yellow
        // Customize the tint color of the delete action (for icon and text)
        editAction.textColor = .black
        
        return [deleteAction,editAction,]
    }
    
    func performDeleteAction(indexPath:IndexPath)
    {
        printContent("Delete request !")
    }
    
    func performEditAction(indexPath:IndexPath)
    {
        printContent("Edit request !")
    }
    
    func displayErrorAlert(errorMessage:String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        // Present the alert view controller
        self.present(alertController, animated: true, completion: nil)
    }
}
