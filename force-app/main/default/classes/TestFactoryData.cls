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

    public static List<Transaction__c> createTransactions(Map<String, Decimal> testTransactionData) {

        List<Transaction__c> testTransactions = new List<Transaction__c>();
        List<Portfolio_Currency__c> testPortfolioCurrencies = createPortfoliosWithPortfolioCurrencies(10);

        for( Portfolio_Currency__c  portfolioCurrency :  testPortfolioCurrencies ){
            Transaction__c buyTransaction = new Transaction__c();
            buyTransaction.Type_Transaction__c = TypeTransaction.BUY;
            buyTransaction.Amount__c = testTransactionData.get('testAmountBuy');
            buyTransaction.Quantity__c = testTransactionData.get('testQuantityBuy');
            buyTransaction.Portfolio_CurrencyId__c = portfolioCurrency.Id;
            testTransactions.add(buyTransaction);

            Transaction__c sellTransaction = new Transaction__c();
            sellTransaction.Type_Transaction__c = TypeTransaction.SELL;
            sellTransaction.Amount__c = testTransactionData.get('testAmountSell');
            sellTransaction.Quantity__c = testTransactionData.get('testQuantitySell');
            sellTransaction.Portfolio_CurrencyId__c = portfolioCurrency.Id;
            testTransactions.add(sellTransaction);
        }

        insert testTransactions;
        return testTransactions;
    }


    
    public static String createCryptoDataMockString() {
        
        List<String> testCryptoSymbols = getTestStringCryptoSymbols();
        String testMockData = '{';  
        
        Integer i = 0;

        for (String symbol : testCryptoSymbols) {
            String price = String.valueOf(i);  
        
            testMockData += '"' + symbol + '": {"USD": ' + price + '}';
        
            if (i < testCryptoSymbols.size() - 1) {
                testMockData += ',';
            }
            i++;
        }
    
        testMockData += '}'; 
        System.debug(testMockData);

        return testMockData;

    }


    public static List<String> getTestStringCryptoSymbols(){
        List<String> cryptoSymbolsToIsRunnigTest = new List<String>(); 
        for(Integer i = 0; i < 1500; i++){
            String symbol = 'TEST'+ i;
            cryptoSymbolsToIsRunnigTest .add(symbol);
        }
        return cryptoSymbolsToIsRunnigTest;
    }

    
    
}