//
//  ThreadingUtil.swift
//  InsuranceSample
//
//  Created by Yogesh on 11/27/17.
//  Copyright © 2017 Zendrive. All rights reserved.
//

import UIKit

class ThreadingUtil: NSObject {

    public static func synchronized(_ lock: Any, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }

}
