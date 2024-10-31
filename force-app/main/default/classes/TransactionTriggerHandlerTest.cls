@IsTest
private with sharing class TransactionTriggerHandlerTest {
    @IsTest
    static void testHandleUpdatePortfolioCurrency() {
  
        Map<String, Decimal> testDataTransaction = new Map<String, Decimal>{
            'testQuantityBuy' => 100,
            'testQuantitySell' => 50,
            'testAmountBuy' => 100,
            'testAmountSell' => 150
        };

        List<Transaction__c> testTransactions = TestFactoryData.createTransactions(testDataTransaction);

        List<Portfolio_Currency__c> portfolioCurrenciesAfterUpdate = [
            SELECT
                Id, Name, PortfolioId__c, Symbol__c, Total_Quantity__c,
                (SELECT Id, Total_Profit__c, Total_Cost__c, Portfolio_CurrencyId__c FROM PortfolioCurrencySummaries__r)
            FROM Portfolio_Currency__c
        ];

        Assert.areEqual((testTransactions.size() - portfolioCurrenciesAfterUpdate.size()),
                         portfolioCurrenciesAfterUpdate.size(),
                          'Expected the difference between testTransactions and portfolioCurrenciesAfterUpdate sizes to equal the size of portfolioCurrenciesAfterUpdate');

        for(Portfolio_Currency__c portfolioCurrency : portfolioCurrenciesAfterUpdate) {

                Assert.areEqual(testDataTransaction.get('testQuantitySell'), portfolioCurrency.Total_Quantity__c,
                 'Total Quantity does not match for Portfolio Currency: ' + portfolioCurrency.Id);
                
                for(PortfolioCurrencySummary__c portfolioCurrencySummary : portfolioCurrency.PortfolioCurrencySummaries__r){
    
                    Assert.areEqual(testDataTransaction.get('testAmountBuy'), portfolioCurrencySummary.Total_Cost__c,
                     'Total Cost does not match for Portfolio Currency Summary: ' + portfolioCurrencySummary.Id);
                    Assert.areEqual(testDataTransaction.get('testAmountSell'),portfolioCurrencySummary.Total_Profit__c,
                     'Total Profit does not match for Portfolio Currency Summary: ' + portfolioCurrencySummary.Id);
                }
        }
    }
}