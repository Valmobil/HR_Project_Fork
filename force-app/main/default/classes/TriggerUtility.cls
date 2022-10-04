public with sharing class TriggerUtility {
    public static Boolean isFieldValueChanged(SObject newObject, SObject oldObject, String fieldAPIName) {
        return isFieldsValueChanged(newObject, oldObject, new Set<String>{ fieldAPIName });
    }

    public static Boolean isFieldsValueChanged(SObject newObject, SObject oldSobject, Set<String> fieldAPINames) {
        for (String fieldAPIName : fieldAPINames) {
            if (newObject.get(fieldAPIName) != oldSobject.get(fieldAPIName)) {
                return true;
            }
        }
        return false;
    }

    public static Boolean isFieldsValueChangedOrNull(SObject newObject, SObject oldSobject, Set<String> fieldAPINames) {
        for (String fieldAPIName : fieldAPINames) {
            if (newObject.get(fieldAPIName) != oldSobject.get(fieldAPIName) || newObject.get(fieldAPIName) == null) {
                return true;
            }
        }
        return false;
    }

    public static Boolean isFieldValueChangedOrPopulated(SObject newObject, SObject oldObject, String fieldAPIName) {
        return isFieldValuesChangedOrPopulated(newObject, oldObject, new Set<String>{ fieldAPIName });
    }

    public static Boolean isFieldValuesChangedOrPopulated(SObject newObject, SObject oldObject, Set<String> fieldAPINames) {
        if (oldObject == null) {
            return true;
        }
        return isFieldsValueChanged(newObject, oldObject, fieldAPINames);
    }
}
