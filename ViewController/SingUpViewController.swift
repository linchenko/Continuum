//
//  SingUpViewController.swift
//  Continuum
//
//  Created by Levi Linchenko on 27/09/2018.
//  Copyright © 2018 Levi Linchenko. All rights reserved.
//

import UIKit

class SingUpViewController: UIViewController {
    
    @IBOutlet weak var enterUsername: UITextField!
    @IBOutlet weak var enterEmail: UITextField!
    @IBOutlet weak var enterPassword: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func signUpTapped(_ sender: Any) {
    }
    
}
