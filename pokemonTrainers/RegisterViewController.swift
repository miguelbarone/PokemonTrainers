//
//  ViewController.swift
//  pokemonTrainers
//
//  Created by Miguel Barone - MBA on 18/02/20.
//  Copyright © 2020 Miguel Barone - MBA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RegisterViewController: UIViewController {
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var trainerNameTextField: UITextField!
    @IBOutlet weak var favoritePokemonTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    let viewModel = RegisterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }
    
    
    func setup() {
        registerButton.layer.cornerRadius = 15
        trainerNameTextField.addBottomBorder()
        trainerNameTextField.layer.masksToBounds = true
        favoritePokemonTextField.addBottomBorder()
        favoritePokemonTextField.layer.masksToBounds = true
        tableView.keyboardDismissMode = .onDrag
    }
    
    func bind() {
        viewModel.getTrainers()
        viewModel.trainers.drive(tableView.rx.items(cellIdentifier: "cell", cellType: TrainersTableViewCell.self)) { items, model, cell in
            cell.trainerNameLabel.text = model.name
            cell.pokemonTypeLabel.text = model.pokemonType
            cell.selectionStyle = .none 
        }.disposed(by: disposeBag)
        
        let picker = UIPickerView(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 300))
        picker.backgroundColor = .systemGray6
        
        viewModel.getTypes()
        viewModel.types.drive(picker.rx.itemTitles) {row, elem in
            return elem
        }.disposed(by: disposeBag)
        
        picker.rx.itemSelected
        .subscribe(onNext: { (row, value) in
            self.favoritePokemonTextField.text = self.viewModel.didResquestPokemonTypes(index: row)
        })
        .disposed(by: disposeBag)

        
        favoritePokemonTextField.inputView = picker
    }
    
    @IBAction func registerTrainer(_ sender: Any) {
        
        if let name = trainerNameTextField.text, !name.isEmpty, let type = favoritePokemonTextField.text, !type.isEmpty {
            viewModel.createDocument(name: trainerNameTextField.text!, pokemonType: favoritePokemonTextField.text!)
            let alert = UIAlertController(title: "Treinador Cadastrado!", message: "Verifique a lista abaixo.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.trainerNameTextField.text = ""
                self.favoritePokemonTextField.text = ""
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Preencha corretamente os campos.", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          view.endEditing(true)
      }
      
}

extension UITextField {
    func addBottomBorder(){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height, width: UIScreen.main.bounds.width, height: 1)
        bottomLine.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.frame.size.height)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        borderStyle = .none
        layer.addSublayer(bottomLine)
        layer.masksToBounds = true
    }
}
