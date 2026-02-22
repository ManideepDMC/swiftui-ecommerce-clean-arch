//
//  ProductDetailsViewUITests.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 20/02/26.
//

import XCTest

@MainActor
class ProductDetailsViewUITests: XCTestCase {

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
    // MARK: - 1. Navigation to Product Details
    // =========================================================================

    func testTappingProductNavigatesToDetailsScreen() {
        navigateToAppleDetails()

        let detailName = app.staticTexts["detailName_100"]
        XCTAssertTrue(detailName.waitForExistence(timeout: 5),
                       "Product name should be visible on the details screen")
    }

    func testBackButtonReturnsToShopList() {
        navigateToAppleDetails()

        let detailName = app.staticTexts["detailName_100"]
        XCTAssertTrue(detailName.waitForExistence(timeout: 5))

        app.navigationBars.buttons.firstMatch.tap()

        let shopList = app.collectionViews["shopProductList"]
        XCTAssertTrue(shopList.waitForExistence(timeout: 5),
                       "Shop list should be visible after tapping back")
    }

    // =========================================================================
    // MARK: - 2. Product Information Display
    // =========================================================================

    func testDetailsScreenShowsProductName() {
        navigateToAppleDetails()

        let detailName = app.staticTexts["detailName_100"]
        XCTAssertTrue(detailName.waitForExistence(timeout: 5))
        XCTAssertEqual(detailName.label, "Apple",
                        "Product name should be 'Apple'")
    }

    func testDetailsScreenShowsFormattedPrice() {
        navigateToAppleDetails()

        let detailPrice = app.staticTexts["detailPrice_100"]
        XCTAssertTrue(detailPrice.waitForExistence(timeout: 5))
        XCTAssertEqual(detailPrice.label, "$ 1.99 per 1.2kg",
                        "Price should be formatted as '$ 1.99 per 1.2kg'")
    }

    func testDetailsScreenShowsProductDescription() {
        navigateToAppleDetails()

        let detailDescription = app.staticTexts["detailDescription_100"]
        XCTAssertTrue(detailDescription.waitForExistence(timeout: 5),
                       "Product description should be visible on details screen")
    }

