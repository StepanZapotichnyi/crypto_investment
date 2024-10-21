@IsTest
public with sharing class UtilityToPortfolioTest {
    @IsTest
    static void testVerifyTokenSymbol() {

        String symbol = 'btc'; 

        String resultSymbol = UtilityToPortfolio.verifyTokenSymbol(symbol);

        Assert.areEqual(symbol.toUpperCase(), resultSymbol, 'The symbol ' + symbol + ' is not present in the list of crypto currency symbols' +
                          '\n' + 'Please add the symbol to the crypto currency list');


    }

    @IsTest
    static void testVerifyTokenSymbolNegative() {
        String testSymbol = 'tets'; 
        String testMessage = 'The symbol ' + testSymbol + ' is not present in the list of crypto currency symbols.' +
                          '\n' + 'Please add the symbol to the crypto currency list.';
        try {
            String resultSymbol = UtilityToPortfolio.verifyTokenSymbol(testSymbol);
        } catch ( UtilityToPortfolio.UtilityToPortfolioException e) {
            Assert.areEqual(testMessage, e.getMessage(), 'Message should be same');
        }
    }


}
