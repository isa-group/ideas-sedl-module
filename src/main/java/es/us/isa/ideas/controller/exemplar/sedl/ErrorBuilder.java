package es.us.isa.ideas.controller.exemplar.sedl;

import java.util.ArrayList;
import java.util.List;


import es.us.isa.ideas.common.AppAnnotations;
import es.us.isa.ideas.common.AppAnnotations.Type;
import es.us.isa.sedl.core.BasicExperiment;
import es.us.isa.sedl.core.util.Error;
import es.us.isa.sedl.core.util.Error.ERROR_SEVERITY;
import es.us.isa.sedl.error.SEDL4PeopleError;
import es.us.isa.sedl.runtime.analysis.validation.ValidationError;


public class ErrorBuilder {

	// refactorizar
	public static AppAnnotations[] buildErrorStructure(
			List<? extends Error> lErrors) {

		System.out.println("Building errors: " + lErrors.toString());

		List<AppAnnotations> result = new ArrayList<AppAnnotations>();

		for (int i = 0; i < lErrors.size(); i++) {

			AppAnnotations annotations = new AppAnnotations();

			Error err = lErrors.get(i);

			annotations.setRow(err.getLineNo() + "");
                        if(err instanceof SEDL4PeopleError)
                            annotations.setColumn(((SEDL4PeopleError)err).getCharStart() + "");
                        
                        
                        if(err.getMessage()!=null){
                            String text = err.getMessage();
                            text = text.replace("\"", "\\\"");
                            text = text.replace("\'", "\\\'");
                            annotations.setText(text);
                        }
			if (err.getSeverity().equals(ERROR_SEVERITY.INFO))
				annotations.setType("info");
			else if (err.getSeverity().equals(ERROR_SEVERITY.WARNING))
				annotations.setType("warning");
			else
				annotations.setType("error");

			result.add(annotations);

		}

		return result.toArray(new AppAnnotations[result.size()]);
	}

	public static AppAnnotations[] buildSemanticErrorStructure(List<Error> lErrors) {
		
		System.out.println("Building errors: " + lErrors.toString());
		
		List<AppAnnotations> result = new ArrayList<AppAnnotations>();
		for (int i = 0; i < lErrors.size(); i++) {
			Error err = lErrors.get(i);
			
			AppAnnotations annotations = new AppAnnotations();

			
			annotations.setRow(err.getLineNo() + "");
			annotations.setColumn("1");
			annotations.setText(err.getMessage().replace("\"", "\\\"")
					.replace("\'", "\\\'"));
			if (err.getSeverity().equals(ERROR_SEVERITY.INFO))
				annotations.setType("info");
			else if (err.getSeverity().equals(ERROR_SEVERITY.WARNING))
				annotations.setType("warning");
			else
				annotations.setType("error");
			
			
			result.add(annotations);
		}


		return result.toArray(new AppAnnotations[result.size()]);
	}

	public static String buildValidationErrorStructure(
			List lErrors) {
		System.out.println("Building errors: " + lErrors.toString());
		String result = "[";
		for (int i = 0; i < lErrors.size(); i++) {
			ValidationError<BasicExperiment> err = (ValidationError)lErrors.get(i);
			if (i != 0) {
				result += ",";
			}
			result += "{";
			result += "row:" + err.getLineNo() + ",";
			result += "text: \""
					+ err.getMessage().replace("\"", "\\\"")
							.replace("\'", "\\\'") + "\",";

			if (err.getSeverity().equals(ERROR_SEVERITY.INFO)) {
				result += "type: \"info\"";
			} else if (err.getSeverity().equals(ERROR_SEVERITY.WARNING)) {
				result += "type: \"warning\"";
			} else {
				result += "type: \"error\"";
			}
			result += "}";
		}

		result += "]";

		return result;
	}

	public static AppAnnotations[] buildAnnotationsFromValidationErrors(
			List errors) {

		List<AppAnnotations> retList = new ArrayList<AppAnnotations>();
                ValidationError val=null;
		for (Object er : errors) {
                        val=(ValidationError)er;
			AppAnnotations ann = new AppAnnotations();
			ann.setRow(String.valueOf(val.getLineNo()));
			ann.setColumn("1");
			ann.setText(val.getMessage());
			if (val.getSeverity().equals(
					es.us.isa.exemplar.commons.util.Error.ERROR_SEVERITY.ERROR)) {
				ann.setType(Type.ERROR);
			} else if (val.getSeverity().equals(
					es.us.isa.exemplar.commons.util.Error.ERROR_SEVERITY.FATAL)) {
				ann.setType(Type.FATAL);
			} else if (val.getSeverity().equals(
					es.us.isa.exemplar.commons.util.Error.ERROR_SEVERITY.INFO)) {
				ann.setType(Type.INFO);
			} else if (val
					.getSeverity()
					.equals(es.us.isa.exemplar.commons.util.Error.ERROR_SEVERITY.WARNING)) {
				ann.setType(Type.WARNING);
			}
			retList.add(ann);
		}
		return retList.toArray(new AppAnnotations[retList.size()]);
	}

}
