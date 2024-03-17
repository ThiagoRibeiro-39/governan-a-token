// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract ColabToken {
    // Variáveis de estado
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    address private _owner;

    // Informações públicas do token
    string public name = "ColabToken";
    string public symbol = "CLB";
    uint8 public decimals = 18;

    // Estrutura de Proposta
    struct Proposal {
        string description;
        uint256 voteCount;
        mapping(address => bool) votes;
    }
   
    Proposal[] public proposals;

    // Eventos
    event Transfer(address indexed from, address indexed to, uint256 value);
    event ProposalCreated(uint256 proposalId, string description);
    event Voted(address indexed voter, uint256 proposalId);

    // Modificador de acesso restrito ao dono do contrato
    modifier onlyOwner {
        require(msg.sender == _owner, "ColabToken: Not the owner");
        _;
    }

    // Construtor do contrato
    constructor() {
        _owner = msg.sender;
        _totalSupply = 1_000_000 * 10 ** decimals;
        _balances[_owner] = _totalSupply;
    }

    // Função para criar uma proposta
    function createProposal(string memory description) external onlyOwner {
        Proposal storage newProposal = proposals.push();
        newProposal.description = description;
        newProposal.voteCount = 0;

        emit ProposalCreated(proposals.length - 1, description);
    }

    // Função para votar em uma proposta
    function vote(uint256 proposalId) external {
        require(proposalId < proposals.length, "ColabToken: Invalid proposalId");
        require(!proposals[proposalId].votes[msg.sender], "ColabToken: Already voted on this proposal");

        uint256 votes = 0;
        if (_balances[msg.sender] <= 1000) {
            votes = 1;
        } else if (_balances[msg.sender] <= 5000) {
            votes = 2;
        } else if (_balances[msg.sender] <= 10000) {
            votes = 5;
        }

        proposals[proposalId].voteCount += votes;
        proposals[proposalId].votes[msg.sender] = true;

        emit Voted(msg.sender, proposalId);
    }

    // Função para obter o saldo de um endereço
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    // Função para transferir tokens
    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    // Função interna para transferir tokens
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ColabToken: transfer from the zero address");
        require(recipient != address(0), "ColabToken: transfer to the zero address");
        require(_balances[sender] >= amount, "ColabToken: transfer amount exceeds balance");
        
        _balances[sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }
}
