import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import verifyTokenSymbol from '@salesforce/apex/PortfolioUtility.verifyTokenSymbol';
import  LightningModal  from 'lightning/modal';


export default class CreateTransactionModal extends LightningModal {
    
    symbolTransaction = '';
    quantityTransaction = 0;
    amountTransaction = 0;
    
    handleTokenSymbolChange(event) {
        this.symbolTransaction =  event.target.value;
    }

    handleQuantityChange(event) {
        this.quantityTransaction =  parseFloat(event.target.value);
    }
    handleAmountChange(event) {
        this.amountTransaction = parseFloat(event.target.value);
    }
    
    
    handleAddTransaction() {
        
        if (this.validateFields()) {
            return; 
        }
    
        verifyTokenSymbol({ symbol: this.symbolTransaction.toUpperCase() })
            .then(response => {
                this.handleTransactionSuccess(response);
            })
            .catch(error => {
                this.showToast('Error',error.body.message,'error');
            });    
    }

    validateFields() {
        return !this.symbolTransaction 
        ? (this.showToast('Error', 'Symbol field should not be empty', 'error'), true)
        : !this.quantityTransaction 
        ? (this.showToast('Error', 'Quantity field should not be empty', 'error'), true)
        : !this.amountTransaction 
        ? (this.showToast('Error', 'Amount field should not be empty', 'error'), true)
        : false;
    }

    handleTransactionSuccess(response) {
        this.close({
            symbolTransaction: response,
            quantityTransaction: this.quantityTransaction,
            amountTransaction: this.amountTransaction
        }); 
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

}