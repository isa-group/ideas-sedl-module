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
import es.us.isa.sedl.core.design.FullySpecifiedExperimentalDesign;
import es.us.isa.sedl.core.design.FundamentalSetConstraint;
import es.us.isa.sedl.core.design.Group;
import es.us.isa.sedl.core.design.IntensionDomain;
import es.us.isa.sedl.core.design.IntervalConstraint;
import es.us.isa.sedl.core.design.NonControllableFactor;
import es.us.isa.sedl.core.design.Variable;
import es.us.isa.sedl.core.design.Level;
import es.us.isa.sedl.core.design.Literal;
import es.us.isa.sedl.core.design.Sizing;
import es.us.isa.sedl.core.design.VariableValuation;
import es.us.isa.sedl.core.hypothesis.AssociationalHypothesis;
import es.us.isa.sedl.core.hypothesis.DifferentialHypothesis;
import es.us.isa.sedl.core.hypothesis.Hypothesis;
import es.us.isa.sedl.core.hypothesis.RelationalHypothesis;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * @author japarejo
 */
public class LatexSeedStudyGenerator {

    private String documentClass;
    private Map<String, List<String>> importedPackages;
    private List<URL> dependences;

    public LatexSeedStudyGenerator() {
        this("article", new HashMap<String, List<String>>());
        importedPackages.put("color", Collections.EMPTY_LIST);
        importedPackages.put("hyperref", Collections.EMPTY_LIST);
        dependences = new ArrayList<>();
    }

    protected LatexSeedStudyGenerator(String documentClass, Map<String, List<String>> importedPackages) {
        this.documentClass = documentClass;
        this.importedPackages = importedPackages;
    }

    public String generate(BasicExperiment exp) {
        StringBuilder builder = new StringBuilder();
        builder.append(generatePreamble(exp))
                .append(generateFrontMatter(exp))
                .append(generateBody(exp))
                .append(generateAppendixes(exp))
                .append(generateClosing(exp));
        return builder.toString();
    }

    private String generatePreamble(BasicExperiment exp) {
        StringBuilder builder = new StringBuilder("\\documentclass{" + documentClass + "}\n");
        for (String packageToImport : importedPackages.keySet()) {
            builder.append("\\usepackage{" + packageToImport + "}\n");
        }
        builder.append("\n");
        builder.append("\\begin{document}\n");
        return builder.toString();
    }

    private String generateClosing(BasicExperiment exp) {
        return "\\end{document}\n";
    }

    private String generateFrontMatter(BasicExperiment exp) {
        return generateTitle(exp)
                + generateAuthors(exp)
                + "\n\\maketitle\n\n"
                + generateAbstract(exp)
                + "\n";
    }

    private String generateBody(BasicExperiment exp) {
        return generateIntro(exp) + generateVariables(exp) + generateHypotheses(exp) + generateDesign(exp) + generateConduction(exp) + "\n";
    }

    private String generateIntro(BasicExperiment exp) {
        String result = "\\section{Introduction}\n\\label{sec:intro}\n";
        result += generateGoal(exp);
        result += generateReportContents(exp);
        return result;
    }

    private String generateGoal(BasicExperiment exp) {
        String result = "";
        List<String> notes = exp.getContext().getNotes();
        if (notes.size() == 1) {
            result = exp.getContext().getNotes().get(0) + "\\n";
        } else if (notes.size() > 2) {
            for (int i = 0; i < (5 - notes.size()); i++) {
                notes.add("");
            }
            result += "\\textbf{Analyze} " + notes.get(0);
            result += " \\textbf{for the purpose of} " + notes.get(1);
            result += " \\textbf{with respect to} " + notes.get(2);
            result += " \\textbf{from the point of view of} " + notes.get(3);
            result += " \\textbf{in the context of} " + notes.get(4);
        }
        return result;
    }

    private String generateReportContents(BasicExperiment exp) {
        return "\n\nThe remainder of this report is structured as follows: "
                + "section \\ref{sec:variables} decribes the variables taking into account in the experiment. "
                + "Section \\ref{sec:hypotheses} describes the research hypotheses. "
                + "Section \\ref{sec:design} describes the experimental design of the study."
                + "Section \\ref{sec:analyses} describes the statistical analyses to be performed"
                + " in order to confirm or disprove the research hypotheses, and the rationale behind them. "
                + "Finally, section \\ref{sec:conclusions} describes the conclusions drawn from the study.";
    }

