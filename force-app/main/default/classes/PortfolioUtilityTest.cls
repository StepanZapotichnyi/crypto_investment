@IsTest
public with sharing class PortfolioUtilityTest {
    @IsTest
    static void testVerifyTokenSymbol() {

        String symbol = 'test50'; 

        String resultSymbol = PortfolioUtility.verifyTokenSymbol(symbol);
        Assert.areEqual(symbol.toUpperCase(), resultSymbol, 'The symbol ' + symbol.toUpperCase() + ' is not present in the list of crypto currency symbols' +
                          '\n' + 'Please add the symbol to the crypto currency list');


    }

    @IsTest
    static void testVerifyTokenSymbolNegative() {
        String testSymbol = 'tets?'; 
        String testMessage = 'The symbol ' + testSymbol + ' is not present in the list of crypto currency symbols.' +
                          '\n' + 'Please add the symbol to the crypto currency list.';
        try {
            String resultSymbol = PortfolioUtility.verifyTokenSymbol(testSymbol);
        } catch ( PortfolioUtility.PortfolioUtilityException e) {
            Assert.areEqual(testMessage, e.getMessage(), 'Message should be same');
        }
    }


}