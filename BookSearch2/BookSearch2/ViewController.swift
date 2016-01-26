//
//  ViewController.swift
//  BookSearch
//
//  Created by Dev on 11/25/15.
//  Copyright © 2015 Dev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtISBN: UITextField!
    
    @IBOutlet weak var lblTitulo: UILabel!
    
    @IBOutlet weak var lblAutores: UILabel!
    
    @IBOutlet weak var imgPortada: UIImageView!
    
    
    @IBOutlet weak var lblError: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtISBN.delegate = self
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.lblError.text = ""
        self.lblAutores.text = ""
        self.lblTitulo.text = ""
        self.imgPortada.image = nil
        
        let value = textField.text
        
        if  (value != nil && value != ""){
        
            self.view.makeToastActivity()
            let isbn = value!
            let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(isbn)"
            let url = NSURL(string: urls)!
            let session = NSURLSession.sharedSession()
            

            let task = session.dataTaskWithURL(url, completionHandler: {data, response, error in
                dispatch_async(dispatch_get_main_queue(), {
                    self.view.hideToastActivity()
                    
                    
                    if error != nil {
                        self.lblError.text = "Problemas con Internet"
                        self.view.makeToast(message: "Problemas con Internet")
                    }
                    else if data == nil {
                        self.lblError.text = "No se encontraron datos"
                        self.view.makeToast(message: "No se encontraron datos")
                    }
                    else {
                        
                        do {
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves)
                            let dict = json as! NSDictionary
                            if let book = dict["ISBN:\(isbn)"] as? NSDictionary {
                            
                            
                                self.lblTitulo.text = book["title"] as? String
                                
                                let autores = book["authors"] as! NSArray
                                var autoresStr = ""
                                for autor in autores {
                                    let autorDict = autor as! NSDictionary
                                    let nombre = autorDict["name"] as! String
                                    autoresStr += "\(nombre), "
                                }
                                autoresStr = autoresStr.substringWithRange(Range<String.Index>(start: autoresStr.startIndex, end: autoresStr.endIndex.advancedBy(-2)))
                                self.lblAutores.text = autoresStr
                                
                                let cover = book["cover"] as! NSDictionary?
                                if cover != nil {
                                    let coverUrlStr = cover!["large"] as! String
                                    let coverUrl = NSURL(string: coverUrlStr)
                                    if let img = NSData(contentsOfURL: coverUrl!) {
                                        self.imgPortada.image = UIImage(data: img)
                                    }
                                    else {
                                        self.imgPortada.image = nil
                                    }
                                }
                                else {
                                    self.imgPortada.image = nil
                                }
                            
                            }
                            else {
                                self.lblError.text = "No se encontraron datos"
                                self.view.makeToast(message: "No se encontraron datos")
                            }
                        }
                        catch _ {
                            
                        }
                    }
                    textField.resignFirstResponder()
                })
            })
            task.resume()
            return true
        }
        else {
            self.view.makeToast(message: "Debe introducir una ISBN")
            return false
        }
    }

}

