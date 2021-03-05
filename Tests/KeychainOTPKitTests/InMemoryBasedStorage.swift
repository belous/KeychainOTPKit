//
//  InMemoryBasedStorage.swift
//  
//
//  Created by Sergei Belous on 5.03.21.
//

import Foundation
@testable import KeychainOTPKit

/*
class InMemoryBasedStorage: Storable {
    private var storage: [UUID: [String: Data]] = [UUID: [String: Data]]()

    func save(userData: UserData, uuid: UUID, secretData: SecretData) -> Result<Void, StorableError> {
        if storage.updateValue(["userData": userData, "secretData": secretData], forKey: uuid) != nil {
            return .success(())
        }
        return .failure(.genericError)
    }

    func remove(at persistentRef: PersistentRef) -> Result<Void, StorableError> {
        return .failure(.genericError)
    }

    func retriveRawData() -> Result<[StorableData], StorableError> {
        
    }

    func retriveSecret(at persistentRef: PersistentRef) -> Result<SecretData, StorableError> {

    }
}

 */
