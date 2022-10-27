({	
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getParticipants");
        action.setParams({ trainingId : recordId });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                component.set('v.participants', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    savePDF : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var action = component.get('c.savePDFCertificate');
        action.setParams({ trainingId : recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                alert('Certificates were saved');
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
        $A.enqueueAction(action);
        alert("Certificates were saved");
        $A.get("e.force:closeQuickAction").fire();
    },
    cancelClick : function(component, event, helper){
    $A.get("e.force:closeQuickAction").fire();     
    }     
})

