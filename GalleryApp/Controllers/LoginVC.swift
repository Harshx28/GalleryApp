//
//  LoginVC.swift
//  GalleryApp
//
//  Created by Harsh Sangani on 2025-12-30.
//

import UIKit

class LoginVC: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var btnGoogle: UIButton!
    
    //----------------------------------------------------------------------------------------------
    
    //MARK: - Custom Variable
    
    private let socialLoginManager: SocialLoginManager = SocialLoginManager()
    
    //-----------------------------------------------------------------------------------------------
    
    
    //MARK: - Custom Methods

    func setUp() {
        self.applyTheme()
    }

    func applyTheme() {
        self.btnGoogle.layer.cornerRadius = self.btnGoogle.frame.height / 2
        self.btnGoogle.clipsToBounds = true
    }

    //----------------------------------------------------------------------------------------------
    
    //MARK: - Memory Management Method
    //==============================================================
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        debugPrint("‼️‼️‼️ deinit : \(self.classForCoder) ‼️‼️‼️")
    }

    //==============================================================
    
    //MARK: - View Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
        self.socialLoginManager.delegate = self
        // Do any additional setup after loading the view.
    }
    
    //----------------------------------------------------------------------------------------------
    
    //MARK: - Actions

    @IBAction func btnGoogleClicked(_ sender: Any) {
        self.socialLoginManager.performGoogleLogin()
        
//        UserDefaultsConfig.isAuthorization = true
//        UIApplication.shared.manageLogin()
    }
    
    //----------------------------------------------------------------------------------------------

}

    //DELEGATE METHOD:-

//MARK: - Social Login delegate method -

extension LoginVC: SocialLoginDelegate {
    
    func socialLoginData(data: SocialLoginDataModel) {
        
        print("Social Id==>", data.socialId ?? "")
        print("First Name==>", data.first_name ?? "")
        print("Last Name==>", data.last_Name ?? "")
        print("Email==>", data.email ?? "")
        print("Login type==>", data.login_type ?? "")
        print("profileImage==>", data.profileImage ?? "")
        
        UserSession.shared.save(data: data)
        
        UserDefaultsConfig.isAuthorization = true
        UIApplication.shared.manageLogin()
    }
}
