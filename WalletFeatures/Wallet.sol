pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;


contract Wallet {

    constructor() public {

        require(tvm.pubkey() != 0, 101);

        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }


    modifier checkOwnerAndAccept {

        require(msg.pubkey() == tvm.pubkey(), 100);

		tvm.accept();
		_;
	}


    function sendTransactionSenderExpenses(address dest, uint128 value) public pure checkOwnerAndAccept {

        dest.transfer(value, true, 1);
    }

    function sendTransactionPayeeExpenses(address dest, uint128 value) public pure checkOwnerAndAccept {

        dest.transfer(value, true, 0);
    }

    function sendAllMoneyAndDestroy(address dest) public pure checkOwnerAndAccept {
        uint16 currentFlag = 128 + 32;
        dest.transfer(0, true, currentFlag);
    }

}