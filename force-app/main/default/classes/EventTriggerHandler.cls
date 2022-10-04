public with sharing class EventTriggerHandler extends TriggerHandler {
    private Map<Id, Event> newMap;
    private Map<Id, Event> oldMap;
    
    public EventTriggerHandler() {
        this.oldMap = (Map<Id, Event>) Trigger.oldMap;
        this.newMap = (Map<Id, Event>) Trigger.newMap;
    }

    public override void beforeUpdate() {
        protectOutlookEvents(this.newMap.values());
    }

    public override void beforeDelete() {
        protectOutlookEvents(this.oldMap.values());
    }

    private void protectOutlookEvents(List<Event> events) {
        Map<Id,String> eventRecTypesById = Utils.recordTypeMap(Constants.OBJECT_TYPE_EVENT);
        for(Event event : events){
            if(eventRecTypesById.get(event.RecordTypeId) != null) {
                if(Constants.RECORD_TYPE_OUTLOOK_EVENT == (eventRecTypesById.get(event.RecordTypeId)) 
                    && (event.Description == null || !event.Description.startsWith(Constants.OUTLOOL_EVENT_MARK_FOR_DELETION))) {
                    event.addError(Constants.OUTLOOK_EVENT_MODIFICATION_ERROR);
                }
            }      
        }
    }
}