    private String generateAppendixes(BasicExperiment exp) {
        return generateAcnowledgements(exp) + generateMaterialsListing(exp);
    }

    private String generateTitle(BasicExperiment exp) {
        return "\\title{Report of the experiment "
                + exp.getId()
                + "\\footnote{"
                + "Generated automatically by "
                + "\\href{http://exemplar.us.es}{EXEMPLAR}"
                + "}"
                + "}\n";
    }

    private String generateAuthors(BasicExperiment exp) {
        StringBuilder builder = new StringBuilder();
        builder.append("\\author{\n");
        Person person = null;
        for (int i = 0; i < exp.getContext().getPeople().getPerson().size(); i++) {
            person = exp.getContext().getPeople().getPerson().get(i);
            if (i != 0) {
                builder.append("    \\and\n");
            }
            builder.append(person.getName());
            if ("Responsible".equals(person.getRole())) {
                if (person.getAddress() != null && !"".equals(person.getAddress())) {
                    builder.append("  Adress: " + person.getAddress());
                }
                if (person.getEmail() != null && !"".equals(person.getEmail())) {
                    builder.append("  \\\\ ")
                            .append("  E-mail: " + person.getEmail());
                }
                builder.append("\n");
            }
            if (person.getOrganization() != null && !"".equals(person.getOrganization())) {
                builder.append("\\\\ \n" + person.getOrganization());
            }
            builder.append("\n");
        }
        builder.append("}\n");
        return builder.toString();
    }

    private String generateAbstract(BasicExperiment exp) {
        String content = "";
        if (exp.getNotes().size() == 1) {
            content = exp.getNotes().get(0);
        } else {
            content = generateStructuredAbstractContent(exp);
        }
        return "\\begin{abstract}\n"
                + content
                + "\n"
                + "\\end{abstract}\n\n";
    }

    private String generateStructuredAbstractContent(BasicExperiment exp) {
        List<String> notes = exp.getNotes();
        if (notes.size() < 5) {
            for (int i = notes.size(); i <= 5; i++) {
                notes.add("");
            }
        }
        String result = "\\textbf{Context:}" + notes.get(0);
        result += "\\textbf{Goal:}" + notes.get(1);
        result += "\\textbf{Method:}" + notes.get(2);
        result += "\\textbf{Results:}" + notes.get(3);
        result += "\\textbf{Conclusions:}" + notes.get(4);
        return result;
    }

    private String generateHypotheses(BasicExperiment exp) {
        String result = "\\section{Hypotheses}\n\\label{sec:hypotheses}\n";
        List<Hypothesis> researchHypothesis = exp.getHypotheses();
        if (!researchHypothesis.isEmpty()) {
            result += "The research hypothesis of the experiment are enunciated below. When possible, for each research hypothesis, a pair of associated statistical hypothesis is formulated:\n";
            result += "\\begin{itemize}\n";
            for (Hypothesis h : researchHypothesis) {
                result += "\\item[$" + h.getId() + "$:]\n";
                result += generateHypothesis(h, exp);
                result += "\\newline\n\n";
            }
            result += "\\end{itemize}\n";
        } else {
            result += "The set of hypothesis of the experiment was empty.\n";
        }
        return result;
    }

    private String generateHypothesis(Hypothesis h, BasicExperiment exp) {
        String result = "";
        for (String note : h.getNotes()) {
            result += note + ". \n";
        }
        result += "In general, this hypotheis can be stated as: \\textit{the value of " + h.getDependentVariable();
        if (h instanceof DifferentialHypothesis) {
            result += " is impacted significantly by ";
        } else if (h instanceof AssociationalHypothesis) {
            result += " tends to fluctuate together with the values of ";
        }
        RelationalHypothesis assoH = (RelationalHypothesis) h;

        for (int i = 0; i < assoH.getIndependentVariables().size(); i++) {
            if (i != 0) {
                result += ", ";
            }
            result += assoH.getIndependentVariables().get(i);
        }
        result += "}.\n";
        if (h instanceof DifferentialHypothesis) {
            result += generateStatisticalHypotheses((DifferentialHypothesis) h, exp);
        }
        return result;
    }

