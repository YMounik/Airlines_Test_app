//
//  ViewController.swift
//  AlaskaTest
//
//  Created by Kiran on 09/01/19.
//  Copyright © 2019 Kiran. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UINavigationControllerDelegate {
    @IBOutlet weak var txtFieldAirports: UITextField!
    @IBOutlet weak var tableViewFlightDetails: UITableView!
    @IBOutlet weak var lblMessage: UILabel!
    var timer: Timer!

    var airportsArray : [String] = []
    let defaults = UserDefaults.standard
    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    var inputArray : [[String : Any]]?
    var flightDetailsArray : [FlightDetails] = []
    var searchedAirportString : String = ""

    let dataManager = DataManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshData()
        airportsArray = defaults.value(forKey: "airports") as? [String] ?? []

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setUpBaseView() {
        
        flightDetailsArray = dataManager.fetchFlightDetails()
        if flightDetailsArray.count > 0{
            self.setHomeView(value: false)
            self.tableViewFlightDetails.reloadData()
        }else{
            self.setHomeView(value: true)
        }
    }
    
    @objc func refreshData(){
        dataManager.remove10MinOldData()
        self.setUpBaseView()
        timer = Timer.scheduledTimer(timeInterval: 600.0, target: self, selector:  #selector(refreshData), userInfo: nil, repeats: true)
    }

    
    // fetching flight details information
    func fetchFlightDetails(_ urlString:String){

        NetworkManager.fetchFlightDetailsResponse(urlString) { (status, responseArray) in
            if status{
                print(responseArray)
                self.inputArray = responseArray
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.saveFlightDetails()
                }
            }else{
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                self.showAlertMessage(message: "Invalid input or Error Response")
            }
        }
    }
    
    @IBAction func btnSearchTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)

        if txtFieldAirports.text?.count == 3 {
            searchedAirportString = txtFieldAirports.text!
            airportsArray.append(searchedAirportString)
            defaults.set(airportsArray, forKey: "airports")
            self.addLoader()
            let urlString = String(format: "https://api.qa.alaskaair.net/aag/1/dayoftravel/airports/%@/flights/flightInfo?minutesBefore=10&minutesAfter=120", txtFieldAirports.text ?? "")
            self.fetchFlightDetails(urlString)
        }else{
            txtFieldAirports.layer.borderColor = UIColor.red.cgColor
            txtFieldAirports.layer.borderWidth = 1.0
            self.showAlertMessage(message: "Enter a valid airport code")
        }
        
    }
    
    func setHomeView(value : Bool)   {
        self.lblMessage.isHidden = !value
        self.tableViewFlightDetails.isHidden = value
    }
    
    //MARK:- Utilities
   
    func addLoader()  {
        activityIndicator.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2)
        activityIndicator.color = UIColor.black
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    // showing error message on failure response.
    func showAlertMessage(message : String)  {
        
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    // sorting - The list should show the flights arriving for the next hour, ordered by arrival time, with soonest at the top.
    
    func saveFlightDetails()  {
        
        
        if let responseArray = self.inputArray{
              dataManager.insertFlightDetails(responseArray as NSArray, searchedAirportString)
        }
      
        
        self.setUpBaseView()
        
    }
    
}



extension ViewController : UITableViewDataSource{
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.flightDetailsArray.count
    }
    
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ATFlightDetailsCell") as! ATFlightDetailsCell
        let flightDetail : FlightDetails = self.flightDetailsArray[indexPath.row]
        cell.lblFlightId.text = String(format:"FlightId : %@",flightDetail.flightId ?? "")
        cell.lblOrigin.text = String(format:"Origin : %@",flightDetail.origin ?? "")
        cell.lblArrivalTIme.text = String(format:"Arrival Time : %@",flightDetail.schArrivalTime ?? "")
        cell.lblCurrentTime.text = String(format:"Current time : %@",Utilities.getCurrentTime())
        
        if let estimated = flightDetail.estArrivalTime{
            let estimatedDateString : String = Utilities.getStringFromDate(estimated)
            cell.lblEstimatedArrival.text = String(format:"Est Arrival : %@", estimatedDateString)
        }
        cell.lblairport.text = String(format:"Your Airport : %@",flightDetail.airport ?? "")

        return cell
    }
}

extension ViewController : UITextFieldDelegate{
    // restricting the user to enter three characters of maximum as airport code is a three character string
     public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool // return NO to not change text
    {
        txtFieldAirports.layer.borderColor = UIColor.black.cgColor
        txtFieldAirports.layer.borderWidth = 1.0
        
        
        if string == " " {
            return false
        }
        
        let userEnteredString = textField.text
        
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as NSString


        if newString.length > 3 {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        airportsArray = defaults.value(forKey: "airports") as? [String] ?? []
        if  airportsArray.count > 0 {
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let popoverController = storyBoard.instantiateViewController(withIdentifier: "RecentAirportsPopover") as! RecentAirportsPopover
            popoverController.delegate = self
            popoverController.inputArray = Array(Set(airportsArray)) as NSArray
            popoverController.modalPresentationStyle = .popover
            let popover = popoverController.popoverPresentationController
            popover?.delegate = self
            popover?.sourceView = textField
            popover?.sourceRect = textField.bounds
            popover?.permittedArrowDirections = .any
            self.present(popoverController, animated: true, completion: nil)
        }
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }

}

extension ViewController : SelectedAirportDelegate {
    func selectedAirportFromRecentSearches(_ airportCode: String) {
        txtFieldAirports.text = airportCode

    }
}

extension ViewController : UIPopoverPresentationControllerDelegate{
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle{
        return UIModalPresentationStyle.none
        
    }

}
