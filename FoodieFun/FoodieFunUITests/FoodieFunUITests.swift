//
//  FoodieFunUITests.swift
//  FoodieFunUITests
//
//  Created by Dennis Rudolph on 1/6/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import XCTest

class FoodieFunUITests: XCTestCase {
    
    var app = XCUIApplication()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app.launch()
        sleep(2)
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLogin() {
       
       let usernameTF = app.textFields["Username"]
        usernameTF.tap()
        usernameTF.typeText("Dennis\n")
        let passwordTF = app.secureTextFields["Password"]
        passwordTF.tap()
        passwordTF.typeText("Rudolph")
        let signInButton = app.buttons["Sign In"]
        signInButton.tap()
        XCTAssert(app.staticTexts["Foodie Fun"].exists)
        
    }
    
    func logIn() {
        
        sleep(5)
        
        let usernameTF = app.textFields["Username"]
        usernameTF.tap()
        usernameTF.typeText("Dennis\n")
        let passwordTF = app.secureTextFields["Password"]
        passwordTF.tap()
        passwordTF.typeText("Rudolph")
        let signInButton = app.buttons["Sign In"]
        signInButton.tap()
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
