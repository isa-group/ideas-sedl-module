package es.us.isa.ideas.controller.exemplar.sedl;

import java.util.ArrayList;
import java.util.List;

import org.antlr.v4.runtime.tree.RuleNode;


import es.us.isa.ideas.module.common.AppResponse;
import es.us.isa.ideas.module.common.AppResponse.Status;
import es.us.isa.sedl.analysis.errors.SEDL4PeopleReferenceDelegate;
import es.us.isa.sedl.analysis.operations.information.computestats.ComputeStats;
import es.us.isa.sedl.analysis.operations.information.NumberOfBlocks;
import es.us.isa.sedl.analysis.operations.information.computestats.StatisticalAnalysisOperation;
import es.us.isa.sedl.analysis.operations.information.SampleSize;
import es.us.isa.sedl.analysis.operations.validation.MultipleComparison;
import es.us.isa.sedl.analysis.operations.validation.OutOfRange;
import es.us.isa.sedl.analysis.operations.validation.SmallSampling;
import es.us.isa.sedl.core.BasicExperiment;
import es.us.isa.sedl.core.design.FullySpecifiedExperimentalDesign;
import es.us.isa.sedl.core.design.Variable;
import es.us.isa.sedl.core.execution.Execution;
import es.us.isa.sedl.marshaller.SEDL4PeopleUnmarshaller;
import es.us.isa.sedl.runtime.analysis.validation.ValidationError;
import es.us.isa.sedl.core.util.Error;
import es.us.isa.sedl.module.sedl4people.SEDL4PeopleExtensionPointsUnmarshallerImplementation;

class AnalyserDelegate {

	// TODO: Revise. Refactored from original exemplar code.

	// Temp
	public final static String NUMBER_OF_BLOCKS = "numberofblocks";
	public final static String SAMPLE_SIZE = "samplesize";
	public final static String OUT_OF_RANGE = "outofrange";
	public final static String OUT_OF_RANGE_CSV = "outofrangecsv";
	public final static String COMPUTE_STATS = "computestats";
	public final static String COMPUTE_STATS_CALC = "computestatscalc";
        public final static String GENERATE_RAW_DATA_TEMPLATE = "generateRawDataTemplate";
        public final static String GENERATE_SEED_STUDY = "generateSeedStudy";

	// Validations
	public final static String SMALL_SAMPLING = "smallsampling";
	public final static String MULTIPLE_COMPARISON = "multiplecomparison";

	private NumberOfBlocks nBlocks = new NumberOfBlocks();
	private SampleSize sampleSize = new SampleSize();

	private SmallSampling sampling = new SmallSampling();
	private MultipleComparison multipleComparison = new MultipleComparison();
	private SEDL4PeopleUnmarshaller sedl4peopleUnmarsh;
	private SEDL4PeopleReferenceDelegate sedlDelegate = new SEDL4PeopleReferenceDelegate();

	private OutOfRange outOfRange = new OutOfRange();
	private ComputeStats computeStats = new ComputeStats();
	

	public AnalyserDelegate() {
		super();
                sedl4peopleUnmarsh= new SEDL4PeopleUnmarshaller();
                sedl4peopleUnmarsh.setEpUnmarshaller(new SEDL4PeopleExtensionPointsUnmarshallerImplementation());
	}

	public AppResponse numberOfBlocks(String content, String fileUri) {
		
		AppResponse response = constructBaseResponse(fileUri);
		
		try {
			response.setMessage(String.valueOf(nBlocks.apply(getExperimentFromCode(content))));
		} catch (Exception e) {
			response.setMessage(e.getMessage());
			response.setStatus(Status.ERROR);
		}
		
		return response;
	}

	public AppResponse sampleSize(String content, String fileUri) {
		
		AppResponse response = constructBaseResponse(fileUri);
		
		try {
			response.setMessage( String.valueOf( sampleSize.apply(getExperimentFromCode(content))) );
		} catch (Exception e) {
			response.setMessage(e.getMessage());
			response.setStatus(Status.ERROR);
		}
		
		return response;
	}

	public AppResponse smallSampling(String content, String fileUri) {

		AppResponse response = constructBaseResponse(fileUri);
		
		try {
			
			BasicExperiment exp = getExperimentFromCode(content);
			List<ValidationError<BasicExperiment>> errors = sampling.validate(exp);
			if ( !errors.isEmpty() ) {
				response.setMessage("Check for sample size problems.");
				FullySpecifiedExperimentalDesign design = (FullySpecifiedExperimentalDesign) exp.getDesign().getExperimentalDesign();
				RuleNode ctx = sedl4peopleUnmarsh.getListener().getObjectNodeMap().get( design.getGroups());
				List<RuleNode> lCtx = new ArrayList<RuleNode>();
				lCtx.add(ctx);
				List<ValidationError<BasicExperiment>> error = sedlDelegate.fillValidationError(lCtx, sedl4peopleUnmarsh.getTokens(), errors);
				response.setAnnotations(ErrorBuilder.buildAnnotationsFromValidationErrors(error));
			}else {
				response.setMessage("Experiment sample size is correct.");
			}
			
		} catch (Exception e) {
			response.setMessage(e.getMessage());
			response.setStatus(Status.ERROR);
		}
		
		return response;
	}

