
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Composition {

    constructor() public {

        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    uint currentCompositionKey;

    struct CompositionToken {
        string compositionName;
        string genre;
        string composerName;
    }

    CompositionToken[] compositions;

    mapping (uint => mapping (uint => uint)) ownerTokens; //address => (key => price)

    mapping (uint => bool) forSale; //key => forSale

    modifier checkOwnerAndAccept(string compositionName) {

        currentCompositionKey = 0;
        
        for (uint256 index = 0; index < compositions.length; index++) {
            
            if(compositions[index].compositionName == compositionName) {

                currentCompositionKey = index;
                break;
            }
        }

        require(compositions[currentCompositionKey].compositionName == compositionName, 101);
        require(ownerTokens[msg.pubkey()].exists(currentCompositionKey), 101);

		tvm.accept();
		_;
	}

    modifier checkUniqueAndAccept(string compositionName) {

        for (uint256 index = 0; index < compositions.length; index++) {

            require(compositionName != compositions[index].compositionName, 101);
        }

		tvm.accept();
		_;
	}

    function addComposition(string compositionName, string genre, string composerName, uint128 price) public checkUniqueAndAccept(compositionName) {

        compositions.push(CompositionToken(compositionName, genre, composerName));
        ownerTokens[msg.pubkey()][compositions.length - 1] = price;
        forSale[compositions.length - 1] = false;

    }

    function setForSale(string compositionName, uint128 price) public checkOwnerAndAccept(compositionName){

        forSale[currentCompositionKey] = true;
        ownerTokens[msg.pubkey()][currentCompositionKey] = price;
    }
}
