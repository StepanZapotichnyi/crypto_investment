public with sharing class PortfolioCurrencyTriggerHandler { 
    public static void  handleUpdatePortfolioCurrencyName(List<Portfolio_Currency__c> portfolioCurrencies) {
        
        Map<Id, List<Portfolio_Currency__c>> portfolioIdAndSymbols = new Map<Id, List<Portfolio_Currency__c>>();
        for (Portfolio_Currency__c portfolioCurrency : portfolioCurrencies) { 
            if (!portfolioIdAndSymbols.containsKey(portfolioCurrency.PortfolioId__c)) {
                portfolioIdAndSymbols.put(portfolioCurrency.PortfolioId__c, new List<Portfolio_Currency__c>());
            }
            portfolioIdAndSymbols.get(portfolioCurrency.PortfolioId__c).add(portfolioCurrency);
        }

        List<Portfolio__c> portfolios = [SELECT Id, Name FROM Portfolio__c WHERE Id IN :portfolioIdAndSymbols.keySet()];

        List<Portfolio_Currency__c> portfolioCurrenciToUpdate = new List<Portfolio_Currency__c>();
        Set<Id> portfolioCurrencyIds = new Set<Id>();

        for (Portfolio__c portfolio : portfolios) {
            if (!portfolioIdAndSymbols.containsKey(portfolio.Id)) {
                continue;
            }

            String portfolioName = portfolio.Name;

             for (Portfolio_Currency__c portfolioCurrency : portfolioIdAndSymbols.get(portfolio.Id)) {
                portfolioCurrency.Name = portfolioCurrency.Symbol__c + '-' + portfolioName;
            }
        
        }
        
    }
    
    
    public static void createPortfolioCurrencySummary(List<Portfolio_Currency__c> portfolioCurrencyList) {
        List<PortfolioCurrencySummary__c> portfolioCurrencySummaryList = new List<PortfolioCurrencySummary__c>();

        for (Portfolio_Currency__c portfolioCurrency : portfolioCurrencyList) {
            PortfolioCurrencySummary__c portfolioCurrencySummary = new PortfolioCurrencySummary__c(
                Name = portfolioCurrency.Name,
                Portfolio_CurrencyId__c = portfolioCurrency.Id,
                Total_Profit__c = 0,
                Total_Cost__c = 0
            );
            portfolioCurrencySummaryList.add(portfolioCurrencySummary);
        }

        if (!portfolioCurrencySummaryList.isEmpty()) {
            insert portfolioCurrencySummaryList;
        }
    }
    
}