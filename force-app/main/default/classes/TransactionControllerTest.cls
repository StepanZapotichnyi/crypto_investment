@IsTest
public with sharing class TransactionControllerTest {
    @IsTest
    static void testCreateTransaction() {

        Portfolio__c testPortfolio =  new Portfolio__c(Name = 'Test');
        insert testPortfolio;

        String testType = 'Buy';
        Decimal testQuantityTransaction = 500;

        String testDataTransaction = '{'+
            '"portfolioId": "'+testPortfolio.Id+'",' +
            '"typeTransaction": "'+testType+'",'+
            '"quantityTransaction": "'+String.valueOf(testQuantityTransaction)+'",'+
            '"amountTransaction": "200",'+
            '"symbol": "Test"'+
            '}';

        TransactionController.createTransaction(testDataTransaction);

        List<Transaction__c> transactionsAfterTest =  [
            SELECT
                 Id, Name, Amount__c, Quantity__c, Type_Transaction__c, Price_Per_Coin__c, CreatedDate, Symbol__c
            FROM 
                Transaction__c
        ];

        Assert.isNotNull(transactionsAfterTest[0].Id, 'Transaction Id should not be null');
        Assert.areEqual(testType, transactionsAfterTest[0].Type_Transaction__c, 'Type transaction is not the same');
        Assert.areEqual(testQuantityTransaction, transactionsAfterTest[0].Quantity__c, 'Quantity transaction is not the same'); 
    }

    @IsTest
    static void testCreateTransactionWithPortfoliCurrencyoId() {

        List<Portfolio_Currency__c> testPortfolioCurrencies = TestFactoryData.createPortfoliosWithPortfolioCurrencies(1);

        String testType = 'Buy';
        Decimal testQuantityTransaction = 500;

        String testDataTransaction = '{'+
            '"portfolioCurrencyId": "'+testPortfolioCurrencies[0].Id+'",' +
            '"typeTransaction": "'+testType+'",'+
            '"quantityTransaction": "'+String.valueOf(testQuantityTransaction)+'",'+
            '"amountTransaction": "200",'+
            '"symbol": "Test"'+
            '}';

        TransactionController.createTransaction(testDataTransaction);

        List<Transaction__c> transactionsAfterTest =  [
            SELECT
                 Id, Name, Amount__c, Quantity__c, Type_Transaction__c, Portfolio_CurrencyId__c, Price_Per_Coin__c, CreatedDate, Symbol__c
            FROM 
                Transaction__c
        ];

        Assert.areEqual(testPortfolioCurrencies[0].Id, transactionsAfterTest[0].Portfolio_CurrencyId__c, 
                  'Id not found. Expected: ' + testPortfolioCurrencies[0].Id + ', but got: ' + transactionsAfterTest[0].Portfolio_CurrencyId__c);
        Assert.areEqual(testType, transactionsAfterTest[0].Type_Transaction__c, 'Type transaction is not the same');
        Assert.areEqual(testQuantityTransaction, transactionsAfterTest[0].Quantity__c, 'Quantity transaction is not the same');
    }   
}