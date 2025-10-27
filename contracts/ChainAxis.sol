// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ChainAxis
 * @dev Decentralized project management and milestone tracking system
 */
contract Project {
    
    struct ProjectInfo {
        uint256 id;
        string name;
        string description;
        address owner;
        uint256 budget;
        uint256 timestamp;
        ProjectStatus status;
    }
    
    struct Milestone {
        uint256 id;
        uint256 projectId;
        string title;
        string description;
        uint256 reward;
        address assignee;
        bool completed;
        uint256 completionTime;
    }
    
    enum ProjectStatus { Active, Completed, Cancelled }
    
    uint256 private projectCounter;
    uint256 private milestoneCounter;
    
    mapping(uint256 => ProjectInfo) public projects;
    mapping(uint256 => Milestone) public milestones;
    mapping(uint256 => uint256[]) public projectMilestones;
    mapping(address => uint256[]) public userProjects;
    
    event ProjectCreated(uint256 indexed projectId, string name, address indexed owner, uint256 budget);
    event MilestoneCreated(uint256 indexed milestoneId, uint256 indexed projectId, string title, uint256 reward);
    event MilestoneCompleted(uint256 indexed milestoneId, address indexed assignee, uint256 reward);
    event ProjectStatusChanged(uint256 indexed projectId, ProjectStatus newStatus);
    
    modifier onlyProjectOwner(uint256 _projectId) {
        require(projects[_projectId].owner == msg.sender, "Not project owner");
        _;
    }
    
    modifier projectExists(uint256 _projectId) {
        require(_projectId > 0 && _projectId <= projectCounter, "Project does not exist");
        _;
    }
    
    /**
     * @dev Create a new project with budget
     * @param _name Project name
     * @param _description Project description
     */
    function createProject(string memory _name, string memory _description) external payable returns (uint256) {
        require(bytes(_name).length > 0, "Project name cannot be empty");
        require(msg.value > 0, "Project budget must be greater than 0");
        
        projectCounter++;
        
        projects[projectCounter] = ProjectInfo({
            id: projectCounter,
            name: _name,
            description: _description,
            owner: msg.sender,
            budget: msg.value,
            timestamp: block.timestamp,
            status: ProjectStatus.Active
        });
        
        userProjects[msg.sender].push(projectCounter);
        
        emit ProjectCreated(projectCounter, _name, msg.sender, msg.value);
        
        return projectCounter;
    }
    
    /**
     * @dev Create a milestone for a project
     * @param _projectId Project ID
     * @param _title Milestone title
     * @param _description Milestone description
     * @param _reward Reward amount for milestone completion
     * @param _assignee Address of the person assigned to complete the milestone
     */
    function createMilestone(
        uint256 _projectId,
        string memory _title,
        string memory _description,
        uint256 _reward,
        address _assignee
    ) external projectExists(_projectId) onlyProjectOwner(_projectId) returns (uint256) {
        require(bytes(_title).length > 0, "Milestone title cannot be empty");
        require(_reward > 0, "Reward must be greater than 0");
        require(_assignee != address(0), "Invalid assignee address");
        require(projects[_projectId].status == ProjectStatus.Active, "Project is not active");
        require(_reward <= projects[_projectId].budget, "Reward exceeds project budget");
        
        milestoneCounter++;
        
        milestones[milestoneCounter] = Milestone({
            id: milestoneCounter,
            projectId: _projectId,
            title: _title,
            description: _description,
            reward: _reward,
            assignee: _assignee,
            completed: false,
            completionTime: 0
        });
        
        projectMilestones[_projectId].push(milestoneCounter);
        
        emit MilestoneCreated(milestoneCounter, _projectId, _title, _reward);
        
        return milestoneCounter;
    }
    
    /**
     * @dev Complete a milestone and transfer reward
     * @param _milestoneId Milestone ID
     */
    function completeMilestone(uint256 _milestoneId) external {
        require(_milestoneId > 0 && _milestoneId <= milestoneCounter, "Milestone does not exist");
        
        Milestone storage milestone = milestones[_milestoneId];
        ProjectInfo storage project = projects[milestone.projectId];
        
        require(!milestone.completed, "Milestone already completed");
        require(msg.sender == project.owner, "Only project owner can mark milestone as complete");
        require(project.status == ProjectStatus.Active, "Project is not active");
        require(project.budget >= milestone.reward, "Insufficient project budget");
        
        milestone.completed = true;
        milestone.completionTime = block.timestamp;
        project.budget -= milestone.reward;
        
        payable(milestone.assignee).transfer(milestone.reward);
        
        emit MilestoneCompleted(_milestoneId, milestone.assignee, milestone.reward);
    }
    
    // View functions
    
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