@IsTest
public with sharing class TransactionControllerTest {
    @IsTest
    static void testCreateTransaction() {

        Portfolio__c testPortfolio =  new Portfolio__c(Name = 'Test');
        insert testPortfolio;

        Map<String, Object> transactionDataMap = new Map<String, Object>{
                    'portfolioId' => testPortfolio.Id,
                    'typeTransaction' => 'Buy',
                    'quantityTransaction' => '500.0',
                    'amountTransaction' => '200.0',
                    'symbol' => 'Test'
        };

        String testDataTransaction = JSON.serialize(transactionDataMap);

        TransactionController.createTransaction(testDataTransaction);

        List<Transaction__c> transactionsAfterTest =  [
            SELECT
                 Id, Name, Amount__c, Quantity__c, Type_Transaction__c, Price_Per_Coin__c, CreatedDate, Symbol__c
            FROM 
                Transaction__c
        ];
        
        Assert.areEqual(1, transactionsAfterTest.size(), 'Transaction size should be 1');
        for( Transaction__c txn : transactionsAfterTest) {
            Assert.isNotNull(txn.Id, 'Transaction Id should not be null');
            Assert.areEqual(transactionDataMap.get('typeTransaction'), txn.Type_Transaction__c, 'Type transaction is not the same');
            Decimal expectedQuantity =  Decimal.valueOf((String)transactionDataMap.get('quantityTransaction'));
            Assert.areEqual(expectedQuantity, txn.Quantity__c, 'Quantity transaction is not the same'); 
            Decimal expectedAmount = Decimal.valueOf((String)transactionDataMap.get('amountTransaction'));
            Assert.areEqual(expectedAmount, txn.Amount__c, 'Quantity transaction is not the same'); 

        }
    }

    @IsTest
    static void testCreateTransactionWithPortfoliCurrencyoId() {

        List<Portfolio_Currency__c> testPortfolioCurrencies = TestFactoryData.createPortfoliosWithPortfolioCurrencies(1);

        Map<String, Object> transactionDataMap = new Map<String, Object>{
            'portfolioCurrencyId' => testPortfolioCurrencies[0].Id,
            'typeTransaction' => 'Buy',
            'quantityTransaction' => '500.0',
            'amountTransaction' => '200.0',
            'symbol' => 'Test'
            };

        String testDataTransaction = JSON.serialize(transactionDataMap);    

        TransactionController.createTransaction(testDataTransaction);

        List<Transaction__c> transactionsAfterTest =  [
            SELECT
                 Id, Name, Amount__c, Quantity__c, Type_Transaction__c, Portfolio_CurrencyId__c, Price_Per_Coin__c, CreatedDate, Symbol__c
            FROM 
                Transaction__c
        ];

        Assert.areEqual(1, transactionsAfterTest.size(), 'Transaction size should be 1');
        for( Transaction__c txn : transactionsAfterTest) {
            Assert.isNotNull(txn.Id, 'Transaction Id should not be null');
                
            Assert.areEqual(testPortfolioCurrencies[0].Id, txn.Portfolio_CurrencyId__c, 
                            'Expected Portfolio Currency Id: ' + testPortfolioCurrencies[0].Id + 
                            ', but found: ' + txn.Portfolio_CurrencyId__c + 
                            '. Ensure that the Portfolio Currency record is correctly linked to the transaction.');

            Assert.areEqual(transactionDataMap.get('typeTransaction'), txn.Type_Transaction__c, 'Type transaction is not the same');
            Decimal expectedQuantity =  Decimal.valueOf((String)transactionDataMap.get('quantityTransaction'));
            Assert.areEqual(expectedQuantity, txn.Quantity__c, 'Quantity transaction is not the same'); 
            Decimal expectedAmount = Decimal.valueOf((String)transactionDataMap.get('amountTransaction'));
            Assert.areEqual(expectedAmount, txn.Amount__c, 'Quantity transaction is not the same'); 

        }

    }   
}