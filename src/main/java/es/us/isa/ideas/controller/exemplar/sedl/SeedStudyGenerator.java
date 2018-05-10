/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.us.isa.ideas.controller.exemplar.sedl;

import es.us.isa.sedl.core.BasicExperiment;
import es.us.isa.sedl.core.context.Person;
import es.us.isa.sedl.core.design.Constraint;
import es.us.isa.sedl.core.design.ControllableFactor;
import es.us.isa.sedl.core.design.Domain;
import es.us.isa.sedl.core.design.ExtensionDomain;
import es.us.isa.sedl.core.design.FundamentalSetConstraint;
import es.us.isa.sedl.core.design.IntensionDomain;
import es.us.isa.sedl.core.design.IntervalConstraint;
import es.us.isa.sedl.core.design.NonControllableFactor;
import es.us.isa.sedl.core.design.Variable;
import es.us.isa.sedl.core.design.Level;


/**
 *
 * @author japarejo
 */
public class SeedStudyGenerator {

    public String generate(BasicExperiment exp) {
        StringBuilder builder=new StringBuilder();
        builder.append(generatePreamble(exp))
                .append(generateFrontMatter(exp))
                .append(generateBody(exp))
                .append(generateAppendixes(exp))
                .append(generateClosing(exp));
        return builder.toString();
    }

    private String generatePreamble(BasicExperiment exp) {
        return  "\\documentclass{article}\n"    +
                "\\usepackage{color}\n"           +
                "\\usepackage{graphicx}\n"      +
                "\\usepackage{hyperref}\n"      +
                "\n"                            +
                "\\begin{document}\n";
    }
    
    private String generateClosing(BasicExperiment exp) {
        return  "\\end{document}\n";
    }

    private String generateFrontMatter(BasicExperiment exp) {
        return generateTitle(exp)
                +generateAuthors(exp)
                +"\n\\maketitle\n\n"
                +generateAbstract(exp)
                +"\n";
    }
    
    private String generateBody(BasicExperiment exp) {
        return generateVariables(exp)+generateHypotheses(exp)+generateDesign(exp)+generateConduction(exp)+"\n";
    }

    private String generateAppendixes(BasicExperiment exp) {
        return generateMaterialsListing(exp);
    }

    private String generateTitle(BasicExperiment exp) {
        return "\\title{Report of the experiment "
                + exp.getId()
                +   "\\footnote{"
                +       "Generated automatically by "
                +       "\\href{http://exemplar.us.es}{EXEMPLAR}"
                +   "}"
                + "}\n";
    }

    private String generateAuthors(BasicExperiment exp) {
        StringBuilder builder=new StringBuilder();
        builder.append("\\author{\n");        
        Person person=null;
        for(int i=0;i<exp.getContext().getPeople().getPerson().size();i++){            
            person=exp.getContext().getPeople().getPerson().get(i);
            if(i!=0)
                builder.append("    \\and\n");
            builder.append( person.getName());
            if("Responsible".equals(person.getRole())){                
                if(person.getAddress()!=null && !"".equals(person.getAddress()))
                       builder.append("  Adress: "+person.getAddress());
                if(person.getEmail()!=null && !"".equals(person.getEmail()))
                    builder .append("  \\\\ ")
                            .append("  E-mail: "+person.getEmail()+"\\\\ ");
                builder.append("\n");
            }
            if(person.getOrganization()!=null && !"".equals(person.getOrganization()))
                builder.append( person.getOrganization());
            builder.append("\\\\ \n");                               
        }
        builder.append("}\n");
        return builder.toString();
    }

    private String generateAbstract(BasicExperiment exp) {
        String content="";
        if(exp.getNotes().size()>0)
            content=exp.getNotes().get(0);
        return "\\begin{abstract}\n"
                +
                content
                +"\n"
                + "\\end{abstract}\n\n";
    }
    
    private String generateHypotheses(BasicExperiment exp) {
        return "\\section{Hypotheses}\n";
    }

