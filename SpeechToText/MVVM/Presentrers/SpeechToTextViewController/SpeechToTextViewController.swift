//
//  SpeechToTextViewController.swift
//  SpeechToText
//
//  Created by Ashish on 28/05/20.
//  Copyright © 2020 Ashish. All rights reserved.
//

import UIKit

class SpeechToTextViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var commandTableView: UITableView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var searchViewBottomConstraint: NSLayoutConstraint!
    
    private let commandCellIdentifier = "VoiceCommandCell"
    
    private var viewModel = SpeechToTextViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupViewModel()
    }
    
    func setupViews() {
        bindKeypad(to: searchViewBottomConstraint)
        commandTableView.dataSource = self
        commandTableView.register(UINib(nibName: commandCellIdentifier, bundle: nil), forCellReuseIdentifier: commandCellIdentifier)
        searchTextField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    }
    
    func setupViewModel() {
        viewModel.viewController = self
        viewModel.commands = [Command]()
        viewModel.requestAuthorization()
        viewModel.showCommandHistory()
    }
    
    @objc func textDidChange(_ sender: UITextField) {
        viewModel.showCommandsContaining(text: sender.text ?? "")
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        viewModel.stopListening()
        micButton.isSelected = false
        recordingLabel.isHidden = true
        if let commandText = searchTextField.text, !commandText.isEmpty {
            if let command = Command(text: commandText) {
                viewModel.store(command)
            }
        }
        searchTextField.text = ""
        viewModel.showCommandsContaining(text: "")
    }
    
    @IBAction func micButtonTapped(_ sender: UIButton) {
        viewModel.commands = [Command]()
        viewModel.micButtonTapped(sender)
    }
    
    @IBAction func didEndEditing(_ sender: UITextField) {
        view.endEditing(true)
    }
}

extension SpeechToTextViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.commands?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: commandCellIdentifier, for: indexPath) as! VoiceCommandCell
        cell.command = viewModel.commands?[indexPath.row]
        return cell
    }
}
