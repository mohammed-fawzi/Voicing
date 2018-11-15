//
//  FCollectionReference.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/13/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import Foundation
import FirebaseFirestore


enum FCollectionReference: String {
    case User
    case Typing
    case Recent
    case Message
    case Group
    case Call
}


func reference(_ collectionReference: FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}

