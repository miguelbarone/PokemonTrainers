//
//  RegisterViewModel.swift
//  pokemonTrainers
//
//  Created by Miguel Barone - MBA on 20/02/20.
//  Copyright © 2020 Miguel Barone - MBA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol RegisterViewModelContract {
    func getTrainers()
    func getTypes()
    func didResquestPokemonTypes(index: Int) -> String
    func createDocument(name:String, pokemonType:String)
    var trainers: Driver<[PokemonTrainer]> { get }
    var types: Driver<[String]> { get }
}

class RegisterViewModel: RegisterViewModelContract {
    
    private let TRAINERS_COLLECTION_KEY = "trainers"
    private let TYPES_COLLECTION_KEY = "pokemonTypes"
    
    private let trainerRelay: BehaviorRelay<[PokemonTrainer]> = BehaviorRelay(value: [])
    private let typesRelay: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    
    let service = FirebaseService()
    let disposeBag = DisposeBag()
    
    var trainers: Driver<[PokemonTrainer]> { return trainerRelay.asDriver() }
    var types: Driver<[String]> { return typesRelay.asDriver() }
    
    public func getTrainers() {
        service.listenDocument(collection: TRAINERS_COLLECTION_KEY).subscribe(onNext: { (trainers) in
            var listTrainer:[PokemonTrainer] = []
            trainers.forEach { (dict) in
                listTrainer.append(PokemonTrainer(name: dict["name"] as? String ?? "",
                                                  pokemonType: dict["pokemonType"] as? String ?? ""))
            }
            self.trainerRelay.accept(listTrainer)
        }).disposed(by: disposeBag)
    }
    
    func getTypes() {
        service.listenDocument(collection: TYPES_COLLECTION_KEY).subscribe(onNext: { (types) in
            let pokeTypes = types[0]["types"] as? [String]
            self.typesRelay.accept(pokeTypes ?? [])
            }).disposed(by: disposeBag)
    }
    
    func didResquestPokemonTypes(index: Int) -> String {
        return typesRelay.value[index]
    }
    
    func createDocument(name: String, pokemonType: String) {
        service.createDocument(name: name, pokemonTypes: pokemonType)
    }
}
