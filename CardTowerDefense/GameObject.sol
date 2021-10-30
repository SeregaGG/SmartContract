
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "GameObjectInterface.sol";

contract GameObject is GameObjectInterface {

    int defensePower = 0;
    int healthPoints = 5;
    bool private isDead = false;
    

    modifier onlyAccept {

		tvm.accept();
		_;
	}

    function setDefensePower(int power) external onlyAccept {
        
        defensePower = power;
    }

    function setIsDead() internal onlyAccept {

        isDead = true;
    }

    function checkIsDead() public onlyAccept returns(bool) {

        return isDead;
    }

    function sendPrize(address killer, bool deadFlag) virtual public onlyAccept {

        uint16 currentFlag = 128 + 32;
        killer.transfer(0, false, currentFlag);
    }

    function getAttack(int dmg) external override onlyAccept {

        healthPoints -= (dmg - defensePower); // dmg > defensePower or enemy will heal us
        

        if(healthPoints <= 0) {
            setIsDead();
            sendPrize(address(msg.pubkey()), checkIsDead());
        }
    }
}
