@IsTest
private  class PortfolioCurrencyTriggerHandlerTest {
    @IsTest
    static void testHandleUpdatePortfolioCurrency() {
        
        List<Portfolio_Currency__c> testPortfolioCurrencies = TestFactoryData.createPortfoliosWithPortfolioCurrencies(5);
      
        PortfolioCurrencyTriggerHandler.handleUpdatePortfolioCurrencyName(testPortfolioCurrencies);
        
        List<Portfolio_Currency__c> portfolioCurrenciesAfterUpdate = [
            SELECT
                Id, Name, PortfolioId__c, Symbol__c, Total_Quantity__c,
                (SELECT Id, Total_Profit__c, Total_Cost__c, Portfolio_CurrencyId__c FROM PortfolioCurrencySummaries__r)
            FROM Portfolio_Currency__c
        ];

        List<Portfolio__c> portfolios = [SELECT Id, Name FROM Portfolio__c];

        Map<Id, String> namePortfolio = new Map<Id, String>();
        for (Portfolio__c portfolio : portfolios) {
            namePortfolio.put(portfolio.Id, portfolio.Name);
        }

        for(Portfolio_Currency__c portfolioCurrency :  portfolioCurrenciesAfterUpdate) {

            if(namePortfolio.containsKey(portfolioCurrency.PortfolioId__c)) {
                String expected = portfolioCurrency.Symbol__c + '-' + namePortfolio.get(portfolioCurrency.PortfolioId__c);                 
                Assert.areEqual(expected, portfolioCurrency.Name, 'Expected Name to be: ' + expected);
            }

        }
          
        
    } 
    
    @IsTest
    static void testCreatePortfolioCurrencySummary() {

        
        List<Portfolio_Currency__c> testPortfolioCurrencies = TestFactoryData.createPortfoliosWithPortfolioCurrencies(5);

        PortfolioCurrencyTriggerHandler.createPortfolioCurrencySummary(testPortfolioCurrencies);

        List<Portfolio_Currency__c> portfolioCurrenciesAfterUpdate = [
            SELECT
                Id, Name, PortfolioId__c, Symbol__c, Total_Quantity__c,
                (SELECT Id, Total_Profit__c, Total_Cost__c, Portfolio_CurrencyId__c FROM PortfolioCurrencySummaries__r)
            FROM Portfolio_Currency__c
        ];
        

        for(Portfolio_Currency__c portfolioCurrency :  portfolioCurrenciesAfterUpdate) {

            for (PortfolioCurrencySummary__c currencySummary : portfolioCurrency.PortfolioCurrencySummaries__r) {
                Assert.areEqual(portfolioCurrency.Id, currencySummary.Portfolio_CurrencyId__c, 
                  'PortfolioCurrencyId not found for PortfolioCurrencySummary. Expected: ' + portfolioCurrency.Id + ', but got: ' + currencySummary.Portfolio_CurrencyId__c);
                
            }

        }
    }
}