ace.define('ace/theme/SEDL4People', ['require', 'exports', 'module' , 'ace/lib/dom'], function(require, exports, module) {

exports.isDark = false;
exports.cssClass = "ace-sedl";
exports.cssText = ".ace-sedl{\
}\
.ace_header{\
	color: #BC1818;\
	text-decoration: underline;\
}\
.ace_experiment{\
	color: #BC1818;\
	font-style: italic;\
}\
.ace_constant{\
	color: #73214F;\
}\
.ace_variable{\
	color: #DF7401;\
}\
.ace_hypothesis{\
	color: #DF7401;\
}\
.ace_design,.ace_type{\
	color: #BC1818;\
	font-style: oblique;\
}\
.ace_method{\
	color: #DF7401;\
}\
.ace_function{\
	color: #DF7401;\
}\
.ace_numeric.ace_sets{\
	font-style:oblique;\
	font-weight: 900;\
}\
.ace_correlation.ace_Types{\
	color: #DF7401;\
}\
.ace_comment{\
	color: #0000FF;\
}\
.ace_global{\
	color: red;\
}\
.ace_configuration{\
	color: #BC1818;\
	font-style: oblique;\
}\
.ace_setting{\
	color: #BC1818;\
	font-style: oblique;\
}\
.ace_units,.ace_filters,.ace_commands,.ace_execution,.ace_fileRoles,.ace_file,.ace_configTypes,.ace_preamble{\
	color: orange;\
}\
.ace_string{\
	color: #424242;\
}\
.ace_url{\
	color: #0000FF;\
}\
.ace_variables{\
	color: #000000;\
}\
.ace_comments{\
	color: #0000FF;\
}\
.ace-sedl .ace_gutter {\
background: rgba(250, 250, 250, 0.5);\
color: #BDBDBD;\
overflow : visible;\
border-right: 1px solid rgba(0,0,0,0.05);\
}\
.ace-sedl .ace_print-margin {\
width: 1px;\
background: #e8e8e8;\
}\
.ace-sedl {\
background-color: #FFFFFF;\
}\
.ace-sedl .ace_cursor {\
color: black;\
}\
.ace-sedl .ace_invisible {\
color: rgb(191, 191, 191);\
}\
.ace-sedl .ace_constant.ace_buildin {\
color: rgb(88, 72, 246);\
}\
.ace-sedl .ace_constant.ace_language {\
color: rgb(88, 92, 246);\
}\
.ace-sedl .ace_constant.ace_library {\
color: rgb(6, 150, 14);\
}\
.ace-sedl .ace_invalid {\
background-color: rgb(153, 0, 0);\
color: white;\
}\
.ace-sedl .ace_fold {\
}\
.ace-sedl .ace_support.ace_function {\
color: rgb(60, 76, 114);\
}\
.ace-sedl .ace_support.ace_constant {\
color: rgb(6, 150, 14);\
}\
.ace-sedl .ace_support.ace_type,\
.ace-sedl .ace_support.ace_class\
.ace-sedl .ace_support.ace_other {\
color: rgb(109, 121, 222);\
}\
.ace-sedl .ace_variable.ace_parameter {\
font-style:italic;\
color:#FD971F;\
}\
.ace-sedl .ace_constant.ace_numeric {\
color: rgb(0, 0, 205);\
}\
.ace-sedl .ace_xml-pe {\
color: rgb(104, 104, 91);\
}\
.ace-sedl .ace_entity.ace_name.ace_function {\
color: #0000A2;\
}\
.ace-sedl .ace_heading {\
color: rgb(12, 7, 255);\
}\
.ace-sedl .ace_list {\
color:rgb(185, 6, 144);\
}\
.ace-sedl .ace_marker-layer .ace_selection {\
background: rgba(45, 151, 221, 0.29);\
}\
.ace-sedl .ace_marker-layer .ace_step {\
background: rgb(252, 255, 0);\
}\
.ace-sedl .ace_marker-layer .ace_stack {\
background: rgb(164, 229, 101);\
}\
.ace-sedl .ace_marker-layer .ace_bracket {\
margin: -1px 0 0 -1px;\
border: 1px solid rgb(192, 192, 192);\
}\
.ace-sedl .ace_marker-layer .ace_active-line {\
background: rgba(133, 151, 170, 0.09);\
}\
.ace-sedl .ace_gutter-active-line {\
background-color: rgba(66, 66, 66, 0.06);\
border-right: 1px solid rgba(66, 128, 178, 0.19);\
right: -1px;\
}\
.ace-sedl .ace_marker-layer .ace_selected-word {\
background: rgba(66, 128, 178, 0.12);\
border-bottom: 1px solid rgba(66, 128, 178, 0.19);\
}\
.ace-sedl .ace_storage,\
.ace-sedl .ace_meta.ace_tag {\
color: rgb(147, 15, 128);\
}\
.ace-sedl .ace_entity.ace_other.ace_attribute-name {\
color: #994409;\
}\
";

var dom = require("../lib/dom");
dom.importCssString(exports.cssText, exports.cssClass);
});
