import { LightningElement, track } from 'lwc';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import getInvestmentDetails from '@salesforce/apex/CryptoInvestorController.getInvestmentDetails';
import getDataTableDetails from '@salesforce/apex/CryptoInvestorController.getDataTableDetails';
import CreatePortfolioModal from 'c/createPortfolioModal';
import createPortfolio from '@salesforce/apex/PortfolioController.createPortfolio';
import deletePortfolio from '@salesforce/apex/PortfolioController.deletePortfolio';
import createTransaction from '@salesforce/apex/TransactionController.createTransaction';
import CreateTransactionModal from 'c/createTransactionModal';
import BuyOrSellModal  from 'c/buyOrSellModal';

const ACTIONS = [
    { label: 'Buy', name: 'buy_token' },
    { label: 'Sell', name: 'sell_token' },
];
const COLUMNS = [
    {label: 'Name', fieldName : 'name'},
    {label: 'Price', fieldName : 'price'},
    {label: 'Holdings', fieldName : 'holdings'},
    {label: 'Spent', fieldName : 'spending'},
    {label: 'Avg. Buy Price', fieldName : 'average'},
    {label: 'Profit/Loss', fieldName : 'profitAndLoss'},
    
    {
        type: 'action',
        typeAttributes: { rowActions: ACTIONS },
    },
];

const PAGE_SIZE = 10;
const SYMBOL_USD = '$';

export default class CryptoInvestor extends LightningElement {
   
    @track amountInvestments = `0.00 ${SYMBOL_USD}`;
    @track currencyBalance = `0.00 ${SYMBOL_USD}`;
    @track todayPnl = `0.00 ${SYMBOL_USD}`;
    @track averageProfitAndLoss = `0.00${SYMBOL_USD}`;

    @track selectedPortfolio = {};
    @track portfolios = [];
    @track dataTable = [];
    priceList= [];
    
    columns = COLUMNS;

    
    isLoading = false;
    isMenuOpen = false;
    @track isPaginator = false;
    
    @track pageNumber = 1;
    @track numberOfPages;
    startingPageIndex = 1;
    endingPageIndex = 0;
    totalRecordCount;
    
    connectedCallback(){
        this.loadDetails();    
    }

    loadDetails(){
        this.isLoading = true;
        getInvestmentDetails({})
        .then(result => {
            this.amountInvestments = `${result.totalBalanceInvestment} ${SYMBOL_USD}`;
            this.currencyBalance = `${result.currencyBalance} ${SYMBOL_USD}`;
            this.portfolios = result.portfolios;
            
        })
        .catch(error => {
            this.showToast('Error', error.body.message, 'error');
        })
        .finally(() => {
            this.updateUI();
            this.isLoading = false;
        });
        
    }

    updateUI() {
        if(this.portfolios.length > 0){
            this.selectedPortfolio = this.portfolios[0];
            this.handleSelectPortfolio({currentTarget: {dataset: {id: this.selectedPortfolio.Id}}});
        }
        this.toggleButtonNewPortfolio();
        this.toggleDataTable();
    }

    toggleButtonNewPortfolio(){
        const newPortfolioButton = this.template.querySelector('.button-new');
        if (newPortfolioButton) {
            newPortfolioButton.classList.toggle('slds-hide', this.portfolios.length === 0);
        }
        
    }

    toggleDataTable() {
        const emptyState = this.template.querySelector('.table__empty-state');
        const dataTableContainer = this.template.querySelector('.data-table-container');

        if (this.portfolios.length > 0) {
            emptyState.classList.add('slds-hide');
            dataTableContainer.classList.remove('slds-hide');
        } else {
            emptyState.classList.remove('slds-hide');
            dataTableContainer.classList.add('slds-hide');
        }
    }


    async handleCreatePortfolio() {
        const result = await CreatePortfolioModal.open({
            size: 'Small',
            label: 'Create Portfolio',
            description: 'Please enter the name of the new portfolio',
        });

        createPortfolio({ name: result.label})
            .then(created => {
                this.portfolios = [...this.portfolios, created];
                this.showToast('Success', 'Portfolio created successfully', 'success');
                
            })
            .catch(error =>{
                this.showToast('Error', 'Portfolio creation failed', 'error');
            })
            .finally(() =>{
                this.toggleDataTable();
                this.selectedPortfolio = this.portfolios[this.portfolios.length - 1];
                this.handleSelectPortfolio({currentTarget: {dataset: {id: this.selectedPortfolio.Id}}});
            });
             
    }

    
    handleSelectPortfolio(event) {
        const portfolioId = event.currentTarget.dataset.id;
        this.selectedPortfolio = this.portfolios.find(portfolio => portfolio.Id == portfolioId);
        console.log(JSON.stringify( this.selectedPortfolio));
        this.updatePortfolioHighlight(portfolioId);
        this.loadPortfolioDetails(portfolioId); 
    }

