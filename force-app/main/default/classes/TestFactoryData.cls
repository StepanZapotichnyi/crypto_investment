@IsTest
public with sharing class TestFactoryData {
    
    public static List<Portfolio_Currency__c> createPortfoliosWithPortfolioCurrencies(Integer  numberOfTestRecords){
       
        List<Portfolio__c> portfolios = new List<Portfolio__c>();
        for(Integer i = 0; i < numberOfTestRecords; i++){
            Portfolio__c testPortfolio = new Portfolio__c();
            testPortfolio.Name = 'Test Portfolio' + i;
            portfolios.add(testPortfolio);
        }
        insert portfolios;

        List<Portfolio_Currency__c> testPortfolioCurrencies = new List<Portfolio_Currency__c>();
        
        for(Portfolio__c portfolio : portfolios){
            for (Integer i = 0; i < numberOfTestRecords; i++) {
                Portfolio_Currency__c testPortfolioCurrency = new Portfolio_Currency__c();
                testPortfolioCurrency.Name = 'Test Portfolio ' + i;
                testPortfolioCurrency.PortfolioId__c = portfolio.Id;
                testPortfolioCurrency.Symbol__c = 'TEST' + i;
                testPortfolioCurrencies.add(testPortfolioCurrency);
            }

        }

        insert testPortfolioCurrencies;
        return testPortfolioCurrencies;
    }

    public static List<Transaction__c> createTransactions(Map<String, Decimal> testDataTransaction) {

        List<Transaction__c> testTransactions = new List<Transaction__c>();
        List<Portfolio_Currency__c> testPortfolioCurrencies = createPortfoliosWithPortfolioCurrencies(10);

        for( Portfolio_Currency__c  portfolioCurrency :  testPortfolioCurrencies ){
            Transaction__c buyTransaction = new Transaction__c();
            buyTransaction.Type_Transaction__c = 'Buy';
            buyTransaction.Amount__c = testDataTransaction.get('testAmountBuy');
            buyTransaction.Quantity__c = testDataTransaction.get('testQuantityBuy');
            buyTransaction.Portfolio_CurrencyId__c = portfolioCurrency.Id;
            testTransactions.add(buyTransaction);

            Transaction__c sellTransaction = new Transaction__c();
            sellTransaction.Type_Transaction__c = 'Sell';
            sellTransaction.Amount__c = testDataTransaction.get('testAmountSell');
            sellTransaction.Quantity__c = testDataTransaction.get('testQuantitySell');
            sellTransaction.Portfolio_CurrencyId__c = portfolioCurrency.Id;
            testTransactions.add(sellTransaction);
        }

        insert testTransactions;
        return testTransactions;
    }

    public static String getMockString() {
        String testMockData = '{';  
        for (Integer i = 0; i < 1500; i++) {
            String testSymbol = 'TEST' + i;
            String testPrice = String.valueOf(i); 
        
            testMockData += '"' + testSymbol + '": {"USD": ' + testPrice + '}';
        
            if (i < 1499) {
                testMockData += ',';
            }
        }
        testMockData += '}'; 
        System.debug(testMockData);

        return testMockData;
    }
}