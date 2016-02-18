//
//  SchoolMapViewCtrl.swift
//  NewTaipei
//
//  Created by Cloud on 11/11/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import Foundation
import MapKit

class SchoolMapViewCtrl: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var PhoneBtn: UIButton!
    @IBOutlet weak var MapBtn: UIButton!
    
    var BaseData : SchoolItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // 1
        var location : CLLocationCoordinate2D!
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(BaseData.Address, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            
            if error != nil{
                print(error)
                return
            }
            
            if let p = placemarks where p.count > 0{
                
                let placemark = p[0]
                location = placemark.location!.coordinate //取得經緯度的參數
                
                // 2
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegion(center: location, span: span)
                self.mapView.setRegion(region, animated: true)
                
                //3
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                annotation.title = self.BaseData.Alias
                annotation.subtitle = self.BaseData.Address
                self.mapView.addAnnotation(annotation)
                
                self.mapView.selectAnnotation(annotation, animated: true)
                
            }
            
        })
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if self.BaseData.Phone.isEmpty{
            PhoneBtn.enabled = false
        }
        
        if self.BaseData.Address.isEmpty{
            MapBtn.enabled = false
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        
        let identifier = "pin"
        var view: MKPinAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
        } else {
            // 3
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            //view.calloutOffset = CGPoint(x: -5, y: 5)
            //view.rightCalloutAccessoryView = MoreInfoBtn
        }
        
        return view
    }
    
    @IBAction func PhoneAction(sender: AnyObject) {
        DialNumber(self.BaseData.Phone)
    }
    
    @IBAction func MapAction(sender: AnyObject) {
        
        let alert = UIAlertController(title: "繼續？", message: "即將開啟Apple map", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (okaction) -> Void in
            GoogleMap(self.BaseData.Address)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
}
