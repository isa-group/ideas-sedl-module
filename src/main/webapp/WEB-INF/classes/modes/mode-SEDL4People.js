/*
 * based on
 * " Vim SEDL Sintaxis file
 * "    Language: SEDL - Sintaxis
 * "    Revision: 2.1
 * "  Maintainer: GHR
 * " Last Change: 2012 Oct 23
 */

ace.define('ace/mode/SEDL4People', ['require', 'exports', 'module' , 'ace/tokenizer', 'ace/mode/abap_highlight_rules', 'ace/mode/folding/coffee', 'ace/range', 'ace/mode/text', 'ace/lib/oop'], function(require, exports, module) {

var Tokenizer = require("../tokenizer").Tokenizer;
var Rules = require("./sintaxis_highlight_rules").AbapHighlightRules;
var FoldMode = require("./folding/coffee").FoldMode;
var Range = require("../range").Range;
var TextMode = require("./text").Mode;
var oop = require("../lib/oop");

function Mode() {
    this.HighlightRules = Rules;
    this.foldingRules = new FoldMode();
}

oop.inherits(Mode, TextMode);

(function() {
    
    this.getNextLineIndent = function(state, line, tab) {
        var indent = this.$getIndent(line);
        return indent;
    };
    
    this.toggleCommentLines = function(state, doc, startRow, endRow){
        var range = new Range(0, 0, 0, 0);
        for (var i = startRow; i <= endRow; ++i) {
            var line = doc.getLine(i);
            if (hereComment.test(line))
                continue;
                
            if (commentLine.test(line))
                line = line.replace(commentLine, '$1');
            else
                line = line.replace(indentation, '$&#');
    
            range.end.row = range.start.row = i;
            range.end.column = line.length + 1;
            doc.replace(range, line);
        }
    };
    
    this.$id = "ace/mode/sintaxis";
}).call(Mode.prototype);

exports.Mode = Mode;

});


