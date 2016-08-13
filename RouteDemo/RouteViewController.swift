//
//  RouteViewController.swift
//  RouteDemo
//
//  Created by Simon Ng on 19/1/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import MapKit

class RouteViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView:MKMapView!
    
    private var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // implement gesture recognizer
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "pinLocation:")
        longPressGestureRecognizer.minimumPressDuration = 0.3
        mapView.addGestureRecognizer(longPressGestureRecognizer)
        
        mapView.delegate = self

    }
    
    func pinLocation(sender: UILongPressGestureRecognizer) {
        if sender.state != .Ended {
            return
        }
        
        // get the location of the touch
        
        let tappedPoint = sender.locationInView(mapView)
        
        // convert point to coordinate
        
        let tappedCoordinate = mapView.convertPoint(tappedPoint, toCoordinateFromView: mapView)
        
        // annotate on the map view
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = tappedCoordinate
        
        // store the annotation for later use
        
        annotations.append(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
    
    @IBAction func drawPolyline() {
        mapView.removeOverlays(mapView.overlays)
        
        var coordinates = [CLLocationCoordinate2D]()
        for annotation in annotations {
            coordinates.append(annotation.coordinate)
        }
        
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        let visibleMapRect = mapView.mapRectThatFits(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
        mapView.setRegion(MKCoordinateRegionForMapRect(visibleMapRect), animated: true)
        
        mapView.addOverlay(polyline)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 3.0
        renderer.strokeColor = UIColor.purpleColor()
        renderer.alpha = 0.5
        
        return renderer
    }
    
    func drawDirection(startPoint: CLLocationCoordinate2D, endPoint: CLLocationCoordinate2D) {
        // create map items from coordinate
        
        let startPlacemark = MKPlacemark(coordinate: startPoint, addressDictionary: nil)
        let endPlacemark = MKPlacemark(coordinate: endPoint, addressDictionary: nil)
        let startMapItem = MKMapItem(placemark: startPlacemark)
        let endMapItem = MKMapItem(placemark: endPlacemark)
        
        // set the source and destination of the route
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = startMapItem
        directionRequest.destination = endMapItem
        directionRequest.transportType = .Automobile
        
        // calculate the directions
        
        let directions = MKDirections(request: directionRequest)
        directions.calculateDirectionsWithCompletionHandler { (routeResponse, routeError) -> Void in
            guard let routeResponse = routeResponse else {
                if let routeError = routeError {
                    print("Error: \(routeError)")
                }
                
                return
            }
            
            let route = routeResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
        }
    }
    
    @IBAction func drawRoute() {
        mapView.removeOverlays(mapView.overlays)
        
        var coordinates = [CLLocationCoordinate2D]()
        for annotation in annotations {
            coordinates.append(annotation.coordinate)
        }
        
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        let visibleMapRect = mapView.mapRectThatFits(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
        self.mapView.setRegion(MKCoordinateRegionForMapRect(visibleMapRect), animated: true)
        
        var index = 0
        while index < annotations.count - 1 {
            drawDirection(annotations[index].coordinate, endPoint: annotations[index + 1].coordinate)
            index += 1
        }
    }
    
    @IBAction func removeAnnotations() {
        // remove annotations and overlays
        
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(annotations)
        
        // clear the annotation array
        
        annotations.removeAll()
    }
    
    // MARK: - Delegate Methods
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        let annotationView = views[0]
        let endFrame = annotationView.frame
        annotationView.frame = CGRectOffset(endFrame, 0, -600)
        UIView.animateWithDuration(0.3) { () -> Void in
            annotationView.frame = endFrame

        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
