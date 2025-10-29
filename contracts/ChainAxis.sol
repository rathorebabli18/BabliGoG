View functions
    
    function getProject(uint256 _projectId) external view projectExists(_projectId) returns (ProjectInfo memory) {
        return projects[_projectId];
    }
    
    function getMilestone(uint256 _milestoneId) external view returns (Milestone memory) {
        require(_milestoneId > 0 && _milestoneId <= milestoneCounter, "Milestone does not exist");
        return milestones[_milestoneId];
    }
    
    function getProjectMilestones(uint256 _projectId) external view projectExists(_projectId) returns (uint256[] memory) {
        return projectMilestones[_projectId];
    }
    
    function getUserProjects(address _user) external view returns (uint256[] memory) {
        return userProjects[_user];
    }
    
    function getProjectCount() external view returns (uint256) {
        return projectCounter;
    }
    
    function getMilestoneCount() external view returns (uint256) {
        return milestoneCounter;
    }
}
// 
update
// 
