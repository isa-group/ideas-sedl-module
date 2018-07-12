//# sourceURL=ExperimentalDescriptionController.js
$scope.loading = false;

$("details").click(function(event) {
  $scope.descriptionType = ($scope.model.notes && $scope.model.notes.length>1)?"StructuredAbstract":"FreeForm";
  $scope.goalType = ($scope.model.context && $scope.model.context.notes.length>1)?"GQM":"FreeForm";
  $("details").off("click");
  $scope.$apply();
});


/* CONTEXT*/

/* People */
$scope.addPeople = function(){
    console.info("Adding a new person");
    var person=JSON.parse('{"notes": [],"annotations": [],"id": null,"phone": [],"name": "Write a name here","address": null, "email": "specify.a.valid@email.com","role": "Responsible","organization": "Organization of the person"}');
    $scope.model.context.people.person.push(person);
}

$scope.removePeople = function (email){
    console.info("Removing the person with email:"+email);
    var index=$scope.findPeopleByEmail(email);
    if(index!=-1){
         $scope.model.context.people.person.splice(index, 1);
    }else
        console.log("Unable to find the person with email:"+email);
}

$scope.findPeopleByEmail = function (email){
    console.info("Searching for a researcher having email:"+email);
    var index=-1;
    for (var i = 0; i <  $scope.model.context.people.person.length; i++) {
        if ( $scope.model.context.people.person[i].email === email) {
            index=i;
        }
    }
    return index;
}

/* VARIABLES */
$scope.removeLevelFromVariable = function (vname,value) {
    console.info("Removing the level '"+value+"' from the  variable "+vname);
    var varIndex=$scope.findVariableIndex(vname);
    if(varIndex!=-1){
        var levelIndex=$scope.findLevelIndex($scope.model.design.variables.variable[varIndex],value);
        if(levelIndex!=-1){
            $scope.model.design.variables.variable[varIndex].domain.levels.splice(levelIndex, 1);
        }else
            console.info("Level '"+value+"' not found for variable "+vname+"!");
    }else
        console.info("Variable "+vname+" not found!");
    
}

$scope.addNewLevelToVariable = function (vname) {
    console.info("Adding a new level to the  variable "+vname);
    var index=$scope.findVariableIndex(vname);
    if(index!=-1){
        var level=JSON.parse('{"value" : "Change me!"}');
        $scope.model.design.variables.variable[index].domain.levels.push(level);
    }else{
        console.info("Variable "+vname+" not found!");
    }
}

$scope.findVariableOfType = function (type){
    console.info("Searching for variables of type "+type);
    var variables=[];
    for (var i = 0; i < $scope.model.design.variables.variable.length; i++) {
        if ($scope.model.design.variables.variable[i]['@type'] === type) {
            variables.push($scope.model.design.variables.variable[i]);
        }
    }
    return variables;
}

$scope.findDependentVariable = function (){
    console.info("Searching for a dependent variable ");
    var variable=null;
    var variables=$scope.findVariableOfType('Outcome');
    if(variables.length>0)
        variable=variables[0];
    return variable;
}

$scope.findDependentVariableNotIn = function (names){
    console.info("Searching for a dependent variable ");
    var variable=null;
    var variables=$scope.findVariableOfType('Outcome');
    var index=-1;
    for(var i=0;i<variables.length;i++){
        index=$scope.findIndexIn(variables[i].name,names)
        if(index==-1)
            variable=variables[i];
    }
    return variable;
}

$scope.findIndependentVariable = function (){
    console.info("Searching for an independent variable ");
    var variable=null;
    var variables=$scope.findVariableOfType('ControllableFactor');
    if(variables.length>0){
        variable=variables[0];
    }else{
        variables=$scope.findVariableOfType('NonControllableFactor');
         if(variables.length>0)
            variable=variables[0];
    }
    return variable;
}

$scope.findIndependentVariableNotIn = function (names){
    console.info("Searching for an independent variable ");
    var variable=null;
    var variables=$scope.findVariableOfType('ControllableFactor');
    var index=-1;
    if(variables.length>0){
        for(var i=0;i<variables.length;i++){
            index=$scope.findIndexIn(variables[i].name,names)
            if(index==-1)
                variable=variables[i];
        }
    }else{
        variables=$scope.findVariableOfType('NonControllableFactor');
        for(var i=0;i<variables.length;i++){
            index=$scope.findIndexIn(variables[i].name,names)
            if(index==-1)
                variable=variables[i];
        }  
    }
    return variable;
}

$scope.findVariableIndex = function (vname){
    console.info("Searching for the index of variable "+vname);
    var index=-1;
    for (var i = 0; i < $scope.model.design.variables.variable.length; i++) {
        if ($scope.model.design.variables.variable[i].name === vname) {
            index=i;
        }
    }
    return index;
}

$scope.findLevelIndex = function(v,value){
    console.info("Searching for the index of the level '"+value+"' on variable "+v.name);
    var index=-1;
    for (var i = 0; i < v.domain.levels.length; i++) {
        if (v.domain.levels[i].value === value) {
            index=i;
        }
    }
    return index;
}

$scope.generateValidValuation=function(varName){
    console.info("Generating a valid valuation for variable: "+varName);
    var result=null;
    var vindex=$scope.findVariableIndex(varName);
    if(vindex!=-1){
        result=JSON.parse('{"variable":'+JSON.stringify($scope.model.design.variables.variable[vindex])+',"level":null}');
        result.level=$scope.generateValidLevel(result.variable.domain);
    }else
        console.info("Unable to find variable with name:"+varName);
    return result;
}

$scope.generateValidLevel=function(domain){
    var result=JSON.parse('{"value":null}');
    if(domain['@type']=="ExtensionDomain"){
        result=domain.levels[0];
    }else{
        if(domain.constraint.length>0){
            if(domain.constraint[0]['@type']=="FundamentalSetConstraint"){
                if(domain.constraint.length>1)
                    result.value=$scope.generateLevelOfFundamentalSet(domain.constraint[0].fundamentalSet,domain.constraint[1]);
                else
                    result.value=$scope.generateLevelOfFundamentalSet(domain.constraint[0].fundamentalSet,null);
            }
        }
    }
    return result;
}

