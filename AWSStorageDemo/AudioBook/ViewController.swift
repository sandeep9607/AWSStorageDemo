//
//  ViewController.swift
//  AudioBook
//
//  Created by rootmacmini on 20/08/19.
//  Copyright © 2019 rootmacmini. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSS3
import AWSCognito

class ViewController: UIViewController {

    @IBOutlet weak var tblAudioFiles: UITableView!
    var arrAudioBooks = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblAudioFiles.delegate = self
        tblAudioFiles.dataSource = self
        
        listOblects()
    }
    
    func listOblects(){
        
                let myIdentityPoolId = "us-east-2:b39bd302-8793-4595-bfdb-c2a51f585c22"
                let credentialsProvider:AWSCognitoCredentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast2, identityPoolId: myIdentityPoolId)
                let configuration = AWSServiceConfiguration(region: .USEast2, credentialsProvider:credentialsProvider)
                AWSServiceManager.default().defaultServiceConfiguration = configuration
        
                AWSS3.register(with: configuration!, forKey: "defaultKey")
                let s3 = AWSS3.s3(forKey: "defaultKey")
        
                let listRequest: AWSS3ListObjectsRequest = AWSS3ListObjectsRequest()
                listRequest.bucket = "audiobook198-ios"
                s3.listObjects(listRequest).continueWith { (task) -> AnyObject? in
//                    print("call returned")
                    
                    guard let listObjectsOutput = task.result else{
                        return nil
                    }
                    
                    print(listObjectsOutput)
        
                    for object in (listObjectsOutput.contents)! {
//                        print(object.key!)
                        self.arrAudioBooks.append(object.key!)
//                        let file = self.removeFileExtension(filename: object.key!)
                    }
                    DispatchQueue.main.async {
                        self.tblAudioFiles.reloadData()
                    }
                    
                    return nil
                }
       

    }

}
extension ViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAudioBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblAudioFiles.dequeueReusableCell(withIdentifier: "audioCell")
        cell?.textLabel?.text = arrAudioBooks[indexPath.row].removeFileExtension()
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PlayAudioVC") as! PlayAudioVC
        vc.strFilename = arrAudioBooks[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension String{
    func removeFileExtension() -> String{
        let fileName = self
        var components = fileName.components(separatedBy: ".")
        if components.count > 1 { // If there is a file extension
            components.removeLast()
            return components.joined(separator: ".")
        } else {
            return fileName
        }
    }
}

