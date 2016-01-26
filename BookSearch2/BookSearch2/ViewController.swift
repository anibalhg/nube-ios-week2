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
        
        if let isbn = textField.text {
            
            let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(isbn)"
            let url = NSURL(string: urls)!
            let session = NSURLSession.sharedSession()

            let task = session.dataTaskWithURL(url, completionHandler: {data, response, error in
                dispatch_async(dispatch_get_main_queue(), {
                    if error != nil {
                        self.lblError.text = error!.localizedDescription
                    }
                    else if data == nil {
                        self.lblError.text = "No se encontraron datos"
                    }
                    else {
                        do {
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves)
                            let dict = json as! NSDictionary
                            let book = dict["ISBN:\(isbn)"] as! NSDictionary
                            
                            self.lblTitulo.text = book["title"] as! String
                            
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
                                let coverUrl = cover!["large"] as! String
                                let url = NSURL(string: coverUrl)
                                if let img = NSData(contentsOfURL: url!) {
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
            self.lblError.text = "Debe introducir una ISBN"
            return false
        }
    }

}

