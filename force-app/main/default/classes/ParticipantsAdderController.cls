public with sharing class ParticipantsAdderController {
    
    @auraEnabled
    public static List<Training__c> getTrainings(){
        List<Training__c> trainings=[SELECT id, Name, Training_Course__r.Name, Max_Participants_Quantity__c, Free_Places__c FROM Training__c];
		                
        return trainings;
    }
    @AuraEnabled    
    public static Boolean insertParticipants(String trainingName, Integer amount){
        boolean canInsert;
        Training__c t =[SELECT id, Free_Places__c FROM Training__C WHERE Name=:trainingName Limit 1];
        if(t.Free_Places__c >= amount){
            List <Participant__c> participants = New List<Participant__c>();
            for(integer a=0; a<amount; a++){
                Participant__c p = new Participant__c();
                p.Registration_Date_Time__c = DateTime.now();
                p.Training__c = t.id;
                participants.add(p);
            }
            insert participants;
            canInsert=true;
        }
        else{
            canInsert=false;
        }
        return canInsert;                       
    }
    
}
