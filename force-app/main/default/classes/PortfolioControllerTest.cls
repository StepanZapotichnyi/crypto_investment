@IsTest
public with sharing class PortfolioControllerTest {
   @IsTest
    static void testCreatePortfolio() {

        String testName = 'Test Portfolio';

        Portfolio__c portfolio  =  PortfolioController.createPortfolio(testName);

        Assert.isNotNull(portfolio.Id, 'Portfolio Id should be null');
        Assert.areEqual(testName, portfolio.Name, 'Portfolio name does not match');

    }

    @IsTest
    static void testDeletePortfolio() {
        
        Portfolio__c testPortfolio =  new Portfolio__c(Name = 'Test');
        insert testPortfolio;

        PortfolioController.deletePortfolio(testPortfolio.Id);


        List<Portfolio__c> portfolios = [SELECT Id, Name FROM Portfolio__c WHERE Id =: testPortfolio.Id];
        for(Portfolio__c portfolio : portfolios) {
            Assert.isNull(portfolio.Id, 'Portfolio Id should be null');
        }

    }
    
}