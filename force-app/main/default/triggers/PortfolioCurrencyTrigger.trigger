trigger PortfolioCurrencyTrigger on Portfolio_Currency__c (before insert, after insert) {
    
    if(Trigger.isBefore && Trigger.isInsert) {
        PortfolioCurrencyTriggerHandler.handleUpdatePortfolioCurrencyName(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isInsert) {
        PortfolioCurrencyTriggerHandler.createPortfolioCurrencySummary(Trigger.new);
    }
}