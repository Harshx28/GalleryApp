//
//  SocialLoginManager.swift
//  GalleryApp
//
//  Created by Harsh Sangani on 31/12/25.
//

import Foundation
import AuthenticationServices
import GoogleSignIn

struct SocialLoginDataModel {

    init() {

    }

    var socialId: String!
    var login_type: String!
    var first_name: String!
    var last_Name: String!
    var email: String!
    var profileImage: String?
    var fullname: String?
    var birthdate: String?
}

protocol SocialLoginDelegate: AnyObject {
    func socialLoginData(data: SocialLoginDataModel)
}

class SocialLoginManager: UIViewController {

    //MARK: Class Variable
    static let shared: SocialLoginManager = SocialLoginManager()
    weak var delegate: SocialLoginDelegate? = nil

   
}

extension SocialLoginManager {

    func performGoogleLogin() {

        guard let topVC = UIApplication.topViewController() else {
            print("No presenting view controller")
            return
        }

        // Optional: force account chooser
        GIDSignIn.sharedInstance.signOut()

        GIDSignIn.sharedInstance.signIn(
            withPresenting: topVC
        ) { [weak self] result, error in

            guard let self = self else { return }

            if let error = error {
                print("Google Sign-In failed:", error.localizedDescription)
                return
            }

            guard let result = result else {
                print("No result returned")
                return
            }

            let user = result.user

            var dataObj = SocialLoginDataModel()
            dataObj.login_type = "google"
            dataObj.socialId = user.userID
            dataObj.email = user.profile?.email
            dataObj.first_name = user.profile?.givenName
            dataObj.last_Name = user.profile?.familyName
            dataObj.fullname = user.profile?.name

            if user.profile?.hasImage == true {
                dataObj.profileImage =
                    user.profile?.imageURL(withDimension: 200)?.absoluteString
            }

            self.delegate?.socialLoginData(data: dataObj)
        }
    }
}

//MARK: Google login delegate
//extension SocialLoginManager : GIDSignInDelegate{
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if let error = error {
//            print(error.localizedDescription)
//
//        } else {
//            //Call delegate
//            if let delegate = self.delegate {
//
//                var dataObj: SocialLoginDataModel = SocialLoginDataModel()
//                dataObj.socialId = user.userID
//                dataObj.first_name = user.profile.givenName
//                dataObj.last_Name = user.profile.familyName
//                dataObj.email = user.profile.email
//                if user.profile.hasImage {
//                    dataObj.profileImage = user.profile.imageURL(withDimension: 100)?.description
//                }
//
//                delegate.socialLoginData(data: dataObj)
//            }
//        }
//    }
//}