ace.define('ace/mode/sintaxis_highlight_rules', ['require', 'exports', 'module' , 'ace/lib/oop', 'ace/mode/text_highlight_rules'],function(require, exports, module) {
"use strict";

var oop = require("../lib/oop");
var TextHighlightRules = require("./text_highlight_rules").TextHighlightRules;

var AbapHighlightRules = function() {

    var keywordMapper = this.createKeywordMapper({
        "variable.language": "this",
        "token_Keyword.blockHeader": 
            "EXPERIMENT Constants Variables Hypothesis Design Configuration",
        "entity-name-tag.EXPERIMENT.1": 
            "Object Population Accessible_Population Subjects Notes Annotations Responsible Collaborator",
        "entity-name-tag.Constants.1": 
            "Solver Termination_criterion RandomNumberGenerator NFeatures CTC CrossoverProb MutationProb PopulationSize Executions",
        "variable.Variables.1":
            "Factors NCFactors Outcomes Outcome Extraneous",
        "entity-name-tag.Hypothesis.values":
            "Differential Descriptive Associational" ,
        "variable.Hypothesis.values":
            "Random RandomBlockAdhoc RandomBlock" ,
        "entity-name-tag.Design.1":
            "Sampling Groups Protocol Analyses Alignment Analyses_Spec Detailed_Design Assignment Blocking sizing Grouping" ,
        "entity-name-tag.Configuration.1":
            "Outputs Inputs Setting Experimental_Setting Experimental_Procedure Procedure Runtimes Libraries Command Treatment Preprocessing Postprocessing Measurement Miscellaneous Additional_Evidence role format mapping Result Runs Start End" ,
        "variable.functions.1":
            "linear cuadratic Random Adhoc Pvalue Sthreshold freedom_degrees Mean Mode Avg StdDev Variance Range CI IQR Ranking Pearson ANOVA Friedman Tukey KruskalWalls TTest Wilcoxon Holms FactANOVAwRS Chi Square Median " +
            "SignTest Kolmogorov-Smirnov Lilliefors Shapiro-Wilk Levene T-student McNemar Aligned Friedman Iman & Davenport Quade Cochran Q Bonferroni-Dunn Hochberg Hommel Holland Rom Finner Li Shaffer Nemenyi Fisher" ,
        "entity-name-tag.types.1":
            "float integer enum ordered boolean" ,
        "entity-name-tag.inlineOperator.1":
            "version rep sizingrole format mapping as in size",
        "variable.Variables.inlineOperator.2":
            "(File)",
        "numeric.sets":
        	"N Z Q R I C p-value",
        "correlation.Types":
        	"BivariateRegression Spearman Kendall Cramer LogLinear"
            
    }, "text", true, " ");
    
    var headers = "\\b(EXPERIMENT|Constants|Variables|Hypothesis|Design|Configuration)\\b";
    var experiments = "\\b(Object|Population|Accessible_Population|Subjects)\\b";
    var preamble = "\\b(version|rep)\\b";
    var constants = "\\b(Solver|Termination_criterion|RandomNumberGenerator|NFeatures|CTC|CrossoverProb|MutationProb|PopulationSize|Executions)\\b";
    var variables = "\\b(Factors|NCFactors|Outcomes|Outcome|Extraneous)\\b";
    var hypothesis = "(\\b(Differential|Descriptive|Associational)\\b)";
    var explicitAssociationalHypothesis = "(\\b(is correlated with|is (linearly |logistically) correlated with)\\b)";
    var explicitDifferentialHypothesis = "(\\b(impacts on|impacts significantly on)\\b)";
    var design = "\\b(Sampling|Groups|Protocol|Analyses|Alignment|Analyses_Spec|Detailed_Design|Assignment|Grouping|in)\\b";
    var grouping="(\\b(by|sizing)\\b)";
    var sampling="\\b(Assignment|Blocking)\\b";
    var samplingMethods = "(\\b(Random|RandomBlockAdhoc|RandomBlock)\\b)";
    var assignmentsMethods = "(\\b(Random|Adhoc)\\b)";
    var protocolTypes = "(\\b(Random|Adhoc)\\b)";
    var configuration = "\\b(Outputs|Inputs|Setting|Experimental_Setting|Experimental_Procedure|Procedure)\\b";
    var configTypes="\\b(Role|Format|Mapping)\\b";
    var commands = "(\\b(Command as ( |Treatment|Measurement|Postprocessing|Preprocessing))|(Command)\\b)";
    var execution ="(\\b(Runs|Start|End|Result|Analyses)\\b)";
    var fileRoles="(\\b(Miscellaneous|Additional_Evidence|Result)\\b)";
    var file="(\\b(File)\\b)";
    
    var global =  "(\\b(float|integer|enum|ordered|boolean)\\b)";
    var otherVariables = "(\\b\\d+(\\.\\d+)?\\b)";
   
    
    var numerics = "(\\b(N|Z|Q|R|I|C|p-value|range)\\b)";
    var units = "\\bmeasured in\\b";
    var filters="(\\b(?:where|of|by)\\b)";
    var setting="\\b(Runtimes|Libraries)\\b";
    
    var functions = "(\\b(linear|cuadratic|Pvalue|Sthreshold|freedom_degrees)\\b)";
    var centralTendency="(\\b(Avg|Mean|Median|Mode)\\b)";
    var variability=	"(\\b(CI|StdDev|Variance|Range|IQR)\\b)";
    var rankings=	"(\\b(?:Ranking)\\b)";
    var statAnalysis= "(\\b(?:ANOVA|Friedman|Tukey|KruskalWalls|TTest|Wilcoxon|Holms|FactANOVAwRS|File|Chi Square|Median|SignTest|Kolmogorov-Smirnov|Lilliefors|Shapiro-Wilk|Levene|T-student|McNemar|Aligned Friedman|Iman & Davenport|Quade|Cochran Q|Bonferroni-Dunn|Hochberg|Hommel|Holland|Rom|Finner|Li|Shaffer|Nemenyi|Fisher)\\b)";
    var correlation = "(\\b(?:Pearson|LogLinear|BivariateRegression|Spearman|Kendall|Cramer)\\b)";
    
    var url = "((http://|https://|ftp://|www.|localhost/|localhost:)([^\\s])+)";
    var comments = "(//.+)";
     
    this.$rules = {
        "start" : [ 
            {token : "header", regex : headers},
            {token : "experiment", regex : experiments},
            {token : "preamble", regex : preamble},
            {token : "constant", regex : constants},
            {token : "variable", regex : variables},
            {token : "hypothesis", regex : hypothesis},
            {token : "hypothesis", regex : explicitAssociationalHypothesis},
            {token : "hypothesis", regex : explicitDifferentialHypothesis},
            {token : "design", regex : design},
            {token : "design", regex : sampling},
            {token : "method", regex : samplingMethods},
            {token : "method", regex : assignmentsMethods},
            {token : "method", regex : protocolTypes},
            {token : "function", regex : functions},
            {token : "function", regex : centralTendency},
            {token : "function", regex : variability},
			{token : "function", regex : statAnalysis},
			{token : "function", regex : rankings},
            {token : "function", regex : correlation},
            {token : "type", regex : configTypes},
            {token : "file", regex : file},
            {token : "type", regex : fileRoles},
            {token : "execution", regex : execution},
            {token : "type", regex : commands},
            {token : "method", regex : filters},
            {token : "units", regex : units},
            {token : "setting", regex : setting},
            {token : "variables", regex : otherVariables},
            {token : "variables", regex : variables},
            {token : "configuration", regex : configuration},
            {token : "global", regex : global},
            {token : "numeric.sets", regex : numerics},
            {token : "url", regex : url},
            {token : "comments", regex : comments},
            {token : "comment", regex : "\\/\\/.*$" },
            {token : "comment",  regex : "\\/\\*", next : "comment" },//multiline comment
            {token : "string", regex : "'", next  : "qstring"},
            {caseInsensitive: false}
        ],
        "qstring" : [
            {token : "constant.language.escape",   regex : "''"},
            {token : "string", regex : "'",     next  : "start"},
            {defaultToken : "string"}
        ],
        "comment" : [
                     {token : "comment", regex : ".*?\\*\\/", next : "start"}, 
                     {token : "comment",regex : ".+"}
        ]
    };
};
oop.inherits(AbapHighlightRules, TextHighlightRules);

exports.AbapHighlightRules = AbapHighlightRules;
});