$scope.generateLevelOfFundamentalSet=function(fundamentalSet,additionalConstraint){
    var result=null;
    if(fundamentalSet=='B'){
        result=true;
    }else if(fundamentalSet=='R'){
        result=0;
        if(additionalConstraint!=null && additionalConstraint['@type'] === 'IntervalConstraint')
            result=additionalConstraint.min;
    }else if(fundamentalSet=='Z'){
        result=0;
        if(additionalConstraint!=null && additionalConstraint['@type'] === 'IntervalConstraint')
            result=additionalConstraint.min;
    }else
        console.info("Unable to generate a default value on fundamental set:"+fundamentalSet);
    return result;
}

$scope.variableDomainTypeChange=function(variableName){
	console.info("The type of the variable "+variableName+" changed");
        var varIndex=$scope.findVariableIndex(variableName);
        if(varIndex!=-1){
            var domainType=$scope.model.design.variables.variable[varIndex].domain['@type'];
            console.info("The new domain type is "+domainType);
            $scope.model.design.variables.variable[varIndex].domain=$scope.createDefaultDomainOfType(domainType);
        }
}

$scope.createDefaultDomainOfType = function(domainType){
    var result=null;
    if(domainType==='ExtensionDomain'){
        result=JSON.parse('{"@type":"ExtensionDomain","levels":[{"value":"V1"},{"value":"V2"}],"finite":true}');
    }else if(domainType==='IntensionDomain'){
        result=JSON.parse('{"@type":"IntensionDomain","levels":[],"constraint":[{"@type":"FundamentalSetConstraint","fundamentalSet":"R"}],"finite": false}');
    }
    return result;
}

$scope.addNewVariable = function(){
    console.info("Adding a new variable to the experiment")
    var result=null;
    result=JSON.parse('{"@type":"ControllableFactor","domain":null,"kind":"NOMINAL","name":"Change_me","units":null}');
    result.domain=$scope.createDefaultDomainOfType('ExtensionDomain');
    $scope.model.design.variables.variable.push(result);
    return result;
}

$scope.removeVariable = function (v){
    console.info("Removing variable "+v.name);
    var index=$scope.findVariableIndex(v.name);
    if(index!=-1){
        $scope.model.design.variables.variable.splice(index,1);    
    }else{
        console.info("Unable to find a variable with name "+v.name);
    }
}

/* HYPOTHESES */
$scope.generateHypothesisId = function (){
    var i=1;
    var candidate="H"+i;
    var index=$scope.findHypothesisIndex(candidate);
    while(index!=-1){
        i++;
        candidate="H"+i;
        index=$scope.findHypothesisIndex(candidate);
    }
    return candidate;
}

$scope.generateDummyHypothesis = function (){
    console.info("Generating a dummy hypotheis ");
    var dependentVariable=$scope.findDependentVariable();
    var independentVariable=$scope.findIndependentVariable();
    var id=$scope.generateHypothesisId()
    var result=null;
    if(dependentVariable && independentVariable)
        result=JSON.parse('{"@type" : "DifferentialHypothesis",    "notes" : [ ],    "annotations" : [ ],    "id" :"'+id+'",    "dependentVariable" : "'+dependentVariable.name+'",    "independentVariables" : [ "'+independentVariable.name+'" ]}');
    else
        result=JSON.parse('{"@type" : "DescriptiveHypothesis","notes" : ["Write your descriptoin here"]}');
    return result;
}

$scope.addNewHypothesis = function (h){
    $scope.model.hypotheses.push($scope.generateDummyHypothesis());
}

$scope.removeHypothesis = function (h){
    console.info("Removing hypotheis "+h.id);
    var hypothesisIndexToRemove = $scope.findHypothesisIndex(h.id);

    if(hypothesisIndexToRemove!=-1){
        $scope.model.hypotheses.splice(hypothesisIndexToRemove, 1);
    }else{
        console.info("Unable to find hypotheis "+h.id); 
    }
}

$scope.addNewIndependentVariableToHypothesis = function (h){
    console.info("Adding new independent variable to hypotheis "+h.id);
    var ret = true;
    var controllableFactors=$scope.findVariableOfType('ControllableFactor').filter(function(item){
        return h.independentVariables.indexOf(item.name) === -1;
    });
    var nonControllableFactors=$scope.findVariableOfType('NonControllableFactor').filter(function(item){
        return h.independentVariables.indexOf(item.name) === -1;
    });

    var hypothesisIndex=$scope.findHypothesisIndex(h.id);
    
    if(controllableFactors.length!=0 && hypothesisIndex!=-1){
         $scope.model.hypotheses[hypothesisIndex].independentVariables.push(controllableFactors[0].name)
    }else if(nonControllableFactors.length!=0 && hypothesisIndex!=-1){
        $scope.model.hypotheses[hypothesisIndex].independentVariables.push(nonControllableFactors[0].name)
    }else if(hypothesisIndex!=-1){
       console.info("Unable to find hypotheis "+h.id); 
    }else{
        window.alert("There are not candidate variables to be added, all the factors of the experiment are being used as indenpendent variables in this hypothesis!")
    }
    
    return ret;
}

$scope.removeIndependentVariableFromHypothesis = function(hid,v){
    console.info("Removing independent variable "+v+" from hypotheis "+hid);
    var hypothesisIndex=$scope.findHypothesisIndex(hid);
    if(hypothesisIndex!=-1){
        if($scope.model.hypotheses[hypothesisIndex].independentVariables.length>1){
            var index=$scope.model.hypotheses[hypothesisIndex].independentVariables.indexOf(v);
            if(index!=-1)
                $scope.model.hypotheses[hypothesisIndex].independentVariables.splice(index,1);
        }
    }
    
}

