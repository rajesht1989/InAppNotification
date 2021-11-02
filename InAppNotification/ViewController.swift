//
//  ViewController.swift
//  InAppNotification
//
//  Created by Rajesh Thangaraj on 02/11/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!

    @IBAction func showAction(_ sender: Any) {
        InAppNotification.show(message: textField.text ?? "No text entered")
    }
    
}