    public String generateStatisticalHypotheses(DifferentialHypothesis h, BasicExperiment exp) {
        String result = "Asosociated to this research hypothesis, we can formulate two mutually "
                + "excluding statistical hypothesis: the \\textit{null hypothesis} ${" + h.getId() + "}_0$, that states that there "
                + "is not a statistically significant difference in the mean of \\textit{"
                + h.getDependentVariable() + "} for the set observations with different values of ";
        for (int i = 0; i < h.getIndependentVariables().size(); i++) {
            if (i != 0) {
                result += ", ";
            }
            result += "\\textit{" + h.getIndependentVariables().get(i) + "}";
        }
        result+="; and the \\textit{alternative hypothesis} ${" + h.getId() + "}_0$: $\\neg{H_{0,2}}$,"
                + " that states that such a difference in the means exists and it is not due to chance.";
        return result;
    }

    private String generateParameters(BasicExperiment exp) {
        return "\\section{Design Parameters}\n\\label{sec:parameters}\n";
    }

    private String generateVariables(BasicExperiment exp) {
        StringBuilder builder = new StringBuilder();
        builder.append("\\section{Variables}\n\\label{sec:variables}\n");

        builder.append("\\subsection{Factors}\n");
        builder.append("    \\begin{itemize}\n");
        for (Variable factor : exp.getDesign().getVariables().getVariable()) {
            if (factor instanceof ControllableFactor || factor instanceof NonControllableFactor) {
                builder.append(printVariable(factor, "       "));
            }
        }
        builder.append("    \\end{itemize}\n");

        builder.append("\\subsection{Outcomes}\n");
        builder.append("    \\begin{itemize}\n");
        for (Variable outcome : exp.getDesign().getVariables().getOutcomes()) {
            builder.append(printVariable(outcome, "      "));
        }
        builder.append("    \\end{itemize}\n");
        return builder.toString();
    }

    private String printVariable(Variable var, String indentation) {
        StringBuilder builder = new StringBuilder(indentation + "\\item ");
        builder.append("\\textbf{" + var.getName() + "}:\n");
        builder.append(indentation + "The domain of this variable is a " + printDomain(var.getDomain(), indentation));
        if (var.getUnits() != null && !"".equals(var.getUnits())) {
            builder.append(indentation + "This variable is measured in " + var.getUnits() + ".\n");
        }
        builder.append("\n");
        return builder.toString();
    }

    private String printDomain(Domain d, String indentation) {
        String result = "";
        if (d instanceof ExtensionDomain) {
            result = printExtensionDomain(d, indentation);
        } else {
            result = printIntensionDomain(d, indentation);
        }
        return result;
    }

    private String generateMaterialsListing(BasicExperiment exp) {
        return "";
    }

    private String printExtensionDomain(Domain d, String indentation) {
        ExtensionDomain e = (ExtensionDomain) d;
        StringBuilder builder = new StringBuilder("This is a discrete variable measured in a nominal scale. ");
        builder.append("Specifically, the levels of the variable are:\n").
                append(indentation + "\\begin{itemize}\n");
        for (Level l : e.getLevels()) {
            builder.append(indentation + "  \\item " + l.getValue() + "\n");
        }
        builder.append(indentation + "\\end{itemize}\n");
        return builder.toString();
    }

    private String printIntensionDomain(Domain d, String indentation) {
        IntensionDomain i = (IntensionDomain) d;
        StringBuilder builder = new StringBuilder("This is a " + (i.isFinite() ? "discrete" : "continuous") + " variable.");
        builder.append("Specifically, the value of this variable must meet the following constraints:\n").
                append(indentation + "\\begin{itemize}\n");
        for (Constraint c : i.getConstraint()) {
            builder.append(indentation + "  \\item " + printConstraint(c, indentation + "  ") + "\n");
        }
        builder.append(indentation + "\\end{itemize}\n");
        return builder.toString();
    }

    private String printConstraint(Constraint c, String s) {
        String result = "";
        if (c instanceof FundamentalSetConstraint) {
            result = printFundamentalSetConstraint(c, s);
        } else {
            result = printMaxMinConstraint(c, s);
        }
        return result;
    }

    private String printFundamentalSetConstraint(Constraint c, String s) {
        FundamentalSetConstraint fsc = (FundamentalSetConstraint) c;
        String result = "It is a ";
        switch (fsc.getFundamentalSet()) {
            case R:
                result += "real number.\n";
                break;
            case N:
            case Z:
                result += "integer number.\n";
                break;
            case B:
                result += "boolean value.\n";
                break;
        }
        return result;
    }

