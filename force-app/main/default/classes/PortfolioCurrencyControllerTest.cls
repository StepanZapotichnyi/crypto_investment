@IsTest
public with sharing class PortfolioCurrencyControllerTest {
    @IsTest
    static void testCreatePortfolioCurrency() {

        Portfolio__c testPortfolio =  new Portfolio__c(Name = 'Test');
        insert testPortfolio;

        Map<String, Object> testDataPortfolioCurrency = new Map<String, Object>{
            'symbol' => 'PortfolioTest',
            'symbol' => 'test',
            'portfolioId' => testPortfolio.Id
         };

        Id portfoiloCurrencyId =   PortfolioCurrencyController.createPortfolioCurrency(testDataPortfolioCurrency);

        List <Portfolio_Currency__c> testPortfolioCurrencies = [
            SELECT
                 Id, Name, Symbol__c, PortfolioId__c 
            FROM 
                Portfolio_Currency__c
            WHERE  
            PortfolioId__c  = :  testPortfolio.Id ];
        for(Portfolio_Currency__c testPortfolioCurrency : testPortfolioCurrencies){
                Assert.areEqual(portfoiloCurrencyId, testPortfolioCurrency.Id ,
                'Expected Portfolio Id: ' + portfoiloCurrencyId + 'Actual Portfolio Id: ' + testPortfolioCurrency.Id);
            
        }
    }
}