<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div id="op-body">
    <div id="configuration">
        <label id="title">Additional Contents of the seed report:</label><br/>
        <input id="includeMaterialsListing" name="includeMaterialsListing" type="checkbox"></input><label>Include listing of materials present in the workspace</label><br>
        <input id="includeAnalysisResults" name="includeAnalysisResults" type="checkbox"></input><label>Include the results of a just-in-time execution of the statistical analyses.</label>
    </div>   
</div>

<!-- CSS FUNCTIONS-->
<style>
    .modal-body {
        padding-bottom: 0px;
    }
    .modal-footer {
        border-top: none;
    }
    #executionsFileSelectionContainer, #configurationFileSelectionContainer {
        height: 90px;
    }
    .run {
        float: right;
    }
</style>

<!-- SCRIPT FUNCTIONS-->
<script>
    
  
</script>