ace.define('ace/mode/folding/coffee', ['require', 'exports', 'module' , 'ace/lib/oop', 'ace/mode/folding/fold_mode', 'ace/range'], function(require, exports, module) {


var oop = require("../../lib/oop");
var BaseFoldMode = require("./fold_mode").FoldMode;
var Range = require("../../range").Range;

var FoldMode = exports.FoldMode = function() {};
oop.inherits(FoldMode, BaseFoldMode);

(function() {

    this.getFoldWidgetRange = function(session, foldStyle, row) {
        var range = this.indentationBlock(session, row);
        if (range)
            return range;

        var re = /\S/;
        var line = session.getLine(row);
        var startLevel = line.search(re);
        if (startLevel == -1 || line[startLevel] != "#")
            return;

        var startColumn = line.length;
        var maxRow = session.getLength();
        var startRow = row;
        var endRow = row;

        while (++row < maxRow) {
            line = session.getLine(row);
            var level = line.search(re);

            if (level == -1)
                continue;

            if (line[level] != "#")
                break;

            endRow = row;
        }

        if (endRow > startRow) {
            var endColumn = session.getLine(endRow).length;
            return new Range(startRow, startColumn, endRow, endColumn);
        }
    };
    this.getFoldWidget = function(session, foldStyle, row) {
        var line = session.getLine(row);
        var indent = line.search(/\S/);
        var next = session.getLine(row + 1);
        var prev = session.getLine(row - 1);
        var prevIndent = prev.search(/\S/);
        var nextIndent = next.search(/\S/);

        if (indent == -1) {
            session.foldWidgets[row - 1] = prevIndent!= -1 && prevIndent < nextIndent ? "start" : "";
            return "";
        }
        if (prevIndent == -1) {
            if (indent == nextIndent && line[indent] == "#" && next[indent] == "#") {
                session.foldWidgets[row - 1] = "";
                session.foldWidgets[row + 1] = "";
                return "start";
            }
        } else if (prevIndent == indent && line[indent] == "#" && prev[indent] == "#") {
            if (session.getLine(row - 2).search(/\S/) == -1) {
                session.foldWidgets[row - 1] = "start";
                session.foldWidgets[row + 1] = "";
                return "";
            }
        }

        if (prevIndent!= -1 && prevIndent < indent)
            session.foldWidgets[row - 1] = "start";
        else
            session.foldWidgets[row - 1] = "";

        if (indent < nextIndent)
            return "start";
        else
            return "";
    };

}).call(FoldMode.prototype);

});