//
//  AppKeychain.swift
//  FaceIDDemo
//
//  Created by Casey Hanley on 11/14/20.
//

import Foundation

class AppKeychain {
    static let account = "FaceIDDemo2"
    
    static func getValue(for service: String) -> String {
        if let value = try? getGenericPasswordFor(
            account: account,
            service: service) {
            return value
        }
        return ""
    }
    
    static func updateValue(for service: String, with value: String) {
        do {
            try storeGenericPasswordFor(
                account: account,
                service: service,
                password: value)
        } catch let error as AppKeychainError {
            print("Exception setting credentials: \(error.message ?? "no message")")
        } catch {
            print("Unknown error setting credentials")
        }
    }
    
    static private func storeGenericPasswordFor(
        account: String,
        service: String,
        password: String
    ) throws {
        if password.isEmpty {
            try deleteGenericPasswordFor(account: account, service: service)
            return
        }
        
        guard let passwordData = password.data(using: .utf8) else {
            print("error converting value to data")
            throw AppKeychainError(type: .badData)
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecValueData as String: passwordData
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            break
        case errSecDuplicateItem:
            try updateGenericPasswordFor(account: account, service: service, password: password)
        default:
            throw AppKeychainError(status: status, type: .servicesError)
        }
    }
    
    static private func getGenericPasswordFor(
        account: String,
        service: String
    ) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            throw AppKeychainError(type: .itemNotFound)
        }
        guard status == errSecSuccess else {
            throw AppKeychainError(status: status, type: .servicesError)
        }
        
        guard
            let existingItem = item as? [String: Any],
            let valueData = existingItem[kSecValueData as String] as? Data,
            let value = String(data: valueData, encoding: .utf8)
        else {
            throw AppKeychainError(type: .unableToConvertToString)
        }
        
        return value
    }
    
    static private func updateGenericPasswordFor(
        account: String,
        service: String,
        password: String
    ) throws {
        guard let passwordData = password.data(using: .utf8) else {
            print("Error converting value to data.")
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: passwordData
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecItemNotFound else {
            throw AppKeychainError(
                message: "Matching Item Not Found",
                type: .itemNotFound)
        }
        guard status == errSecSuccess else {
            throw AppKeychainError(status: status, type: .servicesError)
        }
    }
    
    static private func deleteGenericPasswordFor(account: String, service: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AppKeychainError(status: status, type: .servicesError)
        }
    }
}

struct AppKeychainError: Error {
    var message: String?
    var type: KeychainErrorType
    
    enum KeychainErrorType {
        case badData
        case servicesError
        case itemNotFound
        case unableToConvertToString
    }
    
    init(status: OSStatus, type: KeychainErrorType) {
        self.type = type
        if let errorMessage = SecCopyErrorMessageString(status, nil) {
            self.message = String(errorMessage)
        } else {
            self.message = "Status Code: \(status)"
        }
    }
    
    init(type: KeychainErrorType) {
        self.type = type
    }
    
    init(message: String, type: KeychainErrorType) {
        self.message = message
        self.type = type
    }
}
