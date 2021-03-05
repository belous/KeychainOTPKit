import Foundation

public struct KeychainOTPKit {

    public enum KeychainCaretakerError: Error {
        case retrivingError
        case readingError
        case creatingError
        case removingError
    }

    private let keychain: Storable

    public init(with keychain: Storable) {
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
            case .genericError, .noData, .readingError:
                return .failure(KeychainCaretakerError.retrivingError)
            case .notFound:
                return .success([])
            }
        }
    }

    private func extractAccount(from storableData: StorableData) -> Result<Account, KeychainCaretakerError> {
        let userDataDecoded = decoder.decode(storableData.userData, KeychainAccount.self)
        let secretDataDecoded = decoder.decode(storableData.secretData, Secret.self)
        switch (userDataDecoded, secretDataDecoded) {
        case (.success(let keychainAccount), .success(let secret)):
            return .success(Account(from: keychainAccount, secret: secret, persistentRef: storableData.persistentRef))
        case (_, _):
            return .failure(KeychainCaretakerError.readingError)
        }

    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

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

fileprivate extension JSONDecoder {
    func decode<T>(_ data: Data, _ type: T.Type) -> Result<T, Error> where T: Decodable {
        do {
            let result = try self.decode(type.self, from: data)
            return .success(result)
        } catch let error {
            print("Decode failed: `\(error)`")
            return .failure(KeychainOTPKitError.decodingError)
        }
    }
}

extension Account {
    init(from keychainAccount: KeychainAccount, secret: Secret, persistentRef: PersistentRef) {
        self.init(issuer: keychainAccount.issuer, label: keychainAccount.label, secret: secret, id: keychainAccount.id, persistentRef: persistentRef)
    }
}
