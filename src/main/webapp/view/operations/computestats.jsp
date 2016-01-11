<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div id="op-body">
    <div id="configuration">
        <label id="title">Configurations of </label>
        <div id="configurationFileSelectionContainer">
            <div class="form-group">
                <select id="configurationFiles" class="form-control" name="category">
                    <option value=0>-</option>
                </select>
            </div>
            <button id="run-conf" class="btn btn-primary run">RUN Configuration</button>
        </div>

        <div id="executions">
            <label id="title-exec">Executions of </label>
            <div id="executionsFileSelectionContainer">
                <div class="form-group">
                    <select id="exeuctionFiles" class="form-control" name="category">
                        <option value=0>-</option>
                    </select>
                </div>
                <button id="run-exec" class="btn btn-primary run">RUN Execution</button>
            </div>			
        </div>
    </div>

    <div id="other">
        <label>Other file to execute:</label>
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
    //@ ComputeStatsFindDataFile.js
    $(function () {
        
        var name = EditorManager.currentUri.split("/")[EditorManager.currentUri.split("/").length - 1];
        var ant = $("#title").html();
        var antE = $("#title-exec").html();
        $("#title").html(ant + " " + name);
        $("#title-exec").html(antE + " " + name);

        $("#execution-select").ready(function () {
            var line = $("<div id='line'><label id='l-line'></label><button id='l-button' class='btn btn-primary run'>RUN</button></div>");
        });

        $("#run-exec").click(function () {
            var fUri = $('#executionsFileSelectionContainer select, callback').find(":selected").text();
            FileApi.loadFileContents(WorkspaceManager.getSelectedWorkspace() + "/" + fUri, function (result) {
                CommandApi.doDocumentOperation("computestatscalc", {}, EditorManager.currentUri, function (result) {
                    hideModal();
                    //primaryHandler(result);
                }, result);
            });
        });
        $("#run-conf").click(function () {
            var fUri = $('#configurationFileSelectionContainer select, callback').find(":selected").text();
            FileApi.loadFileContents(WorkspaceManager.getSelectedWorkspace() + "/" + fUri, function (result) {
                CommandApi.doDocumentOperation("computestatscalc", {}, EditorManager.currentUri, function (result) {
                    hideModal();
                    //primaryHandler(result);
                }, result);
            });
        });
        if ($('#configurationFiles option').size() == 1)
            $('#configuration').hide();        

    });

    var loadConfigurations = function (configurations) {
        console.log(configurations);
        var arrayConf = eval('(' + configurations + ')');
        console.log(arrayConf);
        if (configurations == "" || configurations == "undefined") {
            alert("No configurations for " + name);
        } else {
            for (var i = 0; i < arrayConf.configuration.length; i++) {
                console.log(arrayConf.configuration[i]);
                $('#configurationFileSelectionContainer select').append($('<option>', {
                    value: arrayConf.configuration[i],
                    text: arrayConf.configuration[i]
                }));
            }
            for (var i = 0; i < arrayConf.execution.length; i++) {
                console.log(arrayConf.execution[i]);
                $('#executionsFileSelectionContainer select').append($('<option>', {
                    value: arrayConf.execution[i],
                    text: arrayConf.execution[i]
                }));
            }
        }
    }
</script>