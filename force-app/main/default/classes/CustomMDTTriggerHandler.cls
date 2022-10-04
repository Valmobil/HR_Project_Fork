public virtual with sharing class CustomMDTTriggerHandler extends TriggerHandler {
    /*
     * This trigger handler class exists as a 'catch-all' trigger handler for
     * objects who's trigger handler logic is actually managed by Custom Metadata

     * Because the Trigger Framework in use is designed to be overridden where needed
     * and because we want to enable incremental changes towards metadata driven
     * trigger logic, we're overriding the run() method here to find and execute
     * the metadata designated trigger logic.
    */

    //bypass handlers for current transaction
    public static Set<String> bypassHandlers = new Set<String>();

    public override void run() {
        /*
         * this loops over each of the trigger handlers identified in the query above, executing them.
         * Please tweet @simongoodyear to ask him about Triggers
         */
        for (TriggerHandler handler : getTriggerHandlers()) {
            // dispatch to the correct handler method
            switch on this.context {
                when BEFORE_INSERT {
                    handler.beforeInsert();
                }
                when BEFORE_UPDATE {
                    handler.beforeUpdate();
                }
                when BEFORE_DELETE {
                    handler.beforeDelete();
                }
                when AFTER_INSERT {
                    handler.afterInsert();
                }
                when AFTER_UPDATE {
                    handler.afterUpdate();
                }
                when AFTER_DELETE {
                    handler.afterDelete();
                }
                when AFTER_UNDELETE {
                    handler.afterUndelete();
                }
            }
        }
    }

    protected List<TriggerHandler> getTriggerHandlers() {
        List<TriggerHandler> result = new List<TriggerHandler>();
        for (TriggersSequence__mdt triggerData : getActiveTriggerHandlerData()) {
            try {
                if(bypassHandlers.contains(triggerData.HandlerName__c)){
                    continue;
                }
                result.add((TriggerHandler) Type.forName(triggerData.HandlerName__c).newInstance());
            } catch (NullPointerException npe) {
                /*
                 * If we fail to instantiate a valid object from the string name, or if
                 * the returned object does not extend TriggerHandler, skip to the next
                 * iteration of the for loop. Might want to at least tell someone.
                 */
                continue;
            }
        }
        return result;
    }

    protected List<TriggersSequence__mdt> getActiveTriggerHandlerData() {
        return [SELECT ExecutionOrder__c, HandlerName__c FROM TriggersSequence__mdt WHERE sObjectType__c = :getSObjectType() AND isActive__c = true ORDER BY ExecutionOrder__c];
    }

    private String getSObjectType() {
        if (Trigger.new != null) {
            return Trigger.new[0].getSObjectType().getDescribe().getName();
        } else {
            return Trigger.old != null ? Trigger.old[0].getSObjectType().getDescribe().getName() : null;
        }
    }
}