    func testDetailsScreenShowsNavigationTitle() {
        navigateToAppleDetails()

        let navTitle = app.navigationBars["Prodcut Details"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5),
                       "Navigation bar should show 'Prodcut Details' title")
    }

    // =========================================================================
    // MARK: - 3. Add to Cart Button
    // =========================================================================

    func testAddToCartButtonExistsInitially() {
        navigateToAppleDetails()

        let addButton = app.buttons["detailAddToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5),
                       "Add to Cart button should be visible when item is not in cart")
    }

    func testTappingAddToCartShowsQuantityControls() {
        navigateToAppleDetails()

        let addButton = app.buttons["detailAddToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let quantityLabel = app.staticTexts["detailQuantity_100"]
        XCTAssertTrue(quantityLabel.waitForExistence(timeout: 5),
                       "Quantity label should appear after adding to cart")
    }

    func testAddToCartSetsQuantityToOne() {
        navigateToAppleDetails()

        let addButton = app.buttons["detailAddToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let quantityLabel = app.staticTexts["detailQuantity_100"]
        XCTAssertTrue(quantityLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(quantityLabel.label, "1",
                        "Quantity should be 1 after first add to cart")
    }

    func testAddToCartHidesAddButton() {
        navigateToAppleDetails()

        let addButton = app.buttons["detailAddToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        XCTAssertTrue(addButton.waitForNonExistence(timeout: 5),
                       "Add to Cart button should disappear after adding to cart")
    }

    // =========================================================================
    // MARK: - 4. Quantity Controls
    // =========================================================================

    func testPlusAndMinusButtonsAppearAfterAddToCart() {
        navigateToAppleDetails()

        let addButton = app.buttons["detailAddToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let plusButton = app.buttons["detailPlus_100"]
        let minusButton = app.buttons["detailMinus_100"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5),
                       "Plus button should appear after adding to cart")
        XCTAssertTrue(minusButton.exists,
                       "Minus button should appear after adding to cart")
    }

    func testPlusButtonIncrementsQuantity() {
        navigateToAppleDetails()

        let addButton = app.buttons["detailAddToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let quantityLabel = app.staticTexts["detailQuantity_100"]
        XCTAssertTrue(quantityLabel.waitForExistence(timeout: 5))

        let plusButton = app.buttons["detailPlus_100"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 3))
        plusButton.tap()

        let reachedTwo = NSPredicate(format: "label == '2'")
        expectation(for: reachedTwo, evaluatedWith: quantityLabel)
        waitForExpectations(timeout: 5)
    }

    func testMultiplePlusTapsIncrementCorrectly() {
        navigateToAppleDetails()

        let addButton = app.buttons["detailAddToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let quantityLabel = app.staticTexts["detailQuantity_100"]
        XCTAssertTrue(quantityLabel.waitForExistence(timeout: 5))

        let plusButton = app.buttons["detailPlus_100"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 3))
        plusButton.tap()

        let reachedTwo = NSPredicate(format: "label == '2'")
        expectation(for: reachedTwo, evaluatedWith: quantityLabel)
        waitForExpectations(timeout: 5)

        plusButton.tap()

        let reachedThree = NSPredicate(format: "label == '3'")
        expectation(for: reachedThree, evaluatedWith: quantityLabel)
        waitForExpectations(timeout: 5)
    }

    func testMinusButtonDecrementsQuantity() {
        navigateToAppleDetails()

        let addButton = app.buttons["detailAddToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let plusButton = app.buttons["detailPlus_100"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5))
        plusButton.tap()

        let quantityLabel = app.staticTexts["detailQuantity_100"]
        let reachedTwo = NSPredicate(format: "label == '2'")
        expectation(for: reachedTwo, evaluatedWith: quantityLabel)
        waitForExpectations(timeout: 5)

        let minusButton = app.buttons["detailMinus_100"]
        minusButton.tap()

        let reachedOne = NSPredicate(format: "label == '1'")
        expectation(for: reachedOne, evaluatedWith: quantityLabel)
        waitForExpectations(timeout: 5)
    }

    func testDecrementToZeroShowsAddToCartAgain() {
        navigateToAppleDetails()

        let addButton = app.buttons["detailAddToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let minusButton = app.buttons["detailMinus_100"]
        XCTAssertTrue(minusButton.waitForExistence(timeout: 5))
        minusButton.tap()

        XCTAssertTrue(addButton.waitForExistence(timeout: 5),
                       "Add to Cart button should reappear when quantity reaches 0")
    }

    // =========================================================================
    // MARK: - 5. Sync with Shop List
    // =========================================================================

    func testAddToCartInDetailsReflectsInShopList() {
        navigateToAppleDetails()

        let addButton = app.buttons["detailAddToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let detailQty = app.staticTexts["detailQuantity_100"]
        XCTAssertTrue(detailQty.waitForExistence(timeout: 5))

        // Navigate back to shop list
        app.navigationBars.buttons.firstMatch.tap()

        // Shop list should now show quantity controls instead of Add to Cart
        let shopQuantity = app.staticTexts["shopQuantity_100"]
        XCTAssertTrue(shopQuantity.waitForExistence(timeout: 5))
        XCTAssertEqual(shopQuantity.label, "1",
                        "Shop tile should reflect the quantity set in details")
    }

    func testIncrementInDetailsReflectsInShopList() {
        navigateToAppleDetails()

        let addButton = app.buttons["detailAddToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let plusButton = app.buttons["detailPlus_100"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5))
        plusButton.tap()

        let detailQty = app.staticTexts["detailQuantity_100"]
        let reachedTwo = NSPredicate(format: "label == '2'")
        expectation(for: reachedTwo, evaluatedWith: detailQty)
        waitForExpectations(timeout: 5)

        // Navigate back to shop list
        app.navigationBars.buttons.firstMatch.tap()

        let shopQuantity = app.staticTexts["shopQuantity_100"]
        XCTAssertTrue(shopQuantity.waitForExistence(timeout: 5))
        XCTAssertEqual(shopQuantity.label, "2",
                        "Shop tile should show quantity 2 after incrementing in details")
    }

    func testRemoveInDetailsShowsAddToCartInShopList() {
        navigateToAppleDetails()

        let addButton = app.buttons["detailAddToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let minusButton = app.buttons["detailMinus_100"]
        XCTAssertTrue(minusButton.waitForExistence(timeout: 5))
        minusButton.tap()

        // Wait for Add to Cart to reappear in details
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))

        // Navigate back to shop list
        app.navigationBars.buttons.firstMatch.tap()

        let shopAddButton = app.buttons["addToCart_100"]
        XCTAssertTrue(shopAddButton.waitForExistence(timeout: 5),
                       "Shop tile should show Add to Cart after removing in details")
    }

    // =========================================================================
    // MARK: - 6. Sync with Cart Tab
    // =========================================================================

    func testAddToCartInDetailsAppearsInCartTab() {
        navigateToAppleDetails()

        let addButton = app.buttons["detailAddToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let detailQty = app.staticTexts["detailQuantity_100"]
        XCTAssertTrue(detailQty.waitForExistence(timeout: 5))

        // Go back to shop list, then to cart tab
        app.navigationBars.buttons.firstMatch.tap()
        app.tabBars.buttons["Cart"].tap()

        let cartProductName = app.staticTexts["cartProductName_100"]
        XCTAssertTrue(cartProductName.waitForExistence(timeout: 5),
                       "Apple should appear in Cart after adding from details screen")
    }

    func testQuantityInDetailsMatchesCartTab() {
        navigateToAppleDetails()

        let addButton = app.buttons["detailAddToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let plusButton = app.buttons["detailPlus_100"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5))
        plusButton.tap()

        let detailQty = app.staticTexts["detailQuantity_100"]
        let reachedTwo = NSPredicate(format: "label == '2'")
        expectation(for: reachedTwo, evaluatedWith: detailQty)
        waitForExpectations(timeout: 5)

        // Navigate back and go to cart
        app.navigationBars.buttons.firstMatch.tap()
        app.tabBars.buttons["Cart"].tap()

        let cartQuantity = app.staticTexts["cartQuantity_100"]
        XCTAssertTrue(cartQuantity.waitForExistence(timeout: 5))
        XCTAssertEqual(cartQuantity.label, "2",
                        "Cart should show quantity 2 matching the details screen")
    }

    // =========================================================================
    // MARK: - 7. Navigation from Cart Tab
    // =========================================================================

    func testNavigatingToDetailsFromCartTab() {
        // First add Apple from shop
        addAppleFromShop()

        // Switch to Cart tab
        app.tabBars.buttons["Cart"].tap()

        // Tap on Apple in cart to open details
        let cartProductName = app.staticTexts["cartProductName_100"]
        XCTAssertTrue(cartProductName.waitForExistence(timeout: 5))
        cartProductName.tap()

        // Verify details screen shows
        let detailName = app.staticTexts["detailName_100"]
        XCTAssertTrue(detailName.waitForExistence(timeout: 5),
                       "Product details should open when tapping a cart item")
        XCTAssertEqual(detailName.label, "Apple")
    }

    func testDetailsFromCartShowsCorrectQuantity() {
        // Add Apple and increment to 2 from shop
        addAppleFromShop()

        let shopPlus = app.buttons["shopPlus_100"]
        XCTAssertTrue(shopPlus.waitForExistence(timeout: 5))
        shopPlus.tap()

        let shopQty = app.staticTexts["shopQuantity_100"]
        let reachedTwo = NSPredicate(format: "label == '2'")
        expectation(for: reachedTwo, evaluatedWith: shopQty)
        waitForExpectations(timeout: 5)

        // Switch to Cart tab and open details
        app.tabBars.buttons["Cart"].tap()

        let cartProductName = app.staticTexts["cartProductName_100"]
        XCTAssertTrue(cartProductName.waitForExistence(timeout: 5))
        cartProductName.tap()

        // Verify details shows correct quantity
        let detailQty = app.staticTexts["detailQuantity_100"]
        XCTAssertTrue(detailQty.waitForExistence(timeout: 5))
        XCTAssertEqual(detailQty.label, "2",
                        "Details screen should show the current quantity from cart")
    }

    // =========================================================================
    // MARK: - 8. Pre-existing Cart State
    // =========================================================================

    func testDetailsShowsQuantityControlsWhenItemAlreadyInCart() {
        // Add Apple from shop list first
        addAppleFromShop()

        // Now navigate to details - should show quantity controls, not Add to Cart
        let productName = app.staticTexts["productName_100"]
        XCTAssertTrue(productName.waitForExistence(timeout: 5))
        productName.tap()

        let detailQty = app.staticTexts["detailQuantity_100"]
        XCTAssertTrue(detailQty.waitForExistence(timeout: 5),
                       "Details should show quantity controls when item is already in cart")
        XCTAssertEqual(detailQty.label, "1")

        let addButton = app.buttons["detailAddToCart_100"]
        XCTAssertFalse(addButton.exists,
                        "Add to Cart button should NOT appear when item is already in cart")
    }

    // =========================================================================
    // MARK: - Helper Methods
    // =========================================================================

    /// Searches for fruits and taps on Apple to navigate to its details screen.
    private func navigateToAppleDetails() {
        performSearch("fruits")

        let productName = app.staticTexts["productName_100"]
        XCTAssertTrue(productName.waitForExistence(timeout: 5))
        productName.tap()
    }

    /// Searches for fruits and adds Apple to cart from the shop list.
    private func addAppleFromShop() {
        performSearch("fruits")

        let addButton = app.buttons["addToCart_100"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let shopQty = app.staticTexts["shopQuantity_100"]
        XCTAssertTrue(shopQty.waitForExistence(timeout: 5))
    }

    /// Types a query into the SwiftUI `.searchable` search bar.
    private func performSearch(_ query: String) {
        let shopList = app.collectionViews["shopProductList"]
        XCTAssertTrue(shopList.waitForExistence(timeout: 5),
                       "Shop product list should exist")
        shopList.swipeDown()

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5),
                       "Search field should appear after swiping down")

        searchField.tap()
        searchField.typeText(query)
        searchField.typeText("\n")

        let firstProduct = app.staticTexts["productName_100"]
        XCTAssertTrue(firstProduct.waitForExistence(timeout: 5),
                       "Products should load after typing search query")
    }
}
