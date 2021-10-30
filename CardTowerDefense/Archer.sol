
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "MilitaryUnit.sol";

contract Archer is MilitaryUnit {

    int archerOverDmg = 7;
    int archerOverHP = 6;

    constructor(ForwardBase newBase) MilitaryUnit(newBase) public {

        require(tvm.pubkey() != 0, 101);

        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        
        defensePower = 1;
        attackDmg += archerOverDmg;
        healthPoints += archerOverHP;
    }
}
