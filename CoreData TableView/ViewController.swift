//
//  ViewController.swift
//  CoreData TableView
//
//  Created by Bjorn Eivind Rostad on 4/28/16.
//  Copyright © 2016 bearroast. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var users = [User]()
    let tableView = UITableView()
    var newNameInput: UITextField?
    var context: NSManagedObjectContext?
    var fetchedResultsController: NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Users"
        
        edgesForExtendedLayout = UIRectEdge.None
        tableView.frame = view.frame
        
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("toggleEdit"))
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        navigationItem.rightBarButtonItem = addButton
        
        if let context = context {
            let request = NSFetchRequest(entityName: "User")
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "FetchedResultsTableView")
            
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("There was a problem fetching")
            }
        }
        
        
        
        do {
            let request = NSFetchRequest(entityName: "User")
            if let result = try context?.executeFetchRequest(request) as? [User] {
                users = result
            }
        } catch {
            print("We could not fetch")
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func toggleEdit() {
        tableView.setEditing(!tableView.editing, animated: true)
        let title = tableView.editing ? "Done" : "Edit"
        navigationItem.leftBarButtonItem?.title = title
    }
    
    func insertNewObject(sender: AnyObject) {
        let newNameAlert = UIAlertController(title: "Add new user", message: "What's the user's name?", preferredStyle: UIAlertControllerStyle.Alert)
        
        newNameAlert.addTextFieldWithConfigurationHandler { (alertTextField) -> Void in
            self.newNameInput = alertTextField
        }
        
        newNameAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        newNameAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: addNewUser))
        presentViewController(newNameAlert, animated: true, completion: nil)
    }
    
    func addNewUser (alert: UIAlertAction!) {
        
        guard let name = newNameInput?.text else { return }
        guard let context = context else { return }
        guard let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as? User else { return }
        user.name = name
        
        do {
            try context.save()
        }
        catch {
            print("there was a problem saving")
            return
        }
        
        users.append(user)
        tableView.reloadData()
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            return 0
        }
        
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if let user = fetchedResultsController?.objectAtIndexPath(indexPath) as? User {
            cell.textLabel?.text = user.name
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            if let object = fetchedResultsController?.objectAtIndexPath(indexPath) as? User, context = context {
                context.deleteObject(object)
                do {
                    try context.save()
                } catch {
                    print("There was a problem saving")
                    return
                }
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}


extension ViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        default: break
        }
        
        func controllerDidChangeContent(controller: NSFetchedResultsController) {
            tableView.endUpdates()
        }
    }
}