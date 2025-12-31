//
//  UserSession.swift
//  GalleryApp
//
//  Created by Harsh Sangani on 2025-12-31.
//

import Foundation

final class UserSession {

    static let shared = UserSession()
    private init() {
        loadFromDefaults()
    }

    // MARK: - Keys
    private let kIsLoggedIn   = "isLoggedIn"
    private let kSocialId    = "socialId"
    private let kFirstName   = "firstName"
    private let kLastName    = "lastName"
    private let kEmail       = "email"
    private let kLoginType   = "loginType"
    private let kProfileImage = "profileImage"

    // MARK: - Stored Properties
    var isLoggedIn: Bool = false
    var socialId: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var loginType: String?
    var profileImage: String?

    // MARK: - Save Session
    func save(data: SocialLoginDataModel) {
        isLoggedIn = true
        socialId = data.socialId
        firstName = data.first_name
        lastName = data.last_Name
        email = data.email
        loginType = data.login_type
        profileImage = data.profileImage

        saveToDefaults()
    }

    // MARK: - Save to UserDefaults
    private func saveToDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(isLoggedIn, forKey: kIsLoggedIn)
        defaults.set(socialId, forKey: kSocialId)
        defaults.set(firstName, forKey: kFirstName)
        defaults.set(lastName, forKey: kLastName)
        defaults.set(email, forKey: kEmail)
        defaults.set(loginType, forKey: kLoginType)
        defaults.set(profileImage, forKey: kProfileImage)
    }

    // MARK: - Load Session
    private func loadFromDefaults() {
        let defaults = UserDefaults.standard
        isLoggedIn = defaults.bool(forKey: kIsLoggedIn)
        socialId = defaults.string(forKey: kSocialId)
        firstName = defaults.string(forKey: kFirstName)
        lastName = defaults.string(forKey: kLastName)
        email = defaults.string(forKey: kEmail)
        loginType = defaults.string(forKey: kLoginType)
        profileImage = defaults.string(forKey: kProfileImage)
    }

    // MARK: - Logout
    func logout() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: kIsLoggedIn)
        defaults.removeObject(forKey: kSocialId)
        defaults.removeObject(forKey: kFirstName)
        defaults.removeObject(forKey: kLastName)
        defaults.removeObject(forKey: kEmail)
        defaults.removeObject(forKey: kLoginType)
        defaults.removeObject(forKey: kProfileImage)

        isLoggedIn = false
        socialId = nil
        firstName = nil
        lastName = nil
        email = nil
        loginType = nil
        profileImage = nil
    }

    // MARK: - Convenience
    var fullName: String {
        return "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespaces)
    }
}
