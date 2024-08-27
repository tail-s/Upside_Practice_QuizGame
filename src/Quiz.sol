// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }
    
    mapping(address => uint256)[] public bets;
    uint public vault_balance;

    constructor () {
        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public {
    }

    function getAnswer(uint quizId) public view returns (string memory){
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
    }

    function getQuizNum() public view returns (uint){
    }
    
    function betToPlay(uint quizId) public payable {
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
    }

    function claim() public {
    }

}
