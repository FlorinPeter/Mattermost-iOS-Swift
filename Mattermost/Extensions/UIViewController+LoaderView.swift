//
//  UIViewController+LoaderView.swift
//  Mattermost
//
//  Created by Владислав on 06.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

let loadetViewTag = 1812

protocol LoaderView{
    func showLoaderView(topOffset: CGFloat, bottomOffset: CGFloat)
    func hideLoaderView()
}

extension UIViewController: LoaderView {
    func addedLoaderView() -> NVActivityIndicatorView? {
        let loaderView = UIApplication.shared.keyWindow?.viewWithTag(loadetViewTag)
        guard loaderView != nil else { return nil }
        let activityIndicator = loaderView?.subviews.first
        guard (activityIndicator?.isKind(of: NVActivityIndicatorView.self))! else { return nil }
        return activityIndicator as! NVActivityIndicatorView?
    }
    
    func showLoaderView(topOffset: CGFloat, bottomOffset: CGFloat) {
        let activityIndicator = self.addedLoaderView()
        guard activityIndicator == nil else { return }
        
        let screenSize = UIScreen.main.bounds
        //let y = UserStatusManager.sharedInstance.isSignedIn() ? 0 : UIApplication.shared.statusBarFrame.height
        let loader = UIView.init(frame: CGRect(x: 0,
                                               y: topOffset,
                                               width: screenSize.width,
                                               height: screenSize.height-topOffset-bottomOffset))
        loader.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        
        let frame = CGRect(x: (screenSize.width-screenSize.width/7)/2,
                           y: (screenSize.height-topOffset-bottomOffset-screenSize.height*1.25/7)/2,
                           width: screenSize.width/7,
                           height: screenSize.height/7)
        
        let color = UIColor.kg_blueColor()
        let spinner = NVActivityIndicatorView(frame: frame, type: .ballPulse, color: color, padding: 0.0)
        loader.addSubview(spinner)
        spinner.startAnimating()
        loader.tag = loadetViewTag
        self.view.addSubview(loader)
    }
    
    func showFullscreenLoaderView() {
        let activityIndicator = self.addedLoaderView()
        guard activityIndicator == nil else { return }
        
        let screenSize = UIScreen.main.bounds
        //let y = UserStatusManager.sharedInstance.isSignedIn() ? 0 : UIApplication.shared.statusBarFrame.height
        let loader = UIView.init(frame: screenSize)
        loader.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        
        let frame = CGRect(x: (screenSize.width-screenSize.width/7)/2,
                           y: (screenSize.height-screenSize.height*1.25/7)/2,
                           width: screenSize.width/7,
                           height: screenSize.height/7)
        
        let color = UIColor.kg_blueColor()
        let spinner = NVActivityIndicatorView(frame: frame, type: .ballPulse, color: color, padding: 0.0)
        loader.addSubview(spinner)
        spinner.startAnimating()
        loader.tag = loadetViewTag
        //self.view.window?.addSubview(loader)
        let window = UIApplication.shared.keyWindow!
        window.addSubview(loader)
    }
    
    func hideLoaderView(){
        let activityIndicator = self.addedLoaderView()
        guard activityIndicator != nil else { return }
        
        activityIndicator?.superview?.removeFromSuperview()
    }
}
