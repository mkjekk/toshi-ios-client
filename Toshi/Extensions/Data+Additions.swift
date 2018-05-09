//
//  Data+Additions.swift
//  Toshi
//
//  Created by Ellen Shapiro (Work) on 5/8/18.
//  Copyright © 2018 Bakken&Baeck. All rights reserved.
//

import Foundation

extension Data {

    var countInBits: Int {
        // There are 8 bits in a byte, and count is in bytes.
        return self.count * 8
    }
}
