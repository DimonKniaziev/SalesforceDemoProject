public with sharing class CertificatesGeneratorController {
    @auraEnabled
    public static void savePDFCertificate(id trainingId){        
        List<Participant__c> participants = [SELECT id FROM Participant__c WHERE Training__c = :trainingId AND Status__c = 'Registered'];
        
        for(Participant__c p : participants){
            PageReference pdfPage = Page.PDF_Certificate;
		    pdfPage.getParameters().put('Id', p.id);
            Blob pdfContent = pdfPage.getContent();
            
            //Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Certificate';
            cv.PathOnClient = 'Certificate.pdf';
            cv.VersionData = pdfContent;
            cv.IsMajorVersion = true;
            insert cv;
 
            //Get Content Document Id
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
 
            //Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = p.id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            insert cdl;
        }    
    }

    @auraEnabled
    public static List<String> getParticipants(id trainingId){
        List<Participant__c> participants=[SELECT Id FROM Participant__c WHERE Training__c = :trainingId AND Status__c = 'Registered'];
		List <String> ids = new List<String>();
        for(Participant__c p : participants){
            ids.add('/apex/PDF_Certificate?id='+String.valueOf(p.id));
        }
        return ids;
    }

    @AuraEnabled
    public static List<String> getCountries(){
        List<String> countries = new List<String>();
        countries.add('USA');
        countries.add('India');
        return countries;
    }
}
