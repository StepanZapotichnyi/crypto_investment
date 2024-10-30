@IsTest
private class CryptoDataTest {
    @IsTest
    static void testParseValidJson() {

        String json = '{"Response":"Success",'+
                        '"Message":"Data fetched successfully",'+
                        '"HasWarning":false,'+
                        '"Type":1,"RateLimit":{},'+
                        '"Data":{"BTC":{"USD":60000.50},'+
                                '"ETH":{"USD":4000.75}},'+
                        '"ParamWithError":null}';

        CryptoData result = CryptoData.parse(json);

        Assert.areNotEqual(null, result, 'Parsed result should not be null');
        Assert.areEqual('Success', result.Response, 'Response should be Success');
        Assert.areEqual('Data fetched successfully', result.Message, 'Message should match');
        Assert.areEqual(false, result.HasWarning, 'HasWarning should be false');
        Assert.areEqual(1, result.Type, 'Type should be 1');
        Assert.areNotEqual(null, result.RateLimit, 'RateLimit should not be null');
        Assert.areNotEqual(null, result.Data, 'Data should not be null');
        
        CryptoData.Price btcPrice = result.Data.get('BTC');
        Assert.areNotEqual(null, btcPrice, 'BTC Price should not be null');
        Assert.areEqual(60000.50, btcPrice.USD, 'BTC USD price should match');

        CryptoData.Price ethPrice = result.Data.get('ETH');
        Assert.areNotEqual(null, ethPrice, 'ETH Price should not be null');
        Assert.areEqual(4000.75, ethPrice.USD, 'ETH USD price should match');
        
    }

}