    async loadPortfolioDetails(portfolioId) {
        console.log(portfolioId);
        await getDataTableDetails({ portfolioId: portfolioId })
            .then(result => {

                 this.priceList = this.createdPriceListToDataTable(result);
 
                this.totalRecordCount = this.priceList.length;
                this.numberOfPages = Math.ceil(this.totalRecordCount / PAGE_SIZE);
                this.displayRecordPerPage(this.pageNumber);  

                this.calculateAverageProfitAndLoss(this.priceList);
            })
            .catch(error => {
                console.error('Error loading dataTable:', error);
            });

    }
    
    createdPriceListToDataTable(data) {
        console.log(JSON.stringify(data))
        return data.map(item => {
            let totalQuantity = parseFloat(item.totalQuantity) || 0; 
            let totalCost = parseFloat(item.totalCost) || 0;  
            let average = totalQuantity > 0 ? (totalCost / totalQuantity).toFixed(4) : '0.00';
            return {
                Id: item.portfolioCurrencyId,
                name: item.symbol,
                price: `$${parseFloat(item.price).toFixed(2)}`, 
                holdings: `${totalQuantity}`,
                spending: `$${totalCost.toFixed(4)}`, 
                average: `$${average}`, 
                profitAndLoss: this.calculateProfitAndLoss(item), 
            };
        });

        
    }

    calculateProfitAndLoss(item) {
        let currentPrice = parseFloat(item.price.replace(/\$/g, ''));
        let totalQuantity = parseFloat(item.totalQuantity);
        let totalCost = parseFloat(item.totalCost);
    
        if (!totalQuantity || !totalCost || !currentPrice) {
            return '$0.00'; 
        }
    
        let profitAndLoss = (currentPrice - (totalCost / totalQuantity)) * totalQuantity;
    
        return `$${profitAndLoss.toFixed(4)}`;
    }
    

    calculateAverageProfitAndLoss(priceList) {
        let profitAndLossValues = priceList.map(item => parseFloat(item.profitAndLoss.replace(/\$/g, '')));
        this.averageProfitAndLoss = profitAndLossValues.reduce((total, value) => total + value, 0);
        this.averageProfitAndLoss = this.averageProfitAndLoss.toFixed(4);

        this.updateProfitLossStyle(this.averageProfitAndLoss);
    }

    updateProfitLossStyle(value)  {
        const textElement = this.template.querySelector('.profit-indicator__value');
        const iconDown = this.template.querySelector('.icon-down');
        const iconUp = this.template.querySelector('.icon-up');

        if(textElement && iconDown && iconUp) { 
                     
            iconUp.classList.add('slds-hide');
            iconDown.classList.add('slds-hide');
            textElement.style.color = 'black';

            if(value > 0) {
                iconUp.classList.remove('slds-hide');
                textElement.style.color = '#0eff00';
            } else if(value < 0) {
                iconDown.classList.remove('slds-hide');
                textElement.style.color = 'red';
            }else{
                profitIndicator.style.color = 'black';
                iconUp.classList.add('slds-hide');
                iconDown.classList.add('slds-hide');
            }
        }

    }

    displayRecordPerPage(page) {
    
        page = Math.max(1, Math.min(page, this.numberOfPages));

        this.pageNumber = page;
    
        this.startingPageIndex = parseFloat(page - 1) * PAGE_SIZE;
        this.endingPageIndex = Math.min(page * PAGE_SIZE, this.priceList.length);

        this.dataTable = this.priceList.slice(this.startingPageIndex, this.endingPageIndex);
    
        this.isPaginator = this.priceList.length >= (parseFloat(PAGE_SIZE+1));
        
    }
    

    
    prevHandler(event) {
        if (this.pageNumber > 1) {
            this.pageNumber -= 1;
            this.displayRecordPerPage(this.pageNumber);
        }
    }

