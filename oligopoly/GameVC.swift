//
//  GameVC.swift
//  oligopoly
//
//  Created by yseoyu on 15/05/2018.
//  Copyright © 2018 LePremierChat. All rights reserved.
//

import UIKit
import CoreData

class GameVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var playersList = [Player]()
    var turnsCount = 1
    let months = ["January", "February","March","April","May","June","July","August","September","October","November","December"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        playerTable.delegate = self
        playerTable.dataSource = self
        playerTable.alwaysBounceVertical = false
        playerTable.register(PlayerStatusCell.self, forCellReuseIdentifier: "cell")
        playerTable.separatorStyle = .none
        playerTable.allowsSelection = false
        
        setupViews()
        
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if turnsCount > 12 {
            finishGame()
        }
    }
    
    func clearData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Player")
        do {
            let objects = try(context?.fetch(fetchRequest))
            for object in objects! {
                context?.delete(object as! NSManagedObject)
            }
        } catch let err {
            print(err)
        }
        
    }
    
    func setupData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Player")
            
            do {
                playersList = try(context.fetch(request)) as! [Player]
            } catch let err {
                print(err)
            }
        }
    }
    
    func finishGame() {
        turnLabel.text = "End of the Game!"
        inputTurnsButton.isHidden = true
        taxButton.isHidden = true
        self.view.addSubview(endButton)
        self.view.addConstraint(NSLayoutConstraint(item: endButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 1))
        self.view.addConstraintsWithFormat(format: "H:[v0(140)]", views: endButton)
        self.view.addConstraintsWithFormat(format: "V:[v0(140)]-48-|", views: endButton)
    }

    //MARK: views
    let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = view.hexStringToUIColor(hex: "#283593")
        return view
    }()
    
    let playerTable: UITableView = {
        let table = UITableView()
        
        return table
    }()
    
    let restartButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "menu"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleRestart), for: .touchUpInside)
        return button
    }()
    
    let inputTurnsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Make Decisions", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = button.hexStringToUIColor(hex: "#283593")
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(handleInputTurns), for: .touchUpInside)
        return button
    }()
    
    let turnLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    let endButton: UIButton = {
        let button = UIButton()
        button.setTitle("Finish Game", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = button.hexStringToUIColor(hex: "#E53935")
        button.addTarget(self, action: #selector(handleFinish), for: .touchUpInside)
        button.layer.cornerRadius = 70
        return button
    }()
    
    let taxButton: UIButton = {
        let button = UIButton()
        button.setTitle("TAX", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleTax), for: .touchUpInside)
        return button
    }()
    
    func setupViews() {
        self.view.addSubview(topContainerView)
        self.view.addSubview(playerTable)
        self.view.addSubview(inputTurnsButton)
        
        self.view.addConstraintsWithFormat(format: "H:|[v0]|", views: topContainerView)
        self.view.addConstraintsWithFormat(format: "V:|[v0(80)]-16-[v1]-16-|", views: topContainerView, playerTable)
        self.view.addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: playerTable)
        self.view.addConstraintsWithFormat(format: "H:|-64-[v0]-64-|", views: inputTurnsButton)
        self.view.addConstraintsWithFormat(format: "V:[v0(60)]-64-|", views: inputTurnsButton)
        setupContainer()
    }
    
    func setupContainer() {
        topContainerView.addSubview(restartButton)
        topContainerView.addSubview(turnLabel)
        topContainerView.addSubview(taxButton)
        
        turnLabel.text = months[turnsCount - 1]
        
        topContainerView.addConstraintsWithFormat(format: "H:|-16-[v0]", views: restartButton)
        topContainerView.addConstraintsWithFormat(format: "V:[v0]-12-|", views: restartButton)
        topContainerView.addConstraintsWithFormat(format: "V:[v0]-16-|", views: turnLabel)
        topContainerView.addConstraint(NSLayoutConstraint(item: turnLabel, attribute: .centerX, relatedBy: .equal, toItem: topContainerView, attribute: .centerX, multiplier: 1, constant: 1))
        topContainerView.addConstraintsWithFormat(format: "V:[v0]-12-|", views: taxButton)
        topContainerView.addConstraintsWithFormat(format: "H:[v0]-16-|", views: taxButton)
    }
    
    //MARK: handle functions
    @objc
    func handleTax() {
        
        if turnsCount % 3 == 0 {
            let alert = UIAlertController(title: "Taxation Service", message: "How much tax should be enforced?", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.placeholder = "Set tax value"
                textField.keyboardType = .numberPad
            }
            
            alert.addAction(UIAlertAction(title: "Impose Tax", style: .default, handler: { (action) in
                let textField = alert.textFields![0] as UITextField
                if textField.text != "" {
                    self.imposeTax(tax: Int16(textField.text!)!)
                } else {
                }
                alert.dismiss(animated: true, completion: nil)
            }))
            
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Wrong Month!", message: "You can only impose taxes on March, June, September, and December", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
        }
       
    }
    
    func imposeTax(tax: Int16) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context  = delegate?.persistentContainer.viewContext {
            
            var sorted = playersList.sorted(by: {$0.balance > $1.balance})
            if sorted[0].balance == sorted[1].balance {
                if sorted[1].balance == sorted[2].balance {
                    sorted[0].balance -= tax
                    sorted[1].balance -= tax
                    sorted[2].balance -= tax
                } else {
                    sorted[0].balance -= tax
                    sorted[1].balance -= tax
                }
            } else {
                sorted[0].balance -= tax
            }
            
            do {
                try(context.save())
            } catch let err {
                print(err)
            }
        }
        self.playerTable.reloadData()
    }
    
    @objc
    func handleRestart() {
        
        let actionSheet = UIAlertController(title: "Restart Game?", message: "Are you sure you want to restart the game?", preferredStyle: .actionSheet)
       
        let restartAction = UIAlertAction(title: "Restart", style: .default) { (action) in
            self.clearData()
            let vc = CreateGroupsVC()
            vc.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
            self.present(vc, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            actionSheet.dismiss(animated: true, completion: nil)
        }
        
        actionSheet.addAction(restartAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc
    func handleInputTurns() {
        let vc = InputTurnsVC()
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        vc.turns = turnsCount
        present(vc, animated: true, completion: nil)
    }
    
    @objc
    func handleFinish() {
        let vc = EndVC()
        vc.playersList = playersList
        vc.modalTransitionStyle = .partialCurl
        present(vc, animated: true, completion: nil)
    }
    
    //MARK: tableView
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playerTable.dequeueReusableCell(withIdentifier: "cell") as! PlayerStatusCell
        cell.nameLabel.text = playersList[indexPath.row].name
        cell.revenueLabel.text = String(playersList[indexPath.row].balance)
        cell.safeGameLabel.text = "Safe Games : \(String(playersList[indexPath.row].numberOfSafeGames))"
        cell.riskGameLabel.text = "Risk Games : \(String(playersList[indexPath.row].numberOfRiskGames))"
        return cell
    }
}

class PlayerStatusCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: views
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0)
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    let revenueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .right
        return label
    }()
    
    let riskGameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textColor = .darkGray
        label.textAlignment = .right
        return label
    }()
    
    let safeGameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textColor = .darkGray
        label.textAlignment = .right
        return label
    }()
    
    let numberOfGamesContainer: UIView = {
        let view = UIView()
        return view
    }()
   
    func setupViews() {
        addSubview(containerView)
        addConstraintsWithFormat(format: "H:|-8-[v0]-8-|", views: containerView)
        addConstraintsWithFormat(format: "V:|-4-[v0]-4-|", views: containerView)
        setupContainer()

    }
    
    func setupContainer() {
        containerView.addSubview(nameLabel)
        containerView.addSubview(revenueLabel)
        containerView.addSubview(numberOfGamesContainer)
        
        numberOfGamesContainer.addSubview(safeGameLabel)
        numberOfGamesContainer.addSubview(riskGameLabel)
        
        containerView.addConstraintsWithFormat(format: "H:|-16-[v0]", views: nameLabel)
        containerView.addConstraintsWithFormat(format: "V:|[v0]|", views: nameLabel)
        containerView.addConstraintsWithFormat(format: "V:|[v0]|", views: revenueLabel)
        containerView.addConstraintsWithFormat(format: "H:[v1]-16-[v0(60)]-8-|", views: revenueLabel, numberOfGamesContainer)
        containerView.addConstraint(NSLayoutConstraint(item: numberOfGamesContainer, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1, constant: 1))
        
        numberOfGamesContainer.addConstraintsWithFormat(format: "V:|-8-[v0]-4-[v1]-8-|", views: safeGameLabel, riskGameLabel)
        numberOfGamesContainer.addConstraintsWithFormat(format: "H:|[v0]|", views: safeGameLabel)
        numberOfGamesContainer.addConstraintsWithFormat(format: "H:|[v0]|", views: riskGameLabel)
        
    }
}
