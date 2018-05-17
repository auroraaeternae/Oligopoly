//
//  EndVC.swift
//  oligopoly
//
//  Created by Christian Yu on 5/16/18.
//  Copyright © 2018 LePremierChat. All rights reserved.
//

import UIKit
import CoreData

class EndVC: UIViewController {
    
    var playersList = [Player]()
    var winnerList = [String]()
    var winnerString = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = view.hexStringToUIColor(hex: "#283593")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        determineWinner()
        setupViews()

    }
    
    let congratulationsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Congratulations!"
        label.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        label.textAlignment = .center
        return label
    }()
    
    let restartButton: UIButton = {
        let button = UIButton()
        button.setTitle("Restart Game", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = button.hexStringToUIColor(hex: "#E53935")
        button.addTarget(self, action: #selector(handleRestart), for: .touchUpInside)
        button.layer.cornerRadius = 70
        return button
    }()
    
    let winnerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    func setupViews() {
        self.view.addSubview(congratulationsLabel)
        self.view.addSubview(restartButton)
        self.view.addSubview(winnerLabel)
        
        if winnerList.count == 1 {
            winnerLabel.text = "The Winner is \(winnerString)"
        } else {
            winnerLabel.text = "The Winners are \(winnerString)"
        }
        
        self.view.addConstraint(NSLayoutConstraint(item: congratulationsLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 1))
        self.view.addConstraint(NSLayoutConstraint(item: restartButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 1))
        self.view.addConstraint(NSLayoutConstraint(item: winnerLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 1))
        self.view.addConstraintsWithFormat(format: "V:|-100-[v0]-16-[v1]", views: congratulationsLabel, winnerLabel)
        self.view.addConstraintsWithFormat(format: "V:[v0(140)]-48-|", views: restartButton)
        self.view.addConstraintsWithFormat(format: "H:[v0(140)]", views: restartButton)
        self.view.addConstraintsWithFormat(format: "H:|-32-[v0]-32-|", views: winnerLabel)
        
    }
    
    @objc
    func handleRestart() {
        clearData()
        let vc = CreateGroupsVC()
        vc.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        present(vc, animated: true, completion: nil)
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
    
    func determineWinner() {
        
            var sorted = playersList.sorted(by: {$0.balance > $1.balance})
            if sorted[0].balance == sorted[1].balance {
                if sorted[1].balance == sorted[2].balance {
                    winnerList.append(sorted[0].name!)
                    winnerList.append(sorted[1].name!)
                    winnerList.append(sorted[2].name!)
                } else {
                    winnerList.append(sorted[0].name!)
                    winnerList.append(sorted[1].name!)
                }
            } else {
                winnerList.append(sorted[0].name!)
            }
            winnerString = winnerList.joined(separator: ", ")
    }
}
