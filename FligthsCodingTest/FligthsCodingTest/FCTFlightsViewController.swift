//
//  FCTFlightsViewController.swift
//  FligthsCodingTest
//
//  Created by jose humberto partida garduño on 3/28/17.
//  Copyright © 2017 jose humberto partida garduño. All rights reserved.
//

import UIKit

class FCTFlightsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var resultsTableView: UITableView!
    var data:[Any] = []
    var objectManagedData:[NSManagedObject] = []
    let cellIdentifier = "Cell"
    var openFromDelegate = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,from isAppDelegate:Bool){
        self.init(nibName: nibNameOrNil,bundle: nibBundleOrNil)
        self.openFromDelegate = isAppDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        // Do any additional setup after loading the view.
        FCTStorageManager.sharedInstance.goToFlights = true
        if self.openFromDelegate{
            if let fetchedData = FCTStorageManager.sharedInstance.fetchEntities(name: "Flight"){
                objectManagedData = fetchedData
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.openFromDelegate{
            self.openFromDelegate = false
            self.resultsTableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //if self.navigationController?.viewControllers.index(of: self) == NSNotFound{
        //    FCTStorageManager.sharedInstance.delete(entities: "Flight")
        //}
        
    }
    
    func saveData(){
        for item in data{
            let flight = item as! NSDictionary
            let number = flight.value(forKey: "FltId") as! String
            let originAirport = flight.value(forKey: "Orig") as! String
            let arrivalTime = flight.value(forKey: "SchedArrTime") as! String
            let dateTime = getFlightDate(from: arrivalTime)
            let (date,time) = dateTime
            if let entity = FCTStorageManager.sharedInstance.create(entity: "Flight", with: ["number":number,"origin":originAirport,"arrivalDate":date,"arrivalTime":time]){
              objectManagedData.append(entity)
            }
        }
        FCTStorageManager.sharedInstance.save()
        
    }
    
    func setupNavigationBar(){
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action:#selector(backButtonAction))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func setupTableView()
    {
        self.resultsTableView.register(UINib(nibName:"FCTFlightCellTableViewCell",bundle:nil),forCellReuseIdentifier: cellIdentifier)
    }
    
    func backButtonAction(){
        FCTStorageManager.sharedInstance.delete(entities: "Flight")
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectManagedData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FCTFlightCellTableViewCell
        let flight = objectManagedData[indexPath.row] as! Flight
        cell.flightNumber.text = flight.number
        cell.originAirport.text = flight.origin
        cell.arrivalDate.text = flight.arrivalDate
        cell.arrivalTime.text = flight.arrivalTime
        return cell
        
    }
    
    func getFlightDate(from schedArrTime:String) -> (String,String){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let date = dateFormatter.date(from: schedArrTime)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: date!)
        return (String(format:"%02d/%02d/%d",components.month!,components.day!,components.year!),String(format:"%02d:%02d",components.hour!,components.minute!))
        ///let components = NSCalendar.currentCalendar.com
    }
}
