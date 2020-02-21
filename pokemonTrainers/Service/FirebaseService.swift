//
//  FirebaseService.swift
//  pokemonTrainers
//
//  Created by Miguel Barone - MBA on 19/02/20.
//  Copyright © 2020 Miguel Barone - MBA. All rights reserved.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa

class FirebaseService {
    let db = Firestore.firestore()
    let disposeBag = DisposeBag()
    
    func listenDocument(collection: String) -> Observable<[[String:Any]]> {
        return Observable.create { (observer) -> Disposable in
            self.db.collection(collection).addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    observer.onNext([])
                    return
                }
                observer.onNext(document.documents.map({ $0.data() }))
            }
            return Disposables.create()
        }
    }

    
    func  createDocument(name: String, pokemonTypes: String) {
        
        // Add a new document with a generated ID
        
        var ref: DocumentReference? = nil
        ref = db.collection("trainers").addDocument(data: [
            "name": name,
            "pokemonType": pokemonTypes
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
}
