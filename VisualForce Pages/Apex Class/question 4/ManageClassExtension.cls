public class ManageClassExtension {
    public Class__c selectedClass { get; set; }
    public Boolean showEditForm { get; set; }
    public String editClassId { get; set; }
    public String deleteClassId { get; set; }
    
    // Constructor
    public ManageClassExtension() {
        selectedClass = new Class__c();
        showEditForm = false;
    }

    public ApexPages.StandardSetController objController {
        get {
            if (objController == null) {
                List<Class__c> classList = [SELECT Id, Name, MaxLimit__c, My_Count__c, CreatedDate 
                                          FROM Class__c 
                                          ORDER BY CreatedDate DESC];
                objController = new ApexPages.StandardSetController(classList);
                objController.setPageSize(10);
            }
            return objController;
        }
        set;
    }

    public List<Class__c> getClasses() {
        return (List<Class__c>)objController.getRecords();
    }

    // Edit functionality
    public PageReference editClassById() {
        try {
            if (String.isNotBlank(editClassId)) {
                selectedClass = [SELECT Id, Name, MaxLimit__c, My_Count__c 
                               FROM Class__c 
                               WHERE Id = :editClassId 
                               LIMIT 1];
                showEditForm = true;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                'Error loading class: ' + e.getMessage()));
        }
        return null;
    }

    // Save functionality
    public PageReference saveFnc() {
        try {
            if (selectedClass != null && selectedClass.Id != null) {
                update selectedClass;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 
                                    'Class updated successfully!'));
                showEditForm = false;
                // Refresh the list
                objController = null;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                'Error saving class: ' + e.getMessage()));
        }
        return null;
    }

    // Cancel functionality
    public PageReference cancelFnc() {
        selectedClass = new Class__c();
        showEditForm = false;
        return null;
    }
    
    // Delete functionality
    public PageReference deleteClassById() {
        try {
            if (String.isNotBlank(deleteClassId)) {
                Class__c classToDelete = [SELECT Id FROM Class__c WHERE Id = :deleteClassId LIMIT 1];
                delete classToDelete;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 
                                    'Class deleted successfully!'));
                // Refresh the list
                objController = null;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                'Error deleting class: ' + e.getMessage()));
        }
        return null;
    }
    
    // Pagination methods
    public Boolean hasNext {
        get {
            return objController.getHasNext();
        }
        set;
    }
    
    public Boolean hasPrevious {
        get {
            return objController.getHasPrevious();
        }
        set;
    }
    
    public PageReference next() {
        objController.next();
        return null;
    }
    
    public PageReference previous() {
        objController.previous();
        return null;
    }
    
    public PageReference first() {
        objController.first();
        return null;
    }
    
    public PageReference last() {
        objController.last();
        return null;
    }
    
    public Integer pageNumber {
        get {
            return objController.getPageNumber();
        }
        set;
    }
    
    public Integer totalPages {
        get {
            Decimal totalSize = objController.getResultSize();
            Decimal pageSize = objController.getPageSize();
            return (Integer)Math.ceil(totalSize / pageSize);
        }
        set;
    }
}