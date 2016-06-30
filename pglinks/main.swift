//
//  main.swift
//  pglinks
//
//  Created by Richard Turton on 30/06/2016.
//  Copyright © 2016 Richard Turton. All rights reserved.
//

import Foundation

guard Process.arguments.count == 2 else {
    writeToStdError("Expected a path")
    exit(EXIT_FAILURE)
}

let path = Process.arguments[1]
let url = URL(fileURLWithPath: path)
guard let playground = playground(fromURL: url) else {
    writeToStdError("No playground at " + path)
    exit(EXIT_FAILURE)
}

generateNavigationLinks(playground: playground)





