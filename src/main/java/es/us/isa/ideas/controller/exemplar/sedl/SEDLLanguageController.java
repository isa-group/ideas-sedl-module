package es.us.isa.ideas.controller.exemplar.sedl;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;
import es.us.isa.ideas.module.common.AppAnnotations;
import es.us.isa.ideas.module.common.AppResponse;
import es.us.isa.ideas.module.common.AppResponse.Status;
import es.us.isa.ideas.module.controller.BaseLanguageController;
import es.us.isa.sedl.core.ControlledExperiment;
import es.us.isa.sedl.core.EmpiricalStudy;
import es.us.isa.sedl.core.util.Error;
import es.us.isa.sedl.core.util.SEDLMarshaller;
import es.us.isa.sedl.core.util.xml.XMLMarshaller;
import es.us.isa.sedl.core.util.xml.XMLUnmarshaller;
import es.us.isa.sedl.marshaller.SEDL4PeopleMarshaller;
import es.us.isa.sedl.marshaller.SEDL4PeopleStringTemplateMarshaller;
import es.us.isa.sedl.marshaller.SEDL4PeopleUnmarshaller;
import es.us.isa.sedl.module.sedl4people.SEDL4PeopleExtensionPointsUnmarshallerImplementation;
import es.us.isa.sedl.sedl4json.JSONMarshaller;
import es.us.isa.sedl.sedl4json.JSONUnmarshaller;
import es.us.isa.sedl.semantic.SEDLSemanticChecker;
import javax.servlet.http.HttpServletRequest;


@Controller
@RequestMapping("/language")
public class SEDLLanguageController extends BaseLanguageController {

	@RequestMapping(value = "/operation/{id}/execute", method = RequestMethod.POST)
	@ResponseBody
	public AppResponse executeOperation(String id, String content, String fileUri, String auxArg0,HttpServletRequest req) {
		
		AppResponse response;
		AnalyserDelegate analiser = new AnalyserDelegate();
		
		if (id.equals(AnalyserDelegate.NUMBER_OF_BLOCKS))
			response = analiser.numberOfBlocks(content, fileUri);
		else if (id.equals(AnalyserDelegate.SAMPLE_SIZE))
			response = analiser.sampleSize(content, fileUri);
		else if (id.equals(AnalyserDelegate.SMALL_SAMPLING))
			response = analiser.smallSampling(content, fileUri);
		else if (id.equals(AnalyserDelegate.MULTIPLE_COMPARISON))
			response = analiser.multipleComparison(content, fileUri);
		else if (id.equals(AnalyserDelegate.OUT_OF_RANGE))
			response = analiser.outOfRange(content, fileUri);
		else if (id.equals(AnalyserDelegate.OUT_OF_RANGE_CSV))
			response = analiser.outOfRangeCSV(content, fileUri, auxArg0);
		else if (id.equals(AnalyserDelegate.COMPUTE_STATS))
			response = analiser.computeStats(content, fileUri);
		else if (id.equals(AnalyserDelegate.COMPUTE_STATS_CALC)){
			response = analiser.computeStatsCalc(content, fileUri, auxArg0);
                }else if (id.equals(AnalyserDelegate.GENERATE_RAW_DATA_TEMPLATE)){
			response = analiser.generateRawDataTemplatec(content, fileUri, auxArg0);
                }else if (id.equals(AnalyserDelegate.GENERATE_SEED_STUDY)){
			response = analiser.generateSeedStudy(content, fileUri, auxArg0);
		}else {
			response = new AppResponse();
			response.setMessage("No analisis operation with id " + id);
			response.setStatus(Status.ERROR);
		}
		
		return response;
	}
	
	@RequestMapping(value = "/format/{format}/checkLanguage", method = RequestMethod.POST)
	@ResponseBody
	public AppResponse checkLanguage(String id, String content, String fileUri,HttpServletRequest req) {
		
		AppResponse appResponse = new AppResponse();
		SEDL4PeopleUnmarshaller unmarshaller = new SEDL4PeopleUnmarshaller();
                unmarshaller.setEpUnmarshaller(new SEDL4PeopleExtensionPointsUnmarshallerImplementation());
		EmpiricalStudy experiment = unmarshaller.fromString(content);
		
		boolean problems = false;
		
		if ( experiment == null ) {
			// provisional
			AppAnnotations[] annotations = ErrorBuilder.buildErrorStructure( unmarshaller.getErrors() );
			appResponse.setAnnotations(annotations);
			problems = true;
		} else {
			
			SEDLSemanticChecker semantic = new SEDLSemanticChecker(experiment, unmarshaller.getListener().getObjectNodeMap(), unmarshaller.getTokens());
			List<Error> lError = semantic.checkSemantic();
                        lError.addAll(unmarshaller.getErrors());
			if ( !lError.isEmpty() ) {
				AppAnnotations[] annotations = ErrorBuilder.buildSemanticErrorStructure(lError);
				appResponse.setAnnotations(annotations);
				problems = true;
			} 
		}
		//System.out.println("CheckSyntax: " + res );
		appResponse.setFileUri(fileUri);
		
		if (problems)
			appResponse.setStatus(Status.OK_PROBLEMS);
		else
			appResponse.setStatus(Status.OK);
		
		
		return appResponse;
	}