$scope.findHypothesisIndex = function (hid){
    console.info("Searching for hypotheis "+hid);
    var index=-1;
    for (var i = 0; i < $scope.model.hypotheses.length; i++) {
        if ($scope.model.hypotheses[i].id === hid) {
           index = i;
        }
    }
    return index;
}

/* CONSTANTS */
$scope.addDesignParameter = function (){
    console.info("Adding new design parameter");
    $scope.model.design.designParameters.push(JSON.parse('{"@type" : "SimpleParameter","name":"default_name","value":"default_value"}'))
}

$scope.removeDesignParameter = function (c){
    console.info("Removing design parameter "+c.name);
    var indexToRemove = $scope.findDesignParameterIndex(c.name);
    if(indexToRemove!=-1){
        $scope.model.design.designParameters.splice(indexToRemove, 1);
    }else{
        console.info("Removing design parameter "+c.name);
    }
}

$scope.findDesignParameterIndex = function(dpname){
    var index = -1;
    for (var i = 0; i < $scope.model.design.designParameters.length; i++) {
        if ($scope.model.design.designParameters[i].name === dpname) {
            index = i;
        }
    }
    return index;
}

/* BLOCKING VARIABLES */
$scope.addBlockingVariable=function(){
    console.info("Adding a new blocking variable");
    var variable=$scope.findIndependentVariableNotIn($scope.model.design.experimentalDesign.blockingVariables);
    if(variable!=null)
        $scope.model.design.experimentalDesign.blockingVariables.push(variable.name);
}

$scope.removeBlockingVariable = function(varname){
    console.info("Removing blocking variable "+varname);
    var index=$scope.findIndexIn(varname,$scope.model.design.experimentalDesign.blockingVariables);
    if(index!=-1)
        $scope.model.design.experimentalDesign.blockingVariables.splice(index,1);
}

/* EXPERIMENTAL GROUPS */
$scope.addGroup=function(){
    console.info("Adding a new dummy group to the design");
    var group=JSON.parse('{"sizing":{"@type":"Literal","value":1},"valuations":[],"name":"Change_me","groupSpecification":true}');
    $scope.model.design.experimentalDesign.groups.push(group);
}

$scope.removeGroup=function(groupName){
    console.info("Removing group "+groupName);
    var groupIndex=$scope.findIndexInForProperty(groupName,$scope.model.design.experimentalDesign.groups,"name");
    if(groupIndex!=-1){
        $scope.model.design.experimentalDesign.groups.splice(groupIndex,1);
    }else
        console.info("Unable to find group "+groupName);
}

$scope.findValidGroupId=function(){
    console.info("Searching for valid Group name");
    var result="null";
    if($scope.model.design.experimentalDesign.groups.length>0){
        result='"'+$scope.model.design.experimentalDesign.groups[0].name+'"';
    }
    return result;
}

/* EXPERIMENTAL PROTOCOL */
$scope.addProtocolStep = function () {
    console.info("Adding a protocol step");
    var defaultStep = JSON.parse('{"@type": "Measurement", "group": '+ $scope.findValidGroupId() +',"id": "'+$scope.generateNewProtocolStepId()+'","variableValuation": [],"variable": []}');
    defaultStep.variableValuation.push($scope.generateValidValuation($scope.model.design.variables.variable[0].name));
    $scope.model.design.experimentalDesign.experimentalProtocol.steps.push(defaultStep);
}

$scope.generateNewProtocolStepId =function (){
    console.info("Generating new protocol step ID");
    var candidate=null;
    var isValid=false;
    var i=0;
    while(!isValid){
        i++;
        isValid=true;
        candidate="S"+i;
        for(var j=0;j<$scope.model.design.experimentalDesign.experimentalProtocol.steps.length;j++)
            if(candidate===$scope.model.design.experimentalDesign.experimentalProtocol.steps[j].id)
                valid=false;
    }
    return candidate;
}

$scope.removeProtocolStep = function(step){
    console.info("Removing the procol step:"+step);
    if(step.id!=null && step.id!=""){
        $scope.removeProtocolStepById(step.id);
    }else{
        var index=findProtocolStepByContent(step);
        if(index!=-1)
        {
            $scope.model.design.experimentalDesign.experimentalProtocol.steps.splice(index,1);
        }else
            console.info("Unable to remove the procol step:"+step);
    }
}

$scope.findProtocolStepByContent=function (step){
    console.info("Searching for protocol step having id:"+stepId);
    var index = -1;
    for (var i = 0; i < $scope.model.design.experimentalDesign.experimentalProtocol.steps.length; i++) {
        if ($scope.model.design.experimentalDesign.experimentalProtocol.steps[i]['@type'] === step['@type'] && 
            $scope.model.design.experimentalDesign.experimentalProtocol.steps[i].group==step.group && 
            $scope.model.design.experimentalDesign.experimentalProtocol.steps[i].variableValuation == step.variableValuation) {
            index = i;
        }
    }
    return index;
}

$scope.removeProtocolStepById = function(stepId){
    var index=$scope.findProtocolStepIndexById(stepId);
    if(index!=-1){
        $scope.model.design.experimentalDesign.experimentalProtocol.steps.splice(index,1);
    }else
        console.info("Unable to find protocol step with Id:"+stepId);
}

$scope.findProtocolStepIndexById=function(stepId){
    console.info("Searching for protocol step having id:"+stepId);
    var index = -1;
    for (var i = 0; i < $scope.model.design.experimentalDesign.experimentalProtocol.steps.length; i++) {
        if ($scope.model.design.experimentalDesign.experimentalProtocol.steps[i].id === stepId) {
            index = i;
        }
    }
    return index;
}

