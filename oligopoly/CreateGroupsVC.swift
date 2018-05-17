//
//  ViewController.swift
//  oligopoly
//
//  Created by yseoyu on 15/05/2018.
//  Copyright © 2018 LePremierChat. All rights reserved.
//

import UIKit
import CoreData

class CreateGroupsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var playerList = [Player]()
    var numberOfPlayers = Int()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = self.view.hexStringToUIColor(hex: "#212121")
        
        numberOfPlayers = 5
        
        playersInputTable.delegate = self
        playersInputTable.dataSource = self
        playersInputTable.separatorStyle = .none
        playersInputTable.register(InputCell.self, forCellReuseIdentifier: "cell")
        playersInputTable.allowsSelection = false
        
        setupViews()
        
        clearData()
        
    }
    
    
    
    //MARK: Views
    let logoImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "logo")
        image.tintColor = UIColor.white
        image.contentMode = .scaleAspectFit
        image.layer.masksToBounds = true
        return image
    }()
    
    let playersInputTable: UITableView = {
        let table = UITableView()
        table.alwaysBounceVertical = false
        table.backgroundColor = table.hexStringToUIColor(hex: "#212121")
        return table
    }()
    
    let placeHolderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Enter Players"
        label.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        return label
    }()
    
    let startButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start Game", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.backgroundColor = UIColor.lightGray
        button.layer.cornerRadius = 24
        button.addTarget(self, action: #selector(handleStart), for: .touchUpInside)
        return button
    }()
    
    let addPlayersButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "addPlayers"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleAddPlayers), for: .touchUpInside)
        return button
    }()
    
    func setupViews() {
        self.view.addSubview(playersInputTable)
        self.view.addSubview(startButton)
        self.view.addSubview(placeHolderLabel)
        self.view.addSubview(addPlayersButton)
        
        self.view.addConstraintsWithFormat(format: "V:|-48-[v1]-8-[v0]-8-[v2(48)]-280-|", views: playersInputTable, placeHolderLabel, startButton)
        self.view.addConstraintsWithFormat(format: "H:|-32-[v0]-32-|", views: playersInputTable)
        self.view.addConstraintsWithFormat(format: "H:|-16-[v0]", views: placeHolderLabel)
        self.view.addConstraintsWithFormat(format: "H:[v0]-16-|", views: addPlayersButton)
        self.view.addConstraintsWithFormat(format: "V:|-48-[v0]", views: addPlayersButton)
        self.view.addConstraintsWithFormat(format: "H:[v0(150)]-16-|", views: startButton)
    }
    
    //MARK: handle methods
    @objc
    func handleStart() {
        clearData()
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            
            for row in 0...playersInputTable.numberOfRows(inSection: 0) - 1 {
                
                let index = IndexPath(row: row, section: 0)
                let cell: InputCell = playersInputTable.cellForRow(at: index) as! InputCell
                
                if cell.inputPlayersField.text != "" {
                    
                    let player = NSEntityDescription.insertNewObject(forEntityName: "Player", into: context) as! Player
                    player.name = cell.inputPlayersField.text
                    player.balance = 0
                    player.numberOfRiskGames = 0
                    player.numberOfSafeGames = 0
                    player.isSafe = true
                   
                    playerList.append(player)
                }
            }
            if playerList.count > 4 {
                do {
                    try(context.save())
                } catch let err {
                    print(err)
                }
                let gameVC = GameVC()
                gameVC.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
                present(gameVC.self, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Not enough players", message: "Add more people!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                present(alert, animated: true, completion: nil)
                
            }

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
    
    @objc
    func handleAddPlayers() {
        if numberOfPlayers < 7 {
            numberOfPlayers += 1

            let indexPath = IndexPath(row: numberOfPlayers - 1, section: 0)
            playersInputTable.beginUpdates()
            playersInputTable.insertRows(at: [indexPath], with: .automatic)
            playersInputTable.endUpdates()
        } else {
            let alert = UIAlertController(title: "Too Many Players", message: "This game is ideal for a maximum of 7 players! If you would like to have more players, please devise a new profit function!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "I understand", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: UITableView
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfPlayers
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playersInputTable.dequeueReusableCell(withIdentifier: "cell") as! InputCell
        cell.inputPlayersField.tag = indexPath.row
        return cell
    }
    

}

class InputCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: tableViewCellViews
    let inputPlayersField: UITextField = {
        let field = UITextField()
        field.backgroundColor = field.hexStringToUIColor(hex: "#212121")
        field.textColor = UIColor.white
        field.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        field.borderStyle = .none
        return field
    }()
    
    let underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    private func setupViews() {
        self.addSubview(inputPlayersField)
        self.addSubview(underLineView)
        
        self.addConstraintsWithFormat(format: "H:|[v0]|", views: inputPlayersField)
        self.addConstraintsWithFormat(format: "V:|[v0][v1(1)]|", views: inputPlayersField,underLineView)
        self.addConstraintsWithFormat(format: "H:|[v0]|", views: underLineView)
    }
}
