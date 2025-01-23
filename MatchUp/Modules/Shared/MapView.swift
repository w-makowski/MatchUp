//
//  MapView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 14/01/2025.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    var onLocationSelected: (CLLocationCoordinate2D) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.mapTapped(_:)))
        
        mapView.addGestureRecognizer(tapGesture)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let location = selectedLocation {
            uiView.removeAnnotations(uiView.annotations)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            uiView.addAnnotation(annotation)
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        @objc func mapTapped(_ sender: UITapGestureRecognizer) {
            let locationInView = sender.location(in: sender.view as? MKMapView)
            guard let mapView = sender.view as? MKMapView else { return }
            let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            parent.selectedLocation = coordinate
            parent.onLocationSelected(coordinate)
        }
    }
}

#Preview {
    //MapView()
}