	@RequestMapping(value = "/convert", method = RequestMethod.POST)
	@ResponseBody
	public AppResponse convertFormat(String currentFormat, String desiredFormat, String fileUri, String content,HttpServletRequest req) {
		AppResponse appResponse = new AppResponse();
		
		if (currentFormat.equals("sedl") && desiredFormat.equals("xml")) {
			
			String xmlData = "";
			
			try {
				SEDL4PeopleUnmarshaller sedl4peopleUnmarsh = new SEDL4PeopleUnmarshaller();
				SEDLMarshaller xmlMarsh = new XMLMarshaller();
				OutputStream outStream = new ByteArrayOutputStream();
				EmpiricalStudy exp = sedl4peopleUnmarsh.fromString(content);
				xmlData = es.us.isa.sedl.jlibsedl.JLibSEDL.getXML(exp, outStream, xmlMarsh);
				appResponse.setStatus(Status.OK);
			} catch ( Exception e ) {   
				appResponse.setStatus(Status.ERROR);
				appResponse.setMessage(e.getMessage());
				e.printStackTrace();
				return appResponse;
			}
			
			appResponse.setData(xmlData);
			appResponse.setFileUri(fileUri);
			
		} else if (currentFormat.equals("xml") && desiredFormat.equals("sedl") ) {
			
			String data = "";
			
			try {
                            //SEDL4PeopleMarshaller marshaller = new SEDL4PeopleMarshaller();
                            SEDL4PeopleStringTemplateMarshaller marshaller = new SEDL4PeopleStringTemplateMarshaller();
				XMLUnmarshaller<ControlledExperiment> xmlUnmarsh = new XMLUnmarshaller<ControlledExperiment>();
				InputStream inStream = new ByteArrayInputStream(content.getBytes("UTF-8"));
				EmpiricalStudy exp = xmlUnmarsh.load(ControlledExperiment.class, inStream);
				data = marshaller.asString(exp);
				appResponse.setStatus(Status.OK);
			} catch ( Exception e ) {
				appResponse.setStatus(Status.ERROR);
				appResponse.setMessage(e.getMessage());
				e.printStackTrace();
				return appResponse;
			}
			
			appResponse.setData(data);
			appResponse.setFileUri(fileUri);
		}else if (currentFormat.equals("sedl") && desiredFormat.equals("json") ) {
                    try {
                        SEDL4PeopleUnmarshaller sedl4peopleUnmarsh = new SEDL4PeopleUnmarshaller();
                        sedl4peopleUnmarsh.setEpUnmarshaller(new SEDL4PeopleExtensionPointsUnmarshallerImplementation());
                        EmpiricalStudy exp = sedl4peopleUnmarsh.fromString(content);
                        JSONMarshaller marshaller=new JSONMarshaller();
                        appResponse.setData(marshaller.asString(exp));
                        appResponse.setFileUri(fileUri);
                        appResponse.setStatus(Status.OK);
                    } catch(Exception e){
                        appResponse.setStatus(Status.ERROR);
			appResponse.setMessage(e.getMessage());
			e.printStackTrace();
			return appResponse;
                    }
                }else if (currentFormat.equals("json") && desiredFormat.equals("sedl") ) {
                    try {
                        JSONUnmarshaller sedl4peopleUnmarsh = new JSONUnmarshaller();
                        EmpiricalStudy exp = sedl4peopleUnmarsh.fromString(content);
                        SEDL4PeopleMarshaller marshaller=new SEDL4PeopleMarshaller();
                        appResponse.setData(marshaller.asString(exp));
                        appResponse.setFileUri(fileUri);
                        appResponse.setStatus(Status.OK);
                    } catch(Exception e){
                        appResponse.setStatus(Status.ERROR);
			appResponse.setMessage(e.getMessage());
			e.printStackTrace();
			return appResponse;
                    }
                } else {
			appResponse.setStatus(Status.ERROR);
			appResponse.setMessage("Not a valid conversion: from " + currentFormat + " to " + desiredFormat);
		}
		
		return appResponse;
	}
	
	// Analysis operations:
	@RequestMapping(value = "/operationView/{id}", method = RequestMethod.GET)
	@ResponseBody
	public ModelAndView getOperationView(@PathVariable String id){
		System.out.println("Entra en controller " + id);
		ModelAndView result;
		result = new ModelAndView("operations/"+id);
		return result;
		
		//System.out.println("Entra en controller "+result.getView().toString() +" " +result.toString());
		
		
		
//		appResponse.setData(result.getView());
//		return appResponse;
	}
        
        @RequestMapping(value = "/modulesLoaded", method = RequestMethod.GET)
	@ResponseBody
        public ModelAndView getModulesLoaded(){
            return new ModelAndView("modulesLoaded");
        }        

}
