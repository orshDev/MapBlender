

import UIKit

protocol TypesTableViewControllerDelegate: class {
  func typesController(controller: TypesTableViewController, didSelectTypes types: [String])
}

class TypesTableViewController: UITableViewController {
  
  let possibleTypesDictionary = ["bakery":"Bakery", "bar":"Bar", "cafe":"Cafe", "grocery_or_supermarket":"Supermarket", "restaurant":"Restaurant"]
  var selectedTypes: [String]!
  weak var delegate: TypesTableViewControllerDelegate!
  var sortedKeys: [String] {
    return possibleTypesDictionary.keys.sorted()
  }
  
  // MARK: - Actions
  @IBAction func donePressed(sender: AnyObject) {
    delegate?.typesController(controller: self, didSelectTypes: selectedTypes)
  }
  
  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return possibleTypesDictionary.count
  }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath)
        let key = sortedKeys[indexPath.row]
        let type = possibleTypesDictionary[key]!
        cell.textLabel?.text = type
        cell.imageView?.image = UIImage(named: key)
        cell.accessoryType = (selectedTypes!).contains(key) ? .checkmark : .none
        return cell

    }
    
 
    
  // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let key = sortedKeys[indexPath.row]
        if (selectedTypes!).contains(key) {
            selectedTypes = selectedTypes.filter({$0 != key})
        } else {
            selectedTypes.append(key)
        }
         tableView.reloadData()
    }
    
  
}
