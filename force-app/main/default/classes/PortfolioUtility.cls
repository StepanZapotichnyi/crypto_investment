public with sharing class PortfolioUtility {
    public static final String DATA_PATH =  'data/';
    public static final String PRICE = 'pricemulti?';
    public static final Integer  CURRENCY_STRING_MAX_LENGHT = 290;
    static final Crypto_Endpoind_Data__mdt CRYPTO_ENDPOIND_METADATA = Crypto_Endpoind_Data__mdt.getInstance('Config');
    

    public static List<String> getCryptoSymbols() {
        
        List<Crypto_Endpoind_Data__mdt> cryptoEndpoindData = [SELECT Crypto_Currency_Symbols__c FROM Crypto_Endpoind_Data__mdt];
        List<String> cryptoSymbols = new List<String>(); 

        for(Crypto_Endpoind_Data__mdt mdt :cryptoEndpoindData) {
            cryptoSymbols = Test.isRunningTest() ? TestFactoryData.getTestStringCryptoSymbols()  : mdt?.Crypto_Currency_Symbols__c.replace(' ', '').split(',');
        }

        return cryptoSymbols;
    }


    public static List<String> getContainerCryptoSymbols() {

        List<String> cryptoSymbols = getCryptoSymbols(); 

        List<String> finalSymbols = new List<String>();
        String currencySymbolsContainer = ''; 

        for (String symbol : cryptoSymbols) {
            if (currencySymbolsContainer.length() > CURRENCY_STRING_MAX_LENGHT) {
                currencySymbolsContainer = currencySymbolsContainer.removeEnd(',');
                finalSymbols.add(currencySymbolsContainer);
                currencySymbolsContainer = '';
            }
            currencySymbolsContainer += symbol + ',';
        }

        if(String.isNotBlank(currencySymbolsContainer)) {
            currencySymbolsContainer = currencySymbolsContainer.removeEnd(',');
            finalSymbols.add(currencySymbolsContainer);
        }

        return finalSymbols;   
    }

     public static String getCryptoEndpoint(String cryptoSymbols) {

        String conversionCurrencyPath = '&tsyms=' + CRYPTO_ENDPOIND_METADATA.Conversion_Currency_Symbol__c;
        String cryptoSymbolsPath =  'fsyms=' + cryptoSymbols;  
        
        String endpointUrlToCrypto = CRYPTO_ENDPOIND_METADATA.EndpointUrlForCrypto__c + DATA_PATH + PRICE+ cryptoSymbolsPath + conversionCurrencyPath;
        
        return endpointUrlToCrypto;
    }

    @AuraEnabled
    public static String verifyTokenSymbol(String symbol) {

        List<String> cryptoSymbols = getCryptoSymbols(); 

        for (String token : cryptoSymbols) {
            if (token.equalsIgnoreCase(symbol)) {
                return token;
            }
        }
        
        String errorMessage = 'The symbol ' + symbol + ' is not present in the list of crypto currency symbols.' +
                          '\n' + 'Please add the symbol to the crypto currency list.';
        throw new PortfolioUtilityException(errorMessage);

    }

    public class PortfolioUtilityException extends Exception {
            
    }
}