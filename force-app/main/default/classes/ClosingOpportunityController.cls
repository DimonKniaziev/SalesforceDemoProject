public with sharing class ClosingOpportunityController {
    @AuraEnabled
    public static List<OpportunityContactRole> getOpportunityContactRoles(id opportunityId){
        List<OpportunityContactRole> o = [SELECT Contact.id, Contact.Name, Opportunity.Participants_Quantity__c, Role FROM OpportunityContactRole WHERE OpportunityId=:opportunityId];
		                
        return o;
    }
    
    @AuraEnabled
    public static List<id> getContactRoleIds(id opportunityId){
        List<OpportunityContactRole> contactRoles = [SELECT Contact.id FROM OpportunityContactRole WHERE OpportunityId=:opportunityId];
        List <id> ids = new List<id>();
        for(OpportunityContactRole cr : contactRoles){
            id i=cr.Contact.id;
            ids.add(i);
        }
        return ids;
    }
    @AuraEnabled        
    public static void updateStatus(id opportunityId, boolean statusWon){
        Opportunity opportunity =[SELECT id, Name, StageName FROM Opportunity WHERE id = :opportunityId LIMIT 1];
            if(statusWon){
                opportunity.StageName='Closed Won';
            }
            else{
                opportunity.StageName='Closed Lost';
            }
        update opportunity;        
    } 
    @AuraEnabled
    public static List<Contact> getAccountContacts(id opportunityId){
        id account = [SELECT AccountId FROM Opportunity WHERE id = :opportunityId Limit 1].AccountId;
        List<Contact> contacts=[SELECT id, Name FROM Contact WHERE AccountId=:account];
        return contacts;
    } 
    @AuraEnabled
    public static Integer getMPQ(id opportunityId){
        Decimal participantQuantity = [SELECT Participants_Quantity__c FROM Opportunity WHERE id=:opportunityId LIMIT 1].Participants_Quantity__c;
        List<Participant__c> insertedParticipants= [SELECT id FROM Participant__c WHERE Opportunity_Name__c = :opportunityId];
        Decimal freePlaces = participantQuantity-insertedParticipants.size();
        Opportunity ThisOpportunity = [SELECT Training__c, AccountId, Participants_Quantity__c FROM Opportunity WHERE id=:opportunityId LIMIT 1];
        return Integer.valueOf(freePlaces);
    }
    @AuraEnabled 
    public static Boolean insertParticipants(id opportunityId, List<id> contactIds){
        Opportunity ThisOpportunity = [SELECT Training__c, AccountId, Participants_Quantity__c FROM Opportunity WHERE id=:opportunityId LIMIT 1];
        id ThisAccountId = ThisOpportunity.AccountId;
        id ThisTrainingId = ThisOpportunity.Training__c;

        Pricebook2 standardBook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
        Id productIds = [SELECT product2.id FROM OpportunityLineItem WHERE opportunity.id =:opportunityId LIMIT 1].product2.id;
         
        Pricebookentry entry = [SELECT Id,unitprice FROM PricebookEntry WHERE Pricebook2Id = :standardBook.Id AND Product2.id = :productIds];
        List<OpportunityContactRole> contactRoles = [SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId=:opportunityId];
        List<Participant__c> insertedParticipants= [SELECT id FROM Participant__c WHERE Opportunity_Name__c = :opportunityId];



        Boolean CanInsert = true;
        if(ThisOpportunity.Participants_Quantity__c < (contactIds.size()+contactRoles.size())){
            CanInsert=false;
        }
        else if(ThisOpportunity.Participants_Quantity__c <= insertedParticipants.size()){
            CanInsert=false;
        }
        else if (ThisOpportunity.Participants_Quantity__c < (contactIds.size()+contactRoles.size()+insertedParticipants.size())){
            Caninsert = false;
        }
        
        if(CanInsert){
            list<Orderitem> lineitems = new list<Orderitem>();
            List<Participant__c> participants = new List<Participant__c>();
            for(OpportunityContactRole ocr : contactRoles){
                Participant__c p = new Participant__c(); 
                p.Contact__c = ocr.ContactId;      
                p.RecordTypeId = '0127Q000000y1onQAA';
                p.Opportunity_Name__c = opportunityId;
                p.Registration_Date_Time__c = DateTime.now();
                p.Training__c = ThisTrainingId;  
                participants.add(p);
                
                Contract c = new Contract();
                c.Status = 'Draft';
                c.StartDate = Date.today();
                c.ContractTerm = 1;
                c.AccountId = ThisAccountId;
                c.CustomerSignedId = ocr.ContactId;
                insert c;
                
                Order o = new Order();
                o.ContractId = c.id;
                o.Status = 'Draft';
                o.AccountId = ThisAccountId;
                o.EffectiveDate = Date.today(); 
                o.Pricebook2Id = standardbook.id;
                insert o;
                
                Orderitem oitem = new Orderitem();
                oitem.OrderId = o.id;
                oitem.PricebookEntryId = entry.Id;
                oitem.UnitPrice = entry.UnitPrice;
                oitem.Quantity = 1;
                lineitems.add(oitem);
            }
            for(id i : contactIds){
                Participant__c p = new Participant__c(); 
                p.Contact__c = i;      
                p.RecordTypeId = '0127Q000000y1onQAA';
                p.Opportunity_Name__c = opportunityId;
                p.Registration_Date_Time__c = DateTime.now();
                p.Training__c = ThisTrainingId;  
                participants.add(p);
                Contract c = new Contract();
                c.Status = 'Draft';
                c.StartDate = Date.today();
                c.ContractTerm = 1;
                c.AccountId = ThisAccountId;
                c.CustomerSignedId = i;
                insert c;
                
                Order o = new Order();
                o.ContractId = c.id;
                o.Status = 'Draft';
                o.AccountId = ThisAccountId;
                o.EffectiveDate = Date.today(); 
                o.Pricebook2Id = standardbook.id;
                insert o;
                
                Orderitem oitem = new Orderitem();
                oitem.OrderId = o.id;
                oitem.PricebookEntryId = entry.Id;
                oitem.UnitPrice = entry.UnitPrice;
                oitem.Quantity = 1;
                lineitems.add(oitem);
            }
            insert participants;
            insert lineitems;
        }
        


        return CanInsert;
    }
}
