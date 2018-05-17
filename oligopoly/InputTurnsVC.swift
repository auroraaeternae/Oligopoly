//
//  InputTurnsVC.swift
//  oligopoly
//
//  Created by yseoyu on 16/05/2018.
//  Copyright © 2018 LePremierChat. All rights reserved.
//

import UIKit
import CoreData

class InputTurnsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var playersList = [Player]()
    
    var turns = Int()
    
    var riskGame = RiskGame()
    var safeGame = SafeGame()
    
    var safeWinnersList = [String]()
    var safeWinnersString = String()
    var riskWinnersList = [String]()
    var riskWinnersString = String()
    var safeLosersList = [String]()
    var riskLosersList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        
        gameTable.delegate = self
        gameTable.dataSource = self
        gameTable.register(GameCell.self, forCellReuseIdentifier: "cell")
        gameTable.alwaysBounceVertical = false
        gameTable.separatorStyle = .none
        gameTable.allowsSelection = false
        
        setupData()
        
        titleLabel.isHidden = true
        resultsText.isHidden = true
        returnButton.isHidden = true
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
        
        for player in playersList {
            player.isSafe = true
        }
    }
    
    //MARK: views
    let gameTable: UITableView = {
        let table = UITableView()
        table.backgroundColor = .white
        return table
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Complete Decisions", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .heavy)
        button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
        button.backgroundColor = button.hexStringToUIColor(hex: "#283593")
        button.layer.cornerRadius = 30
        return button
    }()
    
    let popupView: UIView = {
        let view = UIView()
        view.backgroundColor = view.hexStringToUIColor(hex: "#283593")
        view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        view.layer.shadowOpacity = 0
        
        return view
    }()
    
    var popupTopConstraint: NSLayoutConstraint!
    
    func setupViews() {
        view.addSubview(gameTable)
        view.addSubview(doneButton)
        view.addConstraintsWithFormat(format: "H:|-32-[v0]-32-|", views: gameTable)
        view.addConstraintsWithFormat(format: "V:|-60-[v0]-180-|", views: gameTable)
        view.addConstraintsWithFormat(format: "H:|-64-[v0]-64-|", views: doneButton)
        view.addConstraintsWithFormat(format: "V:[v0(60)]-80-|", views: doneButton)
        
        view.addSubview(popupView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: popupView)
        view.addConstraintsWithFormat(format: "V:[v0(500)]", views: popupView)
        popupTopConstraint = NSLayoutConstraint(item: popupView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .topMargin, multiplier: 1, constant: 8)
        view.addConstraint(popupTopConstraint)
        setupResultsContainer()
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Investment Results"
        label.font = .systemFont(ofSize: 32, weight: .heavy)
        label.textColor = .white
        return label
    }()
    
    let resultsText: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 24, weight: .bold)
        textView.textColor = .white
        textView.textAlignment = .center
        textView.backgroundColor = textView.hexStringToUIColor(hex: "#283593")
        return textView
    }()
    
    let returnButton: UIButton = {
        let button = UIButton()
        button.setTitle("Return", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        button.addTarget(self, action: #selector(handleReturn), for: .touchUpInside)
        return button
    }()
    
    func setupResultsContainer() {
        popupView.addSubview(titleLabel)
        popupView.addSubview(resultsText)
        popupView.addSubview(returnButton)
        popupView.addConstraintsWithFormat(format: "V:|-60-[v0]-12-[v1]-16-[v2]-16-|", views: titleLabel,resultsText,returnButton)
        popupView.addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: resultsText)
        popupView.addConstraints([
            NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: popupView, attribute: .centerX, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: resultsText, attribute: .centerX, relatedBy: .equal, toItem: popupView, attribute: .centerX, multiplier: 1, constant: 1),
            NSLayoutConstraint(item: returnButton, attribute: .centerX, relatedBy: .equal, toItem: popupView, attribute: .centerX, multiplier: 1, constant: 1)])
    }
    
    //MARK: functions
    @objc
    func handleReturn() {
        turns += 1
        let vc = GameVC()
        vc.modalTransitionStyle = .crossDissolve
        vc.turnsCount = turns
        present(vc, animated: true, completion: nil)
    }
    
    @objc
    func handleDone() {

        var q = 0
        for player in playersList {
            if player.isSafe == false {
                q += 1
            }
        }
        
        constructRevenues(q: q)
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            
            for player in playersList {
                
                if player.isSafe == true {
                    
                    player.numberOfSafeGames += 1
                    
                    let randomIndex = Int(arc4random_uniform(UInt32(100)))
                    
                    if randomIndex < safeGame.prob {
                        player.balance = player.balance + safeGame.revenue - 10
                        safeWinnersList.append(player.name!)
                    } else {
                        player.balance = player.balance + safeGame.xrevenue - 10
                        safeLosersList.append(player.name!)
                    }
                } else {
                    
                    player.numberOfRiskGames += 1
                    
                    let randomIndex = Int(arc4random_uniform(UInt32(100)))
                    
                    if randomIndex < riskGame.prob {
                        player.balance = player.balance + riskGame.revenue - 13
                        riskWinnersList.append(player.name!)
                    } else {
                        player.balance = player.balance + riskGame.xrevenue - 13
                        riskLosersList.append(player.name!)
                    }
                }
            }
            do {
                try(context.save())
            } catch let err {
                print(err)
            }
        }
        
        if safeWinnersList.count != 0 {
            safeWinnersString = safeWinnersList.joined(separator: ", ")
        } else {
            safeWinnersString = "no one"
        }
        if riskWinnersList.count != 0 {
            riskWinnersString = riskWinnersList.joined(separator: ", ")
        } else {
            riskWinnersString = "no one"
        }
        
        UIView.animate(withDuration: 0.5) {
            self.popupTopConstraint.constant = 460
            self.popupView.layer.shadowOffset = CGSize(width: 0, height: 10.0)
            self.popupView.layer.shadowOpacity = 0.5
            
            self.titleLabel.isHidden = false
            self.resultsText.isHidden = false
            self.returnButton.isHidden = false
            
            self.resultsText.text = "Players who made successful investments in the Safe Game are \(self.safeWinnersString). \n \n Those who were successful by being Risky are \(self.riskWinnersString)."
            
            self.view.layoutIfNeeded()
        }
    }
    
    func constructRevenues(q: Int) {
        
        riskGame.prob = Int(100 * Float(0.2 + Double(q) * 0.05))
        riskGame.revenue = Int16(50 - 6 * q)
        if playersList.count == 7 {
            riskGame.xrevenue = Int16(10 - 1 * q)
        } else {
            riskGame.xrevenue = Int16(8 - 1 * q)
        }
        
        safeGame.prob = 80
        safeGame.revenue = Int16(50 - 6 * q)
        safeGame.xrevenue = Int16(3 + 0.5 * Double(q))
    }
    
    //MARK: uitableview
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = gameTable.dequeueReusableCell(withIdentifier: "cell") as! GameCell
        cell.nameLabel.text = playersList[indexPath.row].name
        cell.balanceLabel.text = String(playersList[indexPath.row].balance)
        cell.decisionButton.tag = Int(indexPath.row)
        cell.decisionButton.addTarget(self, action: #selector(handleDecision), for: .touchUpInside)
        return cell
    }
    
    @objc
    func handleDecision (_sender: UIButton!) {
        let index = _sender.tag
        if playersList[index].isSafe == true {
            playersList[index].isSafe = false
            _sender.setTitle("Risky", for: .normal)
            _sender.backgroundColor = view.hexStringToUIColor(hex: "#E53935")
            _sender.titleLabel?.textColor = .black
        } else if playersList[index].isSafe == false {
            playersList[index].isSafe = true
            _sender.setTitle("Safe", for: .normal)
            _sender.backgroundColor = view.hexStringToUIColor(hex: "#1976D2")
            _sender.titleLabel?.textColor = .white
        }
    }
}

class GameCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Views
    let containerView: UIView = {
        let view = UIView()
        return view
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    let decisionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Safe", for: UIControlState.normal)
        button.backgroundColor = button.hexStringToUIColor(hex: "#1976D2")
        button.titleLabel?.textColor = .white
        button.layer.cornerRadius = 20
        return button
    }()
   
    func setupViews() {
        addSubview(containerView)
        addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: containerView)
        addConstraintsWithFormat(format: "V:|-4-[v0]-4-|", views: containerView)
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(decisionButton)
        containerView.addSubview(balanceLabel)
        containerView.addConstraintsWithFormat(format: "H:|-8-[v0]", views: nameLabel)
        containerView.addConstraintsWithFormat(format: "V:|[v0]|", views: nameLabel)
        containerView.addConstraintsWithFormat(format: "V:[v0(40)]", views: decisionButton)
        containerView.addConstraintsWithFormat(format: "H:[v1]-16-[v0(60)]-16-|", views: decisionButton, balanceLabel)
        containerView.addConstraint(NSLayoutConstraint(item: decisionButton, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1, constant: 1))
        containerView.addConstraint(NSLayoutConstraint(item: balanceLabel, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1, constant: 1))
        
        
        
    }
}










