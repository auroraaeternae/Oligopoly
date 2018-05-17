//
//  HelpVC.swift
//  oligopoly
//
//  Created by Christian Yu on 5/17/18.
//  Copyright © 2018 LePremierChat. All rights reserved.
//

import UIKit

class HelpVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = view.hexStringToUIColor(hex: "#283593")
        
        setupViews()
    }
    
    let text = "This is an investment game. \n"
    
    let helpText: UITextView = {
        let view = UITextView()
        return view
    }()
    
    let proceedButton: UIButton = {
        let button = UIButton()
        button.setTitle("Proceed", for: .normal)
        button.backgroundColor = button.hexStringToUIColor(hex: "#E53935")
        button.titleLabel?.textColor = .white
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(handleProceed), for: .touchUpInside)
        return button
    }()

    func setupViews() {
        self.view.addSubview(helpText)
        self.view.addSubview(proceedButton)
        self.view.addConstraintsWithFormat(format: "H:|-32-[v0]-32-|", views: helpText)
        self.view.addConstraintsWithFormat(format: "H:|-64-[v0]-64-|", views: proceedButton)
        self.view.addConstraintsWithFormat(format: "V:|-64-[v0]-32-[v1]-64-|", views: helpText,proceedButton)
    }

    @objc
    func handleProceed() {
        let vc = GameVC()
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true, completion: nil)
    }
}
