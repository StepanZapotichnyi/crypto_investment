@IsTest
private with sharing class PortfolioCurrencyControllerTest {
    @IsTest
    static void testGetPortfolioCurrencyDetails() {
        Map<String, Decimal> testDataTransaction = new Map<String, Decimal>{
            'testQuantityBuy' => 100,
            'testQuantitySell' => 50,
            'testAmountBuy' => 100,
            'testAmountSell' => 50
        };

        List<Transaction__c> testTransactions = TestFactoryData.createTransactions(testDataTransaction);

        List<Portfolio_Currency__c> portfolioCurrencies = [
            SELECT
                Id, Name, PortfolioId__c, Symbol__c, Total_Quantity__c,
                (SELECT Id, Total_Profit__c, Total_Cost__c, Portfolio_CurrencyId__c FROM PortfolioCurrencySummaries__r)
            FROM Portfolio_Currency__c
        ];
        

        PortfolioCurrencyController.PortfolioCurrencyWrapper resultWrapper = PortfolioCurrencyController.getPortfolioCurrencyDetails();

        Assert.areEqual(
            portfolioCurrencies.size(), resultWrapper.portfolioCurrencies.size(),
            'Expected the size of resultWrapper.portfolioCurrencies to match the size of portfolioCurrencies.'
        );


    Decimal expectedNetInvestment = 0;
    for (Portfolio_Currency__c portfolioCurrency : portfolioCurrencies) {
        if (!portfolioCurrency.PortfolioCurrencySummaries__r.isEmpty()) {
            for (PortfolioCurrencySummary__c summary : portfolioCurrency.PortfolioCurrencySummaries__r) {
                expectedNetInvestment += (summary.Total_Cost__c != null ? summary.Total_Cost__c : 0) -
                                          (summary.Total_Profit__c != null ? summary.Total_Profit__c : 0);
            }
        }
    }
    expectedNetInvestment = expectedNetInvestment > 0 ? expectedNetInvestment : 0;
    Assert.areEqual(expectedNetInvestment, resultWrapper.netInvestment, 'Net investment does not match the expected value.');


    Map<String, Decimal> expectedSymbolToTotalQuantityMap = new Map<String, Decimal>();
    for (Portfolio_Currency__c portfolioCurrency : portfolioCurrencies) {
        String symbol = portfolioCurrency.Symbol__c;
        Decimal quantity = portfolioCurrency.Total_Quantity__c != null ? portfolioCurrency.Total_Quantity__c : 0;
        expectedSymbolToTotalQuantityMap.put(symbol, 
            expectedSymbolToTotalQuantityMap.get(symbol) != null ? 
            expectedSymbolToTotalQuantityMap.get(symbol) + quantity : quantity
        );
    }
    Assert.areEqual(expectedSymbolToTotalQuantityMap, resultWrapper.symbolToTotalQuantityMap, 
        'The symbolToTotalQuantityMap in the result does not match the expected values.');

    }
    
    @IsTest
    static void testCreatePortfolioCurrency() {

        Portfolio__c testPortfolio =  new Portfolio__c(Name = 'Test');
        insert testPortfolio;

        Map<String, Object> testDataPortfolioCurrency = new Map<String, Object>{
            'symbol' => 'PortfolioTest',
            'symbol' => 'test',
            'portfolioId' => testPortfolio.Id
         };

        Id portfolioCurrencyId =  PortfolioCurrencyController.createPortfolioCurrency(testDataPortfolioCurrency);

        List <Portfolio_Currency__c> testPortfolioCurrencies = [
            SELECT
                 Id, Name, Symbol__c, PortfolioId__c 
            FROM 
                Portfolio_Currency__c
            WHERE  
            PortfolioId__c  = :  testPortfolio.Id 
        ];

        Assert.areEqual(1, testPortfolioCurrencies.size(), 'Expected exactly one Portfolio_Currency__c record to be created for the test portfolio.');


        for(Portfolio_Currency__c testPortfolioCurrency : testPortfolioCurrencies){
                Assert.areEqual(portfolioCurrencyId, testPortfolioCurrency.Id ,
                'Expected Portfolio Id: ' + portfolioCurrencyId + 'Actual Portfolio Id: ' + testPortfolioCurrency.Id);
            
        }
    }
}