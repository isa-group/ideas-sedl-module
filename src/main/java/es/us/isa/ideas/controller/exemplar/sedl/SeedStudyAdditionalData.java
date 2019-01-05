/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.us.isa.ideas.controller.exemplar.sedl;

import es.us.isa.ideas.controller.exemplar.sedl.util.Node;
import java.io.Serializable;

/**
 *
 * @author japarejo
 */
public class SeedStudyAdditionalData implements Serializable {
    
    private Node[] workspaceContents;
    private String statsComputation;
    private String currentUser;
    private String currentWorkspace;
    private String currentProject;

    /**
     * @return the workspaceContents
     */
    public Node[] getWorkspaceContents() {
        return workspaceContents;
    }

    
    /**
     * @return the statsComputation
     */
    public String getStatsComputation() {
        return statsComputation;
    }

    /**
     * @param statsComputation the statsComputation to set
     */
    public void setStatsComputation(String statsComputation) {
        this.statsComputation = statsComputation;
    }
    

    /**
     * @return the currentUser
     */
    public String getCurrentUser() {
        return currentUser;
    }

    /**
     * @param currentUser the currentUser to set
     */
    public void setCurrentUser(String currentUser) {
        this.currentUser = currentUser;
    }

    /**
     * @return the currentWorkspace
     */
    public String getCurrentWorkspace() {
        return currentWorkspace;
    }

    /**
     * @param currentWorkspace the currentWorkspace to set
     */
    public void setCurrentWorkspace(String currentWorkspace) {
        this.currentWorkspace = currentWorkspace;
    }

    public String getCurrentProject() {
        return this.currentProject;
    }

    public void setCurrentProject(String currentProject) {
        this.currentProject = currentProject;
    }

    /**
     * @param workspaceContents the workspaceContents to set
     */
    public void setWorkspaceContents(Node[] workspaceContents) {
        this.workspaceContents = workspaceContents;
    }
    
    
}