$scope.addVariableToProtocolStep = function (step){
    console.info("Addding variable to step having id:"+step.id);
    var index=$scope.findProtocolStepIndexById(step.id);
    if(index!=-1){
        var variable=$scope.findDependentVariable();
        $scope.model.design.experimentalDesign.experimentalProtocol.steps[index].variable.push(variable.name);
    }else
        console.info("Unable to find protocol step with Id:"+step.id);
}

$scope.removeVariableFromProtocolStep = function(step,variable){
    console.info("Removing variable"+variable+"from step having id:"+step.id);
    var index=$scope.findProtocolStepIndexById(step.id);
    if(index!=-1){
        var variableIndex=$scope.findIndexIn(variable,$scope.model.design.experimentalDesign.experimentalProtocol.steps[index].variable);
        if(variableIndex!=-1)
            $scope.model.design.experimentalDesign.experimentalProtocol.steps[index].variable.splice(variableIndex,1);
    }else
        console.info("Unable to find protocol step with Id:"+step.id);
}

$scope.addAssignmentToProtocolStepGroup = function(step) {
    console.info("Addding variable assignmet to step having id:"+step.id);
    var index=$scope.findProtocolStepIndexById(step.id);
    if(index!=-1){
        $scope.model.design.experimentalDesign.experimentalProtocol.steps[index].variableValuation.push($scope.generateValidValuation($scope.model.design.variables.variable[0].name));
    }else
        console.info("Unable to find protocol step with Id:"+step.id);
}

$scope.removeAssigmentFromProtocolStep=function(stepId,assignment){
    console.info("Removing variable assígnment form step having id:"+stepId);
    var index=$scope.findProtocolStepIndexById(stepId);
    if(index!=-1){
        var assignmentIndex=$scope.findAssignmentIndex(index,assignment);
        if(assignmentIndex!=-1){
            $scope.model.design.experimentalDesign.experimentalProtocol.steps[index].variableValuation.splice(assignmentIndex,1);
        }else
            console.info("Unable to find assignment in protocol step with Id:"+stepId);
    }else
        console.info("Unable to find protocol step with Id:"+stepId);
}

$scope.findAssignmentIndex=function(stepIndex,assignment){
    var result=-1;
    for(var i=0;i < $scope.model.design.experimentalDesign.experimentalProtocol.steps[stepIndex].variableValuation.length;i++){
        if($scope.model.design.experimentalDesign.experimentalProtocol.steps[stepIndex].variableValuation[i]==assignment)
            result=i;
    }
    return result;
}

/* ANALYSES */

$scope.generateNewAnalysisGroupId=function (){
    var candidate=null;
    var isValid=false;
    var i=0;
    while(!isValid){
        i++;
        isValid=true;
        candidate="AG"+i;
        for(var j=0;j<$scope.model.design.experimentalDesign.intendedAnalyses.length;j++)
            if(candidate===$scope.model.design.experimentalDesign.intendedAnalyses[j].id)
                valid=false;
    }
    return candidate;
}

$scope.addAnalysisGroup = function (){
    console.info("Adding new analysis group");
    var newAnalysisGroup=JSON.parse('{"analyses": [], "id": "'+$scope.generateNewAnalysisGroupId()+'"}');
    $scope.model.design.experimentalDesign.intendedAnalyses.push(newAnalysisGroup)
}

$scope.addAnalysis=function (analysisGroupId){
    console.info("Addina a dummy analysis to the group "+analysisGroupId);
    var indexToAdd = $scope.findAnalysisGroupIndex(analysisGroupId);
    if(indexToAdd!=-1){ // IF FOUND:
        var newAnalysis=JSON.parse('{"@type" : "StatisticalAnalysisSpec","id" : null, "statistic" : [ { "@type" : "Mean","datasetSpecification" : {"projections" : [],"filters" : [ ],"groupings" : [],"valuationFilters" : [ ],"nonGroupingProjections" : [ ]}} ]}');
        $scope.model.design.experimentalDesign.intendedAnalyses[indexToAdd].analyses.push(newAnalysis);
    }else{
        console.info("Unable to find analysis group: "+analysisGroupId);
    }
}

$scope.findAnalysisGroupIndex = function (analysisGroupId){
    console.info("Searching the index of the analysis group "+analysisGroupId);
    var indexToAdd = -1;
    for (var i = 0; i < $scope.model.design.experimentalDesign.intendedAnalyses.length; i++) {
        if (analysisGroupId===$scope.model.design.experimentalDesign.intendedAnalyses[i].id) {
            indexToAdd = i;
        }
    }
    return indexToAdd;
}

$scope.removeAnalysisGroup = function (analysisGroupId){
    console.info("Removing an analysis to the group "+analysisGroupId);
    var index = $scope.findAnalysisGroupIndex(analysisGroupId);
    if(index!=-1){
      $scope.model.design.experimentalDesign.intendedAnalyses.splice(index,1);
    }else
      console.log("Unable to find analysis group "+analysisGroupId);

}


$scope.removeAnalysis = function (analysisGroupId,a){
    console.info("Removing an analysis to the group "+analysisGroupId);
    var index = $scope.findAnalysisGroupIndex(analysisGroupId);
    var indexToRemove=-1;
    for(var i=0;i<$scope.model.design.experimentalDesign.intendedAnalyses[index].analyses.length;i++){
        if(a===$scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[i])
        indexToRemove=i;
    }
    if(indexToRemove!=-1){
        $scope.model.design.experimentalDesign.intendedAnalyses[index].analyses.splice(indexToRemove, 1);
    }else{
        console.info("Unable to find analysis in analysis group: "+analysisGroupId);
    }
}

$scope.findAnalysisIndex=function(analysisGroupIndex,a){
    var index=-1;
    for(var i=0;i<$scope.model.design.experimentalDesign.intendedAnalyses[analysisGroupIndex].analyses.length;i++){
        if(a===$scope.model.design.experimentalDesign.intendedAnalyses[analysisGroupIndex].analyses[i])
            index=i;
    }
    return index;
}

