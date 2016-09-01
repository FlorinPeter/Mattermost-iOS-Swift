//
//  Errir.swift
//  Mattermost
//
//  Created by Maxim Gubin on 28/06/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

struct Error {
    var code: Int = 0;
    var message: String!
    
    init(error: NSError!) {
        code = error.code;
        message = error.localizedDescription
        
    }
    
    internal static  func errorWithGenericError(error: NSError!) -> Error {
        return Error(error: error)
    }
}
