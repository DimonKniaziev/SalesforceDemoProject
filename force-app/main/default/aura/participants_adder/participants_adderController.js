({
    doInit : function(component, event, helper) {        
        var action = component.get("c.getTrainings");        
        action.setCallback(this,               
             function(response){
            var responseValue = response.getReturnValue();            
           component.set('v.trainings',responseValue);
        },'SUCCESS');
        $A.enqueueAction(action,false);
        
    },        
    addParticipants : function(component, event, helper) {
        var selectedTraining = component.get("v.selectedTraining");
        var participantAmount = component.get("v.newParticipantAmount");       
        var amountValid = component.find("amountInput").get("v.validity");
        var trainingValid = component.find("trainingSelector").get("v.validity");                     
        
        if(amountValid.valid && trainingValid.valid){   
                        
            var action = component.get("c.insertParticipants");
            action.setParams({ trainingName : selectedTraining, amount : participantAmount});
            action.setCallback(this, function(response) {
                var responseValue = response.getReturnValue();               
                var state = response.getState();                                 
                if (state === "SUCCESS" && responseValue) {
                    alert('Participants were added');
                    $A.get("e.force:closeQuickAction").fire();
                    
                }
                else if (state === "SUCCESS") {
                    alert('You trying to add too much participants');
                    
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            });
            $A.enqueueAction(action,false);                       
        } 
       
       
    },
    cancelClick : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
         
    } 
})
