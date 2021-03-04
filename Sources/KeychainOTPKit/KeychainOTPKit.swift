import Foundation

enum AccountsError: Error {
    case encodingError
    case decodingError
    case savingError
    case removalError
}

public final class KeychainOTPKit {

    private let encoder = JSONEncoder()

    private let keychain: KeychainCore
    private var accounts: [UUID: Account] = [:]
    var all: [UUID: Account] {
        accounts
    }

    init(keychainService: KeychainService) {
        self.keychain = KeychainCore(keychainService: keychainService)
        retriveAccounts()
    }

    private func retriveAccounts() {
        accounts = keychain.accounts
    }

    func addNewAccount(keychainAccount: KeychainAccount, secret: Secret) {
        let keychainID = keychainAccount.id
        let keychainAccountEncoded = encoder.code(keychainAccount)
        let keychainSecretEncoded = encoder.code(secret)

        switch (keychainAccountEncoded, keychainSecretEncoded) {
        case (.success(let userData), .success(let secretData)):
            let result = keychain.save(userData: userData, uuid: keychainID, secretData: secretData)
            switch result {
            case .success:
                retriveAccounts()
            case .failure(let error):
                print("\(AccountsError.savingError): \(error)")
            }
        case (_, _):
            print(AccountsError.encodingError)
        }
    }

    func remove(account: Account) {
        let result = keychain.remove(at: account.persistentRef)
        switch result {
        case .success:
            retriveAccounts()
        case .failure(let error):
            print("\(AccountsError.removalError): \(error)")
        }
    }
}

fileprivate extension KeychainCore {
    var accounts: [UUID: Account] {
        switch retriveRawData() {
        case .success(let accounts):
            return accounts.reduce([UUID: Account]()) { result, keychainData -> [UUID: Account] in
                var result = result
                if let userData = keychainData[kSecAttrGeneric as String] as? UserData,
                   let secretData = keychainData[kSecValueData as String] as? SecretData,
                   let persistentRef = keychainData[kSecValuePersistentRef as String] as? PersistentRef,
                   let account = Account(userData: userData, secretData: secretData, persistentRef: persistentRef) {
                    result[account.id] = account
                }
                return result
            }
        case .failure(let error):
            print("Keychain.retrieveAccounts() error: \(error)")
            return [UUID: Account]()
        }
    }
}

fileprivate extension JSONEncoder {
    func code<T>(_ value: T) -> Result<Data, Error> where T: Encodable {
        do {
            let data = try self.encode(value)
            return .success(data)
        } catch let error {
            print("Encode failed: `\(error)`")
            return .failure(AccountsError.encodingError)
        }
    }
}
