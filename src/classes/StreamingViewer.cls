public class StreamingViewer {
    
    public SelectOption[] operationsOptions { get; private set; }
    public SelectOption[] fieldsOptions { get; private set; }
    public PushTopic[] topics { get; set; }
    public PushTopic editTopic { get; set; }
    public String deleteId { get; set; }
    
    public StreamingViewer() {
        operationsOptions = getSelectOptions(PushTopic.fields.NotifyForOperations);
        fieldsOptions = getSelectOptions(PushTopic.fields.NotifyForFields);
        topics = getTopics();
        initEditTopic();
    }
    
    private void initEditTopic() {
        editTopic = new PushTopic(
            ApiVersion = 24,
            NotifyForOperations = 'All',
            NotifyForFields = 'All'
        );
    }
    
    public PageReference saveTopic() {
        try {
            upsert editTopic;
            initEditTopic();
            topics = getTopics();
            PageReference page = ApexPages.currentPage();
            page.setRedirect(true);
            return page;
        } catch (DMLException e) {
            return null;
        }
    }
    
    private static PushTopic[] getTopics() {
        return [
            SELECT 
                Id, Name, Query, ApiVersion, NotifyForOperations, NotifyForFields, Description
            FROM PushTopic
            ORDER BY SystemModstamp DESC
            LIMIT 20
        ];
    }
    
    private static SelectOption[] getSelectOptions(SObjectField field) {
        SelectOption[] options = new SelectOption[0];
        DescribeFieldResult f = field.getDescribe();
        PicklistEntry[] entries = f.getPicklistValues();
        for (PicklistEntry e : entries) {
            options.add(new SelectOption(e.getValue(), e.getValue()));
        }
        return options;
    }
    
    public void deleteTopic() {
        Id tid = ApexPages.currentPage().getParameters().get('id');
        Map<Id, PushTopic> m = new Map<Id, PushTopic>(topics);
        delete m.remove(tid);
        topics = getTopics();
    }
    
}