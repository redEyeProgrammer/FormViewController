//
//  Forms.swift
//  FormViewController
//
//  Created by Oge Nwabuoku on 5/14/18.
//  Copyright © 2018 Oge Nwabuoku. All rights reserved.
//

import UIKit

class Sections {
    let cells : [FormViewCell]
    var footerTitle: String?
    
    init(cells: [FormViewCell], footerTitle: String?) {
        self.cells = cells
        self.footerTitle = footerTitle
    }
}

class FormViewCell: UITableViewCell {
    var shouldHighlight = false
    var didSelect : (() -> ())?
}

class FormViewController: UITableViewController {
    var sections: [Sections] = []
    var firstResponder : UIResponder?
    
    
    func reloadSectionFooters(){
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        //Grab a hold of the footer reference
        //for index in section.indices
        for (index, _) in sections.enumerated() {
            let footer = tableView.footerView(forSection: index)
            footer?.textLabel?.text = tableView(tableView, titleForFooterInSection: index)
            footer?.setNeedsLayout()
        }
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    init(sections: [Sections], title: String, firstResponder: UIResponder? = nil) {
        self.firstResponder = firstResponder
        self.sections = sections
        super.init(style: .grouped)
        self.navigationItem.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.firstResponder?.becomeFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //First we need to look at the right section in the section arrays
        //Then we need to pickout the right cell
        return cell(forRow: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footerTitle
    }
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return cell(forRow: indexPath).shouldHighlight
    }
    func cell(forRow indexPath: IndexPath) -> FormViewCell {
        return sections[indexPath.section].cells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cell(forRow: indexPath).didSelect?()
    }
    
    
}
