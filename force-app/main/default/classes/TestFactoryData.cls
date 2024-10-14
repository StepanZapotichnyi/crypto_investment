@IsTest
public with sharing class TestFactoryData {
    @IsTest
    public static List<Portfolio_Currency__c> createPortfolioCurrency() {

        List<Portfolio_Currency__c> testPortfolioCurrencies = new List<Portfolio_Currency__c>();
   
        List<Portfolio__c> portfolios = new List<Portfolio__c>();
        for(Integer i = 0; i < 3; i++){
            Portfolio__c testPortfolio = new Portfolio__c();
            testPortfolio.Name = 'Test Portfolio' + i;
            portfolios.add(testPortfolio);
        }
        insert portfolios;
        
        for(Portfolio__c portfolio : portfolios){
            for (Integer i = 1; i <= 100; i++) {
                Portfolio_Currency__c testPortfolioCurrency = new Portfolio_Currency__c();
                testPortfolioCurrency.Name = 'Test Portfolio ' + i;
                testPortfolioCurrency.PortfolioId__c = portfolio.Id;
                testPortfolioCurrency.Symbol__c = 'TEST' + i;
                testPortfolioCurrencies.add(testPortfolioCurrency);
            }

        }
        System.debug(testPortfolioCurrencies.size());
        insert testPortfolioCurrencies;
        return testPortfolioCurrencies;
    }
}