$scope.addProjection = function (analysisGroupId,a){
  console.info("Adding new projection to analysis in analysis group '"+analysisGroupId+"'");
  var index=$scope.findAnalysisGroupIndex(analysisGroupId);
  if(index!=-1){
    var analysisIndex=$scope.findAnalysisIndex(index,a);
    if(analysisIndex!=-1){
        var projectionIndex=$scope.findProjectionIndexByType(index,analysisIndex,"Projection");
        if(projectionIndex==-1){
            var variable=$scope.findDependentVariable();
            if(variable==null)
                variable=$scope.findIndependentVariable();
            if(variable==null){
                window.alert("You need to define at least one variable!");
                return;
            }
            var newProjection=JSON.parse('{"@type":"Projection","projectedVariables":["'+variable.name+'"]}');
            $scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections.push(newProjection);
        }else{
            var variable=$scope.findDependentVariableNotIn($scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections[projectionIndex].projectedVariables);
            if(variable==null)
                variable=$scope.findIndependentVariableNotIn($scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections[projectionIndex].projectedVariables);
            if(variable==null){
                window.alert("All the variables are present. You need to define at least one variable to add it!");
                return;
            }
            $scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections[projectionIndex].projectedVariables.push(variable.name);
        }
    }else{
        console.info("Unable to find analysis in analysis group: "+analysisGroupId);
    }
  }else{
      console.info("Unable to find analysis group: "+analysisGroupId);
  }
}

$scope.addGrouping = function (analysisGroupId,a){
  console.info("Adding new projection to analysis in analysis group '"+analysisGroupId+"'");
  var index=$scope.findAnalysisGroupIndex(analysisGroupId);
  if(index!=-1){
    var analysisIndex=$scope.findAnalysisIndex(index,a);
    if(analysisIndex!=-1){
        var projectionIndex=$scope.findProjectionIndexByType(index,analysisIndex,"GroupingProjection");
        if(projectionIndex==-1){
            var variable=$scope.findIndependentVariable(); 
            if(variable==null)
                variable=$scope.findDependentVariable();
            if(variable==null){
                window.alert("You need to define at least one variable!");
                return;
            }
            var newProjection=JSON.parse('{"@type":"GroupingProjection","projectedVariables":["'+variable.name+'"]}');
            $scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections.push(newProjection);
        }else{
            var variable=$scope.findIndependentVariableNotIn($scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections[projectionIndex].projectedVariables); 
            if(variable==null)
                variable=$scope.findDependentVariableNotIn($scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections[projectionIndex].projectedVariables);
            if(variable==null){
                window.alert("All the variables are present. You need to define at least one variable to add it!");
                return;
            }
            $scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections[projectionIndex].projectedVariables.push(variable.name);    
        }
    }else{
        console.info("Unable to find analysis in analysis group: "+analysisGroupId);
    }
  }else{
      console.info("Unable to find analysis group: "+analysisGroupId);
  }
}


$scope.addFilter = function (analysisGroupId,a){
  console.info("Adding new filter to analysis in analysis group '"+analysisGroupId+"'");
  var index=$scope.findAnalysisGroupIndex(analysisGroupId);
  if(index!=-1){
    var analysisIndex=$scope.findAnalysisIndex(index,a);
    if(analysisIndex!=-1){
        var variable=$scope.findIndependentVariable();
        if(variable==null)
            variable=$scope.findDependentVariable();
        if(variable==null){
            window.alert("You need to define at leas one variable!");
            return;
        }
        
        if($scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.filters.length==0){
            var level=$scope.generateValidLevel(variable.domain);
            var newFilter=JSON.parse('{"@type":"ValuationFilter","variableValuations":[{"variable":'+JSON.stringify(variable)+',"level":'+JSON.stringify(level)+'}]}');
            $scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.filters.push(newFilter);
        }else{
            $scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.filters[0].variableValuations.push($scope.generateValidValuation(variable.name));
        }
    }else{
        console.info("Unable to find analysis in analysis group: "+analysisGroupId);
    }
  }else{
      console.info("Unable to find analysis group: "+analysisGroupId);
  }
}

$scope.removeProjection = function (analysisGroupId,a,p,v){
  console.info("Removing projection from analysis in analysis group '"+analysisGroupId+"'");
  var index=$scope.findAnalysisGroupIndex(analysisGroupId);
  if(index!=-1){
    var analysisIndex=$scope.findAnalysisIndex(index,a);
    if(analysisIndex!=-1){
        var projectionIndex=$scope.findProjectionIndex(index,analysisIndex,p);
        if(projectionIndex!=-1){
            if($scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections[projectionIndex].projectedVariables.length==1){
                $scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections.splice(projectionIndex,1);
            }else{
                    var vindex=-1;
                    for(var i=0;i<$scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections[projectionIndex].projectedVariables.length;i++)
                        if($scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections[projectionIndex].projectedVariables[i]==v)
                            vindex=i;
                    if(vindex!=-1){
                        $scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections[projectionIndex].projectedVariables.splice(vindex,1);
                    }else{
                        console.info("Unable to remove variable "+v+" in projection from analysis (not found)");
                    }
                        
                }
        }else{
            console.info("Unable to remove projection from analysis (not found)");
        }
    }else{
        console.info("Unable to find analysis in analysis group: "+analysisGroupId);
    }
  }else{
      console.info("Unable to find analysis group: "+analysisGroupId);
  }
}

$scope.findProjectionIndex = function (analysisGroupIndex, analysisIndex,p){
    var projectionIndex=-1;
    for(var i=0;i<$scope.model.design.experimentalDesign.intendedAnalyses[analysisGroupIndex].analyses[analysisIndex].statistic[0].datasetSpecification.projections.length;i++)
        if($scope.model.design.experimentalDesign.intendedAnalyses[analysisGroupIndex].analyses[analysisIndex].statistic[0].datasetSpecification.projections[i]===p)
            projectionIndex=i;
    return projectionIndex;
}

