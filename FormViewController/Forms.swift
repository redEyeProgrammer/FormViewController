//
//  Forms.swift
//  FormViewController
//
//  Created by Oge Nwabuoku on 5/14/18.
//  Copyright © 2018 Oge Nwabuoku. All rights reserved.
//

import UIKit

class Section {
    let cells: [FormCell]
    var footerTitle: String?
    init(cells: [FormCell], footerTitle: String?) {
        self.cells = cells
        self.footerTitle = footerTitle
    }
}

class FormCell: UITableViewCell {
    var shouldHighlight = false
    var didSelect: (() -> ())?
}

class FormViewController: UITableViewController {
    var sections: [Section] = []
    var firstResponder: UIResponder?
    
    func reloadSectionFooters() {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        for index in sections.indices {
            let footer = tableView.footerView(forSection: index)
            footer?.textLabel?.text = tableView(tableView, titleForFooterInSection: index)
            footer?.setNeedsLayout()
            
        }
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    
    init(sections: [Section], title: String, firstResponder: UIResponder? = nil) {
        self.firstResponder = firstResponder
        self.sections = sections
        super.init(style: .grouped)
        navigationItem.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstResponder?.becomeFirstResponder()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    
    
    func cell(for indexPath: IndexPath) -> FormCell {
        return sections[indexPath.section].cells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell(for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return cell(for: indexPath).shouldHighlight
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footerTitle
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cell(for: indexPath).didSelect?()
    }
    
}

class FormDriver<State> {
    var formViewController: FormViewController!
    var rendered: RenderedElement<[Section], State>!
    
    var state: State {
        didSet {
            rendered.update(state)
            formViewController.reloadSectionFooters()
        }
    }
    
    init(initial state: State, build: (RenderingContext<State>) -> RenderedElement<[Section], State>) {
        self.state = state
        let context = RenderingContext(state: state, change: { [unowned self] f in
            f(&self.state)
            }, pushViewController: { [unowned self] vc in
                self.formViewController.navigationController?.pushViewController(vc, animated: true)
            }, popViewController: {
                self.formViewController.navigationController?.popViewController(animated: true)
        })
        self.rendered = build(context)
        rendered.update(state)
        formViewController = FormViewController(sections: rendered.element, title: "Personal Hotspot Settings")
    }
}

final class TargetAction {
    let execute: () -> ()
    init(_ execute: @escaping () -> ()) {
        self.execute = execute
    }
    @objc func action(_ sender: Any) {
        execute()
    }
}

struct RenderedElement<Element, State> {
    var element: Element
    var strongReferences: [Any]
    var update: (State) -> ()
}

struct RenderingContext<State> {
    let state: State
    let change: ((inout State) -> ()) -> ()
    let pushViewController: (UIViewController) -> ()
    let popViewController: () -> ()
}

func uiSwitch<State>(context: RenderingContext<State>, keyPath: WritableKeyPath<State, Bool>) -> RenderedElement<UIView, State> {
    let toggle = UISwitch()
    toggle.translatesAutoresizingMaskIntoConstraints = false
    let toggleTarget = TargetAction {
        context.change { $0[keyPath: keyPath] = toggle.isOn }
    }
    toggle.addTarget(toggleTarget, action: #selector(TargetAction.action(_:)), for: .valueChanged)
    return RenderedElement(element: toggle, strongReferences: [toggleTarget], update: { state in
        toggle.isOn = state[keyPath: keyPath]
    })
}

func textField<State>(context: RenderingContext<State>, keyPath: WritableKeyPath<State, String>) -> RenderedElement<UIView, State> {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    let didEnd = TargetAction {
        context.change { $0[keyPath: keyPath] = textField.text ?? "" }
    }
    let didExit = TargetAction {
        context.change { $0[keyPath: keyPath] = textField.text ?? "" }
        context.popViewController()
    }
    
    textField.addTarget(didEnd, action: #selector(TargetAction.action(_:)), for: .editingDidEnd)
    textField.addTarget(didExit, action: #selector(TargetAction.action(_:)), for: .editingDidEndOnExit)
    return RenderedElement(element: textField, strongReferences: [didEnd, didExit], update: { state in
        textField.text = state[keyPath: keyPath]
    })
}
