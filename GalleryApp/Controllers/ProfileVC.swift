//
//  ProfileVC.swift
//  GalleryApp
//
//  Created by Harsh Sangani on 31/12/25.
//

import UIKit

class ProfileVC: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnLogout: UIButton!
    
    //----------------------------------------------------------------------------------------------
    
    //MARK: - Custom Variable
    
    //-----------------------------------------------------------------------------------------------
    
    //MARK: - Custom Methods
    
    func setUp() {
        self.applyTheme()
    }
    
    func applyTheme() {
        self.btnLogout.backgroundColor = .white
        self.btnLogout.layer.cornerRadius = 14

           // Shadow
        self.btnLogout.layer.shadowColor = UIColor.black.cgColor
        self.btnLogout.layer.shadowOpacity = 0.15
        self.btnLogout.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.btnLogout.layer.shadowRadius = 8

           // IMPORTANT: allow shadow
        self.btnLogout.layer.masksToBounds = false
        
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.height / 2
        self.imgProfile.clipsToBounds = true
        
        let user = UserSession.shared
        self.lblName.text = user.fullName
        self.lblEmail.text = user.email
        self.imgProfile.setImageFromURL(user.profileImage ?? "")
    }
    
    //----------------------------------------------------------------------------------------------
    
    //MARK: - Actions
    
    @IBAction func btnLogoutClicked(_ sender: Any) {
        UserSession.shared.logout()
        UserDefaultsConfig.isAuthorization = false
        UIApplication.shared.manageLogin()
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
    }
    
    //----------------------------------------------------------------------------------------------
}

//MARK: - Extensions

//----------------------------------------------------------------------------------------------

