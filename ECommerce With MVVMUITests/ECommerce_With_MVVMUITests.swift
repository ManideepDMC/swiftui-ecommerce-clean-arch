//
//  ECommerce_With_MVVMUITests.swift
//  ECommerce With MVVMUITests
//
//  Created by Manideep on 10/02/26.
//

import XCTest

@MainActor
final class ECommerce_With_MVVMUITests: XCTestCase {

    // MARK: - Properties

    var app: XCUIApplication!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // =========================================================================
    // MARK: - 1. Tab Bar Tests
    // =========================================================================

    func testTabBarShowsShopAndCartTabs() {
        let shopTab = app.tabBars.buttons["Shop"]
        let cartTab = app.tabBars.buttons["Cart"]

        XCTAssertTrue(shopTab.exists, "Shop tab should be visible")
        XCTAssertTrue(cartTab.exists, "Cart tab should be visible")
    }

    func testTappingCartTabNavigatesToCart() {
        app.tabBars.buttons["Cart"].tap()

        let cartList = app.collectionViews["cartProductList"]
        XCTAssertTrue(cartList.waitForExistence(timeout: 3),
                       "Cart product list should be visible after tapping Cart tab")
    }

    func testTappingShopTabFromCartNavigatesBack() {
        app.tabBars.buttons["Cart"].tap()
        app.tabBars.buttons["Shop"].tap()

        let shopList = app.collectionViews["shopProductList"]
        XCTAssertTrue(shopList.waitForExistence(timeout: 3),
                       "Shop product list should be visible after tapping Shop tab")
    }

    // =========================================================================
    // MARK: - 2. Shop — Search Tests
    // =========================================================================

    func testSearchDisplaysProducts() {
        performSearch("Apple")

        let appleTile = app.staticTexts["productName_100"]
        XCTAssertTrue(appleTile.waitForExistence(timeout: 5),
                       "Apple product should appear after searching")
    }

    func testProductTileShowsNameAndPrice() {
        performSearch("fruits")

        let productName = app.staticTexts["productName_100"]
        XCTAssertTrue(productName.waitForExistence(timeout: 5),
                       "Product name should be displayed")

        let priceLabel = app.staticTexts["productPrice_100"]
        XCTAssertTrue(priceLabel.exists, "Product price should be displayed")
    }

    func testSearchShowsMultipleProducts() {
        performSearch("fruits")

        let apple = app.staticTexts["productName_100"]
        XCTAssertTrue(apple.waitForExistence(timeout: 5))

        let banana = app.staticTexts["productName_101"]
        XCTAssertTrue(banana.exists, "Banana should also appear in search results")
    }

    // =========================================================================
    // MARK: - 3. Shop — Add to Cart Tests
    // =========================================================================

    func testAddToCartButtonExists() {
        performSearch("fruits")

        let addButton = app.buttons["addToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5),
                       "Add to Cart button should be visible for Apple")
    }

