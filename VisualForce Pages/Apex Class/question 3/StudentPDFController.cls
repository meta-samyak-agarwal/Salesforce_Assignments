public class StudentPDFController {
    private final Student__c stud;
    
    public StudentPDFController(ApexPages.StandardController stdController){
        this.stud = (Student__c) stdController.getRecord();
    }
    
    public PageReference generateAndAttachPdf() {
        
        List<ContentDocumentLink> existingLinks = [
            SELECT Id, ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :stud.Id
        ];
        
        Set<Id> docIds = new Set<Id>();
        for(ContentDocumentLink cdl : existingLinks){
            docIds.add(cdl.ContentDocumentId);
        }
        
        if(!docIds.isEmpty()) {
            List<ContentDocument> docsToDelete = [
                SELECT Id FROM ContentDocument WHERE Id IN :docIds
            ];
            
            //if (!versionsToDelete.isEmpty()) delete versionsToDelete;
            if (!existingLinks.isEmpty()) delete existingLinks;
            if (!docsToDelete.isEmpty()) delete docsToDelete;
        }
        
        PageReference pdfPage = Page.StudentPDF;
        pdfPage.getParameters().put('id', stud.Id);
        Blob pdfBlob = pdfPage.getContentAsPDF();
        
        ContentVersion cv = new ContentVersion();
        cv.VersionData = pdfBlob;
        cv.Title = 'StudentDetails';
        cv.PathOnClient = 'StudentDetails.pdf';
        insert cv;
        
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = stud.Id;
        cdl.ShareType = 'I';
        insert cdl;
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'PDF generated and attached. Previous PDF deleted.'));
        return new PageReference('/' + stud.Id);
    }
}