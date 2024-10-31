public class CryptoData {

    public String Response;
    public String Message;
    public Boolean HasWarning;
    public Integer Type;
    public Map<String, Object> RateLimit;
    public  Map<String, Price> Data = new Map<String,CryptoData.Price>(); 
    public String ParamWithError;

    public class Price{
        public Decimal USD;
    }

    public static CryptoData parse(String json) {
        return (CryptoData) System.JSON.deserialize(json, CryptoData.class);
    }
   
}