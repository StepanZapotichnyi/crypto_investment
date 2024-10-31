public with sharing class TransactionTriggerHandler {

    public static void handleUpdatePortfolioCurrency(List<Transaction__c> tranascations) {

        Map<Id, List<Transaction__c>> portfolioCurrencyIdsToTransactions = new Map<Id, List<Transaction__c>>();
        for (Transaction__c txn : tranascations) {
            if (txn.Portfolio_CurrencyId__c == null) {
                continue;
            }
            
            if (!portfolioCurrencyIdsToTransactions.containsKey(txn.Portfolio_CurrencyId__c)) {
                portfolioCurrencyIdsToTransactions.put(txn.Portfolio_CurrencyId__c, new List<Transaction__c>());
            }
            
            portfolioCurrencyIdsToTransactions.get(txn.Portfolio_CurrencyId__c).add(txn);
        }
        updatePortfolioCurrency(portfolioCurrencyIdsToTransactions);
    }

    public static void updatePortfolioCurrency(Map<Id, List<Transaction__c>> portfolioCurrencyIdsToTransactions) {
        
        List<Portfolio_Currency__c> portfolioCurrencyList = [
             SELECT 
                Id, PortfolioId__c, Symbol__c, Total_Quantity__c,
                (SELECT Id, Total_Profit__c, Total_Cost__c, Portfolio_CurrencyId__c FROM PortfolioCurrencySummaries__r)
            FROM 
                Portfolio_Currency__c 
                WHERE Id IN :portfolioCurrencyIdsToTransactions.keySet()
        ];

        Map <Id, Map<String, Decimal>> totalCalculate  = calculatePortfolioCurrencyTotals(portfolioCurrencyIdsToTransactions, portfolioCurrencyList);
        
        for (Portfolio_Currency__c portfolioCurrency : portfolioCurrencyList) {
            if (totalCalculate.containsKey(portfolioCurrency.Id)) {
                Map<String, Decimal> calculations = totalCalculate.get(portfolioCurrency.Id);
                portfolioCurrency.Total_Quantity__c = calculations.get('TotalQuantity');
            }
        } 

        if(!portfolioCurrencyList.isEmpty()){
            update portfolioCurrencyList;
            updatePortfolioCurrencySummaries(portfolioCurrencyList, totalCalculate);
        }
        
    }   

    public static Map<Id, Map<String, Decimal>> calculatePortfolioCurrencyTotals(Map<Id, List<Transaction__c>> portfolioCurrencyIdsToTransactions, List<Portfolio_Currency__c> portfolioCurrencyList) {
    
        Map<Id, Portfolio_Currency__c> portfolioCurrencyMap = new Map<Id, Portfolio_Currency__c>(portfolioCurrencyList);
        Map<Id, Map<String, Decimal>> totalCalculate = new Map<Id, Map<String, Decimal>>();
        List<Transaction__c> transactions = new List<Transaction__c>();
        
        for (Id portfolioCurrencyId : portfolioCurrencyIdsToTransactions.keySet()) {
            Portfolio_Currency__c portfolioCurrency = portfolioCurrencyMap.get(portfolioCurrencyId);
            Decimal totalQuantity = portfolioCurrency.Total_Quantity__c ?? 0;

            transactions.addAll(portfolioCurrencyIdsToTransactions.get(portfolioCurrencyId));

            totalCalculate.put(portfolioCurrencyId, new Map<String, Decimal>{
                'TotalProfit' => 0,
                'TotalCost' => 0,
                'TotalQuantity' => totalQuantity
            });
            
        }

        for (Transaction__c txn : transactions) {

            Id portfolioCurrencyId = txn.Portfolio_CurrencyId__c;
            Decimal quantity = txn.Quantity__c ?? 0;
            Decimal amount = txn.Amount__c ?? 0;

            Map<String, Decimal> totals = totalCalculate.get(portfolioCurrencyId);

            if (txn.Type_Transaction__c == TypeTransaction.BUY) {
                totals.put('TotalQuantity', totals.get('TotalQuantity') + quantity);
                totals.put('TotalCost', totals.get('TotalCost') + amount);
            } else if (txn.Type_Transaction__c == TypeTransaction.SELL) {
                totals.put('TotalQuantity', totals.get('TotalQuantity') - quantity);
                totals.put('TotalProfit', totals.get('TotalProfit') + amount);
            }
        }


        return totalCalculate;
    }
    

    public static void updatePortfolioCurrencySummaries(List<Portfolio_Currency__c> portfolioCurrencyList, Map <Id, Map<String, Decimal>> totalCalculate){
        
        List<PortfolioCurrencySummary__c> portfolioCurrencySummaries = new List<PortfolioCurrencySummary__c>();
        
        for(Portfolio_Currency__c portfolioCurrency : portfolioCurrencyList) {
            portfolioCurrencySummaries.add(portfolioCurrency.PortfolioCurrencySummaries__r);
        }
        
        List<PortfolioCurrencySummary__c> portfolioCurrencySummaryListToUpdate = new List<PortfolioCurrencySummary__c>();

        for(PortfolioCurrencySummary__c currencySummary : portfolioCurrencySummaries) {
            if(totalCalculate.containsKey(currencySummary.Portfolio_CurrencyId__c)) {
                currencySummary.Total_Cost__c = currencySummary.Total_Cost__c + totalCalculate.get(currencySummary.Portfolio_CurrencyId__c).get('TotalCost');
                currencySummary.Total_Profit__c = currencySummary.Total_Profit__c + totalCalculate.get(currencySummary.Portfolio_CurrencyId__c).get('TotalProfit');
                portfolioCurrencySummaryListToUpdate.add(currencySummary);
            }

        }

        if(!portfolioCurrencySummaryListToUpdate.isEmpty()) {
            update portfolioCurrencySummaryListToUpdate;
        }

    }

 }

