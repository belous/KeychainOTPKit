import Foundation

public struct KeychainOTPKit {

    public enum KeychainCaretakerError: Error {
        case retrivingError
        case readingError
        case creatingError
        case removingError
    }

    private let keychain: KeychainCore

    public init(with keychain: KeychainCore) {
        self.keychain = keychain
    }

    public func retriveAccounts() -> Result<[Account], KeychainCaretakerError> {
        let keychainRawAccounts = keychain.retriveRawData()
        switch keychainRawAccounts {
        case .success(let keychainRawData):
            do {
                let result: [Account] = try keychainRawData.map(extractAccount).map { item in
                    switch item {
                    case .success(let account):
                        return account
                    case .failure(let error):
                        throw error
                    }
                }
                return .success(result)
            } catch {
                return .failure(KeychainCaretakerError.retrivingError)
            }
        case .failure(let error):
            switch error {
            case .genericError, .noData:
                return .failure(KeychainCaretakerError.retrivingError)
            case .notFound:
                return .success([])
            }
        }
    }

    private func extractAccount(from rawData: KeychainRawData) -> Result<Account, KeychainCaretakerError> {
        if let userData = rawData[kSecAttrGeneric as String] as? UserData,
           let secretData = rawData[kSecValueData as String] as? SecretData,
           let persistentRef = rawData[kSecValuePersistentRef as String] as? PersistentRef,
           // TODO: Moved decoding from Account to this Caretaker
           let account = Account(userData: userData, secretData: secretData, persistentRef: persistentRef) {
            return .success(account)
        } else {
            return .failure(KeychainCaretakerError.readingError)
        }
    }

    private let encoder = JSONEncoder()

    public func addNewAccount(keychainAccount: KeychainAccount, secret: Secret) -> Result<Void, KeychainCaretakerError> {
        let keychainID = keychainAccount.id
        let keychainAccountEncoded = encoder.code(keychainAccount)
        let keychainSecretEncoded = encoder.code(secret)

        switch (keychainAccountEncoded, keychainSecretEncoded) {
        case (.success(let userData), .success(let secretData)):
            let result = keychain.save(userData: userData, uuid: keychainID, secretData: secretData)
            switch result {
            case .success:
                return .success(())
            case .failure:
                return .failure(KeychainCaretakerError.creatingError)
            }
        case (_, _):
            return .failure(KeychainCaretakerError.creatingError)
        }
    }

    public func remove(account: Account) -> Result<Void, KeychainCaretakerError> {
        let result = keychain.remove(at: account.persistentRef)
        switch result {
        case .success:
            return .success(())
        case .failure:
            return .failure(KeychainCaretakerError.removingError)
        }
    }

}

enum KeychainOTPKitError: Error {
    case encodingError
    case decodingError
    case savingError
    case removalError
}

fileprivate extension JSONEncoder {
    func code<T>(_ value: T) -> Result<Data, Error> where T: Encodable {
        do {
            let data = try self.encode(value)
            return .success(data)
        } catch let error {
            print("Encode failed: `\(error)`")
            return .failure(KeychainOTPKitError.encodingError)
        }
    }
}
