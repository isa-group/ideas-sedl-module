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


/* RUNS */

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