    private String printMaxMinConstraint(Constraint c, String s) {
        IntervalConstraint ic = (IntervalConstraint) c;
        return "It is comprised between " + ic.getMin() + " and " + ic.getMax();
    }

    private String generateDesign(BasicExperiment exp) {
        return "\\section{Design}\n"
                + generateSampling(exp)
                + generateAssignment(exp)
                + generateGroups(exp)
                + generateBlockingVariables(exp)
                + generateProtocol(exp);
    }

    private String generateGroups(BasicExperiment exp) {
        FullySpecifiedExperimentalDesign fsed = (FullySpecifiedExperimentalDesign) exp.getDesign().getExperimentalDesign();
        StringBuilder builder = new StringBuilder("\\subsection{Groups}\n");
        builder.append("The experimental design involves " + fsed.getGroups().size() + " groups:\n");
        builder.append("\\begin{itemize}\n");
        for (Group g : fsed.getGroups()) {
            builder.append("    \\item " + generateGroup(exp, g) + "\n");
        }
        builder.append("\\end{itemize}\n");
        return builder.toString();
    }

    private String generateGroup(BasicExperiment exp, Group g) {
        return g.getName() + ". " + generateSizing(g.getSizing()) + ". " + generateGroupValuations(g);
    }

    private String generateProtocol(BasicExperiment exp) {
        return "\\subsection{Experimental protocol}\n";
    }

    private String generateConduction(BasicExperiment exp) {
        return "\\section{Conduction}\n";
    }

    private String generateAcnowledgements(BasicExperiment exp) {
        return "\\section*{Acnowledgements}\n "
                + "The authors of this experiments are grateful to the "
                + "\\href{http://exemplar.us.es}{EXEMPLAR} development team for "
                + "providing such a wonderful tool.\n";
    }

    private String generateSampling(BasicExperiment exp) {
        String result = "";
        if (exp.getDesign().getSamplingMethod() != null) {
            result = "\\subsection{Sampling}\n";
            result += exp.getDesign().getSamplingMethod().getDescription();
            result += "\n";
        }
        return result;
    }

    private String generateAssignment(BasicExperiment exp) {
        String result = "\\subsection{Sampling}\n";
        FullySpecifiedExperimentalDesign design = (FullySpecifiedExperimentalDesign) exp.getDesign().getExperimentalDesign();
        result += "The sampling strategy was " + (design.getAssignmentMethod().isRandom() ? "random." : "custom.");
        if (design.getAssignmentMethod().getDescription() != null && !"".equals(design.getAssignmentMethod()));
        result += design.getAssignmentMethod().getDescription();
        result += "\n";
        return result;
    }

    private String generateBlockingVariables(BasicExperiment exp) {
        String result = "";
        FullySpecifiedExperimentalDesign design = (FullySpecifiedExperimentalDesign) exp.getDesign().getExperimentalDesign();
        if (!design.getBlockingVariables().isEmpty()) {
            result = "\\subsection{Blocking Variables}\n"
                    + "The variables to be bloked in the design are: " + design.getBlockingVariables().get(0);
            for (int i = 1; i < design.getBlockingVariables().size(); i++) {
                result += (", " + design.getBlockingVariables().get(i));
            }
            result += "\n";
        }
        return result;
    }

    public String getDocumentClass() {
        return documentClass;
    }

    public Map<String, List<String>> getImportedPackages() {
        return importedPackages;
    }

    public List<URL> getDependences() {
        return dependences;
    }

    private String generateSizing(Sizing sizing) {
        String result = "";
        if (sizing instanceof Literal) {
            Literal literalSizing = (Literal) sizing;
            result = "The size of this group at the end of the experiment was " + literalSizing.getValue();
        }
        return result;
    }

    private String generateGroupValuations(Group g) {
        String result = "";
        if (!g.getValuations().isEmpty()) {
            result = "This group will meet the following constraints:\n"
                    + "\\begin{itemize}\n";
            for (VariableValuation valuation : g.getValuations()) {
                result += "  \\item \\textit{" + valuation.getVariable().getName() + "} ";
                result += " presents the value " + valuation.getLevel() + ".\n";
            }
            result += "\\end{itemize}\n";
        }
        return result;
    }

}
