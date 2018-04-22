//
//  MacKeyUITests.swift
//  MacKeyUITests
//
//  Created by Liu Liang on 5/14/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import XCTest
import Localize_Swift

class MacKeyUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app)
        UserDefaults.standard.set(deviceLanguage, forKey: "LCLCurrentLanguageKey")
        app.launchArguments += ["UI-TESTING"]
        app.launchEnvironment["wake"] = "Mac is unlocked"
        app.launch()
        
        let alias = "Home"
        let dStaticText = app.tables.staticTexts[alias]
        if dStaticText.exists {
            dStaticText.tap()
            app.navigationBars["Mac Key"].buttons["Delete"].tap()
            app.alerts[String(format:"Delete '%@'", alias)]
                .buttons["Delete"].tap()
        }
        
        let macKeyNavigationBar = app.navigationBars["Mac Key"]
        macKeyNavigationBar.buttons["HelpButton"].tap()
        snapshot("1Help")
        app.navigationBars["Help"].buttons["CloseButton"].tap()
        
        macKeyNavigationBar.buttons["Add"].tap()
        snapshot("2hostDetails")
        
        let tablesQuery = XCUIApplication().tables
        
        [("Enter alias", alias),
         ("Enter host name or IP address", "192.168.1.194"),
         ("Enter username", "tester")]
            .forEach {
                let textField = tablesQuery.textFields[$0.0]
                textField.tap()
                textField.typeText($0.1)
        }
        
        let passwordTextField = tablesQuery.secureTextFields["Enter password"]
        passwordTextField.tap()
        passwordTextField.typeText("123456")
        snapshot("3hostDetailsFilled")
        
        app.navigationBars["Host Editor"].buttons["Save"].tap()
        
        app.tables.staticTexts[alias].tap()
        snapshot("4Unlock")
        app.navigationBars["Mac Key"].buttons["Delete"].tap()
        snapshot("5Delete")
        app.alerts["Delete"]
            .buttons["Delete"].tap()
    }
}