    nextHandler(event) {
        if (this.pageNumber < this.numberOfPages) {
            this.pageNumber += 1;
            this.displayRecordPerPage(this.pageNumber);
        }
    }

    updatePortfolioHighlight(portfolioId) {
    
        const previouslySelectedElement = this.template.querySelector('.is-selected');
        const currentlySelectedElement = this.template.querySelector(`[data-id="${portfolioId}"]`);
    
        this.togglePortfolioSelection(previouslySelectedElement);
        this.togglePortfolioSelection(currentlySelectedElement);
    }
    
    togglePortfolioSelection(element) {
        if (!element) return;
    
        element.classList.toggle('is-selected');
        element.classList.toggle('is-active');
    
        const threeDotsButton = element.querySelector('.sidebar-item_button-threedots');
        if (threeDotsButton) {
            threeDotsButton.classList.toggle('slds-hide');
        }
    }
    

    async handleCreateTransaction() {
        const resultTransactionModal = await CreateTransactionModal.open({
            size: 'Small',
            label: 'New Transaction',
            description: 'Enter transaction details',
        });
         
        if(resultTransactionModal){
            let transactionData = {
                portfolioId:  this.selectedPortfolio.Id,
                typeTransaction: 'Buy',
                quantityTransaction: resultTransactionModal.quantityTransaction,
                amountTransaction: resultTransactionModal.amountTransaction,
                symbol: resultTransactionModal.symbolTransaction    
             };

            await this.handleTransactionCreation(transactionData);
           
        }else{
            this.showToast('Error','Incorrectly entered parameters','error');
        }

    }


    async handleTransactionCreation(transactionData) {

        createTransaction({data: JSON.stringify(transactionData)})
        .then(response => {
            this.handleSelectPortfolio({currentTarget: {dataset: {id: this.selectedPortfolio.Id}}});
            this.showToast('Success', 'Transaction completed', 'success');
        })
        .catch(error =>{
            console.error('Error creating transaction:', error);
        })
    }



    
    handleThreedots() {
        this.isMenuOpen = !this.isMenuOpen;
    }

    

    handleRename() {
        console.log('Rename clicked');
        this.closeMenu();
    }

    handleDelete() {
        this.closeMenu();
        if(this.selectedPortfolio.Id) {
            deletePortfolio({portfolioId: this.selectedPortfolio.Id})
            .then(result => {
                this.showToast('Success', `Portfolio ${this.selectedPortfolio.Name} was successfully deleted.`, 'success');
                this.loadDetails();
            })
            .catch(error =>{
                let errorMessage = error.body ? error.body.message : 'An unexpected error occurred during portfolio deletion.';
                this.showToast('Error', `Failed to delete portfolio. Error: ${errorMessage}`, 'error');
            })
        }else{
            this.showToast('Error', 'Invalid Portfolio ID. Please select a valid portfolio and try again.', 'error');
        }

       
    }
    
    closeMenu() {
        this.isMenuOpen = false;
    }



    handleRowAction(event) {
        const actionType = event.detail.action.name;
        const token = event.detail.row;

        switch (actionType) {
            case 'buy_token':
                const buyingDetails = this.createTransactionDetails(token, 'Buy', 'success');
                this.openTransactionModal(buyingDetails);             
                break;
            case 'sell_token':
                const sellingData = this.createTransactionDetails(token, 'Sell', 'destructive');
                this.openTransactionModal(sellingData);
                break;
            default:
        }
    }

    createTransactionDetails(tokenData, transactionType, transactionVariant) {
        const cleanPrice = (price) => price.replace(/\$/g, '');

        return {
            id: tokenData.Id,
            name: tokenData.name,
            type: transactionType,
            variant: transactionVariant,
            price: cleanPrice(tokenData.price),
            holdings: tokenData.holdings,
            average: cleanPrice(tokenData.average),
            profitAndLoss: cleanPrice(tokenData.profitAndLoss),
            totalProfitAndLoss: tokenData.totalProfitAndLoss
        };
    }

    openTransactionModal(transaction) {
        BuyOrSellModal.open({transaction: transaction})
        .then(result => {
            this.handleSelectPortfolio({currentTarget: {dataset: {id: this.selectedPortfolio.Id}}});
            this.showToast('Transaction Successful','The transaction was completed successfully.', 'success');
        }).catch(error => {
            this.showToast('Transaction Failed', `An error occurred: ${error.message}`, 'error');
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