	public AppResponse multipleComparison(String content, String fileUri) {

		AppResponse response = constructBaseResponse(fileUri);
		
		try {
			BasicExperiment exp = getExperimentFromCode(content);
			List<ValidationError<BasicExperiment>> errors = multipleComparison.validate(exp);
			
			//TODO: Refactor: Quick fix for showing correct line. (Demo 7/3/14)
			if (errors.size()>0)	errors = errors.subList(0, 1);
			//---
			
			if ( !errors.isEmpty() ) {
				response.setMessage(errors.get(0).getMessage());
				FullySpecifiedExperimentalDesign design = (FullySpecifiedExperimentalDesign) exp.getDesign().getExperimentalDesign();
				if ( design.getIntendedAnalyses().size() > 0 ) {
					RuleNode ctx = sedl4peopleUnmarsh.getListener().getObjectNodeMap().get( design.getIntendedAnalyses());
					if ( ctx == null ) {
						System.out.println("Couldn't find context node: " + design.getIntendedAnalyses().get(0));
//						System.out.println( ">> Object Map: " + sedl4peopleUnmarsh.getListener().getObjectNodeMap());
					}else {
						List<RuleNode> lCtx = new ArrayList<RuleNode>();
						lCtx.add(ctx);
						List<ValidationError<BasicExperiment>> lVal = sedlDelegate.fillValidationError(lCtx, sedl4peopleUnmarsh.getTokens(), errors);
						response.setAnnotations(ErrorBuilder.buildAnnotationsFromValidationErrors(lVal));
//						result = ErrorBuilder.buildValidationErrorStructure(sedlDelegate.fillValidationError(lCtx, sedl4peopleUnmarsh.getTokens(), errors));
					}
				}
			} else {
				response.setMessage("Statistical test are correct");
			}
			
		} catch (Exception e) {
			response.setMessage(e.getMessage());
			response.setStatus(Status.ERROR);
		}
		
		return response;
	}
	
	public AppResponse outOfRangeCSV(String content, String fileUri, String csvContent) {
		
		AppResponse response = constructBaseResponse(fileUri);
		try {
			BasicExperiment exp = getExperimentFromCode(content);
			List<ValidationError<BasicExperiment>> errors = new ArrayList<ValidationError<BasicExperiment>>();
			if(csvContent.equals("")){
				errors = outOfRange.validate(exp);
			}else{
				errors = outOfRange.validateCsv(exp,csvContent);
			}
			//response.setMessage(String.valueOf(outOfRange.validate(exp)));
			if(errors.isEmpty()){
				response.setMessage("Range of variables are correct");
			}else{
				String msg ="<div class='opError'>";
				for(ValidationError<BasicExperiment> ve : errors){
					msg = msg + "<br>" + ve.getMessage()+" -Severity: " + ve.getSeverity();
				}
				msg = msg +"</div>";
				response.setMessage(msg);
				
				FullySpecifiedExperimentalDesign design = (FullySpecifiedExperimentalDesign) exp.getDesign().getExperimentalDesign();
				RuleNode ctx = sedl4peopleUnmarsh.getListener().getObjectNodeMap().get( design.getIntendedAnalyses());
				List<RuleNode> lCtx = new ArrayList<RuleNode>();
				lCtx.add(ctx);
				List<ValidationError<BasicExperiment>> error = sedlDelegate.fillValidationError(lCtx, sedl4peopleUnmarsh.getTokens(), errors);
				//response.setAnnotations(ErrorBuilder.buildAnnotationsFromValidationErrors(error));
			}
		} catch (Exception e) {
			response.setMessage(e.getMessage());
			response.setStatus(Status.ERROR);
		}

		return response;
	}
	public AppResponse outOfRange(String content, String fileUri) {
		System.out.println("[INFO-SEDL-Lenguage] outofrange");
		AppResponse response = constructBaseResponse(fileUri);
		try {
			BasicExperiment exp = getExperimentFromCode(content);
			List<ValidationError<BasicExperiment>> errors = new ArrayList<ValidationError<BasicExperiment>>();
			List<String> csvRoots = outOfRange.parseDocument(exp);
			String result = "";

			result = stringResultOp(csvRoots);
			System.out.println("[INFO-SEDL-Lenguage]"+result);
			response.setMessage("OutOfRange configuration loaded...");
			response.setData(result);
		} catch (Exception e) {
			response.setMessage(e.getMessage());
			response.setStatus(Status.ERROR);
		}
		return response;
	}
	
