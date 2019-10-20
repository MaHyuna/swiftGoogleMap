//
//  GoogleMapViewController.swift
//  MyGoogleMap
//
//  Created by maro on 28/09/2019.
//  Copyright © 2019 마현아. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation     // GPS를 이용하여 현재위치를 가져옴

class GoogleMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    var mapView: GMSMapView!
    var marker = GMSMarker()
    let locationManager = CLLocationManager()
    let geocoder = GMSGeocoder()        // GPS좌표(위도, 경도), 행정주소 Geocoder로 가져옴

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMapView()
        initLocationManager()
    }
    
    // MARK: - 구글맵뷰 초기화
    func initMapView() {
        mapView = GMSMapView()
        // 화면의 일부분의 뷰를 camera라고 함
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 15)
        
        mapView.camera = camera
        
        // 내 위치 동그란 표시여부
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        self.view = mapView
        
    }
    
    // MARK: - GPS 초기화
    func initLocationManager() {
        // GPS 정확도
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        // GPS 사용할 때만 위치정보를 사용한다는 팝업 발생
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - 위치가 업데이트될 때마다 호출됨
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coor = manager.location?.coordinate {
            print( "위도: " + String(coor.latitude) + "경도" + String(coor.longitude) )
            
            let camera = GMSCameraPosition.camera(withLatitude: coor.latitude, longitude: coor.longitude, zoom: 15)
            
            mapView?.camera = camera
            mapView?.animate(to: camera)    // 스무스하게 이동
            
        }
    }
    
    // MARK: - 드래그했을 때 지도 중심점 바뀜
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        // 맵 초기화
        mapView.clear()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        // 지오코드로 행정주소 구하기
        geocoder.reverseGeocodeCoordinate(position.target) {
            (response, error) in
            guard error == nil else {
                return
            }
            
            if let result = response?.firstResult() {
                let marker = GMSMarker()
                
                marker.position = position.target
                marker.title = "우리집"
                marker.snippet = result.lines?[0]   // 주소
                marker.map = mapView
            }
        }
    }
}
