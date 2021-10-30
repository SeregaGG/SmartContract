
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "MilitaryUnit.sol";

contract Warrior is MilitaryUnit {

    int warriorOverDmg = 5;
    int warriorOverHP = 8;
    
    constructor(ForwardBase newBase) MilitaryUnit(newBase) public {

        require(tvm.pubkey() != 0, 101);

        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        
        defensePower = 4;
        attackDmg += warriorOverDmg;
        healthPoints += warriorOverHP;
    }
}