$scope.findProjectionIndexByType = function (analysisGroupIndex, analysisIndex,type){
    var projectionIndex=-1;
    for(var i=0;i<$scope.model.design.experimentalDesign.intendedAnalyses[analysisGroupIndex].analyses[analysisIndex].statistic[0].datasetSpecification.projections.length;i++)
        if($scope.model.design.experimentalDesign.intendedAnalyses[analysisGroupIndex].analyses[analysisIndex].statistic[0].datasetSpecification.projections[i]["@type"]===type)
            projectionIndex=i;
    return projectionIndex;
}

$scope.removeGrouping = function (analysisGroupId,a,g,v){
  console.info("Removing grouping from analysis in analysis group '"+analysisGroupId+"'");
  var index=$scope.findAnalysisGroupIndex(analysisGroupId);
  if(index!=-1){
    var analysisIndex=$scope.findAnalysisIndex(index,a);
    if(analysisIndex!=-1){
    var projectionIndex=$scope.findProjectionIndex(index,analysisIndex,g);
        if(projectionIndex!=-1){
            if($scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections[projectionIndex].projectedVariables.length==1){
                $scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections.splice(projectionIndex,1);
            }else{
                var vindex=-1;
                for(var i=0;i<$scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections[projectionIndex].projectedVariables.length;i++)
                    if($scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections[projectionIndex].projectedVariables[i]==v)
                        vindex=i;
                if(vindex!=-1){
                    $scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.projections[projectionIndex].projectedVariables.splice(vindex,1);
                }else{
                    console.info("Unable to remove variable "+v+" in groupingprojection from analysis (not found)");
                }
            }
        }else{
            console.info("Unable to remove groupingprojection from analysis (not found)");
        }
    }else{
        console.info("Unable to find analysis in analysis group: "+analysisGroupId);
    }
  }else{
      console.info("Unable to find analysis group: "+analysisGroupId);
  }
}

$scope.findGroupingProjectionIndex = function(analysisGroupIndex,analysisIndex,g){
    var groupingIndex=-1;
    for(var i=0;i<$scope.model.design.experimentalDesign.intendedAnalyses[analysisGroupIndex].analyses[analysisIndex].statistic[0].datasetSpecification.groupings.length;i++)
        if($scope.model.design.experimentalDesign.intendedAnalyses[analysisGroupIndex].analyses[analysisIndex].statistic[0].datasetSpecification.groupings[i]===g)
            groupingIndex=i;
    return groupIndex;
}

$scope.removeFilter = function (analysisGroupId,a,f,v){
  console.info("Removing filter from analysis in analysis group '"+analysisGroupId+"'");
  var index=$scope.findAnalysisGroupIndex(analysisGroupId);
  if(index!=-1){
    var analysisIndex=$scope.findAnalysisIndex(index,a);
    if(analysisIndex!=-1){
        if($scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.filters.length>0 && $scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.filters[0].variableValuations.length==1){
            $scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.filters=[];            
        }else{
            var filterIndex=$scope.findFilterIndex(index,analysisIndex,f);
            if(filterIndex!=-1){
                var variableValuationIndex=-1;
                for(var i=0;i<$scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.filters[filterIndex].variableValuations.length;i++)
                    if($scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.filters[filterIndex].variableValuations[i]===v)
                        variableValuationIndex=i;
                $scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.filters[filterIndex].variableValuations.splice(variableValuationIndex,1);
            }else
                console.info("Unable to remove filter from analysis (not found)");
        }
    }else{
        console.info("Unable to find analysis in analysis group: "+analysisGroupId);
    }
  }else{
      console.info("Unable to find analysis group: "+analysisGroupId);
  }
}

$scope.variableChangeInFilterValuation = function(analysisGroupId, a, f, v){
   var index=$scope.findAnalysisGroupIndex(analysisGroupId);
  if(index!=-1){
    var analysisIndex=$scope.findAnalysisIndex(index,a);
    if(analysisIndex!=-1){
            var filterIndex=$scope.findFilterIndex(index,analysisIndex,f);
            if(filterIndex!=-1){
                var variableValuationIndex=-1;
                for(var i=0;i<$scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.filters[filterIndex].variableValuations.length;i++)
                    if($scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.filters[filterIndex].variableValuations[i]===v)
                        variableValuationIndex=i;
                var newValuation=$scope.generateValidValuation(v.variable.name);
                $scope.model.design.experimentalDesign.intendedAnalyses[index].analyses[analysisIndex].statistic[0].datasetSpecification.filters[filterIndex].variableValuations[variableValuationIndex]=newValuation;
            }else
                console.info("Unable to remove filter from analysis (not found)");
    }else{
        console.info("Unable to find analysis in analysis group: "+analysisGroupId);
    }
  }else{
      console.info("Unable to find analysis group: "+analysisGroupId);
  } 
}

$scope.findFilterIndex = function(analysisGroupIndex,analysisIndex,f)
{
    var filterIndex=-1;
    for(var i=0;i<$scope.model.design.experimentalDesign.intendedAnalyses[analysisGroupIndex].analyses[analysisIndex].statistic[0].datasetSpecification.filters.length;i++)
        if($scope.model.design.experimentalDesign.intendedAnalyses[analysisGroupIndex].analyses[analysisIndex].statistic[0].datasetSpecification.filters[i]===f)
            filterIndex=i;
    return filterIndex;
}


/* CONFIGURATIONS */
$scope.findConfigurationIndex=function (configId){
    console.info("Searching for configuration with id:'"+configId+"'");
    var index = -1;
    for (var i = 0; i < $scope.model.configurations.length; i++) {
        if (configId===$scope.model.configurations[i].id) {
            index = i;
        }
    }
    return index;
}