	private String stringResultOp(List<String> csvRoots){
		String result = "{'execution':[";//},configuration{}}}";
		boolean first = true;
		for(String s : csvRoots){
			if(s.equals("CONFIG")){
				result = result + "],'configuration':[";
				first = true;
			}else{
				if(first){
					result = result + s ;
				}else{
					result = result + "," + s ;
				}
			}
		}
		result = result + "]}";
		System.out.println("[INFO]resultData OOR: "+result);
		return result;
	}
	
	public AppResponse computeStats(String content, String fileUri){
		AppResponse response = constructBaseResponse(fileUri);
		try {
			BasicExperiment exp = getExperimentFromCode(content);
			List<ValidationError<BasicExperiment>> errors = new ArrayList<ValidationError<BasicExperiment>>();
			List<String> csvRoots = computeStats.getCandidateDatasetFiles(exp);
			String result = "";

			result = stringResultOp(csvRoots);
			response.setData(result);
			response.setMessage("<div>Configurations exported</div>");
		} catch (Exception e) {
			response.setMessage(e.getMessage());
			response.setStatus(Status.ERROR);
		}
		return response;
	}
	
	public AppResponse computeStatsCalc(String content, String fileUri, String csvContent){
		AppResponse response = constructBaseResponse(fileUri);
		try {
			BasicExperiment exp = getExperimentFromCode(content);
			List errors = new ArrayList();
			List<StatisticalAnalysisOperation> result = new ArrayList<StatisticalAnalysisOperation>();
			if(csvContent.equals("")){
				result = computeStats.apply(exp);
			}else{
				result = computeStats.applyCSV(exp,csvContent);
			}
				String message = "Compute Stats Operation:<br>";
				for(StatisticalAnalysisOperation operation : result){
					errors = operation.getErrors();
					if(!errors.isEmpty()){		//if there are an error
						message = message + "<br><div class='opError'>There are errors in operations or dataset, maybe results are wrong: <br>";
						for(Object ve : errors){
							message = message + ((Error)ve).getMessage()+ "<br>";
						}
						message = message +"</div><br>";
						FullySpecifiedExperimentalDesign design = (FullySpecifiedExperimentalDesign) exp.getDesign().getExperimentalDesign();
						RuleNode ctx = sedl4peopleUnmarsh.getListener().getObjectNodeMap().get( design.getIntendedAnalyses());
						List<RuleNode> lCtx = new ArrayList<RuleNode>();
						lCtx.add(ctx);
						List  lError = sedlDelegate.fillValidationError(lCtx, sedl4peopleUnmarsh.getTokens(), errors);
                                                                                                        
						response.setAnnotations(ErrorBuilder.buildAnnotationsFromValidationErrors(lError));
					}else{
                                            for(int i =0; i < operation.getResults().size();i++){
						message = message + "<br> - " + operation.renderResults();
                                            }
                                        }
					message = message + "<br>";
					System.out.println("[INFO] Operation"+operation.toString());
				}
				System.out.println("[INFO] (AnalyserDelegate.computeStatsClac()) message:<br>"+message);
				response.setMessage(message);
		}catch (Exception e) {
			response.setMessage(e.getMessage());
			response.setStatus(Status.ERROR);
		}
		return response;
	}
        
        public AppResponse generateRawDataTemplatec(String content, String fileUri, String format){
            AppResponse response = constructBaseResponse(fileUri);
            String columnSeparator=";";
            try {
			BasicExperiment exp = getExperimentFromCode(content);
			List errors = new ArrayList();
                        StringBuilder message=new StringBuilder("SubjectId");
                        for(Variable var:exp.getDesign().getVariables().getVariable()){
                            message.append(columnSeparator);
                            message.append(var.getName());
                        }
                        message.append("\n");
                        response.setMessage(message.toString());
            }catch(Exception e){
                response.setMessage(e.getMessage());
                response.setStatus(Status.ERROR);
            }
            return response;
        }
        
        public AppResponse generateSeedStudy(String content, String fileUri, String additionalInfo){
            AppResponse response = constructBaseResponse(fileUri);
            String columnSeparator=";";
            try {
			BasicExperiment exp = getExperimentFromCode(content);
			List errors = new ArrayList();
                        LatexSeedStudyGenerator studyGenerator=new LatexSeedStudyGenerator();
                        response.setMessage(studyGenerator.generate(exp,additionalInfo));
                        response.setHtmlMessage("<pre>"+response.getMessage()+"</pre>");
            }catch(Exception e){
                response.setMessage(e.getMessage());
                response.setStatus(Status.ERROR);
            }
            return response;
        }

	// Aux methods
	
	private AppResponse constructBaseResponse(String fileUri) {
		AppResponse appResponse = new AppResponse();
		appResponse.setFileUri(fileUri);
		appResponse.setStatus(Status.OK);
		return appResponse;
	}

	private BasicExperiment getExperimentFromCode(String code) {
		BasicExperiment exp = (BasicExperiment) sedl4peopleUnmarsh
				.fromString(code);
		return exp;
	}


}
