@IsTest
public with sharing class PortfolioCurrencyDetailsTest {
    @IsTest
    static void  testPortfolioCurrencyDetailsConstructor() {
      
        String testPortfolioCurrencyId = '123';
        String testSymbol = 'USD';
        String testTotalQuantity = '100';
        String testPortfolioId = '456';
        String testPrice = '10.5';
        String testTotalCost = '1050';

        PortfolioCurrencyDetails details = new PortfolioCurrencyDetails(
            testPortfolioCurrencyId,
            testSymbol,
            testTotalQuantity,
            testPortfolioId,
            testPrice,
            testTotalCost
        );

        Assert.areEqual(testPortfolioCurrencyId, details.portfolioCurrencyId, 'portfolioCurrencyId is not the same');
        Assert.areEqual(testSymbol, details.symbol, 'symbol is not the same');
        Assert.areEqual(testTotalQuantity, details.totalQuantity, 'totalQuantity is not the same');
        Assert.areEqual(testPortfolioId, details.portfolioId, 'portfolioId is not the same');
        Assert.areEqual(testPrice, details.price, 'price is not the same');
        Assert.areEqual(testTotalCost, details.totalCost, 'totalCost is not the same');
    }
}
    
