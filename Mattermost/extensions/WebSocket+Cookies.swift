//
//  WebSocket+Cookies.swift
//  Mattermost
//
//  Created by Maxim Gubin on 26/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import Starscream

extension WebSocket {
    func setCookie(cookie: NSHTTPCookie?) {
        if let unwrappedCookie = cookie  {
            self.headers[Constants.Http.Headers.Cookie] = NSHTTPCookie.requestHeaderFieldsWithCookies([unwrappedCookie]).first?.1
        }
    }
}