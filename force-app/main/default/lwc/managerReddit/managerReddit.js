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
import { LightningElement, wire } from 'lwc';
import getRedditItems from '@salesforce/apex/managerReddit.getRedditItems'

const columns = [
    { label:'Author fullname', fieldName: 'author_fullname__c'},
    { label:'Title', fieldName: 'title__c'},
    { label:'Thumbnail', fieldName: 'thumbnail__c'},
    { label:'Selftext', fieldName: 'selftext__c'}
];
export default class ManagerReddit extends LightningElement {

        columns = columns;
        rowOffset = 0;

        @wire(getRedditItems)
        redditItems;
}