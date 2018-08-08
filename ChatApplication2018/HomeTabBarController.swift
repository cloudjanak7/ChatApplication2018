//
//  HomeTabBarController.swift
//  ChatApplication2018
//
//  Created by Thomas McGarry on 03/06/2018.
//  Copyright © 2018 Thomas McGarry. All rights reserved.
//

import UIKit
import XMPPFramework
import SwiftKeychainWrapper

class HomeTabBarController: UITabBarController {
    
    weak var loginViewController: LoginViewController?
    var chatsViewController: ChatsViewController?
    var xmppController: XMPPController?
    var loggedIn = false
    var count = 0
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginView" {
            let viewController = segue.destination as! LoginViewController
            viewController.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let retrievedPassword: String? = KeychainWrapper.standard.string(forKey: "userPassword")
        let retrievedUserName: String? = KeychainWrapper.standard.string(forKey: "userName")
        
        if retrievedPassword == nil && retrievedUserName == nil && !loggedIn {
            //bring up log in page
            self.performSegue(withIdentifier: "loginView", sender: nil)
        } else if !loggedIn {
            //login with stored credentials
            autoLogIn(userJID: retrievedUserName!, userPassword: retrievedPassword!)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("HTBC will disappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("HTBC did disappear")
    }
    
    func autoLogIn(userJID: String, userPassword: String) {
        do {
            //need to reconfigure so that I am not sending the host name every time
            //May also be issues with userJID - full or with domain?
            //Also, duplicated code
            count = 6
            try self.xmppController = XMPPController(userJIDString: userJID,
                                                     password: userPassword)
            //init(hostName: String, userJIDString: String, hostPort: UInt16 = 5222, password: String)
            self.xmppController?.xmppStream?.addDelegate(self, delegateQueue: DispatchQueue.main)
            self.xmppController?.connect()
            
            print("Automatically logged in with saved credentials")
        } catch {
            //need to show an error message to the user, below is just for testing
            print("something went wrong")
        }
        loggedIn = true
        NotificationCenter.default.post(name: .loggedIn, object: nil)
    }

}

extension HomeTabBarController: LoginViewControllerDelegate {
    
    func didTouchLogIn(sender: LoginViewController, userJID: String, userPassword: String) {
        //Test
        print("got here1")
        self.loginViewController = sender
        //Test
        print("got here2")
        do {
            count = 3
            try self.xmppController = XMPPController(userJIDString: userJID,
                                                     password: userPassword)
            print("where am i?")
            self.xmppController?.xmppStream?.addDelegate(self, delegateQueue: DispatchQueue.main)
            print("got here9b")
            self.xmppController?.connect()
            
            print("Logged in with new credentials")
        } catch {
            sender.showErrorMessage(message: "Something went wrong")
        }
        loggedIn = true
        NotificationCenter.default.post(name: .loggedIn, object: nil)
    }
}

extension HomeTabBarController: XMPPStreamDelegate {
    
    //if login details are authenticated, the LoginViewController view is dismissed - if it exists
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        self.loginViewController?.dismiss(animated: true, completion: nil)
        
        //Alert ChatsViewController that the stream is authenticated so can begin populating chatList
        //chatsViewController = self.viewControllers![0] as! ChatsViewController
        //chatsViewController?.authenticated = true
        NotificationCenter.default.post(name: .streamAuthenticated, object: nil)
    }
    
    func xmppStream(_ sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        self.loginViewController?.showErrorMessage(message: "Wrong password or username")
    }
    
}

protocol HomeTabBarControllerDelegate: class {
    func didTouchLogIn(sender: LoginViewController, userJID: String, userPassword: String)

}