    private String generateParameters(BasicExperiment exp) {
        return "\\section{Parameters}\n";
    }
    
    private String generateVariables(BasicExperiment exp) {
        StringBuilder builder=new StringBuilder();
        builder.append("\\section{Variables}\n");
        
        builder.append("\\subsection{Factors}\n");
        builder.append("    \\begin{itemize}\n");
        for(Variable factor:exp.getDesign().getVariables().getVariable()){
                if(factor instanceof ControllableFactor || factor instanceof NonControllableFactor)
                    builder.append(printVariable(factor,"       "));
        }
        builder.append("    \\end{itemize}\n");
        
        builder.append("\\subsection{Outcomes}\n");
        builder.append("    \\begin{itemize}\n");
        for(Variable outcome:exp.getDesign().getVariables().getOutcomes()){                
                    builder.append(printVariable(outcome,"      "));
        }
        builder.append("    \\end{itemize}\n");
        return builder.toString();
    }
    
    private String printVariable(Variable var,String indentation){
        StringBuilder builder=new StringBuilder(indentation+"\\item ");
        builder.append("\\textbf{"+var.getName()+"}:\n");
        builder.append(indentation+"The domain of this variable is a "+printDomain(var.getDomain(),indentation));
        if(var.getUnits()!=null && !"".equals(var.getUnits())){
            builder.append(indentation+"This variable is measured in "+var.getUnits()+".\n");
        }
        builder.append("\n");
        return builder.toString();
    }
    
    private String printDomain(Domain d,String indentation){
        String result="";
        if(d instanceof ExtensionDomain)
            result=printExtensionDomain(d,indentation);
        else
            result=printIntensionDomain(d,indentation);
        return result;
    }
    
    private String generateMaterialsListing(BasicExperiment exp) {
        return "";
    }    

    private String printExtensionDomain(Domain d, String indentation) {
        ExtensionDomain e=(ExtensionDomain)d;
        StringBuilder builder=new StringBuilder("This is a discrete variable measured in a nominal scale. ");
        builder.append("Specifically, the levels of the variable are:\n").
                append(indentation+"\\begin{itemize}\n");
        for(Level l:e.getLevels()){
            builder.append(indentation+"  \\item "+l.getValue()+"\n");
        }
        builder.append(indentation+"\\end{itemize}\n");
        return builder.toString();
    }

    private String printIntensionDomain(Domain d, String indentation) {
        IntensionDomain i=(IntensionDomain)d;
        StringBuilder builder=new StringBuilder("This is a "+(i.isFinite()?"discrete":"continuous")+" variable.");
        builder.append("Specifically, the value of this variable must meet the following constraints:\n").
                append(indentation+"\\begin{itemize}\n");
        for(Constraint c:i.getConstraint()){
            builder.append(indentation+"  \\item "+printConstraint(c,indentation+"  ")+"\n");
        }
        builder.append(indentation+"\\end{itemize}\n");
        return builder.toString();
    }
    
    private String printConstraint(Constraint c,String s){
        String result="";
        if(c instanceof FundamentalSetConstraint)
            result=printFundamentalSetConstraint(c,s);
        else
            result=printMaxMinConstraint(c,s);
        return result;
    }

    private String printFundamentalSetConstraint(Constraint c, String s) {
        FundamentalSetConstraint fsc=(FundamentalSetConstraint)c;
        String result="It is a ";
        switch(fsc.getFundamentalSet()){
            case R:
                result+="real number.\n";
                break;
            case N:
            case Z:
                result+="integer number.\n";
                break;
            case B:
                result+="boolean value.\n";
                break;            
        }
        return result;
    }

    private String printMaxMinConstraint(Constraint c, String s) {
        IntervalConstraint ic=(IntervalConstraint)c;        
        return "It is comprised between "+ic.getMin()+" and "+ic.getMax();
    }

    private String generateDesign(BasicExperiment exp) {
        return "\\section{Design}\n";
    }

    private String generateConduction(BasicExperiment exp) {
        return "\\section{Conduction}\n";
    }
    
    
    
}
