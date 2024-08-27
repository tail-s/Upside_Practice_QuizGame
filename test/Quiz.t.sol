// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Quiz.sol";

contract QuizTest is Test {
    Quiz public quiz;
    uint quiz_num;
    address user1 = address(1337);
    Quiz.Quiz_item q1;

    function setUp() public {
       vm.deal(address(this), 100 ether);
       quiz = new Quiz();
       address(quiz).call{value: 5 ether}("");
       q1 = quiz.getQuiz(1);
    }

    function testAddQuizACL() public {
        uint quiz_num_before = quiz.getQuizNum();
        Quiz.Quiz_item memory q;
        q.id = quiz_num_before + 1;
        q.question = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        q.answer = "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        vm.prank(address(1));
        vm.expectRevert();
        quiz.addQuiz(q);
    }

    function testGetQuizSecurity() public {
        Quiz.Quiz_item memory q = quiz.getQuiz(1);
        assertEq(q.answer, "");
    }

    function testAddQuizGetQuiz() public {
        uint quiz_num_before = quiz.getQuizNum();
        Quiz.Quiz_item memory q;
        q.id = quiz_num_before + 1;
        q.question = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        q.answer = "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        quiz.addQuiz(q);
        Quiz.Quiz_item memory q2 = quiz.getQuiz(q.id);
        q.answer = "";
        assertEq(abi.encode(q), abi.encode(q2));
    }

    function testBetToPlayMin() public {
        quiz.betToPlay{value: q1.min_bet}(1);
    }

    function testBetToPlay() public {
        quiz.betToPlay{value: (q1.min_bet + q1.max_bet) / 2}(1);
    }

    function testBetToPlayMax() public {
        quiz.betToPlay{value: q1.max_bet}(1);
    }

    function testFailBetToPlayMin() public {
        quiz.betToPlay{value: q1.min_bet - 1}(1);
    }

    function testFailBetToPlayMax() public {
        quiz.betToPlay{value: q1.max_bet + 1}(1);
    }

    function testMultiBet() public {
        quiz.betToPlay{value: q1.min_bet}(1);
        quiz.betToPlay{value: q1.min_bet}(1);
        assertEq(quiz.bets(0, address(this)), q1.min_bet * 2);
    }

    function testSolve1() public {
        quiz.betToPlay{value: q1.min_bet}(1);
        assertEq(quiz.solveQuiz(1, quiz.getAnswer(1)), true);
    }

    function testSolve2() public {
        quiz.betToPlay{value: q1.min_bet}(1);
        uint256 prev_vb = quiz.vault_balance();
        uint256 prev_bet = quiz.bets(0, address(this));
        assertEq(quiz.solveQuiz(1, ""), false);
        uint256 bet = quiz.bets(0, address(this));
        assertEq(bet, 0);
        assertEq(prev_vb + prev_bet, quiz.vault_balance());
    }

    function testClaim() public {
        quiz.betToPlay{value: q1.min_bet}(1);
        quiz.solveQuiz(1, quiz.getAnswer(1));
        uint256 prev_balance = address(this).balance;
        quiz.claim();
        uint256 balance = address(this).balance;
        assertEq(balance - prev_balance, q1.min_bet * 2);
    }

    receive() external payable {}
}
