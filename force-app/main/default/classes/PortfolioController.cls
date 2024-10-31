public with sharing class PortfolioController {
   
    @AuraEnabled
    public static Portfolio__c createPortfolio(String name) {
        
        Portfolio__c portfolio = new Portfolio__c();
        portfolio.Name = name;
        insert portfolio;
        
        return portfolio;
    }
    
    
    @AuraEnabled
    public static List<Portfolio__c> getPortfolios() {
        List<Portfolio__c> portfolios = [SELECT Id, Name FROM Portfolio__c ];
        return portfolios;  
        
    }

    
    @AuraEnabled
    public static void deletePortfolio(Id portfolioId){

        List<Portfolio__c> portfolios = [SELECT Id, Name FROM Portfolio__c WHERE Id = :portfolioId];
        if(!portfolios.isEmpty()){
            delete portfolios;
        }
    
    }

}