    func testAddToCartButtonShowsQuantityControls() {
        performSearch("fruits")

        let addButton = app.buttons["addToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let quantityLabel = app.staticTexts["shopQuantity_100"]
        XCTAssertTrue(quantityLabel.waitForExistence(timeout: 5),
                       "Quantity label should appear after adding to cart")
        XCTAssertEqual(quantityLabel.label, "1",
                        "Quantity should be 1 after first add")
    }

    func testShopPlusButtonIncrementsQuantity() {
        performSearch("fruits")

        let addButton = app.buttons["addToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let quantityLabel = app.staticTexts["shopQuantity_100"]
        XCTAssertTrue(quantityLabel.waitForExistence(timeout: 5))

        let plusButton = app.buttons["shopPlus_100"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 3))
        plusButton.tap()

        let predicate = NSPredicate(format: "label == '2'")
        expectation(for: predicate, evaluatedWith: quantityLabel)
        waitForExpectations(timeout: 5)
    }

    func testShopMinusButtonDecrementsQuantity() {
        performSearch("fruits")

        let addButton = app.buttons["addToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let plusButton = app.buttons["shopPlus_100"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5))
        plusButton.tap()

        let quantityLabel = app.staticTexts["shopQuantity_100"]
        let reachedTwo = NSPredicate(format: "label == '2'")
        expectation(for: reachedTwo, evaluatedWith: quantityLabel)
        waitForExpectations(timeout: 5)

        let minusButton = app.buttons["shopMinus_100"]
        XCTAssertTrue(minusButton.waitForExistence(timeout: 3))
        minusButton.tap()

        let reachedOne = NSPredicate(format: "label == '1'")
        expectation(for: reachedOne, evaluatedWith: quantityLabel)
        waitForExpectations(timeout: 5)
    }

    func testDecrementToZeroShowsAddToCartAgain() {
        performSearch("fruits")

        let addButton = app.buttons["addToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let minusButton = app.buttons["shopMinus_100"]
        XCTAssertTrue(minusButton.waitForExistence(timeout: 5))
        minusButton.tap()

        XCTAssertTrue(addButton.waitForExistence(timeout: 5),
                       "Add to Cart button should reappear when quantity reaches 0")
    }

    // =========================================================================
    // MARK: - 4. Cart Tab — Product Appears & Details
    // =========================================================================

    func testProductAppearsInCartAfterAddingFromShop() {
        addAppleAndSwitchToCart()

        let cartProductName = app.staticTexts["cartProductName_100"]
        XCTAssertTrue(cartProductName.waitForExistence(timeout: 5),
                       "Apple should appear in the cart after adding from Shop")
    }

    func testCartShowsProductPrice() {
        addAppleAndSwitchToCart()

        let cartPrice = app.staticTexts["cartProductPrice_100"]
        XCTAssertTrue(cartPrice.waitForExistence(timeout: 5),
                       "Cart should display the product price")
    }

    func testCartShowsQuantityOfOne() {
        addAppleAndSwitchToCart()

        let cartQuantity = app.staticTexts["cartQuantity_100"]
        XCTAssertTrue(cartQuantity.waitForExistence(timeout: 5))
        XCTAssertEqual(cartQuantity.label, "1",
                        "Cart should show quantity 1 for a freshly added item")
    }

    func testCartShowsCorrectQuantityAfterShopIncrement() {
        performSearch("fruits")
        let addButton = app.buttons["addToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let plusButton = app.buttons["shopPlus_100"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5))
        plusButton.tap()

        let shopQty = app.staticTexts["shopQuantity_100"]
        let predicate = NSPredicate(format: "label == '2'")
        expectation(for: predicate, evaluatedWith: shopQty)
        waitForExpectations(timeout: 5)

        app.tabBars.buttons["Cart"].tap()
        let cartQuantity = app.staticTexts["cartQuantity_100"]
        XCTAssertTrue(cartQuantity.waitForExistence(timeout: 5))
        XCTAssertEqual(cartQuantity.label, "2",
                        "Cart should show quantity 2 for Apple")
    }

    // =========================================================================
    // MARK: - 5. Cart Tab — Plus / Minus / Remove
    // =========================================================================

    func testCartPlusButtonExists() {
        addAppleAndSwitchToCart()

        let cartPlus = app.buttons["cartPlus_100"]
        XCTAssertTrue(cartPlus.waitForExistence(timeout: 5),
                       "Plus button should exist in cart")
    }

    func testCartMinusButtonExists() {
        addAppleAndSwitchToCart()

        let cartMinus = app.buttons["cartMinus_100"]
        XCTAssertTrue(cartMinus.waitForExistence(timeout: 5),
                       "Minus button should exist in cart")
    }

    func testCartPlusButtonIncrementsQuantity() {
        addAppleAndSwitchToCart()

        let cartQuantity = app.staticTexts["cartQuantity_100"]
        XCTAssertTrue(cartQuantity.waitForExistence(timeout: 5))

        let cartPlus = app.buttons["cartPlus_100"]
        XCTAssertTrue(cartPlus.waitForExistence(timeout: 3))
        cartPlus.tap()

        let predicate = NSPredicate(format: "label == '2'")
        expectation(for: predicate, evaluatedWith: cartQuantity)
        waitForExpectations(timeout: 5)
    }

    func testCartPlusButtonIncrementsTwice() {
        addAppleAndSwitchToCart()

        let cartQuantity = app.staticTexts["cartQuantity_100"]
        XCTAssertTrue(cartQuantity.waitForExistence(timeout: 5))

        let cartPlus = app.buttons["cartPlus_100"]
        XCTAssertTrue(cartPlus.waitForExistence(timeout: 3))
        cartPlus.tap()

        let reachedTwo = NSPredicate(format: "label == '2'")
        expectation(for: reachedTwo, evaluatedWith: cartQuantity)
        waitForExpectations(timeout: 5)

        cartPlus.tap()

        let reachedThree = NSPredicate(format: "label == '3'")
        expectation(for: reachedThree, evaluatedWith: cartQuantity)
        waitForExpectations(timeout: 5)
    }

    func testCartMinusButtonDecrementsQuantity() {
        addAppleAndSwitchToCart()

        // Increment to 2 first
        let cartPlus = app.buttons["cartPlus_100"]
        XCTAssertTrue(cartPlus.waitForExistence(timeout: 5))
        cartPlus.tap()

        let cartQuantity = app.staticTexts["cartQuantity_100"]
        let reachedTwo = NSPredicate(format: "label == '2'")
        expectation(for: reachedTwo, evaluatedWith: cartQuantity)
        waitForExpectations(timeout: 5)

        // Decrement 2 → 1
        let cartMinus = app.buttons["cartMinus_100"]
        XCTAssertTrue(cartMinus.waitForExistence(timeout: 3))
        cartMinus.tap()

        let reachedOne = NSPredicate(format: "label == '1'")
        expectation(for: reachedOne, evaluatedWith: cartQuantity)
        waitForExpectations(timeout: 5)
    }

    func testDecrementToZeroRemovesItemFromCart() {
        addAppleAndSwitchToCart()

        let cartMinus = app.buttons["cartMinus_100"]
        XCTAssertTrue(cartMinus.waitForExistence(timeout: 5))
        cartMinus.tap()

        let cartProductName = app.staticTexts["cartProductName_100"]
        XCTAssertTrue(cartProductName.waitForNonExistence(timeout: 5),
                       "Product should disappear from cart when quantity reaches 0")
    }

    func testCartIsEmptyOnFreshLaunch() {
        app.tabBars.buttons["Cart"].tap()

        let cartList = app.collectionViews["cartProductList"]
        XCTAssertTrue(cartList.waitForExistence(timeout: 3))

        let anyCartProduct = app.staticTexts.matching(identifier: "cartProductName_100")
        XCTAssertEqual(anyCartProduct.count, 0, "Cart should be empty on fresh launch")
    }

    // =========================================================================
    // MARK: - 6. Cross-Tab Sync Tests
    // =========================================================================

    func testCartIncrementReflectsInShop() {
        performSearch("fruits")
        let addButton = app.buttons["addToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let shopQty = app.staticTexts["shopQuantity_100"]
        XCTAssertTrue(shopQty.waitForExistence(timeout: 5))

        app.tabBars.buttons["Cart"].tap()
        let cartPlus = app.buttons["cartPlus_100"]
        XCTAssertTrue(cartPlus.waitForExistence(timeout: 5))
        cartPlus.tap()

        let cartQty = app.staticTexts["cartQuantity_100"]
        let reachedTwo = NSPredicate(format: "label == '2'")
        expectation(for: reachedTwo, evaluatedWith: cartQty)
        waitForExpectations(timeout: 5)

        app.tabBars.buttons["Shop"].tap()
        let shopQuantity = app.staticTexts["shopQuantity_100"]
        XCTAssertTrue(shopQuantity.waitForExistence(timeout: 5))
        XCTAssertEqual(shopQuantity.label, "2",
                        "Shop quantity should reflect the increment made in Cart")
    }

    func testRemovingFromCartResetsShopButton() {
        performSearch("fruits")
        let addButton = app.buttons["addToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let shopQty = app.staticTexts["shopQuantity_100"]
        XCTAssertTrue(shopQty.waitForExistence(timeout: 5))

        app.tabBars.buttons["Cart"].tap()
        let cartMinus = app.buttons["cartMinus_100"]
        XCTAssertTrue(cartMinus.waitForExistence(timeout: 5))
        cartMinus.tap()

        let cartProductName = app.staticTexts["cartProductName_100"]
        _ = cartProductName.waitForNonExistence(timeout: 5)

        app.tabBars.buttons["Shop"].tap()
        XCTAssertTrue(addButton.waitForExistence(timeout: 5),
                       "Add to Cart button should reappear after removing from Cart")
    }

    // =========================================================================
    // MARK: - 7. Multiple Products Tests
    // =========================================================================

    func testAddMultipleProductsToCart() {
        performSearch("fruits")

        let addApple = app.buttons["addToCart_100"]
        XCTAssertTrue(addApple.waitForExistence(timeout: 5))
        addApple.tap()

        let appleQty = app.staticTexts["shopQuantity_100"]
        XCTAssertTrue(appleQty.waitForExistence(timeout: 5))

        let addBanana = app.buttons["addToCart_101"]
        XCTAssertTrue(addBanana.waitForExistence(timeout: 3))
        addBanana.tap()

        let bananaQty = app.staticTexts["shopQuantity_101"]
        XCTAssertTrue(bananaQty.waitForExistence(timeout: 5))

        app.tabBars.buttons["Cart"].tap()

        let cartApple = app.staticTexts["cartProductName_100"]
        let cartBanana = app.staticTexts["cartProductName_101"]
        XCTAssertTrue(cartApple.waitForExistence(timeout: 5), "Apple should be in cart")
        XCTAssertTrue(cartBanana.waitForExistence(timeout: 5), "Banana should be in cart")
    }

    func testCartShowsPricesForMultipleProducts() {
        performSearch("fruits")

        let addApple = app.buttons["addToCart_100"]
        XCTAssertTrue(addApple.waitForExistence(timeout: 5))
        addApple.tap()
        let appleQty = app.staticTexts["shopQuantity_100"]
        XCTAssertTrue(appleQty.waitForExistence(timeout: 5))

        let addBanana = app.buttons["addToCart_101"]
        XCTAssertTrue(addBanana.waitForExistence(timeout: 3))
        addBanana.tap()
        let bananaQty = app.staticTexts["shopQuantity_101"]
        XCTAssertTrue(bananaQty.waitForExistence(timeout: 5))

        app.tabBars.buttons["Cart"].tap()

        let applePrice = app.staticTexts["cartProductPrice_100"]
        let bananaPrice = app.staticTexts["cartProductPrice_101"]
        XCTAssertTrue(applePrice.waitForExistence(timeout: 5), "Apple price should show in cart")
        XCTAssertTrue(bananaPrice.waitForExistence(timeout: 5), "Banana price should show in cart")
    }

    func testCartShowsQuantitiesForMultipleProducts() {
        performSearch("fruits")

        let addApple = app.buttons["addToCart_100"]
        XCTAssertTrue(addApple.waitForExistence(timeout: 5))
        addApple.tap()
        let appleQty = app.staticTexts["shopQuantity_100"]
        XCTAssertTrue(appleQty.waitForExistence(timeout: 5))

        let addBanana = app.buttons["addToCart_101"]
        XCTAssertTrue(addBanana.waitForExistence(timeout: 3))
        addBanana.tap()
        let bananaQty = app.staticTexts["shopQuantity_101"]
        XCTAssertTrue(bananaQty.waitForExistence(timeout: 5))

        app.tabBars.buttons["Cart"].tap()

        let cartAppleQty = app.staticTexts["cartQuantity_100"]
        let cartBananaQty = app.staticTexts["cartQuantity_101"]
        XCTAssertTrue(cartAppleQty.waitForExistence(timeout: 5))
        XCTAssertTrue(cartBananaQty.waitForExistence(timeout: 5))
        XCTAssertEqual(cartAppleQty.label, "1", "Apple quantity should be 1")
        XCTAssertEqual(cartBananaQty.label, "1", "Banana quantity should be 1")
    }

    // =========================================================================
    // MARK: - 8. Scroll Test
    // =========================================================================

    func testProductListIsScrollable() {
        performSearch("fruits")

        let firstProduct = app.staticTexts["productName_100"]
        XCTAssertTrue(firstProduct.waitForExistence(timeout: 5))

        let shopList = app.collectionViews["shopProductList"]
        shopList.swipeUp()

        let papaya = app.staticTexts["productName_109"]
        XCTAssertTrue(papaya.waitForExistence(timeout: 5),
                       "Papaya should be visible after scrolling down")
    }

    // =========================================================================
    // MARK: - Helper Methods
    // =========================================================================

    /// Types a query into the SwiftUI `.searchable` search bar.
    ///
    /// The ShopView uses `.onChange(of: searchText)` to trigger fetching,
    /// so typing text is enough — no need to "submit" the search.
    ///
    /// IMPORTANT: Do NOT tap "Cancel" after typing — that clears the
    /// searchText, which triggers .onChange with "", which empties the
    /// product list. Instead, wait for results to appear, confirming
    /// the fetch completed successfully.
    private func performSearch(_ query: String) {
        // Step 1: Find the search field.
        // SwiftUI `.searchable` hides the search bar under the nav bar on load.
        // Swipe down on the shop list to reveal it.
        let shopList = app.collectionViews["shopProductList"]
        XCTAssertTrue(shopList.waitForExistence(timeout: 5),
                       "Shop product list should exist")
        shopList.swipeDown()

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5),
                       "Search field should appear after swiping down")

        // Step 2: Tap to activate and type the query.
        searchField.tap()
        searchField.typeText(query)

        // Step 3: Submit the search using the keyboard return key.
        searchField.typeText("\n")

        // Step 4: Wait for the first product to appear, confirming fetch worked.
        let firstProduct = app.staticTexts["productName_100"]
        XCTAssertTrue(firstProduct.waitForExistence(timeout: 5),
                       "Products should load after typing search query")
    }

    /// Adds Apple (id=100) from Shop and navigates to Cart tab.
    private func addAppleAndSwitchToCart() {
        performSearch("fruits")

        let addButton = app.buttons["addToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let shopQty = app.staticTexts["shopQuantity_100"]
        XCTAssertTrue(shopQty.waitForExistence(timeout: 5))

        app.tabBars.buttons["Cart"].tap()
    }
}
