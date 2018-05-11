//
//  ViewController.swift
//  FormViewController
//
//  Created by Oge Nwabuoku on 5/11/18.
//  Copyright © 2018 Oge Nwabuoku. All rights reserved.
//

import UIKit

struct HotSpot {
    var isEnabled: Bool = true
    var password: String = "Hello"
}

extension HotSpot {
    var enabledSectionTitle : String? {
        return isEnabled ? "Personal Hotspot" : nil
    }
}
struct Sections {
    var cells : [FormViewCell]
    var footerTitle: String?
}

class FormViewCell: UITableViewCell {
    var shouldHighlight = false
    var didSelect : (() -> ())?
}
//First Commit
class ViewController: UITableViewController {
    var sections: [Sections] = []
    var toggle = UISwitch()
    var state = HotSpot() {
        didSet {
            print(state)
            sections[0].footerTitle = state.enabledSectionTitle
            sections[1].cells[0].detailTextLabel?.text = state.password
            reloadSectionFooters()
        }
    }
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
    
    init() {
        super.init(style: .grouped)
        buildSections()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func buildSections() {
        
        let toggleCell = FormViewCell(style: .value1, reuseIdentifier: nil)
        toggleCell.textLabel?.text = "Personal Hostspot"
        toggleCell.contentView.addSubview(toggle)
        toggle.isOn = state.isEnabled
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector (toggleChanged(_:)), for: .valueChanged)
        toggleCell.contentView.addConstraints([
            toggle.centerYAnchor.constraint(equalTo: toggleCell.contentView.centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: toggleCell.contentView.layoutMarginsGuide.trailingAnchor)
            ])
        
        let passwordCell = FormViewCell(style: .value1, reuseIdentifier: nil)
        passwordCell.textLabel?.text =  "Password"
        passwordCell.detailTextLabel?.text = state.password
        passwordCell.accessoryType = .disclosureIndicator
        passwordCell.shouldHighlight = true
        
        let passwordVC = PasswordViewController(password: state.password) {[unowned self] in
            self.state.password = $0
        }
        passwordCell.didSelect = {[unowned self] in
            self.navigationController?.pushViewController(passwordVC, animated: true)
        }
        
        sections = [
            Sections(cells: [toggleCell], footerTitle: state.enabledSectionTitle),
            Sections(cells: [passwordCell], footerTitle: nil)
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
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
    
    @objc func toggleChanged(_ sender : Any) {
        state.isEnabled = toggle.isOn
    }
}


class PasswordViewController : UITableViewController {
    let textField = UITextField()
    let onChange : (String) -> ()
    
    init(password: String, onChange: @escaping (String) -> ()) {
        self.onChange = onChange
        super.init(style: .grouped)
        textField.text = password
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Hostpot Password"
    }
    
    @objc func editingEnded(_ sender : Any) {
        onChange(textField.text ?? "")
    }
    
    @objc func editingDidEnter(_ sender : Any) {
        onChange(textField.text ?? "")
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        textField.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = "Password"
        cell.contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addConstraints([
            textField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor)
            ])
        textField.addTarget(self, action: #selector(editingEnded(_:)), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(editingDidEnter(_:)), for: .editingDidEndOnExit)
        return cell
    }
}
