pragma solidity 0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";



contract voting is Ownable {
//definition des variables de base 
address public administrateur; 
Proposal[] public proposals; 
uint public winningProposalId;

// definition des structs (fourni par l'exo ne pas toucher )

struct Voter {
    bool isRegistered;
    bool hasVoted;
    uint votedProposalId;
    }

struct Proposal {
    string description;
    uint voteCount;
    }
// definition des enums (fourni par l'exo ne pas toucher )

enum WorkflowStatus {
    RegisteringVoters,
    ProposalsRegistrationStarted,
    ProposalsRegistrationEnded,
    VotingSessionStarted,
    VotingSessionEnded,
    VotesTallied
    }
WorkflowStatus public workflowstatus; 

// le mapping qui definit si un voter peut voter 
mapping (address => Voter) public voters;    

// liste des events (fourni par l'exo ne pas toucher )
 
event VoterRegistered(address voterAddress);
event ProposalsRegistrationStarted();
event ProposalsRegistrationEnded();
event ProposalRegistered(uint proposalId);
event VotingSessionStarted();
event VotingSessionEnded();
event Voted (address voter, uint proposalId);
event VotesTallied();
event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus
newStatus);



// definition du constructeur, admin = msg.sender et workflow status passe en mode registeringvoters. 
constructor() {
    administrateur = msg.sender; 
    workflowstatus = WorkflowStatus.RegisteringVoters;
    
}


// modifier qui s'assure que l'admin seul a le droit de faire 

modifier onlyAdmin(){
    require(msg.sender==administrateur, "You must be admin");
    _;
    }
    
//modifier qui verifier que la fonction utilisée est bien dans le mode only registering voters

modifier onlyRegistering(){
    require(workflowstatus==WorkflowStatus.RegisteringVoters,"You cannot propose in the current state");
    _;
    
}

// modifier qui permet de verifier que nous sommes bien au status ProposalsRegistrationStarted
modifier onlyProposal(){
    require(workflowstatus == WorkflowStatus.ProposalsRegistrationStarted, 'You cannot propose in the current state');
    _;
}

modifier onlyProposalEnd(){
    require(workflowstatus == WorkflowStatus.ProposalsRegistrationEnded, " the proposal workflow is not started");
    _;
    
}



modifier onlyRegisteredVoters() {
    require (voters[msg.sender].isRegistered);
    _;
    
}
modifier onlyRecProposal(){
    require(workflowstatus == WorkflowStatus.ProposalsRegistrationEnded, " the proposal workflow is not ended");
    _;
    
}



modifier onlyVoting(){
    require(workflowstatus == WorkflowStatus.VotingSessionStarted, ' the voting session is not started');
    _;
    
}

modifier onlyVotingEnd(){
    require(workflowstatus == WorkflowStatus.VotingSessionEnded, ' the voting session is not stop');
    _;
    
}

modifier onlyAfterTailed(){
    require(workflowstatus == WorkflowStatus.VotesTallied, 'the tailed session is not over');
    _;
}
// moteur d'enregistrement des votants s'assure que seul l'admin peut faire et que le workflow est bien en enregistrement. 

function I_enregistreVoters(address _voteurAddress) public onlyAdmin onlyRegistering{
    require(!voters[_voteurAddress].isRegistered, 'address already registered');
    voters[_voteurAddress].isRegistered=true;
    voters[_voteurAddress].hasVoted = false;
    voters[_voteurAddress].votedProposalId=0; 
    emit VoterRegistered(_voteurAddress); 
  
    
    }
// on lance la proposition des votes, on met le status du workflow a ProposalsRegistrationStarted et on lance
// les events ProposalsRegistrationStarted & on dit qu'on modifie le status de RegisteringVoters a ProposalsRegistrationStarted

function II_demarreEnregistrementVotes() public onlyAdmin onlyRegistering{
    workflowstatus = WorkflowStatus.ProposalsRegistrationStarted;
    emit ProposalsRegistrationStarted();
    emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
    
    }
    
    


//Enregistrement des propositions de vote. verifie avec le modifier que seuls les utilisateurs enregistrés et que le workflow est correct

function III_recProposal(string memory proposition)  public  onlyRegisteredVoters onlyProposal {
    proposals.push(Proposal({description: proposition, voteCount: 0}));
    
    emit ProposalRegistered(proposals.length -1); 
    
    } 

    
    // stop les propositions seulement accessible a l'admin et ne peut etre passé en ce status que si on est a l'état only proposal 
    
function IV_arretPropositions() public onlyAdmin onlyProposal{
    workflowstatus = WorkflowStatus.ProposalsRegistrationEnded;
    emit ProposalsRegistrationEnded();
    emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);
    
    
    }
function V_votingSessionStart() public onlyAdmin onlyProposalEnd{
    workflowstatus = WorkflowStatus.VotingSessionStarted;
    emit VotingSessionStarted();
    emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);
    } 



function VI_vote(uint propositionId) public onlyRegisteredVoters onlyVoting {
    require(!voters[msg.sender].hasVoted, 'had already voted');
    voters[msg.sender].votedProposalId = propositionId;
    voters[msg.sender].hasVoted = true; 
    proposals[propositionId].voteCount +=1; 
    emit Voted(msg.sender, propositionId);
    
    
    
    }
    
function VII_votingSessionStop() public onlyAdmin onlyVoting{
    workflowstatus = WorkflowStatus.VotingSessionEnded;
    emit VotingSessionEnded();
    emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
    
    
    
    }
function VIII_TotalDesVotes() onlyAdmin onlyVotingEnd public{
    uint decompteDesVotes = 0;
    uint indexDesPropositions = 0;
    for(uint i=0; i< proposals.length;i++) {
        if( proposals[i].voteCount > decompteDesVotes){
            decompteDesVotes  = proposals[i].voteCount;
            indexDesPropositions = i;
            
            }
        }
    winningProposalId = indexDesPropositions;
    workflowstatus = WorkflowStatus.VotesTallied;
    emit VotesTallied();
    
    }    
function IX_getWinningProposalID() onlyAfterTailed public view returns(uint) {
    return winningProposalId; 
    
    }

function X_winningProposalDesc() onlyAfterTailed  public view returns(string memory) { 
    return  proposals[winningProposalId].description;
    

    }
function XI_winningProposalCount() onlyAfterTailed public view returns(uint)    {
    return proposals[winningProposalId].voteCount; 
    
}

}
