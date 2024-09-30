public with sharing class TransactionController {

    @AuraEnabled
    public static void createTransaction(String data) {
        Map<String, Object> transactionData = (Map<String, Object>) JSON.deserializeUntyped(data);

        Transaction__c newTransaction = new Transaction__c();
        newTransaction.Type_Transaction__c = (String) transactionData.get('typeTransaction');
        newTransaction.Amount__c =  Decimal.valueOf((String) transactionData.get('amountTransaction'));
        newTransaction.Quantity__c = (Decimal) transactionData.get('quantityTransaction');
        newTransaction.Portfolio_CurrencyId__c = isValidPortfolioCurrencyId(transactionData);

        insert newTransaction;

    }

    public static Id isValidPortfolioCurrencyId(Map<String, Object> transactionData){

        Id portfolioCurrencyId = (Id) transactionData.get('portfolioCurrencyId');
        if(portfolioCurrencyId == null){
            portfolioCurrencyId = PortfolioCurrencyController.createPortfolioCurrency(transactionData);
        }
        
        return portfolioCurrencyId;
    } 

}