$scope.addConfiguration=function () {
    console.info("Creating a default configuration");
    var config=JSON.parse('{"notes":[ ],"annotations":[ ],"id":"Change_me","context":null,"experimentalProcedure":{"tasks":[]},"experimentalSetting":null,"experimentalInputs":null,"experimentalOutputs":{"outputDataSources":[]},"parameters":[],"executions":[]}');
    $scope.model.configurations.push(config);
    
}

$scope.removeConfiguration=function(configId){
    console.info("Removing configuration with id:"+configId);
    var index=$scope.findConfigurationIndex(configId);
    if(index!=-1){
        $scope.model.configurations.splice(index,1);
    }else
        console.info("Unable to find configuration with id:"+configId)
}

/* RUNS */

$scope.addRun = function(configId){
    var index=$scope.findConfigurationIndex(configId);
    if(index!=-1){
        var defaultRun=JSON.parse('{"id":"Change_me","notes":[],"annotations":[],"log": null,"results": [],"analysisResults": [],"experimentalSetting": null,"start": null,"finish": null}');
        $scope.model.configurations[index].executions.push(defaultRun);
    }else{
        console.info("Unable to find configuration: "+configId);
    }
}

$scope.removeRun = function(configId, runId){
    console.info("Removing run '"+runId+"' from the configuration '"+configId+"'");
    var configIndex= $scope.findConfigurationIndex(configId);
    if(configIndex!=-1){
        var runIndex=$scope.findRunIndex(configIndex,runId);
        if(runIndex!=-1){
            $scope.model.configurations[configIndex].executions.splice(runIndex,1);
        }else
            console.info("Unable to find run '"+runId+"'  in configuration '"+configId+"'");
    }else{
        console.info("Unable to find configuration: "+configId);
    }
}

$scope.addResult = function (configId,runId) {
    console.info("Adding a results file to the configuration '"+configId+"' and run '"+runId+"'");
    var configIndex= $scope.findConfigurationIndex(configId);
    if(configIndex!=-1){
        var runIndex=$scope.findRunIndex(configIndex,runId);
        if(runIndex!=-1){
            var newResultsFile=JSON.parse('{"@type": "ResultsFile","variableMapping": null,"fileFormat": null,"file": {"fileformatspecification": null, "name": "change me!", "path": null } }');
            $scope.model.configurations[configIndex].executions[runIndex].results.push(newResultsFile);
        }else
            console.info("Unable to find run '"+runId+"'  in configuration '"+configId+"'");
    }else{
        console.info("Unable to find configuration: "+configId);
    }
}


$scope.removeResultFromRun = function (configId,runId,filename) {
    console.log("Removing file '"+filename+"' from the configuration '"+configId+"' and run '"+runId+"'");
    var configIndex= $scope.findConfigurationIndex(configId);
    if(configIndex!=-1){
        var runIndex=$scope.findRunIndex(configIndex,runId);
        if(runIndex!=-1){
            var resultIndex=$scope.findFileIndex(configIndex,runIndex,filename);
            if(resultIndex!=-1){
                $scope.model.configurations[configIndex].executions[runIndex].results.splice(resultIndex, 1);
            }else
                console.info("Unable to find file '"+filename+"' in run '"+runId+"'  of configuration '"+configId+"'");
        }else
            console.info("Unable to find run '"+runId+"'  in configuration '"+configId+"'");
    }else{
        console.info("Unable to find configuration: "+configId);
    }
}

$scope.findRunIndex = function (configIndex,runId) {
    console.info("Searching for run with id:'"+runId+"' in the "+(configIndex+1)+"-th configuration");
    var index = -1;
    for (var i = 0; i < $scope.model.configurations[configIndex].executions.length; i++) {
        if (runId===$scope.model.configurations[configIndex].executions[i].id) {
            index = i;
        }
    }
    return index;
}

$scope.findFileIndex = function(configIndex,runIndex,filename) {
     console.info("Searching for file with name '"+filename+"' in run the "+(runIndex+1)+"-th run of the "+(configIndex+1)+"-th configuration");
    var index = -1;
    for (var i = 0; i < $scope.model.configurations[configIndex].executions[runIndex].results.length; i++) {
        if (filename===$scope.model.configurations[configIndex].executions[runIndex].results[i].file.name) {
            index = i;
        }
    }
    return index;
}

/* Generation Operations */

/* Validation Operations */

/* AUXILIARY FUNCTIONS */

$scope.generateRawDataTemplate = function(configId, runId,f){
    CommandApi.doDocumentOperation("generateRawDataTemplate", {}, EditorManager.currentUri, function (csvheader) {
        showContentAsModal("app/modalWindows/createNewFileOfLanguage?language=csv&languageId=ideas-csv-language",
                    function () {
                            createNewFile("ideas-csv-language", ".csv",function(furi){
                                console.info("Saving on "+furi+" the content '"+csvheader.message+"'");
                                FileApi.saveFileContents(furi, csvheader.message, function (result) {
                                    var configIndex= $scope.findConfigurationIndex(configId);
                                    if(configIndex!=-1){ 
                                        var runIndex=$scope.findRunIndex(configIndex,runId);
                                        if(runIndex!=-1){
                                            var resultIndex=$scope.findFileIndex(configIndex,runIndex,f);
                                            if(resultIndex!=-1){
                                                $scope.$apply(function(){
                                                    $scope.model.configurations[configIndex].executions[runIndex].results[resultIndex].file.name=furi;
                                                });
                                            }else
                                                console.info("Unable to find file '"+filename+"' in run '"+runId+"'  of configuration '"+configId+"'");
                                        }else
                                            console.info("Unable to find run '"+runId+"'  in configuration '"+configId+"'");
                                    }else{
                                        console.info("Unable to find configuration: "+configId);
                                    }
                                    //EditorManager.openFile(fileUri);
                                });
                            });
                        },false);
                });
}

