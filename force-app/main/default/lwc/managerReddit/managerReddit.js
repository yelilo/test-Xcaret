/**
 * @description       :
 * @author            : erika.gaby0922@gmail.com
 * @group             :
 * @last modified on  : 06-12-2023
 * @last modified by  : erika.gaby0922@gmail.com
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   06-12-2023   erika.gaby0922@gmail.com   Initial Version
**/
import { LightningElement, wire, track } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import getRedditItems from '@salesforce/apex/managerReddit.getRedditItems'

const actions = [
    { label: 'Delete', name: 'delete' },
];

const columns = [
    { label:'Id', fieldName: 'Id'},
    { label:'Author fullname', fieldName: 'author_fullname__c', sortable: true,},
    { label:'Title', fieldName: 'Title__c', sortable: true,},
    { label:'Thumbnail', fieldName: 'thumbnail__c'},
    { label:'Selftext', fieldName: 'selftext__c'},
    { label:'Created Date', fieldName: 'CreatedDate', sortable: true,},
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];
export default class ManagerReddit extends LightningElement {
    @track data;
    @track columns = columns;
    @track sortDirection;
    @track sortBy;

    @wire(getRedditItems)
    redditItems(result){
        if (result.data) {
            this.data = result.data;
        } else {
            this.error = result.error;
        }
    };

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }

    reload() {
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 1000);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('>>> [handleRowAction] row: ', row);
        this.deleteRow(row);
    }

    deleteRow(row) {
        const registroid = row.Id;
            console.log('>>> [deleteRow] id: ', row.Id);
        deleteRecord(registroid).then(result => {
            this.reload();
        });
    }

}