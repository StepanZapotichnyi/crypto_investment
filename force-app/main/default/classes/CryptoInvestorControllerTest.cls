@IsTest
public with sharing class CryptoInvestorControllerTest {
   @IsTest
    static void testGetInvestmentDetails() {

        Map<String, Decimal> testDataTransaction = new Map<String, Decimal>{
            'testQuantityBuy' => 100,
            'testQuantitySell' => 50,
            'testAmountBuy' => 100,
            'testAmountSell' => 50
        };

        List<Transaction__c> testTransactions = TestFactoryData.createTransactions(testDataTransaction);

        String testMock = TestFactoryData.createCryptoDataMockString();

        Test.setMock(HttpCAlloutMock.class, new PortfolioCryptoServiceMock(200, testMock));
        
        Test.startTest();
        CryptoInvestorController.InvestmentDetailsWrapper investorWrapper = CryptoInvestorController.getInvestmentDetails();
        Test.stopTest();

        List<Portfolio__c> portfolios = [SELECT Id, Name FROM Portfolio__c];


        Assert.areEqual(testTransactions.size(), investorWrapper.transactions.size(), 'Transactions size should be equal');
        Assert.areEqual(portfolios.size(), investorWrapper.portfolios.size(), 'Portfolios size should be equal');
        Assert.isNotNull(investorWrapper.totalBalanceInvestment, 'Total balance should be not null (total of all CurrencyBalances)');
        Assert.isNotNull(investorWrapper.currencyBalance, 'Currency balance should be not null (total of all Portfolio_Currencies)');
    }

    @IsTest
    static void testNegativeGetInvestmentDetails() {

        Map<String, Decimal> testDataTransaction = new Map<String, Decimal>{
            'testQuantityBuy' => 100,
            'testQuantitySell' => 50,
            'testAmountBuy' => 100,
            'testAmountSell' => 50
        };


        List<Transaction__c> testTransactions = TestFactoryData.createTransactions(testDataTransaction);

        String testErrorMessage = 'Error retrieving crypto data.';
        String testMock = '{ "error" : "Not found RateSymbol", "message" : "'+testErrorMessage +'"}';
        Integer testStatusCode = 400;

        Test.setMock(HttpCAlloutMock.class, new PortfolioCryptoServiceMock(testStatusCode, testMock));

        try {
            Test.startTest();
                CryptoInvestorController.InvestmentDetailsWrapper investorWrapper = CryptoInvestorController.getInvestmentDetails();
            Test.stopTest();
        } catch (CryptoInvestorController.CryptoInvestorControllerException e) {
                Assert.areEqual(testErrorMessage, e.getMessage(), 'Error message should be the same');
        }

    }

    @IsTest
    static void testGetDataTableDetails() {
        
        Map<String, Decimal> testDataTransaction = new Map<String, Decimal>{
            'testQuantityBuy' => 100,
            'testQuantitySell' => 50,
            'testAmountBuy' => 100,
            'testAmountSell' => 50
        };

        List<Transaction__c> testTransactions = TestFactoryData.createTransactions(testDataTransaction);
        
        String testMock = TestFactoryData.createCryptoDataMockString();

        List<Portfolio__c> testPortfolio = [SELECT Id, Name FROM Portfolio__c ];
    
        Test.setMock(HttpCAlloutMock.class, new PortfolioCryptoServiceMock(200, testMock));
        
        Test.startTest();
        List<PortfolioCurrencyDetails> portfolioCurrencyDetails = CryptoInvestorController.getDataTableDetails(testPortfolio[0].Id);
        Test.stopTest();

        List<Portfolio_Currency__c> portfolioCurrencies = [
            SELECT  
                Id, Name, PortfolioId__c, Symbol__c, Total_Quantity__c 
            FROM
                Portfolio_Currency__c
            WHERE PortfolioId__c = :testPortfolio[0].Id
        ];


        for(PortfolioCurrencyDetails portfolioCurrencyDetail  : portfolioCurrencyDetails) {
            Assert.areEqual(testPortfolio[0].Id, portfolioCurrencyDetail.portfolioId,
            'PortfolioId not found. Expected: ' + testPortfolio[0].Id + ', but got: ' + portfolioCurrencyDetail.portfolioId);
           
            for(Portfolio_Currency__c portfolioCurrency : portfolioCurrencies ) {
                if(portfolioCurrency.Id == portfolioCurrencyDetail.portfolioCurrencyId){
                    System.debug('work');
                    Assert.areEqual(portfolioCurrency.Id, portfolioCurrencyDetail.portfolioCurrencyId,
                    'Id not found. Expected: ' + portfolioCurrency.Id + ', but got: ' + portfolioCurrencyDetail.portfolioCurrencyId);
                    Assert.areEqual(portfolioCurrency.Symbol__c, portfolioCurrencyDetail.symbol,
                    'Symbol not found. Expected: ' + portfolioCurrency.Symbol__c + ', but got: ' + portfolioCurrencyDetail.symbol);
                    Assert.areEqual(String.valueOf(portfolioCurrency.Total_Quantity__c), String.valueOf(portfolioCurrencyDetail.totalQuantity),
                    'Total quantity not found. Expected: ' + String.valueOf(portfolioCurrency.Total_Quantity__c) + ', but got: ' + String.valueOf(portfolioCurrencyDetail.totalQuantity));
                }
            
               
            }
        }   
    }
}