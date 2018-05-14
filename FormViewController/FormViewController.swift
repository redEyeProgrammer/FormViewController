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

class HotSpotDriver {
    var formViewController: FormViewController!
    var sections: [Sections] = []
    var toggle = UISwitch()

    init() {
        buildSections()
        formViewController = FormViewController(sections: sections, title : "Personal Hotspot Settings")
    }
    var state = HotSpot() {
        didSet {
            print(state)
            sections[0].footerTitle = state.enabledSectionTitle
            sections[1].cells[0].detailTextLabel?.text = state.password
            formViewController.reloadSectionFooters()
        }
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
        
        let passwordDriver = PasswordDriver(password: state.password) {[unowned self] in
            self.state.password = $0
        }
        passwordCell.didSelect = {[unowned self] in
            self.formViewController.navigationController?.pushViewController(passwordDriver.formViewController, animated: true)
        }
        
        sections = [
            Sections(cells: [toggleCell], footerTitle: state.enabledSectionTitle),
            Sections(cells: [passwordCell], footerTitle: nil)
        ]
    }
    
    @objc func toggleChanged(_ sender : Any) {
        state.isEnabled = toggle.isOn
    }
}


class PasswordDriver {
    let textField = UITextField()
    let onChange : (String) -> ()
    var formViewController: FormViewController!
    var sections : [Sections] = []
    
    init(password: String, onChange: @escaping (String) -> ()) {
        self.onChange = onChange
        buildSections()
        self.formViewController = FormViewController(sections: sections, title: "Hotspot Password", firstResponder: textField)
        textField.text = password
    }
    
    func buildSections() {
        let cell = FormViewCell(style: .value1, reuseIdentifier: nil)
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
        
        sections = [
            Sections(cells: [cell], footerTitle: nil)
        ]
    }
    @objc func editingEnded(_ sender : Any) {
        onChange(textField.text ?? "")
    }
    
    @objc func editingDidEnter(_ sender : Any) {
        onChange(textField.text ?? "")
        formViewController.navigationController?.popViewController(animated: true)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//        textField.becomeFirstResponder()
//    }
//

}