$scope.uploadRawDataFile = function(configId,runId,f){
    console.log("Uploading file as result in conducition "+configId+" and run "+runId);
    fileUploadCallback = function(path) {
        var configIndex= $scope.findConfigurationIndex(configId);
        if(configIndex!=-1){ 
            var runIndex=$scope.findRunIndex(configIndex,runId);
            if(runIndex!=-1){
                var resultIndex=$scope.findFileIndex(configIndex,runIndex,f);
                if(resultIndex!=-1){
                    $scope.$apply(function(){
                        $scope.model.configurations[configIndex].executions[runIndex].results[resultIndex].file.name=path;
                    });
                }else
                    console.info("Unable to find file '"+filename+"' in run '"+runId+"'  of configuration '"+configId+"'");
            }else
                console.info("Unable to find run '"+runId+"'  in configuration '"+configId+"'");
        }else{
            console.info("Unable to find configuration: "+configId);
        }
    };
    showContentAsModal("app/modalWindows/uploadFile",
        function () {
                fileUploadCallback=null;
        }
    );
    
}

$scope.generateStudySeedWithContents=function(workspaceContents,statAnalysisResult){
    var param={
                    "workspaceContents": workspaceContents, 
                    "statsComputation": statAnalysisResult,
                    "currentUser":principalUserName,
                    "currentWorkspace":WorkspaceManager.getSelectedWorkspace() ,
                    "currentProject": currentSelectedNode.data.keyPath.substr(0, currentSelectedNode.data.keyPath.indexOf('/'))
            };
    CommandApi.doDocumentOperation("generateSeedStudy", {}, EditorManager.currentUri, function (latex) {
        showContentAsModal("app/modalWindows/createNewFileOfLanguage?language=tex&languageId=ideas-latex-language",
            function () {
                if(!currentSelectedNode)
                    $('#projectsTree').dynatree('getRoot').childList[0].click();
                else
                    currentSelectedNode=getNodeByFileUri(WorkspaceManager.getSelectedWorkspace() + "/" + currentSelectedNode.data.keyPath);
                createNewFile("ideas-latex-language", ".tex",function(furi){
                    console.info("Saving on "+furi+" the content '"+latex.message+"'");
                    FileApi.saveFileContents(furi, latex.message, function (result) {                                  
                        EditorManager.openFile(furi,function(){
                            var model = ModeManager.getMode("ideas-latex-language");
                            launchOperation(model,"compileToPDF", furi);
                        });                                  
                    });
                });
            }
        );
    },false,JSON.stringify(param));
}

$scope.generateStudySeed=function(){
 CommandsRegistry.clearConsole.exec();
 var view=null;
 $.ajax('/ideas-sedl-language/language/operationView/generateseedreport', {
        'type' : 'get',
        'data' : {},
        'success' : function(result) {
                        view = result;
                    },
        'onError' : function(result) {
                            console.log('[ERROR] '+result);
        },
        'async' : false,
 });
 var generateContent=false;
 var generateStats=false;
 var workspaceContents=null;
 var statAnalysisResult=null;
 
 showModal("Report content configuration",view,"Generate", 
  function(){
    generateContent=$("#includeMaterialsListing")[0].checked;
    generateStats=$("#includeAnalysisResults")[0].checked;
    hideModal();
    if(generateStats){
        $scope.computeAllTheStats(function(result){
            statAnalysisResult=$(".gcli-display").html();
            if(generateContent){
               FileApi.loadWorkspace(WorkspaceManager.getSelectedWorkspace(), function(ts){
                    workspaceContents=ts;
                    $scope.generateStudySeedWithContents(workspaceContents,statAnalysisResult);
                });
            } else {
                $scope.generateStudySeedWithContents(workspaceContents,statAnalysisResult);
            }
        });
    }else{ 
        if(generateContent){
            FileApi.loadWorkspace(WorkspaceManager.getSelectedWorkspace(), function(ts){
                workspaceContents=ts;
                $scope.generateStudySeedWithContents(workspaceContents,statAnalysisResult);
            });
        } else {
            $scope.generateStudySeedWithContents(workspaceContents,statAnalysisResult);
        }
    }
  },
  function(){hideModal();},
  function(){hideModal();}
 );
}

$scope.findIndexIn = function (value, set){
    var index = -1;
    for (var i=0;i<set.length;i++) {
        if (value===set[i]) {
            index = i;
        }
    }
    return index;
}

$scope.findIndexInForProperty = function (value, set,property){
    var index = -1;
    for (var i=0;i<set.length;i++) {
        if (value===set[i][property]) {
            index = i;
        }
    }
    return index;
}
 
$scope.runRScript=function(file,callback){
    CommandApi.echo("<p>Running file '"+file+"'")
    var oldFileUriOperation=fileUriOperation;
    fileUriOperation=selectedWorkspace+'/'+file;
    //EditorManager.openFile(fileUriOperation,function(content){
        launchOperation('ideas-R-language','executeScript',fileUriOperation, function (result) { if(callback) callback(result); });
    //});
    fileUriOperation=oldFileUriOperation;
}

$scope.computeAllTheStats=function(callback, analysesIndex, statisticIndex){
    if(typeof analysesIndex === 'undefined')
        analysesIndex=-1;
    if(typeof statisticIndex === 'undefined')
        statisticIndex=-1;
    for(var i=0;i<$scope.model.design.experimentalDesign.intendedAnalyses.length;i++){
        for(var j=0;j<$scope.model.design.experimentalDesign.intendedAnalyses[i].analyses.length;j++){
            if($scope.model.design.experimentalDesign.intendedAnalyses[i].analyses[j].statistic[0]['@type']=="RScript" && ((i>=analysesIndex && j>statisticIndex) || i>analysesIndex)){
                $scope.runRScript($scope.model.design.experimentalDesign.intendedAnalyses[i].analyses[j].statistic[0].fileName,function(){$scope.computeAllTheStats(callback,i,j);});
                return;
            }
        }
    }
    launchOperation('ideas-sedl-language','computestats', EditorManager.currentUri, function (result) {if(callback) callback(result)});    
}