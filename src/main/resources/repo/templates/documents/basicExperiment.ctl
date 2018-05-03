$scope.loading = false;

/* CONTEXT*/

/* People */
$scope.addPeople = function(){
    console.info("Adding a new person");
    var person=JSON.parse('{"notes": [],"annotations": [],"id": null,"phone": [],"name": "Write a real name here!","address": null, "email": "specify.a.valid@email.com","role": "Responsible","organization": "Organization of the person"}');
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

$scope.findPeopleByEmail=function (email){
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
        result=JSON.parse('{"variable":null,"level":null}');
        result.variable=$scope.model.design.variables.variable[vindex];
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
                    result.value=generateLevelOfFundamentalSet(domain.constraint[0].fundamentalSet,domain.constraint[1]);
                else
                    result.value=result.value=generateLevelOfFundamentalSet(domain.constraint[0].fundamentalSet,null);
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

/* HYPOTHESES */

$scope.generateHypothesisId = function (){
    return "ChangeMe";
}

$scope.generateDummyHypothesis = function (){
    console.info("Generating a dummy hypotheis ");
    var dependentVariable=$scope.findDependentVariable();
    var independentVariable=$scope.findIndependentVariable();
    var id=generateHypothesisId()
    var result=null;
    if(dependentVariable && independentVariable)
        result=JSON.parse('{"@type" : "DifferentialHypothesis",    "notes" : [ ],    "annotations" : [ ],    "id" : null,    "dependentVariable" : "'+dependentVariable.name+'",    "independentVariables" : [ "'+independentVariable.name+'" ]}');
    else
        result=JSON.parse('{"@type" : "DescriptiveHypothesis","notes" : ["Write your descriptoin here"]}');
    return result;
}


$scope.addNewHypothesis = function (h){
    $scope.model.hypotheses.push(generateDummyHypothesis());
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


/* EXPERIMENTAL GROUPS */

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
            $scope.model.design.experimentalDesign.experimentalProtocol.steps[stepIndex].variableValuation.splice(assignmentIndex,1);
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

$scope.addRun=function(configId){
    var index=$scope.findConfigurationIndex(configId);
    if(index!=-1){
        var defaultRun=JSON.parse('{"id":"Change_me","notes":[],"annotations":[],"log": null,"results": [],"analysisResults": [],"experimentalSetting": null,"start": null,"finish": null}');
        $scope.model.configurations[index].executions.push(defaultRun);
    }else{
        console.info("Unable to find configuration: "+configId);
    }
}

$scope.removeRun=function(configId, runId){
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

$scope.addResult= function (configId,runId) {
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

/* AUXILIARY FUNCTIONS */
$scope.boolToStrAssignment = function(arg) { return arg ? 'Random' : 'Custom'};
