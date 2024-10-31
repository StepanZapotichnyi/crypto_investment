@IsTest
private class PortfolioCryptoServiceTest {
    @IsTest 
    static void testRetrievePortfolioCryptoData() {
        String testMock = TestFactoryData.createCryptoDataMockString();

        Test.setMock(HttpCAlloutMock.class, new PortfolioCryptoServiceMock(200, testMock));
        
        Test.startTest();
        Map<String, CryptoData.Price> result = PortfolioCryptoService.retrievePortfolioCryptoData();
        Test.stopTest();

        Integer count = 0;

        for (String key : result.keySet()) {
            String testSymbol = 'TEST' + count;
            Assert.areEqual(testSymbol, key, 'Expected key: ' + testSymbol + ', but received key: ' + key);
            count++;
        }
    }


    @isTest
    static void testDeserializeResponseWithError() {

        String testErrorMessage = 'Error retrieving crypto data.';
        String testErrorJson = '{"Response":"Error","Message":"'+testErrorMessage+'","HasWarning":false,"Type":1,"RateLimit":{},"Data":{},"ParamWithError":null}';
        
        List<String> testBody = new List<String> { testErrorJson };

        List<CryptoData> result = PortfolioCryptoService.deserializeResponse(testBody);

        Assert.areEqual(1, result.size(), 'There should be one CryptoData object');

        CryptoData cryptoData = result[0];
        Assert.areEqual('Error', cryptoData.Response, 'Response should be Error');
        Assert.areEqual(testErrorMessage , cryptoData.Message, 'Message should match');
        Assert.areEqual(0, cryptoData.Data.size(), 'Data should be empty for an error response');
    }


    @IsTest
    static void testCombineCryptoResponsesWithErrors() {
        String testErrorMessage = 'Error retrieving crypto data.';
        String  testErrorJson = '{"Response":"Error","Message":"'+testErrorMessage+'","HasWarning":false,"Type":1,"RateLimit":{},"Data":{},"ParamWithError":null}';
        
        List<String> testBody = new List<String> { testErrorJson };
 
        try {
            PortfolioCryptoService.combineCryptoResponses(testBody);
        } catch (PortfolioCryptoService.PortfolioCryptoServiceException e) {
            Assert.areEqual(testErrorMessage, e.getMessage(), 'Exception message should match');
        }
    }
}