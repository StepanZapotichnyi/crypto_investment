@IsTest
public class CryptoDataTest {
    
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

        System.assertNotEquals(null, result, 'Parsed result should not be null');
        System.assertEquals('Success', result.Response, 'Response should be Success');
        System.assertEquals('Data fetched successfully', result.Message, 'Message should match');
        System.assertEquals(false, result.HasWarning, 'HasWarning should be false');
        System.assertEquals(1, result.Type, 'Type should be 1');
        System.assertNotEquals(null, result.RateLimit, 'RateLimit should not be null');
        System.assertNotEquals(null, result.Data, 'Data should not be null');
        
        CryptoData.Price btcPrice = result.Data.get('BTC');
        System.assertNotEquals(null, btcPrice, 'BTC Price should not be null');
        System.assertEquals(60000.50, btcPrice.USD, 'BTC USD price should match');

        CryptoData.Price ethPrice = result.Data.get('ETH');
        System.assertNotEquals(null, ethPrice, 'ETH Price should not be null');
        System.assertEquals(4000.75, ethPrice.USD, 'ETH USD price should match');
        
    }

}