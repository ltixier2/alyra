pragma solidity 0.8.10;

import '@openzeppelin/contracts/access/Ownable.sol';

contract Voting is Ownable{
        struct voter {
                bool isRegistered;
                bool hasVoted;
                uint votedProposalId;
        }

        mapping(address => voter) Voters; 

        struct Proposal {
                string description;
                uint voteCount;
        }      
        Proposal[] public proposal; 

        enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
        }
        WorkflowStatus currentWFS;

        //démarre le workflow
        function activateWorkflow() external onlyOwner {
                currentWFS = WorkflowStatus.RegisteringVoters;
        }
        //modifier qui limite l'usage de la periode d'enregistrement des voters (utilisé dans fonction addVoters)

        modifier onlyWhenListingVoters() {
                require (currentWFS == WorkflowStatus.RegisteringVoters); 
                _;
        }


        //Fonction addVoter pour ajouter un nouveau votant (attention seul l'admin a le droit et seulement pendant le workflow RegisteringVoters)       
        function addVoter(address _voter) external onlyWhenListingVoters onlyOwner{
                require (Voters[_voter].isRegistered == false);
                Voters[_voter].isRegistered = true;
                
                
 
        }
        
        
        
        //Check pour voir si une adresse est enregistrée.
        function isRegisteredVoter(address _voter) external view returns(bool){
                return Voters[_voter].isRegistered;
                
        } 
        
        //comme son nom l'indique pour connaitre a quel endroit du workflow nous sommes.        
        function currentWorkFlowStatus() external view returns (WorkflowStatus){
                return currentWFS;
        
        }
        
        //ici on active le workflow n°2 : ProposalsRegistrationStarted
        function activateRecordProposals() external onlyOwner onlyWhenListingVoters{
                currentWFS = WorkflowStatus.ProposalsRegistrationStarted;
                

               }

        //modifier de fonction pour verifier le status du workflow.
        modifier onlyWhenProposalRegistrations() {
                require (currentWFS == WorkflowStatus.ProposalsRegistrationStarted);
                _;
                
        }
        function createProposal(string memory _description) public onlyWhenProposalRegistrations {
                proposal.push (Proposal(_description,0));

        }
        //retourne le nombre de propositions
        function nbrProposals() public view returns (uint) {
                return proposal.length;

        }
        //filtrer par numéro de proposition
        function descProposal(uint i) external view returns (string memory) {
                return proposal[i].description;

        }

        //listing des propositions 
        function listAllProposal() external view returns (string[] memory) {
                string[] memory  prop = new string[] (proposal.length); 
                for (uint i=0; i < proposal.length; i++) {
                        prop[i] = proposal[i].description;
                }
                return prop;
        }

        //démarre les votes
        function startVotingSession() external onlyOwner onlyWhenProposalRegistrations{
                currentWFS = WorkflowStatus.VotingSessionStarted;

        }

        //modifier pour verifier que nous sommes bien en session de vote. 
        modifier onlyWhenVotingSessionStarted() {
                require (currentWFS == WorkflowStatus.VotingSessionStarted);
                _;
        }


        function vote( uint _proposalid ) external onlyWhenVotingSessionStarted{
                address _address = msg.sender;
                require(Voters[_address].isRegistered,'address not registered');
                require(!Voters[_address].hasVoted, 'Already voted');
                proposal[_proposalid].voteCount++;
                Voters[_address].hasVoted=true; 
                }

        function seeVotes() public view returns(uint[] memory) {
                uint longueur = proposal.length;
                uint[] memory proposalValue = new uint[](longueur);
                for (uint i=0 ; i<proposal.length ; i++){
                        proposalValue[i] = proposal[i].voteCount; 

                
                }
                return proposalValue;
        }
/*  struct voter {
                bool isRegistered;
                bool hasVoted;
                uint votedProposalId;
        }

        mapping(address => voter) Voters; 
        
        struct Proposal {
                string description;
                uint voteCount;
        }      
        Proposal[] public proposal; */
        
}


