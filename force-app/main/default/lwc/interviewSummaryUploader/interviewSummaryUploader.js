import { LightningElement, api, wire } from 'lwc';
import addInfo from '@salesforce/apex/InterviewSummaryController.addInfo';
import checkJobStatus from '@salesforce/apex/InterviewSummaryController.checkJobStatus';
import deleteUploadedDoc from '@salesforce/apex/InterviewSummaryController.deleteUploadedDoc';
import deleteUploadedDocScheduled from '@salesforce/apex/InterviewSummaryController.deleteUploadedDocScheduled';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

import SUMMARY_OF_QUALIFICATION_FIELD from '@salesforce/schema/Interview_Summary__c.Summary_of_Qualification__c';
import YEARS_OF_EXPERIENCE_FIELD from '@salesforce/schema/Interview_Summary__c.Years_of_Experience__c';
import LEVEL_FIELD from '@salesforce/schema/Interview_Summary__c.Level__c';
import GAPS_FIELD from '@salesforce/schema/Interview_Summary__c.Gaps__c';
import TECHNICAL_ENGLISH_FIELD from '@salesforce/schema/Interview_Summary__c.Technical_English__c';
import HIGH_POTENTIAL_FIELD from '@salesforce/schema/Interview_Summary__c.High_Potential__c';
import POTENTIAL_HIRE_FIELD from '@salesforce/schema/Interview_Summary__c.Potentially_Hire__c';

const INTERVIEW_SUMMARY_FIELDS = [
    SUMMARY_OF_QUALIFICATION_FIELD,
    YEARS_OF_EXPERIENCE_FIELD,
    LEVEL_FIELD,
    GAPS_FIELD,
    TECHNICAL_ENGLISH_FIELD,
    HIGH_POTENTIAL_FIELD,
    POTENTIAL_HIRE_FIELD
];

const DOWNLOAD_LINK_MID = 'sfc/servlet.shepherd/document/download/';
const TOAST_ADDINFO_ERROR_TITLE = 'An unexpected error occured';
const TOAST_COMPLETED_TITLE = 'File updated successfully';
const TOAST_FAILED_TITLE = 'File update failed';
const TOAST_ABORTED_TITLE = 'File update aborted';
const TOAST_BLANK_FIELDS_TITLE = 'Record has blank fields';
const TOAST_COMPLETED_MSG = 'Download will start in a moment';
const TOAST_ABORTED_MSG = 'Update was manually/automatically aborted';
const TOAST_BLANK_FIELDS_MSG = 'The Interview Summary fields should be populated in order to download the file.';
const VARIANT_SUCCESS = 'success';
const VARIANT_WARNING = 'warning';
const VARIANT_ERROR = 'error';
const STATUS_COMPLETED = 'Completed';
const STATUS_FAILED = 'Failed';
const STATUS_ABORTED = 'Aborted';

function showToast(obj, title, message, variant) {
    obj.dispatchEvent(new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    }));
}

export default class HrToolsInterviewSummaryUpload extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;

    @wire(getRecord, {recordId: '$recordId', fields: INTERVIEW_SUMMARY_FIELDS})
    wiredRecord({error, data}) {
        if (error) {
            console.log(JSON.stringify(error));
        } else if (data) {
            const summaryOfQualification = data.fields.Summary_of_Qualification__c.value;
            const yearsOfExperience = data.fields.Years_of_Experience__c.value;
            const level = data.fields.Level__c.value;
            const gaps = data.fields.Gaps__c.value;
            const technicalEnglish = data.fields.Technical_English__c.value;
            const highPotential = data.fields.High_Potential__c.value;
            const potentialHire = data.fields.Potentially_Hire__c.value;
            const allFieldsArePopulated = summaryOfQualification && yearsOfExperience &&
                level && gaps && technicalEnglish && highPotential && potentialHire;
            if (!allFieldsArePopulated) {
                showToast(this, TOAST_BLANK_FIELDS_TITLE ,TOAST_BLANK_FIELDS_MSG, VARIANT_WARNING);
            }
            this.isUploadFilesDisabled = allFieldsArePopulated ? false : true;
        }
    }

    acceptedFormats = ['.xlsx', '.xlsm'];
    isAddInfoDisabled = true;
    isUploadFilesDisabled = true;
    isDownloadDisabled = true;
    isProcessOngoing = false;
    downloadLink;
    fileData;
    jobId;
    

    getBaseUrl(){
        return 'https://'+location.host+'/';
    }

    handleUploadFinished(event){
        this.fileData = event.detail.files[0];
        this.isAddInfoDisabled = false;
        deleteUploadedDocScheduled({documentId: this.fileData.documentId, documentName: this.fileData.name});
    }

    handleAddInfo(){
        this.isAddInfoDisabled = true;
        addInfo({
            summaryId: this.recordId,
            documentId: this.fileData.documentId
        })
        .then(result => {
            this.downloadLink = this.getBaseUrl() + DOWNLOAD_LINK_MID + this.fileData.documentId;
            this.jobId = result;
            this.isProcessOngoing = true;
            this.checkFileReadiness(this);
        })
        .catch(error => {
            showToast(this, TOAST_ADDINFO_ERROR_TITLE, error.body.message, VARIANT_ERROR);
            this.isAddInfoDisabled = false;
        });
    }

    checkFileReadiness(obj) {
        checkJobStatus({jobId: obj.jobId})
        .then(result => {
            let status = result[0];
            if (status == STATUS_COMPLETED) {
                showToast(obj, TOAST_COMPLETED_TITLE, TOAST_COMPLETED_MSG, VARIANT_SUCCESS);
                obj.isDownloadDisabled = false;
                obj.isProcessOngoing = false;
                obj.handleDownloadInfo();
            }
            else if (status == STATUS_FAILED) {
                showToast(obj, TOAST_FAILED_TITLE, result[1], VARIANT_ERROR);
                obj.isProcessOngoing = false;
                deleteUploadedDoc({documentId: obj.fileData.documentId});
            }
            else if (status == STATUS_ABORTED) {
                showToast(obj, TOAST_ABORTED_TITLE, TOAST_ABORTED_MSG, VARIANT_WARNING);
                obj.isProcessOngoing = false;
                deleteUploadedDoc({documentId: obj.fileData.documentId});
            }
            else {
                setTimeout(obj.checkFileReadiness, 3000, obj);
            }
        })
        .catch(error => {
            showToast(obj, TOAST_ADDINFO_ERROR_TITLE, error.body.message, VARIANT_ERROR);
            obj.isAddInfoDisabled = false;
        });
    }

    handleDownloadInfo(){
        open(this.downloadLink, '_blank');
    }
}