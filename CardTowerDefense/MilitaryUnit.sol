
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "GameObject.sol";
import "ForwardBase.sol";

contract MilitaryUnit is GameObject {

    ForwardBase homeBase;
    int attackDmg = 8;

    constructor(ForwardBase newBase /*int dmg, int powerDefense*/) public {

        require(tvm.pubkey() != 0, 101);

        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();

        homeBase = newBase;
        newBase.addDefenderUnit(this);
    }

    function setAttackDmg (int power) virtual public onlyAccept {

        attackDmg = power;
    }

    function doAttack(GameObjectInterface enemy) public onlyAccept {
        
        enemy.getAttack(attackDmg);
    }

    function sendPrize(address killer, bool deadFlag) virtual public override onlyAccept {

        if(deadFlag) {
            homeBase.removeUnit(this);
        }
        uint16 currentFlag = 128 + 32;
        killer.transfer(0, false, currentFlag);
    }
}
