
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;


contract MarketQueue {
    
    string[] public PeopleInQueue;

    constructor() public {

        require(tvm.pubkey() != 0, 101);

        require(msg.pubkey() == tvm.pubkey(), 102);

        tvm.accept();
    }

    modifier checkOwnerAndAccept {
		
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

    function removeElementByIndex(string[] queue, uint256 index) public pure returns(string[]){

        for (uint256 i = index; i < queue.length - 1; i++) {
            queue[i] = queue[i + 1];
        }
        queue.pop();
        return queue;
    }

    function QueueEntry(string name) public checkOwnerAndAccept {

        PeopleInQueue.push(name);
    }

    function QueueExit() public checkOwnerAndAccept {
        
        require(!PeopleInQueue.empty(), 101);
        PeopleInQueue = removeElementByIndex(PeopleInQueue, 0);
    }
}
