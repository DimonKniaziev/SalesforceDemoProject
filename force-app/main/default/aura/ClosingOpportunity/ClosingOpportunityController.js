({
    doInit : function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
        var getContactRoles = component.get("c.getOpportunityContactRoles");
        getContactRoles.setParams({ opportunityId : recordId });
        getContactRoles.setCallback(this,               
             function(response){
            var responseValue = response.getReturnValue();
            component.set("v.ThisOpportunityContactRoles", responseValue);
        },'SUCCESS');        
        $A.enqueueAction(getContactRoles,false);

        var getAccountContacts = component.get("c.getAccountContacts");
        getAccountContacts.setParams({ opportunityId : recordId });
        getAccountContacts.setCallback(this,               
             function(response){
            var responseValue = response.getReturnValue();
            component.set("v.ThisAccountContacts", responseValue);
        },'SUCCESS');        
        $A.enqueueAction(getAccountContacts,false);

        var action3 = component.get("c.getMPQ");
        action3.setParams({ opportunityId : recordId });
        action3.setCallback(this,               
             function(response){
            var responseValue = response.getReturnValue();            
            component.set("v.ThisTrainingMPQ", responseValue);
        },'SUCCESS');        
        $A.enqueueAction(action3,false);
        
        var action5 = component.get("c.getContactRoleIds");
        action5.setParams({ opportunityId : recordId });
        action5.setCallback(this,               
             function(response){
            var responseValue = response.getReturnValue();            
            component.set("v.ThisContactRolesIds", responseValue);
        },'SUCCESS');        
        $A.enqueueAction(action5,false);
        
    },    
    checkStatus : function(component, event, helper) {        
        
        var FreePlaces = component.get('v.ThisTrainingMPQ') - component.get('v.ThisOpportunityContactRoles').length;  
        var SelectedContacts = []; 
        var Valids=[];
        
        if(FreePlaces<=0){
            component.set("v.HasFreePlaces", false);            
        }               
        else if(FreePlaces>0){
            component.set("v.HasFreePlaces", true);
            var SelectedContacts = [];  
            for (var i=0; i< FreePlaces; i++){           
                var c = " ";
                var v = false;
                SelectedContacts.push(c);  
                Valids.push(v);             
            }        
            component.set("v.SelectedContacts", SelectedContacts);
            component.set("v.ValidContacts", Valids);
        }
              
        
    },
    selectContact : function(component, event, helper){ 
        var idx = event.target.dataset.index;        
        var contacts = component.get("v.SelectedContacts");
        var valids = component.get("v.ValidContacts");
        contacts[idx] = event.getSource().get('v.value');        
        valids[idx] = event.getSource().get('v.validity').valid;
        component.set("v.SelectedContacts", contacts);
        component.set("v.ValidContacts", valids);
    },
    closeOpportunity : function(component, event, helper) {
        var isWon = component.get('v.statusWon');        
        var statusValid = component.find("statusSelector").get("v.validity"); 
        if(statusValid.valid){     
            
            if(isWon == 'true'){
                var ALLVALID;
                var Valids = component.get('v.ValidContacts');
                var Contacts = component.get('v.SelectedContacts');
                var recordId = component.get('v.recordId');
                var hasFreePlaces = component.get('v.HasFreePlaces');
                

                if(hasFreePlaces){
                    for (var i=0; i< Valids.length; i++){           
                        if(Valids[i]){
                            ALLVALID = true;
                        }
                        else{
                            ALLVALID = false;
                            break;
                        }             
                    } 
                }
                else{
                    ALLVALID=true;
                }
                if(ALLVALID){  
                    var action = component.get("c.insertParticipants");                   
                    action.setParams({ opportunityId : recordId, contactIds: Contacts });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        var responseValue = response.getReturnValue();
                        
                        if (state === "SUCCESS"&&responseValue==true) {
                            alert('Created Participants');                        
                        }
                        else if(state === "SUCCESS"&&responseValue!=true){
                            alert('Opportunity Owerfilled');
                        }
                    });      
                    $A.enqueueAction(action,false); 

                    var action = component.get("c.updateStatus");
                    var recordId = component.get('v.recordId');
                    action.setParams({ opportunityId : recordId, statusWon :  true});
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                        alert('Closed as Won');                        
                        }                    
                        else if (state === "ERROR") {
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    console.log("Error message: " + errors[0].message);
                                }
                            }
                            else{
                                console.log("Unknown error");
                            }
                        }
                    });      
                    $A.enqueueAction(action,false);
                }
                else{
                    alert("Fill All Contacts");                    
                }           
            }
            
            else{
                var updateOpportunityStatus = component.get("c.updateStatus");
                var recordId = component.get('v.recordId');
                updateOpportunityStatus.setParams({ opportunityId : recordId, statusWon :  false});
                updateOpportunityStatus.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        alert('Closed as Lost');                        
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                        console.log("Unknown error");
                        }
                    }
                });      
                $A.enqueueAction(updateOpportunityStatus,false);
            }
        }        
        
        
    },
    cancelClick : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();         
    } 
})