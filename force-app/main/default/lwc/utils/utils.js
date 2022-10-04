import {ShowToastEvent} from "lightning/platformShowToastEvent";

export {cloneObject, showToast, getErrorMessage}

const cloneObject = (obj) => {
    if (!obj) {
        return null;
    }
    return JSON.parse(JSON.stringify(obj));
};

const showToast = (context, title, message, variant) => {
    const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
    });
    context.dispatchEvent(evt);
};

const getErrorMessage = (error) => {
    if (error) {
        if (Array.isArray(error.body)) {
            return error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            return error.body.message;
        }
    }
    else {
        return null;
    }
}