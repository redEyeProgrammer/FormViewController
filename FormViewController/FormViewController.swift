//
//  ViewController.swift
//  FormViewController
//
//  Created by Oge Nwabuoku on 5/11/18.
//  Copyright © 2018 Oge Nwabuoku. All rights reserved.
//

import UIKit

struct Hotspot {
    var isEnabled: Bool = true
    var password: String = "hello"
}

extension Hotspot {
    var enabledSectionTitle: String? {
        return isEnabled ? "Personal Hotspot Enabled" : nil
    }
}


func hotspotForm(context: RenderingContex<Hotspot>) -> ([Sections], Observer<Hotspot>) {
    var strongReferences: [Any] = []
    var updates: [(Hotspot) -> ()] = []
    
    let toggleCell = FormViewCell(style: .value1, reuseIdentifier: nil)
    let toggle = UISwitch()
    toggleCell.textLabel?.text = "Personal Hotspot"
    toggleCell.contentView.addSubview(toggle)
    toggle.translatesAutoresizingMaskIntoConstraints = false
    let toggleTarget = TargetAction {
        context.change { $0.isEnabled = toggle.isOn }
    }
    strongReferences.append(toggleTarget)
    updates.append { state in
        toggle.isOn = state.isEnabled
    }
    toggle.addTarget(toggleTarget, action: #selector(TargetAction.action(_:)), for: .valueChanged)
    toggleCell.contentView.addConstraints([
        toggle.centerYAnchor.constraint(equalTo: toggleCell.contentView.centerYAnchor),
        toggle.trailingAnchor.constraint(equalTo: toggleCell.contentView.layoutMarginsGuide.trailingAnchor)
        ])
    
    
    let passwordCell = FormViewCell(style: .value1, reuseIdentifier: nil)
    passwordCell.textLabel?.text = "Password"
    passwordCell.accessoryType = .disclosureIndicator
    passwordCell.shouldHighlight = true
    updates.append { state in
        passwordCell.detailTextLabel?.text = state.password
    }
    
    //let passwordDriver = FormDriver(initial: context.state, build: buildPasswordForm)
    let (sections, observers) = buildPasswordForm(context)
    let nested = FormViewController(sections: sections, title: "Personal Hostpot Password")
    passwordCell.didSelect = {
        context.pushViewController(nested)
    }
    
    let toggleSection = Sections(cells: [toggleCell], footerTitle: nil)
    updates.append { state in
        toggleSection.footerTitle = state.enabledSectionTitle
    }
    
    return ([
        toggleSection,
        Sections(cells: [
            passwordCell
            ], footerTitle: nil),
        ], Observer(strongReferences: strongReferences + observers.strongReferences) { state in
            observers.update(state)
            for u in updates {
                u(state)
            }
        }
    )
}


func buildPasswordForm(_ context: RenderingContex<Hotspot>) -> ([Sections], Observer<Hotspot>) {
    let cell = FormViewCell(style: .value1, reuseIdentifier: nil)
    let textField = UITextField()
    cell.textLabel?.text = "Password"
    cell.contentView.addSubview(textField)
    textField.translatesAutoresizingMaskIntoConstraints = false
    let update: (Hotspot) -> () = { state in
        textField.text = state.password
    }
    cell.contentView.addConstraints([
        textField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        textField.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
        textField.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 20)
        ])
    let ta1 = TargetAction {
        context.change { $0.password = textField.text ?? ""}
    }
    
    let ta2 = TargetAction {
        context.change { $0.password = textField.text ?? ""}
        context.popViewController()
    }
    textField.addTarget(ta1, action: #selector(TargetAction.action(_:)), for: .editingDidEnd)
    textField.addTarget(ta2, action: #selector(TargetAction.action(_:)), for: .editingDidEndOnExit)
    
     return ([
        Sections(cells: [cell], footerTitle: nil)
        ], Observer(strongReferences: [ta1, ta2], update: update))

}

